/*
 * hme_timer.c
 *
 *  Created on: 2021��11��23��
 *      Author: Administrator
 */

#include "hme_timer.h"


static void PlicMachineTimerHandle(void * ptrBackCall);

/*****************************************************************
 * @brief  MachineTimer�ṹ��Ĭ�ϳ�ʼ��
 * @param  pstTimerObj��TImer����
 * @retval ��
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
 * @brief  MachineTimer�ṹ�������ʼ��
 * @param  pstTimerObj��TImer����pstTimerParam�����ò����ṹ��ָ��
 * @retval ��
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
 * @brief  MachineTimer�Ĵ���������ʼ��
 * @param  pstTimerObj��TImer����
 * @retval ��
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
 * @brief  MachineTimer��ǰ����ֵ��ȡ
 * @param  pstTimerObj��TImer����
 * @retval ��
*****************************************************************/
void MachineTimerCurTimeGet(PST_TIMER_ATTR pstTimerObj)
{
	assert_param(NULL != pstTimerObj);
	assert_param(NULL != pstTimerObj->pstCtrller);

    pstTimerObj->ulCurTimerL = MachineTimerCtrllerCurTimeLGet(pstTimerObj->pstCtrller);
    pstTimerObj->ulCurTimerH = MachineTimerCtrllerCurTimeHGet(pstTimerObj->pstCtrller);
}


/*****************************************************************
 * @brief  MachineTimer�ȽϼĴ�������
 * @param  pstTimerObj��TImer����
 * @retval ��
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
 * @brief  MachineTimer��������ǰ����ֵ��λ��ȡ
 * @param  ptrTimerCtrller��Timer������
 * @retval uint32_t�����ص�λ����ֵ
*****************************************************************/
uint32_t MachineTimerCtrllerCurTimeLGet(PST_MACH_TIME_RegDef ptrTimerCtrller)
{
	assert_param(NULL != ptrTimerCtrller);
	return ptrTimerCtrller->CUR_CNTL;
}

/*****************************************************************
 * @brief  MachineTimer��������ǰ����ֵ��λ��ȡ
 * @param  ptrTimerCtrller��Timer������
 * @retval uint32_t�����ظ�λ����ֵ
*****************************************************************/
uint32_t MachineTimerCtrllerCurTimeHGet(PST_MACH_TIME_RegDef ptrTimerCtrller)
{
	assert_param(NULL != ptrTimerCtrller);
	return ptrTimerCtrller->CUR_CNTH;
}

/*****************************************************************
 * @brief  MachineTimer�������ȽϼĴ�������
 * @param  ptrTimerCtrller��Timer�������� ullComVal:�Ƚ�ֵ�����ò���
 * @retval ��
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
 * @brief  MachineTimer������PLIC�жϺ����ӿ�
 * @param  ptrBackCall���ص�����
 * @retval ��
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




