// 
// ARM v8 AArch64 PSCI test code
//
// Copyright (c) 2013-2016, Freescale Semiconductor, Inc. All rights reserved.
//

//-----------------------------------------------------------------------------

  .section .text, "ax"
 
//-----------------------------------------------------------------------------

.global _test_psci

//-----------------------------------------------------------------------------

#include "soc.h"
#include "psci.h"

//-----------------------------------------------------------------------------

.equ  MPIDR_CORE_0,   0x00000000
.equ  MPIDR_CORE_1,   0x00000001
.equ  MPIDR_CORE_2,   0x00000002
.equ  MPIDR_CORE_3,   0x00000003
.equ  MPIDR_CORE_4,   0x00000100
.equ  MPIDR_CORE_5,   0x00000101
.equ  MPIDR_CORE_6,   0x00000102
.equ  MPIDR_CORE_7,   0x00000103
.equ  MPIDR_CORE_8,   0x00000200

.equ  CONTEXT_CORE_1, 0x12345678
.equ  CONTEXT_CORE_2, 0x23456781
.equ  CONTEXT_CORE_3, 0x34567812
.equ  CONTEXT_CORE_4, 0x45678123
.equ  CONTEXT_CORE_5, 0x56781234
.equ  CONTEXT_CORE_6, 0x67812345
.equ  CONTEXT_CORE_7, 0x78123456

//-----------------------------------------------------------------------------

_test_psci:
    dsb sy
    isb
    nop

    // test PSCI_CPU_ON

    //-------
    // (Core 1)     
    ldr  w1, =MPIDR_CORE_1
    adr  x2, cpu_1_pass
    ldr  w3, =CONTEXT_CORE_1
    ldr  w0, =PSCI_CPU_ON_ID
    smc  0x0
    nop
    nop
    nop
//    cmp  x0, #PSCI_SUCCESS
//    b.ne cpu_0_badreturn_01
1:
     // test AFFINITY_INFO of core 1
     // x0 = function id = 0xC4000004
     // x1 = mpidr       = 0x0001
     // x2 = level       = 0x0
    ldr  x0, =PSCI_AFFINITY_INFO_ID
    ldr  x1, =MPIDR_CORE_1
    mov  x2, #0
    smc  0x0
    nop
    nop
    nop
     // test the return value
    ldr  x1, =AFFINITY_LEVEL_ON
    cmp  x0, x1
    b.ne 1b

    //-------
    // (Core 2)
    ldr  w0, =PSCI_CPU_ON_ID
    ldr  w1, =MPIDR_CORE_2
    adr  x2, cpu_2_start
    ldr  w3, =CONTEXT_CORE_2
    smc  0x0
    nop
    nop
    nop
//    cmp  x0, #PSCI_SUCCESS
//    b.ne cpu_0_badreturn_01
2:
     // test AFFINITY_INFO of core 2
     // x0 = function id = 0xC4000004
     // x1 = mpidr       = 0x0001
     // x2 = level       = 0x0
    ldr  x0, =PSCI_AFFINITY_INFO_ID
    ldr  x1, =MPIDR_CORE_2
    mov  x2, #0
    smc  0x0
    nop
    nop
    nop
     // test the return value
    ldr  x1, =AFFINITY_LEVEL_ON
    cmp  x0, x1
    b.ne 2b

    //-------
    // (Core 3)
    ldr  w0, =PSCI_CPU_ON_ID
    ldr  w1, =MPIDR_CORE_3
    adr  x2, cpu_3_start
    ldr  w3, =CONTEXT_CORE_3
    smc  0x0
    nop
    nop
    nop
//    cmp  x0, #PSCI_SUCCESS
//    b.ne cpu_0_badreturn_01
3:
     // test AFFINITY_INFO of core 3
     // x0 = function id = 0xC4000004
     // x1 = mpidr       = 0x0001
     // x2 = level       = 0x0
    ldr  x0, =PSCI_AFFINITY_INFO_ID
    ldr  x1, =MPIDR_CORE_3
    mov  x2, #0
    smc  0x0
    nop
    nop
    nop
     // test the return value
    ldr  x1, =AFFINITY_LEVEL_ON
    cmp  x0, x1
    b.ne 3b

    //-------
    // (Core 4)
    ldr  w0, =PSCI_CPU_ON_ID
    ldr  w1, =MPIDR_CORE_4
    adr  x2, cpu_4_start
    ldr  w3, =CONTEXT_CORE_4
    smc  0x0
    nop
    nop
    nop
