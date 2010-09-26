/**
 * @file flash.c
 */

/*
 * (C) Copyright 2003
 * AMIRIX Systems Inc.
 *
 * Originated from ppcboot-2.0.0/common/flash.c
 *                 ppcboot-2.0.0/common/cmd_flash.c
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
#include "serial.h"
#include "flash.h"


extern flash_info_t  flash_info[CFG_MAX_FLASH_BANKS]; /** info for FLASH chips */

/*-----------------------------------------------------------------------
 * Functions
 */

/**
 * Set protection status for monitor sectors
 *
 * The monitor is always located in the _first_ Flash bank.
 * If necessary you have to map the second bank at lower addresses.
 */

void
flash_protect (int flag, ulong from, ulong to, flash_info_t *info)
{
	ulong b_end = info->start[0] + info->size - 1;	/* bank end address */
	short s_end = info->sector_count - 1;	/* index of last sector */
	int i;

	/* Do nothing if input data is bad. */
	if (info->sector_count == 0 || info->size == 0 || to < from) {
		return;
	}

	/* There is nothing to do if we have no data about the flash
	 * or the protect range and flash range don't overlap.
	 */
	if (info->flash_id == FLASH_UNKNOWN ||
	    to < info->start[0] || from > b_end) {
		return;
	}

	for (i=0; i<info->sector_count; ++i) {
		ulong end;		/* last address in current sect	*/

		end = (i == s_end) ? b_end : info->start[i + 1] - 1;

		/* Update protection if any part of the sector
		 * is in the specified range.
		 */
		if (from <= end && to >= info->start[i]) {
			if (flag & FLAG_PROTECT_CLEAR) {
#if defined(CFG_FLASH_PROTECTION)
				flash_real_protect(info, i, 0);
#else
				info->protect[i] = 0;
#endif	/* CFG_FLASH_PROTECTION */
			}
			else if (flag & FLAG_PROTECT_SET) {
#if defined(CFG_FLASH_PROTECTION)
				flash_real_protect(info, i, 1);
#else
				info->protect[i] = 1;
#endif	/* CFG_FLASH_PROTECTION */
			}
		}
	}
}

/**
 *
 */

flash_info_t *
addr2info (ulong addr)
{

	flash_info_t *info;
	int i;

	for (i=0, info=&flash_info[0]; i<CFG_MAX_FLASH_BANKS; ++i, ++info) {
		if (info->flash_id != FLASH_UNKNOWN &&
		    addr >= info->start[0] &&
		    /* WARNING - The '- 1' is needed if the flash
		     * is at the end of the address space, since
		     * info->start[0] + info->size wraps back to 0.
		     * Please don't change this unless you understand this.
		     */
		    addr <= info->start[0] + info->size - 1) {
			return (info);
		}
	}

	return (NULL);
}

/**
 * Copy memory to flash.
 *
 * Make sure all target addresses are within Flash bounds,
 * and no protected sectors are hit.
 * Returns:
 * ERR_OK          0 - OK
 * ERR_TIMOUT      1 - write timeout
 * ERR_NOT_ERASED  2 - Flash not erased
 * ERR_PROTECTED   4 - target range includes protected sectors
 * ERR_INVAL       8 - target address not in Flash memory
 * ERR_ALIGN       16 - target address not aligned on boundary
 *			(only some targets require alignment)
 */

int
flash_write (uchar *src, ulong addr, ulong cnt)
{
	int i;
	ulong         end        = addr + cnt - 1;
	flash_info_t *info_first = addr2info (addr);
	flash_info_t *info_last  = addr2info (end );
	flash_info_t *info;

	if (cnt == 0) {
		return (ERR_OK);
	}

	if (!info_first || !info_last) {
		return (ERR_INVAL);
	}

	for (info = info_first; info <= info_last; ++info) {
		ulong b_end = info->start[0] + info->size;	/* bank end addr */
		short s_end = info->sector_count - 1;
		for (i=0; i<info->sector_count; ++i) {
			ulong e_addr = (i == s_end) ? b_end : info->start[i + 1];

			if ((end >= info->start[i]) && (addr < e_addr) &&
			    (info->protect[i] != 0) ) {
				return (ERR_PROTECTED);
			}
		}
	}

	/* finally write data to flash */
	for (info = info_first; info <= info_last && cnt>0; ++info) {
		ulong len;

		len = info->start[0] + info->size - addr;
		if (len > cnt)
			len = cnt;
		if ((i = write_buff(info, src, addr, len)) != 0) {
			return (i);
		}
		cnt  -= len;
		addr += len;
		src  += len;
	}
	return (ERR_OK);
}

