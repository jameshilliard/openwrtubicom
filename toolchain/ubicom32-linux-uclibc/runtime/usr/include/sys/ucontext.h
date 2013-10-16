/* Copyright (C) 1998, 1999 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
   02111-1307 USA.  */

#ifndef _SYS_UCONTEXT_H
#define _SYS_UCONTEXT_H	1

#include <features.h>
#include <signal.h>
/*
 * Location of the users' stored registers relative to D0.
 * Usage is as an index into a gregset_t array or as u.u_ar0[XX].
 */
#define REG_D0           0
#define REG_D1           1
#define REG_D2           2
#define REG_D3           3
#define REG_D4           4
#define REG_D5           5
#define REG_D6           6
#define REG_D7           7
#define REG_D8           8
#define REG_D9           9
#define REG_D10          10
#define REG_D11          11
#define REG_D12          12
#define REG_D13          13
#define REG_D14          14
#define REG_D15          15
#define REG_A0           16
#define REG_A1           17
#define REG_A2           18
#define REG_A3           19
#define REG_A4           20
#define REG_A5           21
#define REG_A6           22
#define REG_A7           23
#define REG_SP           REG_A7
#define REG_ACC0HI       24
#define REG_ACC0LO       25
#define REG_MAC_RC16     26
#define REG_ACC1HI       27
#define REG_ACC1LO       28
#define REG_SOURCE3      29
#define REG_INST_CNT     30
#define REG_CSR          31
#define REG_DUMMY_UNUSED 32
#define REG_INT_MASK0    33
#define REG_INT_MASK1    34
#define REG_TRAP_CAUSE   35
#define REG_PC           36
#define REG_ORIGINAL_D0  37
#define REG_FRAME_TYPE   38
#define REG_PREVIOUS_PC  39 /* only usefull for debug */
#define REG_NESTING_LEVEL 40
#define REG_THREAD_TYPE  41

/*
 * A gregset_t is defined as an array type for compatibility with the reference
 * source. This is important due to differences in the way the C language
 * treats arrays and structures as parameters.
 *
 * Note that NGREG is really (sizeof (struct pt_regs) / sizeof (greg_t))
 */

#define NGREG   42
typedef int greg_t;

typedef greg_t  gregset_t[NGREG];

typedef struct
  {
    gregset_t   gregs;		/* general register set */
  } mcontext_t;


/* Userlevel context.  */
typedef struct ucontext
  {
    unsigned long   uc_flags;
    struct ucontext *uc_link;
    stack_t         uc_stack;
    mcontext_t      uc_mcontext;
    __sigset_t	    uc_sigmask;
  } ucontext_t;

#endif /* sys/ucontext.h */
