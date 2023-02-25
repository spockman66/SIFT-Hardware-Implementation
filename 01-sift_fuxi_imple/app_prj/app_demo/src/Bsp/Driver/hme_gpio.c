/*
 * hme_gpio.c
 *
 *  Created on: 2021年11月10日
 *      Author: Administrator
 */

#include "stdio.h"
#include "hme_gpio.h"

static uint32_t GpioIntrStateGet(PST_GPIO_ATTR pstGpioObj);
static void GpioIntrStateClear(PST_GPIO_ATTR pstGpioObj, uint32_t ulIntrClearParam);
static void GpioIntrDispatch(PST_GPIO_ATTR pstGpioObj, uint32_t ulIntrParam);
static void GpioIntrExecute(PST_GPIO_ATTR pstGpioObj);
static void PlicGpioHandle(void * ptrBackCall);

/*****************************************************************
 * @brief  GPIO设备ID获取
 * @param  pstGpioObj：GPIO对象
 * @retval 无
*****************************************************************/
uint32_t GpioIdGet(PST_GPIO_ATTR pstGpioObj)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);
	return pstGpioObj->pstCtrller->IDREV;
}

/*****************************************************************
  * @brief  GPIO结构体默认初始化
  * @param  pstGpioObj:GPIO设备对象
  * @retval 无
*****************************************************************/
void GpioStructDeInit(PST_GPIO_ATTR pstGpioObj)
{
	assert_param(NULL != pstGpioObj);

	pstGpioObj->stCfgParam.usDevId      = DEF_GPIO_DEV_ID;
	pstGpioObj->stCfgParam.ucDirection  = EN_GPIO_DIR_TYPE_OUT;
	pstGpioObj->stCfgParam.ucIntrEn     = DISABLE;
	pstGpioObj->stCfgParam.ucIntrMode   = EN_GPIO_INTR_MODE_NO_OP;
	pstGpioObj->stCfgParam.ucPullEn     = DISABLE;
	pstGpioObj->stCfgParam.ucPullType   = EN_GPIO_PULL_TYPE_UP;
	pstGpioObj->stCfgParam.ucDbBounceEn = DISABLE;
	pstGpioObj->stCfgParam.ucDBClkSel   = EN_GPIO_DBCLK_TYPE_EXT;
	pstGpioObj->stCfgParam.DBPreScale   = 0;
	pstGpioObj->stCfgParam.ulChannels   = GPIO_Pin_All;

	pstGpioObj->stPlicCfgParam.ucIntrEnFlage = DISABLE;
	pstGpioObj->stPlicCfgParam.ucPriority = EN_PRIORITY_2;

	pstGpioObj->pstCtrller = DEV_GPIO;
}

/*****************************************************************
 * @brief  GPIO结构体根据参数进行初始化
 * @param  pstGpioObj：配置GPIO对象， pstGpioParam:GPIO配置参数指针
 * @retval 无
*****************************************************************/
void GpioObjParamInit(PST_GPIO_ATTR pstGpioObj, PST_GPIO_ATTR pstGpioParam)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioParam);
	assert_param(NULL != pstGpioParam->pstCtrller);
	assert_param(IS_GPIO_DIR_TYPE(pstGpioParam->stCfgParam.ucDirection));
	assert_param(IS_GPIO_INTR_MODE(pstGpioParam->stCfgParam.ucIntrMode));
	assert_param(IS_GPIO_PULL_TYPE(pstGpioParam->stCfgParam.ucPullType));

	pstGpioObj->stCfgParam.usDevId      = pstGpioParam->stCfgParam.usDevId;
	pstGpioObj->stCfgParam.ucDirection  = pstGpioParam->stCfgParam.ucDirection;
	pstGpioObj->stCfgParam.ucIntrEn     = pstGpioParam->stCfgParam.ucIntrEn;
	pstGpioObj->stCfgParam.ucIntrMode   = pstGpioParam->stCfgParam.ucIntrMode;
	pstGpioObj->stCfgParam.ucPullEn     = pstGpioParam->stCfgParam.ucPullEn;
	pstGpioObj->stCfgParam.ucPullType   = pstGpioParam->stCfgParam.ucPullType;
	pstGpioObj->stCfgParam.ucDbBounceEn = pstGpioParam->stCfgParam.ucDbBounceEn;
	pstGpioObj->stCfgParam.ucDBClkSel   = pstGpioParam->stCfgParam.ucDBClkSel;
	pstGpioObj->stCfgParam.DBPreScale   = pstGpioParam->stCfgParam.DBPreScale;
	pstGpioObj->stCfgParam.ulChannels   = pstGpioParam->stCfgParam.ulChannels;

	pstGpioObj->stPlicCfgParam.ucIntrEnFlage  = pstGpioParam->stPlicCfgParam.ucIntrEnFlage;
	pstGpioObj->stPlicCfgParam.ucPriority = pstGpioParam->stPlicCfgParam.ucPriority;

	pstGpioObj->pstCtrller = pstGpioParam->pstCtrller;
}

