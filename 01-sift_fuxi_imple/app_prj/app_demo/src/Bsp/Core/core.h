/*
 * core.h
 *
 *  Created on: 2021Äê11ÔÂ23ÈÕ
 *      Author: Administrator
 */

#ifndef _CORE_H_
#define _CORE_H_

#ifdef __cplusplus
extern "C" {
#endif

//exceptions
#define CASE_MACHINE_SOFT        3
#define CAUSE_MACHINE_TIMER      7
#define CAUSE_MACHINE_EXTERNAL   11

#define MIE_USIE            0x00000001
#define MIE_SSIE            0x00000002
#define MIE_HSIE            0x00000004
#define MIE_MSIE            0x00000008
#define MIE_UTIE            0x00000010
#define MIE_STIE            0x00000020
#define MIE_HTIE            0x00000040
#define MIE_MTIE            0x00000080
#define MIE_UEIE            0x00000100
#define MIE_SEIE            0x00000200
#define MIE_HEIE            0x00000400
#define MIE_MEIE            0x00000800

#define MSTATUS_UIE         0x00000001
#define MSTATUS_SIE         0x00000002
#define MSTATUS_HIE         0x00000004
#define MSTATUS_MIE         0x00000008
#define MSTATUS_UPIE        0x00000010
#define MSTATUS_SPIE        0x00000020
#define MSTATUS_HPIE        0x00000040
#define MSTATUS_MPIE        0x00000080
#define MSTATUS_SPP         0x00000100
#define MSTATUS_HPP         0x00000600
#define MSTATUS_MPP         0x00001800
#define MSTATUS_FS          0x00006000
#define MSTATUS_XS          0x00018000
#define MSTATUS_MPRV        0x00020000
#define MSTATUS_SUM         0x00040000
#define MSTATUS_MXR         0x00080000
#define MSTATUS_TVM         0x00100000
#define MSTATUS_TW          0x00200000
#define MSTATUS_TSR         0x00400000
#define MSTATUS32_SD        0x80000000


#define csr_swap(csr, val)                               \
(                                                        \
    {                                                    \
        unsigned long __v = (unsigned long)(val);        \
        __asm__ __volatile__ ("csrrw %0, " #csr ", %1"   \
                  : "=r" (__v) : "rK" (__v));            \
        __v;                                             \
    }                                                    \
)

#define csr_read(csr)                                    \
(                                                        \
    {                                                    \
        register unsigned long __v;                      \
        __asm__ __volatile__ ("csrr %0, " #csr           \
                      : "=r" (__v));                     \
        __v;                                             \
    }                                                    \
)

#define csr_write(csr, val)                              \
(                                                        \
    {                                                    \
        unsigned long __v = (unsigned long)(val);        \
        __asm__ __volatile__ ("csrw " #csr ", %0"        \
                   : : "rK" (__v));                      \
    }                                                    \
)

#define csr_read_set(csr, val)                           \
(                                                        \
    {                                                    \
        unsigned long __v = (unsigned long)(val);        \
        __asm__ __volatile__ ("csrrs %0, " #csr ", %1"   \
                  : "=r" (__v) : "rK" (__v));            \
        __v;                                             \
    }                                                    \
)

#define csr_set(csr, val)                                \
(                                                        \
	{                                                    \
        unsigned long __v = (unsigned long)(val);        \
        __asm__ __volatile__ ("csrs " #csr ", %0"        \
                  : : "rK" (__v));                       \
    }                                                    \
)

#define csr_read_clear(csr, val)                         \
(                                                        \
	{                                                    \
        unsigned long __v = (unsigned long)(val);        \
        __asm__ __volatile__ ("csrrc %0, " #csr ", %1"   \
                  : "=r" (__v) : "rK" (__v));            \
        __v;                                             \
    }                                                    \
)

#define csr_clear(csr, val)                              \
(                                                        \
	{                                                    \
        unsigned long __v = (unsigned long)(val);        \
        __asm__ __volatile__ ("csrc " #csr ", %0"        \
                  : : "rK" (__v));                       \
    }                                                    \
)


#ifdef __cplusplus
}
#endif

#endif /* _CORE_H_ */