/**
 *
 */

void flash_perror (int err)
{
	switch (err) {
	case ERR_OK:
		break;
	case ERR_TIMOUT:
		serial_puts ("Timeout writing to Flash\n");
		break;
	case ERR_NOT_ERASED:
		serial_puts ("Flash not Erased\n");
		break;
	case ERR_PROTECTED:
		serial_puts ("Can't write to protected Flash sectors\n");
		break;
	case ERR_INVAL:
		serial_puts ("Outside available Flash\n");
		break;
	case ERR_ALIGN:
		serial_puts ("Start and/or end address not on sector boundary\n");
		break;
	case ERR_UNKNOWN_FLASH_VENDOR:
		serial_puts ("Unknown Vendor of Flash\n");
		break;
	case ERR_UNKNOWN_FLASH_TYPE:
		serial_puts ("Unknown Type of Flash\n");
		break;
	case ERR_PROG_ERROR:
		serial_puts ("General Flash Programming Error\n");
		break;
	default:
		printf ("%s[%d] FIXME: rc=%d\n", __FILE__, __LINE__, err);
		break;
	}
}

/*
 * The user interface starts numbering for Flash banks with 1
 * for historical reasons.
 */

/*
 * this routine looks for an abbreviated flash range specification.
 * the syntax is B:SF[-SL], where B is the bank number, SF is the first
 * sector to erase, and SL is the last sector to erase (defaults to SF).
 * bank numbers start at 1 to be consistent with other specs, sector numbers
 * start at zero.
 *
 * returns:	1	- correct spec; *pinfo, *psf and *psl are
 *			  set appropriately
 *		0	- doesn't look like an abbreviated spec
 *		-1	- looks like an abbreviated spec, but got
 *			  a parsing error, a number out of range,
 *			  or an invalid flash bank.
 */
static int
abbrev_spec(char *str, flash_info_t **pinfo, int *psf, int *psl)
{
    flash_info_t *fp;
    int bank, first, last;
    char *p, *ep;

    if ((p = (char*)strchr(str, ':')) == NULL)
	return 0;
    *p++ = '\0';

    bank = simple_strtoul(str, &ep, 10);
    if (ep == str || *ep != '\0' ||
      bank < 1 || bank > CFG_MAX_FLASH_BANKS ||
      (fp = &flash_info[bank - 1])->flash_id == FLASH_UNKNOWN)
	return -1;

    str = p;
    if ((p = (char*)strchr(str, '-')) != NULL)
	*p++ = '\0';

    first = simple_strtoul(str, &ep, 10);
    if (ep == str || *ep != '\0' || first >= fp->sector_count)
	return -1;

    if (p != NULL) {
	last = simple_strtoul(p, &ep, 10);
	if (ep == p || *ep != '\0' ||
	  last < first || last >= fp->sector_count)
	    return -1;
    }
    else
	last = first;

    *pinfo = fp;
    *psf = first;
    *psl = last;

    return 1;
}
int do_flinfo ( cmd_tbl_t *cmdtp, int flag, int argc, char *argv[])
{
	ulong bank;

	if (argc == 1) {	/* print info for all FLASH banks */
		for (bank=0; bank <CFG_MAX_FLASH_BANKS; ++bank) {
			printf ("Bank # %ld: ", bank+1);

			flash_print_info (&flash_info[bank]);
		}
		return 0;
	}

	bank = simple_strtoul(argv[1], NULL, 16);
	if ((bank < 1) || (bank > CFG_MAX_FLASH_BANKS)) {
		printf ("Only FLASH Banks # 1 ... # %d supported\n",
			CFG_MAX_FLASH_BANKS);
		return 1;
	}
	printf ("Bank # %ld: ", bank);
	flash_print_info (&flash_info[bank-1]);
	return 0;
}
int do_flerase (cmd_tbl_t *cmdtp, int flag, int argc, char *argv[])
{
	flash_info_t *info;
	ulong bank, addr_first, addr_last;
	int n, sect_first, sect_last;
	int rcode = 0;

	if (argc < 2) {
		printf ("Usage:\n%s\n", cmdtp->usage);
		return 1;
	}

	if (strcmp(argv[1], "all") == 0) {
		for (bank=1; bank<=CFG_MAX_FLASH_BANKS; ++bank) {
			printf ("Erase Flash Bank # %ld ", bank);
			info = &flash_info[bank-1];
			rcode = flash_erase (info, 0, info->sector_count-1);
		}
		return rcode;
	}

	if ((n = abbrev_spec(argv[1], &info, &sect_first, &sect_last)) != 0) {
		if (n < 0) {
			printf("Bad sector specification\n");
			return 1;
		}
		printf ("Erase Flash Sectors %d-%d in Bank # %d ",
			sect_first, sect_last, (info-flash_info)+1);
		rcode = flash_erase(info, sect_first, sect_last);
		return rcode;
	}

	if (argc != 3) {
		printf ("Usage:\n%s\n", cmdtp->usage);
		return 1;
	}

	if (strcmp(argv[1], "bank") == 0) {
		bank = simple_strtoul(argv[2], NULL, 16);
		if ((bank < 1) || (bank > CFG_MAX_FLASH_BANKS)) {
			printf ("Only FLASH Banks # 1 ... # %d supported\n",
				CFG_MAX_FLASH_BANKS);
			return 1;
		}
		printf ("Erase Flash Bank # %ld ", bank);
		info = &flash_info[bank-1];
		rcode = flash_erase (info, 0, info->sector_count-1);
		return rcode;
	}

	addr_first = simple_strtoul(argv[1], NULL, 16);
	addr_last  = simple_strtoul(argv[2], NULL, 16);

	if (addr_first >= addr_last) {
		printf ("Usage:\n%s\n", cmdtp->usage);
		return 1;
	}

	printf ("Erase Flash from 0x%08lx to 0x%08lx ", addr_first, addr_last);
	rcode = flash_sect_erase(addr_first, addr_last);
	return rcode;
}

