`timescale 1ns / 1ps
//*************************************************
//company:   capital-micro
//author:    nn.sun
//date:      20121106
//function:   1)the synchronizer between two clock domains
//            2)data_width and default_value could be changed by parameter
//*************************************************
//$Log: .v,v $
`ifdef DLY
`else
`define DLY #1
`endif
module m7s_sync_single (
     dst_rst_n
    ,dst_clk
    ,src_dat
    ,dst_dat
    );

//--------------------------------------------------------
// Parameter define
//--------------------------------------------------------
parameter SYNC_BW =1;
parameter DEFAULT_VALUE='b0;

//--------------------------------------------------------
// Port define
//--------------------------------------------------------
input                  dst_rst_n;
input                  dst_clk;
input   [SYNC_BW-1:0]  src_dat;
output  [SYNC_BW-1:0]  dst_dat;

reg     [SYNC_BW-1:0] synchronizer_tmp_stage1;
reg     [SYNC_BW-1:0] dst_dat;

always @ (posedge dst_clk or negedge dst_rst_n) begin
   if(~dst_rst_n) begin
       synchronizer_tmp_stage1 <= `DLY DEFAULT_VALUE;
       dst_dat    <= `DLY DEFAULT_VALUE;
   end else begin
       synchronizer_tmp_stage1 <= `DLY src_dat;
       dst_dat    <= `DLY synchronizer_tmp_stage1;
   end
end
endmodule      
