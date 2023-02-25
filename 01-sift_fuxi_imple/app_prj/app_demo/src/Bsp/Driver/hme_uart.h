
#ifndef __HME_UART_H__
#define __HME_UART_H__

#ifdef __cplusplus
extern "C" {
#endif

#include "stdio.h"
#include "hme_riscv.h"
#include "hme_plic.h"

#define DEF_UART_DEV_ID                          DEV1_INTR_NUM

#define BAUD_RATE(n)                             (UCLKFREQ / (n) / 16)

#define UART_OSC_DEFAULT_VAL                     (0x10)     //过采样默认配置参数值

#define UART_INTR_ERBI_EN                        (0x01)     //Enable received data available interrupt
#define UART_INTR_ETHEI_EN                       (0x02)     //Enable transmitter holding register interrupt
#define UART_INTR_ELSI_EN                        (0x04)     //Enable receiver line status interrupt
#define UART_INTR_EMSI_EN                        (0x08)     //Enable modem status interrupt
#define UART_INTR_ALL_EN                         (0x0F)
#define UART_INTR_ALL_DIS                        (0x00)

//intr enable check
#define IS_UART_INTR_EN(intr_enable)              ((intr_enable == UART_INTR_ERBI_EN)  || \
		                                          (intr_enable == UART_INTR_ETHEI_EN) || \
												  (intr_enable == UART_INTR_ELSI_EN)  || \
												  (intr_enable == UART_INTR_EMSI_EN)  || \
												  (intr_enable == UART_INTR_ALL_EN))

#define UART_INTR_ID_NONE                         (0x01)    //No Intr
#define UART_INTR_ID_RLS                          (0x06)    //Overrun errors, parity errors, framing errors, or line breaks
#define UART_INTR_ID_RDA                          (0x04)    //Received data available  interrupt
#define UART_INTR_ID_RCT                          (0x0C)    //Receive Character timeout
#define UART_INTR_ID_THRE                         (0x02)    //Transmitter interrupt
#define UART_INTR_ID_MS                           (0x00)    //Modem Status interrupt

//UART intr id check
#define IS_UART_INTR_ID(intr_id)                  ((intr_id == UART_INTR_ID_NONE) || \
	                                              (intr_id == UART_INTR_ID_RLS)  || \
												  (intr_id == UART_INTR_ID_RDA)  || \
												  (intr_id == UART_INTR_ID_RCT)  || \
												  (intr_id == UART_INTR_ID_THRE) || \
												  (intr_id == UART_INTR_ID_MS))

//FIFO Config Param,  Write to FIFO Control Register (0x28)
#define UART_FIFO_CFG_DIS                         (0x00)      //FIFO Disable
#define UART_FIFO_CFG_EN                          (0x01)      //FIFO enable Write 1 to enable both the transmitter and receiver FIFOs
#define UART_FIFO_CFG_RRST                        (0x02)      //Receiver FIFO reset
#define UART_FIFO_CFG_TRST                        (0x04)      //Transmitter FIFO reset
#define UART_FIFO_CFG_DMAE                        (0x08)      //DMA enable

#define UART_FIFO_STATE_EN                        (0x01)      //FIFO enable state
#define UART_FIFO_STATE_DIS                       (0x00)      //FIFO disable state

#define UART_TFIFO_TRIG_LEV_SHIFT                 (0x04)      //Transmitter FIFO trigger level shift
#define UART_RFIFO_TRIG_LEV_SHIFT                 (0x06)      //Receiver FIFO trigger level shift

typedef enum {
	EN_FIFO_LEV_TYPE_0 = 0,
	EN_FIFO_LEV_TYPE_1,
	EN_FIFO_LEV_TYPE_2,
	EN_FIFO_LEV_TYPE_3,
	EN_FIFO_LEV_TYPE_MAX
}EN_FIFO_LEV_TYPE;


//Data param config，Write to Line Control Register (0x2C)
#define UART_LINE_CFG_WLS_5BIT                    (0x00)      //5bit Data
#define UART_LINE_CFG_WLS_6BIT                    (0x01)      //6bit Data
#define UART_LINE_CFG_WLS_7BIT                    (0x02)      //7bit Data
#define UART_LINE_CFG_WLS_8BIT                    (0x03)      //8bit Data

#define UART_LINE_CFG_STB_2BIT                    (0x04)      //2 bits STOP，
#define UART_LINE_CFG_PEN                         (0x08)      //Parity enable
#define UART_LINE_CFG_EPS                         (0x10)      //Even parity select
#define UART_LINE_CFG_SPS                         (0x20)      //Stick parity
#define UART_LINE_CFG_BC                          (0x40)      //Break control
#define UART_LINE_CFG_DLAB                        (0x80)      //Divisor latch access


//Modem config param， Write to Modem Control Register (0x30)
#define UART_MODEM_CFG_DEFAULT                    (0x00)      //Default config
#define UART_MODEM_CFG_DTR                        (0x01)      //Data terminal ready
#define UART_MODEM_CFG_RTS                        (0x02)      //The modem_rtsn output signal will be driven LOW
#define UART_MODEM_CFG_OUT1                       (0x04)      //The uart_out1n output signal will be driven LOW
#define UART_MODEM_CFG_OUT2                       (0x08)      //The uart_out2n output signal will be driven LOW
#define UART_MODEM_CFG_LOOP                       (0x10)      //Enable loopback mode
#define UART_MODEM_CFG_AFE                        (0x20)      //Auto flow control enable，The auto-CTS and auto-RTS setting is based on the RTS bit setting

