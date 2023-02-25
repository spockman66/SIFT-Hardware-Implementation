#include "hme_uart.h"




static void PlicUartHandle(void * ptrBackCall);
static void UartIntrDispatch(PST_UART_ATTR pstUartObj, int8_t ucDispatch);
static void UartIntrRecvErr(PST_UART_ATTR pstUartObj);
static void UartIntrRecvExc(PST_UART_ATTR pstUartObj);
static void UartIntrRecvTimeOut(PST_UART_ATTR pstUartObj);
static void UartIntrSendExc(PST_UART_ATTR pstUartObj);
static void UartIntrModemExc(PST_UART_ATTR pstUartObj);

/*****************************************************************
 * @brief  UART�豸ID��ȡ
 * @param  pstUartObj��UART�豸����
 * @retval uint32_t������ID��
*****************************************************************/
uint32_t UartIdGet(PST_UART_ATTR pstUartObj)
{
	assert_param(NULL != pstUartObj);
	assert_param(NULL != pstUartObj->pstCtrller);

	return pstUartObj->pstCtrller->IDREV;
}

/*****************************************************************
 * @brief  UART����ṹ�����Ĭ�ϳ�ʼ��
 * @param  pstUartObj��UART�豸����
 * @retval ��
*****************************************************************/
void UartStructDeInit(PST_UART_ATTR pstUartObj)
{
	assert_param(NULL != pstUartObj);

	pstUartObj->usDevId = DEF_UART_DEV_ID;
	pstUartObj->pucSendBuf = NULL;
	pstUartObj->pucRecvBuf = NULL;
	pstUartObj->usSendDataSize = 0;
	pstUartObj->usRecvDataSize = 0;
	pstUartObj->usSendBytesCnt = 0;
	pstUartObj->usRecvBytesCnt = 0;
	pstUartObj->stCfgParam.ucFifoCtrl = UART_FIFO_CFG_EN | UART_FIFO_CFG_RRST | UART_FIFO_CFG_TRST;
	pstUartObj->stCfgParam.ucIntrCtrl = UART_INTR_ALL_DIS;
	pstUartObj->stCfgParam.ucLineCtrl = UART_LINE_CFG_WLS_8BIT;
	pstUartObj->stCfgParam.ucModemCtrl = UART_MODEM_CFG_DEFAULT;
	pstUartObj->stCfgParam.ucOscCtrl = UART_OSC_DEFAULT_VAL;
	pstUartObj->stCfgParam.ucScratchCtrl = 0;
	pstUartObj->stCfgParam.usBaudDiv = BAUD_RATE(115200);

	pstUartObj->stPlicCfgParam.ucIntrEnFlage = DISABLE;
	pstUartObj->stPlicCfgParam.ucPriority = EN_PRIORITY_3;

	pstUartObj->pstCtrller = DEV_UART0;
}

/*****************************************************************
 * @brief  UART�����������ݲ�����ʼ��
 * @param  pstUartObj��UART�豸���� pstUartParam��UART���ò���ָ��
 * @retval ��
*****************************************************************/
void UartObjParamInit(PST_UART_ATTR pstUartObj, PST_UART_ATTR pstUartParam)
{
	assert_param(NULL != pstUartObj);
	assert_param(NULL != pstUartParam);
	assert_param(NULL != pstUartParam->pstCtrller);

	pstUartObj->usDevId = pstUartParam->usDevId;
	pstUartObj->pucSendBuf = pstUartParam->pucSendBuf;
	pstUartObj->pucRecvBuf = pstUartParam->pucRecvBuf;
	pstUartObj->usSendDataSize = pstUartParam->usSendDataSize;
	pstUartObj->usRecvDataSize = pstUartParam->usRecvDataSize;
	pstUartObj->usSendBytesCnt = pstUartParam->usSendBytesCnt;
	pstUartObj->usRecvBytesCnt = pstUartParam->usRecvBytesCnt;
	pstUartObj->stCfgParam.ucFifoCtrl = pstUartParam->stCfgParam.ucFifoCtrl;
	pstUartObj->stCfgParam.ucIntrCtrl = pstUartParam->stCfgParam.ucIntrCtrl;
	pstUartObj->stCfgParam.ucLineCtrl = pstUartParam->stCfgParam.ucLineCtrl;
	pstUartObj->stCfgParam.ucModemCtrl = pstUartParam->stCfgParam.ucModemCtrl;
	pstUartObj->stCfgParam.ucOscCtrl = pstUartParam->stCfgParam.ucOscCtrl;
	pstUartObj->stCfgParam.ucScratchCtrl = pstUartParam->stCfgParam.ucScratchCtrl;
	pstUartObj->stCfgParam.usBaudDiv = pstUartParam->stCfgParam.usBaudDiv;

	pstUartObj->stPlicCfgParam.ucIntrEnFlage = pstUartParam->stPlicCfgParam.ucIntrEnFlage;
	pstUartObj->stPlicCfgParam.ucPriority = pstUartParam->stPlicCfgParam.ucPriority;

	pstUartObj->pstCtrller = pstUartParam->pstCtrller;
}

