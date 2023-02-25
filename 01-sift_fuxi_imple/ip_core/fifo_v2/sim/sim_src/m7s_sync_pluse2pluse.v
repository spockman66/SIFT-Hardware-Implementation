`timescale 1ns / 1ps
//*************************************************
//company:   capital-micro
//author:    nn.sun
//date:      20121106
//function:   1)transfer one cycle pluse between two async clock domains
//                                  ____        ____        ____        ____        ____        ____        
//                 src_clk         /    \      /    \      /    \      /    \      /    \      /    \
//                            ____/      \____/      \____/      \____/      \____/      \____/      \
//                                                __________                          
//                 src_pluse                     /          \          
//                               _______________/            \______________________
//                                                               __      __      __      __      __      __        
//                 dst_clk                                      /  \    /  \    /  \    /  \    /  \    /  \
//                                                         ____/    \__/    \__/    \__/    \__/    \__/    \
//                                                                                ______                          
//                 dst_pluse                                                     /      \          
//                                                               _______________/        \______________________
//            2)
//*************************************************
//$Log: .v,v $
`ifdef DLY
`else
`define DLY #1
`endif
module m7s_sync_pluse2pluse (
     src_rst_n
    ,src_clk
    ,dst_rst_n
    ,dst_clk
    ,src_pluse
    ,dst_pluse
    );

//--------------------------------------------------------
// Port define
//--------------------------------------------------------
input     src_rst_n;
input     src_clk;
input     dst_rst_n;
input     dst_clk;
input     src_pluse;
output    dst_pluse;

reg src_trans;
always @ (posedge src_clk or negedge src_rst_n)begin
    if    (src_rst_n==1'b0) begin
        src_trans <= `DLY 1'b0;
    end
    else if(src_pluse) begin
        src_trans <= `DLY !src_trans;
    end
end

wire dst_trans;
m7s_sync_single  U_sync_single_trans(
    .dst_rst_n     (dst_rst_n),
    .dst_clk       (dst_clk),
    .src_dat       (src_trans),
    .dst_dat       (dst_trans)
    );

reg dst_trans_d;
always @ (posedge dst_clk or negedge dst_rst_n)begin
    if    (dst_rst_n==1'b0) begin
        dst_trans_d <= `DLY 1'b0;
    end
    else begin
        dst_trans_d <= `DLY dst_trans;
    end
end


reg    [4:0]    r_msk_after_drst;
wire   mask_rst_n = dst_rst_n & src_rst_n ;
always @ (posedge dst_clk or negedge mask_rst_n)begin
    if (mask_rst_n==1'b0) begin
        r_msk_after_drst <= `DLY 5'b0;
    end else begin
        r_msk_after_drst <= `DLY {r_msk_after_drst[3:0],1'b1};
    end
end
assign  dst_pluse  = !r_msk_after_drst[4] ? 0 : dst_trans_d != dst_trans ;



endmodule      
