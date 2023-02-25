/*
 * hme_timer.c
 *
 *  Created on: 2021年11月23日
 *      Author: Administrator
 */

#include "hme_timer.h"


static void PlicMachineTimerHandle(void * ptrBackCall);

/*****************************************************************
 * @brief  MachineTimer结构体默认初始化
 * @param  pstTimerObj：TImer对象
 * @retval 无
*****************************************************************/
void MachineTimerObjStructDeInit(PST_TIMER_ATTR pstTimerObj)
{
	assert_param(NULL != pstTimerObj);

    pstTimerObj->usDevId = DEF_MACHINE_TIMER_ID;
    pstTimerObj->ulCurTimerL = 0;
    pstTimerObj->ulCurTimerH = 0;
    pstTimerObj->stPlicCfgParam.ucIntrEnFlage = ENABLE;
    pstTimerObj->stPlicCfgParam.ucPriority = EN_PRIORITY_1;
    pstTimerObj->ulIntrPeriod = DEF_TIMER_PERIOD;
    pstTimerObj->pstCtrller = DEV_MACH_TIMER;
}

/*****************************************************************
 * @brief  MachineTimer结构体参数初始化
 * @param  pstTimerObj：TImer对象，pstTimerParam：配置参数结构体指针
 * @retval 无
*****************************************************************/
void MachineTimerObjParamInit(PST_TIMER_ATTR pstTimerObj, PST_TIMER_ATTR pstTimerParam)
{
	assert_param(NULL != pstTimerObj);
	assert_param(NULL != pstTimerParam);
	assert_param(NULL != pstTimerParam->pstCtrller);

	pstTimerObj->usDevId = pstTimerParam->usDevId;
	pstTimerObj->ulIntrPeriod = pstTimerParam->ulIntrPeriod;
	pstTimerObj->ulCurTimerL = pstTimerParam->ulCurTimerL;
	pstTimerObj->ulCurTimerH = pstTimerParam->ulCurTimerH;
	pstTimerObj->stPlicCfgParam.ucIntrEnFlage = pstTimerParam->stPlicCfgParam.ucIntrEnFlage;
	pstTimerObj->stPlicCfgParam.ucPriority = pstTimerParam->stPlicCfgParam.ucPriority;
	pstTimerObj->pstCtrller = pstTimerParam->pstCtrller;
}

/*****************************************************************
 * @brief  MachineTimer寄存器参数初始化
 * @param  pstTimerObj：TImer对象
 * @retval 无
*****************************************************************/
void MachineTimerObjConfigInit(PST_TIMER_ATTR pstTimerObj)
{
	assert_param(NULL != pstTimerObj);
	assert_param(NULL != pstTimerObj->pstCtrller);
	assert_param(pstTimerObj->usDevId == DEF_MACHINE_TIMER_ID);

	ST_PLIC_REG_PARAM stTimerRegParam = {0};
	uint32_t ulTimerEnVal= 0;

    ulTimerEnVal = DevIntrEnTableGet(pstTimerObj->usDevId);

    stTimerRegParam.usIntrId    = DevIntrIdTableGet(pstTimerObj->usDevId);
    stTimerRegParam.IntrHander  = PlicMachineTimerHandle;
    stTimerRegParam.ptrBackCall = pstTimerObj;

    if (pstTimerObj->stPlicCfgParam.ucIntrEnFlage)
    {
    	//intr Priority set
    	IntrPrioritySet(pstTimerObj->usDevId, pstTimerObj->stPlicCfgParam.ucPriority);
        //intr handle register
    	PlicIntrHandleRegister(&stTimerRegParam, pstTimerObj->usDevId);
    	//intr handle enable
    	PlicEnableSet(ulTimerEnVal);
    }

    MachineTimerCmpAdjuct(pstTimerObj);
}


/*****************************************************************
 * @brief  MachineTimer当前计数值获取
 * @param  pstTimerObj：TImer对象
 * @retval 无
*****************************************************************/
void MachineTimerCurTimeGet(PST_TIMER_ATTR pstTimerObj)
{
	assert_param(NULL != pstTimerObj);
	assert_param(NULL != pstTimerObj->pstCtrller);

    pstTimerObj->ulCurTimerL = MachineTimerCtrllerCurTimeLGet(pstTimerObj->pstCtrller);
    pstTimerObj->ulCurTimerH = MachineTimerCtrllerCurTimeHGet(pstTimerObj->pstCtrller);
}


/*****************************************************************
 * @brief  MachineTimer比较寄存器调整
 * @param  pstTimerObj：TImer对象
 * @retval 无
*****************************************************************/
void MachineTimerCmpAdjuct(PST_TIMER_ATTR pstTimerObj)
{
	assert_param(NULL != pstTimerObj);
	assert_param(NULL != pstTimerObj->pstCtrller);

	uint32_t ulCurTimerL = 0;
	uint32_t ulCurTimerH = 0;
	uint64_t ulCurTimer = 0;

    ulCurTimerL = MachineTimerCtrllerCurTimeLGet(pstTimerObj->pstCtrller);
    ulCurTimerH = MachineTimerCtrllerCurTimeHGet(pstTimerObj->pstCtrller);
    ulCurTimer = (((uint64_t)ulCurTimerH << 32) | ulCurTimerL);
    ulCurTimer = ulCurTimer + pstTimerObj->ulIntrPeriod;
    MachineTimerCtrllerCmpSet(pstTimerObj->pstCtrller, ulCurTimer);
}

/*****************************************************************
 * @brief  MachineTimer控制器当前计数值低位获取
 * @param  ptrTimerCtrller：Timer控制器
 * @retval uint32_t：返回低位计数值
*****************************************************************/
uint32_t MachineTimerCtrllerCurTimeLGet(PST_MACH_TIME_RegDef ptrTimerCtrller)
{
	assert_param(NULL != ptrTimerCtrller);
	return ptrTimerCtrller->CUR_CNTL;
}

/*****************************************************************
 * @brief  MachineTimer控制器当前计数值高位获取
 * @param  ptrTimerCtrller：Timer控制器
 * @retval uint32_t：返回高位计数值
*****************************************************************/
uint32_t MachineTimerCtrllerCurTimeHGet(PST_MACH_TIME_RegDef ptrTimerCtrller)
{
	assert_param(NULL != ptrTimerCtrller);
	return ptrTimerCtrller->CUR_CNTH;
}

/*****************************************************************
 * @brief  MachineTimer控制器比较寄存器设置
 * @param  ptrTimerCtrller：Timer控制器， ullComVal:比较值的配置参数
 * @retval 无
*****************************************************************/
void MachineTimerCtrllerCmpSet(PST_MACH_TIME_RegDef ptrTimerCtrller, uint64_t ullComVal)
{
	assert_param(NULL != ptrTimerCtrller);
	uint32_t ulCurTimerL = ullComVal & 0xFFFFFFFF;
	uint32_t ulCurTimerH = (ullComVal >> 32) & 0xFFFFFFFF;

	ptrTimerCtrller->CMPH = ulCurTimerH;
	ptrTimerCtrller->CMPL = ulCurTimerL;
}

/*****************************************************************
 * @brief  MachineTimer控制器PLIC中断函数接口
 * @param  ptrBackCall：回调参数
 * @retval 无
*****************************************************************/
void PlicMachineTimerHandle(void * ptrBackCall)
{
	PST_TIMER_ATTR pstTimerObj = NULL;
	if (NULL != ptrBackCall)
	{
		pstTimerObj = (PST_TIMER_ATTR)ptrBackCall;
		MachineTimerCmpAdjuct(pstTimerObj);
	}
}




