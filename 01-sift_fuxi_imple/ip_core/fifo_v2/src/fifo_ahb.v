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
// This is the core of ahb_inf_fifo IP 
//================================================================================
// Revision History :
//     V1.1   2013-12-05  FPGA IP Grp, first created
//     V2.0   2014-06-20  FPGA IP Grp, add FWFT function
//================================================================================

module cme_ip_fifo_ahb_v2 (         
    hclk, 
    hresetn,
    haddr, 
    hsel,
    htrans, 
    hwrite,
    hsize, 
    hburst,
    hready_out,
    hwdata, 
    hrdata,
    hresp,
    //ahb_fifo_interrupt
    ahb_fifo_int,
    //connect with FIFO
    clk,
	rst_n,
	wclk,
    rclk,
    wrst_n,
    rrst_n,
    wclr,
    rclr,
	fifo_clr,
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
	prog_empty_assert,
	prog_full_negate,
	prog_empty_negate
);

//-----------------
// parameters
//-----------------
// set by users
parameter BASE_ADDR = 32'hc000_0000;
parameter WORK_MODE = 0;//1-asyn,0-syn
parameter WR_AHB_INF = 1;//1-AHB,0-FIFO
parameter RD_AHB_INF = 1;//1-AHB,0-FIFO

parameter WR_DATA_WIDTH = 4;
parameter RD_DATA_WIDTH = 4;
parameter WR_ADDR_WIDTH = 9;
parameter RD_ADDR_WIDTH = 9;

//const
parameter HADDR_WIDTH= 32;
parameter HRESP_WIDTH = 1;
parameter HTRANS_WIDTH = 2;
parameter AHB_DATA_WIDTH = 32;
parameter HSIZE_WIDTH = 3;
parameter HBURST_WIDTH = 3;

//-----------------
// IO declarations
//-----------------
input  [HADDR_WIDTH-1:0]    haddr;      // AHB address
input                       hclk;       // AHB system clock
input                       hresetn;    // AHB system reset
input                       hsel;       // AHB slave select signal
input  [HTRANS_WIDTH-1:0]   htrans;     // AHB transfer control
input                       hwrite;     // AHB write/not read signal
input  [HSIZE_WIDTH-1:0]    hsize;      // only support 32 bit
input  [HBURST_WIDTH-1:0]   hburst;  
input  [AHB_DATA_WIDTH-1:0] hwdata;     // AHB write data bus

output [AHB_DATA_WIDTH-1:0] hrdata;     // AHB read data bus
output                      hready_out;// hready output
output [HRESP_WIDTH-1:0]    hresp;      // AHB response bus

output                      ahb_fifo_int;

//for fifo
input                       almost_full;
input                       almost_empty;
input                       prog_full;
input                       prog_empty;
input  [WR_ADDR_WIDTH-1:0]  wr_data_cnt;
input  [RD_ADDR_WIDTH-1:0]  rd_data_cnt;
input                       rempty;
input                       wfull;
input  [RD_DATA_WIDTH-1:0]  rdata;

output                       clk;
output                       rst_n;
output                       wen;
output                       ren;
output                       wclk;
output                       rclk;
output                       wrst_n;
output                       rrst_n;
output                       wclr;
output                       rclr;
output                       fifo_clr;
output  [WR_DATA_WIDTH-1:0]  wdata;

output  [WR_ADDR_WIDTH-1:0]  prog_full_thresh;
output	[RD_ADDR_WIDTH-1:0]  prog_empty_thresh;
output	[WR_ADDR_WIDTH-1:0]  prog_full_assert;
output	[RD_ADDR_WIDTH-1:0]  prog_empty_assert;
output	[WR_ADDR_WIDTH-1:0]  prog_full_negate;
output	[RD_ADDR_WIDTH-1:0]  prog_empty_negate;


//-----------------------------
// Internal registers and wires
//-----------------------------
reg                       slave_sel;
reg                       slave_write;
//reg                       slave_read;
reg                       slave_readyout;

reg                       slave_command_sel;
reg                       slave_command_sel_d;
reg [AHB_DATA_WIDTH-1:0]  slave_command_rdata;
reg [WR_ADDR_WIDTH -1:0]  fifo_wr_data_cnt_r;//{wr_data_cnt}
reg [RD_ADDR_WIDTH -1:0]  fifo_rd_data_cnt_r;//{rd_data_cnt}

