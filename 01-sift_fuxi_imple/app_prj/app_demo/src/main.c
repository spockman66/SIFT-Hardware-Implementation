/*
 ============================================================================
 Name        : main.c
 Author      : 
 Version     :
 Copyright   : Your copyright notice
 Description : Hello RISC-V World in C
 ============================================================================
 */

#include <stdio.h>
#include <string.h>
#include "platform.h"

/* user add */
uint8_t* dataAddr = (uint8_t*)RSLT_ADDR_TX;

uint8_t* imgAddr = (uint8_t*)IMG_ADDR_RX;
uint8_t* imgAddrRd = (uint8_t*)IMG_ADDR_RX;
uint8_t wr_flag = 0;
uint8_t rd_flag = 0;

/*
 * Demonstrate how to print a greeting message on standard output
 * and exit.
 *
 * WARNING: This is a build-only project. Do not try to run it on a
 * physical board, since it lacks the device specific startup.
 */
ST_UART_ATTR  stUartObj;
ST_TIMER_ATTR stTimerObj;
ST_GPIO_ATTR  stGpioObj;
ST_SPI_ATTR   stSpiObj;
ST_I2C_ATTR   stI2cObj;

void MainTest(void);
void UartSendRecvTest(void);
void UartIntrTest(void);
void SpiFlashTest(void);
void EepromI2cTest(void);


/**********     GPIO Command function    ***********/
void load_image(){
	stGpioObj.stCfgParam.ulChannels = GPIO_Pin_1;

	// give a impulse to notify FPGA of loading image from ddr to ram
    GpioBitsDoutSet(&stGpioObj);
    DelayUs(5);
    GpioBitsDoutClear(&stGpioObj);
}

void soft_rstn(){
	stGpioObj.stCfgParam.ulChannels = GPIO_Pin_3;

	// give a impulse to notify FPGA of
    GpioBitsDoutSet(&stGpioObj);
    DelayUs(10);
    GpioBitsDoutClear(&stGpioObj);
}

int main(void)
{
//	MainTest();


	UartIntrTest();


}


void MainTest(void)
{
	UartStructDeInit(&stUartObj);
	UartObjConfigInit(&stUartObj);

	MachineTimerObjStructDeInit(&stTimerObj);
	MachineTimerObjConfigInit(&stTimerObj);

	GpioStructDeInit(&stGpioObj);
	GpioObjConfigInit(&stGpioObj);
    GpioBitsDoutSet(&stGpioObj);

	TrapInit();
	stGpioObj.stCfgParam.ulChannels = GPIO_Pin_0;

	while(1)
	{
		DelayMs (500);
	    GpioBitsDoutSet(&stGpioObj);
		DelayMs (500);
		GpioBitsDoutClear(&stGpioObj);

		printf("BSP_VERSION: %x!\n", BSP_VERSION);
	}
}


void UartSendRecvTest(void)
{
	UartStructDeInit(&stUartObj);
	UartObjConfigInit(&stUartObj);

	uint8_t aucSendBuf[256] = {0};
	uint8_t aucRecvBuf[256] = {0};
	stUartObj.usRecvDataSize = 16;
	stUartObj.usSendDataSize = 16;
	stUartObj.pucRecvBuf = aucRecvBuf;
	stUartObj.pucSendBuf = aucRecvBuf;
	while(1)
	{
		printf("请输入16个字节的字符数据\n\r");
		stUartObj.usRecvBytesCnt = 0;
		UartBuffRecv(&stUartObj);
		printf("接收到的数据：");
		fflush (stdout);
	    stUartObj.usSendBytesCnt = 0;
	    UartBuffSend(&stUartObj);
		printf("\nBSP_VERSION: %x!\n", BSP_VERSION);
	}

}


