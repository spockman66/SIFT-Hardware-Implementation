/*
 * hme_spi.c
 *
 *  Created on: 2021年11月11日
 *      Author: Administrator
 */
#include "hme_spi.h"

static void PlicSpiHandle(void * ptrBackCall);

/*****************************************************************
 * @brief  SPI设备对象默认初始化
 * @param  pstSpiObj：SPI设备对象
 * @retval 无
*****************************************************************/
void SpiStructDeInit(PST_SPI_ATTR pstSpiObj)
{
	assert_param(NULL != pstSpiObj);

	pstSpiObj->usDevId = DEF_SPI0_DEV_ID;
	pstSpiObj->pucSendBuf = NULL;
	pstSpiObj->pucRecvBuf = NULL;
	pstSpiObj->ulTranBytesSize = 0;
	pstSpiObj->ulTranBytesCnt = 0;
	pstSpiObj->stCfgParam.ucCtrlParam = SPI_SPCON_DEFAULT;
	pstSpiObj->stCfgParam.ucSlaveScl = SPI_SLAVE_SCL_ALL;
	pstSpiObj->stCfgParam.ucSsnPolarity = EN_POLARITY_TYPE_HIGH;
	pstSpiObj->stPlicCfgParam.ucIntrEnFlage = DISABLE;
	pstSpiObj->stPlicCfgParam.ucPriority = EN_PRIORITY_2;
	pstSpiObj->pstCtrller = DEV_SPI0;
}

/*****************************************************************
 * @brief  根据SPI结构体参数初始化设备对象
 * @param  pstSpiObj：SPI设备对象， pstSpiParam：SPI参数配置指针
 * @retval 无
*****************************************************************/
void SpiObjParamInit(PST_SPI_ATTR pstSpiObj, PST_SPI_ATTR pstSpiParam)
{
	assert_param(NULL != pstSpiObj);
	assert_param(NULL != pstSpiParam);
	assert_param(NULL != pstSpiParam->pstCtrller);

	pstSpiObj->usDevId = pstSpiParam->usDevId;
	pstSpiObj->pucSendBuf = pstSpiParam->pucSendBuf;
	pstSpiObj->pucRecvBuf = pstSpiParam->pucRecvBuf;
	pstSpiObj->ulTranBytesSize = pstSpiParam->ulTranBytesSize;
	pstSpiObj->ulTranBytesCnt = pstSpiParam->ulTranBytesCnt;
	pstSpiObj->stCfgParam.ucCtrlParam = pstSpiParam->stCfgParam.ucCtrlParam;
	pstSpiObj->stCfgParam.ucSlaveScl = pstSpiParam->stCfgParam.ucSlaveScl;
	pstSpiObj->stCfgParam.ucSsnPolarity = pstSpiParam->stCfgParam.ucSsnPolarity;
	pstSpiObj->stPlicCfgParam.ucIntrEnFlage = pstSpiParam->stPlicCfgParam.ucIntrEnFlage;
	pstSpiObj->stPlicCfgParam.ucPriority = pstSpiParam->stPlicCfgParam.ucPriority;
	pstSpiObj->pstCtrller = pstSpiParam->pstCtrller;
}

/*****************************************************************
 * @brief  SPI控制器参数配置
 * @param  pstSpiObj：SPI设备对象
 * @retval 无
*****************************************************************/
void SpiObjConfigInit(PST_SPI_ATTR pstSpiObj)
{
	assert_param(NULL != pstSpiObj);
	assert_param(NULL != pstSpiObj->pstCtrller);

	uint32_t ulSpiEnVal= 0;
	ST_PLIC_REG_PARAM stSpiRegParam = {0};

	//PLIC中断使能和注册
	ulSpiEnVal = DevIntrEnTableGet(pstSpiObj->usDevId);
	stSpiRegParam.usIntrId = DevIntrIdTableGet(pstSpiObj->usDevId);
	stSpiRegParam.IntrHander = PlicSpiHandle;
	stSpiRegParam.ptrBackCall = pstSpiObj;
	if (pstSpiObj->stPlicCfgParam.ucIntrEnFlage)
	{
		//intr Priority set
		IntrPrioritySet(pstSpiObj->usDevId, pstSpiObj->stPlicCfgParam.ucPriority);
        //intr handle register
		PlicIntrHandleRegister(&stSpiRegParam, pstSpiObj->usDevId);
		//intr handle enable
		PlicEnableSet(ulSpiEnVal);
	}

	SpiSpconCfg(pstSpiObj);
	SpiSlaveCfg(pstSpiObj);
	SpiEnable(pstSpiObj);
}