/*****************************************************************
 * @brief  UART�豸�����Ĵ�������
 * @param  pstUartObj��UART�豸����
 * @retval ��
*****************************************************************/
void UartObjConfigInit(PST_UART_ATTR pstUartObj)
{
	assert_param(NULL != pstUartObj);
	assert_param(NULL != pstUartObj->pstCtrller);

	uint32_t ulUartEnVal= 0;
	ST_PLIC_REG_PARAM stUartRegParam = {0};

	//PLIC�ж�ʹ�ܺ�ע��
	ulUartEnVal = DevIntrEnTableGet(pstUartObj->usDevId);
	stUartRegParam.usIntrId = DevIntrIdTableGet(pstUartObj->usDevId);
	stUartRegParam.IntrHander = PlicUartHandle;
	stUartRegParam.ptrBackCall = pstUartObj;
	if (pstUartObj->stPlicCfgParam.ucIntrEnFlage)
	{
		//intr Priority set
		IntrPrioritySet(pstUartObj->usDevId, pstUartObj->stPlicCfgParam.ucPriority);
        //intr handle register
		PlicIntrHandleRegister(&stUartRegParam, pstUartObj->usDevId);
		//intr handle enable
		PlicEnableSet(ulUartEnVal);
	}

	//����������
	UartBaudDivCfg(pstUartObj);
	//FIFO����
	UartFifoCfg(pstUartObj);
	//����������
	UartOscCfg(pstUartObj);
	//������ģʽ����
	UartModemCtrlCfg(pstUartObj);
	UartScratchCfg(pstUartObj);
	//���䷽ʽ����
	UartTranModeCfg(pstUartObj);
	//�����ж�����
	UartIntrCfg(pstUartObj);
}


/*****************************************************************
 * @brief  UART�豸��Ƶ��������ʹ��
 * @param  pstUartObj��UART�豸����
 * @retval ��
*****************************************************************/
void UartDivAccessSet(PST_UART_ATTR pstUartObj)
{
	assert_param(NULL != pstUartObj);
	assert_param(NULL != pstUartObj->pstCtrller);

	PST_UART_RegDef pstUartCtrller = pstUartObj->pstCtrller;
	uint8_t  ucLineState = 0;
	ucLineState = pstUartCtrller->LCR;
	ucLineState = ucLineState | UART_LINE_CFG_DLAB;
	pstUartCtrller->LCR = ucLineState;
}

/*****************************************************************
 * @brief  UART�豸��Ƶ�������ʽ�ֹ
 * @param  pstUartObj��UART�豸����
 * @retval ��
*****************************************************************/
void UartDivAccessClear(PST_UART_ATTR pstUartObj)
{
	assert_param(NULL != pstUartObj);
	assert_param(NULL != pstUartObj->pstCtrller);

	PST_UART_RegDef pstUartCtrller = pstUartObj->pstCtrller;
	uint8_t  ucLineState = 0;
	ucLineState = pstUartCtrller->LCR;
	ucLineState = ucLineState & (~UART_LINE_CFG_DLAB);
	pstUartCtrller->LCR = ucLineState;
}