/*****************************************************************
 * @brief  GPIO结构体控制器配置
 * @param  pstGpioObj：配置的GPIO对象
 * @retval 无
*****************************************************************/
void GpioObjConfigInit(PST_GPIO_ATTR pstGpioObj)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);

	uint32_t ulGpioEnVal= 0;
	ST_PLIC_REG_PARAM stGpioRegParam = {0};

	//PLIC中断使能和注册
	ulGpioEnVal = DevIntrEnTableGet(pstGpioObj->stCfgParam.usDevId);
	stGpioRegParam.usIntrId = DevIntrIdTableGet(pstGpioObj->stCfgParam.usDevId);
	stGpioRegParam.IntrHander = PlicGpioHandle;
	stGpioRegParam.ptrBackCall = pstGpioObj;
	if (pstGpioObj->stPlicCfgParam.ucIntrEnFlage)
	{
		//intr Priority set
		IntrPrioritySet(pstGpioObj->stCfgParam.usDevId, pstGpioObj->stPlicCfgParam.ucPriority);
        //intr handle register
		PlicIntrHandleRegister(&stGpioRegParam, pstGpioObj->stCfgParam.usDevId);
		//intr handle enable
		PlicEnableSet(ulGpioEnVal);
	}

	//GPIO方向配置
	GpioBitsDirCfg(pstGpioObj);
	//GPIO中断配置
	GpioBitsIntrCfg(pstGpioObj);
	//GPIO上下拉配置
	GpioBitsPullCfg(pstGpioObj);
	//中断防抖配置
	GpioBitsDebounceCfg(pstGpioObj);
}

/*****************************************************************
 * @brief  GPIO配置属性获取
 * @param  pstGpioObj：GPIO设备对象
 * @retval uint32_t：返回控制参数属性
 *****************************************************************/
uint32_t GpioCfgStateGet(PST_GPIO_ATTR pstGpioObj)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);
	return pstGpioObj->pstCtrller->CFG;
}

/*****************************************************************
 * @brief  GPIO引脚的方向配置
 * @param  pstGpioObj：GPIO设备参数
 * @retval 无
 *****************************************************************/
void GpioBitsDirCfg(PST_GPIO_ATTR pstGpioObj)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);

	uint32_t ulTemParam = 0;
	uint8_t  ucDirFlag  = pstGpioObj->stCfgParam.ucDirection;
	uint32_t ulChannels   = pstGpioObj->stCfgParam.ulChannels;

	assert_param(IS_GPIO_DIR_TYPE(ucDirFlag));

	ulTemParam = pstGpioObj->pstCtrller->CHANNELDIR;

	if (ucDirFlag == EN_GPIO_DIR_TYPE_OUT)
	{
		ulTemParam = ulTemParam | ulChannels;
		pstGpioObj->pstCtrller->CHANNELDIR = ulTemParam;
	}
	else
	{
		ulTemParam = (ulTemParam & (~ulChannels));
		pstGpioObj->pstCtrller->CHANNELDIR = ulTemParam;
	}
}

