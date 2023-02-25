/*
 * trap.c
 *
 *  Created on: 2021��11��15��
 *      Author: Administrator
 */

#include "trap_handle.h"
#include "stdio.h"

//mepc ��ջ
#define PUSH_MEPC                                       \
(                                                       \
	{                                                   \
	    __asm__ __volatile__ (                          \
		     "csrr   a0,  mepc;"                        \
			 "sw     a0,  1*4(sp);"                     \
        );                                              \
	}                                                   \
)

//mepc ��ջ
#define POP_MEPC                                        \
(                                                       \
	{                                                   \
	    __asm__ __volatile__ (                          \
	        "lw     a0,   1*4(sp);"                     \
			"csrw   mepc, x10;"                         \
        );                                              \
	}                                                   \
)


/*****************************************************************
 * @brief  ����ж�ִ�нӿ�
 * @param  ��
 * @retval ��
*****************************************************************/
void SoftwareInterruptExcute(uint32_t sp[])
{
	extern void Software_IRQHandler();

	uint32_t* pulSoftAddr = (uint32_t*)SOFT_INTR_BASE_ADDR;
	*pulSoftAddr = 0;

     printf("Software Interrput....\n");
}

/*****************************************************************
 * @brief  �˶�ʱ���ж�ִ�нӿ�
 * @param  ��
 * @retval ��
*****************************************************************/
void TimerInterruptExcute()
{
	PST_MACH_TIME_RegDef pstMachTimer = DEV_MACH_TIMER;

	uint32_t ulCurTimerL = 0;
	uint32_t ulCurTimerH = 0;
	uint64_t ulCurTimer = 0;

    ulCurTimerL = MachineTimerCtrllerCurTimeLGet(pstMachTimer);
    ulCurTimerH = MachineTimerCtrllerCurTimeHGet(pstMachTimer);
    ulCurTimer = (((uint64_t)ulCurTimerH << 32) | ulCurTimerL);
    ulCurTimer = ulCurTimer + DEF_TIMER_PERIOD;
    MachineTimerCtrllerCmpSet(pstMachTimer, ulCurTimer);
}

/*****************************************************************
 * @brief  �쳣����ʱִ�нӿ�
 * @param  ��
 * @retval ��
*****************************************************************/
void ExceptionHandleExcute()
{
	printf ("/n __Exception Occured: Fatal Fault!/n");
	while (1);
}

/*****************************************************************
 * @brief  ϵͳ�жϳ�ʼ��
 * @param  ��
 * @retval ��
*****************************************************************/
void TrapInit()
{
    csr_set(mie, MIE_MEIE | MIE_MSIE);             //Enable machine timer and external interrupts
    csr_write(mstatus, MSTATUS_MPP | MSTATUS_MIE);
}

/*****************************************************************
 * @brief  ϵͳ�쳣���Ƚӿ�
 * @param  ��
 * @retval ��
*****************************************************************/
void trap(int32_t mcause, uint32_t mepc, uint32_t sp[])
{
	int32_t interrupt = mcause < 0;               //Interrupt if true, exception if false
	int32_t cause     = mcause & 0xF;


    if (interrupt)
    {
        switch(cause)
        {
            case CASE_MACHINE_SOFT:
            {
            	sp[31] = mepc;
            	SoftwareInterruptExcute(sp);
            	break;
            }
            case CAUSE_MACHINE_TIMER:
            {
            	TimerInterruptExcute();
            	break;
            }
            case CAUSE_MACHINE_EXTERNAL:
            {
            	csr_set(mie, MIE_MEIE);
            	PUSH_MEPC;
            	ExternalInterruptExcute();
            	POP_MEPC;
            	csr_set(mie, MIE_MEIE | MIE_MSIE);
            	break;
            }
            default:
            {
            	ExceptionHandleExcute();
            	break;
            }
        }
    }
    else
    {
    	ExceptionHandleExcute();
    }
}