reg [3:0]                 slave_command_addr;//each command register is 32bits, and register No. no more than 16
reg [5:0]                 fifo_status_r;//{prog_empty, prog_full, almost_empty, almost_full, rempty, wfull}
reg [3:0]                 fifo_ctrl_r;
reg [5:0]                 fifo_int_enable_r;
reg [5:0]                 fifo_int_status_r;
reg                       ahb_fifo_int;

reg  [WR_ADDR_WIDTH-1:0]  prog_full_thresh;
reg	 [RD_ADDR_WIDTH-1:0]  prog_empty_thresh;
reg	 [WR_ADDR_WIDTH-1:0]  prog_full_assert;
reg	 [RD_ADDR_WIDTH-1:0]  prog_empty_assert;
reg	 [WR_ADDR_WIDTH-1:0]  prog_full_negate;
reg	 [RD_ADDR_WIDTH-1:0]  prog_empty_negate;


wire                      hard_fifo_clr;
wire                      fifo_wen;
wire                      fifo_ren;
wire                      fifo_wclr;
wire                      fifo_rclr;

wire                      sel_fifo;
wire                      sel_register;
wire                      sel_data;


//-----------------------------
// Implement
//-----------------------------

//------------------------------fpga as slave part 1, memory space-------------------------------
//---
//------------------------------------decode ------------------------------------------------//

assign sel_fifo = (haddr[31:6] == BASE_ADDR[31:6])? 1'b1:1'b0;
assign sel_data = ((sel_fifo == 1'b1)&&(haddr[5:0] == 6'b0));
assign sel_register = sel_fifo & ~sel_data;

//--------------------------generate control signals ------------------------------------//


reg slave_sel_w;
always@(posedge hclk, negedge hresetn) begin
    if(!hresetn)
        slave_sel_w <= 0;
    else if(hsel && sel_data && htrans[1]) 
        slave_sel_w <= 1;
    else
        slave_sel_w <= 0;
end



always@(posedge hclk, negedge hresetn) begin
    if(!hresetn)
        slave_write <= 0;
    else if(hsel && htrans[1] && hwrite)
        slave_write <= 1;
    else
        slave_write <= 0;
end


wire slave_read_command = (!hwrite) & hsel & sel_register & htrans[1];

wire slave_read;
assign slave_read = (!hwrite) & hsel & sel_data & htrans[1];

assign hready_out = 1;
assign fifo_wen = slave_sel_w && slave_write && (!wfull);
//assign fifo_ren = slave_sel && slave_read && (!rempty);
assign fifo_ren = slave_read && (!rempty);// && htrans[1];
assign hresp = 1'b0;


//------------------------------fpga as slave part 2, command space-------------------------------
//---
//--------------------------generate control signals ------------------------------------//

always@(posedge hclk, negedge hresetn) begin
    if(!hresetn)
        slave_command_sel <= 0;
	else if(hsel && sel_register) 
        slave_command_sel <= 1;
    else
        slave_command_sel <= 0;
end
//added by mwang 624
wire slave_command_sel_r = hsel && sel_register;
wire [3:0]slave_command_addr_r = haddr[5:2];
/////////////////

always@(posedge hclk, negedge hresetn) begin
    if(!hresetn)
        slave_command_sel_d <= 0;
    else
        slave_command_sel_d <= slave_command_sel_r;
end

always@(posedge hclk, negedge hresetn) begin
    if(!hresetn)
        slave_command_addr <= 0;
    else
        slave_command_addr <= haddr[5:2]; //each command register is 32bits, and register No. no more than 16
end

//Register Status, RO, offset:0, value[5:0]:{prog_empty, prog_full, almost_empty, almost_full, rempty, wfull}
always@(posedge hclk, negedge hresetn) begin
    if(!hresetn)
        fifo_status_r <= 0;
    else
        fifo_status_r <= {prog_empty, prog_full, almost_empty, almost_full, rempty, wfull};
end

wire [5:0] fifo_status = {prog_empty, prog_full, almost_empty, almost_full, rempty, wfull};

//Register Wr_data_cnt, RO, offset:4
always@(posedge hclk, negedge hresetn) begin
    if(!hresetn)
        fifo_wr_data_cnt_r <= 0;
    else
        fifo_wr_data_cnt_r <= wr_data_cnt;
end