/*****************************************************************
 * @brief  配置SPI属性
 * @param  pstSpiObj：SPI设备对象
 * @retval 无
*****************************************************************/
void SpiSpconCfg(PST_SPI_ATTR pstSpiObj)
{
	assert_param(NULL != pstSpiObj);
	assert_param(NULL != pstSpiObj->pstCtrller);

	PST_SPI_RegDef pstSpiCtrller = pstSpiObj->pstCtrller;
	pstSpiCtrller->SPCON = pstSpiObj->stCfgParam.ucCtrlParam;
}

/*****************************************************************
 * @brief  SPI配置属性获取
 * @param  pstSpiObj：SPI设备对象
 * @retval uint8_t：返回SPI配置参数
*****************************************************************/
uint8_t SpiSpconGet(PST_SPI_ATTR pstSpiObj)
{
	assert_param(NULL != pstSpiObj);
	assert_param(NULL != pstSpiObj->pstCtrller);

	PST_SPI_RegDef pstSpiCtrller = pstSpiObj->pstCtrller;
	return pstSpiCtrller->SPCON;
}

/*****************************************************************
 * @brief  SPI使能
 * @param  pstSpiObj：SPI设备对象
 * @retval 无
*****************************************************************/
void SpiEnable(PST_SPI_ATTR pstSpiObj)
{
	assert_param(NULL != pstSpiObj);
	assert_param(NULL != pstSpiObj->pstCtrller);

	uint8_t ucSpconParam = 0;
	PST_SPI_RegDef pstSpiCtrller = pstSpiObj->pstCtrller;

	ucSpconParam = SpiSpconGet(pstSpiObj);
	ucSpconParam = ucSpconParam | SPI_SPCON_SPEN;
	pstSpiCtrller->SPCON = ucSpconParam;
}

/*****************************************************************
 * @brief  SPI禁止
 * @param  pstSpiObj：SPI设备对象
 * @retval 无
*****************************************************************/
void SpiDisable(PST_SPI_ATTR pstSpiObj)
{
	assert_param(NULL != pstSpiObj);
	assert_param(NULL != pstSpiObj->pstCtrller);

	uint8_t ucSpconParam = 0;
	PST_SPI_RegDef pstSpiCtrller = pstSpiObj->pstCtrller;

	ucSpconParam = SpiSpconGet(pstSpiObj);
	ucSpconParam = ucSpconParam & (~SPI_SPCON_SPEN);
	pstSpiCtrller->SPCON = ucSpconParam;
}

/*****************************************************************
 * @brief  SPI状态获取
 * @param  pstSpiObj：SPI设备对象
 * @retval 无
*****************************************************************/
uint8_t SpiStateGet(PST_SPI_ATTR pstSpiObj)
{
	assert_param(NULL != pstSpiObj);
	assert_param(NULL != pstSpiObj->pstCtrller);

	PST_SPI_RegDef pstSpiCtrller = pstSpiObj->pstCtrller;

	return pstSpiCtrller->SPSTA;
}

