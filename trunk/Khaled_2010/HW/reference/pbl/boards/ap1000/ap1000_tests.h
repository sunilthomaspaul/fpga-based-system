/**
 * @file tests.h
 */

/*
 * (C) Copyright 2005
 * AMIRIX Systems Inc.
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

/** @defgroup TestSystem Test System Software
  * This part of the software is only compiled into a test system.
  */

/** @defgroup ProductionSystem Production System Software
  * This part of the software is compiled into both Production, and Test Systems.
  */


#ifndef AP1000_TESTS_H_
#define AP1000_TESTS_H_


#if !defined(PRODUCTION)

#define CMD_TBL_GPIOTEST     MK_CMD_TBL_ENTRY(                              \
        "gpiotest",          2,      CFG_MAXARGS,    0,      do_gpiotest,   \
        "gpiotest- run spare I/O signal test\n",                            \
        "- run spare I/O signal test\n"                                     \
),

#define CMD_TBL_PCISCAN     MK_CMD_TBL_ENTRY(                           \
        "pciscan",          4,      CFG_MAXARGS,    0,      do_pciscan, \
        "pciscan - scan pci bus for devices and init base addresses\n", \
        "- scan pci bus for devices and init base addresses\n"          \
),

#define CMD_TBL_ACETEST     MK_CMD_TBL_ENTRY(                           \
        "acetest",          4,      CFG_MAXARGS,    0,      do_acetest, \
        "acetest - run system ACE test\n",                              \
        "- run system ACE test\n"                                       \
),

#define CMD_TBL_PCIINIT     MK_CMD_TBL_ENTRY(                           \
        "pciinit",          4,      CFG_MAXARGS,    0,      do_pciinit, \
        "pciinit - initialize the pci bus\n",                           \
        "- initialize the pci bus\n"                                    \
),

#define CMD_TBL_SETVERB     MK_CMD_TBL_ENTRY(                               \
        "verb",             2,      CFG_MAXARGS,    0,      do_verbosity,   \
        "verb    - set the verbosity level for debugging\n",                \
        "- set the verbosity level for debugging\n"                         \
),

#define CMD_TBL_READCFG     MK_CMD_TBL_ENTRY(                               \
        "readcfg",          2,      CFG_MAXARGS,    0,      do_readconfig,  \
        "readcfg - read a pci config register\n",                           \
        "- read a pci config register\n"                                    \
),

#define CMD_TBL_WRITECFG    MK_CMD_TBL_ENTRY(                               \
        "writecfg",         2,      CFG_MAXARGS,    0,      do_writeconfig, \
        "writecfg- write a pci config register\n",                          \
        "- write a pci config register\n"                                   \
),

#define CMD_TBL_ETHTEST     MK_CMD_TBL_ENTRY(                           \
        "ethtest",          2,      CFG_MAXARGS,    0,      do_eth_test,\
        "ethtest - run GB ethernet test\n",                             \
        "- run GB ethernet test\n"                                      \
),

#define CMD_TBL_INT_CMD     MK_CMD_TBL_ENTRY(                           \
        "intcmd",         4,      CFG_MAXARGS,        0,      do_int_cmd, \
        "intcmd  - intcmd [dump/clear/init/test]\n",                    \
        " [dump/clear/init/test]\n"                                     \
),

#define CMD_TBL_INTTEST_CMD     MK_CMD_TBL_ENTRY(                       \
        "inttest",          4,      CFG_MAXARGS,    0,      do_int_test,\
        "inttest - run interrupt test\n",                               \
        "- run interrupt test\n"                                        \
),

#define CMD_TBL_ACE_CMD     MK_CMD_TBL_ENTRY(                           \
        "ace",          3,      CFG_MAXARGS,        0,      do_ace_cmd, \
        "ace     - ace [dump/clint/reset/or (n)/and (n)]\n",            \
        "- ace [dump/clint/reset/or (n)/and (n)]\n"                     \
),

