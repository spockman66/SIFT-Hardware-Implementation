/*
 * hme_gpio.c
 *
 *  Created on: 2021��11��10��
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
 * @brief  GPIO�豸ID��ȡ
 * @param  pstGpioObj��GPIO����
 * @retval ��
*****************************************************************/
uint32_t GpioIdGet(PST_GPIO_ATTR pstGpioObj)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);
	return pstGpioObj->pstCtrller->IDREV;
}

/*****************************************************************
  * @brief  GPIO�ṹ��Ĭ�ϳ�ʼ��
  * @param  pstGpioObj:GPIO�豸����
  * @retval ��
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
 * @brief  GPIO�ṹ����ݲ������г�ʼ��
 * @param  pstGpioObj������GPIO���� pstGpioParam:GPIO���ò���ָ��
 * @retval ��
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
 * @brief  GPIO�ṹ�����������
 * @param  pstGpioObj�����õ�GPIO����
 * @retval ��
*****************************************************************/
void GpioObjConfigInit(PST_GPIO_ATTR pstGpioObj)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);

	uint32_t ulGpioEnVal= 0;
	ST_PLIC_REG_PARAM stGpioRegParam = {0};

	//PLIC�ж�ʹ�ܺ�ע��
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

	//GPIO��������
	GpioBitsDirCfg(pstGpioObj);
	//GPIO�ж�����
	GpioBitsIntrCfg(pstGpioObj);
	//GPIO����������
	GpioBitsPullCfg(pstGpioObj);
	//�жϷ�������
	GpioBitsDebounceCfg(pstGpioObj);
}

/*****************************************************************
 * @brief  GPIO�������Ի�ȡ
 * @param  pstGpioObj��GPIO�豸����
 * @retval uint32_t�����ؿ��Ʋ�������
 *****************************************************************/
uint32_t GpioCfgStateGet(PST_GPIO_ATTR pstGpioObj)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);
	return pstGpioObj->pstCtrller->CFG;
}

/*****************************************************************
 * @brief  GPIO���ŵķ�������
 * @param  pstGpioObj��GPIO�豸����
 * @retval ��
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
 * @brief ��ȡGPIO�ķ�����Ʋ���
 * @param  pstGpioObj��GPIO�豸����
 * @retval uint32_t�����ط���������Ϣ
 *****************************************************************/
uint32_t GpioAllBitsDirGet(PST_GPIO_ATTR pstGpioObj)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);
	return pstGpioObj->pstCtrller->CHANNELDIR;
}

/*****************************************************************
 * @brief  GPIO�˿��������
 * @param  pstGpioObj��GPIO�豸����
 * @retval ��
 *****************************************************************/
void GpioBitsDoutSet(PST_GPIO_ATTR pstGpioObj)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);

	uint32_t ulChannels = pstGpioObj->stCfgParam.ulChannels;
	pstGpioObj->pstCtrller->DOUTSET = ulChannels;
}

/*****************************************************************
 * @brief  GPIO�˿��������
 * @param  pstGpioObj��GPIO�豸����
 * @retval ��
 *****************************************************************/
void GpioBitsDoutClear(PST_GPIO_ATTR pstGpioObj)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);

	uint32_t ulChannels   = pstGpioObj->stCfgParam.ulChannels;
	pstGpioObj->pstCtrller->DOUTCLEAR = ulChannels;
}

/*****************************************************************
 * @brief  GPIO�˿����״̬���ݻ�ȡ
 * @param  stGpioObj��GPIO�豸����
 * @retval ��
 *****************************************************************/
uint32_t GpioDoutDataGet(PST_GPIO_ATTR pstGpioObj)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);

	return pstGpioObj->pstCtrller->DATAOUT;
}

/*****************************************************************
 * @brief  GPIO�˿�����״̬���ݻ�ȡ
 * @param  stGpioObj��GPIO�豸����
 * @retval ��
 *****************************************************************/
uint32_t GpioDinDataGet(PST_GPIO_ATTR pstGpioObj)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);

	return pstGpioObj->pstCtrller->DATAIN;
}

/*****************************************************************
 * @brief  GPIO��������������
 * @param  pstGpioObj��GPIO�豸����
 * @retval ��
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
 * @brief GPIO������ʹ��״̬��ȡ
 * @param  pstGpioObj��GPIO�豸����
 * @retval uint32_t������ʹ�ܲ�������
 *****************************************************************/
uint32_t GpioPullEnStateGet(PST_GPIO_ATTR pstGpioObj)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);
	return pstGpioObj->pstCtrller->PULLEN;
}

/*****************************************************************
 * @brief  GPIO�������������Ի�ȡ
 * @param  pstGpioObj��GPIO�豸����
 * @retval uint32_t����������������
 *****************************************************************/
uint32_t GpioPullTypeGet(PST_GPIO_ATTR pstGpioObj)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);
	return pstGpioObj->pstCtrller->PULLTYPE;
}