//    cmp  x0, #PSCI_SUCCESS
//    b.eq cpu_0_badreturn_02
4:
     // test AFFINITY_INFO of core 4
     // x0 = function id = 0xC4000004
     // x1 = mpidr       = 0x0001
     // x2 = level       = 0x0
    ldr  x0, =PSCI_AFFINITY_INFO_ID
    ldr  x1, =MPIDR_CORE_4
    mov  x2, #0
    smc  0x0
    nop
    nop
    nop
     // test the return value
    ldr  x1, =AFFINITY_LEVEL_ON
    cmp  x0, x1
    b.ne 4b

    //-------
    // (Core 7)
    ldr  w0, =PSCI_CPU_ON_ID
    ldr  w1, =MPIDR_CORE_7
    adr  x2, cpu_7_start
    ldr  w3, =CONTEXT_CORE_7
    smc  0x0
    nop
    nop
    nop
7:
     // test AFFINITY_INFO of core 7
     // x0 = function id = 0xC4000004
     // x1 = mpidr       = 0x0001
     // x2 = level       = 0x0
    ldr  x0, =PSCI_AFFINITY_INFO_ID
    ldr  x1, =MPIDR_CORE_7
    mov  x2, #0
    smc  0x0
    nop
    nop
    nop
     // test the return value
    ldr  x1, =AFFINITY_LEVEL_ON
    cmp  x0, x1
    b.ne 7b

    //-------
    // (Core 5)
    ldr  w0, =PSCI_CPU_ON_ID
    ldr  w1, =MPIDR_CORE_5
    adr  x2, cpu_5_start
    ldr  w3, =CONTEXT_CORE_5
    smc  0x0
    nop
    nop
    nop
5:
     // test AFFINITY_INFO of core 5
     // x0 = function id = 0xC4000004
     // x1 = mpidr       = 0x0001
     // x2 = level       = 0x0
    ldr  x0, =PSCI_AFFINITY_INFO_ID
    ldr  x1, =MPIDR_CORE_5
    mov  x2, #0
    smc  0x0
    nop
    nop
    nop
     // test the return value
    ldr  x1, =AFFINITY_LEVEL_ON
    cmp  x0, x1
    b.ne 5b

    //-------
    // (Core 6)
    ldr  w0, =PSCI_CPU_ON_ID
    ldr  w1, =MPIDR_CORE_6
    adr  x2, cpu_6_start
    ldr  w3, =CONTEXT_CORE_6
    smc  0x0
    nop
    nop
    nop
6:
     // test AFFINITY_INFO of core 6
     // x0 = function id = 0xC4000004
     // x1 = mpidr       = 0x0001
     // x2 = level       = 0x0
    ldr  x0, =PSCI_AFFINITY_INFO_ID
    ldr  x1, =MPIDR_CORE_6
    mov  x2, #0
    smc  0x0
    nop
    nop
    nop
     // test the return value
    ldr  x1, =AFFINITY_LEVEL_ON
    cmp  x0, x1
    b.ne 6b

cpu_0_stop:
    b  cpu_0_stop

cpu_0_badreturn_01:
    b  cpu_0_badreturn_01

cpu_0_badreturn_02:
    b  cpu_0_badreturn_02

cpu_1_pass:
    b cpu_1_pass

cpu_2_start:
    ldr  w9, =CONTEXT_CORE_2
    bl context_id_chk
cpu_2_pass:
    b cpu_2_pass

cpu_3_start:
    ldr  w9, =CONTEXT_CORE_3
    bl context_id_chk
cpu_3_pass:
    b cpu_3_pass

cpu_4_start:
    ldr  w9, =CONTEXT_CORE_4
    bl context_id_chk
cpu_4_pass:
    b cpu_4_pass

cpu_5_start:
    ldr  w9, =CONTEXT_CORE_5
    bl context_id_chk
cpu_5_pass:
    b cpu_5_pass

cpu_6_start:
    ldr  w9, =CONTEXT_CORE_6
    bl context_id_chk
cpu_6_pass:
    b cpu_6_pass

cpu_7_start:
    ldr  w9, =CONTEXT_CORE_7
    bl context_id_chk
cpu_7_pass:
    b cpu_7_pass

 // CPU_ON context id check
context_id_chk:
    cmp w0, w9
    b.ne context_chk_fail
    ret
context_chk_fail: 
     // context did not match
    b context_chk_fail


