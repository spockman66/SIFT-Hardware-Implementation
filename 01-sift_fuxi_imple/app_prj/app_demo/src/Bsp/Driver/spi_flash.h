/*
 * spi_flash.h
 *
 *  Created on: 2021Äê11ÔÂ11ÈÕ
 *      Author: Administrator
 */

#ifndef _SPI_FLASH_H_
#define _SPI_FLASH_H_


#ifdef __cplusplus
extern "C" {
#endif

#include "hme_spi.h"


#define FLASH_ID                   (0xC84017)
#define FLASH_PAGE_SIZE            (256)
#define FLASH_WIP_STATUS           (0x01)
#define FLASH_WEL_STATUS           (0x02)

//flash  cmd define
#define CMD_GD25_WRITE_EN          (0x06)
#define CMD_GD25_WRITE_DIS         (0x04)
#define CMD_GD25_READ_STATUS       (0x05)
#define CMD_GD25_WRITE_STATUS      (0x01)
#define CMD_GD25_READ_DATA         (0x03)
#define CMD_GD25_FAST_READ_DATA    (0x0B)
#define CMD_GD25_PAGE_PROGRAM      (0x02)
#define CMD_GD25_SECTOR_ERASE      (0x20)
#define CMD_GD25_BLOCK_ERASE_32K   (0x52)
#define CMD_GD25_BLOCK_ERASE_64K   (0xD8)
#define CMD_GD25_CHIP_ERASE        (0xC7)
#define CMD_GD25_READ_ID           (0x9F)

#define Dummy_Byte                 (0xFF)


typedef enum
{
	EN_BLOCK_TYPE_MIN = 0,
	EN_BLOCK_TYPE_32K = EN_BLOCK_TYPE_MIN,
	EN_BLOCK_TYPE_64K,
	EN_BLOCK_TYPE_MAX
}EN_BLOCK_TYPE;

void SpiFlashInit(PST_SPI_ATTR pstSpiObj);
void SpiFlashSectorErase(PST_SPI_ATTR pstSpiObj, uint32_t ulSectorAddr);
void SpiFlashBlockErase(PST_SPI_ATTR pstSpiObj, uint32_t ulBlockAddr, EN_BLOCK_TYPE enEraseType);
void SpiFlashChipErase(PST_SPI_ATTR pstSpiObj);
void SpiFlashBufferWrite(PST_SPI_ATTR pstSpiObj, uint32_t ulWriteAddr);
void SpiFlashBufferRead(PST_SPI_ATTR pstSpiObj, uint32_t ulReadAddr);
void SpiFlashRandomRead(PST_SPI_ATTR pstSpiObj, uint32_t ulReadAddr);
uint32_t SpiFlashReadID(PST_SPI_ATTR pstSpiObj);


#ifdef __cplusplus
}
#endif

#endif /* _SPI_FLASH_H_ */
