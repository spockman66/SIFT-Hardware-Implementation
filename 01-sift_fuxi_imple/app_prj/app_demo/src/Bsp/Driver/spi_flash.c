/*
 * spi_flash.c
 *
 *  Created on: 2021��11��11��
 *      Author: Administrator
 */


#include "spi_flash.h"

#define SPIT_LONG_TIMEOUT        (1000)

static void SpiFlashWriteEnable(PST_SPI_ATTR pstSpiObj);
static uint8_t SpiFlashStateGet(PST_SPI_ATTR pstSpiObj);
static void SpiFlashPageWrite(PST_SPI_ATTR pstSpiObj, uint32_t ulWriteAddr);
static void SpiFlashPageRead(PST_SPI_ATTR pstSpiObj, uint32_t ulReadAddr);


/*****************************************************************
 * @brief  SPI Flash��ʼ��
 * @param  pstSpiObj��SPI�豸����
 * @retval ��
*****************************************************************/
void SpiFlashInit(PST_SPI_ATTR pstSpiObj)
{
	assert_param(NULL != pstSpiObj);
	SpiStructDeInit(pstSpiObj);
	SpiObjConfigInit(pstSpiObj);
	pstSpiObj->stCfgParam.ucSlaveScl = SPI_SLAVE_SCL_BIT0;
}

/*****************************************************************
 * @brief  Flashдʹ������
 * @param  pstSpiObj��SPI�豸����
 * @retval ��
*****************************************************************/
void SpiFlashWriteEnable(PST_SPI_ATTR pstSpiObj)
{
	assert_param(NULL != pstSpiObj);
	assert_param(NULL != pstSpiObj->pstCtrller);

	uint8_t FLASH_Status = 0;
	uint8_t aucSendData[1] = {CMD_GD25_WRITE_EN};
	uint8_t aucRevData[1]  = {0};

	pstSpiObj->pucSendBuf = aucSendData;
	pstSpiObj->pucRecvBuf = aucRevData;
	pstSpiObj->ulTranBytesSize = 1;
	pstSpiObj->ulTranBytesCnt = 0;

	SpiHanderRequest(pstSpiObj);

	while (1)
	{
		FLASH_Status = SpiFlashStateGet(pstSpiObj);
		if ((FLASH_Status & FLASH_WEL_STATUS) == FLASH_WEL_STATUS)
		{
			break;
		}
	}
}


/*****************************************************************
 * @brief  Flash����״̬��ȡ
 * @param  pstSpiObj��SPI�豸����
 * @retval uint8_t������SPI�Ĺ���״̬
*****************************************************************/
uint8_t SpiFlashStateGet(PST_SPI_ATTR pstSpiObj)
{
	assert_param(NULL != pstSpiObj);
	assert_param(NULL != pstSpiObj->pstCtrller);

	uint8_t FLASH_Status = 0;
	uint8_t aucSendData[4] = {CMD_GD25_READ_STATUS, Dummy_Byte, Dummy_Byte, Dummy_Byte};
	uint8_t aucRevData[4]  = {0};
	pstSpiObj->pucSendBuf = aucSendData;
	pstSpiObj->pucRecvBuf = aucRevData;
	pstSpiObj->ulTranBytesSize = 4;
	pstSpiObj->ulTranBytesCnt = 0;
	SpiHanderRequest(pstSpiObj);
    FLASH_Status = aucRevData[3];
    return FLASH_Status;
}

/*****************************************************************
 * @brief  Flash��������
 * @param  pstSpiObj��SPI�豸���� ulSectorAddr��SPI������ַ
 * @retval ��
*****************************************************************/
void SpiFlashSectorErase(PST_SPI_ATTR pstSpiObj, uint32_t ulSectorAddr)
{
	assert_param(NULL != pstSpiObj);
	assert_param(NULL != pstSpiObj->pstCtrller);

	uint8_t FLASH_Status = 0;
	uint8_t aucSendData[4] = {0};
	uint8_t aucRevData[4]  = {0};
	aucSendData[0] = CMD_GD25_SECTOR_ERASE;
	aucSendData[1] = (ulSectorAddr & 0xFF0000) >> 16;
	aucSendData[2] = (ulSectorAddr & 0xFF00) >> 8;
	aucSendData[3] = ulSectorAddr & 0xFF;

	SpiFlashWriteEnable(pstSpiObj);

	pstSpiObj->pucSendBuf = aucSendData;
	pstSpiObj->pucRecvBuf = aucRevData;
	pstSpiObj->ulTranBytesSize = 4;
	pstSpiObj->ulTranBytesCnt = 0;

	SpiHanderRequest(pstSpiObj);

    while (1)
	{
		FLASH_Status = SpiFlashStateGet(pstSpiObj);
		if ((FLASH_Status & FLASH_WIP_STATUS) == 0)
		{
			break;
		}
	}
}

