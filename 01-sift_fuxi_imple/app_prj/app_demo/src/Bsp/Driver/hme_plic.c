/*
 * hme_plic.c
 *
 *  Created on: 2021年11月10日
 *      Author: Administrator
 */

#include "hme_plic.h"

static void PlicFinishNotice(uint16_t usIntrId);
static uint16_t PlicClaimGet(void);
static uint16_t DevIdTableGet(uint16_t usIntrId);
static void PlicErrExcute(void);

//中断注册表
static ST_PLIC_REG_PARAM astPlicReg[DEV_INTR_MAX] = {0};

//Plic Param Table
static ST_PLIC_DEV_PARAM astDevParam[DEV_INTR_MAX] = {
		{EN_DEV_ID_0,  DEF_PLIC_INT13_ID, DEF_PLIC_DEV0_PRIORITY_OFFSET,  DEF_PLIC_DEV0_IP_OFFSET,  DEF_PLIC_DEV0_IE_EN },
		{EN_DEV_ID_1,  DEF_PLIC_INT1_ID,  DEF_PLIC_DEV1_PRIORITY_OFFSET,  DEF_PLIC_DEV1_IP_OFFSET,  DEF_PLIC_DEV1_IE_EN },
		{EN_DEV_ID_2,  DEF_PLIC_INT2_ID,  DEF_PLIC_DEV2_PRIORITY_OFFSET,  DEF_PLIC_DEV2_IP_OFFSET,  DEF_PLIC_DEV2_IE_EN },
		{EN_DEV_ID_3,  DEF_PLIC_INT6_ID,  DEF_PLIC_DEV3_PRIORITY_OFFSET,  DEF_PLIC_DEV3_IP_OFFSET,  DEF_PLIC_DEV3_IE_EN },
		{EN_DEV_ID_4,  DEF_PLIC_INT7_ID,  DEF_PLIC_DEV4_PRIORITY_OFFSET,  DEF_PLIC_DEV4_IP_OFFSET,  DEF_PLIC_DEV4_IE_EN },
		{EN_DEV_ID_5,  DEF_PLIC_INT8_ID,  DEF_PLIC_DEV5_PRIORITY_OFFSET,  DEF_PLIC_DEV5_IP_OFFSET,  DEF_PLIC_DEV5_IE_EN },
		{EN_DEV_ID_6,  DEF_PLIC_INT11_ID, DEF_PLIC_DEV6_PRIORITY_OFFSET,  DEF_PLIC_DEV6_IP_OFFSET,  DEF_PLIC_DEV6_IE_EN },
		{EN_DEV_ID_7,  DEF_PLIC_INT3_ID,  DEF_PLIC_DEV7_PRIORITY_OFFSET,  DEF_PLIC_DEV7_IP_OFFSET,  DEF_PLIC_DEV7_IE_EN },
		{EN_DEV_ID_8,  DEF_PLIC_INT4_ID,  DEF_PLIC_DEV8_PRIORITY_OFFSET,  DEF_PLIC_DEV8_IP_OFFSET,  DEF_PLIC_DEV8_IE_EN },
		{EN_DEV_ID_9,  DEF_PLIC_INT5_ID,  DEF_PLIC_DEV9_PRIORITY_OFFSET,  DEF_PLIC_DEV9_IP_OFFSET,  DEF_PLIC_DEV9_IE_EN },
		{EN_DEV_ID_10, DEF_PLIC_INT12_ID, DEF_PLIC_DEV10_PRIORITY_OFFSET, DEF_PLIC_DEV10_IP_OFFSET, DEF_PLIC_DEV10_IE_EN},
		{EN_DEV_ID_11, DEF_PLIC_INT9_ID,  DEF_PLIC_DEV11_PRIORITY_OFFSET, DEF_PLIC_DEV11_IP_OFFSET, DEF_PLIC_DEV11_IE_EN},
		{EN_DEV_ID_12, DEF_PLIC_INT10_ID, DEF_PLIC_DEV12_PRIORITY_OFFSET, DEF_PLIC_DEV12_IP_OFFSET, DEF_PLIC_DEV12_IE_EN}
};

/*****************************************************************
 * @brief  PLIC中断通知获取
 * @param  无
 * @retval uint16_t：返回中断ID
 *****************************************************************/
uint16_t PlicClaimGet(void)
{
	uint16_t usClaimVal = EN_DEV_ID_0;
	usClaimVal = ReadReg32(PLIC_BASE_ADDR + DEF_PLIC_INT_CLAIM_OFFSET);
    return usClaimVal;
}

