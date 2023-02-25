/*
 * hme_plic.h
 *
 *  Created on: 2021年11月23日
 *      Author: Administrator
 */

#ifndef _HME_PLIC_H_
#define _HME_PLIC_H_

#ifdef __cplusplus
extern "C" {
#endif

#include "stdio.h"
#include "stdlib.h"
#include "system.h"
#include "core.h"


/*PLIC interrupt id, interrupt id 0 is no use*/
#define DEF_PLIC_INT0_ID                         (0x00)
#define DEF_PLIC_INT1_ID                         (0x01)
#define DEF_PLIC_INT2_ID                         (0x02)
#define DEF_PLIC_INT3_ID                         (0x04)
#define DEF_PLIC_INT4_ID                         (0x05)
#define DEF_PLIC_INT5_ID                         (0x06)
#define DEF_PLIC_INT6_ID                         (0x08)
#define DEF_PLIC_INT7_ID                         (0x09)
#define DEF_PLIC_INT8_ID                         (0x0a)
#define DEF_PLIC_INT9_ID                         (0x0c)
#define DEF_PLIC_INT10_ID                        (0x0d)
#define DEF_PLIC_INT11_ID                        (0x19)
#define DEF_PLIC_INT12_ID                        (0x1e)
#define DEF_PLIC_INT13_ID                        (0x1f)

#define DEF_PLIC_INT_IE_OFFSET                   (0x2000)          /*PLIC intr enable offset addr*/
#define DEF_PLIC_INT_THRESHOLD_OFFSET            (0x200000)        /*PLIC intr threshold offset addr*/
#define DEF_PLIC_INT_CLAIM_OFFSET                (0x200004)        /*PLIC intr claim offset addr*/
#define DEF_PLIC_INT_FINISH_OFFSET               (0x200004)        /*PLIC intr completion offsetaddr*/

/*PLIC interrupt priority offset addr*/
#define DEF_PLIC_DEV0_PRIORITY_OFFSET            (0x7C)
#define DEF_PLIC_DEV1_PRIORITY_OFFSET            (0x04)
#define DEF_PLIC_DEV2_PRIORITY_OFFSET            (0x08)
#define DEF_PLIC_DEV3_PRIORITY_OFFSET            (0x20)
#define DEF_PLIC_DEV4_PRIORITY_OFFSET            (0x24)
#define DEF_PLIC_DEV5_PRIORITY_OFFSET            (0x28)
#define DEF_PLIC_DEV6_PRIORITY_OFFSET            (0x64)
#define DEF_PLIC_DEV7_PRIORITY_OFFSET            (0x10)
#define DEF_PLIC_DEV8_PRIORITY_OFFSET            (0x14)
#define DEF_PLIC_DEV9_PRIORITY_OFFSET            (0x18)
#define DEF_PLIC_DEV10_PRIORITY_OFFSET           (0x78)
#define DEF_PLIC_DEV11_PRIORITY_OFFSET           (0x30)
#define DEF_PLIC_DEV12_PRIORITY_OFFSET           (0x34)

/*PLIC interrupt pending offset addr*/
#define DEF_PLIC_DEV0_IP_OFFSET                  (0x107C)
#define DEF_PLIC_DEV1_IP_OFFSET                  (0x1004)
#define DEF_PLIC_DEV2_IP_OFFSET                  (0x1008)
#define DEF_PLIC_DEV3_IP_OFFSET                  (0x1020)
#define DEF_PLIC_DEV4_IP_OFFSET                  (0x1024)
#define DEF_PLIC_DEV5_IP_OFFSET                  (0x1028)
#define DEF_PLIC_DEV6_IP_OFFSET                  (0x1064)
#define DEF_PLIC_DEV7_IP_OFFSET                  (0x1010)
#define DEF_PLIC_DEV8_IP_OFFSET                  (0x1014)
#define DEF_PLIC_DEV9_IP_OFFSET                  (0x1018)
#define DEF_PLIC_DEV10_IP_OFFSET                 (0x1078)
#define DEF_PLIC_DEV11_IP_OFFSET                 (0x1030)
#define DEF_PLIC_DEV12_IP_OFFSET                 (0x1034)

/*PILC intr enable*/
#define DEF_PLIC_DEV0_IE_EN                      (0x80000000)
#define DEF_PLIC_DEV1_IE_EN                      (0x00000002)
#define DEF_PLIC_DEV2_IE_EN                      (0x00000004)
#define DEF_PLIC_DEV3_IE_EN                      (0x00000100)
#define DEF_PLIC_DEV4_IE_EN                      (0x00000200)
#define DEF_PLIC_DEV5_IE_EN                      (0x00000400)
#define DEF_PLIC_DEV6_IE_EN                      (0x02000000)
#define DEF_PLIC_DEV7_IE_EN                      (0x00000010)
#define DEF_PLIC_DEV8_IE_EN                      (0x00000020)
#define DEF_PLIC_DEV9_IE_EN                      (0x00000040)
#define DEF_PLIC_DEV10_IE_EN                     (0x40000000)
#define DEF_PLIC_DEV11_IE_EN                     (0x00001000)
#define DEF_PLIC_DEV12_IE_EN                     (0x00002000)
#define DEF_PLIC_IE_ALL_EN                       (0xC2003776)
#define DEF_PLIC_IE_ALL_DIS                      (0x00000000)


#define DEV0_INTR_NUM                            (0x00)
#define DEV1_INTR_NUM                            (0x01)
#define DEV2_INTR_NUM                            (0x02)
#define DEV3_INTR_NUM                            (0x03)
#define DEV4_INTR_NUM                            (0x04)
#define DEV5_INTR_NUM                            (0x05)
#define DEV6_INTR_NUM                            (0x06)
#define DEV7_INTR_NUM                            (0x07)
#define DEV8_INTR_NUM                            (0x08)
#define DEV9_INTR_NUM                            (0x09)
#define DEV10_INTR_NUM                           (0x0a)
#define DEV11_INTR_NUM                           (0x0b)
#define DEV12_INTR_NUM                           (0x0c)
#define DEV_INTR_MAX                             (13)

//设备ID枚举
typedef enum{
	EN_DEV_ID_0 = DEV0_INTR_NUM,
	EN_DEV_ID_1,
	EN_DEV_ID_2,
	EN_DEV_ID_3,
	EN_DEV_ID_4,
	EN_DEV_ID_5,
	EN_DEV_ID_6,
	EN_DEV_ID_7,
	EN_DEV_ID_8,
	EN_DEV_ID_9,
	EN_DEV_ID_10,
	EN_DEV_ID_11,
	EN_DEV_ID_12,
	EN_DEV_ID_MAX
}EN_DEV_ID;

//PLIC优先级枚举
typedef enum {
	EN_PRIORITY_MIN = 0,
	EN_PRIORITY_0 = EN_PRIORITY_MIN,
	EN_PRIORITY_1,
	EN_PRIORITY_2,
	EN_PRIORITY_3,
	EN_PRIORITY_MAX
}EN_PRIORITY;

//PILC中断悬挂枚举
typedef enum {
	EN_PENDING_MIN = 0,
	EN_PENDING_OFF = EN_PRIORITY_MIN,
	EN_PENDING_ON,
	EN_PENDING_MAX
}EN_PENDING;

//plic 中断设备判断
#define IS_DEV_ID(dev_id)                         ((dev_id == EN_DEV_ID_0)  ||        \
		                                           (dev_id == EN_DEV_ID_1)  ||        \
		                                           (dev_id == EN_DEV_ID_2)  ||        \
		                                           (dev_id == EN_DEV_ID_3)  ||        \
		                                           (dev_id == EN_DEV_ID_4)  ||        \
		                                           (dev_id == EN_DEV_ID_5)  ||        \
		                                           (dev_id == EN_DEV_ID_6)  ||        \
		                                           (dev_id == EN_DEV_ID_7)  ||        \
		                                           (dev_id == EN_DEV_ID_8)  ||        \
		                                           (dev_id == EN_DEV_ID_9)  ||        \
		                                           (dev_id == EN_DEV_ID_10) ||        \
		                                           (dev_id == EN_DEV_ID_11) ||        \
		                                           (dev_id == EN_DEV_ID_12))


