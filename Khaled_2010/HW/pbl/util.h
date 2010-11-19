/**
 * @file util.h
 */

/*
 * (C) Copyright 2003
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


#ifndef UTIL_H
#define UTIL_H

int printf (const char *fmt, ...);
void flush_cache (ulong start_addr, ulong size);

unsigned long simple_strtoul(const char *cp,char **endp,unsigned int base);
long simple_strtol(const char *cp,char **endp,unsigned int base);
int vsprintf(char *buf, const char *fmt, va_list args);
int sprintf(char * buf, const char *fmt, ...);
char * strcpy(char * dest,const char *src);
int strcmp(const char * cs,const char * ct);
int strncmp(const char * cs,const char * ct,size_t count);
char * strchr(const char * s, int c);
size_t strlen(const char * s);
size_t strnlen(const char * s, size_t count);
void * memset(void * s,int c,size_t count);
void * memcpy(void * dest,const void *src,size_t count);
void * memmove(void * dest,const void *src,size_t count);
int memcmp(const void * cs,const void * ct,size_t count);
void * memscan(void * addr, int c, size_t size);
void *memchr(const void *s, int c, size_t n);


#endif
