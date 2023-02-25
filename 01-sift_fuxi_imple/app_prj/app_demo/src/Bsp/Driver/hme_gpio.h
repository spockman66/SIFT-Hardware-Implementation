/*
 * hme_gpio.h
 *
 *  Created on: 2021年11月10日
 *      Author: Administrator
 */

#ifndef _HEM_GPIO_H_
#define _HEM_GPIO_H_

#ifdef __cplusplus
extern "C" {
#endif

#include "hme_riscv.h"
#include "hme_plic.h"

#define DEF_GPIO_DEV_ID           DEV11_INTR_NUM

typedef struct {
	uint16_t  usDevId;
	uint8_t   ucDirection;               //0: input  1:output
	uint8_t   ucIntrEn;                  //0:disable intr  1:enable intr
	uint8_t   ucIntrMode;                //GPIO intr tarp mode
	uint8_t   ucPullEn;                  //write 1 to enable pull-up/pull-down of the corresponding channels
	uint8_t   ucPullType;                //0:pull-up  1:pull-down
	uint8_t   ucDbBounceEn;              //bits De-bounce Enable, bit 0 ctrl pin0.
	uint8_t   ucDBClkSel;                //0:extclk  1: pclk
	uint8_t   DBPreScale;                //GPIO pre-scale base
	uint32_t  ulChannels;                //bits  channels,  0 is bit0, 1 is bit 1
}ST_GPIO_CFG_PARAM;

typedef struct {
	ST_GPIO_CFG_PARAM stCfgParam;        //GPIO Config paramiter
	ST_PLIC_CFG_PARAM stPlicCfgParam;    //GPIO PLIC Config paramiter
	PST_GPIO_RegDef   pstCtrller;        //GPIO contrller
}ST_GPIO_ATTR,*PST_GPIO_ATTR;

typedef enum {
	EN_GPIO_INTR_MODE_NO_OP = 0x0,       //No operation trap
	EN_GPIO_INTR_MODE_HL    = 0x2,       //High-level trap
	EN_GPIO_INTR_MODE_LL    = 0x3,       //Low-level trap
	EN_GPIO_INTR_MODE_NE    = 0x5,       //Negative-edge trap
	EN_GPIO_INTR_MODE_PE    = 0x6,       //Positive-edge trap
	EN_GPIO_INTR_MODE_DE    = 0x7,        //Dual-edge trap
}EN_GPIO_INTR_MODE;

typedef enum {
	EN_GPIO_DIR_TYPE_IN  = 0x0,          //No operation trap
	EN_GPIO_DIR_TYPE_OUT
}EN_GPIO_DIR_TYPE;

typedef enum {
	EN_GPIO_INTRM_GROUP_0 = 0x0,
	EN_GPIO_INTRM_GROUP_1,
	EN_GPIO_INTRM_GROUP_2,
	EN_GPIO_INTRM_GROUP_3
}EN_GPIO_INTRM_GROUP;

typedef enum {
	EN_GPIO_PULL_TYPE_UP = 0x0,
	EN_GPIO_PULL_TYPE_DOWN
}EN_GPIO_PULL_TYPE;

typedef enum {
	EN_GPIO_DBCLK_TYPE_EXT = 0x0,
	EN_GPIO_DBCLK_TYPE_PCLK
}EN_GPIO_DBCLK_TYPE;

//GPIO使能属性判断
#define IS_GPIO_ENABLE_TYPE(enable)         ((enable == DISABLE) || (enable == ENABLE))

//输出方向属性判断
#define IS_GPIO_DIR_TYPE(dir_type)          ((dir_type == EN_GPIO_DIR_TYPE_IN) || (dir_type == EN_GPIO_DIR_TYPE_OUT))

//GPIO上拉属性判断
#define IS_GPIO_PULL_TYPE(pull_type)        ((pull_type == EN_GPIO_PULL_TYPE_UP) || (pull_type == EN_GPIO_PULL_TYPE_DOWN))

//GPIO防抖时钟属性判断
#define IS_GPIO_DBCLK_TYPE(dbclk_sel)       ((dbclk_sel == EN_GPIO_DBCLK_TYPE_EXT) || (dbclk_sel == EN_GPIO_DBCLK_TYPE_PCLK))

//GPIO 中断分组属性判断
#define IS_GPIO_INTRM_GROUP(intrm_group)    ((intrm_group == EN_GPIO_INTRM_GROUP_0) || \
	                                      	(intrm_group == EN_GPIO_INTRM_GROUP_1)  || \
                                            (intrm_group == EN_GPIO_INTRM_GROUP_2)  || \
		                                    (intrm_group == EN_GPIO_INTRM_GROUP_3))

//GPIO中断模式属性判断
#define IS_GPIO_INTR_MODE(intr_mode)        ((intr_mode == EN_GPIO_INTR_MODE_NO_OP) || \
	                                   	    (intr_mode == EN_GPIO_INTR_MODE_HL) || \
                                            (intr_mode == EN_GPIO_INTR_MODE_LL) || \
		                                    (intr_mode == EN_GPIO_INTR_MODE_NE) || \
		                                    (intr_mode == EN_GPIO_INTR_MODE_PE) || \
		                                    (intr_mode == EN_GPIO_INTR_MODE_DE))

