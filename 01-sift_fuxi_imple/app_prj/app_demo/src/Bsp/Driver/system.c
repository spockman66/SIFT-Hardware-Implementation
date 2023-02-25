/*
 * system.c
 *
 *  Created on: 2021Äê11ÔÂ15ÈÕ
 *      Author: Administrator
 */

#include "system.h"

/*the 20 is test parameter, if CLK modify, the val isn't correct*/
void DelayS (uint32_t ulDelayS)
{
	uint32_t ulWaitCnt = ulDelayS * 1000 * 1000 * 1000 / (CLK_CYC * 20);
	while (ulWaitCnt > 0)
	{
		ulWaitCnt--;
	}
}

void DelayMs (uint32_t ulDelayMs)
{
	uint32_t ulWaitCnt = (ulDelayMs * 1000 * 1000)  / (CLK_CYC * 20);
	while (ulWaitCnt > 0)
	{
		ulWaitCnt--;
	}
}

void DelayUs (uint32_t ulDelayUs)
{
	uint32_t ulWaitCnt = (ulDelayUs * 1000) / (CLK_CYC * 20);
	while (ulWaitCnt > 0)
	{
		ulWaitCnt--;
	}
}


