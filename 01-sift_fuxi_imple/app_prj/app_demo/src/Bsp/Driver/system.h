/*
 * system.h
 *
 *  Created on: 2021Äê11ÔÂ15ÈÕ
 *      Author: Administrator
 */

#ifndef _SYSTEM_H_
#define _SYSTEM_H_

#ifdef __cplusplus
extern "C" {
#endif

#include "hme_riscv.h"

//delay interface
void DelayS (uint32_t ulDelayS);
void DelayMs (uint32_t ulDelayMs);
void DelayUs (uint32_t ulDelayUs);


#ifdef __cplusplus
}
#endif

#endif /* _SYSTEM_H_ */
