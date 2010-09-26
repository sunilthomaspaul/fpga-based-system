/**
 * @file monitor.c
 */

/*
 * (C) Copyright 2005
 * AMIRIX Systems Inc.
 *
 * Originated from ppcboot-2.0.0/common/command.c
 *                 ppcboot-2.0.0/common/main.c
 *
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

#include "system.h"
#include "monitor.h"
#include "serial.h"
#include "loadb.h"
#include "mem.h"
#include "flash.h"
#include "tests.h"

char console_buffer[CFG_CBSIZE];     /* console I/O buffer   */
char lastcommand[CFG_CBSIZE];        /* last command */

/**
 * The commands in this table are sorted alphabetically by the
 * command name and in descending order by the command name string
 * length. This is to prevent conflicts in command name parsing.
 * Please ensure that new commands are added according to that rule.
 * Please use $(TOPDIR)/doc/README.commands as a reference AND make
 * sure it gets updated.
 */

cmd_tbl_t cmd_tbl[] = {
    BOARD_CMD_TABLE
    MK_CMD_TBL_ENTRY( NULL, 0, 0, 0, NULL, NULL, NULL )
};

/**
 * Prompt for input and read a line.
 * If  CONFIG_BOOT_RETRY_TIME is defined and retry_time >= 0,
 * time out when time goes past endtime (timebase time in ticks).
 * Return:  number of read characters
 *      -1 if break
 *      -2 if timed out
 */
int readline(const char *const prompt)
{
    char           *p = console_buffer;
    int             n = 0;      /* buffer index         */
    int             plen = 0;   /* prompt length        */
    int             col;        /* output column cnt    */
    char            c;

    /* print prompt */
    if (prompt)
    {
        plen = strlen(prompt);
        serial_puts(prompt);
    }
    col = plen;

    for (;;)
    {
#ifdef CONFIG_BOOT_RETRY_TIME
        while (!tstc())
        {                       /* while no incoming data */
            if (retry_time >= 0 && get_ticks() > endtime)
                return (-2);    /* timed out */
        }
#endif
        WATCHDOG_RESET();       /* Trigger watchdog, if needed */

#ifdef CONFIG_SHOW_ACTIVITY
        while (!tstc())
        {
            extern void     show_activity(int arg);
            show_activity(0);
        }
#endif
        c = serial_getc();

        /*
         * Special character handling
         */
        switch (c)
        {
        case '\r':             /* Enter                */
        case '\n':
            *p = '\0';
            serial_puts("\r\n");
            return (p - console_buffer);

        case 0x03:             /* ^C - break           */
            console_buffer[0] = '\0';   /* discard input */
            return (-1);

        case 0x15:             /* ^U - erase line      */
            while (col > plen)
            {
                serial_puts(ERASE_STRING);
                --col;
            }
            p = console_buffer;
            n = 0;
            continue;

        case 0x17:             /* ^W - erase word      */
            p = delete_char(console_buffer, p, &col, &n, plen);
            while ((n > 0) && (*p != ' '))
            {
                p = delete_char(console_buffer, p, &col, &n, plen);
            }
            continue;

        case 0x08:             /* ^H  - backspace      */
        case 0x7F:             /* DEL - backspace      */
            p = delete_char(console_buffer, p, &col, &n, plen);
            continue;

        default:
            /*
             * Must be a normal character then
             */
            if (n < CFG_CBSIZE - 2)
            {
                if (c == '\t')
                {               /* expand TABs          */
                    serial_puts(TAB_STRING + (col & 07));
                    col += 8 - (col & 07);
                }
                else
                {
                    ++col;      /* echo input           */
                    serial_putc(c);
                }
                *p++ = c;
                ++n;
            }
            else
            {                   /* Buffer full          */
                serial_putc('\a');
            }
        }
    }
}


/**
 *
 *
 */

static char* delete_char(char *buffer, char *p, int *colp, int *np, int plen)
{
    char           *s;

    if (*np == 0)
    {
        return (p);
    }

    if (*(--p) == '\t')
    {                           /* will retype the whole line   */
        while (*colp > plen)
        {
            serial_puts(ERASE_STRING);
            (*colp)--;
        }
        for (s = buffer; s < p; ++s)
        {
            if (*s == '\t')
            {
                serial_puts(TAB_STRING + ((*colp) & 07));
                *colp += 8 - ((*colp) & 07);
            }
            else
            {
                ++(*colp);
                serial_putc(*s);
            }
        }
    }
    else
    {
        serial_puts(ERASE_STRING);
        (*colp)--;
    }
    (*np)--;
    return (p);
}