/*****************************************************************
 * @brief 获取GPIO的方向控制参数
 * @param  pstGpioObj：GPIO设备对象
 * @retval uint32_t：返回方向数据信息
 *****************************************************************/
uint32_t GpioAllBitsDirGet(PST_GPIO_ATTR pstGpioObj)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);
	return pstGpioObj->pstCtrller->CHANNELDIR;
}

/*****************************************************************
 * @brief  GPIO端口输出设置
 * @param  pstGpioObj：GPIO设备对象
 * @retval 无
 *****************************************************************/
void GpioBitsDoutSet(PST_GPIO_ATTR pstGpioObj)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);

	uint32_t ulChannels = pstGpioObj->stCfgParam.ulChannels;
	pstGpioObj->pstCtrller->DOUTSET = ulChannels;
}

/*****************************************************************
 * @brief  GPIO端口输出清零
 * @param  pstGpioObj：GPIO设备对象
 * @retval 无
 *****************************************************************/
void GpioBitsDoutClear(PST_GPIO_ATTR pstGpioObj)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);

	uint32_t ulChannels   = pstGpioObj->stCfgParam.ulChannels;
	pstGpioObj->pstCtrller->DOUTCLEAR = ulChannels;
}

/*****************************************************************
 * @brief  GPIO端口输出状态数据获取
 * @param  stGpioObj：GPIO设备对象
 * @retval 无
 *****************************************************************/
uint32_t GpioDoutDataGet(PST_GPIO_ATTR pstGpioObj)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);

	return pstGpioObj->pstCtrller->DATAOUT;
}

/*****************************************************************
 * @brief  GPIO端口输入状态数据获取
 * @param  stGpioObj：GPIO设备对象
 * @retval 无
 *****************************************************************/
uint32_t GpioDinDataGet(PST_GPIO_ATTR pstGpioObj)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);

	return pstGpioObj->pstCtrller->DATAIN;
}

/*****************************************************************
 * @brief  GPIO上下拉属性配置
 * @param  pstGpioObj：GPIO设备对象
 * @retval 无
 *****************************************************************/
void GpioBitsPullCfg(PST_GPIO_ATTR pstGpioObj)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);

	uint32_t ulTemParam = 0;
	uint8_t  ucPullEnFlag = pstGpioObj->stCfgParam.ucPullEn;
	uint8_t  ucPullType   = pstGpioObj->stCfgParam.ucPullType;
	uint32_t ulChannels   = pstGpioObj->stCfgParam.ulChannels;

	assert_param(IS_GPIO_ENABLE_TYPE(ucPullEnFlag));
	assert_param(IS_GPIO_PULL_TYPE(ucPullType));

	if (ucPullEnFlag == ENABLE)
	{
		ulTemParam = pstGpioObj->pstCtrller->PULLEN;
		ulTemParam = ulTemParam | ulChannels;
		pstGpioObj->pstCtrller->PULLEN = ulTemParam;

		if (ucPullType == EN_GPIO_PULL_TYPE_UP)
		{
			ulTemParam = pstGpioObj->pstCtrller->PULLTYPE;
			ulTemParam = ulTemParam & (~ulChannels);
			pstGpioObj->pstCtrller->PULLTYPE = ulTemParam;
		}
		else
		{
			ulTemParam = pstGpioObj->pstCtrller->PULLTYPE;
			ulTemParam = ulTemParam | ulChannels;
			pstGpioObj->pstCtrller->PULLTYPE = ulTemParam;
		}
	}
	else
	{
		ulTemParam = pstGpioObj->pstCtrller->PULLEN;
		ulTemParam = ulTemParam & (~ulChannels);
		pstGpioObj->pstCtrller->PULLEN = ulTemParam;
	}
}

