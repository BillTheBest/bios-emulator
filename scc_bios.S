/*
 * Copyright (C) 2011, Jan-Arne Sobania <jan-arne.sobania@hpi.uni-potsdam.de>, Hasso-Plattner-Institut 
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE, GOOD TITLE or
 * NON INFRINGEMENT.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

/* Activate this option to read the amount of private memory from the FPGA's
 * GRB space (0xF9008244, "Private memory slots").
 *
 * If this option is not used, a default amount of SCCBIOS_DEFAULT_MEMSIZE_MB
 * is used.
 */
#define SCCBIOS_QUERY_MEMSIZE_FROM_FPGA
#define SCCBIOS_DEFAULT_MEMSIZE_MB		512

/* Print information as the bootloader invokes BIOS interrupts */
//#define SCCBIOS_TRACE_INT15_CALLS

/* Print BIOS banner message on boot */
#define SCCBIOS_PRINT_BANNER

/* Print configured tile frequency.
 * With this option, the BIOS reads the clock divisor from the tile's
 * configuration register (GCBCFG) and the global clock configuration from the
 * FPGA's GRB space (0xF9008230). */
#define SCCBIOS_PRINT_FREQUENCY_FROM_FPGA

/* Print TILEID on boot */
#define SCCBIOS_PRINT_TILEID

/* Print size of private memory on boot */
#define SCCBIOS_PRINT_MEMSIZE


/******************************************************************************
 * SCC BIOS Interrupt Entry Points
 */
.code16	
.text
	.globl _start

.org 0x0000	// INT 0x00
_start:
INT_00:
	iret

.org 0x0008	// INT 0x01
INT_01:
	iret

.org 0x0010	// INT 0x02
INT_02:
	iret

.org 0x0018	// INT 0x03
INT_03:
	iret

.org 0x0020	// INT 0x04
INT_04:
	iret

.org 0x0028	// INT 0x05
INT_05:
	iret

.org 0x0030	// INT 0x06
INT_06:
	iret

.org 0x0038	// INT 0x07
INT_07:
	iret

.org 0x0040	// INT 0x08
INT_08:
	iret

.org 0x0048	// INT 0x09
INT_09:
	iret

.org 0x0050	// INT 0x0A
INT_0A:
	iret

.org 0x0058	// INT 0x0B
INT_0B:
	iret

.org 0x0060	// INT 0x0C
INT_0C:
	iret

.org 0x0068	// INT 0x0D
INT_0D:
	iret

.org 0x0070	// INT 0x0E
INT_0E:
	iret

.org 0x0078	// INT 0x0F
INT_0F:
	iret

.org 0x0080	// INT 0x10
INT_10:
	iret

.org 0x0088	// INT 0x11
INT_11:
	iret

.org 0x0090	// INT 0x12
INT_12:
	iret

.org 0x0098	// INT 0x13
INT_13:
	iret

.org 0x00A0	// INT 0x14
INT_14:
	iret

.org 0x00A8	// INT 0x15
INT_15:
	jmp INT_15_entry

.org 0x00B0	// INT 0x16
INT_16:
	iret

.org 0x00B8	// INT 0x17
INT_17:
	iret

.org 0x00C0	// INT 0x18
INT_18:
	iret

.org 0x00C8	// INT 0x19
INT_19:
	iret

.org 0x00D0	// INT 0x1A
INT_1A:
	iret

.org 0x00D8	// INT 0x1B
INT_1B:
	iret

.org 0x00E0	// INT 0x1C
INT_1C:
	iret

.org 0x00E8	// INT 0x1D
INT_1D:
	iret

.org 0x00F0	// INT 0x1E
INT_1E:
	iret

.org 0x00F8	// INT 0x1F
INT_1F:
	iret


#if defined(SCCBIOS_TRACE_INT15_CALLS) || defined(SCCBIOS_PRINT_BANNER) || \
    defined(SCCBIOS_PRINT_TILEID) || defined(SCCBIOS_PRINT_MEMSIZE)
/**********************************\
 * Write character to UART @ 0x3f8
 * Usage:
 *   push $'X'
 *   call uart_putchr
\**********************************/

uart_putchr:
	push	%bp
	mov	%sp, %bp
	push	%ax
	push	%dx

	movw	$0x3f8, %dx

	movb	4(%bp), %al
	outb	%al, %dx

	pop	%dx
	pop	%ax

	leave
	ret	$2