/**
 *
 *
 */

int parse_line(char *line, char *argv[])
{
    int             nargs = 0;

#ifdef DEBUG_PARSER
    printf("parse_line: \"%s\"\n", line);
#endif
    while (nargs < CFG_MAXARGS)
    {

        /* skip any white space */
        while ((*line == ' ') || (*line == '\t'))
        {
            ++line;
        }

        if (*line == '\0')
        {                       /* end of line, no more args    */
            argv[nargs] = NULL;
#ifdef DEBUG_PARSER
            printf("parse_line: nargs=%d\n", nargs);
#endif
            return (nargs);
        }

        argv[nargs++] = line;   /* begin of argument string     */

        /* find end of string */
        while (*line && (*line != ' ') && (*line != '\t'))
        {
            ++line;
        }

        if (*line == '\0')
        {                       /* end of line, no more args    */
            argv[nargs] = NULL;
#ifdef DEBUG_PARSER
            printf("parse_line: nargs=%d\n", nargs);
#endif
            return (nargs);
        }

        *line++ = '\0';         /* terminate current arg         */
    }

    printf("** Too many args (max. %d) **\n", CFG_MAXARGS);

#ifdef DEBUG_PARSER
    printf("parse_line: nargs=%d\n", nargs);
#endif
    return (nargs);
}


/**
 *
 *
 */

static void process_macros(const char *input, char *output)
{
    char            c, prev;
    const char     *varname_start = NULL;
    int             inputcnt = strlen(input);
    int             outputcnt = CFG_CBSIZE;
    int             state = 0;  /* 0 = waiting for '$'  */
    /* 1 = waiting for '('  */
    /* 2 = waiting for ')'  */

#ifdef DEBUG_PARSER
    char           *output_start = output;

    printf("[PROCESS_MACROS] INPUT len %d: \"%s\"\n", strlen(input), input);
#endif

    prev = '\0';                /* previous character   */

    while (inputcnt && outputcnt)
    {
        c = *input++;
        inputcnt--;

        /* remove one level of escape characters */
        if ((c == '\\') && (prev != '\\'))
        {
            if (inputcnt-- == 0)
                break;
            prev = c;
            c = *input++;
        }

        switch (state)
        {
        case 0:                /* Waiting for (unescaped) $    */
            if ((c == '$') && (prev != '\\'))
            {
                state++;
            }
            else
            {
                *(output++) = c;
                outputcnt--;
            }
            break;
        case 1:                /* Waiting for (        */
            if (c == '(')
            {
                state++;
                varname_start = input;
            }
            else
            {
                state = 0;
                *(output++) = '$';
                outputcnt--;

                if (outputcnt)
                {
                    *(output++) = c;
                    outputcnt--;
                }
            }
            break;
        case 2:                /* Waiting for )        */
            if (c == ')')
            {
                int             i;
                char            envname[CFG_CBSIZE], *envval;
                int             envcnt = input - varname_start - 1;     /* Varname # of chars */

                /* Get the varname */
                for (i = 0; i < envcnt; i++)
                {
                    envname[i] = varname_start[i];
                }
                envname[i] = 0;

#if 0
                /* Get its value */
                envval = getenv(envname);
#endif

                /* Copy into the line if it exists */
                if (envval != NULL)
                    while ((*envval) && outputcnt)
                    {
                        *(output++) = *(envval++);
                        outputcnt--;
                    }
                /* Look for another '$' */
                state = 0;
            }
            break;
        }

        prev = c;
    }

    if (outputcnt)
        *output = 0;

#ifdef DEBUG_PARSER
    printf("[PROCESS_MACROS] OUTPUT len %d: \"%s\"\n",
           strlen(output_start), output_start);
#endif
}

/**
 * returns:
 *  1  - command executed, repeatable
 *  0  - command executed but not repeatable, interrupted commands are
 *       always considered not repeatable
 *  -1 - not executed (unrecognized, bootd recursion or too many args)
 *           (If cmd is NULL or "" or longer than CFG_CBSIZE-1 it is
 *           considered unrecognized)
 *
 * WARNING:
 *
 * We must create a temporary copy of the command since the command we get
 * may be the result from getenv(), which returns a pointer directly to
 * the environment data, which may change magicly when the command we run
 * creates or modifies environment variables (like "bootp" does).
 */