/*****************************************************************
 * @brief  PLIC中断完成通知
 * @param  usIntrId：中断ID
 * @retval 无
 *****************************************************************/
void PlicFinishNotice(uint16_t usIntrId)
{
	WriteReg32(PLIC_BASE_ADDR + DEF_PLIC_INT_FINISH_OFFSET, usIntrId);
}

/*****************************************************************
 * @brief  根据断号查找设备ID号
 * @param  usIntrId：中断ID
 * @retval uint16_t：返回设备ID
 *****************************************************************/
uint16_t DevIdTableGet(uint16_t usIntrId)
{
	uint16_t usDevId = EN_DEV_ID_MAX;
	EN_DEV_ID enIdCnt = EN_DEV_ID_0;
	for (enIdCnt = EN_DEV_ID_0; enIdCnt < EN_DEV_ID_MAX; enIdCnt = enIdCnt + 1)
	{
		if (astDevParam[enIdCnt].usIntrId == usIntrId)
		{
			usDevId = astDevParam[enIdCnt].usDevId;
			break;
		}

	}
	return usDevId;
}

/*****************************************************************
 * @brief  根据设备ID查找中断ID
 * @param  usDevId：设备ID
 * @retval uint16_t：返回中断ID
 *****************************************************************/
uint16_t DevIntrIdTableGet(uint16_t usDevId)
{
	assert_param(IS_DEV_ID(usDevId));

	return astDevParam[usDevId].usIntrId;
}

/*****************************************************************
 * @brief  根据设备ID查找优先级配置寄存器的偏移地址
 * @param  usDevId：设备ID
 * @retval uint32_t：返回优先级寄存器偏移地址
 *****************************************************************/
uint32_t DevPriorityOffsetTableGet(uint16_t usDevId)
{
	assert_param(IS_DEV_ID(usDevId));

	return astDevParam[usDevId].ulPriorityOffset;
}

/*****************************************************************
 * @brief  根据设备ID查找悬挂寄存器的偏移地址
 * @param  usDevId：设备ID
 * @retval uint32_t：返回悬挂寄存器偏移地址
 *****************************************************************/
uint32_t DevPendingOffsetTableGet(uint16_t usDevId)
{
	assert_param(IS_DEV_ID(usDevId));

	return astDevParam[usDevId].ulPendingOffset;
}

/*****************************************************************
 * @brief  根据设备ID查找中断使能配置值
 * @param  usDevId：设备ID
 * @retval uint32_t：返回使能配置值
 *****************************************************************/
uint32_t DevIntrEnTableGet(uint16_t usDevId)
{
	assert_param(IS_DEV_ID(usDevId));

	return astDevParam[usDevId].ulIntrEnable;
}

/*****************************************************************
 * @brief  根据设备ID配置中断优先级
 * @param  usDevId：设备ID， ucPriority优先级参数
 * @retval 无
 *****************************************************************/
void IntrPrioritySet(uint16_t usDevId, uint8_t ucPriority)
{
	assert_param(IS_DEV_ID(usDevId));
	assert_param(IS_PLIC_PRIORITY(ucPriority));

	uint32_t ulPriorityOffset = 0;

	ulPriorityOffset = DevPriorityOffsetTableGet(usDevId);
    WriteReg32(PLIC_BASE_ADDR + ulPriorityOffset, ucPriority);
}

/*****************************************************************
 * @brief  根据设备ID获取中断优先级
 * @param  usDevId：设备ID
 * @retval uint32_t：返回中断优先级的值
 *****************************************************************/
uint32_t IntrPriorityGet(uint16_t usDevId)
{
	assert_param(IS_DEV_ID(usDevId));

	uint32_t ulPriority = EN_PRIORITY_MAX;
	uint32_t ulPriorityOffset = 0;

	ulPriorityOffset = DevPriorityOffsetTableGet(usDevId);
	ulPriority = ReadReg32(PLIC_BASE_ADDR + ulPriorityOffset);

	return ulPriority;
}

/*****************************************************************
 * @brief  根据设备ID获取悬挂寄存器的值
 * @param  usDevId：设备ID
 * @retval uint32_t：返回中悬挂寄存器的值
 *****************************************************************/
uint32_t IntrPendingGet(uint16_t usDevId)
{
	assert_param(IS_DEV_ID(usDevId));

	uint32_t ulPending = EN_PENDING_MAX;
	uint32_t ulPendingOffset = 0;

	ulPendingOffset = DevPendingOffsetTableGet(usDevId);
	ulPending = ReadReg32(PLIC_BASE_ADDR + ulPendingOffset);

	return ulPending;
}

