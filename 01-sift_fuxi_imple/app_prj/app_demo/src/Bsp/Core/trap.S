.global  trap_entry
.align(2) //mtvec require 32 bits allignement
trap_entry:
  addi sp,sp, -32*4
  sw     ra,   0 * 4(sp)
  sw     t0,   4 * 4(sp)
  sw     t1,   5 * 4(sp)
  sw     t2,   6 * 4(sp)
  sw     s0,   7 * 4(sp)
  sw     s1,   8 * 4(sp)
  sw     a0,   9 * 4(sp)
  sw     a1,  10 * 4(sp)
  sw     a2,  11 * 4(sp)
  sw     a3,  12 * 4(sp)
  sw     a4,  13 * 4(sp)
  sw     a5,  14 * 4(sp)
  sw     a6,  15 * 4(sp)
  sw     a7,  16 * 4(sp)
  sw     s2,  17 * 4(sp)
  sw     s3,  18 * 4(sp)
  sw     s4,  19 * 4(sp)
  sw     s5,  20 * 4(sp)
  sw     s6,  21 * 4(sp)
  sw     s7,  22 * 4(sp)
  sw     s8,  23 * 4(sp)
  sw     s9,  24 * 4(sp)
  sw     s10, 25 * 4(sp)
  sw     s11, 26 * 4(sp)
  sw     t3,  27 * 4(sp)
  sw     t4,  28 * 4(sp)
  sw     t5,  29 * 4(sp)
  sw     t6,  30 * 4(sp)

  csrr   a0,  mcause
  csrr   a1,  mepc
  mv     a2,  sp

  call trap

  lw     ra,   0 * 4(sp)
  lw     t0,   4 * 4(sp)
  lw     t1,   5 * 4(sp)
  lw     t2,   6 * 4(sp)
  lw     s0,   7 * 4(sp)
  lw     s1,   8 * 4(sp)
  lw     a0,   9 * 4(sp)
  lw     a1,  10 * 4(sp)
  lw     a2,  11 * 4(sp)
  lw     a3,  12 * 4(sp)
  lw     a4,  13 * 4(sp)
  lw     a5,  14 * 4(sp)
  lw     a6,  15 * 4(sp)
  lw     a7,  16 * 4(sp)
  lw     s2,  17 * 4(sp)
  lw     s3,  18 * 4(sp)
  lw     s4,  19 * 4(sp)
  lw     s5,  20 * 4(sp)
  lw     s6,  21 * 4(sp)
  lw     s7,  22 * 4(sp)
  lw     s8,  23 * 4(sp)
  lw     s9,  24 * 4(sp)
  lw     s10, 25 * 4(sp)
  lw     s11, 26 * 4(sp)
  lw     t3,  27 * 4(sp)
  lw     t4,  28 * 4(sp)
  lw     t5,  29 * 4(sp)
  lw     t6,  30 * 4(sp)

  addi sp,sp, 32*4
  mret

   .weak trap
   .align(2)
trap:
 1:	j 1b