void UartIntrTest(void)
{
	uint32_t *pulSoftAddr = (uint32_t *)SOFT_INTR_BASE_ADDR;
	UartStructDeInit(&stUartObj);

	stUartObj.stCfgParam.ucIntrCtrl = UART_INTR_ERBI_EN;
	stUartObj.stPlicCfgParam.ucIntrEnFlage = ENABLE;

	UartObjConfigInit(&stUartObj);

	/* Initialize GPIO Structure */
	GpioStructDeInit(&stGpioObj);
	GpioObjConfigInit(&stGpioObj);
    GpioBitsDoutSet(&stGpioObj);


	MachineTimerObjStructDeInit(&stTimerObj);
	MachineTimerObjConfigInit(&stTimerObj);
	TrapInit();
	uint8_t aucCount = 0;
	uint8_t aucSendBuf[256] = {0};
	uint8_t aucRecvBuf[256] = {0};
	stUartObj.usRecvDataSize = 1;
	stUartObj.usRecvBytesCnt = 0;
	stUartObj.pucRecvBuf = aucRecvBuf;


	while(1)
	{
		if (!wr_flag && !rd_flag && stUartObj.usRecvBytesCnt == stUartObj.usRecvDataSize) 	//
		{
			switch(aucRecvBuf[0]){
			case 0xaa:
				wr_flag = 0;
				rd_flag = 0;
				printf("[Reset] wr flag: %d, rd flag: %d \r", wr_flag, rd_flag);
				break;
			case 0xbb:
				wr_flag = 1;
				rd_flag = 0;
				printf("\r wr flag: %d, rd flag: %d \r", wr_flag, rd_flag);
				break;
			case 0xcc:
				wr_flag = 0;
				rd_flag = 1;
				printf("\r wr flag: %d, rd flag: %d \r", wr_flag, rd_flag);
				break;
			case 0xdd:
				load_image();
				printf("\r load image  \r");
				break;
			case 0xee:
				soft_rstn();
				printf("\r soft reset! \r");
				break;
			default:
				wr_flag = 0;
				rd_flag = 0;
				break;
			}

			stUartObj.usRecvBytesCnt = 0;
//			for(int i=0;i<stUartObj.usRecvDataSize;i++){
//	            printf ("接收到的数据： %d\r", aucRecvBuf[i]);
//			}
			memset(aucRecvBuf, 0, stUartObj.usRecvDataSize);
		}
	}

}


void SpiFlashTest(void)
{
	uint32_t ulCount = 0;
	uint8_t aucRecvData[1024 * 20] = {0};
	uint32_t ulFlashId = 0;
	UartStructDeInit(&stUartObj);
	UartObjConfigInit(&stUartObj);
	SpiFlashInit(&stSpiObj);


	ulFlashId = SpiFlashReadID(&stSpiObj);
	printf ("Flash ID： %x \n", ulFlashId);

	stSpiObj.pucRecvBuf = aucRecvData;
	stSpiObj.ulTranBytesSize = 1024 * 15;
	stSpiObj.ulTranBytesCnt = 0;

	while(1)
	{
		stSpiObj.ulTranBytesCnt = 0;
		SpiFlashRandomRead(&stSpiObj, 0x600000);
		for (ulCount = 0; ulCount < 1024 * 15; ulCount++)
		{
			printf ("%02x", aucRecvData[ulCount]);
			if (((ulCount+1) % 4) == 0)
			{
				printf ("\n");
			}
		}

		for (ulCount = 0; ulCount < 1024 * 15; ulCount++)
		{
			aucRecvData[ulCount] = 0;
		}

		printf("\nBSP_VERSION: %x!\n", BSP_VERSION);
		DelayMs (2000);
	}
}

#define EEPRAM_DEV_ADDR     (0xA0)
#define RW_ADDR             (0)
void EepromI2cWrite();
void EepromI2cRead();

void WaitSiState()
{
	uint8_t ucSpconParam = 0;

	while(1)
	{
		ucSpconParam = I2cSpconGet(&stI2cObj);
		if ((ucSpconParam & I2C_CON_REG_SI) == I2C_CON_REG_SI)
		{
			break;
		}
	}
}


void EepromI2cTest(void)
{
	 uint8_t ucSpconParam = 0;

	 UartStructDeInit(&stUartObj);
	 UartObjConfigInit(&stUartObj);

	 I2cStructDeInit(&stI2cObj);
	 I2cObjConfigInit(&stI2cObj);

	 while (1)
	 {
		 EepromI2cWrite();
		 EepromI2cRead();
		 printf("\nBSP_VERSION: %x!\n", BSP_VERSION);
		 fflush (stdout);
		 DelayMs (1000);
	 }

}

void EepromI2cWrite()
{
	static uint8_t ucWriteData = 0x55;
	 uint8_t ucSpconParam = 0;
	 I2cGenerateStart(&stI2cObj);
	 WaitSiState();
	 ucSpconParam = I2cSpconGet(&stI2cObj);
	 ucSpconParam = ucSpconParam & (~I2C_CON_REG_STA);
     I2cSpconCfg(&stI2cObj, ucSpconParam);

	 I2cSend7bitAddress(&stI2cObj, EEPRAM_DEV_ADDR, EN_I2C_DIR_SEND);
	 ucSpconParam = I2cSpconGet(&stI2cObj);
	 ucSpconParam = ucSpconParam & (~I2C_CON_REG_SI);
	 I2cSpconCfg(&stI2cObj, ucSpconParam);
	 WaitSiState();

	 I2cSendData(&stI2cObj, 0x00);
	 ucSpconParam = I2cSpconGet(&stI2cObj);
	 ucSpconParam = ucSpconParam & (~I2C_CON_REG_SI);
	 I2cSpconCfg(&stI2cObj, ucSpconParam);
	 WaitSiState();


	 I2cSendData(&stI2cObj, ucWriteData);
	 ucSpconParam = I2cSpconGet(&stI2cObj);
	 ucSpconParam = ucSpconParam & (~ I2C_CON_REG_SI);
	 I2cSpconCfg(&stI2cObj, ucSpconParam);
	 WaitSiState();

	 I2cGenerateStop(&stI2cObj);
	 WaitSiState();
	 ucSpconParam = I2cSpconGet(&stI2cObj);
	 ucSpconParam = ucSpconParam & (~ I2C_CON_REG_SI);
	 I2cSpconCfg(&stI2cObj, ucSpconParam);
	 printf ("SendData; 0x%x\n",  ucWriteData++);
}