/*****************************************************************
 * @brief  SPI从站片选配置
 * @param  pstSpiObj：SPI设备对象
 * @retval 无
*****************************************************************/
void SpiSlaveCfg(PST_SPI_ATTR pstSpiObj)
{
	assert_param(NULL != pstSpiObj);
	assert_param(NULL != pstSpiObj->pstCtrller);


	uint8_t ucSsnPolarity= pstSpiObj->stCfgParam.ucSsnPolarity;
	PST_SPI_RegDef pstSpiCtrller = pstSpiObj->pstCtrller;
	uint8_t ucSpssnVal = pstSpiCtrller->SPSSN;

	assert_param(ucSsnPolarity < EN_POLARITY_TYPE_MAX);

    if (ucSsnPolarity == EN_POLARITY_TYPE_HIGH)
    {
    	pstSpiCtrller->SPSSN = ucSpssnVal | pstSpiObj->stCfgParam.ucSlaveScl;
    }
    else
    {
    	pstSpiCtrller->SPSSN = ucSpssnVal & (~(pstSpiObj->stCfgParam.ucSlaveScl));
    }
}

/*****************************************************************
 * @brief  SPI从站片选获取
 * @param  pstSpiObj：SPI设备对象
 * @retval uint8_t：返回片选参数
*****************************************************************/
uint8_t SpiSlaveSclGet(PST_SPI_ATTR pstSpiObj)
{
	assert_param(NULL != pstSpiObj);
	assert_param(NULL != pstSpiObj->pstCtrller);

	PST_SPI_RegDef pstSpiCtrller = pstSpiObj->pstCtrller;

	return pstSpiCtrller->SPSSN;
}

/*****************************************************************
 * @brief  SPI读写操作
 * @param  pstSpiObj：SPI设备对象
 * @retval 无
*****************************************************************/
void SpiHanderRequest(PST_SPI_ATTR pstSpiObj)
{
	assert_param(NULL != pstSpiObj);
	assert_param(NULL != pstSpiObj->pstCtrller);
	assert_param(NULL != pstSpiObj->pucSendBuf);
	assert_param(NULL != pstSpiObj->pucRecvBuf);

	uint8_t ucSsnPolarity= pstSpiObj->stCfgParam.ucSsnPolarity;

	assert_param(ucSsnPolarity < EN_POLARITY_TYPE_MAX);

    uint8_t  ucSpiState = 0;
    uint32_t ulTranBytesCnt = 0;
    uint8_t* pucSendBuf = pstSpiObj->pucSendBuf;
    uint8_t* pucRecvBuf = pstSpiObj->pucRecvBuf;
	PST_SPI_RegDef pstSpiCtrller = pstSpiObj->pstCtrller;
    uint32_t ulTranBytesSize = pstSpiObj->ulTranBytesSize;

    pstSpiObj->stCfgParam.ucSsnPolarity = EN_POLARITY_TYPE_LOW;
    SpiSlaveCfg(pstSpiObj);

    while (ulTranBytesCnt < ulTranBytesSize)
    {
    	pstSpiCtrller->SPDAT = *pucSendBuf;
    	while (1)
    	{
    		ucSpiState = SpiStateGet(pstSpiObj);
    		if ((ucSpiState & SPI_SPSTA_SPIF) == SPI_SPSTA_SPIF)
    		{
    			*pucRecvBuf = pstSpiCtrller->SPDAT;
    			break;
    		}
    	}

    	ulTranBytesCnt++;
    	pucSendBuf++;
    	pucRecvBuf++;
    }

    pstSpiObj->stCfgParam.ucSsnPolarity = EN_POLARITY_TYPE_HIGH;
    SpiSlaveCfg(pstSpiObj);
}


/*****************************************************************
 * @brief  SPI 中断执行接口
 * @param  ptrBackCall: 回调函数
 * @retval 无
*****************************************************************/
void PlicSpiHandle(void * ptrBackCall)
{
	uint8_t ucIntrId = 0;
	PST_SPI_ATTR ptrSpiObj = NULL;
	if (NULL != ptrBackCall)
	{
		ptrSpiObj = (PST_SPI_ATTR)ptrBackCall;
		//读取中断状态
		//执行中断接口
	}

	printf("PLIC Spi Interrupt...!\n");
}


