int run_command(const char *cmd, int flag)
{
    cmd_tbl_t      *cmdtp;
    char            cmdbuf[CFG_CBSIZE]; /* working copy of cmd          */
    char           *token;      /* start of token in cmdbuf     */
    char           *sep;        /* end of token (separator) in cmdbuf */
    char            finaltoken[CFG_CBSIZE];
    char           *str = cmdbuf;
    char           *argv[CFG_MAXARGS + 1];      /* NULL terminated      */
    int             argc;
    int             repeatable = 1;

#ifdef DEBUG_PARSER
    printf("[RUN_COMMAND] cmd[%p]=\"", cmd);
    serial_puts(cmd ? cmd : "NULL");   /* use puts - string may be loooong */
    serial_puts("\"\n");
#endif

    clear_ctrlc();              /* forget any previous Control C */

    if (!cmd || !*cmd)
    {
        return -1;              /* empty command */
    }

    if (strlen(cmd) >= CFG_CBSIZE)
    {
        serial_puts("## Command too long!\n");
        return -1;
    }

    strcpy(cmdbuf, cmd);

    /* Process separators and check for invalid
     * repeatable commands
     */

#ifdef DEBUG_PARSER
    printf("[PROCESS_SEPARATORS] %s\n", cmd);
#endif
    while (*str)
    {

        /*
         * Find separator, or string end
         * Allow simple escape of ';' by writing "\;"
         */
        for (sep = str; *sep; sep++)
        {
            if ((*sep == ';') &&        /* separator            */
                (sep != str) && /* past string start    */
                (*(sep - 1) != '\\'))   /* and NOT escaped      */
                break;
        }

        /*
         * Limit the token to data between separators
         */
        token = str;
        if (*sep)
        {
            str = sep + 1;      /* start of command for next pass */
            *sep = '\0';
        }
        else{
            str = sep;          /* no more commands for next pass */
        }
#ifdef DEBUG_PARSER
        printf("token: \"%s\"\n", token);
#endif

        /* find macros in this token and replace them */
        process_macros(token, finaltoken);

        /* Extract arguments */
        argc = parse_line(finaltoken, argv);

        /* Look up command in command table */
        if ((cmdtp = find_cmd(argv[0])) == NULL)
        {
            printf("Unknown command '%s' - try 'help'\n", argv[0]);
            return -1;          /* give up after bad command */
        }

        /* found - check max args */
        if (argc > cmdtp->maxargs)
        {
            printf("Usage:\n%s\n", cmdtp->usage);
            return -1;
        }

#if (CONFIG_COMMANDS & CFG_CMD_BOOTD)
        /* avoid "bootd" recursion */
        if (cmdtp->cmd == do_bootd)
        {
#ifdef DEBUG_PARSER
            printf("[%s]\n", finaltoken);
#endif
            if (flag & CMD_FLAG_BOOTD)
            {
                printf("'bootd' recursion detected\n");
                return -1;
            }
            else
                flag |= CMD_FLAG_BOOTD;
        }
#endif /* CFG_CMD_BOOTD */

        /* return not repeatable if this is a non-repeatable repeat */
        if(flag & CMD_FLAG_REPEAT){
            if(cmdtp->repeatable == 0){
                return 0;
            }
        }


        /* OK - call function to do the command */
        if ((cmdtp->cmd) (cmdtp, flag, argc, argv) != 0)
        {
            return (-1);
        }

        repeatable &= cmdtp->repeatable;

        /* Did the user stop this? */
        if (had_ctrlc())
            return 0;           /* if stopped then not repeatable */
    }

    return repeatable;
}


/**
 *
 *
 */

#if (CONFIG_COMMANDS & CFG_CMD_RUN)
int do_run(cmd_tbl_t * cmdtp, int flag, int argc, char *argv[])
{
    int             i;
    int             rcode = 1;

    if (argc < 2)
    {
        printf("Usage:\n%s\n", cmdtp->usage);
        return 1;
    }

    for (i = 1; i < argc; ++i)
    {
#ifndef CFG_HUSH_PARSER
        if (run_command(getenv(argv[i]), flag) != -1)
            ++rcode;
#else
        if (parse_string_outer(getenv(argv[i]),
                               FLAG_PARSE_SEMICOLON | FLAG_EXIT_FROM_LOOP) ==
            0)
            ++rcode;
#endif
    }
    return ((rcode == i) ? 0 : 1);
}
#endif



/**
 * find command table entry for a command
 */