/*****************************************************************
 * @brief  UART�����ʷ�Ƶ����
 * @param  pstUartObj��UART�豸����
 * @retval ��
*****************************************************************/
void UartBaudDivCfg(PST_UART_ATTR pstUartObj)
{
	assert_param(NULL != pstUartObj);
	assert_param(NULL != pstUartObj->pstCtrller);

	PST_UART_RegDef pstUartCtrller = pstUartObj->pstCtrller;
	uint16_t usBaudDiv = pstUartObj->stCfgParam.usBaudDiv;

	UartDivAccessSet(pstUartObj);
	pstUartCtrller->DLL = (usBaudDiv >> 0) & 0xff;
	pstUartCtrller->DLM = (usBaudDiv >> 8) & 0xff;
	UartDivAccessClear(pstUartObj);
}


/*****************************************************************
 * @brief  �����ʷ�Ƶ��ȡ
 * @param  pstUartObj��UART�豸����
 * @retval uint16_t�����ز����ʷ�Ƶ����
*****************************************************************/
uint16_t UartBaudDivGet(PST_UART_ATTR pstUartObj)
{
	assert_param(NULL != pstUartObj);
	assert_param(NULL != pstUartObj->pstCtrller);

	PST_UART_RegDef pstUartCtrller = pstUartObj->pstCtrller;
	uint16_t  usBaudRate = 0;

	UartDivAccessSet(pstUartObj);
	usBaudRate = ((pstUartCtrller->DLM) << 8) | pstUartCtrller->DLL;
	UartDivAccessClear(pstUartObj);

	return usBaudRate;
}


/*****************************************************************
 * @brief  UART���ݴ��䷽ʽ����
 * @param  pstUartObj��UART�豸����
 * @retval ��
*****************************************************************/
void UartTranModeCfg(PST_UART_ATTR pstUartObj)
{
	assert_param(NULL != pstUartObj);
	assert_param(NULL != pstUartObj->pstCtrller);

	PST_UART_RegDef pstUartCtrller = pstUartObj->pstCtrller;
	pstUartCtrller->LCR = pstUartObj->stCfgParam.ucLineCtrl;
}

/*****************************************************************
 * @brief  UART���䷽ʽ��ȡ
 * @param  pstUartObj��UART�豸����
 * @retval uint8_t�����ش��䷽ʽ���ò���
*****************************************************************/
uint8_t UartTranModeGet(PST_UART_ATTR pstUartObj)
{
	assert_param(NULL != pstUartObj);
	assert_param(NULL != pstUartObj->pstCtrller);

	PST_UART_RegDef pstUartCtrller = pstUartObj->pstCtrller;
    return pstUartCtrller->LCR;
}

/*****************************************************************
 * @brief  UART FIFO����
 * @param  pstUartObj��UART�豸����
 * @retval ��
*****************************************************************/
void UartFifoCfg(PST_UART_ATTR pstUartObj)
{
	assert_param(NULL != pstUartObj);
	assert_param(NULL != pstUartObj->pstCtrller);

	PST_UART_RegDef pstUartCtrller = pstUartObj->pstCtrller;
	pstUartCtrller->FCR = pstUartObj->stCfgParam.ucFifoCtrl;
}

/*****************************************************************
 * @brief  UART FIFO��Ȼ�ȡ
 * @param  pstUartObj��UART�豸����
 * @retval uint8_t:����FIFO���
*****************************************************************/
uint8_t UartFifoDepthGet(PST_UART_ATTR pstUartObj)
{
	assert_param(NULL != pstUartObj);
	assert_param(NULL != pstUartObj->pstCtrller);

	return pstUartObj->pstCtrller->CFG;
}

/*****************************************************************
 * @brief  UART FIFOʹ��״̬��ȡ
 * @param  pstUartObj��UART�豸����
 * @retval uint8_t:����FIFOʹ��״̬
*****************************************************************/
uint8_t UartFifoEnStateGet(PST_UART_ATTR pstUartObj)
{
	assert_param(NULL != pstUartObj);
	assert_param(NULL != pstUartObj->pstCtrller);

	return (pstUartObj->pstCtrller->FCR) >> UART_RFIFO_TRIG_LEV_SHIFT;
}