/*****************************************************************
 * @brief  Flash�����
 * @param  pstSpiObj��SPI�豸����ulBlockAddr�����ַ��
 *         enEraseType����������
 * @retval ��
*****************************************************************/
void SpiFlashBlockErase(PST_SPI_ATTR pstSpiObj, uint32_t ulBlockAddr, EN_BLOCK_TYPE enEraseType)
{
	assert_param(NULL != pstSpiObj);
	assert_param(NULL != pstSpiObj->pstCtrller);

	uint8_t FLASH_Status = 0;
	uint8_t aucSendData[4] = {0};
	uint8_t aucRevData[4]  = {0};

	if (enEraseType == EN_BLOCK_TYPE_32K)
	{
		aucSendData[0] = CMD_GD25_BLOCK_ERASE_32K;
	}
	else
	{
		aucSendData[0] = CMD_GD25_BLOCK_ERASE_64K;
	}
	aucSendData[1] = (ulBlockAddr & 0xFF0000) >> 16;
	aucSendData[2] = (ulBlockAddr & 0xFF00) >> 8;
	aucSendData[3] = ulBlockAddr & 0xFF;

	SpiFlashWriteEnable(pstSpiObj);

	pstSpiObj->pucSendBuf = aucSendData;
	pstSpiObj->pucRecvBuf = aucRevData;
	pstSpiObj->ulTranBytesSize = 4;
	pstSpiObj->ulTranBytesCnt = 0;

	SpiHanderRequest(pstSpiObj);

     while (1)
	{
		FLASH_Status = SpiFlashStateGet(pstSpiObj);
		if ((FLASH_Status & FLASH_WIP_STATUS) == 0)
		{
			break;
		}
	}
}

/*****************************************************************
 * @brief  Flash��Ƭ����
 * @param  pstSpiObj��SPI�豸����
 * @retval ��
*****************************************************************/
void SpiFlashChipErase(PST_SPI_ATTR pstSpiObj)
{
	assert_param(NULL != pstSpiObj);
	assert_param(NULL != pstSpiObj->pstCtrller);

	uint8_t FLASH_Status = 0;
	uint8_t aucSendData[1] = {CMD_GD25_CHIP_ERASE};
	uint8_t aucRevData[1]  = {0};

	SpiFlashWriteEnable(pstSpiObj);

	pstSpiObj->pucSendBuf = aucSendData;
	pstSpiObj->pucRecvBuf = aucRevData;
	pstSpiObj->ulTranBytesSize = 1;
	pstSpiObj->ulTranBytesCnt = 0;

	SpiHanderRequest(pstSpiObj);

     while (1)
	{
		FLASH_Status = SpiFlashStateGet(pstSpiObj);
		if ((FLASH_Status & FLASH_WIP_STATUS) == 0)
		{
			break;
		}
	}
}

/*****************************************************************
 * @brief  Flashҳд
 * @param  pstSpiObj��SPI�豸����ulWriteAddr��д��ַ
 * @retval ��
*****************************************************************/
void SpiFlashPageWrite(PST_SPI_ATTR pstSpiObj, uint32_t ulWriteAddr)
{
	assert_param(NULL != pstSpiObj);
	assert_param(NULL != pstSpiObj->pstCtrller);
	assert_param(NULL != pstSpiObj->pucSendBuf);

	uint8_t FLASH_Status = 0;
	uint16_t usCount = 0;
	uint16_t usNumBytes = pstSpiObj->ulTranBytesSize;
	uint8_t aucSendData[300] = {0};
	uint8_t aucRevData[300]  = {0};
    aucSendData[0] = CMD_GD25_PAGE_PROGRAM;
    aucSendData[1] = (ulWriteAddr & 0xFF0000) >> 16;
	aucSendData[2] = (ulWriteAddr & 0xFF00) >> 8;
	aucSendData[3] = ulWriteAddr & 0xFF;


	if(usNumBytes > FLASH_PAGE_SIZE)
    {
       usNumBytes = FLASH_PAGE_SIZE;
    }

	for (usCount = 0; usCount < usNumBytes; usCount++)
	{
		aucSendData[usCount + 4] = (pstSpiObj->pucSendBuf)[usCount];
	}

	SpiFlashWriteEnable(pstSpiObj);

	pstSpiObj->pucSendBuf = aucSendData;
	pstSpiObj->pucRecvBuf = aucRevData;
	pstSpiObj->ulTranBytesSize = usNumBytes + 4;
	pstSpiObj->ulTranBytesCnt = 0;

	SpiHanderRequest(pstSpiObj);

    while (1)
	{
		FLASH_Status = SpiFlashStateGet(pstSpiObj);
		if ((FLASH_Status & FLASH_WIP_STATUS) == 0)
		{
			break;
		}
	}
}