//中断优先级判断
#define IS_PLIC_PRIORITY(priority)                ((priority == EN_PRIORITY_0) ||  \
	                                               (priority == EN_PRIORITY_1) ||  \
				                                   (priority == EN_PRIORITY_2) ||  \
						                           (priority == EN_PRIORITY_3))
//中断悬挂判断
#define IS_PLIC_PENDING(pending)                  ((priority == EN_PENDING_OFF) || (priority == EN_PENDING_ON))


typedef void (*ptrIntrFun)(void *);

//PLIC中断注册结构体
typedef struct {
	uint16_t   usIntrId;
	ptrIntrFun IntrHander;
	void * ptrBackCall;
}ST_PLIC_REG_PARAM, *PST_PLIC_REG_PARAM;

//设备参数表结构体
typedef struct {
	uint16_t usDevId;
	uint16_t usIntrId;
	uint32_t ulPriorityOffset;
	uint32_t ulPendingOffset;
	uint32_t ulIntrEnable;
}ST_PLIC_DEV_PARAM,*PST_PLIC_DEV_PARAM;

//设备PLIC参数结构体
typedef struct {
	uint8_t   ucIntrEnFlage;     //intr enbale   DEF_ENABLE or DEF_DISABLE
	uint8_t   ucPriority;        //intr Priority  < 4
}ST_PLIC_CFG_PARAM,*PST_PLIC_CFG_PARAM;


/*look param table*/
uint16_t DevIntrIdTableGet(uint16_t usDevId);
uint32_t DevPriorityOffsetTableGet(uint16_t usDevId);
uint32_t DevPendingOffsetTableGet(uint16_t usDevId);
uint32_t DevIntrEnTableGet(uint16_t usDevId);

void IntrPrioritySet(uint16_t usDevId, uint8_t ucPriority);
uint32_t IntrPriorityGet(uint16_t usDevId);
uint32_t IntrPendingGet(uint16_t usDevId);
void PlicEnableSet(uint32_t ulEnableVal);
uint32_t PlicEnableGet(void);
void PlicThresholdSet(uint8_t ucPlicThreshold);
uint8_t PlicThresholdGet(void);
void PlicIntrHandleRegister(PST_PLIC_REG_PARAM pstRegParam, uint16_t usDevId);
void ExternalInterruptExcute(void);

#ifdef __cplusplus
}
#endif

#endif /* _HME_PLIC_H_ */
