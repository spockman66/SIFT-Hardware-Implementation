/*
 * hme_iic.c
 *
 *  Created on: 2021年12月3日
 *      Author: Administrator
 */


#include "hme_iic.h"

#define OAR_ADD_Set           ((uint16_t)0x0001)
#define OAR_ADD_Reset         ((uint16_t)0xFFFE)

static void PlicI2cHandle(void * ptrBackCall);

/*****************************************************************
 * @brief  I2C结构体默认初始化
 * @param  pstI2cObj: I2c设备对象
 * @retval 无
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
 * @brief  I2C结构体初始化
 * @param  pstI2cObj: I2c设备对象，pstI2cParam:初始化参数指针
 * @retval 无
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
 * @brief  I2C设备初始化，将数据写入对应寄存器
 * @param  pstI2cObj: I2c设备对象
 * @retval 无
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

	//PLIC中断使能和注册
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
 * @brief  I2C控制参数配置
 * @param  pstI2cObj: I2c设备对象， ucCfgParam：配置参数
 * @retval 无
*****************************************************************/
void I2cSpconCfg(PST_I2C_ATTR pstI2cObj, uint8_t ucCfgParam)
{
	assert_param(NULL != pstI2cObj);
	assert_param(NULL != pstI2cObj->pstCtrller);

	PST_I2C_RegDef pstI2cCtrller = pstI2cObj->pstCtrller;
	pstI2cCtrller->I2CCON = ucCfgParam;
}

/*****************************************************************
 * @brief  I2C时钟分频配置
 * @param  pstI2cObj: I2c设备对象
 * @retval 无
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
 * @brief  获取I2C的配置参数
 * @param  pstI2cObj: I2c设备对象
 * @retval 无
*****************************************************************/
uint8_t I2cSpconGet(PST_I2C_ATTR pstI2cObj)
{
	assert_param(NULL != pstI2cObj);
	assert_param(NULL != pstI2cObj->pstCtrller);

	PST_I2C_RegDef pstI2cCtrller = pstI2cObj->pstCtrller;
	return pstI2cCtrller->I2CCON;
}

/*****************************************************************
 * @brief  I2C设备使能
 * @param  pstI2cObj: I2c设备对象
 * @retval 无
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
 * @brief  I2C设备禁止
 * @param  pstI2cObj: I2c设备对象
 * @retval 无
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
 * @brief  I2C状态码获取
 * @param  pstI2cObj: I2c设备对象
 * @retval 无
*****************************************************************/
uint8_t I2cStateCodeGet(PST_I2C_ATTR pstI2cObj)
{
	assert_param(NULL != pstI2cObj);
	assert_param(NULL != pstI2cObj->pstCtrller);

	PST_I2C_RegDef pstI2cCtrller = pstI2cObj->pstCtrller;
	return pstI2cCtrller->I2CSTA;
}

/*****************************************************************
 * @brief  I2C作为从站时的设备地址配置
 * @param  pstI2cObj: I2c设备对象
 * @retval 无
*****************************************************************/
void I2cOwnAddressCfg(PST_I2C_ATTR pstI2cObj)
{
	assert_param(NULL != pstI2cObj);
	assert_param(NULL != pstI2cObj->pstCtrller);

	PST_I2C_RegDef pstI2cCtrller = pstI2cObj->pstCtrller;
	pstI2cCtrller->I2CADR = pstI2cObj->stCfgParam.ucSelfAddr;
}

/*****************************************************************
 * @brief  I2C自身的设备地址获取
 * @param  pstI2cObj: I2c设备对象
 * @retval 无
*****************************************************************/
uint8_t I2cOwnAddressGet(PST_I2C_ATTR pstI2cObj)
{
	assert_param(NULL != pstI2cObj);
	assert_param(NULL != pstI2cObj->pstCtrller);

	PST_I2C_RegDef pstI2cCtrller = pstI2cObj->pstCtrller;
	return pstI2cCtrller->I2CADR;
}

/*****************************************************************
 * @brief  I2C起始位生成
 * @param  pstI2cObj: I2c设备对象
 * @retval 无
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
 * @brief  I2C发送数据
 * @param  pstI2cObj: I2c设备对象， ucData:发送的数据
 * @retval 无
*****************************************************************/
void I2cSendData(PST_I2C_ATTR pstI2cObj, uint8_t ucData)
{
	assert_param(NULL != pstI2cObj);
	assert_param(NULL != pstI2cObj->pstCtrller);

	PST_I2C_RegDef pstI2cCtrller = pstI2cObj->pstCtrller;
	pstI2cCtrller->I2CDAT = ucData;
}

/*****************************************************************
 * @brief  I2C发送数据获取
 * @param  pstI2cObj: I2c设备对象
 * @retval uint8_t：返回发送的数据
*****************************************************************/
uint8_t I2cSendDataGet(PST_I2C_ATTR pstI2cObj)
{
	assert_param(NULL != pstI2cObj);
	assert_param(NULL != pstI2cObj->pstCtrller);

	PST_I2C_RegDef pstI2cCtrller = pstI2cObj->pstCtrller;
	return pstI2cCtrller->I2CDAT;
}

/*****************************************************************
 * @brief  I2C接收数据
 * @param  pstI2cObj: I2c设备对象
 * @retval 无
*****************************************************************/
uint8_t I2cReceiveData(PST_I2C_ATTR pstI2cObj)
{
	assert_param(NULL != pstI2cObj);
	assert_param(NULL != pstI2cObj->pstCtrller);

	PST_I2C_RegDef pstI2cCtrller = pstI2cObj->pstCtrller;
	return pstI2cCtrller->I2CDAT;
}

/*****************************************************************
 * @brief  I2C停止位产生
 * @param  pstI2cObj: I2c设备对象
 * @retval 无
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
 * @brief  I2C发送7地址
 * @param  pstI2cObj: I2c设备对象， ucAddress：从设备地址，
 *         ucDirection：传输方向
 * @retval 无
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
 * @brief  I2C中断接口
 * @param  pstI2cObj: I2c设备对象
 * @retval 无
*****************************************************************/
void PlicI2cHandle(void * ptrBackCall)
{

}