/*****************************************************************
 * @brief  GPIO������������
 * @param  pstGpioObj��GPIO�豸����
 * @retval ��
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

    //ʹ��Gpio����ʹ�ܺͲ�������
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
		//��ֹGPIO��������
		ulTemParam = pstGpioObj->pstCtrller->DEBOUNCEEN;
		ulTemParam = ulTemParam & (~ulChannels);
		pstGpioObj->pstCtrller->DEBOUNCEEN = ulTemParam;
	}
}


/*****************************************************************
 * @brief  ��ȡGPIO�Ķ������Ʋ���
 * @param  pstGpioObj��GPIO�豸����
 * @retval uint32_t�����ض������Ʋ�������
 *****************************************************************/
uint32_t GpioDebounceCtrlStateGet(PST_GPIO_ATTR pstGpioObj)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);
	return pstGpioObj->pstCtrller->DEBOUNCECTRL;
}

/*****************************************************************
 * @brief  GPIO����ʹ�ܲ�����ȡ
 * @param  pstGpioObj��GPIO�豸����
 * @retval uint32_t�����ط���ʹ�ܿ���״̬
 *****************************************************************/
uint32_t GpioDebounceEnStateGet(PST_GPIO_ATTR pstGpioObj)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);
	return pstGpioObj->pstCtrller->DEBOUNCEEN;
}

/*****************************************************************
 * @brief  GPIO�ж�ʹ������
 * @param  pstGpioObj��GPIO�豸����
 * @retval ��
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
        //GPIO�豸�ж�ʹ������
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
		/***�ж϶�Ӧλ��ֹʹ��***/
		GpioBitsIntrDisable(pstGpioObj);
	}
}

/*****************************************************************
 * @brief   GPIO�ж�ʹ��״̬��ȡ
 * @param   pstGpioObj��GPIO�豸����
 * @retval  uint32_t�������ж�ʹ�ܿ��Ʋ���
 *****************************************************************/
uint32_t GpioIntrEnStateGet(PST_GPIO_ATTR pstGpioObj)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);
	return pstGpioObj->pstCtrller->INTREN;
}


/*****************************************************************
 * @brief  GPIO�ж�ģʽ��ȡ
 * @param  pstGpioObj��GPIO�豸����, ucGroup:�жϷ������
 * @retval uint32_t�������ж�ģʽ����
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
 * @brief  GPIO�жϽ�ֹ
 * @param  pstGpioObj��GPIO�豸����
 * @retval ��
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
 * @brief  GPIO�ж�״̬��ȡ
 * @param  pstGpioObj��GPIO�豸����
 * @retval ��
 *****************************************************************/
uint32_t GpioIntrStateGet(PST_GPIO_ATTR pstGpioObj)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);

	return pstGpioObj->pstCtrller->INTRSTATUS;
}

/*****************************************************************
 * @brief  GPIO�ж�״̬���
 * @param  pstGpioObj��GPIO�豸����ulIntrClearParam���ж�����˿ڲ���
 * @retval ��
 *****************************************************************/
void GpioIntrStateClear(PST_GPIO_ATTR pstGpioObj, uint32_t ulIntrClearParam)
{
	assert_param(NULL != pstGpioObj);
	assert_param(NULL != pstGpioObj->pstCtrller);

    pstGpioObj->pstCtrller->INTRSTATUS = ulIntrClearParam;
}

/*****************************************************************
 * @brief  GPIO�жϴ���ӿ�
 * @param  ptrBackCall���ص�����
 * @retval ��
 *****************************************************************/
void PlicGpioHandle(void * ptrBackCall)
{
	uint32_t ulIntrState = 0;
	PST_GPIO_ATTR ptrGpioObj = NULL;
	if (NULL != ptrBackCall)
	{
		ptrGpioObj = (PST_GPIO_ATTR)ptrBackCall;
		//��ȡ�ж�״̬
		ulIntrState = GpioIntrStateGet(ptrGpioObj);
		//ִ���жϼ����͵���
		GpioIntrDispatch(ptrGpioObj, ulIntrState);
		//���GPIO���ж� д�ж�״̬��Ӧ��bitλ
		GpioIntrStateClear(ptrGpioObj, ulIntrState);
	}
	else
	{
		printf("PLIC Gpio Interrupt Err...!\n");
	}
}

/*****************************************************************
 * @brief  GPIO�жϷ���
 * @param  pstGpioObj: GPIO�豸����ָ�룬 ulIntrParam���������
 * @retval ��
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
 * @brief  GPIO�ж�ִ�к���
 * @param  pstGpioObj��GPIO�豸����ָ��
 * @retval ��
 * ע�⣺�ýӿ�Ԥ����ֻ��Ϊ���Դ���
 *****************************************************************/
void GpioIntrExecute(PST_GPIO_ATTR pstGpioObj)
{
	printf ("PLIC Gpio Interrupt Execute....\n");
}