/*****************************************************************
 * @brief  UART ������������ȡ
 * @param  pstUartObj��UART�豸����
 * @retval uint8_t:���ع��������ò���
*****************************************************************/
uint8_t UartOscGet(PST_UART_ATTR pstUartObj)
{
	assert_param(NULL != pstUartObj);
	assert_param(NULL != pstUartObj->pstCtrller);

	return pstUartObj->pstCtrller->OSCR;
}

/*****************************************************************
 * @brief  UART��������������
 * @param  pstUartObj��UART�豸����
 * @retval ��
*****************************************************************/
void UartOscCfg(PST_UART_ATTR pstUartObj)
{
	assert_param(NULL != pstUartObj);
	assert_param(NULL != pstUartObj->pstCtrller);

	PST_UART_RegDef pstUartCtrller = pstUartObj->pstCtrller;
	pstUartCtrller->OSCR = pstUartObj->stCfgParam.ucOscCtrl;
}

/*****************************************************************
 * @brief  UART LSR״̬���ݻ�ȡ
 * @param  pstUartObj��UART�豸����
 * @retval uint8_t������LSR״̬����
*****************************************************************/
uint8_t UartLineStatusGet(PST_UART_ATTR pstUartObj)
{
	assert_param(NULL != pstUartObj);
	assert_param(NULL != pstUartObj->pstCtrller);

	PST_UART_RegDef pstUartCtrller = pstUartObj->pstCtrller;
	return pstUartCtrller->LSR;
}

/*****************************************************************
 * @brief  UART modem����
 * @param  pstUartObj��UART�豸����
 * @retval ��
*****************************************************************/
void UartModemCtrlCfg(PST_UART_ATTR pstUartObj)
{
	assert_param(NULL != pstUartObj);
	assert_param(NULL != pstUartObj->pstCtrller);

	pstUartObj->pstCtrller->MCR = pstUartObj->stCfgParam.ucModemCtrl;
}

/*****************************************************************
 * @brief  UART modem���ò�����ȡ
 * @param  pstUartObj��UART�豸����
 * @retval uint8_t������modem���ò���
*****************************************************************/
uint8_t UartModemCtrlParamGet(PST_UART_ATTR pstUartObj)
{
	assert_param(NULL != pstUartObj);
	assert_param(NULL != pstUartObj->pstCtrller);

	PST_UART_RegDef pstUartCtrller = pstUartObj->pstCtrller;
	return pstUartCtrller->MCR;
}

/*****************************************************************
 * @brief  UART modem״̬������ȡ
 * @param  pstUartObj��UART�豸����
 * @retval uint8_t������modem״̬����
*****************************************************************/
uint8_t UartModemStatusGet(PST_UART_ATTR pstUartObj)
{
	assert_param(NULL != pstUartObj);
	assert_param(NULL != pstUartObj->pstCtrller);

	PST_UART_RegDef pstUartCtrller = pstUartObj->pstCtrller;
	return pstUartCtrller->MSR;
}

/*****************************************************************
 * @brief  Uart Scratch ��������
 * @param  pstUartObj��UART�豸����
 * @retval ��
*****************************************************************/
void UartScratchCfg(PST_UART_ATTR pstUartObj)
{
	assert_param(NULL != pstUartObj);
	assert_param(NULL != pstUartObj->pstCtrller);

	PST_UART_RegDef pstUartCtrller = pstUartObj->pstCtrller;
	pstUartCtrller->SCR = pstUartObj->stCfgParam.ucScratchCtrl;
}

/*****************************************************************
 * @brief  Uart Scratch���ò�����ȡ
 * @param  pstUartObj��UART�豸����
 * @retval uint8_t������Scratch���ò���
*****************************************************************/
uint8_t UartScratchGet(PST_UART_ATTR pstUartObj)
{
	assert_param(NULL != pstUartObj);
	assert_param(NULL != pstUartObj->pstCtrller);

	PST_UART_RegDef pstUartCtrller = pstUartObj->pstCtrller;
	return pstUartCtrller->SCR;
}

