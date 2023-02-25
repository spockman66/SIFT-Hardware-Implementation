/*
 * hme_iic.c
 *
 *  Created on: 2021��12��3��
 *      Author: Administrator
 */


#include "hme_iic.h"

#define OAR_ADD_Set           ((uint16_t)0x0001)
#define OAR_ADD_Reset         ((uint16_t)0xFFFE)

static void PlicI2cHandle(void * ptrBackCall);

/*****************************************************************
 * @brief  I2C�ṹ��Ĭ�ϳ�ʼ��
 * @param  pstI2cObj: I2c�豸����
 * @retval ��
*****************************************************************/
void I2cStructDeInit(PST_I2C_ATTR pstI2cObj)
{
	assert_param(NULL != pstI2cObj);

	pstI2cObj->usDevId = DEF_I2C0_DEV_ID;
	pstI2cObj->stCfgParam.ucClkDiv = I2C_SCL_CLK_DIV_224;
	pstI2cObj->stCfgParam.ucSelfAddr = 0;
	pstI2cObj->stCfgParam.ucMode = EN_I2C_MODE_MASTER;
	pstI2cObj->stPlicCfgParam.ucIntrEnFlage = DISABLE;
	pstI2cObj->stPlicCfgParam.ucPriority = EN_PRIORITY_2;
	pstI2cObj->pstCtrller = DEV_I2C0;
}

/*****************************************************************
 * @brief  I2C�ṹ���ʼ��
 * @param  pstI2cObj: I2c�豸����pstI2cParam:��ʼ������ָ��
 * @retval ��
*****************************************************************/
void I2cObjParamInit(PST_I2C_ATTR pstI2cObj, PST_I2C_ATTR pstI2cParam)
{
	assert_param(NULL != pstI2cObj);
	assert_param(NULL != pstI2cParam);
	assert_param(NULL != pstI2cParam->pstCtrller);

	pstI2cObj->usDevId = pstI2cParam->usDevId;
	pstI2cObj->stCfgParam.ucClkDiv = pstI2cParam->stCfgParam.ucClkDiv;
	pstI2cObj->stCfgParam.ucSelfAddr = pstI2cParam->stCfgParam.ucSelfAddr;
	pstI2cObj->stCfgParam.ucMode = pstI2cParam->stCfgParam.ucMode;
	pstI2cObj->stPlicCfgParam.ucIntrEnFlage = pstI2cParam->stPlicCfgParam.ucIntrEnFlage;
	pstI2cObj->stPlicCfgParam.ucPriority = pstI2cParam->stPlicCfgParam.ucPriority;
	pstI2cObj->pstCtrller = pstI2cParam->pstCtrller;
}

/*****************************************************************
 * @brief  I2C�豸��ʼ����������д���Ӧ�Ĵ���
 * @param  pstI2cObj: I2c�豸����
 * @retval ��
*****************************************************************/
void I2cObjConfigInit(PST_I2C_ATTR pstI2cObj)
{
	assert_param(NULL != pstI2cObj);
	assert_param(NULL != pstI2cObj->pstCtrller);

	uint32_t ulI2cEnVal= 0;
	ST_PLIC_REG_PARAM stI2cRegParam = {0};

	uint8_t ucCfgParam = 0;
	uint8_t ucI2cMode = pstI2cObj->stCfgParam.ucMode;

	uint8_t ucDivParam = pstI2cObj->stCfgParam.ucClkDiv;

	assert_param(IS_SCL_DIV(ucDivParam));
	assert_param(ucI2cMode < EN_I2C_MODE_MAX);

	//PLIC�ж�ʹ�ܺ�ע��
	ulI2cEnVal = DevIntrEnTableGet(pstI2cObj->usDevId);
	stI2cRegParam.usIntrId = DevIntrIdTableGet(pstI2cObj->usDevId);
	stI2cRegParam.IntrHander = PlicI2cHandle;
	stI2cRegParam.ptrBackCall = pstI2cObj;
	if (pstI2cObj->stPlicCfgParam.ucIntrEnFlage)
	{
		//intr Priority set
		IntrPrioritySet(pstI2cObj->usDevId, pstI2cObj->stPlicCfgParam.ucPriority);
        //intr handle register
		PlicIntrHandleRegister(&stI2cRegParam, pstI2cObj->usDevId);
		//intr handle enable
		PlicEnableSet(ulI2cEnVal);
	}

	pstI2cObj->pstCtrller->I2CADR = pstI2cObj->stCfgParam.ucSelfAddr;
	if (ucI2cMode == EN_I2C_MODE_MASTER)
	{
		ucCfgParam = I2C_CON_MAST_CFG_MASK & (pstI2cObj->stCfgParam.ucClkDiv);
	}
	else
	{
		ucCfgParam = (I2C_CON_MAST_CFG_MASK & (pstI2cObj->stCfgParam.ucClkDiv)) | I2C_CON_REG_AA;
	}

	I2cSpconCfg(pstI2cObj, ucCfgParam);
	I2cEnable(pstI2cObj);
}

