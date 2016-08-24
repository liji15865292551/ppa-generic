/*
 * Copyright (c) 2016, NXP Semiconductors
 * All rights reserved.
 *
 * Author York Sun <york.sun@nxp.com>
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of NXP Semiconductors nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * ALTERNATIVELY, this software may be distributed under the terms of the
 * GNU General Public License ("GPL") as published by the Free Software
 * Foundation, either version 2 of that License or (at your option) any
 * later version.
 *
 * THIS SOFTWARE IS PROVIDED BY NXP Semiconductors "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL NXP Semiconductors BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef __IO_H__
#define __IO_H__

/*
 * These macros are for ARM-based SoCs.
 * Raw IO access is presumed to be in little-endian.
 */
#define out8(a,v)	(*(volatile unsigned char *)(a) = (v))
#define out16(a,v)	(*(volatile unsigned short *)(a) = (v))
#define out32(a,v)	(*(volatile unsigned int *)(a) = (v))
#define out64(a,v)	(*(volatile unsigned long long *)(a) = (v))
#define in8(a)		(*(volatile unsigned char *)(a))
#define in16(a)		(*(volatile unsigned short *)(a))
#define in32(a)		(*(volatile unsigned int *)(a))
#define in64(a)		(*(volatile unsigned long long *)(a))

#define in_le16(a)	in16(a)
#define in_le32(a)	in32(a)
#define in_le64(a)	in64(a)
#define out_le16(a,v)	out16(a,v)
#define out_le32(a,v)	out32(a,v)
#define out_le64(a,v)	out64(a,v)
#define setbits_le32(a,v)	out_le32((a), in_le32(a) | (set))
#define clrbits_le32(a,c)	out_le32((a), in_le32(a) & ~(c))
#define clrsetbits_le32(a,c,s)	out_le32((a), (in_le32(a) & ~(c)) | (s))

#define uswap16(v)	((((v) & 0xff00) >> 8) | (((v) & 0xff) << 8))
#define uswap32(v)	((((v) & 0xff000000) >> 24)	|\
			 (((v) & 0x00ff0000) >> 8)	|\
			 (((v) & 0x0000ff00) << 8)	|\
			 (((v) & 0x000000ff) << 24))
#define uswap64(v)	((((v) & 0xff00000000000000ULL) >> 56)	|\
			 (((v) & 0x00ff000000000000ULL) >> 40)	|\
			 (((v) & 0x0000ff0000000000ULL) >> 24)	|\
			 (((v) & 0x000000ff00000000ULL) >> 8)	|\
			 (((v) & 0x00000000ff000000ULL) << 8)	|\
			 (((v) & 0x0000000000ff0000ULL) << 24)	|\
			 (((v) & 0x000000000000ff00ULL) << 40)	|\
			 (((v) & 0x00000000000000ffULL) << 56))

#define out_be16(a,v)	out16(a,uswap16(v))
#define out_be32(a,v)	out32(a,uswap32(v))
#define out_be64(a,v)	out64(a,uswap64(v))
#define in_be16(a)	uswap16(in16(a))
#define in_be32(a)	uswap32(in32(a))
#define in_be64(a)	uswap64(in64(a))
#define setbits_be32(a,v)	out_be32((a), in_be32(a) | (set))
#define clrbits_be32(a,c)	out_be32((a), in_be32(a) & ~(c))
#define clrsetbits_be32(a,c,s)	out_be32((a), (in_be32(a) & ~(c)) | (s))

#define uart_in		in8
#define uart_out	out8
#define i2c_in		in8
#define i2c_out		out8

#ifdef CONFIG_SYS_FSL_CCSR_DDR_BE
#define ddr_in32(a)			in_be32(a)
#define ddr_out32(a, v)			out_be32(a, v)
#define ddr_setbits32(a, v)		setbits_be32(a, v)
#define ddr_clrbits32(a, v)		clrbits_be32(a, v)
#define ddr_clrsetbits32(a, clear, set)	clrsetbits_be32(a, clear, set)
#elif defined(CONFIG_SYS_FSL_CCSR_DDR_LE)
#define ddr_in32(a)			in_le32(a)
#define ddr_out32(a, v)			out_le32(a, v)
#define ddr_setbits32(a, v)		setbits_le32(a, v)
#define ddr_clrbits32(a, v)		clrbits_le32(a, v)
#define ddr_clrsetbits32(a, clear, set)	clrsetbits_le32(a, clear, set)
#else
#error Please define CCSR DDR register endianness
#endif

#ifdef CONFIG_SYS_FSL_CCSR_GUR_BE
#define gur_in32(a)	in_be32(a)
#define gur_out32(a, v)	out_be32(a, v)
#elif defined(CONFIG_SYS_FSL_CCSR_GUR_LE)
#define gur_in32(a)	in_le32(a)
#define gur_out32(a, v)	out_le32(a, v)
#else
#error Please define CCSR GUR register endianness
#endif

#define mb()		asm volatile("dsb sy" : : : "memory")
#define isb()		asm volatile("isb" : : : "memory")
#endif /* __IO_H__ */