#define CMD_TBL_SENSOR      MK_CMD_TBL_ENTRY(                   \
    "temp",     4,      6,      0,      do_temp_sensor,         \
    "temp    - Interact with the temperature sensor\n",         \
    "[s]\n"                                                     \
    "        - Show status.\n"                                  \
    "temp l LOW [HIGH] [THERM]\n"                               \
    "        - Set local limits.\n"                             \
    "temp e LOW [HIGH] [THERM] [OFFSET]\n"                      \
    "        - Set external limits.\n"                          \
    "temp c CONFIG [CONVERSION] [CONS. ALERT] [THERM HYST]\n"   \
    "        - Set config options.\n"                           \
    "\n"                                                        \
    "All values can be decimal or hex (hex preceded with 0x).\n"\
    "Only whole numbers are supported for external limits.\n"   \
),

#define CMD_TBL_AUTOTEST_CMD     MK_CMD_TBL_ENTRY(      \
    "autotest", 4,      2,      0,      do_autotest,    \
    "autotest- Run the platform test sequence.\n",      \
    "[m] - Run the platform test sequence ('m' indicates to run full memory tests.\n" \
),

#define CMD_TBL_SWCONFIG MK_CMD_TBL_ENTRY(          \
    "swconfig", 3,     3,     0, do_swconfigbyte,   \
    "swconfig- display or modify the software configuration byte\n",            \
    "N [ADDRESS]\n"                                                             \
    "    - set software configuration byte to N, optionally use ADDRESS as\n"   \
    "      location of buffer for flash copy\n"                                 \
    "swconfig\n"                                                                \
    "    - display software configuration byte\n"                               \
),

#define CMD_TBL_SWRECONFIG MK_CMD_TBL_ENTRY(                                        \
    "swrecon",  3,     1,     0, do_swreconfig,                                     \
    "swrecon - trigger a reconfiguration to the software selected configuration\n", \
    "\n"                                                                            \
    "    - trigger a board reconfigure to the software selected configuration\n"    \
),

#define CMD_TBL_KINIT MK_CMD_TBL_ENTRY(                     \
    "kinit",  5,     3,     0, do_kinit,                    \
    "kinit   - klean and initialize the onboard images\n",  \
    "[s]    - show status of the 5 images\n"                \
    "kinit [f] a  - copy all 5 images\n"                    \
    "kinit [f] u  - copy u-boot\n"                          \
    "kinit [f] e  - copy environment\n"                     \
    "kinit [f] k  - copy kernel\n"                          \
    "kinit [f] r  - copy ramdisk\n"                         \
    "kinit [f] c  - copy configuration\n"                   \
    "kinit [f] b  - copy all but environment\n"             \
    "\n"                                                    \
    "[f] forces with no prompt\n"                           \
),

#define CMD_TBL_HOSTTEST MK_CMD_TBL_ENTRY(      \
    "hosttest",  4,     2,     0, do_host_test, \
    "hosttest- run the host test.\n",           \
    "\n"                                        \
    "    - run the host test.\n"                \
),



/* I2C Stuff */
#define I2C_SENSOR_DEV      0x9
#define I2C_SENSOR_CHIP_SEL 0x4
#define TEMP_ARA_DEV        0x1
#define TEMP_ARA_CHIP_SEL   0x4

int do_verbosity(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);
int do_gpiotest(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);
int do_acetest(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);
int do_pciinit(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);
int do_pciscan(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);
int do_eth_test(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);
int do_int_cmd(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);
int do_int_test(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);
int do_ace_cmd(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);
int do_readconfig(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);
int do_writeconfig(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);
int do_temp_sensor(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);
int do_autotest(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);
int do_swconfigbyte(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);
int do_swreconfig(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);
int do_kinit(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);
int do_host_test(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);

int TestSystemAutoRun(int theFlag);
void DoSWReconfig();

extern int gPCIInitialized;
typedef unsigned long long uint64;

#endif	/* !defined(PRODUCTION) */

#endif  /* ifndef AP1100_TESTS_H_ */