/*****************************************************************
 * @brief  I2C���Ʋ�������
 * @param  pstI2cObj: I2c�豸���� ucCfgParam�����ò���
 * @retval ��
*****************************************************************/
void I2cSpconCfg(PST_I2C_ATTR pstI2cObj, uint8_t ucCfgParam)
{
	assert_param(NULL != pstI2cObj);
	assert_param(NULL != pstI2cObj->pstCtrller);

	PST_I2C_RegDef pstI2cCtrller = pstI2cObj->pstCtrller;
	pstI2cCtrller->I2CCON = ucCfgParam;
}

/*****************************************************************
 * @brief  I2Cʱ�ӷ�Ƶ����
 * @param  pstI2cObj: I2c�豸����
 * @retval ��
*****************************************************************/
void I2cDivCfg(PST_I2C_ATTR pstI2cObj)
{
	assert_param(NULL != pstI2cObj);
	assert_param(NULL != pstI2cObj->pstCtrller);

	PST_I2C_RegDef pstI2cCtrller = pstI2cObj->pstCtrller;
	uint8_t ucConParam = pstI2cCtrller->I2CCON;
	pstI2cCtrller->I2CCON = ucConParam | pstI2cObj->stCfgParam.ucClkDiv;
}

/*****************************************************************
 * @brief  ��ȡI2C�����ò���
 * @param  pstI2cObj: I2c�豸����
 * @retval ��
*****************************************************************/
uint8_t I2cSpconGet(PST_I2C_ATTR pstI2cObj)
{
	assert_param(NULL != pstI2cObj);
	assert_param(NULL != pstI2cObj->pstCtrller);

	PST_I2C_RegDef pstI2cCtrller = pstI2cObj->pstCtrller;
	return pstI2cCtrller->I2CCON;
}

/*****************************************************************
 * @brief  I2C�豸ʹ��
 * @param  pstI2cObj: I2c�豸����
 * @retval ��
*****************************************************************/
void I2cEnable(PST_I2C_ATTR pstI2cObj)
{
	assert_param(NULL != pstI2cObj);
	assert_param(NULL != pstI2cObj->pstCtrller);

	PST_I2C_RegDef pstI2cCtrller = pstI2cObj->pstCtrller;
	uint8_t ucConParam = pstI2cCtrller->I2CCON;
	pstI2cCtrller->I2CCON = ucConParam | I2C_CON_REG_ENS1;
}

/*****************************************************************
 * @brief  I2C�豸��ֹ
 * @param  pstI2cObj: I2c�豸����
 * @retval ��
*****************************************************************/
void I2cDisable(PST_I2C_ATTR pstI2cObj)
{
	assert_param(NULL != pstI2cObj);
	assert_param(NULL != pstI2cObj->pstCtrller);

	PST_I2C_RegDef pstI2cCtrller = pstI2cObj->pstCtrller;
	uint8_t ucConParam = pstI2cCtrller->I2CCON;
	pstI2cCtrller->I2CCON = ucConParam & (~I2C_CON_REG_ENS1);
}

/*****************************************************************
 * @brief  I2C״̬���ȡ
 * @param  pstI2cObj: I2c�豸����
 * @retval ��
*****************************************************************/
uint8_t I2cStateCodeGet(PST_I2C_ATTR pstI2cObj)
{
	assert_param(NULL != pstI2cObj);
	assert_param(NULL != pstI2cObj->pstCtrller);

	PST_I2C_RegDef pstI2cCtrller = pstI2cObj->pstCtrller;
	return pstI2cCtrller->I2CSTA;
}

/*****************************************************************
 * @brief  I2C��Ϊ��վʱ���豸��ַ����
 * @param  pstI2cObj: I2c�豸����
 * @retval ��
*****************************************************************/
void I2cOwnAddressCfg(PST_I2C_ATTR pstI2cObj)
{
	assert_param(NULL != pstI2cObj);
	assert_param(NULL != pstI2cObj->pstCtrller);

	PST_I2C_RegDef pstI2cCtrller = pstI2cObj->pstCtrller;
	pstI2cCtrller->I2CADR = pstI2cObj->stCfgParam.ucSelfAddr;
}

