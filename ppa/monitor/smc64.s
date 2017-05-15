//-----------------------------------------------------------------------------
// 
// Copyright (c) 2013-2016, Freescale Semiconductor
// Copyright 2017 NXP Semiconductors
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
// 
// 1. Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
// 
// 3. Neither the name of the copyright holder nor the names of its contributors
//    may be used to endorse or promote products derived from this software
//    without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED.IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// Author Rod Dorris <rod.dorris@nxp.com>
// 
//-----------------------------------------------------------------------------

  .section .text, "ax"

//-----------------------------------------------------------------------------

#include "aarch64.h"
#include "smc.h"

//-----------------------------------------------------------------------------

.global smc64_handler
.global _initialize_smc
.global _getEL2Width

//-----------------------------------------------------------------------------

 // function classes
.equ  SMC64_ARM_ARCH,   0xC0
.equ  SMC64_CPU_SVC,    0xC1
.equ  SMC64_SIP_SVC,    0xC2
.equ  SMC64_OEM_SVC,    0xC3
.equ  SMC64_STD_SVC,    0xC4
.equ  SMC64_TRSTD_APP,  0xF0
.equ  SMC64_TRSTD_APP2, 0xF1

.equ  SIP64_FUNCTION_COUNT,  0x5
.equ  ARCH64_FUNCTION_COUNT, 0x2

//-----------------------------------------------------------------------------

smc64_handler:
     // secure monitor smc64 interface lives here
     // Note: this secure monitor only implements "fast calls", thus
     //       interrupts are disabled during execution of the call

     // per the ARM SMC Calling convention:
     // x0     = function id 
     // x1-x5  = function parameters 
     // x6     = session id (optional) 
     // x7     = hypervisor client id
     // x8     = indirect result location register
     // x9-x15 = volatile/scratch

     // mask interrupts
    msr  DAIFset, #0xF

     // invalidate tlb
    tlbi alle3
    dsb  sy
    isb

     // extract bits 31:24 to see what class of function this is
    mov   x9, xzr
    bfxil x9, x0, #24, #8
     // extract bits 15:0 (the function number)
    mov   x11, xzr
    bfxil x11, x0, #0, #16

     // Note: x11 contains the function number

     // is it SMC64: ARM Architecture Call?
    cmp  x9, #SMC64_ARM_ARCH
    b.eq smc64_arch_svc
     // is it SMC64: CPU Service Call?
    cmp  x9, #SMC64_CPU_SVC
    b.eq smc64_no_services
     // is it SMC64: SiP Service Call?
    cmp  x9, #SMC64_SIP_SVC
    b.eq smc64_sip_svc
     // is it SMC64: OEM Service Call?
    cmp  x9, #SMC64_OEM_SVC
    b.eq smc64_no_services
     // is it SMC64: Std Service Call?
    cmp  x9, #SMC64_STD_SVC
    b.eq _smc64_std_svc
     // is it SMC64: Trusted App Call?
    cmp  x9, #SMC64_TRSTD_APP
    b.eq _smc_unimplemented
     // is it SMC64: Trusted App Call?
    cmp  x9, #SMC64_TRSTD_APP2
    b.eq _smc_unimplemented
     // is it SMC64: Trusted OS Call? (multiple ranges)
    lsr  x10, x9, #4
    cmp  x10, #0xF
    b.eq smc64_no_services

     // if we are here then we have an unimplemented/unrecognized function
    b _smc_unimplemented

     //------------------------------------------

     // Note: x11 contains the function number

smc64_arch_svc:
         // ARCH64 service call COUNT function is 0xFF00
    ldr  x10, =ARCH_COUNT_ID
    and  w10, w10, #SMC_FUNCTION_MASK
    cmp  w10, w11
    b.eq smc64_arch_count

    ldr  x10, =ARCH_EL2_2_AARCH32_ID
    and  w10, w10, #SMC_FUNCTION_MASK
    cmp  w10, w11
    b.eq smc64_arch_el2_2_aarch32

    b    _smc_unimplemented 

     //------------------------------------------

     // Note: x11 contains the function number

