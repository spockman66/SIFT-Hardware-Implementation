
`timescale 1ns / 1ps
//================================================================================
// Copyright (c) 2012 Capital-micro, Inc.(Beijing)  All rights reserved.
//
// Capital-micro, Inc.(Beijing) Confidential.
//
// No part of this code may be reproduced, distributed, transmitted,
// transcribed, stored in a retrieval system, or translated into any
// human or computer language, in any form or by any means, electronic,
// mechanical, magnetic, manual, or otherwise, without the express
// written permission of Capital-micro, Inc.
//
//================================================================================
// Module Description: 
// This is the simulation module of ARM_M3 Core 
//================================================================================
// Revision History :
//     V1.0   2014-05-23  FPGA IP Grp, first created
//================================================================================

module M7S_SOC(
    fp2soc_rst_n,
	c2r1_dll_clk,
    fp_lvds_sclk,
	fp_clk_sys,
    fp_clk_adc,
    fp_clk_arm,
    fp_clk_usb,
	clk_eth_tx,
    
	// peripherals
    gpio_0_out_o,
    gpio_0_oe_o,
    gpio_0_in_i,
    i2c0_scl_oe_o,
    i2c0_sda_oe_o,
    i2c0_scl_i,
    i2c0_sda_i,
    i2c1_scl_oe_o,
    i2c1_sda_oe_o,
    i2c1_scl_i,
    i2c1_sda_i,
    uart0_rts_o,
    uart0_txd_o,
    uart0_cts_i,
    uart0_rxd_i,
    uart1_rts_o,
    uart1_txd_o,
    uart1_cts_i,
    uart1_rxd_i,
    spi0_mosi,
    spi0_sck,
    spi0_ssn,
    spi0_miso,
    spi1_mosi,
    spi1_sck,
    spi1_ssn,
    spi1_miso,
    pad_can0_o_clk,
    pad_can0_o_tx1,
    pad_can0_o_tx0,
    pad_can0_oen_tx1,
    pad_can0_oen_tx0,
    pad_can0_i_rx0,
    pad_can1_o_clk,
    pad_can1_o_tx1,
    pad_can1_o_tx0,
    pad_can1_oen_tx1,
    pad_can1_oen_tx0,
    pad_can1_i_rx0,
	// for fp1
    clk_ahb_fp1,
    rst_ahb_fp1_n,
    fp1_m_ahb_mastlock,
    fp1_m_ahb_prot,
    fp1_m_ahb_size,
    fp1_m_ahb_addr,
    fp1_m_ahb_write,
    fp1_m_ahb_burst,
    fp1_m_ahb_trans,
    fp1_m_ahb_wdata,
    fp1_m_ahb_ready,
    fp1_m_ahb_resp,
    fp1_m_ahb_rdata,
    fp1_s_ahb_mastlock,
    fp1_s_ahb_prot,
    fp1_s_ahb_size,
    fp1_s_ahb_sel,
    fp1_s_ahb_addr,
    fp1_s_ahb_write,
    fp1_s_ahb_burst,
    fp1_s_ahb_trans,
    fp1_s_ahb_wdata,
    fp1_s_ahb_readyout,
    fp1_s_ahb_resp,
    fp1_s_ahb_rdata,
	//for fp0
	clk_ahb_fp0,
    rst_ahb_fp0_n,
    fp0_m_ahb_mastlock,
    fp0_m_ahb_prot,
    fp0_m_ahb_size,
    fp0_m_ahb_addr,
    fp0_m_ahb_write,
    fp0_m_ahb_burst,
    fp0_m_ahb_trans,
    fp0_m_ahb_wdata,
    fp0_m_ahb_ready,
    fp0_m_ahb_resp,
    fp0_m_ahb_rdata,
    fp0_s_ahb_mastlock,
    fp0_s_ahb_prot,
    fp0_s_ahb_size,
    fp0_s_ahb_sel,
    fp0_s_ahb_addr,
    fp0_s_ahb_write,
    fp0_s_ahb_burst,
    fp0_s_ahb_trans,
    fp0_s_ahb_wdata,
    fp0_s_ahb_readyout,
    fp0_s_ahb_resp,
    fp0_s_ahb_rdata,
	//int 
    fp_INTNMI
);
//------------------------------------------------//
//if you don't simulate the AHB_FIFO,don't care the 
//parameter SIM_FIFO 
//------------------------------------------------//
parameter SIM_FIFO = 0;  // if you don't simulate AHB_FIFO, don't modify it
parameter START_ADDR = 32'ha000_0000; //  the address from START_ADDR ~ (START_ADDR + 32'h7ff);
                                     

parameter use_arm = 1'b1;
parameter use_clk_arm = 1'b1;
parameter use_pbus0 =1'b1;
parameter use_pbus1 =1'b1;
parameter use_on_chip_eth =1'b0;
parameter use_on_chip_usb =1'b0;
parameter use_on_chip_ddr_ctrl =1'b0;
parameter use_on_chip_adc =12'b000000000000;
parameter use_uart_io =1'b0;
parameter use_arm_nmi =1'b0;
parameter program_file ="";
parameter on_chip_ddr_ctrl_mode ="";
parameter on_chip_eth_mode = "";
  

input           fp2soc_rst_n;
input           c2r1_dll_clk;
input           fp_lvds_sclk;
input           fp_clk_sys;
input           fp_clk_adc;
input           fp_clk_arm;
input           fp_clk_usb;
input           clk_eth_tx;
//input           fp_clk_ddrc;
input           i2c0_scl_i;
input           i2c0_sda_i;
input [31:0]    gpio_0_in_i;
input           i2c1_scl_i;
input           i2c1_sda_i;
input           uart0_cts_i;
input           uart0_rxd_i;
input           uart1_cts_i;
input           uart1_rxd_i;
input           spi0_miso;
input           spi1_miso;
input           pad_can0_i_rx0;
input           pad_can1_i_rx0;

output [31:0]   gpio_0_out_o;
output [31:0]   gpio_0_oe_o;
output          i2c0_scl_oe_o;
output          i2c0_sda_oe_o;
output          i2c1_scl_oe_o;
output          i2c1_sda_oe_o;
output          uart0_rts_o;
output          uart0_txd_o;
output          uart1_rts_o;
output          uart1_txd_o;
output          spi0_mosi;
output          spi0_sck;
output          spi0_ssn;
output          spi1_mosi;
output          spi1_sck;
output          spi1_ssn;
output          pad_can0_o_clk;
output          pad_can0_o_tx1;
output          pad_can0_o_tx0;
output          pad_can0_oen_tx1;
output          pad_can0_oen_tx0;
output          pad_can1_o_clk;
output          pad_can1_o_tx1;
output          pad_can1_o_tx0;
output          pad_can1_oen_tx1;
output          pad_can1_oen_tx0;

// for fp1
input           clk_ahb_fp1;
input           rst_ahb_fp1_n;
input           fp1_m_ahb_mastlock;
input  [3: 0]   fp1_m_ahb_prot;
input  [2: 0]   fp1_m_ahb_size;
input  [31:0]   fp1_m_ahb_addr;
input           fp1_m_ahb_write;
input  [2: 0]   fp1_m_ahb_burst;
input  [1: 0]   fp1_m_ahb_trans;
input  [31:0]   fp1_m_ahb_wdata;
output          fp1_m_ahb_ready;
output          fp1_m_ahb_resp;
output [31:0]   fp1_m_ahb_rdata;
output          fp1_s_ahb_mastlock;
output [3: 0]   fp1_s_ahb_prot;
output [2: 0]   fp1_s_ahb_size;
output          fp1_s_ahb_sel;
output [31:0]   fp1_s_ahb_addr;
output          fp1_s_ahb_write;
output [2: 0]   fp1_s_ahb_burst;
output [1: 0]   fp1_s_ahb_trans;
output [31:0]   fp1_s_ahb_wdata;
input           fp1_s_ahb_readyout;
input           fp1_s_ahb_resp;
input  [31:0]   fp1_s_ahb_rdata;
input  [15:0]   fp_INTNMI;

//for fp0
input           clk_ahb_fp0;
input           rst_ahb_fp0_n;
input           fp0_m_ahb_mastlock;
input  [3 :0]   fp0_m_ahb_prot;
input  [2 :0]   fp0_m_ahb_size;
input  [31:0]   fp0_m_ahb_addr;
input           fp0_m_ahb_write;
input  [2: 0]   fp0_m_ahb_burst;
input  [1: 0]   fp0_m_ahb_trans;
input  [31:0]   fp0_m_ahb_wdata;
output          fp0_m_ahb_ready;
output          fp0_m_ahb_resp;
output [31:0]   fp0_m_ahb_rdata;
output          fp0_s_ahb_mastlock;
output [3: 0]   fp0_s_ahb_prot;
output [2: 0]   fp0_s_ahb_size;
output          fp0_s_ahb_sel;
output [31:0]   fp0_s_ahb_addr;
output          fp0_s_ahb_write;
output [2: 0]   fp0_s_ahb_burst;
output [1: 0]   fp0_s_ahb_trans;
output [31:0]   fp0_s_ahb_wdata;
input           fp0_s_ahb_readyout;
input           fp0_s_ahb_resp;
input [31:0]    fp0_s_ahb_rdata;

// internal regs and wires

wire    [31:0]        haddr_fp0;
wire    [2:0]         hburst_fp0;
wire                  hready_fp0;     
wire    [2:0]         hsize_fp0;   
wire    [1:0]         htrans_fp0;   
wire    [31:0]        hwdata_fp0;   
wire                  hwrite_fp0;     
wire                  hsel_fp0;

wire    [31:0]        haddr_fp1;
wire    [2:0]         hburst_fp1;
wire                  hready_fp1;     
wire    [2:0]         hsize_fp1;   
wire    [1:0]         htrans_fp1;   
wire    [31:0]        hwdata_fp1;   
wire                  hwrite_fp1;     
wire                  hsel_fp1;

wire  [3 :0]         pbus1_aid_s;
wire  [31:0]         pbus1_addr_s;     
wire                 pbus1_write_s;    
wire  [3 :0]         pbus1_length_s;  
wire  [3 :0]         pbus1_wbyte_en_s;            
wire  [1 :0]         pbus1_type_burst_s;            
wire                 pbus1_avalid_s;          
wire                 pbus1_aready_s;         
wire  [31:0]         pbus1_wdata_s;    
wire                 pbus1_wvalid_s;           
wire                 pbus1_wready_s;            
wire  [3 :0]         pbus1_did_s;
wire  [31:0]         pbus1_rdata_s;        
wire                 pbus1_rready_s;           
wire                 pbus1_rvalid_s; 

wire  [3 :0]         pbus1_aid_m;
wire  [31:0]         pbus1_addr_m;     
wire                 pbus1_write_m;    
wire  [3 :0]         pbus1_length_m;  
wire  [3 :0]         pbus1_wbyte_en_m;            
wire  [1 :0]         pbus1_type_burst_m;            
wire                 pbus1_avalid_m;          
wire                 pbus1_aready_m;         
wire  [31:0]         pbus1_wdata_m;    
wire                 pbus1_wvalid_m;           
wire                 pbus1_wready_m;            
wire  [3 :0]         pbus1_did_m;
wire  [31:0]         pbus1_rdata_m;        
wire                 pbus1_rready_m;           
wire                 pbus1_rvalid_m;  

wire  [3 :0]         pbus0_aid_s;
wire  [31:0]         pbus0_addr_s;     
wire                 pbus0_write_s;    
wire  [3 :0]         pbus0_length_s;  
wire  [3 :0]         pbus0_wbyte_en_s;            
wire  [1 :0]         pbus0_type_burst_s;            
wire                 pbus0_avalid_s;          
wire                 pbus0_aready_s;         
wire  [31:0]         pbus0_wdata_s;    
wire                 pbus0_wvalid_s;           
wire                 pbus0_wready_s;            
wire  [3 :0]         pbus0_did_s;
wire  [31:0]         pbus0_rdata_s;        
wire                 pbus0_rready_s;           
wire                 pbus0_rvalid_s; 

wire  [3 :0]         pbus0_aid_m;
wire  [31:0]         pbus0_addr_m;     
wire                 pbus0_write_m;    
wire  [3 :0]         pbus0_length_m;  
wire  [3 :0]         pbus0_wbyte_en_m;            
wire  [1 :0]         pbus0_type_burst_m;            
wire                 pbus0_avalid_m;          
wire                 pbus0_aready_m;         
wire  [31:0]         pbus0_wdata_m;    
wire                 pbus0_wvalid_m;           
wire                 pbus0_wready_m;            
wire  [3 :0]         pbus0_did_m;
wire  [31:0]         pbus0_rdata_m;        
wire                 pbus0_rready_m;           
wire                 pbus0_rvalid_m; 


wire  [31:0]         hrdata_fp0;
wire  [31:0]         hrdata_fp1;

wire  [31:0]         m_haddr_fp1;
wire  [2:0]		     m_hburst_fp1;			
wire  [1:0]			 m_htrans_fp1;
wire  [31:0]	     m_hwdata_fp1;
wire				 m_hwrite_fp1;
wire				 m_hsel_fp1;
wire  [31:0]		 m_hrdata_fp1;
wire				 m_hready_fp1;

wire  [31:0]         m_haddr_fp0;
wire  [2:0]		     m_hburst_fp0;			
wire  [1:0]			 m_htrans_fp0;
wire  [31:0]	     m_hwdata_fp0;
wire				 m_hwrite_fp0;
wire				 m_hsel_fp0;
wire  [31:0]		 m_hrdata_fp0;
wire				 m_hready_fp0;
    
//********************************************* //
//--------assign the output ports unused -------//
assign          gpio_0_out_o = 32'hxxxxxxxx;
assign          gpio_0_oe_o = 32'hxxxxxxxx;
assign          i2c0_scl_oe_o = 1'bx;
assign          i2c0_sda_oe_o = 1'bx;
assign          i2c1_scl_oe_o = 1'bx;
assign          i2c1_sda_oe_o = 1'bx;
assign          uart0_rts_o = 1'bx;
assign          uart0_txd_o = 1'bx;
assign          uart1_rts_o = 1'bx;
assign          uart1_txd_o = 1'bx;
assign          spi0_mosi = 1'bx;
assign          spi0_sck = 1'bx;
assign          spi0_ssn = 1'bx;
assign          spi1_mosi = 1'bx;
assign          spi1_sck = 1'bx;
assign          spi1_ssn = 1'bx;
assign          pad_can0_o_clk = 1'bx;
assign          pad_can0_o_tx1 = 1'bx;
assign          pad_can0_o_tx0 = 1'bx;
assign          pad_can0_oen_tx1 = 1'bx;
assign          pad_can0_oen_tx0 = 1'bx;
assign          pad_can1_o_clk = 1'bx;
assign          pad_can1_o_tx1 = 1'bx;
assign          pad_can1_o_tx0 = 1'bx;
assign          pad_can1_oen_tx1 = 1'bx;
assign          pad_can1_oen_tx0= 1'bx;

//**************************************//


m7s_ahb_bfm u_ahb_bfm_fp0(
				.hclk  (clk_ahb_fp0),
				.hmasterlock(),
				.hprot (),
				.hsize (),
				.haddr (haddr_fp0),
				.hburst(hburst_fp0),
				.htrans(htrans_fp0),
				.hwdata(hwdata_fp0),
				.hwrite(hwrite_fp0),
				.hsel  (),

				.hrdata(hrdata_fp0),
				.hready(hready_fp0),
				.hresp (1'b0),
				// master
				.m_hclk(clk_ahb_fp0),
				.m_hresetn(rst_ahb_fp0_n),
				.m_haddr(m_haddr_fp0),
				.m_hburst(m_hburst_fp0),
				.m_hmasterlock(),
				.m_hprot(),
				.m_hsize(),
				.m_htrans(m_htrans_fp0),
				.m_hwdata(m_hwdata_fp0),
				.m_hwrite(m_hwrite_fp0),
				.m_hsel(m_hsel_fp0),

				.m_hrdata(m_hrdata_fp0),
				.m_hready(m_hready_fp0),
				.m_hresp()
);

defparam u_ahb_bfm_fp0.SIM_FIFO = SIM_FIFO;
defparam u_ahb_bfm_fp0.START_ADDR = START_ADDR;

m7s_ahb_bfm u_ahb_bfm_fp1(
				.hclk  (clk_ahb_fp1),
				.hmasterlock(),
				.hprot (),
				.hsize (),
				.haddr (haddr_fp1),
				.hburst(hburst_fp1),
				.htrans(htrans_fp1),
				.hwdata(hwdata_fp1),
				.hwrite(hwrite_fp1),
				.hsel  (),

				.hrdata(hrdata_fp1),
				.hready(hready_fp1),
				.hresp (1'b0),
				// master
				.m_hclk(clk_ahb_fp1),
				.m_hresetn(rst_ahb_fp1_n),
				.m_haddr(m_haddr_fp1),
				.m_hburst(m_hburst_fp1),
				.m_hmasterlock(),
				.m_hprot(),
				.m_hsize(),
				.m_htrans(m_htrans_fp1),
				.m_hwdata(m_hwdata_fp1),
				.m_hwrite(m_hwrite_fp1),
				.m_hsel(m_hsel_fp1),

				.m_hrdata(m_hrdata_fp1),
				.m_hready(m_hready_fp1),
				.m_hresp()
);
defparam u_ahb_bfm_fp1.SIM_FIFO = SIM_FIFO;
defparam u_ahb_bfm_fp1.START_ADDR = START_ADDR;

m7s_hm2pm_if_async  hm2pm_fp1_s_inst(
                 .clk_pbus(clk_ahb_fp1),
                 .rst_pbus_n(rst_ahb_fp1_n),
                 .clk_ahb(clk_ahb_fp1),
                 .rst_ahb_n(rst_ahb_fp1_n),

                 .ahb_mastlock(1'b0),
                 .ahb_prot(4'b0),
                 .ahb_size(3'b10),   // 32 bits

                 .ahb_addr(haddr_fp1),
                 .ahb_write(hwrite_fp1),
                 .ahb_burst(hburst_fp1),
                 .ahb_trans(htrans_fp1),
                 .ahb_wdata(hwdata_fp1),

                 .ahb_ready(hready_fp1),
                 .ahb_resp(),
                 .ahb_rdata(hrdata_fp1),

                 .pbus_aid(pbus1_aid_s),
                 .pbus_addr(pbus1_addr_s),  
                 .pbus_write(pbus1_write_s),         
                 .pbus_length(pbus1_length_s),
                 .pbus_wbyte_en(pbus1_wbyte_en_s),
                 .pbus_type_burst(pbus1_type_burst_s),
                 .pbus_avalid(pbus1_avalid_s),
                 .pbus_aready(pbus1_aready_s),
                 .pbus_wdata(pbus1_wdata_s),
                 .pbus_wvalid(pbus1_wvalid_s),
                 .pbus_wready(pbus1_wready_s),

                 .pbus_did(pbus1_did_s),
                 .pbus_rdata(pbus1_rdata_s),
                 .pbus_rready(pbus1_rready_s),
                 .pbus_rvalid(pbus1_rvalid_s)
                );
				

m7s_ps2hs_if_async ps2hs_fp1_s_inst(
                .clk_pbus(clk_ahb_fp1),
                .rst_pbus_n(rst_ahb_fp1_n),
                .clk_ahb(clk_ahb_fp1),
                .rst_ahb_n(rst_ahb_fp1_n),

                .pbus_aid(pbus1_aid_s),
                .pbus_addr(pbus1_addr_s),
                .pbus_write(pbus1_write_s),
                .pbus_length(pbus1_length_s),
                .pbus_wbyte_en(pbus1_wbyte_en_s),
                .pbus_type_burst(pbus1_type_burst_s),
                .pbus_avalid(pbus1_avalid_s),
                .pbus_aready(pbus1_aready_s),
                .pbus_wdata(pbus1_wdata_s),
                .pbus_wvalid(pbus1_wvalid_s),
                .pbus_wready(pbus1_wready_s),

                .pbus_did(pbus1_did_s),
                .pbus_rdata(pbus1_rdata_s),
                .pbus_rready(pbus1_rready_s),
                .pbus_rvalid(pbus1_rvalid_s),

                .ahb_mastlock(),
                .ahb_prot(),
                .ahb_size(),

                .ahb_sel(fp1_s_ahb_sel),
                .ahb_addr(fp1_s_ahb_addr),
                .ahb_write(fp1_s_ahb_write),
                .ahb_burst(fp1_s_ahb_burst),
                .ahb_trans(fp1_s_ahb_trans),
                .ahb_wdata(fp1_s_ahb_wdata),

                .ahb_readyin(),
                .ahb_readyout(fp1_s_ahb_readyout),
                .ahb_resp(1'b0), //no care
                .ahb_rdata(fp1_s_ahb_rdata)
                );
				
defparam ps2hs_fp1_s_inst.SIM_FIFO = SIM_FIFO;
				
m7s_hm2pm_if_async  hm2pm_fp0_s_inst(
                 .clk_pbus(clk_ahb_fp0),
                 .rst_pbus_n(rst_ahb_fp0_n),
                 .clk_ahb(clk_ahb_fp0),
                 .rst_ahb_n(rst_ahb_fp0_n),

                 .ahb_mastlock(1'b0),
                 .ahb_prot(4'b0),
                 .ahb_size(3'b10),   // 32 bits

                 .ahb_addr(haddr_fp0),
                 .ahb_write(hwrite_fp0),
                 .ahb_burst(hburst_fp0),
                 .ahb_trans(htrans_fp0),
                 .ahb_wdata(hwdata_fp0),

                 .ahb_ready(hready_fp0),
                 .ahb_resp(),
                 .ahb_rdata(hrdata_fp0),

                 .pbus_aid(pbus0_aid_s),
                 .pbus_addr(pbus0_addr_s),  
                 .pbus_write(pbus0_write_s),         
                 .pbus_length(pbus0_length_s),
                 .pbus_wbyte_en(pbus0_wbyte_en_s),
                 .pbus_type_burst(pbus0_type_burst_s),
                 .pbus_avalid(pbus0_avalid_s),
                 .pbus_aready(pbus0_aready_s),
                 .pbus_wdata(pbus0_wdata_s),
                 .pbus_wvalid(pbus0_wvalid_s),
                 .pbus_wready(pbus0_wready_s),

                 .pbus_did(pbus0_did_s),
                 .pbus_rdata(pbus0_rdata_s),
                 .pbus_rready(pbus0_rready_s),
                 .pbus_rvalid(pbus0_rvalid_s)
                );
				
m7s_ps2hs_if_async ps2hs_fp0_s_inst(
                .clk_pbus(clk_ahb_fp0),
                .rst_pbus_n(rst_ahb_fp0_n),
                .clk_ahb(clk_ahb_fp0),
                .rst_ahb_n(rst_ahb_fp0_n),

                .pbus_aid(pbus0_aid_s),
                .pbus_addr(pbus0_addr_s),
                .pbus_write(pbus0_write_s),
                .pbus_length(pbus0_length_s),
                .pbus_wbyte_en(pbus0_wbyte_en_s),
                .pbus_type_burst(pbus0_type_burst_s),
                .pbus_avalid(pbus0_avalid_s),
                .pbus_aready(pbus0_aready_s),
                .pbus_wdata(pbus0_wdata_s),
                .pbus_wvalid(pbus0_wvalid_s),
                .pbus_wready(pbus0_wready_s),

                .pbus_did(pbus0_did_s),
                .pbus_rdata(pbus0_rdata_s),
                .pbus_rready(pbus0_rready_s),
                .pbus_rvalid(pbus0_rvalid_s),

                .ahb_mastlock(),
                .ahb_prot(),
                .ahb_size(),

                .ahb_sel(fp0_s_ahb_sel),
                .ahb_addr(fp0_s_ahb_addr),
                .ahb_write(fp0_s_ahb_write),
                .ahb_burst(fp0_s_ahb_burst),
                .ahb_trans(fp0_s_ahb_trans),
                .ahb_wdata(fp0_s_ahb_wdata),

                .ahb_readyin(),
                .ahb_readyout(fp0_s_ahb_readyout),
                .ahb_resp(1'b0), //no care
                .ahb_rdata(fp0_s_ahb_rdata)
                );
defparam ps2hs_fp0_s_inst.SIM_FIFO = SIM_FIFO;

//////////////////////////////////////////////////////
// for master                                       //
//////////////////////////////////////////////////////

m7s_hm2pm_if_async  hm2pm_fp1_m_inst(
                 .clk_pbus(clk_ahb_fp1),
                 .rst_pbus_n(rst_ahb_fp1_n),
                 .clk_ahb(clk_ahb_fp1),
                 .rst_ahb_n(rst_ahb_fp1_n),

                 .ahb_mastlock(fp1_m_ahb_mastlock),//1'b0
                 .ahb_prot(fp1_m_ahb_prot),//4'b0
                 .ahb_size(fp1_m_ahb_size),   // 32 bits 3'b10

                 .ahb_addr(fp1_m_ahb_addr),
                 .ahb_write(fp1_m_ahb_write),
                 .ahb_burst(fp1_m_ahb_burst),
                 .ahb_trans(fp1_m_ahb_trans),
                 .ahb_wdata(fp1_m_ahb_wdata),

                 .ahb_ready(fp1_m_ahb_ready),
                 .ahb_resp(fp1_m_ahb_resp),
                 .ahb_rdata(fp1_m_ahb_rdata),

                 .pbus_aid(pbus1_aid_m),
                 .pbus_addr(pbus1_addr_m),  
                 .pbus_write(pbus1_write_m),         
                 .pbus_length(pbus1_length_m),
                 .pbus_wbyte_en(pbus1_wbyte_en_m),
                 .pbus_type_burst(pbus1_type_burst_m),
                 .pbus_avalid(pbus1_avalid_m),
                 .pbus_aready(pbus1_aready_m),
                 .pbus_wdata(pbus1_wdata_m),
                 .pbus_wvalid(pbus1_wvalid_m),
                 .pbus_wready(pbus1_wready_m),

                 .pbus_did(pbus1_did_m),
                 .pbus_rdata(pbus1_rdata_m),
                 .pbus_rready(pbus1_rready_m),
                 .pbus_rvalid(pbus1_rvalid_m)
                );
				

m7s_ps2hs_if_async ps2hs_fp1_m_inst(
                .clk_pbus(clk_ahb_fp1),
                .rst_pbus_n(rst_ahb_fp1_n),
                .clk_ahb(clk_ahb_fp1),
                .rst_ahb_n(rst_ahb_fp1_n),

                .pbus_aid(pbus1_aid_m),
                .pbus_addr(pbus1_addr_m),
                .pbus_write(pbus1_write_m),
                .pbus_length(pbus1_length_m),
                .pbus_wbyte_en(pbus1_wbyte_en_m),
                .pbus_type_burst(pbus1_type_burst_m),
                .pbus_avalid(pbus1_avalid_m),
                .pbus_aready(pbus1_aready_m),
                .pbus_wdata(pbus1_wdata_m),
                .pbus_wvalid(pbus1_wvalid_m),
                .pbus_wready(pbus1_wready_m),

                .pbus_did(pbus1_did_m),
                .pbus_rdata(pbus1_rdata_m),
                .pbus_rready(pbus1_rready_m),
                .pbus_rvalid(pbus1_rvalid_m),

				.ahb_mastlock(),
                .ahb_prot(),
                .ahb_size(),

                .ahb_sel(m_hsel_fp1),
                .ahb_addr(m_haddr_fp1),
                .ahb_write(m_hwrite_fp1),
                .ahb_burst(m_hburst_fp1),
                .ahb_trans(m_htrans_fp1),
                .ahb_wdata(m_hwdata_fp1),

                .ahb_readyin(),
                .ahb_readyout(m_hready_fp1),
                .ahb_resp(1'b0), //no care
                .ahb_rdata(m_hrdata_fp1)
                );
				
defparam ps2hs_fp1_m_inst.SIM_FIFO = SIM_FIFO;
				
m7s_hm2pm_if_async  hm2pm_fp0_m_inst(
                 .clk_pbus(clk_ahb_fp0),
                 .rst_pbus_n(rst_ahb_fp0_n),
                 .clk_ahb(clk_ahb_fp0),
                 .rst_ahb_n(rst_ahb_fp0_n),

                 .ahb_mastlock(fp0_m_ahb_mastlock),//1'b0
                 .ahb_prot(fp0_m_ahb_prot),//4'b0
                 .ahb_size(fp0_m_ahb_size),   // 32 bits,3'b10

                 .ahb_addr(fp0_m_ahb_addr),
                 .ahb_write(fp0_m_ahb_write),
                 .ahb_burst(fp0_m_ahb_burst),
                 .ahb_trans(fp0_m_ahb_trans),
                 .ahb_wdata(fp0_m_ahb_wdata),

                 .ahb_ready(fp0_m_ahb_ready),
                 .ahb_resp(fp0_m_ahb_resp),
                 .ahb_rdata(fp0_m_ahb_rdata),

                 .pbus_aid(pbus0_aid),
                 .pbus_addr(pbus0_addr),  
                 .pbus_write(pbus0_write),         
                 .pbus_length(pbus0_length),
                 .pbus_wbyte_en(pbus0_wbyte_en),
                 .pbus_type_burst(pbus0_type_burst),
                 .pbus_avalid(pbus0_avalid),
                 .pbus_aready(pbus0_aready),
                 .pbus_wdata(pbus0_wdata),
                 .pbus_wvalid(pbus0_wvalid),
                 .pbus_wready(pbus0_wready),

                 .pbus_did(pbus0_did),
                 .pbus_rdata(pbus0_rdata),
                 .pbus_rready(pbus0_rready),
                 .pbus_rvalid(pbus0_rvalid)
                );
				
m7s_ps2hs_if_async ps2hs_fp0_m_inst(
                .clk_pbus(clk_ahb_fp0),
                .rst_pbus_n(rst_ahb_fp0_n),
                .clk_ahb(clk_ahb_fp0),
                .rst_ahb_n(rst_ahb_fp0_n),

                .pbus_aid(pbus0_aid),
                .pbus_addr(pbus0_addr),
                .pbus_write(pbus0_write),
                .pbus_length(pbus0_length),
                .pbus_wbyte_en(pbus0_wbyte_en),
                .pbus_type_burst(pbus0_type_burst),
                .pbus_avalid(pbus0_avalid),
                .pbus_aready(pbus0_aready),
                .pbus_wdata(pbus0_wdata),
                .pbus_wvalid(pbus0_wvalid),
                .pbus_wready(pbus0_wready),

                .pbus_did(pbus0_did),
                .pbus_rdata(pbus0_rdata),
                .pbus_rready(pbus0_rready),
                .pbus_rvalid(pbus0_rvalid),

                .ahb_mastlock(),
                .ahb_prot(),
                .ahb_size(),

                .ahb_sel(m_hsel_fp0),
                .ahb_addr(m_haddr_fp0),
                .ahb_write(m_hwrite_fp0),
                .ahb_burst(m_hburst_fp0),
                .ahb_trans(m_htrans_fp0),
                .ahb_wdata(m_hwdata_fp0),

                .ahb_readyin(),
                .ahb_readyout(m_hready_fp0),
                .ahb_resp(1'b0), //no care
                .ahb_rdata(m_hrdata_fp0)
                );
defparam ps2hs_fp0_m_inst.SIM_FIFO = SIM_FIFO;

endmodule