/*****************************************************************
 * @brief GPIO上下拉使能状态获取
 * @param  pstGpioObj：GPIO设备对象
 * @retval uint32_t：返回使能参数属性
 *****************************************************************/
uint32_t GpioPullEnStateGet(PST_GPIO_ATTR pstGpioObj)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);
	return pstGpioObj->pstCtrller->PULLEN;
}

/*****************************************************************
 * @brief  GPIO上下拉类型属性获取
 * @param  pstGpioObj：GPIO设备对象
 * @retval uint32_t：返回上下拉属性
 *****************************************************************/
uint32_t GpioPullTypeGet(PST_GPIO_ATTR pstGpioObj)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);
	return pstGpioObj->pstCtrller->PULLTYPE;
}

/*****************************************************************
 * @brief  GPIO防抖属性配置
 * @param  pstGpioObj：GPIO设备对象
 * @retval 无
 *****************************************************************/
void GpioBitsDebounceCfg(PST_GPIO_ATTR pstGpioObj)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);

	uint32_t ulTemParam = 0;
	uint8_t  ucDbBounceEn = pstGpioObj->stCfgParam.ucDbBounceEn;
	uint8_t  ucDbClkSel   = pstGpioObj->stCfgParam.ucDBClkSel;
	uint8_t  ucDBPreScale = pstGpioObj->stCfgParam.DBPreScale;
	uint32_t ulChannels   = pstGpioObj->stCfgParam.ulChannels;

	assert_param(IS_GPIO_DIR_TYPE(ucDbBounceEn));
    assert_param(IS_GPIO_DBCLK_TYPE(ucDbClkSel));

    //使能Gpio抖动使能和参数配置
	if (ucDbBounceEn == ENABLE)
	{
		ulTemParam = pstGpioObj->pstCtrller->DEBOUNCECTRL;
		if (ucDbClkSel == EN_GPIO_DBCLK_TYPE_EXT)
		{
			ulTemParam = ulTemParam & (~(1 << 31));
			ulTemParam = ulTemParam | ucDBPreScale;
			pstGpioObj->pstCtrller->DEBOUNCECTRL = ulTemParam;
		}
		else
		{
			ulTemParam = ulTemParam | (1 << 31);
			ulTemParam = ulTemParam | ucDBPreScale;
			pstGpioObj->pstCtrller->DEBOUNCECTRL = ulTemParam;
		}


		ulTemParam = pstGpioObj->pstCtrller->DEBOUNCEEN;
		ulTemParam = ulTemParam | ulChannels;
		pstGpioObj->pstCtrller->DEBOUNCEEN = ulTemParam;
	}
	else
	{
		//禁止GPIO抖动设置
		ulTemParam = pstGpioObj->pstCtrller->DEBOUNCEEN;
		ulTemParam = ulTemParam & (~ulChannels);
		pstGpioObj->pstCtrller->DEBOUNCEEN = ulTemParam;
	}
}


/*****************************************************************
 * @brief  获取GPIO的抖动控制参数
 * @param  pstGpioObj：GPIO设备对象
 * @retval uint32_t：返回抖动控制参数属性
 *****************************************************************/
uint32_t GpioDebounceCtrlStateGet(PST_GPIO_ATTR pstGpioObj)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);
	return pstGpioObj->pstCtrller->DEBOUNCECTRL;
}

/*****************************************************************
 * @brief  GPIO抖动使能参数获取
 * @param  pstGpioObj：GPIO设备对象
 * @retval uint32_t：返回防抖使能控制状态
 *****************************************************************/
uint32_t GpioDebounceEnStateGet(PST_GPIO_ATTR pstGpioObj)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);
	return pstGpioObj->pstCtrller->DEBOUNCEEN;
}

/*****************************************************************
 * @brief  GPIO中断使能配置
 * @param  pstGpioObj：GPIO设备对象
 * @retval 无
 *****************************************************************/