/*****************************************************************
 * @brief  UART�ֽڷ���
 * @param  pstUartObj��UART�豸����
 * @retval ��
*****************************************************************/
void UartByteSend(PST_UART_ATTR pstUartObj, const uint8_t ucSendData)
{
	assert_param(NULL != pstUartObj);
	assert_param(NULL != pstUartObj->pstCtrller);

	PST_UART_RegDef pstUartCtrller = pstUartObj->pstCtrller;
	uint8_t ucLsrState = 0;

	while (1)
	{
		ucLsrState = UartLineStatusGet(pstUartObj);
		if ((ucLsrState & UART_LINE_STATE_THRE) == UART_LINE_STATE_THRE)
		{
			pstUartCtrller->THR = ucSendData;
			break;
		}
	}
}

/*****************************************************************
 * @brief  UART�ֽڽ���
 * @param  pstUartObj��UART�豸����
 * @retval uint8_t�����ؽ��յ�����
*****************************************************************/
uint8_t UartByteRecv(PST_UART_ATTR pstUartObj)
{
	assert_param(NULL != pstUartObj);
	assert_param(NULL != pstUartObj->pstCtrller);

	PST_UART_RegDef pstUartCtrller = pstUartObj->pstCtrller;
	uint8_t ucLsrState = 0;
	uint8_t ucRecvData = 0;

	while (1)
	{
		ucLsrState = UartLineStatusGet(pstUartObj);
		if ((ucLsrState & UART_LINE_STATE_DR) == UART_LINE_STATE_DR)
		{
			ucRecvData = pstUartCtrller->RBR;
			break;
		}
	}
	return ucRecvData;
}

/*****************************************************************
 * @brief  UART BUFF����
 * @param  pstUartObj��UART�豸����
 * @retval ��
*****************************************************************/
void UartBuffSend(PST_UART_ATTR pstUartObj)
{
	assert_param(NULL != pstUartObj);
	assert_param(NULL != pstUartObj->pstCtrller);
	assert_param(NULL != pstUartObj->pucSendBuf);

	uint8_t ucLineState = 0;
	uint8_t ucCount = 0;
	uint8_t ucFifoEnable = UartFifoEnStateGet(pstUartObj);
	uint8_t ucFifoDepth = UartFifoDepthGet(pstUartObj);
	uint8_t* pucSendBuf = pstUartObj->pucSendBuf;

    while (1)
    {
    	ucLineState =  UartLineStatusGet(pstUartObj);
    	if (pstUartObj->usSendBytesCnt < pstUartObj->usSendDataSize)
    	{
    	    if ((ucLineState & UART_LINE_STATE_THRE) == UART_LINE_STATE_THRE)
    	    {
    	    	if (ucFifoEnable == UART_FIFO_STATE_EN)
    	    	{
            		for (ucCount = 0; ucCount < ucFifoDepth; ucFifoDepth++)
            		{
            			pstUartObj->pstCtrller->THR = *pucSendBuf;
            			pucSendBuf = pucSendBuf + 1;
            			pstUartObj->usSendBytesCnt++;
            		}
    	    	}
    	    	else
    	    	{
    	    		pstUartObj->pstCtrller->THR = *pucSendBuf;
    	    		pucSendBuf = pucSendBuf + 1;
    	    		pstUartObj->usSendBytesCnt++;
    	    	}
    	    }
    	}
    	else
    	{
    		break;
    	}
    }
}


/*****************************************************************
 * @brief  UART �ַ�������
 * @param  pstUartObj��UART�豸����, pucSendBuf������Ŀ������
 * @retval ��
*****************************************************************/
uint32_t UartStringSend(PST_UART_ATTR pstUartObj, uint8_t* pucSendBuf)
{
	assert_param(NULL != pstUartObj);
	assert_param(NULL != pstUartObj->pstCtrller);
	assert_param(NULL != pucSendBuf);

	uint32_t ulRetLen = 0;

	while (*pucSendBuf != 0)
	{
		UartByteSend(pstUartObj, *pucSendBuf);
		 pucSendBuf++;
		 ulRetLen++;
	}
	return ulRetLen;
}

