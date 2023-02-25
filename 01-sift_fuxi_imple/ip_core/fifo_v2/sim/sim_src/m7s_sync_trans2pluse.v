`timescale 1ns / 1ps
//*************************************************
//company:   capital-micro
//author:    nn.sun
//date:      20121106
//function:   1)transfer one cycle pluse between two async clock domains
//                                  ____        ____        ____        ____        ____        ____        
//                 src_clk         /    \      /    \      /    \      /    \      /    \      /    \
//                            ____/      \____/      \____/      \____/      \____/      \____/      \
//                                 _____________  __________                          
//                 src_trans                    \/                   
//                               _______________/\_____________________
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
module m7s_sync_trans2pluse (
     dst_rst_n
    ,dst_clk
    ,src_trans
    ,dst_pluse
    );

//--------------------------------------------------------
// Port define
//--------------------------------------------------------
input     dst_rst_n;
input     dst_clk;
input     src_trans;
output    dst_pluse;

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
//assign  dst_pluse  = dst_trans_d != dst_trans ;

reg    [4:0]    r_msk_after_drst;
always @ (posedge dst_clk or negedge dst_rst_n)begin
    if (dst_rst_n==1'b0) begin
        r_msk_after_drst <= `DLY 5'b0;
    end else begin
        r_msk_after_drst <= `DLY {r_msk_after_drst[3:0],1'b1};
    end
end
assign  dst_pluse  = !r_msk_after_drst[4] ? 0 : dst_trans_d != dst_trans ;



endmodule      