//UART Line State
#define UART_LINE_STATE_DR                        (0x01)      //Data ready
#define UART_LINE_STATE_OE                        (0x02)      //Overrun error
#define UART_LINE_STATE_PE                        (0x04)      //Parity error
#define UART_LINE_STATE_FE                        (0x08)      //Framing error
#define UART_LINE_STATE_LB                        (0x10)      //Line break
#define UART_LINE_STATE_THRE                      (0x20)      //Transmitter Holding Register empty
#define UART_LINE_STATE_TEMT                      (0x40)      //Transmitter empty
#define UART_LINE_STATE_ERRF                      (0x80)      //Error in RXFIFO

//UART Modem State
#define UART_MODEM_STATE_DCTS                     (0x01)      //Delta clear to send
#define UART_MODEM_STATE_DDSR                     (0x02)      //Delta data set ready
#define UART_MODEM_STATE_TERI                     (0x04)      //Trailing edge ring indicator
#define UART_MODEM_STATE_DDCD                     (0x08)      //Delta data carrier detect
#define UART_MODEM_STATE_CTS                      (0x10)      //Clear to send,The modem_ctsn input signal is LOW
#define UART_MODEM_STATE_DSR                      (0x20)      //Data set ready,The modem_dsrn input signal is LOW
#define UART_MODEM_STATE_RI                       (0x40)      //Ring indicator,The modem_rin input signal is LOW
#define UART_MODEM_STATE_DCD                      (0x80)      //Data carrier detect, The modem_dcdn input signal is LOW

//UART config param struct
typedef struct {
	uint16_t  usBaudDiv;                    //分频参数
	uint8_t   ucIntrCtrl;                   //中断使能配置
	uint8_t   ucOscCtrl;                    //过采样配置
	uint8_t   ucFifoCtrl;                   //FIFO配置参数
	uint8_t   ucLineCtrl;                   //Line控制参数
	uint8_t   ucModemCtrl;                  //Modem控制参数
	uint8_t   ucScratchCtrl;                //Scratch控制参数
}ST_UART_CFG_PARAM;

//UART object attr struct
typedef struct {
	uint16_t  usDevId;                      //Uart设备ID
	uint8_t*  pucSendBuf;                   //发送数据Buf
	uint8_t*  pucRecvBuf;                   //接收数据Buff
	uint16_t  usSendDataSize;               //发送数据大小
	uint16_t  usRecvDataSize;               //接收数据大小
	uint16_t  usSendBytesCnt;               //已经发送的数据计数
	uint16_t  usRecvBytesCnt;               //已经接收的数据计数
	ST_UART_CFG_PARAM stCfgParam;           //UART配置参数
	ST_PLIC_CFG_PARAM stPlicCfgParam;       //PLIC配置参数
	PST_UART_RegDef pstCtrller;             //UART控制器指针
}ST_UART_ATTR,*PST_UART_ATTR;


uint32_t UartIdGet(PST_UART_ATTR pstUartObj);
void UartStructDeInit(PST_UART_ATTR pstUartObj);
void UartObjParamInit(PST_UART_ATTR pstUartObj, PST_UART_ATTR pstUartParam);
void UartObjConfigInit(PST_UART_ATTR pstUartObj);
void UartDivAccessSet(PST_UART_ATTR pstUartObj);
void UartDivAccessClear(PST_UART_ATTR pstUartObj);
void UartBaudDivCfg(PST_UART_ATTR pstUartObj);
uint16_t UartBaudDivGet(PST_UART_ATTR pstUartObj);
void UartTranModeCfg(PST_UART_ATTR pstUartObj);
uint8_t UartTranModeGet(PST_UART_ATTR pstUartObj);
void UartFifoCfg(PST_UART_ATTR pstUartObj);
uint8_t UartFifoDepthGet(PST_UART_ATTR pstUartObj);
uint8_t UartFifoEnStateGet(PST_UART_ATTR pstUartObj);
void UartOscCfg(PST_UART_ATTR pstUartObj);
uint8_t UartOscGet(PST_UART_ATTR pstUartObj);
uint8_t UartLineStatusGet(PST_UART_ATTR pstUartObj);
void UartModemCtrlCfg(PST_UART_ATTR pstUartObj);
uint8_t UartModemCtrlParamGet(PST_UART_ATTR pstUartObj);
uint8_t UartModemStatusGet(PST_UART_ATTR pstUartObj);
void UartScratchCfg(PST_UART_ATTR pstUartObj);
uint8_t UartScratchGet(PST_UART_ATTR pstUartObj);
void UartByteSend(PST_UART_ATTR pstUartObj, const uint8_t ucSendData);
uint32_t UartStringSend(PST_UART_ATTR pstUartObj, uint8_t* pucSendBuf);
uint8_t UartByteRecv(PST_UART_ATTR pstUartObj);
void UartBuffSend(PST_UART_ATTR pstUartObj);
void UartBuffRecv(PST_UART_ATTR pstUartObj);
void UartIntrCfg(PST_UART_ATTR pstUartObj);
uint8_t UartIntrEnStateGet(PST_UART_ATTR pstUartObj);
uint8_t UartIntrIDGet(PST_UART_ATTR pstUartObj);

#ifdef __cplusplus
}
#endif

#endif	/* __HME_UART_H__*/