cmd_tbl_t* find_cmd(const char *cmd)
{
    cmd_tbl_t      *cmdtp;

    /* Search command table - Use linear search - it's a small table */
    for (cmdtp = &cmd_tbl[0]; cmdtp->name; cmdtp++)
    {
        if (strncmp(cmd, cmdtp->name, cmdtp->lmin) == 0)
            return cmdtp;
    }
    return NULL;                /* not found */
}


/**
 * Use puts() instead of printf() to avoid printf buffer overflow
 * for long help messages
 */

int do_help (cmd_tbl_t *cmdtp, int flag, int argc, char *argv[])
{
        int i;
        int rcode = 0;

        if (argc == 1) {        /* print short help (usage) */

                for (cmdtp=&cmd_tbl[0]; cmdtp->name; cmdtp++) {
                        /* allow user abort */
                        if (ctrlc())
                                return 1;

                        if (cmdtp->usage == NULL)
                                continue;
                        serial_puts (cmdtp->usage);
                }

                return 0;
        }

        /*
         * command help (long version)
         */
        for (i=1; i<argc; ++i) {
                if ((cmdtp = find_cmd(argv[i])) != NULL) {
#ifdef  CFG_LONGHELP
                        /* found - print (long) help info */
                        serial_puts (cmdtp->name);
                        serial_putc (' ');
                        if (cmdtp->help) {
                                serial_puts (cmdtp->help);
                        } else {
                                serial_puts ("- No help available.\n");
                                rcode = 1;
                        }
                        serial_putc ('\n');
#else   /* no long help available */
                        if (cmdtp->usage)
                                serial_puts (cmdtp->usage);
#endif  /* CFG_LONGHELP */
                }
                else {
                        printf ("Unknown command '%s' - try 'help'"
                                " without arguments for list of all"
                                " known commands\n\n",
                                argv[i]
                        );
                        rcode = 1;
                }
        }
        return rcode;
}

#ifdef INCLUDE_GETENV
/* Ignore CRC.
 * PBL will have to assume that the CRC is correct.  PBL has read-only access
 *  to the environment variables.
 */
#define environment_address  0x20040004
#define CFG_ENV_SIZE 0x1000
#define env_get_addr(index) ((char *)(environment_address + index))

char env_get_char(int index){
    return *((char*)(environment_address + index));
}

/************************************************************************
 * Match a name / name=value pair
 *
 * s1 is either a simple 'name', or a 'name=value' pair.
 * i2 is the environment index for a 'name2=value2' pair.
 * If the names match, return the index for the value2, else NULL.
 */

static int envmatch (uchar *s1, int i2)
{

    while (*s1 == env_get_char(i2++))
        if (*s1++ == '=')
            return(i2);
    if (*s1 == '\0' && env_get_char(i2-1) == '=')
        return(i2);
    return(-1);
}


/************************************************************************
 * Look up variable from environment,
 * return address of storage for that variable,
 * or NULL if not found
 */
char *getenv (uchar *name)
{
    int i, nxt;

    for (i=0; env_get_char(i) != '\0'; i=nxt+1) {
        int val;

        for (nxt=i; env_get_char(nxt) != '\0'; ++nxt) {
            if (nxt >= CFG_ENV_SIZE) {
                return (NULL);
            }
        }
        if ((val=envmatch(name, i)) < 0)
            continue;
        return (env_get_addr(val));
    }

    return (NULL);
}

#endif

int Monitor(void){
    int len;
    int flag;
    int rc;

    while (1){
        len = readline(CFG_PROMPT);

        flag = 0;       /* assume no special flags for now */
        if (len > 0){
            strcpy (lastcommand, console_buffer);
        }
        else if (len == 0){
            flag |= CMD_FLAG_REPEAT;
        }

        if (len == -1)
            printf ("*INTERRUPT*\n");
        else
            rc = run_command (lastcommand, flag);
    }
}

void UBoot(unsigned int UBootParam){
    void (*uboot)(unsigned char);
    int ii;

    printf(UBOOT_SELECTED_BANNER);

    /* copy 16 bit word at a time */
    for(ii = 0;ii < CFG_UBOOT_IMAGE_SIZE / 2;ii++){
        *(((ushort *)CFG_UBOOT_IMAGE_BASE) + ii) = *(((ushort *)CFG_PROGFLASH_BASE) + ii);
    }

    uboot = (void (*)(unsigned char))CFG_UBOOT_RUN_BASE;

    uboot(UBootParam);
}