/*****************************************************************
 * @brief  I2C������豸��ַ��ȡ
 * @param  pstI2cObj: I2c�豸����
 * @retval ��
*****************************************************************/
uint8_t I2cOwnAddressGet(PST_I2C_ATTR pstI2cObj)
{
	assert_param(NULL != pstI2cObj);
	assert_param(NULL != pstI2cObj->pstCtrller);

	PST_I2C_RegDef pstI2cCtrller = pstI2cObj->pstCtrller;
	return pstI2cCtrller->I2CADR;
}

/*****************************************************************
 * @brief  I2C��ʼλ����
 * @param  pstI2cObj: I2c�豸����
 * @retval ��
*****************************************************************/
void I2cGenerateStart(PST_I2C_ATTR pstI2cObj)
{
	assert_param(NULL != pstI2cObj);
	assert_param(NULL != pstI2cObj->pstCtrller);

	PST_I2C_RegDef pstI2cCtrller = pstI2cObj->pstCtrller;
	uint8_t ucConParam = pstI2cCtrller->I2CCON;
	pstI2cCtrller->I2CCON = ucConParam | I2C_CON_REG_STA;
}

/*****************************************************************
 * @brief  I2C��������
 * @param  pstI2cObj: I2c�豸���� ucData:���͵�����
 * @retval ��
*****************************************************************/
void I2cSendData(PST_I2C_ATTR pstI2cObj, uint8_t ucData)
{
	assert_param(NULL != pstI2cObj);
	assert_param(NULL != pstI2cObj->pstCtrller);

	PST_I2C_RegDef pstI2cCtrller = pstI2cObj->pstCtrller;
	pstI2cCtrller->I2CDAT = ucData;
}

/*****************************************************************
 * @brief  I2C�������ݻ�ȡ
 * @param  pstI2cObj: I2c�豸����
 * @retval uint8_t�����ط��͵�����
*****************************************************************/
uint8_t I2cSendDataGet(PST_I2C_ATTR pstI2cObj)
{
	assert_param(NULL != pstI2cObj);
	assert_param(NULL != pstI2cObj->pstCtrller);

	PST_I2C_RegDef pstI2cCtrller = pstI2cObj->pstCtrller;
	return pstI2cCtrller->I2CDAT;
}

/*****************************************************************
 * @brief  I2C��������
 * @param  pstI2cObj: I2c�豸����
 * @retval ��
*****************************************************************/
uint8_t I2cReceiveData(PST_I2C_ATTR pstI2cObj)
{
	assert_param(NULL != pstI2cObj);
	assert_param(NULL != pstI2cObj->pstCtrller);

	PST_I2C_RegDef pstI2cCtrller = pstI2cObj->pstCtrller;
	return pstI2cCtrller->I2CDAT;
}

/*****************************************************************
 * @brief  I2Cֹͣλ����
 * @param  pstI2cObj: I2c�豸����
 * @retval ��
*****************************************************************/
void I2cGenerateStop(PST_I2C_ATTR pstI2cObj)
{
	assert_param(NULL != pstI2cObj);
	assert_param(NULL != pstI2cObj->pstCtrller);

	PST_I2C_RegDef pstI2cCtrller = pstI2cObj->pstCtrller;
	uint8_t ucConParam = pstI2cCtrller->I2CCON;
	pstI2cCtrller->I2CCON = ucConParam | I2C_CON_REG_STO;
}

/*****************************************************************
 * @brief  I2C����7��ַ
 * @param  pstI2cObj: I2c�豸���� ucAddress�����豸��ַ��
 *         ucDirection�����䷽��
 * @retval ��
*****************************************************************/
void I2cSend7bitAddress(PST_I2C_ATTR pstI2cObj, uint8_t ucAddress, uint8_t ucDirection)
{
	assert_param(NULL != pstI2cObj);
	assert_param(NULL != pstI2cObj->pstCtrller);
	assert_param(ucDirection < EN_I2C_DIR_MAX);

    uint8_t ucDevAddress = 0;
    PST_I2C_RegDef pstI2cCtrller = pstI2cObj->pstCtrller;

	if (ucDirection == EN_I2C_DIR_SEND)
	{
		ucDevAddress = OAR_ADD_Reset & ucAddress;
	}
	else
	{
		ucDevAddress = OAR_ADD_Set | ucAddress;
	}
	pstI2cCtrller->I2CDAT = ucDevAddress;
}

/*****************************************************************
 * @brief  I2C�жϽӿ�
 * @param  pstI2cObj: I2c�豸����
 * @retval ��
*****************************************************************/
void PlicI2cHandle(void * ptrBackCall)
{

}
