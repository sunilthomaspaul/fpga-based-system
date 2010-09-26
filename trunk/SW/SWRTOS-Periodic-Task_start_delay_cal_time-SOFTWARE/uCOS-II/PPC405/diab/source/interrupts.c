/*
 * (C) Copyright 2000
 * Wolfgang Denk, DENX Software Engineering, wd@denx.de.
 *
 * See file CREDITS for list of people who contributed to this
 * project.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 */

#include "types.h"
#include "ppc.h"
#include "ppc4xx.h"
#include "walnut.h"

/* interrupt vector functions. */
struct	irq_action {
	 interrupt_handler_t *handler;
	 void *arg;
	 int count;
};

static struct irq_action irq_vecs[32];

/****************************************************************************/

void enable_interrupts (void)
{
	ppcMtmsr (ppcMfmsr() | MSR_EE);
}

/* returns flag if MSR_EE was set before */
int disable_interrupts (void)
{
	uint32 msr = ppcMfmsr();
	ppcMtmsr (msr & ~MSR_EE);
	return ((msr & MSR_EE) != 0);
}

/****************************************************************************/

void interrupt_init ()
{
  int vec;

  /* Mark all irqs as free */
  for (vec=0; vec<32; vec++)
    {
      irq_vecs[vec].handler = NULL;
      irq_vecs[vec].arg = NULL;
      irq_vecs[vec].count = 0;
    }

  /* Init PIT. */
  ppcMtpit(BUS_RATE_IN_MHZ * 1000 * TICK_RATE);

  /* Enable PIT */
  ppcMttcr(0x04400000);
  
  /* Set vector base to 0. */
  /* 18/9 sganesh: initialised in startup code */
  /*ppcMtevpr(0x00000000); */
 
  /* Init UIC */
  ppcMtuicsr(0xFFFFFFFF);          /* clear all ints */
  ppcMtuicer(0x00000000);          /* enable required ints */
  ppcMtuiccr(0x00000020);          /* set all but FPGA SMI to non-critical*/
  ppcMtuicpr(0xFFFFFFE0);          /* set int polarities */
  ppcMtuictr(0x10000000);          /* set int trigger levels */
  ppcMtuicvcr(0x00000000);         /* set vect base=0,INT0 highest priority*/
  ppcMtuicsr(0xFFFFFFFF);          /* clear all ints */

}

/****************************************************************************/

/*
 * Handle external interrupts
 */
void external_interrupt()
{
  uint32 uic_msr;
  uint32 msr_shift;
  int vec;

  /*
   * Read masked interrupt status register to determine interrupt source
   */
  uic_msr = ppcMfuicmsr();
  msr_shift = uic_msr;
  vec = 0;
  
  while (msr_shift != 0)
    {
      if (msr_shift & 0x80000000)
        {
          /*
           * Increment irq counter (for debug purpose only)
           */
          irq_vecs[vec].count++;

          if (irq_vecs[vec].handler != NULL)
            (*irq_vecs[vec].handler)(irq_vecs[vec].arg);      /* call isr */
          else
            {
              ppcMtuicer(uicer, ppcMfuicer(uicer) & ~(0x80000000 >> vec));
              PRINTF("Masking bogus interrupt vector 0x%x\n", vec);
            }
          
          /*
           * After servicing the interrupt, we have to remove the status indicator.
           */
          ppcMtuicsr(uicsr, (0x80000000 >> vec));
        }
      
      /*
       * Shift msr to next position and increment vector
       */
      msr_shift <<= 1;
      vec++;
    }
}


/****************************************************************************/

/*
 * Install and free a interrupt handler.
 */

void
irq_install_handler(int vec, interrupt_handler_t *handler, void *arg)
{
  if (irq_vecs[vec].handler != NULL) {
    PRINTF ("Interrupt vector %d: handler 0x%x replacing 0x%x\n",
            vec, (uint32)handler, (uint32)irq_vecs[vec].handler);
  }
  irq_vecs[vec].handler = handler;
  irq_vecs[vec].arg     = arg;
  ppcMtuicer(uicer, ppcMfuicer(uicer) | (0x80000000 >> vec));
#if 0
  PRINTF ("Install interrupt for vector %d ==> %p\n", vec, handler);
#endif
}

void
irq_free_handler(int vec)
{
#if 0
  PRINTF ("Free interrupt for vector %d ==> %p\n",
          vec, irq_vecs[vec].handler);
#endif
  ppcMtuicer(uicer, ppcMfuicer(uicer) & ~(0x80000000 >> vec));
  irq_vecs[vec].handler = NULL;
  irq_vecs[vec].arg     = NULL;
}

/****************************************************************************/

/*******************************************************************************
*
* irqinfo - print information about PCI devices
*
*/
void
do_irqinfo()
{
  int vec;
  
  PRINTF ("\nInterrupt-Information:\n");
  PRINTF ("  Nr  Routine   Arg       Count\n");

  for (vec=0; vec<32; vec++)
    {
      if (irq_vecs[vec].handler != NULL)
        PRINTF("  %02d  %08lx  %08lx  %d\n",
               vec, (uint32)irq_vecs[vec].handler, (uint32)irq_vecs[vec].arg,
               irq_vecs[vec].count);
    }
}
