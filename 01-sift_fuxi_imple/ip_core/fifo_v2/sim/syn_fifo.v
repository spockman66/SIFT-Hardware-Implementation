//================================================================================
// Copyright (c) 2014 Capital-micro, Inc.(Beijing)  All rights reserved.
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
// This is the verilog for synchronous FIFO
//================================================================================
// Revision History :
//     V1.0   2012-08-27  FPGA IP Grp, first create
//     V1.0   2012-10-13  FPGA IP Grp, support read and write with different
//                        data width, support more flexible prog_full/empty
//                        generation
//     V1.1   2013-04-10  Replace parameter prog_full/empty_type value with number  
//     V2.0   2014-06-11  Add FWFT function
//================================================================================
`timescale 1ns / 1ps

module cme_ip_syn_fifo_v2 (
    clk,
    rst_n,
    wclr,
    rclr,
    wdata,
    rdata,
    wen,
    ren,
    almost_full,
    almost_empty,
    prog_full,
    prog_empty,
    wr_data_cnt, 
    rd_data_cnt,
    rempty,
    wfull,
    prog_full_thresh,
    prog_empty_thresh,
    prog_full_assert,
    prog_full_negate,
    prog_empty_assert,
    prog_empty_negate,
    wr_ack,
    rd_ack,
    overflow,
    underflow,
    mem_waddr,
    mem_wdata,
    mem_cew,
    mem_cer,
    mem_raddr,
    mem_rdata
);

//---------------------------------------------------------------------
// parameters
//---------------------------------------------------------------------
parameter wr_dw = 16;
parameter rd_dw = 8;
parameter wr_aw = 12;
parameter rd_aw = 13;
parameter wr_depth = 1 << wr_aw;
parameter rd_depth = 1 << rd_aw;
parameter tDLY = 1;
parameter gen_prog_full_type = 3'b000; //000("none"), (001)"single", (010)"dyn_single", (011)"range", (100)"dyn_range"
parameter gen_prog_empty_type = 3'b000; //000("none"), (001)"single", (010)"dyn_single", (011)"range", (100)"dyn_range'
parameter prog_full_const = wr_depth-4;
parameter prog_empty_const = 4;
parameter prog_full_assert_const = wr_depth - 6;  //less then wr_depth
parameter prog_full_negate_const = wr_depth - 10; //less than assert const value
parameter prog_empty_assert_const = 6;  //less than negate const          
parameter prog_empty_negate_const = 10; //less than rd_depth - 1<<sh_bits        
parameter gen_almost_full = 1;
parameter gen_almost_empty = 1;
parameter gen_prog_full = 1;
parameter gen_prog_empty = 1;
parameter gen_wr_data_cnt = 1;
parameter gen_rd_data_cnt = 1;
parameter gen_wr_ack = 1;
parameter gen_rd_ack = 1;
parameter gen_wr_overflow = 1;
parameter gen_rd_underflow = 1;
parameter need_syn_wr_clr = 1;
parameter need_syn_rd_clr = 1;
parameter fwft_en = 1;

parameter sh_bits = wr_dw>=rd_dw ? (wr_dw/rd_dw == 1 ? 0 : 
		  wr_dw/rd_dw == 2 ? 1 :  
		  wr_dw/rd_dw == 4 ? 2 :  
		  wr_dw/rd_dw == 8 ? 3 :  
		  wr_dw/rd_dw == 16 ? 4 :  
		  wr_dw/rd_dw == 32 ? 5 : 0) : 
          rd_dw/wr_dw == 1 ? 0 : 
		  rd_dw/wr_dw == 2 ? 1 :  
		  rd_dw/wr_dw == 4 ? 2 :  
		  rd_dw/wr_dw == 8 ? 3 :  
		  rd_dw/wr_dw == 16 ? 4 :  
		  rd_dw/wr_dw == 32 ? 5 : 0; 

parameter aw_base = wr_dw>=rd_dw ? wr_aw : rd_aw;
parameter almost_full_flag = (1 << wr_aw) - 1;

//---------------------------------------------------------------------
// inputs
//---------------------------------------------------------------------
input clk;
input rst_n;
input wclr,rclr;
input wen,ren;
input [wr_dw-1:0] wdata;

input [wr_aw-1:0] prog_full_thresh;
input [rd_aw-1:0] prog_empty_thresh;
input [wr_aw-1:0] prog_full_assert;
input [wr_aw-1:0] prog_full_negate;
input [rd_aw-1:0] prog_empty_assert;
input [rd_aw-1:0] prog_empty_negate;

//---------------------------------------------------------------------
// outputs
//---------------------------------------------------------------------
output [rd_dw-1:0] rdata;
output rempty,wfull;

output [wr_aw-1:0] wr_data_cnt;
output [rd_aw-1:0] rd_data_cnt;

output almost_full;
output almost_empty;
output prog_full;
output prog_empty;

output wr_ack, rd_ack;
output overflow, underflow;

//---------------------------------------------------------------------
// fifo memory interface
//---------------------------------------------------------------------
output [wr_aw-1:0] mem_waddr;
output [rd_aw-1:0] mem_raddr;
output [wr_dw-1:0] mem_wdata;
input  [rd_dw-1:0] mem_rdata;

output mem_cew;
output mem_cer;


//---------------------------------------------------------------------
// internal regs/wires
//---------------------------------------------------------------------
reg wfull,rempty;

reg [wr_aw-1:0] wr_data_cnt;
reg [rd_aw-1:0] rd_data_cnt;

reg almost_full;
reg almost_empty;
reg prog_full;
reg prog_empty;

wire [rd_aw:0] rbin_next;
reg [rd_aw:0] rbin;

wire [wr_aw:0] wbin_next;
reg [wr_aw:0] wbin;

reg wr_ack; //rd_ack;
reg overflow, underflow;

wire wr_clr = need_syn_wr_clr ? wclr : 1'b0;
wire rd_clr = need_syn_rd_clr ? rclr : 1'b0;

//---------------------------------------------------------------------
// output for fifo memory
//---------------------------------------------------------------------
assign mem_cew = wen&~wfull;

assign mem_wdata = wdata;
assign rdata = mem_rdata;

//---------------------------------------------------------------------
// read pointer & empty generation logic
//---------------------------------------------------------------------
wire rempty_val; 
reg rd_ack;
reg [wr_aw:0]wbin_next_d; 
wire [rd_aw:0] rd_data_cnt_val;


assign rbin_next = (ren & ~rempty) ? (rbin + 1) : rbin;

always @ (posedge clk or negedge rst_n)
	if(~rst_n)
		rbin <= #tDLY 0;
    else if(rd_clr)
		rbin <= #tDLY 0;
	else
		rbin <= #tDLY rbin_next;
		
				  
always @ (posedge clk or negedge rst_n)
	if(~rst_n)
		rempty <= #tDLY 1;
    else if(rd_clr)
		rempty <= #tDLY 1;
	else
		rempty <= #tDLY rempty_val;



generate
if(fwft_en == 1)begin

always @ (posedge clk or negedge rst_n)
	if(~rst_n)
		wbin_next_d <= #tDLY 0;
    else if(rd_clr)
		wbin_next_d <= #tDLY 0;
	else
		wbin_next_d <= #tDLY wbin_next;
		
always @ (posedge clk or negedge rst_n)
    if(~rst_n)
        rd_ack <= #tDLY 0;
    else if(rd_clr)
        rd_ack <= #tDLY 0;
    else
        rd_ack <= #tDLY gen_rd_ack ?  ~rempty_val : 1'b0;

assign mem_raddr = rbin[rd_aw-1:0] + !(rempty);
assign mem_cer = ren&~rempty | (rempty);

assign rempty_val = rd_dw <= wr_dw ? (rbin_next[rd_aw:sh_bits] == wbin_next_d[wr_aw:0]) :
                  (rbin_next[rd_aw:0] == wbin_next_d[wr_aw:sh_bits]);
				  

assign  rd_data_cnt_val[rd_aw:0] = (rd_dw <= wr_dw) ? ({wbin_next_d[wr_aw:0],{sh_bits{1'b0}}} - rbin_next[rd_aw:0]) :
                                 (wbin_next_d[wr_aw:sh_bits] - rbin_next[rd_aw:0]) ;
end
else begin

always @ (posedge clk or negedge rst_n)
    if(~rst_n)
        rd_ack <= #tDLY 0;
    else if(rd_clr)
        rd_ack <= #tDLY 0;
    else
        rd_ack <= #tDLY gen_rd_ack ? (ren & ~rempty) : 1'b0;
assign mem_raddr = rbin[rd_aw-1:0];
assign mem_cer = ren&~rempty;

assign rempty_val = rd_dw <= wr_dw ? (rbin_next[rd_aw:sh_bits] == wbin_next[wr_aw:0]) :
                  (rbin_next[rd_aw:0] == wbin_next[wr_aw:sh_bits]);
				  

assign rd_data_cnt_val[rd_aw:0] = (rd_dw <= wr_dw) ? ({wbin_next[wr_aw:0],{sh_bits{1'b0}}} - rbin_next[rd_aw:0]) :
                                 (wbin_next[wr_aw:sh_bits] - rbin_next[rd_aw:0]) ;
end
endgenerate


//---------------------------------------------------------------------
// write pointer & full generation logic
//---------------------------------------------------------------------
assign wbin_next = (wen & ~wfull) ? (wbin + 1) : wbin;

always @ (posedge clk or negedge rst_n)
	if(~rst_n)
		wbin <= #tDLY 0;
    else if(wr_clr)
		wbin <= #tDLY 0;
	else
        wbin <= #tDLY wbin_next;

wire wfull_val = wr_dw <= rd_dw ? 
                 (wbin_next[wr_aw] != rbin_next[rd_aw]) && 
                 (wbin_next[wr_aw-1:sh_bits] == rbin_next[rd_aw-1:0]) :
                 (wbin_next[wr_aw] != rbin_next[rd_aw]) && 
                 (wbin_next[wr_aw-1:0] == rbin_next[rd_aw-1:sh_bits]);

always @ (posedge clk or negedge rst_n)
	if(~rst_n)
		wfull <= #tDLY 0;
    else if(wr_clr)
		wfull <= #tDLY 0;
	else
		wfull <= #tDLY wfull_val;

assign mem_waddr = wbin[wr_aw-1:0];

//---------------------------------------------------------------------
// common logic for almost_full/empty and prog_full/empty generation
//---------------------------------------------------------------------

wire [wr_aw:0] wr_data_cnt_val = (wr_dw <= rd_dw) ? (wbin_next[wr_aw:0] - {rbin_next[rd_aw:0],{sh_bits{1'b0}}}) :
                                 (wbin_next[wr_aw:0] - rbin_next[rd_aw:sh_bits]) ;


//---------------------------------------------------------------------
// almost full/empty generation
//---------------------------------------------------------------------
wire almost_full_val = wr_data_cnt_val == almost_full_flag; 

always @ (posedge clk or negedge rst_n)
    if(~rst_n)
        almost_full <= #tDLY 0;
    else if(wr_clr)
        almost_full <= #tDLY 0;
    else
        almost_full <= #tDLY gen_almost_full ? almost_full_val : 1'b0;

wire almost_empty_val = rd_data_cnt_val == 1;

always @ (posedge clk or negedge rst_n)
    if(~rst_n)
        almost_empty <= #tDLY 0;
    else if(rd_clr)
        almost_empty <= #tDLY 0;
    else
        almost_empty <= #tDLY gen_almost_empty ? almost_empty_val : 1'b0;

wire full_wr = wr_data_cnt_val[wr_aw] & (wr_data_cnt_val[wr_aw-1:0] == 0);
wire prog_full_val = gen_prog_full_type == 3'b001 ? ((wr_data_cnt_val[wr_aw-1:0] >= prog_full_const)||full_wr) :
                     gen_prog_full_type == 3'b010 ? ((wr_data_cnt_val[wr_aw-1:0] >= prog_full_thresh)||full_wr) :
                     gen_prog_full_type == 3'b011 ? (~prog_full ? (wr_data_cnt_val[wr_aw-1:0] >= prog_full_assert_const)||full_wr : (wr_data_cnt_val[wr_aw-1:0] >= prog_full_negate_const)||full_wr) :
                     gen_prog_full_type == 3'b100 ? (~prog_full ? (wr_data_cnt_val[wr_aw-1:0] >= prog_full_assert)||full_wr : (wr_data_cnt_val[wr_aw-1:0] >= prog_full_negate)||full_wr) :
                     gen_prog_full_type == 3'b000 ? 1'b0 : 1'b0;

always @ (posedge clk or negedge rst_n)
    if(~rst_n)
        prog_full <= #tDLY 0;
    else if(wr_clr)
        prog_full <= #tDLY 0;
    else
        prog_full <= #tDLY gen_prog_full ? prog_full_val : 1'b0;

wire full_rd = rd_data_cnt_val[rd_aw] & (rd_data_cnt_val[rd_aw-1:0] == 0);
wire prog_empty_val = gen_prog_empty_type == 3'b001 ? ((rd_data_cnt_val[rd_aw-1:0] <= prog_empty_const)&~full_rd) :
                      gen_prog_empty_type == 3'b010 ? ((rd_data_cnt_val[rd_aw-1:0] <= prog_empty_thresh)&~full_rd) :
                      gen_prog_empty_type == 3'b011 ? (~prog_empty ? (rd_data_cnt_val[rd_aw-1:0] <= prog_empty_assert_const)&~full_rd : (rd_data_cnt_val[rd_aw-1:0] <= prog_empty_negate_const)&~full_rd) :
                      gen_prog_empty_type == 3'b100 ? (~prog_empty ? (rd_data_cnt_val[rd_aw-1:0] <= prog_empty_assert)&~full_rd : (rd_data_cnt_val[rd_aw-1:0] <= prog_empty_negate)&~full_rd) :
                      gen_prog_empty_type == 3'b000 ? 1'b0 : 1'b0;

always @ (posedge clk or negedge rst_n)
    if(~rst_n)
        prog_empty <= #tDLY 0;
    else if(rd_clr)
        prog_empty <= #tDLY 0;
    else
        prog_empty <= #tDLY gen_prog_empty ? prog_empty_val : 1'b0;

//---------------------------------------------------------------------
// wr_data_cnt and rd_data_cnt generation
//---------------------------------------------------------------------
always @ (posedge clk or negedge rst_n)
    if(~rst_n)
        wr_data_cnt <= #tDLY 0;
    else if(wr_clr)
        wr_data_cnt <= #tDLY 0;
    else
        wr_data_cnt <= #tDLY gen_wr_data_cnt ? wr_data_cnt_val[wr_aw-1:0] : 0;

always @ (posedge clk or negedge rst_n)
    if(~rst_n)
        rd_data_cnt <= #tDLY 0;
    else if(rd_clr)
        rd_data_cnt <= #tDLY 0;
    else
        rd_data_cnt <= #tDLY gen_rd_data_cnt ? rd_data_cnt_val[rd_aw-1:0] : 0;

//---------------------------------------------------------------------
// handshaking signal generation
//---------------------------------------------------------------------
always @ (posedge clk or negedge rst_n)
    if(~rst_n)
        wr_ack <= #tDLY 0;
    else if(wr_clr)
        wr_ack <= #tDLY 0;
    else
        wr_ack <= #tDLY gen_wr_ack ? (wen & ~wfull) : 1'b0;



always @ (posedge clk or negedge rst_n)
    if(~rst_n)
        overflow <= #tDLY 0;
    else if(wr_clr)
        overflow <= #tDLY 0;
    else
        overflow <= #tDLY gen_wr_overflow ? (wen & wfull) : 1'b0;

always @ (posedge clk or negedge rst_n)
    if(~rst_n)
        underflow <= #tDLY 0;
    else if(rd_clr)
        underflow <= #tDLY 0;
    else
        underflow <= #tDLY gen_rd_underflow ? (ren & rempty) : 1'b0;



endmodule


