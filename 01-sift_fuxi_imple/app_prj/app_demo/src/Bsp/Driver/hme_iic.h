/*
 * hme_iic.h
 *
 *  Created on: 2021年12月3日
 *      Author: Administrator
 */

#ifndef _HME_IIC_H_
#define _HME_IIC_H_

#ifdef __cplusplus
extern "C" {
#endif

#include "hme_riscv.h"
#include "hme_plic.h"

#define DEF_I2C0_DEV_ID                 DEV5_INTR_NUM

#define I2C_CON_REG_CR0                 (0x01)        //Clock rate bit0 Set
#define I2C_CON_REG_CR1                 (0x02)        //Clock rate bit1 Set
#define I2C_CON_REG_CR2                 (0x80)        //Clock rate bit2 Set

#define I2C_CON_REG_AA                  (0x04)        //Assert Acknowledge Flag
#define I2C_CON_REG_SI                  (0x08)        //Serial Interrupt Flag
#define I2C_CON_REG_STO                 (0x10)        //STOP Flag
#define I2C_CON_REG_STA                 (0x20)        //START Flag
#define I2C_CON_REG_ENS1                (0x40)        //I2C enable

#define I2C_CON_MAST_CFG_MASK           (0x83)        //config I2C mask

#define I2C_SCL_CLK_DIV_256             (0x00)                                     //Clk divided by 256
#define I2C_SCL_CLK_DIV_224             (I2C_CON_REG_CR0)                          //Clk divided by 224
#define I2C_SCL_CLK_DIV_192             (I2C_CON_REG_CR1)                          //Clk divided by 192
#define I2C_SCL_CLK_DIV_160             (I2C_CON_REG_CR0 | I2C_CON_REG_CR1)        //Clk divided by 160
#define I2C_SCL_CLK_DIV_960             (I2C_CON_REG_CR2)                          //Clk divided by 960
#define I2C_SCL_CLK_DIV_120             (I2C_CON_REG_CR2 | I2C_CON_REG_CR0)        //Clk divided by 120
#define I2C_SCL_CLK_DIV_60              (I2C_CON_REG_CR2 | I2C_CON_REG_CR1)        //Clk divided by 60

#define IS_SCL_DIV(scl_div)             ((scl_div == I2C_SCL_CLK_DIV_256) ||  \
		                                 (scl_div == I2C_SCL_CLK_DIV_224) ||  \
										 (scl_div == I2C_SCL_CLK_DIV_192) ||  \
										 (scl_div == I2C_SCL_CLK_DIV_160) ||  \
										 (scl_div == I2C_SCL_CLK_DIV_960) ||  \
										 (scl_div == I2C_SCL_CLK_DIV_120) ||  \
										 (scl_div == I2C_SCL_CLK_DIV_60))
//Master Translate mode state
#define I2C_STA_REG_CODE_08H            (0x08)
#define I2C_STA_REG_CODE_10H            (0x10)
#define I2C_STA_REG_CODE_18H            (0x18)
#define I2C_STA_REG_CODE_20H            (0x20)
#define I2C_STA_REG_CODE_28H            (0x28)
#define I2C_STA_REG_CODE_30H            (0x30)
#define I2C_STA_REG_CODE_38H            (0x38)

//Master Receive mode state
#define I2C_STA_REG_CODE_40H            (0x40)
#define I2C_STA_REG_CODE_48H            (0x48)
#define I2C_STA_REG_CODE_50H            (0x50)
#define I2C_STA_REG_CODE_58H            (0x58)

//Slave Receive mode state
#define I2C_STA_REG_CODE_60H            (0x60)
#define I2C_STA_REG_CODE_68H            (0x68)
#define I2C_STA_REG_CODE_70H            (0x70)
#define I2C_STA_REG_CODE_78H            (0x78)
#define I2C_STA_REG_CODE_80H            (0x80)
#define I2C_STA_REG_CODE_88H            (0x88)
#define I2C_STA_REG_CODE_90H            (0x90)
#define I2C_STA_REG_CODE_98H            (0x98)
#define I2C_STA_REG_CODE_A0H            (0xA0)

//Slave Translate mode state
#define I2C_STA_REG_CODE_A8H            (0xA8)
#define I2C_STA_REG_CODE_B0H            (0xB0)
#define I2C_STA_REG_CODE_B8H            (0xB8)
#define I2C_STA_REG_CODE_C0H            (0xC0)
#define I2C_STA_REG_CODE_C8H            (0xC8)
#define I2C_STA_REG_CODE_F8H            (0xF8)
#define I2C_STA_REG_CODE_00H            (0x00)


typedef enum {
	EN_I2C_MODE_MASTER = 0,
	EN_I2C_MODE_SLAVE,
	EN_I2C_MODE_MAX
}EN_I2C_MODE;


typedef enum {
	EN_I2C_DIR_SEND = 0,
	EN_I2C_DIR_RECV,
	EN_I2C_DIR_MAX
}EN_I2C_DIR;

//IIC config param struct
typedef struct {
	uint8_t ucSelfAddr;
	uint8_t ucClkDiv;
	uint8_t ucMode;
}ST_I2C_CFG_PARAM;

//IIC object attr struct
typedef struct {
	uint16_t  usDevId;                      //IIC设备ID
	ST_I2C_CFG_PARAM stCfgParam;            //SPI配置参数
	ST_PLIC_CFG_PARAM stPlicCfgParam;       //PLIC配置参数
	PST_I2C_RegDef pstCtrller;              //IIC控制器指针
}ST_I2C_ATTR,*PST_I2C_ATTR;


void I2cStructDeInit(PST_I2C_ATTR pstI2cObj);
void I2cObjParamInit(PST_I2C_ATTR pstI2cObj, PST_I2C_ATTR pstI2cParam);
void I2cObjConfigInit(PST_I2C_ATTR pstI2cObj);
void I2cSpconCfg(PST_I2C_ATTR pstI2cObj, uint8_t ucCfgParam);
void I2cDivCfg(PST_I2C_ATTR pstI2cObj);
uint8_t I2cSpconGet(PST_I2C_ATTR pstI2cObj);
void I2cEnable(PST_I2C_ATTR pstI2cObj);
void I2cDisable(PST_I2C_ATTR pstI2cObj);
uint8_t I2cStateCodeGet(PST_I2C_ATTR pstI2cObj);
void I2cOwnAddressCfg(PST_I2C_ATTR pstI2cObj);
uint8_t I2cOwnAddressGet(PST_I2C_ATTR pstI2cObj);
void I2cGenerateStart(PST_I2C_ATTR pstI2cObj);
void I2cSendData(PST_I2C_ATTR pstI2cObj, uint8_t ucData);
uint8_t I2cSendDataGet(PST_I2C_ATTR pstI2cObj);
uint8_t I2cReceiveData(PST_I2C_ATTR pstI2cObj);
void I2cGenerateStop(PST_I2C_ATTR pstI2cObj);
void I2cSend7bitAddress(PST_I2C_ATTR pstI2cObj, uint8_t ucAddress, uint8_t ucDirection);


#ifdef __cplusplus
}
#endif

#endif /* _HME_IIC_H_ */