void EepromI2cRead()
{
	 uint8_t ucSpconParam = 0;
//	  ucSpconParam = I2cSpconGet(&stI2cObj);
//	 printf("ucSpconParam-1 = %x\n",ucSpconParam);
	  I2cGenerateStart(&stI2cObj);
	 WaitSiState();
	 ucSpconParam = I2cSpconGet(&stI2cObj);
//	 printf("ucSpconParam0 = %x\n",ucSpconParam);
	 ucSpconParam = ucSpconParam & (~I2C_CON_REG_STA);
     I2cSpconCfg(&stI2cObj, ucSpconParam);
//     printf("ucSpconParam1 = %x\n",ucSpconParam);


	 I2cSend7bitAddress(&stI2cObj, EEPRAM_DEV_ADDR, EN_I2C_DIR_SEND);
	 ucSpconParam = I2cSpconGet(&stI2cObj);
//	 printf("ucSpconParam2 = %x\n",ucSpconParam);
	 ucSpconParam = ucSpconParam & (~I2C_CON_REG_SI);
//	 printf("ucSpconParam3 = %x\n",ucSpconParam);
	 I2cSpconCfg(&stI2cObj, ucSpconParam);
	 WaitSiState();

	 I2cSendData(&stI2cObj, 0x00);
	 ucSpconParam = I2cSpconGet(&stI2cObj);
//	 printf("ucSpconParam4 = %x\n",ucSpconParam);
	 ucSpconParam = ucSpconParam & (~I2C_CON_REG_SI);
	 I2cSpconCfg(&stI2cObj, ucSpconParam);
//	 printf("ucSpconParam5 = %x\n",ucSpconParam);
	 WaitSiState();


	 I2cGenerateStart(&stI2cObj);
	 ucSpconParam = I2cSpconGet(&stI2cObj);
//	 printf("ucSpconParam6 = %x\n",ucSpconParam);
	 ucSpconParam = ucSpconParam & (~I2C_CON_REG_SI);
     I2cSpconCfg(&stI2cObj, ucSpconParam);
//     printf("ucSpconParam7 = %x\n",ucSpconParam);
     WaitSiState();

     ucSpconParam = I2cSpconGet(&stI2cObj);
     ucSpconParam = ucSpconParam & (~I2C_CON_REG_STA);
     I2cSpconCfg(&stI2cObj, ucSpconParam);

	 I2cSend7bitAddress(&stI2cObj, EEPRAM_DEV_ADDR, EN_I2C_DIR_RECV);
	 ucSpconParam = I2cSpconGet(&stI2cObj);
//	 printf("ucSpconParam8 = %x\n",ucSpconParam);
	 ucSpconParam = ucSpconParam & (~I2C_CON_REG_SI);
	 I2cSpconCfg(&stI2cObj, ucSpconParam);
//	 printf("ucSpconParam9 = %x\n",ucSpconParam);
	 WaitSiState();

	 ucSpconParam = I2cSpconGet(&stI2cObj);
//	 printf("ucSpconParam10 = %x\n",ucSpconParam);
	 ucSpconParam = (ucSpconParam & (~I2C_CON_REG_SI)) | I2C_CON_REG_AA;
	 I2cSpconCfg(&stI2cObj, ucSpconParam);
//	 printf("ucSpconParam11 = %x\n",ucSpconParam);
	 WaitSiState();

	 printf("Read Data: 0x%x\n", I2cReceiveData(&stI2cObj));

	 I2cGenerateStop(&stI2cObj);
	 WaitSiState();
	 ucSpconParam = I2cSpconGet(&stI2cObj);
//	 printf("ucSpconParam13 = %x\n",ucSpconParam);
	 ucSpconParam = ucSpconParam & (~ (I2C_CON_REG_SI | I2C_CON_REG_AA));
	 I2cSpconCfg(&stI2cObj, ucSpconParam);
//	 printf("ucSpconParam14 = %x\n",ucSpconParam);
}

#ifdef  USE_FULL_ASSERT

void assert_failed(uint8_t* file, uint32_t line)
{
	printf("Err: Filename-%s， Line-%d\n", file, line);
	while (1);
}

#endif /* USE_FULL_ASSERT*/
