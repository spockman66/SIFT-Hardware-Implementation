//------------------------------------------------------------------------------
// depth of FIFO, the number could be 16/32/64/128
// select to enable one of macro as below, if don't select anyone, the default
// is HMEUART_FIFO_DEPTH_16
//------------------------------------------------------------------------------
`define HMEUART_FIFO_DEPTH_16
//`define HMEUART_FIFO_DEPTH_32
//`define HMEUART_FIFO_DEPTH_64
//`define HMEUART_FIFO_DEPTH_128

//------------------------------------------------------------------------------
// undefine the macro to define the system clock, uclk, is synchronous with pclk to remove the 
// asynchronous interface circuits.
//------------------------------------------------------------------------------
//`define HMEUART_UCLK_PCLK_SAME