/*****************************************************************
 * @brief  Flashҳ��
 * @param  pstSpiObj��SPI�豸����ulReadAddr������ַ
 * @retval ��
*****************************************************************/
void SpiFlashPageRead(PST_SPI_ATTR pstSpiObj, uint32_t ulReadAddr)
{
	assert_param(NULL != pstSpiObj);
	assert_param(NULL != pstSpiObj->pstCtrller);
	assert_param(NULL != pstSpiObj->pucRecvBuf);

	uint16_t usCount = 0;
	uint16_t usNumBytes = pstSpiObj->ulTranBytesSize;
	uint8_t* pucTemRecvBuf = pstSpiObj->pucRecvBuf;
	uint8_t aucSendData[300] = {0};
	uint8_t aucRevData[300]  = {0};
    aucSendData[0] = CMD_GD25_READ_DATA;
    aucSendData[1] = (ulReadAddr & 0xFF0000) >> 16;
	aucSendData[2] = (ulReadAddr & 0xFF00) >> 8;
	aucSendData[3] = ulReadAddr & 0xFF;

	if(usNumBytes > FLASH_PAGE_SIZE)
    {
       usNumBytes = FLASH_PAGE_SIZE;
    }

	for (usCount = 0; usCount < usNumBytes; usCount++)
	{
		aucSendData[usCount + 4] = Dummy_Byte;
	}

	pstSpiObj->pucSendBuf = aucSendData;
	pstSpiObj->pucRecvBuf = aucRevData;
	pstSpiObj->ulTranBytesSize = usNumBytes + 4;
	pstSpiObj->ulTranBytesCnt = 0;

	SpiHanderRequest(pstSpiObj);

	for (usCount = 0; usCount < usNumBytes; usCount++)
	{
		pucTemRecvBuf[usCount] = aucRevData[usCount + 4];
	}

	pstSpiObj->pucRecvBuf = pucTemRecvBuf;
}


/*****************************************************************
 * @brief  Flash Bufferд
 * @param  pstSpiObj��SPI�豸���� ulWriteAddr:д��ַ
 * @retval ��
*****************************************************************/
void SpiFlashBufferWrite(PST_SPI_ATTR pstSpiObj, uint32_t ulWriteAddr)
{
	assert_param(NULL != pstSpiObj);
	assert_param(NULL != pstSpiObj->pstCtrller);
	assert_param(NULL != pstSpiObj->pucSendBuf);

	uint8_t  ucCount    =0;
	uint16_t usNumPages = 0;
	uint16_t usResBytes = 0;
	uint32_t ulTemWriteAddr = ulWriteAddr;
	uint16_t usNumBytes = pstSpiObj->ulTranBytesSize;
	uint8_t* pucTemBuffer = pstSpiObj->pucSendBuf;

	usNumPages = usNumBytes / FLASH_PAGE_SIZE;
	usResBytes = usNumBytes % FLASH_PAGE_SIZE;

	for (ucCount = 0; ucCount < usNumPages; ucCount++)
	{
		pstSpiObj->ulTranBytesSize = FLASH_PAGE_SIZE;
		pstSpiObj->pucSendBuf = pucTemBuffer;
		pstSpiObj->ulTranBytesCnt = 0;
		SpiFlashPageWrite(pstSpiObj, ulTemWriteAddr);
		ulTemWriteAddr += FLASH_PAGE_SIZE;
		pucTemBuffer   += FLASH_PAGE_SIZE;
	}

	pstSpiObj->ulTranBytesSize = usResBytes;
	pstSpiObj->pucSendBuf = pucTemBuffer;
	pstSpiObj->ulTranBytesCnt = 0;

	SpiFlashPageWrite(pstSpiObj, ulTemWriteAddr);
}

/*****************************************************************
 * @brief  Flash Buffer��
 * @param  pstSpiObj��SPI�豸���� ulReadAddr������ַ
 * @retval ��
*****************************************************************/
void SpiFlashBufferRead(PST_SPI_ATTR pstSpiObj, uint32_t ulReadAddr)
{
	assert_param(NULL != pstSpiObj);
	assert_param(NULL != pstSpiObj->pstCtrller);
	assert_param(NULL != pstSpiObj->pucRecvBuf);

	uint8_t  ucCount    =0;
	uint16_t usNumPages = 0;
	uint16_t usResBytes = 0;
	uint32_t ulTemReadAddr = ulReadAddr;
	uint16_t usNumBytes = pstSpiObj->ulTranBytesSize;
	uint8_t* pucTemBuffer = pstSpiObj->pucRecvBuf;

	usNumPages = usNumBytes / FLASH_PAGE_SIZE;
	usResBytes = usNumBytes % FLASH_PAGE_SIZE;

	for (ucCount = 0; ucCount < usNumPages; ucCount++)
	{
		pstSpiObj->ulTranBytesSize = FLASH_PAGE_SIZE;
		pstSpiObj->pucRecvBuf = pucTemBuffer;
		pstSpiObj->ulTranBytesCnt = 0;
		SpiFlashPageRead(pstSpiObj, ulTemReadAddr);
		ulTemReadAddr += FLASH_PAGE_SIZE;
		pucTemBuffer   += FLASH_PAGE_SIZE;
	}

	pstSpiObj->ulTranBytesSize = usResBytes;
	pstSpiObj->pucRecvBuf = pucTemBuffer;
	pstSpiObj->ulTranBytesCnt = 0;
	SpiFlashPageRead(pstSpiObj, ulTemReadAddr);
}