void GpioBitsIntrCfg(PST_GPIO_ATTR pstGpioObj)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);

	uint32_t ulCount = 0;
	uint32_t ulTemParam = 0;
	uint8_t  ucIntrEnFlag = pstGpioObj->stCfgParam.ucIntrEn;
	uint8_t  ucIntrMode   = pstGpioObj->stCfgParam.ucIntrMode;
	uint32_t ulChannels   = pstGpioObj->stCfgParam.ulChannels;

	assert_param(IS_GPIO_ENABLE_TYPE(ucIntrEnFlag));
	assert_param(IS_GPIO_INTR_MODE(ucIntrMode));

	if (ucIntrEnFlag == ENABLE)
	{
        //GPIO设备中断使能配置
		ulTemParam = pstGpioObj->pstCtrller->INTREN;
		ulTemParam = ulTemParam | ulChannels;
		pstGpioObj->pstCtrller->INTREN = ulTemParam;
		for (ulCount = 0; ulCount < 32; ulCount++)
		{
			if (ulChannels & (1 << ulCount))
			{
				if (ulCount < 8)
				{
					ulTemParam = pstGpioObj->pstCtrller->INTRMODE0;
					ulTemParam = ulTemParam | (ucIntrMode << (ulCount * 4));
					pstGpioObj->pstCtrller->INTRMODE0 = ulTemParam;
				}
				else if (ulCount < 16)
				{
					ulTemParam = pstGpioObj->pstCtrller->INTRMODE1;
					ulTemParam = ulTemParam | (ucIntrMode << ((ulCount - 8) * 4));
					pstGpioObj->pstCtrller->INTRMODE0 = ulTemParam;
				}
				else if (ulCount < 24)
				{
					ulTemParam = pstGpioObj->pstCtrller->INTRMODE2;
					ulTemParam = ulTemParam | (ucIntrMode << ((ulCount - 16) * 4));
					pstGpioObj->pstCtrller->INTRMODE0 = ulTemParam;
				}
				else
				{
					ulTemParam = pstGpioObj->pstCtrller->INTRMODE3;
					ulTemParam = ulTemParam | (ucIntrMode << ((ulCount - 24) * 4));
					pstGpioObj->pstCtrller->INTRMODE0 = ulTemParam;
				}
			}
		}
	}
	else
	{
		/***中断对应位禁止使能***/
		GpioBitsIntrDisable(pstGpioObj);
	}
}

/*****************************************************************
 * @brief   GPIO中断使能状态获取
 * @param   pstGpioObj：GPIO设备对象
 * @retval  uint32_t：返回中断使能控制参数
 *****************************************************************/
uint32_t GpioIntrEnStateGet(PST_GPIO_ATTR pstGpioObj)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);
	return pstGpioObj->pstCtrller->INTREN;
}


/*****************************************************************
 * @brief  GPIO中断模式获取
 * @param  pstGpioObj：GPIO设备对象, ucGroup:中断分组参数
 * @retval uint32_t：返回中断模式参数
 *****************************************************************/
uint32_t GpioIntrModeGroupStateGet(PST_GPIO_ATTR pstGpioObj, uint8_t ucGroup)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);
	assert_param(IS_GPIO_INTRM_GROUP(ucGroup));

	uint32_t ulGroupMode = 0;

	switch (ucGroup)
	{
	    case EN_GPIO_INTRM_GROUP_0:
	    {
	    	ulGroupMode = pstGpioObj->pstCtrller->INTRMODE0;
	    	break;
	    }
	    case EN_GPIO_INTRM_GROUP_1:
	    {
	    	ulGroupMode = pstGpioObj->pstCtrller->INTRMODE1;
	    	break;
	    }
	    case EN_GPIO_INTRM_GROUP_2:
	    {
	    	ulGroupMode = pstGpioObj->pstCtrller->INTRMODE2;
	    	break;
	    }
	    case EN_GPIO_INTRM_GROUP_3:
	    {
	    	ulGroupMode = pstGpioObj->pstCtrller->INTRMODE3;
	    	break;
	    }
	    default:
	    	break;
	}

	return ulGroupMode;
}

