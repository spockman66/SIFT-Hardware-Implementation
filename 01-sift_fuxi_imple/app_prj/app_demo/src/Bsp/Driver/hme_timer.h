/*
 * hme_timer.h
 *
 *  Created on: 2021年11月23日
 *      Author: Administrator
 */

#ifndef _HME_TIMER_H_
#define _HME_TIMER_H_

#ifdef __cplusplus
extern "C" {
#endif

#include "stdio.h"
#include "hme_riscv.h"
#include "hme_plic.h"

#define DEF_MACHINE_TIMER_ID           DEV0_INTR_NUM

#define DEF_PERIOD_MS                  (500)
#define DEF_TIMER_PERIOD               (DEF_PERIOD_MS * 1000 * 1000 / CLK_CYC)

//定时器参数结构体
typedef struct {
	uint16_t  usDevId;
	uint32_t  ulIntrPeriod;      //intr period
	uint32_t  ulCurTimerL;
	uint32_t  ulCurTimerH;
	ST_PLIC_CFG_PARAM stPlicCfgParam;
	PST_MACH_TIME_RegDef pstCtrller;
}ST_TIMER_ATTR, *PST_TIMER_ATTR;


void MachineTimerObjStructDeInit(PST_TIMER_ATTR pstTimerObj);
void MachineTimerObjParamInit(PST_TIMER_ATTR pstTimerObj, PST_TIMER_ATTR pstTimerParam);
void MachineTimerObjConfigInit(PST_TIMER_ATTR pstTimerObj);
void MachineTimerCurTimeGet(PST_TIMER_ATTR pstTimerObj);
void MachineTimerCmpAdjuct(PST_TIMER_ATTR pstTimerObj);
void MachineTimerCoreIntrHandle(void);

uint32_t MachineTimerCtrllerCurTimeLGet(PST_MACH_TIME_RegDef ptrTimerCtrller);
uint32_t MachineTimerCtrllerCurTimeHGet(PST_MACH_TIME_RegDef ptrTimerCtrller);
void MachineTimerCtrllerCmpSet(PST_MACH_TIME_RegDef ptrTimerCtrller, uint64_t ullComVal);

#ifdef __cplusplus
}
#endif

#endif /* _HME_TIMER_H_ */