/**********************************************************************\
 * Tracing support
 *
 *  push $1234567
 *  call uart_put_d32	// print 32-bit value as decimal
 **********************************************************************
 *  push $42
 *  call uart_put_d8	// print 8-bit value as decimal
 **********************************************************************
 *  push $'X'
 *  call uart_put_u8	// print 8-bit value as hex
 **********************************************************************
 *  push %ax
 *  call uart_put_u16   // print 16-bit value as hex
 **********************************************************************
 *  push %eax
 *  call uart_put_u32   // print 32-bit value as hex
 **********************************************************************
 *  .ascii "msg...\0"
 *  push $msg
 *  call uart_puts      // print string
 **********************************************************************
 *  call uart_put_crlf  // newline
\**********************************************************************/

uart_hex_chr_map:
	.byte '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'

uart_put_d32:
	push	%bp
	mov	%sp, %bp
	push	%eax
	push	%ebx
	push	%ecx
	push	%edx

	mov	4(%bp), %eax	/* EAX == value */

	mov	$1, %ebx	/* for (EBX = 1; value > EBX*10; EBX*=10 */
	jmp	2f
1:	mov	%ecx, %ebx
2:	lea	(%ebx,%ebx,4), %ecx
	add	%ecx, %ecx
	cmp	%eax, %ecx
	jbe	1b	

	mov	$0xcccccccd, %ecx
3:	xor	%edx, %edx	/* EDX = value % EBX; EAX = value / EBX */
	div	%ebx
	add	$'0', %eax	/* uart_putchr('0' + EAX) */
	push	%ax
	call	uart_putchr

	mov	%ebx, %eax	/* Integer division using reciprocals */
	mov	%edx, %ebx
	mul	%ecx		/* "EBX/=10" <=> "EBX:=(EBX*0xCCCCCCCD)>>35" */
	mov	%edx, %eax
	xchg	%eax, %ebx
	shr	$3, %ebx	/* EBX = EBX / 10 */
	jne	3b		/* while(EBX != 0) */

	pop	%edx
	pop	%ecx
	pop	%ebx
	pop	%eax
	mov	%bp, %sp
	pop	%bp
	ret	$4

uart_put_d8:
	push	%bp
	mov	%sp, %bp
	push	%ax
	push	%bx

	movw	4(%bp), %ax
	movb	$100, %bl
	div	%bl			/* al = num / 100 */
	test	%al, %al
	je	1f
	movzxb	%al, %bx
	push	uart_hex_chr_map(%bx)
	call	uart_putchr
1:

	mul	%bl
	movw	4(%bp), %bx
	sub	%al, %bl		/* bl = num - (num / 100) * 100 */
	mov	%bl, %al
	movb	$10, %bl
	div	%bl			/* al = bl / 10, ah = bl % 10 */
	test	%al, %al
	je	2f
	movzxb	%al, %bx
	push	uart_hex_chr_map(%bx)
	call	uart_putchr
2:
	movzxb	%ah, %bx
	push	uart_hex_chr_map(%bx)
	call	uart_putchr
	
	pop	%bx
	pop	%ax
	leave
	ret	$2

uart_put_u8:
	push	%bp
	mov	%sp, %bp
	push	%bx

	xor	%bx,%bx
	movb	4(%bp), %bl
	shr	$4, %bx
	push	uart_hex_chr_map(%bx)
	call	uart_putchr

	movb	4(%bp), %bl
	andb	$0xF, %bl
	push	uart_hex_chr_map(%bx)
	call	uart_putchr

	pop	%bx
	leave
	ret	$2

uart_put_u16:
	push	%bp
	mov	%sp, %bp

	push	5(%bp)
	call	uart_put_u8

	push	4(%bp)
	call	uart_put_u8

	leave
	ret	$2

uart_put_u32:
	push	%bp
	mov	%sp, %bp

	push	7(%bp)
	call	uart_put_u8

	push	6(%bp)
	call	uart_put_u8

	push	5(%bp)
	call	uart_put_u8

	push	4(%bp)
	call	uart_put_u8

	leave
	ret	$4

uart_put_crlf:
	push	%bp
	mov	%sp, %bp

	push	$13
	call	uart_putchr
	push	$10
	call	uart_putchr

	leave
	ret

uart_puts:
	push	%bp
	mov	%sp, %bp
	push	%ax
	push	%si

	movw	4(%bp), %si

uart_puts_loop:
	movb	%ds:(%si), %al
	test	%al, %al
	jz	uart_puts_end
	push	%ax
	call	uart_putchr
	inc	%si
	jmp	uart_puts_loop

uart_puts_end:
	pop	%si
	pop	%ax
	leave
	ret	$2