/*****************************************************************
 * @brief  Flash �����ַ��
 * @param  pstSpiObj��SPI�豸���� ulReadAddr����ַ
 * @retval ��
*****************************************************************/
void SpiFlashRandomRead(PST_SPI_ATTR pstSpiObj, uint32_t ulReadAddr)
{
	assert_param(NULL != pstSpiObj);
	assert_param(NULL != pstSpiObj->pstCtrller);
	assert_param(NULL != pstSpiObj->pucRecvBuf);

    uint32_t ulSendCnt = 0;
    uint8_t  ucState = 0;

	uint32_t usNumBytes = pstSpiObj->ulTranBytesSize;
	PST_SPI_RegDef pstSpiCtrller = pstSpiObj->pstCtrller;
    uint8_t* pucRecvBuffer = pstSpiObj->pucRecvBuf;

    uint8_t  ucReadAddrH = (ulReadAddr & 0xFF0000) >> 16;
    uint8_t  ucReadAddrM = (ulReadAddr & 0xFF000) >> 8;
    uint8_t  ucReadAddrL = (ulReadAddr & 0xFF);

    pstSpiObj->stCfgParam.ucSsnPolarity = EN_POLARITY_TYPE_LOW;
    SpiSlaveCfg(pstSpiObj);
    while (ulSendCnt < usNumBytes)
    {
    	switch (ulSendCnt)
    	{
    	    case 0:
    	    {
    	    	pstSpiCtrller->SPDAT = (uint8_t)CMD_GD25_READ_DATA;
    	    	break;
    	    }
    	    case 1:
    	    {
    	    	pstSpiCtrller->SPDAT = ucReadAddrH;
    	    	break;
    	    }
    	    case 2:
    	    {
    	    	pstSpiCtrller->SPDAT = ucReadAddrM;
    	    	break;
    	    }
    	    case 3:
    	    {
    	    	pstSpiCtrller->SPDAT = ucReadAddrL;
    	    	break;
    	    }
    	    default :
    	    {
    	    	pstSpiCtrller->SPDAT =(uint8_t) Dummy_Byte;
    	    }
    	}
    	while (1)
    	{
    		ucState = (uint8_t)pstSpiCtrller->SPSTA;
    		if ((ucState & SPI_SPSTA_SPIF) == SPI_SPSTA_SPIF)
    		{
    			if (ulSendCnt >= 4)
    			{
    				*pucRecvBuffer = pstSpiCtrller->SPDAT;
    				pucRecvBuffer++;
    			}
    			else
    			{
    				pstSpiCtrller->SPDAT;
    			}
    			break;
    		}
    	}
    	ulSendCnt++;
    }
    pstSpiObj->stCfgParam.ucSsnPolarity = EN_POLARITY_TYPE_HIGH;
    SpiSlaveCfg(pstSpiObj);
}

/*****************************************************************
 * @brief  Flash ID��ȡ
 * @param  pstSpiObj��SPI�豸����
 * @retval ��
*****************************************************************/
uint32_t SpiFlashReadID(PST_SPI_ATTR pstSpiObj)
{
	assert_param(NULL != pstSpiObj);
	assert_param(NULL != pstSpiObj->pstCtrller);

	uint8_t   pucSendBuffer[4] = {0x9F, 0xFF, 0xFF, 0xFF};
	uint8_t   pucRevBuffer[4]  = {0};
	uint32_t  ulReadFlashId   = 0;

	pstSpiObj->pucSendBuf = pucSendBuffer;
	pstSpiObj->pucRecvBuf = pucRevBuffer;
	pstSpiObj->ulTranBytesSize = 4;
	pstSpiObj->ulTranBytesCnt = 0;

	SpiHanderRequest(pstSpiObj);

	ulReadFlashId = (pucRevBuffer[1] << 16) | (pucRevBuffer[2] << 8) | pucRevBuffer[3];
	return ulReadFlashId;
}
