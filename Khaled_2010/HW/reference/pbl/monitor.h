/**
 * @file monitor.h
 */

/*
 * (C) Copyright 2005
 * AMIRIX Systems Inc.
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

#ifndef MONITOR_H
#define MONITOR_H

#include "system.h"

#ifndef NULL
#define NULL    0
#endif

#ifndef __ASSEMBLY__
/*
 * Monitor Command Table
 */

struct cmd_tbl_s {
    char    *name;      /* Command Name         */
    int     lmin;       /* minimum abbreviated length   */
    int     maxargs;    /* maximum number of arguments  */
    int     repeatable; /* autorepeat allowed?      */
                    /* Implementation function  */
    int     (*cmd)(struct cmd_tbl_s *, int, int, char *[]);
    char        *usage;     /* Usage message    (short) */
#ifdef  CFG_LONGHELP
    char        *help;      /* Help  message    (long)  */
#endif
};

typedef struct cmd_tbl_s    cmd_tbl_t;

extern  cmd_tbl_t cmd_tbl[];

#ifdef  CFG_LONGHELP
#define MK_CMD_TBL_ENTRY(name,lmin,maxargs,rep,cmd,usage,help)  \
                { name, lmin, maxargs, rep, cmd, usage, help }
#else   /* no help info */
#define MK_CMD_TBL_ENTRY(name,lmin,maxargs,rep,cmd,usage,help)  \
                { name, lmin, maxargs, rep, cmd, usage }
#endif

#define ERASE_STRING "\b \b"
#define TAB_STRING   "    "

int readline(const char *const prompt);
char *getenv (uchar *name);

int do_help (cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);
static char *delete_char(char *buffer, char *p, int *colp, int *np, int plen);
static int parse_line(char *, char *[]);
static cmd_tbl_t *find_cmd(const char *cmd);
int Monitor(void);
void UBoot(unsigned int UBootParam);

/*
 * Monitor Command
 *
 * All commands use a common argument format:
 *
 * void function (cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);
 */

typedef void command_t (cmd_tbl_t *, int, int, char *[]);

#endif  /* __ASSEMBLY__ */

/*
 * Command Flags:
 */
#define CMD_FLAG_REPEAT     0x0001  /* repeat last command      */
#define CMD_FLAG_BOOTD      0x0002  /* command is from bootd    */

/**
 * help command
 */
#define CMD_TBL_HELP    MK_CMD_TBL_ENTRY(                                      \
        "help",         4,      CFG_MAXARGS,    1,      do_help,                \
        "help    - print online help\n",                                        \
                                                                                \
        "[command ...]\n"                                                       \
        "    - show help information (for 'command')\n"                         \
        "'help' prints online help for the monitor commands.\n\n"               \
        "Without arguments, it prints a short usage message for all commands.\n\n" \
        "To get detailed help information for specific commands you can type\n" \
        "'help' with one or more command names as arguments.\n"                 \
    ),

/**
 * sdram command
 */
#define CMD_TBL_SDRAM    MK_CMD_TBL_ENTRY(                                     \
        "sdram",         1,      CFG_MAXARGS,    1,      do_sdram,              \
        "sdram   - sdram test\n",                                               \
                                                                                \
        "[ niter ]\n"                                                           \
        "    - run sdram test 'niter' number of times\n"                        \
    ),


/**
 * loadb command
 */
#define CMD_TBL_LOADB   MK_CMD_TBL_ENTRY(                                      \
        "loadb",        5,      2,      0,      do_load_serial_bin,             \
        "loadb   - load binary file over serial line (kermit mode)\n",          \
                                                                                \
        "[ off ]\n"                                                             \
        "    - load binary file over serial line with offset 'off'\n"           \
),

#define CMD_TBL_GO      MK_CMD_TBL_ENTRY(                                       \
        "go",           2,      CFG_MAXARGS,    1,      do_go,                  \
        "go      - start application at address 'addr'\n",                      \
        "addr [arg ...]\n    - start application at address 'addr'\n"           \
        "      passing 'arg' as arguments\n"                                    \
),
int do_go (cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);



#endif