int flash_sect_erase (ulong addr_first, ulong addr_last)
{
	flash_info_t *info;
	ulong bank;
	int s_first, s_last;
	int erased;
	int rcode = 0;

	erased = 0;

	for (bank=0,info=&flash_info[0]; bank < CFG_MAX_FLASH_BANKS; ++bank, ++info) {
		ulong b_end;
		int sect;

		if (info->flash_id == FLASH_UNKNOWN) {
			continue;
		}

		b_end = info->start[0] + info->size - 1; /* bank end addr */

		s_first = -1;		/* first sector to erase	*/
		s_last  = -1;		/* last  sector to erase	*/

		for (sect=0; sect < info->sector_count; ++sect) {
			ulong end;		/* last address in current sect	*/
			short s_end;

			s_end = info->sector_count - 1;

			end = (sect == s_end) ? b_end : info->start[sect + 1] - 1;

			if (addr_first > end)
				continue;
			if (addr_last < info->start[sect])
				continue;

			if (addr_first == info->start[sect]) {
				s_first = sect;
			}
			if (addr_last  == end) {
				s_last  = sect;
			}
		}
		if (s_first>=0 && s_first<=s_last) {
			erased += s_last - s_first + 1;
			rcode = flash_erase (info, s_first, s_last);
		}
	}
	if (erased) {
		printf ("Erased %d sectors\n", erased);
	} else {
		printf ("Error: start and/or end address"
			" not on sector boundary\n");
		rcode = 1;
	}
	return rcode;
}


