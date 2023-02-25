/*
 * hme_spi.h
 *
 *  Created on: 2021年11月11日
 *      Author: Administrator
 */

#ifndef _HME_SPI_H_
#define _HME_SPI_H_

#ifdef __cplusplus
extern "C" {
#endif

#include "stdio.h"
#include "hme_riscv.h"
#include "hme_plic.h"

#define DEF_SPI0_DEV_ID                    DEV4_INTR_NUM

//Serial Peripheral Rate config define
#define SPI_SPCON_SPR0                     (0x01)
#define SPI_SPCON_SPR1                     (0x02)
#define SPI_SPCON_SPR2                     (0x80)

#define SPI_SPCON_CPHA                     (0x04)   //data is sampled when the “scki”/”scko” returns to idle state.
#define SPI_SPCON_CPOL                     (0x08)   //the “sck” is set to 1 in idle state.
#define SPI_SPCON_MSTR                     (0x10)   //configures SPI as a Master
#define SPI_SPCON_SSDIS                    (0x20)   //Disables the “ssn” input in both Master and Slave modes.
#define SPI_SPCON_SPEN                     (0x40)   //Serial peripheral enable.

#define SPI_SPCON_DEFAULT                  (SPI_SPCON_SPR1 | SPI_SPCON_CPHA | SPI_SPCON_CPOL |  \
		                                    SPI_SPCON_MSTR | SPI_SPCON_SSDIS)

#define SPI_SPSTA_MODF                     (0x10)   //Mode Fault Flag
#define SPI_SPSTA_SSERR                    (0x20)   //Synchronous serial slave error flag
#define SPI_SPSTA_WCOL                     (0x40)   //Write collision flag
#define SPI_SPSTA_SPIF                     (0x80)   //Serial Peripheral Data Transfer Flag

//Slave scl config param
#define SPI_SLAVE_SCL_BIT0                 (0x01)
#define SPI_SLAVE_SCL_BIT1                 (0x02)
#define SPI_SLAVE_SCL_BIT2                 (0x04)
#define SPI_SLAVE_SCL_BIT3                 (0x08)
#define SPI_SLAVE_SCL_BIT4                 (0x10)
#define SPI_SLAVE_SCL_BIT5                 (0x20)
#define SPI_SLAVE_SCL_BIT6                 (0x40)
#define SPI_SLAVE_SCL_BIT7                 (0x80)
#define SPI_SLAVE_SCL_ALL                  (0xFF)
#define SPI_SLAVE_SCL_NONE                 (0x00)

typedef enum {
	EN_POLARITY_TYPE_LOW = 0,
	EN_POLARITY_TYPE_HIGH,
	EN_POLARITY_TYPE_MAX
}EN_POLARITY_TYPE;

//SPI config param struct
typedef struct {
	uint8_t  ucCtrlParam;                //Control Param, Write to spcon Register
	uint8_t  ucSlaveScl;                 //SPI slave Selection config
	uint8_t  ucSsnPolarity;              //SSN Single polarity Control
}ST_SPI_CFG_PARAM;

//SPI object attr struct
typedef struct {
	uint16_t  usDevId;                      //USPI设备ID
	uint8_t*  pucSendBuf;                   //发送数据Buf
	uint8_t*  pucRecvBuf;                   //接收数据Buff
	uint32_t  ulTranBytesSize;              //发送数据大小
	uint32_t  ulTranBytesCnt;               //已经接收的数据计数
	ST_SPI_CFG_PARAM stCfgParam;            //SPI配置参数
	ST_PLIC_CFG_PARAM stPlicCfgParam;       //PLIC配置参数
	PST_SPI_RegDef pstCtrller;              //SPI控制器指针
}ST_SPI_ATTR,*PST_SPI_ATTR;


void SpiStructDeInit(PST_SPI_ATTR pstSpiObj);
void SpiObjParamInit(PST_SPI_ATTR pstSpiObj, PST_SPI_ATTR pstSpiParam);
void SpiObjConfigInit(PST_SPI_ATTR pstSpiObj);
void SpiSpconCfg(PST_SPI_ATTR pstSpiObj);
uint8_t SpiSpconGet(PST_SPI_ATTR pstSpiObj);
void SpiEnable(PST_SPI_ATTR pstSpiObj);
void SpiDisable(PST_SPI_ATTR pstSpiObj);
uint8_t SpiStateGet(PST_SPI_ATTR pstSpiObj);
void SpiSlaveCfg(PST_SPI_ATTR pstSpiObj);
uint8_t SpiSlaveSclGet(PST_SPI_ATTR pstSpiObj);
void SpiHanderRequest(PST_SPI_ATTR pstSpiObj);

#ifdef __cplusplus
}
#endif


#endif /* _HME_SPI_H_ */