smc64_sip_svc:
     // SIP64 service call COUNT function is 0xFF00
    ldr  x10, =SIP_COUNT_ID
    and  w10, w10, #SMC_FUNCTION_MASK
    cmp  w10, w11
    b.eq smc64_sip_count

     // SIP service call PRNG_64
    mov  w10, #SIP_PRNG
    cmp  w10, w11
    b.eq smc64_sip_PRNG

     // SIP service call RNG_64
    mov  w10, #SIP_RNG
    cmp  w10, w11
    b.eq smc64_sip_RNG

     // SIP service call MEMBANK_64
    mov  w10, #SIP_MEMBANK
    cmp  w10, w11
    b.eq smc64_membank_data

    b    _smc_unimplemented 

     //------------------------------------------

 // this function returns the number of smc64 SIP functions implemented
 // the count includes *this* function
smc64_sip_count:
    mov  x12, x30

    mov  x0, #SIP64_FUNCTION_COUNT
    mov  x4,  #0
    mov  x3,  #0
    mov  x2,  #0
    mov  x1,  #0
    b    _smc_success

     //------------------------------------------

 // this is the 64-bit interface to the PRNG function
 // in:  x0 = function id
 //      x1 = 0, 32-bit PRNG requested
 //      x1 = 1, 64-bit PRNG requested
 // out: x0 = 0, success
 //      x0 != 0, failure
 //      x1 = 32-bit PRNG, or 64-bit PRNG
smc64_sip_PRNG:
    mov  x12, x30

    cbz  x1, 1f
     // 64-bit PRNG
    mov  x0, #SIP_PRNG_64BIT
    bl   _get_PRNG
    mov  x1, x0
    b    2f

1:   // 32-bit PRNG
    mov  x0, #SIP_PRNG_32BIT
    bl   _get_PRNG
    mov  x1, x0

2:
    mov  x30, x12
    mov  x3,  xzr
    mov  x4,  xzr

     // check if random number returned is 0
     // report failure in case random number is 0
    cmp  x1, #0x0
    b.eq _smc_failure
    b    _smc_success

     //------------------------------------------

 // this is the 64-bit interface to the hw RNG function
 // in:  x0 = function id
 //      x1 = 0, 32-bit hw RNG requested
 //      x1 = 1, 64-bit hw RNG requested
 // out: x0 = 0, success
 //      x0 != 0, failure
 //      x1 = 32-bit RNG, or 64-bit RNG
smc64_sip_RNG:
    mov  x12, x30

    cbz  x1, 1f
     // 64-bit hw RNG
    mov  x0, #SIP_RNG_64BIT
    bl   _get_RNG
    mov  x1, x0
    b    2f

1:   // 32-bit hw RNG
    mov  x0, #SIP_RNG_32BIT
    bl   _get_RNG
    mov  x1, x0

2:
    mov  x30, x12
    mov  x3,  xzr
    mov  x4,  xzr
     // check if random number returned is 0
     // report failure in case random number is 0
    cmp  x1, #0x0
    b.eq _smc_failure
    b    _smc_success

     //------------------------------------------

 // this function returns the number of smc64 SIP functions implemented
 // the count includes *this* function
smc64_arch_count:
    mov  x12, x30

    mov  x0, #ARCH64_FUNCTION_COUNT
    mov  x4,  #0
    mov  x3,  #0
    mov  x2,  #0
    mov  x1,  #0
    b    _smc_success

     //------------------------------------------

 // this function allows changing the execution width of EL2 from Aarch64
 // to Aarch32
 // Note: MUST be called from EL2 @ Aarch64
 // in:  x1 = start address for EL2 @ Aarch32
 //      x2 = first parameter to pass to EL2 @ Aarch32
 //      x3 = second parameter to pass to EL2 @ Aarch32
 // uses x0, x1, x2, x3, x12
