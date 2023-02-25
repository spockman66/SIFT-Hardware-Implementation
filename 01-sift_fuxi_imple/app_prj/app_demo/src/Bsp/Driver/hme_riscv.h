
#ifndef __HME_RISCV_H__
#define __HME_RISCV_H__

#ifdef __cplusplus
extern "C" {
#endif

#include "stdio.h"


/* user define */
#define IMG_SIZE		0x40000
#define IMG_ADDR_RX		0x00300000

#define RSLT_SIZE		0x100000
#define RSLT_ADDR_TX	0x00500000



#define __I                       volatile const	/* 'read only' permissions      */
#define __O                       volatile          /* 'write only' permissions     */
#define __IO                      volatile          /* 'read / write' permissions   */


typedef   signed       char       int8_t;
typedef   signed short  int       int16_t;
typedef   signed       long       int32_t;
typedef   signed  long long       int64_t;

/* exact-width unsigned integer types */
typedef   unsigned      char      uint8_t;
typedef   unsigned short int      uint16_t;
typedef   unsigned      long      uint32_t;
typedef   unsigned long long      uint64_t;


typedef enum {RESET = 0, SET = !RESET} FlagStatus, ITStatus;

typedef enum {DISABLE = 0, ENABLE = !DISABLE} FunctionalState;
#define IS_FUNCTIONAL_STATE(STATE) (((STATE) == DISABLE) || ((STATE) == ENABLE))

typedef enum {ERROR = 0, SUCCESS = !ERROR} ErrorStatus;

#define BSP_VERSION        (0x20211123)


#define KHz                     1000
#define MHz                     1000000

#define CPUFREQ                 (80 * MHz)
#define UCLKFREQ                (CPUFREQ)

#define CLK_CYC                 (1000 * 1000 * 1000 / CPUFREQ)

/*****************************************************************************
 * Machine timer
 ****************************************************************************/
typedef struct {
	__I  uint32_t CUR_CNTL;
	__I  uint32_t CUR_CNTH;
	__IO uint32_t CMPL;
	__IO uint32_t CMPH;
} MACH_TIME_RegDef,*PST_MACH_TIME_RegDef;

/*****************************************************************************
 * UARTx
 ****************************************************************************/
typedef struct {
	__I  uint32_t IDREV;                /* 0x00 ID and Revision Register */
	     uint32_t RESERVED0[3];         /* 0x04 ~ 0x0C Reserved */
	__I  uint32_t CFG;                  /* 0x10 Hardware Configure Register */
	__IO uint32_t OSCR;                 /* 0x14 Over Sample Control Register */
	     uint32_t RESERVED1[2];         /* 0x18 ~ 0x1C Reserved */
	union {
		__IO uint32_t RBR;              /* 0x20 Receiver Buffer Register */
		__O  uint32_t THR;              /* 0x20 Transmitter Holding Register */
		__IO uint32_t DLL;              /* 0x20 Divisor Latch LSB */
	};
	union {
		__IO uint32_t IER;              /* 0x24 Interrupt Enable Register */
		__IO uint32_t DLM;              /* 0x24 Divisor Latch MSB */
	};
	union {
		__IO uint32_t IIR;              /* 0x28 Interrupt Identification Register */
		__O  uint32_t FCR;              /* 0x28 FIFO Control Register */
	};
	__IO uint32_t LCR;                  /* 0x2C Line Control Register */
	__IO uint32_t MCR;                  /* 0x30 Modem Control Register */
	__IO uint32_t LSR;                  /* 0x34 Line Status Register */
	__IO uint32_t MSR;                  /* 0x38 Modem Status Register */
	__IO uint32_t SCR;                  /* 0x3C Scratch Register */
} UART_RegDef, *PST_UART_RegDef;


/*****************************************************************************
 * GPIO
 ****************************************************************************/
typedef struct {
	__I  uint32_t IDREV;                /* 0x00 ID and revision register */
	     uint32_t RESERVED0[3];         /* 0x04 ~ 0x0c Reserved */
	__I  uint32_t CFG;                  /* 0x10 Configuration register */
	     uint32_t RESERVED1[3];         /* 0x14 ~ 0x1c Reserved */
	__I  uint32_t DATAIN;               /* 0x20 Channel data-in register */
	__IO uint32_t DATAOUT;              /* 0x24 Channel data-out register */
	__IO uint32_t CHANNELDIR;           /* 0x28 Channel direction register */
	__O  uint32_t DOUTCLEAR;            /* 0x2c Channel data-out clear register */
	__O  uint32_t DOUTSET;              /* 0x30 Channel data-out set register */
	     uint32_t RESERVED2[3];         /* 0x34 ~ 0x3c Reserved */
	__IO uint32_t PULLEN;               /* 0x40 Pull enable register */
	__IO uint32_t PULLTYPE;             /* 0x44 Pull type register */
	     uint32_t RESERVED3[2];         /* 0x48 ~ 0x4c Reserved */
	__IO uint32_t INTREN;               /* 0x50 Interrupt enable register */
	__IO uint32_t INTRMODE0;            /* 0x54 Interrupt mode register (0~7) */
	__IO uint32_t INTRMODE1;            /* 0x58 Interrupt mode register (8~15) */
	__IO uint32_t INTRMODE2;            /* 0x5c Interrupt mode register (16~23) */
	__IO uint32_t INTRMODE3;            /* 0x60 Interrupt mode register (24~31) */
	__IO uint32_t INTRSTATUS;           /* 0x64 Interrupt status register */
         uint32_t RESERVED4[2];         /* 0x68 ~ 0x6c Reserved */
	__IO uint32_t DEBOUNCEEN;           /* 0x70 De-bounce enable register */
	__IO uint32_t DEBOUNCECTRL;         /* 0x74 De-bounce control register */
} GPIO_RegDef,*PST_GPIO_RegDef;


/*****************************************************************************
 * SPI
 ****************************************************************************/
typedef struct {
	__IO uint32_t RESERVED4;              /*0x00  Reserved */
	__IO uint32_t SPSTA;                  /*0x04  Serial Peripheral status register */
	__IO uint32_t SPCON;                  /*0x08  Serial Peripheral control register */
	__IO uint32_t SPDAT;                  /*0x0c  Serial Peripheral data register */
	__IO uint32_t SPSSN;                  /*0x0c  Serial Peripheral Slave Select register */
} SPI_RegDef, *PST_SPI_RegDef;


/*****************************************************************************
 * I2C
 ****************************************************************************/
typedef struct {
	__IO uint32_t I2CDAT;                /*0x00 IIC Peripheral data register*/
	__IO uint32_t I2CADR;                /*0x04 IIC Peripheral address register*/
	__IO uint32_t I2CCON;                /*0x08 IIC Peripheral control register*/
	__I  uint32_t I2CSTA;                /*0x0C IIC Peripheral status register*/
} I2C_RegDef, *PST_I2C_RegDef;

/*Periph Addr map*/
#define DDR_BASE_ADDR                    ((uint32_t)0x10000)
#define APB_PERIPH_BASE_ADDR             ((uint32_t)0xf8000000)
#define AXI_PERIPH_BASE_ADDR             ((uint32_t)0xfa000000)

#define PLIC_BASE_ADDR                   (APB_PERIPH_BASE_ADDR + 0xC00000)
#define MACH_TIME_BASE_ADDR              (APB_PERIPH_BASE_ADDR + 0x1000)
#define GPIO_BASE_ADDR                   (APB_PERIPH_BASE_ADDR + 0x2000)
#define UART0_BASE_ADDR                  (APB_PERIPH_BASE_ADDR + 0x3000)
#define SPI0_BASE_ADDR                   (APB_PERIPH_BASE_ADDR + 0x4000)
#define I2C0_BASE_ADDR                   (APB_PERIPH_BASE_ADDR + 0x5000)
#define SOFT_INTR_BASE_ADDR              (APB_PERIPH_BASE_ADDR + 0x6000)

#define DEV_MACH_TIMER                   ((MACH_TIME_RegDef *) MACH_TIME_BASE_ADDR)
#define DEV_GPIO                         ((GPIO_RegDef *) GPIO_BASE_ADDR)
#define DEV_UART0                        ((UART_RegDef *) UART0_BASE_ADDR)
#define DEV_SPI0                         ((SPI_RegDef *) SPI0_BASE_ADDR)
#define DEV_I2C0                         ((I2C_RegDef *) I2C0_BASE_ADDR)


/*Read and Write reg define*/
#define  ReadReg32(address)              (*(volatile uint32_t*)(address))
#define  WriteReg32(address, data)       (*(volatile uint32_t*)(address) = (uint32_t)(data))

#define  ReadReg16(address)              (*(volatile uint16_t*)(address))
#define  WriteReg16(address, data)       (*(volatile uint16_t*)(address) = (uint16_t)(data))

#define  ReadReg8(address)               (*(volatile uint8_t*)(address))
#define  WriteReg8(address, data)        (*(volatile uint8_t*)(address) = (uint8_t)(data))


#ifdef  USE_FULL_ASSERT
/**
  * @brief  The assert_param macro is used for function's parameters check.
  * @param  expr: If expr is false, it calls assert_failed function which reports
  *         the name of the source file and the source line number of the call
  *         that failed. If expr is true, it returns no value.
  * @retval None
  */
  #define assert_param(expr) ((expr) ? (void)0 : assert_failed((uint8_t *)__FILE__, __LINE__))
/* Exported functions ------------------------------------------------------- */
void assert_failed(uint8_t* file, uint32_t line);
#else
  #define assert_param(expr) ((void)0)
#endif /* USE_FULL_ASSERT */

#ifdef __cplusplus
}
#endif

#endif	/* __HME_RISCV_H__ */
