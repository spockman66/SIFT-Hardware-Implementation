/*
 * hme_spi.c
 *
 *  Created on: 2021��11��11��
 *      Author: Administrator
 */
#include "hme_spi.h"

static void PlicSpiHandle(void * ptrBackCall);

/*****************************************************************
 * @brief  SPI�豸����Ĭ�ϳ�ʼ��
 * @param  pstSpiObj��SPI�豸����
 * @retval ��
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
 * @brief  ����SPI�ṹ�������ʼ���豸����
 * @param  pstSpiObj��SPI�豸���� pstSpiParam��SPI��������ָ��
 * @retval ��
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
 * @brief  SPI��������������
 * @param  pstSpiObj��SPI�豸����
 * @retval ��
*****************************************************************/
void SpiObjConfigInit(PST_SPI_ATTR pstSpiObj)
{
	assert_param(NULL != pstSpiObj);
	assert_param(NULL != pstSpiObj->pstCtrller);

	uint32_t ulSpiEnVal= 0;
	ST_PLIC_REG_PARAM stSpiRegParam = {0};

	//PLIC�ж�ʹ�ܺ�ע��
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
 * @brief  ����SPI����
 * @param  pstSpiObj��SPI�豸����
 * @retval ��
*****************************************************************/
void SpiSpconCfg(PST_SPI_ATTR pstSpiObj)
{
	assert_param(NULL != pstSpiObj);
	assert_param(NULL != pstSpiObj->pstCtrller);

	PST_SPI_RegDef pstSpiCtrller = pstSpiObj->pstCtrller;
	pstSpiCtrller->SPCON = pstSpiObj->stCfgParam.ucCtrlParam;
}

/*****************************************************************
 * @brief  SPI�������Ի�ȡ
 * @param  pstSpiObj��SPI�豸����
 * @retval uint8_t������SPI���ò���
*****************************************************************/
uint8_t SpiSpconGet(PST_SPI_ATTR pstSpiObj)
{
	assert_param(NULL != pstSpiObj);
	assert_param(NULL != pstSpiObj->pstCtrller);

	PST_SPI_RegDef pstSpiCtrller = pstSpiObj->pstCtrller;
	return pstSpiCtrller->SPCON;
}

/*****************************************************************
 * @brief  SPIʹ��
 * @param  pstSpiObj��SPI�豸����
 * @retval ��
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
 * @brief  SPI��ֹ
 * @param  pstSpiObj��SPI�豸����
 * @retval ��
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
 * @brief  SPI״̬��ȡ
 * @param  pstSpiObj��SPI�豸����
 * @retval ��
*****************************************************************/
uint8_t SpiStateGet(PST_SPI_ATTR pstSpiObj)
{
	assert_param(NULL != pstSpiObj);
	assert_param(NULL != pstSpiObj->pstCtrller);

	PST_SPI_RegDef pstSpiCtrller = pstSpiObj->pstCtrller;

	return pstSpiCtrller->SPSTA;
}

/*****************************************************************
 * @brief  SPI��վƬѡ����
 * @param  pstSpiObj��SPI�豸����
 * @retval ��
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
 * @brief  SPI��վƬѡ��ȡ
 * @param  pstSpiObj��SPI�豸����
 * @retval uint8_t������Ƭѡ����
*****************************************************************/
uint8_t SpiSlaveSclGet(PST_SPI_ATTR pstSpiObj)
{
	assert_param(NULL != pstSpiObj);
	assert_param(NULL != pstSpiObj->pstCtrller);

	PST_SPI_RegDef pstSpiCtrller = pstSpiObj->pstCtrller;

	return pstSpiCtrller->SPSSN;
}

/*****************************************************************
 * @brief  SPI��д����
 * @param  pstSpiObj��SPI�豸����
 * @retval ��
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
 * @brief  SPI �ж�ִ�нӿ�
 * @param  ptrBackCall: �ص�����
 * @retval ��
*****************************************************************/
void PlicSpiHandle(void * ptrBackCall)
{
	uint8_t ucIntrId = 0;
	PST_SPI_ATTR ptrSpiObj = NULL;
	if (NULL != ptrBackCall)
	{
		ptrSpiObj = (PST_SPI_ATTR)ptrBackCall;
		//��ȡ�ж�״̬
		//ִ���жϽӿ�
	}

	printf("PLIC Spi Interrupt...!\n");
}


