smc64_arch_el2_2_aarch32:
    mov   x12, x30

     // x1 = start address
     // x2 = parm 1
     // x3 = parm2

     // check that we were called from EL2 @ Aarch64 - return "invalid" if not
    mrs  x0, spsr_el3
     // see if we were called from Aarch32
    tst  x0, #SPSR_EL3_M4
    b.ne _smc_invalid

     // see if we were called from EL2
    and   x0, x0, SPSR_EL_MASK
    cmp   x0, SPSR_EL2
    b.ne  _smc_invalid_el

     // set ELR_EL3
    msr  elr_el3, x1

     // set scr_el3
    mov  x0, #SCR_EL3_4_EL2_AARCH32
    msr  scr_el3, x0

     // set sctlr_el2
    ldr   x1, =SCTLR_EL2_RES1
    msr  sctlr_el2, x1

     // set spsr_el3
    ldr  x0, =SPSR32_EL2_LE
    msr  spsr_el3, x0

     // x2 = parm 1
     // x3 = parm2

     // set the parameters to be passed-thru to EL2 @ Aarch32
    mov  x1, x2
    mov  x2, x3

     // x1 = parm 1
     // x2 = parm2

     // invalidate the icache
    ic iallu
    dsb sy
    isb

     // finish
    mov  x30, x12
    b    _smc_success

     //------------------------------------------

 // this function returns data about the memory banks on this platform
 // Note: memory bank numbering is 0-based (bank 0, bank 1, etc)
 // in:  x0 = function id
 //      x1 = memory bank requested (0, 1, 2, etc)
 // out: x0 [0] =  1, valid bank
 //             =  0, invalid bank
 //       [1:2] =  1, ddr  
 //             =  2, sram
 //             =  3, special
 //         [3] =  1, not the last bank
 //             =  0, last bank
 //      x1     =  physical start address (not valid unless x0[0]=1)
 //      x2     =  size in bytes (not valid unless x0[0]=1)
 // uses x0, x1, x2, x3, x4
smc64_membank_data:
    mov   x12, x30

     // initialize the return value
    mov   x0, #MEMBANK_INVALID

 // only valid if ddr is being initialized
#if (DDR_INIT)

     // get the number of memory banks installed
    adr   x3, _membank_count_addr
    ldr   x4, [x3]
     // the value read is an address...get the data found at that address
    ldr   x2, [x4]

     // x1 = memory bank requested
     // x2 = number of membanks installed

     // validate the memory bank requested
    sub   x2, x2, #1
    cmp   x2, x1
    b.lt  5f
    b.eq  3f
     // not the last bank
    orr   x0, x0, #MEMBANK_NOT_LAST
3:
     // get the offset to this bank's structure
    mov   x2, #MEMBANK_DATA_SIZE
    mul   x3, x1, x2

     // x3 = offset

     // get the start address of the memory bank data area
    adr   x1, _membank_data_addr
    ldr   x4, [x1]

     // x3 = offset
     // x4 = base address of membank data structures

     // get the address to this bank's structure
    add   x3, x3, x4

     // x3 = start address of data structure

     // get the bank state
    ldr   w4, [x3, #MEMDATA_STATE_OFFSET]
    cmp   w4, #MEMBANK_STATE_INVALID
    b.eq  5f

     // this is a valid bank
    orr   x0, x0, #MEMBANK_VALID

     // get the bank type
    ldr   w4, [x3, #MEMDATA_TYPE_OFFSET]
    cmp   w4, #MEMBANK_TYPE_DDR
    b.ne  1f
     // memory bank is ddr
    orr   x0, x0, #MEMBANK_DDR
    b     4f
1:
    cmp   w4, #MEMBANK_TYPE_SRAM
    b.ne  2f
     // memory bank is sram
    orr   x0, x0, #MEMBANK_SRAM
    b     4f
2:
     // memory bank is special
    orr   x0, x0, #MEMBANK_SPECIAL
4:
     // get the start address
    ldr   x1, [x3, #MEMDATA_ADDR_OFFSET]
    
     // get the size
    ldr   x2, [x3, #MEMDATA_SIZE_OFFSET]
5:

    mov   x3, xzr
#endif

    b     _smc_exit

     //------------------------------------------

smc64_no_services:
    mov   x12, x30
     // w11 contains the requested function id
     // w10 contains the call count function id
    mov   w10, #0xFF00
    cmp   w10, w11
    b.ne  _smc_unimplemented
     // call count is zero
    mov   w0, #0
    b     _smc_exit

//-----------------------------------------------------------------------------

 // this function initializes any smc data
 // in:  none
 // out: none
 // uses 
_initialize_smc:

    ret

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