//Register Rd_data_cnt, RO, offset:8
always@(posedge hclk, negedge hresetn) begin
    if(!hresetn)
        fifo_rd_data_cnt_r <= 0;
    else
        fifo_rd_data_cnt_r <= rd_data_cnt;
end

//Register Ctrl, RW, offset:c, value[2:0]:{wclr, rclr, all_int_enable}
//                                         wclr: 1 write-port-clear, 0 no-change
//                                         rclr: 1 read-port-clear, 0 no-change
//                                         all_int_enable: 1 all-interrupt-enabled, 0 all-interrupt-disabled
//Register Int_enable, RW, offset:10, value[5:0]:{prog_empty_IE, prog_full_IE, almost_empty_IE, almost_full_IE, rempty_IE, wfull_IE}

always@(posedge hclk, negedge hresetn) begin
    if(!hresetn) begin
        fifo_ctrl_r <= 0;
        fifo_int_enable_r <= 0;
		prog_full_thresh  <= 0;
	    prog_empty_thresh <= 0;
        prog_full_assert  <= 0;
        prog_empty_assert <= 0;
        prog_full_negate  <= 0;
        prog_empty_negate <= 0;
    end
    else if(slave_command_sel && slave_write) begin
        case(slave_command_addr)
           4'h1: //addr == BASE_ADDR+4;
                prog_full_thresh <= hwdata[WR_ADDR_WIDTH -1 :0];
           4'h2: //addr == BASE_ADDR+8;
                prog_empty_thresh <= hwdata[RD_ADDR_WIDTH -1 :0];
           4'h3: //addr == BASE_ADDR+C;
                prog_full_assert  <= hwdata[WR_ADDR_WIDTH -1 :0];
		   4'h4: //addr == BASE_ADDR+10;
                prog_empty_assert <= hwdata[RD_ADDR_WIDTH -1 :0];
		   4'h5: //addr == BASE_ADDR+14;
                prog_full_negate  <= hwdata[WR_ADDR_WIDTH -1 :0];
		   4'h6: //addr == BASE_ADDR+18;
                prog_empty_negate <= hwdata[RD_ADDR_WIDTH -1 :0];
		   4'h7: //addr == BASE_ADDR+1C;
                fifo_ctrl_r       <= hwdata[3:0];
           4'h8: //addr == BASE_ADDR+20;
                fifo_int_enable_r <= hwdata[5:0];
            default: begin
                fifo_ctrl_r <= fifo_ctrl_r;
                fifo_int_enable_r <= fifo_int_enable_r;
            end
        endcase
    end
end

assign hard_fifo_clr = fifo_ctrl_r[3];
assign fifo_wclr = fifo_ctrl_r[2];
assign fifo_rclr = fifo_ctrl_r[1];

