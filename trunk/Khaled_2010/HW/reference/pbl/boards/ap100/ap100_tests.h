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


#ifndef TESTS_H_
#define TESTS_H_


#if !defined(PRODUCTION)

#define CMD_TBL_SIOTEST     MK_CMD_TBL_ENTRY(                           \
        "siotest",          2,      CFG_MAXARGS,    0,      do_siotest, \
        "siotest - run spare I/O signal test\n",                        \
        "- run spare I/O signal test\n"                                 \
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

#define CMD_TBL_SETVERB     MK_CMD_TBL_ENTRY(                           \
        "verb",             2,      CFG_MAXARGS,    0,      do_verbosity, \
        "verb    - set the verbosity level for debugging\n",            \
        "- set the verbosity level for debugging\n"                     \
),

#define CMD_TBL_READCFG     MK_CMD_TBL_ENTRY(                           \
        "readcfg",          2,      CFG_MAXARGS,    0,      do_readconfig, \
        "readcfg - read a pci config register\n",                       \
        "- read a pci config register\n"                                \
),

#define CMD_TBL_WRITECFG    MK_CMD_TBL_ENTRY(                           \
        "writecfg",         2,      CFG_MAXARGS,    0,      do_writeconfig, \
        "writecfg- write a pci config register\n",                      \
        "- write a pci config register\n"                               \
),

#define CMD_TBL_PROGSROM    MK_CMD_TBL_ENTRY(                           \
        "srom",             2,      CFG_MAXARGS,    0,      do_program_SROM, \
        "srom    - srom [write/read]\n",                                \
        "- srom [write/read]\n"                                         \
),

#define CMD_TBL_ETHTEST     MK_CMD_TBL_ENTRY(                           \
        "ethtest",          2,      CFG_MAXARGS,    0,      do_eth_test,\
        "ethtest - run GB ethernet test\n",                             \
        "- run GB ethernet test\n"                                      \
),

#define CMD_TBL_INT_CMD     MK_CMD_TBL_ENTRY(                           \
        "int",          3,      CFG_MAXARGS,        0,      do_int_cmd, \
        "int     - int [dump/clear/init/test]\n",                       \
        "- int [dump/clear/init/test]\n"                                \
),

#define CMD_TBL_INTTEST_CMD     MK_CMD_TBL_ENTRY(                       \
        "inttest",          2,      CFG_MAXARGS,    0,      do_int_test,\
        "inttest - run interrupt test\n",                               \
        "- run interrupt test\n"                                        \
),

#define CMD_TBL_ACE_CMD     MK_CMD_TBL_ENTRY(                           \
        "ace",          3,      CFG_MAXARGS,        0,      do_ace_cmd, \
        "ace     - ace [dump/clint/reset/or (n)/and (n)]\n",            \
        "- ace [dump/clint/reset/or (n)/and (n)]\n"                     \
),

int do_verbosity(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);
int do_siotest(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);
int do_acetest(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);
int do_pciinit(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);
int do_pciscan(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);
int do_eth_test(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);
int do_int_cmd(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);
int do_int_test(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);
int do_ace_cmd(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);
int do_readconfig(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);
int do_writeconfig(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);
int do_program_SROM(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);
int TestSystemAutoRun();

#endif

#endif  /* !defined(PRODUCTION) */