int do_go (cmd_tbl_t *cmdtp, int flag, int argc, char *argv[])
{
        ulong   addr, rc;
        int     rcode = 0;

        if (argc < 2) {
                printf ("Usage:\n%s\n", cmdtp->usage);
                return 1;
        }

        addr = simple_strtoul(argv[1], NULL, 16);

        printf ("## Starting application at 0x%08lx ...\n", addr);

        /*
         * pass address parameter as argv[0] (aka command name),
         * and all remaining args
         */
        rc = ((ulong (*)(int, char *[]))addr) (--argc, &argv[1]);
        if (rc != 0) rcode = 1;

        printf ("## Application terminated, rc = 0x%lx\n", rc);
        return rcode;
}

#ifdef INCLUDE_PCI
/* Convert the "bus.device.function" identifier into a number.
 */
int get_pci_bus_dev_fn(char* name, int* bus, int* dev, int* fn)
{
    char cnum[12];
    int len, i, iold, n;
    int bdfs[3] = {0,0,0};

    len = strlen(name);
    if (len > 8)
        return -1;
    for (i = 0, iold = 0, n = 0; i < len; i++) {
        if (name[i] == '.') {
            memcpy(cnum, &name[iold], i - iold);
            cnum[i - iold] = '\0';
            bdfs[n++] = simple_strtoul(cnum, NULL, 16);
            iold = i + 1;
        }
    }
    strcpy(cnum, &name[iold]);
    if (n == 0)
        n = 1;
    bdfs[n] = simple_strtoul(cnum, NULL, 16);

    *bus = bdfs[0];
    *dev = bdfs[1];
    *fn  = bdfs[2];

    return 0;
}

static int pci_cfg_display(int bus, int dev, int fn, ulong addr, ulong size, ulong length)
{
#define DISP_LINE_LEN   16
    ulong i, nbytes, linebytes;
    int rc = 0;

    if (length == 0)
        length = 0x40 / size; /* Standard PCI configuration space */

    /* Print the lines.
     * once, and all accesses are with the specified bus width.
     */
    nbytes = length * size;
    do {
        unsigned long val4;
        unsigned short val2;
        unsigned char val1;

        printf("%08lx:", addr);
        linebytes = (nbytes>DISP_LINE_LEN)?DISP_LINE_LEN:nbytes;
        for (i=0; i<linebytes; i+= size) {
            if (size == 4) {
                pci_read_config_dword(bus, dev, fn, addr, &val4);
                printf(" %08x", val4);
            } else if (size == 2) {
                pci_read_config_word(bus, dev, fn, addr, &val2);
                printf(" %04x", val2);
            } else {
                pci_read_config_byte(bus, dev, fn, addr, &val1);
                printf(" %02x", val1);
            }
            addr += size;
        }
        printf("\n");
        nbytes -= linebytes;
        if (ctrlc()) {
            rc = 1;
            break;
        }
    } while (nbytes > 0);

    return (rc);
}


/* PCI Configuration Space access commands
 *
 * Syntax:
 *  pci display[.b, .w, .l] bus.device.function} addr [len]
 *  pci write[.b, .w, .l]   bus.device.function  addr value
 *  pci scan
 */
int do_pci (cmd_tbl_t *cmdtp, int flag, int argc, char *argv[])
{
    ulong addr = 0, value = 0, size = 0;
    int bus, dev, fn;
    char cmd = 's';
    int ret_val = 1;

    if (argc > 1){
        cmd = argv[1][0];
    }

#ifdef CONFIG_AP100
    set_eat_machine_checks(1);
#endif

    switch (cmd){
        case 'd':
        case 'w':{
            if(argc < 5){
                goto usage;
            }
            size  = cmd_get_data_size(argv[1], 4);
            if(get_pci_bus_dev_fn(argv[2], &bus, &dev, &fn) != 0){
                goto usage;
            }
            addr  = simple_strtoul(argv[3], NULL, 16);
            value = simple_strtoul(argv[4], NULL, 16);
            break;
        }
        case 's':{
            break;
        }
        default:{
            goto usage;
            break;
        }
    }

    switch(cmd){
        case 'd':{
            ret_val = pci_cfg_display(bus, dev, fn, addr, size, value);
            goto done;
        }
        case 'w':{
            ret_val = PCIWriteConfig(bus, dev, fn, addr, size, value);
            goto done;
        }
    }

    goto done;
 usage:
    printf ("Usage:\n%s\n", cmdtp->usage);

 done:
#ifdef CONFIG_AP100
     /* udelay ensures that a stray machine check does not occur */
     udelay(1000);
     set_eat_machine_checks(0);
#endif
     return ret_val;
}

#endif