#endif

/*****************************************************************************\
 * Protected Mode Support                                                    *
 *                                                                           *
 * This code is based on the "flat real mode" example that can be found at   *
 * http://www.assembly.happycodings.com/code54.html                          *
 *                                                                           *
 * Purpose: set_flat_fs is called in real mode, and returns with a specially-*
 *          crafted fs segment that can be used with a 32-bit offset to      *
 *          access *any* physical address of the core.                       *
 * Method:  The code abuses the protected mode operation of the processor.   *
 *          When loading a segment selector in protected mode, the shadow    *
 *          portion of the segment register gets updated from the GDT, and   *
 *          this information persists when switching back to real mode.      *
 *          Therefore, this routine sets up a minimal protected mode         *
 *          environment with only one, flat, 4GB data segment, and loads its *
 *          selector into fs. Then, it switches back to real mode, with fs   *
 *          still mapping the whole address space.                           *
 * Side Effect: The manipulated fs's bounds are never restored, so this may  *
 *              lead to unexpected behaviour in the calling boot loader.     *
 *              However, the Linux boot code does not seem to care; or just  *
 *              stick to The Rules (R) and use at max 64KB offsets.          *
\*****************************************************************************/

gdt:	
	/* Descriptor [0] */
	/* This descriptor is ignored by the processor core, so we can use this
	 * space to construct the contents of the GDTR */
	.word gdt_end - gdt - 1	/* GDT limit is hardcoded */
	.long gdt+0xF0000	/* GDT address depends on load segment. */
	.byte 0, 0		/* Padding */

	/* Descriptor [1] */
	.word 0xffff, 0	/* Limit[15:0]=0xFFFF, Base[15:0]=0 */
	.byte 0		/* Base[23:16]=0 */
	.byte 0x93	/* P(resent)=1,DPL=0,S=1,Type=3 (Data Read/Write+Acc) */
	.byte 0x8f	/* G(ranularity)=1 (4kB),D/B=0 (16-bit), Limit[19:16]=0xF */
	.byte 0		/* Base[31:24]=0 */
gdt_end:

set_flat_fs:
	pushl	%eax
	pushl	%ebx
	pushf

	lgdtl	(gdt)

	movw	$8, %bx		/* Segment selector: index=1, L=0 (GDT), DPL=0 */
	movl	%cr0, %eax
	orb	$1, %al
	cli
	movl	%eax, %cr0	/* Enter Protected Mode */
	movw	%bx, %fs
	andb	$0xFE, %al
	movl	%eax, %cr0	/* Exit Protected Mode */

	popf
	popl	%ebx
	popl	%eax
	ret

.align	32


/*****************************************************************************\
 * BIOS Interrupt 0x15                                                       *
\*****************************************************************************/

e820_map_entry_count:
	.long 12
e820_map:
/*[0]*/	.long 0x00000000, 0, 0x000fffff, 0, 1	// [0]: @0x0_00000000 - 0x0_000fffff, type = 1 (RAM)
/*[1]*/	.long 0x00100000, 0, 0x00000000, 0, 1	// [1]: @0x0_00100000 - 0x0_????????, type = 1 (RAM) Initialized when required
/*[2]*/	.long 0xFEE00000, 0, 0x00001000, 0, 2	// [2]: @0x0_FEE00000 - 0x0_FEE00FFF, type = 2 (reserved/APIC)

	/* Shared Memory of the default LUT mapping
	 *
	 * Really, this is @0x0_80000000 - 0x0_83FFFFFF, but with lots of space
	 * reserved for other things like performance meter, on-die network
	 * (in case the MPB is left for user code/RCCE), and MCPC network/crbnet.
	 *
	 * These ranges have been excluded here, leading to this particularly
	 * convoluted memory map...
	 */
      //.long 0x80000000, 0, 0x00181000, 0, 129 // 1540KB @  0MB: SHM TTY1 & Perfmeter
/*[3]*/	.long 0x80181000, 0, 0x0000F000, 0, 129
      //.long 0x80190000, 0, 0x00060000, 0, 129 //  384KB @ 16KB: rckmb (on-chip network)
/*[4]*/	.long 0x801F0000, 0, 0x00010000, 0, 129
      //.long 0x80200000, 0, 0x000C0000, 0, 129 //  768KB @  2MB: rckpc (Host network)
/*[5]*/	.long 0x802C0000, 0, 0x00D40000, 0, 129

      //.long 0x81000000, 0, 0x00181000, 0, 129 // 1540KB @  0MB: SHM TTY2 & Perfmeter