#define GPIO_Pin_0                          ((uint32_t)1 << 0) /*!< Pin 0 selected */
#define GPIO_Pin_1                          ((uint32_t)1 << 1) /*!< Pin 1 selected */
#define GPIO_Pin_2                          ((uint32_t)1 << 2) /*!< Pin 2 selected */
#define GPIO_Pin_3                          ((uint32_t)1 << 3) /*!< Pin 3 selected */
#define GPIO_Pin_4                          ((uint32_t)1 << 4) /*!< Pin 4 selected */
#define GPIO_Pin_5                          ((uint32_t)1 << 5) /*!< Pin 5 selected */
#define GPIO_Pin_6                          ((uint32_t)1 << 6) /*!< Pin 6 selected */
#define GPIO_Pin_7                          ((uint32_t)1 << 7) /*!< Pin 7 selected */
#define GPIO_Pin_8                          ((uint32_t)1 << 8) /*!< Pin 8 selected */
#define GPIO_Pin_9                          ((uint32_t)1 << 9) /*!< Pin 9 selected */
#define GPIO_Pin_10                         ((uint32_t)1 << 10) /*!< Pin 10 selected */
#define GPIO_Pin_11                         ((uint32_t)1 << 11) /*!< Pin 11 selected */
#define GPIO_Pin_12                         ((uint32_t)1 << 12) /*!< Pin 12 selected */
#define GPIO_Pin_13                         ((uint32_t)1 << 13) /*!< Pin 13 selected */
#define GPIO_Pin_14                         ((uint32_t)1 << 14) /*!< Pin 14 selected */
#define GPIO_Pin_15                         ((uint32_t)1 << 15) /*!< Pin 15 selected */
#define GPIO_Pin_16                         ((uint32_t)1 << 16) /*!< Pin 16 selected */
#define GPIO_Pin_17                         ((uint32_t)1 << 17) /*!< Pin 17 selected */
#define GPIO_Pin_18                         ((uint32_t)1 << 18) /*!< Pin 18 selected */
#define GPIO_Pin_19                         ((uint32_t)1 << 19) /*!< Pin 19 selected */
#define GPIO_Pin_20                         ((uint32_t)1 << 20) /*!< Pin 20 selected */
#define GPIO_Pin_21                         ((uint32_t)1 << 21) /*!< Pin 21 selected */
#define GPIO_Pin_22                         ((uint32_t)1 << 22) /*!< Pin 22 selected */
#define GPIO_Pin_23                         ((uint32_t)1 << 23) /*!< Pin 23 selected */
#define GPIO_Pin_24                         ((uint32_t)1 << 24) /*!< Pin 24 selected */
#define GPIO_Pin_25                         ((uint32_t)1 << 25) /*!< Pin 25 selected */
#define GPIO_Pin_26                         ((uint32_t)1 << 26) /*!< Pin 26 selected */
#define GPIO_Pin_27                         ((uint32_t)1 << 27) /*!< Pin 27 selected */
#define GPIO_Pin_28                         ((uint32_t)1 << 28) /*!< Pin 28 selected */
#define GPIO_Pin_29                         ((uint32_t)1 << 29) /*!< Pin 29 selected */
#define GPIO_Pin_30                         ((uint32_t)1 << 30) /*!< Pin 30 selected */
#define GPIO_Pin_31                         ((uint32_t)1 << 31) /*!< Pin 31 selected */
#define GPIO_Pin_All                        ((uint32_t)0xFFFFFFFF)  /*!< All pins selected */

uint32_t GpioIdGet(PST_GPIO_ATTR pstGpioObj);
void GpioStructDeInit(PST_GPIO_ATTR pstGpioObj);
void GpioObjParamInit(PST_GPIO_ATTR pstGpioObj, PST_GPIO_ATTR pstGpioParam);
void GpioObjConfigInit(PST_GPIO_ATTR pstGpioObj);
uint32_t GpioCfgStateGet(PST_GPIO_ATTR pstGpioObj);
void GpioBitsDirCfg(PST_GPIO_ATTR pstGpioObj);
uint32_t GpioAllBitsDirGet(PST_GPIO_ATTR pstGpioObj);
void GpioBitsDoutSet(PST_GPIO_ATTR pstGpioObj);
void GpioBitsDoutClear(PST_GPIO_ATTR pstGpioObj);
uint32_t GpioDoutDataGet(PST_GPIO_ATTR pstGpioObj);
uint32_t GpioDinDataGet(PST_GPIO_ATTR pstGpioObj);
void GpioBitsPullCfg(PST_GPIO_ATTR pstGpioObj);
uint32_t GpioPullEnStateGet(PST_GPIO_ATTR pstGpioObj);
uint32_t GpioPullTypeGet(PST_GPIO_ATTR pstGpioObj);
void GpioBitsDebounceCfg(PST_GPIO_ATTR pstGpioObj);
uint32_t GpioDebounceCtrlStateGet(PST_GPIO_ATTR pstGpioObj);
uint32_t GpioDebounceEnStateGet(PST_GPIO_ATTR pstGpioObj);
void GpioBitsIntrCfg(PST_GPIO_ATTR pstGpioObj);
uint32_t GpioIntrEnStateGet(PST_GPIO_ATTR pstGpioObj);
uint32_t GpioIntrModeGroupStateGet(PST_GPIO_ATTR pstGpioObj, uint8_t ucGroup);
void GpioBitsIntrDisable(PST_GPIO_ATTR pstGpioObj);


#ifdef __cplusplus
}
#endif

#endif /* _HEM_GPIO_H_ */