/*****************************************************************
 * @brief  GPIO中断禁止
 * @param  pstGpioObj：GPIO设备对象
 * @retval 无
 *****************************************************************/
void GpioBitsIntrDisable(PST_GPIO_ATTR pstGpioObj)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);

	uint32_t ulTemParam = 0;
	uint32_t ulChannels = pstGpioObj->stCfgParam.ulChannels;

	ulTemParam = pstGpioObj->pstCtrller->INTREN;
	ulTemParam = ulTemParam & (~ulChannels);
	pstGpioObj->pstCtrller->INTREN = ulTemParam;
}

/*****************************************************************
 * @brief  GPIO中断状态获取
 * @param  pstGpioObj：GPIO设备对象
 * @retval 无
 *****************************************************************/
uint32_t GpioIntrStateGet(PST_GPIO_ATTR pstGpioObj)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);

	return pstGpioObj->pstCtrller->INTRSTATUS;
}

/*****************************************************************
 * @brief  GPIO中断状态清除
 * @param  pstGpioObj：GPIO设备对象，ulIntrClearParam：中断清除端口参数
 * @retval 无
 *****************************************************************/
void GpioIntrStateClear(PST_GPIO_ATTR pstGpioObj, uint32_t ulIntrClearParam)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);

    pstGpioObj->pstCtrller->INTRSTATUS = ulIntrClearParam;
}

/*****************************************************************
 * @brief  GPIO中断处理接口
 * @param  ptrBackCall：回调参数
 * @retval 无
 *****************************************************************/
void PlicGpioHandle(void * ptrBackCall)
{
	uint32_t ulIntrState = 0;
	PST_GPIO_ATTR ptrGpioObj = NULL;
	if (NULL != ptrBackCall)
	{
		ptrGpioObj = (PST_GPIO_ATTR)ptrBackCall;
		//读取中断状态
		ulIntrState = GpioIntrStateGet(ptrGpioObj);
		//执行中断检索和调度
		GpioIntrDispatch(ptrGpioObj, ulIntrState);
		//清楚GPIO的中断 写中断状态对应的bit位
		GpioIntrStateClear(ptrGpioObj, ulIntrState);
	}
	else
	{
		printf("PLIC Gpio Interrupt Err...!\n");
	}
}

/*****************************************************************
 * @brief  GPIO中断分配
 * @param  pstGpioObj: GPIO设备对象指针， ulIntrParam：分配参数
 * @retval 无
 *****************************************************************/
void GpioIntrDispatch(PST_GPIO_ATTR pstGpioObj, uint32_t ulIntrParam)
{
	uint32_t ulCount = 0;
	for (ulCount = 0; ulCount < 32; ulCount++)
	{
		if (ulIntrParam & (1 << ulCount))
		{
			break;
		}
	}

	switch (ulCount)
	{
	    case 1:
	    case 2:
	    case 3:
	    case 4:
	    case 5:
	    case 6:
	    case 7:
	    case 8:
	    case 9:
	    case 10:
	    case 11:
	    case 12:
	    case 13:
	    case 14:
	    case 15:
	    case 16:
	    case 17:
	    case 18:
	    case 19:
	    case 20:
	    case 21:
	    case 22:
	    case 23:
	    case 24:
	    case 25:
	    case 26:
	    case 27:
	    case 28:
	    case 29:
	    case 30:
	    case 31:
	    case 32:
	    {
	    	GpioIntrExecute(pstGpioObj);
	    	break;
	    }
	    default:
	    	break;
	}

}

/*****************************************************************
 * @brief  GPIO中断执行函数
 * @param  pstGpioObj：GPIO设备对象指针
 * @retval 无
 * 注意：该接口预留，只作为测试处理
 *****************************************************************/
void GpioIntrExecute(PST_GPIO_ATTR pstGpioObj)
{
	printf ("PLIC Gpio Interrupt Execute....\n");
}