/*[6]*/	.long 0x81181000, 0, 0x0006F000, 0, 129
      //.long 0x81200000, 0, 0x000C0000, 0, 129 //  768KB @  2MB: rckpc (Host network)
/*[7]*/	.long 0x812C0000, 0, 0x00D40000, 0, 129

      //.long 0x82000000, 0, 0x00181000, 0, 129 // 1540KB @  0MB: SHM TTY3 & Perfmeter
/*[8]*/	.long 0x82181000, 0, 0x0006F000, 0, 129
      //.long 0x82200000, 0, 0x000C0000, 0, 129 //  768KB @  2MB: rckpc (Host network)
/*[9]*/	.long 0x822C0000, 0, 0x00D40000, 0, 129

      //.long 0x83000000, 0, 0x00181000, 0, 129 // 1540KB @  0MB: SHM TTY4 & Perfmeter
/*[a]*/	.long 0x83181000, 0, 0x0006F000, 0, 129
      //.long 0x83200000, 0, 0x000C0000, 0, 129 //  768KB @  2MB: rckpc (Host network)
/*[b]*/	.long 0x832C0000, 0, 0x00D40000, 0, 129

#ifdef SCCBIOS_TRACE_INT15_CALLS
INT_15_entry_message:
	.ascii "INT 15: ax = \0"
INT_15_e820_message:
	.ascii ", bx = \0"
#endif
#ifdef SCCBIOS_PRINT_BANNER
INT_15_banner_message:
	.ascii "RockCreek BIOS, v0.2\r\nCopyright(C) Jan-Arne Sobania, Hasso-Plattner-Institut\r\n\0"
#endif
#ifdef SCCBIOS_PRINT_TILEID
INT_15_tileid_message:
	.ascii "TILEID = 0x\0"
INT_15_location_message1:
	.ascii ": x=\0"
INT_15_location_message2:
	.ascii ",y=\0"
INT_15_location_message3:
	.ascii ",core=\0"
INT_15_location_message4:
	.ascii " => pid=\0"
#endif
#ifdef SCCBIOS_PRINT_FREQUENCY_FROM_FPGA
INT_15_freq_message:
	.ascii "FREQ   = \0"
INT_15_freq_khz_message:
	.ascii " kHz\0"
#endif
#ifdef SCCBIOS_PRINT_MEMSIZE
INT_15_mem_message:
	.ascii "Usable memory = 0x\0"
#endif

INT_15_entry:
	push	%bp
	mov	%sp, %bp

	push	%ds
	push	$0xF000
	pop	%ds

	// switch(%ax)
	cmpw	$0xe820, %ax
	je	INT_15_e820


	// default:
	// printf("INT 15: ax = %04x\n", %ax);
#ifdef SCCBIOS_TRACE_INT15_CALLS
	push	$INT_15_entry_message
	call	uart_puts
	push	%ax
	call	uart_put_u16
	call	uart_put_crlf
#endif

	jmp	INT_15_exit


#define SMAP	0x534d4150	/* ASCII "SMAP" */


	// case 0xe820:
INT_15_e820:	// function ax=0xe820: query memory map

#ifdef SCCBIOS_TRACE_INT15_CALLS
	// printf("INT 15: ax = %04x, bx = %04x\n", %ax);
	push	$INT_15_entry_message
	call	uart_puts
	push	%ax
	call	uart_put_u16
	push	$INT_15_e820_message
	call	uart_puts
	push	%bx
	call	uart_put_u16
	call	uart_put_crlf
#endif

	push	%es
	push	%di
	push	%dx

	orb	$0x1, 6(%bp)	// set carry/assume failure

	cmpl	$SMAP, %edx	// check SMAP signature
	jne	INT_15_e820_exit
	cmp	$20, %ecx	// we need to return at least 20 bytes per entry
	jl	INT_15_e820_exit
	cmpl	(e820_map_entry_count), %ebx	// abort if beyond last entry
	jge	INT_15_e820_exit

	/* Perform initialization of the e820 memory map only once */
	movl	(e820_map+7*4), %eax
	test	%eax, %eax
	jne	INT_15_e820_docopy

#ifdef SCCBIOS_PRINT_BANNER
	/* Print the banner */
	push	$INT_15_banner_message
	call	uart_puts
#endif

	/* Enable access to 32-bit address space */
	push	%fs
	call	set_flat_fs