/*****************************************************************
 * @brief  UART BUFF����
 * @param  pstUartObj��UART�豸����
 * @retval ��
*****************************************************************/
void UartBuffRecv(PST_UART_ATTR pstUartObj)
{
	assert_param(NULL != pstUartObj);
	assert_param(NULL != pstUartObj->pstCtrller);
	assert_param(NULL != pstUartObj->pucRecvBuf);

	uint8_t ucLineState = 0;
	uint8_t* pucRecvBuf = pstUartObj->pucRecvBuf;

    while (1)
    {
    	ucLineState =  UartLineStatusGet(pstUartObj);
    	if (pstUartObj->usRecvBytesCnt < pstUartObj->usRecvDataSize)
    	{
    	    if ((ucLineState & UART_LINE_STATE_DR) == UART_LINE_STATE_DR)
    	    {
    	    	*pucRecvBuf = pstUartObj->pstCtrller->RBR;
    	    	pucRecvBuf++;
    	    	pstUartObj->usRecvBytesCnt++;
    	    }
    	}
    	else
    	{
    		break;
    	}
    }
}

/*****************************************************************
 * @brief  UART�ж�����
 * @param  pstUartObj��UART�豸����
 * @retval ��
*****************************************************************/
void UartIntrCfg(PST_UART_ATTR pstUartObj)
{
	assert_param(NULL != pstUartObj);
	assert_param(NULL != pstUartObj->pstCtrller);

	PST_UART_RegDef pstUartCtrller = pstUartObj->pstCtrller;
	pstUartCtrller->IER = pstUartObj->stCfgParam.ucIntrCtrl;
}

/*****************************************************************
 * @brief  UART�ж�ʹ��״̬��ȡ
 * @param  pstUartObj��UART�豸����
 * @retval uint8_t�������ж�ʹ�ܲ���
*****************************************************************/
uint8_t UartIntrEnStateGet(PST_UART_ATTR pstUartObj)
{
	assert_param(NULL != pstUartObj);
    assert_param(NULL != pstUartObj->pstCtrller);

    PST_UART_RegDef pstUartCtrller = pstUartObj->pstCtrller;
    return pstUartCtrller->IER;
}


/*****************************************************************
 * @brief  UART�ж�ID��ȡ
 * @param  pstUartObj��UART�豸����
 * @retval �����ж�ID
*****************************************************************/
uint8_t UartIntrIDGet(PST_UART_ATTR pstUartObj)
{
	assert_param(NULL != pstUartObj);
    assert_param(NULL != pstUartObj->pstCtrller);

    PST_UART_RegDef pstUartCtrller = pstUartObj->pstCtrller;
    return (pstUartCtrller->IIR & 0x0F);
}



/*****************************************************************
 * @brief  UART �ж�ִ�нӿ�
 * @param  ptrBackCall:�ص�����
 * @retval ��
*****************************************************************/
void PlicUartHandle(void * ptrBackCall)
{
	uint8_t ucIntrId = 0;
	PST_UART_ATTR ptrUartObj = NULL;
	if (NULL != ptrBackCall)
	{
		ptrUartObj = (PST_UART_ATTR)ptrBackCall;
		//��ȡ�ж�״̬
		ucIntrId = UartIntrIDGet(ptrUartObj);
		//ִ���жϽӿ��ж�
	    UartIntrDispatch(ptrUartObj, ucIntrId);


	}
}


/*****************************************************************
 * @brief  UART�жϵ��Ƚӿ�
 * @param  pstUartObj��UART�豸���� ucDispatch�����Ȳ���
 * @retval ��
 *****************************************************************/
void UartIntrDispatch(PST_UART_ATTR pstUartObj, int8_t ucDispatch)
{
	switch (ucDispatch)
	{
	    case UART_INTR_ID_RLS:
	    {
	    	UartIntrRecvErr(pstUartObj);
	    	break;
	    }
	    case UART_INTR_ID_RDA:						// read data available
	    {
	    	UartIntrRecvExc(pstUartObj);
	    	break;
	    }
	    case UART_INTR_ID_RCT:
	    {
	    	UartIntrRecvTimeOut(pstUartObj);
	    	break;
	    }
	    case UART_INTR_ID_THRE:
	    {
	    	UartIntrSendExc(pstUartObj);
	    	break;
	    }
	    case UART_INTR_ID_MS:
	    {
	    	UartIntrModemExc(pstUartObj);
	    	break;
	    }
	    default:
	    	break;
	}
}