//Register Int_status, RWC, offset:14
always@(posedge hclk, negedge hresetn) begin
    if(!hresetn) begin
        fifo_int_status_r <= 0;
        ahb_fifo_int <= 0;
    end
    else if(fifo_int_status_r == 0 && fifo_ctrl_r[0]) begin
        fifo_int_status_r <= fifo_status_r & fifo_int_enable_r;
        ahb_fifo_int <= |(fifo_status_r & fifo_int_enable_r);
    end
   // else if(slave_command_sel && slave_read_command && slave_command_addr == 4'hc) begin //slave_read//clear the interrupt status and interrupt signal when this register is read
   else if(slave_command_sel_r && slave_read_command && slave_command_addr_r == 4'hc) begin //clear the interrupt status and interrupt signal when this register is read
        fifo_int_status_r <= 0;
        ahb_fifo_int <= 0;
    end
end

//read registers value
always@(posedge hclk, negedge hresetn) begin
    if(!hresetn)
        slave_command_rdata <= 0;
    //else if(slave_command_sel && slave_read_command) begin  //slave_read
        //case(slave_command_addr)
    else if(slave_command_sel_r && slave_read_command) begin
        case(slave_command_addr_r)
		    4'h1: //addr == BASE_ADDR+4;
			    slave_command_rdata <= {{(32-WR_ADDR_WIDTH){1'b0}},prog_full_thresh};
                
            4'h2: //addr == BASE_ADDR+8;
			    slave_command_rdata <= {{(32-RD_ADDR_WIDTH){1'b0}},prog_empty_thresh};
                
            4'h3: //addr == BASE_ADDR+C;
			    slave_command_rdata <= {{(32-WR_ADDR_WIDTH){1'b0}},prog_full_assert};
               
		    4'h4: //addr == BASE_ADDR+10;
			    slave_command_rdata <= {{(32-RD_ADDR_WIDTH){1'b0}},prog_empty_assert};
                
		    4'h5: //addr == BASE_ADDR+14;
			    slave_command_rdata <= {{(32-WR_ADDR_WIDTH){1'b0}},prog_full_negate};
                
		    4'h6: //addr == BASE_ADDR+18;
			    slave_command_rdata <= {{(32-RD_ADDR_WIDTH){1'b0}},prog_empty_negate};
             
            4'h7: //addr == BASE_ADDR+1C;
                slave_command_rdata <= {28'h0,fifo_ctrl_r};
				
            4'h8: //addr == BASE_ADDR+20;
                slave_command_rdata <= {26'h0,fifo_int_enable_r};
				
			4'h9: //addr == BASE_ADDR+24;
                slave_command_rdata <= {26'h0,fifo_status_r};
				//slave_command_rdata <= {26'h0,fifo_status};
				
            4'ha: //addr == BASE_ADDR+28;
                slave_command_rdata <= {{(32-WR_ADDR_WIDTH){1'b0}},fifo_wr_data_cnt_r};
				//slave_command_rdata <= {{(32-WR_ADDR_WIDTH){1'b0}},fifo_wr_data_cnt};
				
            4'hb: //addr == BASE_ADDR+2C;
                slave_command_rdata <= {{(32-RD_ADDR_WIDTH){1'b0}},fifo_rd_data_cnt_r};
				//slave_command_rdata <= {{(32-RD_ADDR_WIDTH){1'b0}},fifo_rd_data_cnt};
            4'hc: //addr == BASE_ADDR+30;
                slave_command_rdata <= {26'h0,fifo_int_status_r};
				
            default:
                slave_command_rdata <= 32'h0;
        endcase
    end
end

//////////////////////////////////////////////////////////////////////
generate 
    if((WR_AHB_INF == 1)&&(RD_AHB_INF == 1))
    begin
		assign clk     = hclk;
		assign rst_n   = hresetn;
		assign wen     = fifo_wen;
		assign ren     = fifo_ren;
		assign wclr    = fifo_wclr;
		assign rclr    = fifo_rclr;
		assign fifo_clr = hard_fifo_clr;
	    assign wdata   = hwdata[WR_DATA_WIDTH -1:0];
		assign hrdata  = slave_command_sel_d ? slave_command_rdata : {{(32-RD_DATA_WIDTH){1'b0}},rdata};
		//assign hrdata  = slave_command_sel ? slave_command_rdata : {{(32-RD_DATA_WIDTH){1'b0}},rdata};
    end

    if((WR_AHB_INF == 1)&&(RD_AHB_INF == 0))
    begin
        if(WORK_MODE == 1)
        begin
		    assign wclk    = hclk;
		    assign wrst_n  = hresetn;
			assign wen     = fifo_wen;
			assign wclr    = fifo_wclr;
	        assign wdata   = hwdata[WR_DATA_WIDTH -1:0];
			assign hrdata  = slave_command_sel_d ? slave_command_rdata : 32'd0;
        end
        if(WORK_MODE == 0)
        begin
		   assign clk     = hclk;
		   assign rst_n   = hresetn;
		   assign wen     = fifo_wen;
		   assign wclr    = fifo_wclr;
	       assign wdata   = hwdata[WR_DATA_WIDTH -1:0];
		   assign hrdata  = slave_command_sel_d ? slave_command_rdata : 32'd0;
       end
    end

    if((WR_AHB_INF == 0)&&(RD_AHB_INF == 1))
    begin
        if(WORK_MODE == 1)
        begin
		    assign rclk    = hclk;
		    assign rrst_n  = hresetn;
		    assign ren     = fifo_ren;
			assign rclr    = fifo_rclr;
		    assign hrdata  = slave_command_sel_d ? slave_command_rdata : {{(32-RD_DATA_WIDTH){1'b0}},rdata};
        end
        if(WORK_MODE == 0)
        begin
		    assign clk     = hclk;
		    assign rst_n   = hresetn;
		    assign ren     = fifo_ren;
			assign rclr    = fifo_rclr;
		    assign hrdata  = slave_command_sel_d ? slave_command_rdata : {{(32-RD_DATA_WIDTH){1'b0}},rdata};
        end 
    end   
endgenerate 


endmodule 