int do_protect (cmd_tbl_t *cmdtp, int flag, int argc, char *argv[])
{
	flash_info_t *info;
	ulong bank, addr_first, addr_last;
	int i, p, n, sect_first, sect_last;
	int rcode = 0;

	if (argc < 3) {
		printf ("Usage:\n%s\n", cmdtp->usage);
		return 1;
	}

	if (strcmp(argv[1], "off") == 0)
		p = 0;
	else if (strcmp(argv[1], "on") == 0)
		p = 1;
	else {
		printf ("Usage:\n%s\n", cmdtp->usage);
		return 1;
	}

	if (strcmp(argv[2], "all") == 0) {
		for (bank=1; bank<=CFG_MAX_FLASH_BANKS; ++bank) {
			info = &flash_info[bank-1];
			if (info->flash_id == FLASH_UNKNOWN) {
				continue;
			}
			printf ("%sProtect Flash Bank # %ld\n",
				p ? "" : "Un-", bank);

			for (i=0; i<info->sector_count; ++i) {
#if defined(CFG_FLASH_PROTECTION)
				if (flash_real_protect(info, i, p))
					rcode = 1;
				serial_putc ('.');
#else
				info->protect[i] = p;
#endif	/* CFG_FLASH_PROTECTION */
			}
		}

#if defined(CFG_FLASH_PROTECTION)
		if (!rcode) puts (" done\n");
#endif	/* CFG_FLASH_PROTECTION */

		return rcode;
	}

	if ((n = abbrev_spec(argv[2], &info, &sect_first, &sect_last)) != 0) {
		if (n < 0) {
			printf("Bad sector specification\n");
			return 1;
		}
		printf("%sProtect Flash Sectors %d-%d in Bank # %d\n",
			p ? "" : "Un-", sect_first, sect_last,
			(info-flash_info)+1);

		for (i = sect_first; i <= sect_last; i++) {
#if defined(CFG_FLASH_PROTECTION)
			if (flash_real_protect(info, i, p))
				rcode =  1;
			serial_putc ('.');
#else
			info->protect[i] = p;
#endif	/* CFG_FLASH_PROTECTION */
		}

#if defined(CFG_FLASH_PROTECTION)
		if (!rcode) puts (" done\n");
#endif	/* CFG_FLASH_PROTECTION */

		return rcode;
	}

	if (argc != 4) {
		printf ("Usage:\n%s\n", cmdtp->usage);
		return 1;
	}

	if (strcmp(argv[2], "bank") == 0) {
		bank = simple_strtoul(argv[3], NULL, 16);
		if ((bank < 1) || (bank > CFG_MAX_FLASH_BANKS)) {
			printf ("Only FLASH Banks # 1 ... # %d supported\n",
				CFG_MAX_FLASH_BANKS);
			return 1;
		}
		printf ("%sProtect Flash Bank # %ld\n",
			p ? "" : "Un-", bank);
		info = &flash_info[bank-1];

		if (info->flash_id == FLASH_UNKNOWN) {
			printf ("missing or unknown FLASH type\n");
			return 1;
		}

		for (i=0; i<info->sector_count; ++i) {
#if defined(CFG_FLASH_PROTECTION)
			if (flash_real_protect(info, i, p))
				rcode =  1;
			serial_putc ('.');
#else
			info->protect[i] = p;
#endif	/* CFG_FLASH_PROTECTION */
		}

#if defined(CFG_FLASH_PROTECTION)
		if (!rcode) puts (" done\n");
#endif	/* CFG_FLASH_PROTECTION */

		return rcode;
	}

	addr_first = simple_strtoul(argv[2], NULL, 16);
	addr_last  = simple_strtoul(argv[3], NULL, 16);

	if (addr_first >= addr_last) {
		printf ("Usage:\n%s\n", cmdtp->usage);
		return 1;
	}
	rcode = flash_sect_protect (p, addr_first, addr_last);
	return rcode;
}


int flash_sect_protect (int p, ulong addr_first, ulong addr_last)
{
	flash_info_t *info;
	ulong bank;
	int s_first, s_last;
	int protected, i;
	int rcode = 0;

	protected = 0;

	for (bank=0,info=&flash_info[0]; bank < CFG_MAX_FLASH_BANKS; ++bank, ++info) {
		ulong b_end;
		int sect;

		if (info->flash_id == FLASH_UNKNOWN) {
			continue;
		}

		b_end = info->start[0] + info->size - 1; /* bank end addr */

		s_first = -1;		/* first sector to erase	*/
		s_last  = -1;		/* last  sector to erase	*/

		for (sect=0; sect < info->sector_count; ++sect) {
			ulong end;		/* last address in current sect	*/
			short s_end;

			s_end = info->sector_count - 1;

			end = (sect == s_end) ? b_end : info->start[sect + 1] - 1;

			if (addr_first > end)
				continue;
			if (addr_last < info->start[sect])
				continue;

			if (addr_first == info->start[sect]) {
				s_first = sect;
			}
			if (addr_last  == end) {
				s_last  = sect;
			}
		}
		if (s_first>=0 && s_first<=s_last) {
			protected += s_last - s_first + 1;
			for (i=s_first; i<=s_last; ++i) {
#if defined(CFG_FLASH_PROTECTION)
				if (flash_real_protect(info, i, p))
					rcode = 1;
				serial_putc ('.');
#else
				info->protect[i] = p;
#endif	/* CFG_FLASH_PROTECTION */
			}
		}
#if defined(CFG_FLASH_PROTECTION)
		if (!rcode) serial_putc ('\n');
#endif	/* CFG_FLASH_PROTECTION */

	}
	if (protected) {
		printf ("%sProtected %d sectors\n",
			p ? "" : "Un-", protected);
	} else {
		printf ("Error: start and/or end address"
			" not on sector boundary\n");
		rcode = 1;
	}
	return rcode;
}