/*****************************************************************
 * @brief  UART�жϽ��մ���
 * @param  pstUartObj��UART����������
 * @retval ��
 * ע�⣺�ýӿ�Ԥ����ֻ��Ϊ���Դ���
 *****************************************************************/
void UartIntrRecvErr(PST_UART_ATTR pstUartObj)
{
	UartLineStatusGet(pstUartObj);
}




extern uint8_t* imgAddr;
extern uint8_t* imgAddrRd;
extern uint8_t wr_flag;
extern uint8_t rd_flag;

/*****************************************************************
 * @brief  UART�жϽ���
 * @param  pstUartObj��UART����������
 * @retval ��
 *****************************************************************/
void UartIntrRecvExc(PST_UART_ATTR pstUartObj)
{
	assert_param(NULL != pstUartObj);
	assert_param(NULL != pstUartObj->pstCtrller);
	assert_param(NULL != pstUartObj->pucRecvBuf);

	uint8_t ucLineState = 0;
	uint8_t* pucRecvBuf = pstUartObj->pucRecvBuf;

	ucLineState =  UartLineStatusGet(pstUartObj);

	if ((ucLineState & UART_LINE_STATE_DR) == UART_LINE_STATE_DR)
	{
		if(!wr_flag && !rd_flag){
			if (pstUartObj->usRecvBytesCnt < pstUartObj->usRecvDataSize)
			{
			    pucRecvBuf[pstUartObj->usRecvBytesCnt] = pstUartObj->pstCtrller->RBR;
			    printf("received data: %d\r", pucRecvBuf[pstUartObj->usRecvBytesCnt]);
			    pstUartObj->usRecvBytesCnt++;
			}
			else
			{
				pstUartObj->pstCtrller->RBR;
			}
		}
		else{
			if(wr_flag){
			    uint8_t data = pstUartObj->pstCtrller->RBR;
			    printf("[WRITE] imgAddr: %d, data: %d\n", imgAddr, data);
			    WriteReg8(imgAddr, data);
			    imgAddr++;

			    if(imgAddr >= (uint8_t*)IMG_ADDR_RX + IMG_SIZE){
			    	wr_flag = 0;
			    	imgAddr = (uint8_t*)IMG_ADDR_RX;
			    }
			}

			else if (rd_flag){
				for(int i=0; i<IMG_SIZE; i++){
				    uint8_t data = ReadReg8(imgAddrRd);
				    printf("[READ] imgAddrRd: %d, data: %d\n", imgAddrRd, data);
				    imgAddrRd++;
				}
				rd_flag = 0;
				imgAddrRd = (uint8_t*)IMG_ADDR_RX;
			}
		}
	}

}

/*****************************************************************
 * @brief  UART�жϽ��ճ�ʱ
 * @param  pstUartObj��UART����������
 * @retval ��
 * ע�⣺�ýӿ�Ԥ����ֻ��Ϊ���Դ���
 *****************************************************************/
void UartIntrRecvTimeOut(PST_UART_ATTR pstUartObj)
{
	assert_param(NULL != pstUartObj);
	assert_param(NULL != pstUartObj->pstCtrller);
	pstUartObj->pstCtrller->RBR;
}

/*****************************************************************
 * @brief  UART�жϷ���
 * @param  pstUartObj��UART����������
 * @retval ��
 * ע�⣺�ýӿ�Ԥ����ֻ��Ϊ���Դ���
 *****************************************************************/
void UartIntrSendExc(PST_UART_ATTR pstUartObj)
{
	UartIntrIDGet(pstUartObj);
}

/*****************************************************************
 * @brief  UART  modem�жϴ���ӿ�
 * @param  pstUartObj��UART����������
 * @retval ��
 * ע�⣺�ýӿ�Ԥ����ֻ��Ϊ���Դ���
 *****************************************************************/
void UartIntrModemExc(PST_UART_ATTR pstUartObj)
{
	UartModemStatusGet(pstUartObj);
}