#ifdef SCCBIOS_PRINT_TILEID
	/* Get and display the TILEID register */
	movl	$0xF8000100, %eax	/* CRB:0x0100: TILEID */
	movl	%fs:(%eax), %eax
	push	$INT_15_tileid_message
	call	uart_puts
	push	%eax
	call	uart_put_u32
	push	$INT_15_location_message1
	call	uart_puts
	movl	%eax, %ecx
	shrl	$3, %ecx		/* ecx = TILEID.x */
	andl	$15, %ecx
	push	%cx
	call	uart_put_d8
	push	$INT_15_location_message2
	call	uart_puts
	movl	%eax, %ecx
	shrl	$7, %ecx		/* ecx = TILEID.y */
	andl	$15, %ecx
	push	%cx
	call	uart_put_d8
	push	$INT_15_location_message3
	call	uart_puts
	movl	%eax, %ecx
	andl	$7, %ecx		/* ecx = TILEID.z */
	push	%cx
	call	uart_put_d8
	push	$INT_15_location_message4
	call	uart_puts

	movl	%eax, %edx
	andl	$1, %edx
	movl	%eax, %ecx
	shrl	$2, %ecx
	andl	$30, %ecx
	add	%ecx, %edx
	shrl	$7, %eax
	andl	$15, %eax
	imul	$12, %eax
	add	%eax, %edx		/* edx = z + x*2 + y*12 */

	push	%dx
	call	uart_put_d8	
	call	uart_put_crlf
#endif

#ifdef SCCBIOS_PRINT_FREQUENCY_FROM_FPGA
	/* Get and display the current tile frequency */
	movl	$0xF9008230, %eax
	movl	%fs:(%eax), %edx	/* GRB:0x8230: FASTCLOCK */
	movzwl	%dx, %eax
	test	%eax, %eax
	je	1f			/* if (!fastclock) freq = 533000 */

	movl	$0xF8000080, %ecx
	movl	%fs:(%ecx), %ecx	/* CRB:0x0080: GCBCFG */
	shr	$8, %ecx
	and	$15, %ecx
	inc	%ecx			/* divider = ((GCBCFG >> 8) & 0xF)+1 */

	xor	%edx, %edx
	div	%ecx
	lea	(%eax, %eax, 4), %eax
	lea	(%eax, %eax, 4), %eax
	lea	(%eax, %eax, 4), %eax
	lea	(,%eax,8), %eax		/* freq = fastclock / divider * 1000 */
	jmp	2f
1:
	movl	$533000, %eax		/* freq = 533000 */
2:
	push	$INT_15_freq_message
	call	uart_puts
	push	%eax
	call	uart_put_d32
	push	$INT_15_freq_khz_message
	call	uart_puts
	call	uart_put_crlf
#endif

	/* Get the amount of available local memory and initialize the E820 map */
#ifdef SCCBIOS_QUERY_MEMSIZE_FROM_FPGA
	movl	$0xF9008244, %eax
	movl	%fs:(%eax), %eax	/* GRB:0x8244: Private Memory Slots */
	andb	$0xFF, %al

	cmpl	$41, %eax		/* Never use more than 41 slots */
	jle	1f
	movl	$41, %eax
1:
	cmpl	$4, %eax		/* Never use less than 4 slots */
	jge	2f
	movl	$4, %eax
2:

	shll	$24, %eax
#else
	movl	$1024*1024*SCCBIOS_DEFAULT_MEMSIZE_MB, %eax	/* Use the default amount */
#endif

	/* Restore old FS selector. Access to 32-bit address space is no longer
	 * possible beyond this instruction. */
	pop	%fs

#ifdef SCCBIOS_PRINT_MEMSIZE
	push	$INT_15_mem_message
	call	uart_puts
	push	%eax
	call	uart_put_u32
	call	uart_put_crlf
#endif

	subl	(e820_map+5*4+0), %eax
	movl	%eax, (e820_map+7*4)

INT_15_e820_docopy:
	cld
	mov	%bx, %cx
	mov	%bx, %si
	shlw	$4, %cx
	shlw	$2, %si
	add	%cx, %si			// si = bx*16 + bx*4
	add	$e820_map, %si			// si += &e820_map
	mov	$20, %cx
	repe movsb				// memcpy(es:di, ds:si, 20)
	movl	$20, %ecx
	inc	%ebx

	movl	$SMAP, %eax
	andb	$0xFE, 6(%bp)	// clear carry

	// end_switch
INT_15_e820_exit:
	pop	%dx
	pop	%di
	pop	%es

	// return from interrupt 0x15
INT_15_exit:
	pop	%ds
	leave
	iret