/*****************************************************************
 * @brief  设备PLIC的中断使能配置
 * @param  ulEnable：中断使能值
 * @retval 无
 *****************************************************************/
void PlicEnableSet(uint32_t ulEnable)
{
	uint32_t ulTemRmableVal = 0;
	ulTemRmableVal = PlicEnableGet();
	ulTemRmableVal = ulTemRmableVal | ulEnable;
	WriteReg32(PLIC_BASE_ADDR + DEF_PLIC_INT_IE_OFFSET, ulTemRmableVal);
}

/*****************************************************************
 * @brief  设备PLIC的中断使能值获取
 * @param  无
 * @retval uint32_t：返回中断使能控制参数
 *****************************************************************/
uint32_t PlicEnableGet(void)
{
	return ReadReg32(PLIC_BASE_ADDR + DEF_PLIC_INT_IE_OFFSET);
}

/*****************************************************************
 * @brief  PLIC的中断阈值设置
 * @param  ucPlicThreshold：中断阈值参数
 * @retval 无
 *****************************************************************/
void PlicThresholdSet(uint8_t ucPlicThreshold)
{
	assert_param(IS_PLIC_PRIORITY(ucPlicThreshold));

	WriteReg32(PLIC_BASE_ADDR + DEF_PLIC_INT_THRESHOLD_OFFSET, ucPlicThreshold);
}

/*****************************************************************
 * @brief  PLIC的中断阈值获取
 * @param  无
 * @retval uint8_t：返回中断阈值
 *****************************************************************/
uint8_t PlicThresholdGet(void)
{
    return ReadReg32(PLIC_BASE_ADDR + DEF_PLIC_INT_THRESHOLD_OFFSET);
}

/*****************************************************************
 * @brief  PLIC的中断注册函数
 * @param  pstRegParam：中断注册参数指针， usDevId：设备ID
 * @retval 无
 *****************************************************************/
void PlicIntrHandleRegister(PST_PLIC_REG_PARAM pstRegParam, uint16_t usDevId)
{
	assert_param(IS_DEV_ID(usDevId));
	assert_param(NULL != pstRegParam);

	astPlicReg[usDevId].usIntrId = pstRegParam->usIntrId;
	astPlicReg[usDevId].IntrHander = pstRegParam->IntrHander;
	astPlicReg[usDevId].ptrBackCall = pstRegParam->ptrBackCall;
}

/*****************************************************************
 * @brief  PLIC中断执行接口
 * @param  无
 * @retval 无
 *****************************************************************/
void ExternalInterruptExcute(void)
{
	uint16_t usIntrExcFlage = 0;
	uint16_t usIntrId = 0;
	uint16_t usRegTableIntrId = 0;
	uint16_t usIntrTableId = 0;
	uint8_t ulPriority = 0;
	uint8_t ulThresholdVal = 0;
	EN_DEV_ID enDevTableId = EN_DEV_ID_MAX;
	EN_DEV_ID enIdCnt = EN_DEV_ID_0;


	uint32_t ulMstatus = csr_read(mstatus);

	ulThresholdVal = PlicThresholdGet();
	usIntrId = PlicClaimGet();
	for (enIdCnt = EN_DEV_ID_0; enIdCnt < EN_DEV_ID_MAX;  enIdCnt = enIdCnt + 1)
	{
		usIntrTableId = astDevParam[enIdCnt].usIntrId;
		if(usIntrId == usIntrTableId)
		{
			enDevTableId = astDevParam[enIdCnt].usDevId;
			break;
		}
	}

    if (enDevTableId < EN_DEV_ID_MAX)
    {
    	ulPriority =IntrPriorityGet(enDevTableId);
    	PlicThresholdSet(ulPriority);
    	csr_write(mstatus, ulMstatus | MSTATUS_MIE);
    	usRegTableIntrId = astPlicReg[enDevTableId].usIntrId;
    }
    else
    {
    	PlicErrExcute();
    }

    if ((usRegTableIntrId == usIntrId) && ( NULL != astPlicReg[enDevTableId].IntrHander))
    {
    	astPlicReg[enDevTableId].IntrHander(astPlicReg[enDevTableId].ptrBackCall);
    	PlicFinishNotice(usIntrId);
    	PlicThresholdSet(ulThresholdVal);
    }
    else
    {
    	PlicErrExcute();
    }
}


void PlicErrExcute(void)
{
	printf("\n __PLIC Excute Err! \n");
}
