//
// This is a file generated by FIFO wizard.
// Please do not edit this file!
// Generated time: 06/24/2014 15:17:42
// Version: Primace 6.0 master
// Wizard name: FIFO 2.0a
//
// ============================================================
// File Name: fifo_v2_sim.v
// IP core : fifo
// Device name: M7A12N0F484C7
// ============================================================

module fifo_v2_sim(
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
    wr_ack,
    rd_ack,
    overflow,
    underflow,
    rempty,
    wfull
);

input clk;
input rst_n;
input wclr;
input rclr;
input [31:0] wdata;
output [31:0] rdata;
input wen;
input ren;
output almost_full;
output almost_empty;
output prog_full;
output prog_empty;
output [8:0] wr_data_cnt;
output [8:0] rd_data_cnt;
output wr_ack;
output rd_ack;
output overflow;
output underflow;
output rempty;
output wfull;

wire clkw;
assign clkw = clk;
wire clkr;
assign clkr = clk;
wire cew;
wire cer;
wire [8:0] ar;
wire [8:0] aw;
wire [31:0] dw;
wire [31:0] qr;

wire [17:0] qr0;
wire [17:0] qr1;
wire [17:0] qr2;
wire [17:0] qr3;
reg [0:0] ar_reg;
always @(posedge clkr) begin
	 begin
		ar_reg <= ar[8];
	end
end
assign qr = (~ar_reg[0])? {qr1[15], qr0[15], qr1[14], qr0[14], qr1[13], qr0[13], qr1[12], qr0[12], qr1[11], qr0[11], qr1[10], qr0[10], qr1[9], qr0[9], qr1[8], qr0[8], qr1[7], qr0[7], qr1[6], qr0[6], qr1[5], qr0[5], qr1[4], qr0[4], qr1[3], qr0[3], qr1[2], qr0[2], qr1[1], qr0[1], qr1[0], qr0[0]} :
            {qr3[15], qr2[15], qr3[14], qr2[14], qr3[13], qr2[13], qr3[12], qr2[12], qr3[11], qr2[11], qr3[10], qr2[10], qr3[9], qr2[9], qr3[8], qr2[8], qr3[7], qr2[7], qr3[6], qr2[6], qr3[5], qr2[5], qr3[4], qr2[4], qr3[3], qr2[3], qr3[2], qr2[2], qr3[1], qr2[1], qr3[0], qr2[0]};

M7S_EMB18K #(
        .width_ext_mode (1'b1),
        .depth_ext_mode (1'b0),
        .dedicated_cfg (16'b1111111111111111),
        .fifo_en (1'b0),
        .emb5k_1_porta_prog (8'b11110000),
        .emb5k_1_portb_prog (8'b00001111),
        .emb5k_1_modea_sel (4'b0000),
        .emb5k_1_modeb_sel (4'b0000),
        .emb5k_1_porta_wr_mode (2'b00),
        .emb5k_1_portb_wr_mode (2'b00),
        .emb5k_1_porta_reg_out (1'b0),
        .emb5k_1_portb_reg_out (1'b0),
        .emb5k_1_reset_value_a (9'b000000000),
        .emb5k_1_reset_value_b (9'b000000000),
        .emb5k_1_porta_data_width (16),
        .emb5k_1_portb_data_width (16),
        .emb5k_1_operation_mode ("simple_dual_port"),
        .emb5k_1_init_file (""),
        .emb5k_2_porta_prog (8'b11110000),
        .emb5k_2_portb_prog (8'b00001111),
        .emb5k_2_modea_sel (4'b0000),
        .emb5k_2_modeb_sel (4'b0000),
        .emb5k_2_porta_wr_mode (2'b00),
        .emb5k_2_portb_wr_mode (2'b00),
        .emb5k_2_porta_reg_out (1'b0),
        .emb5k_2_portb_reg_out (1'b0),
        .emb5k_2_reset_value_a (9'b000000000),
        .emb5k_2_reset_value_b (9'b000000000),
        .emb5k_2_porta_data_width (16),
        .emb5k_2_portb_data_width (16),
        .emb5k_2_operation_mode ("simple_dual_port"),
        .emb5k_2_init_file (""),
        .emb5k_3_porta_prog (8'b11110000),
        .emb5k_3_portb_prog (8'b00001111),
        .emb5k_3_modea_sel (4'b0000),
        .emb5k_3_modeb_sel (4'b0000),
        .emb5k_3_porta_wr_mode (2'b00),
        .emb5k_3_portb_wr_mode (2'b00),
        .emb5k_3_porta_reg_out (1'b0),
        .emb5k_3_portb_reg_out (1'b0),
        .emb5k_3_reset_value_a (9'b000000000),
        .emb5k_3_reset_value_b (9'b000000000),
        .emb5k_3_porta_data_width (16),
        .emb5k_3_portb_data_width (16),
        .emb5k_3_operation_mode ("simple_dual_port"),
        .emb5k_3_init_file (""),
        .emb5k_4_porta_prog (8'b11110000),
        .emb5k_4_portb_prog (8'b00001111),
        .emb5k_4_modea_sel (4'b0000),
        .emb5k_4_modeb_sel (4'b0000),
        .emb5k_4_porta_wr_mode (2'b00),
        .emb5k_4_portb_wr_mode (2'b00),
        .emb5k_4_porta_reg_out (1'b0),
        .emb5k_4_portb_reg_out (1'b0),
        .emb5k_4_reset_value_a (9'b000000000),
        .emb5k_4_reset_value_b (9'b000000000),
        .emb5k_4_porta_data_width (16),
        .emb5k_4_portb_data_width (16),
        .emb5k_4_operation_mode ("simple_dual_port"),
        .emb5k_4_init_file ("")
)
u_emb18k_0 (
        .wfull (),
        .wfull_almost (),
        .rempty (),
        .rempty_almost (),
        .overflow (),
        .wr_ack (),
        .underflow (),
        .rd_ack (),
        .fifo_clr (),
        .wr_req_n (),
        .rd_req_n (),
        .rd_ha (),
        .rd_la (),
        .cea (cer),
        .ceb (cew),
        .haa ({1'b0, ar[8]}),
        .hab ({1'b0, aw[8]}),
        .wea (1'b0),
        .web (1'b1),
        .c1r1_cea (),
        .c1r1_ceb (),
        .c1r1_wea (),
        .c1r1_web (),
        .c1r1_clka (clkr),
        .c1r1_clkb (clkw),
        .c1r1_rstna (1'b1),
        .c1r1_rstnb (1'b1),
        .c1r1_aa ({ar[7:0], 4'b0}),
        .c1r1_ab ({aw[7:0], 4'b0}),
        .c1r1_da (),
        .c1r1_db ({2'b0, dw[30], dw[28], dw[26], dw[24], dw[22], dw[20], dw[18], dw[16], dw[14], dw[12], dw[10], dw[8], dw[6], dw[4], dw[2], dw[0]}),
        .c1r1_q (qr0),
        .c1r2_cea (),
        .c1r2_ceb (),
        .c1r2_wea (),
        .c1r2_web (),
        .c1r2_clka (clkr),
        .c1r2_clkb (clkw),
        .c1r2_rstna (1'b1),
        .c1r2_rstnb (1'b1),
        .c1r2_aa (),
        .c1r2_ab (),
        .c1r2_da (),
        .c1r2_db ({2'b0, dw[31], dw[29], dw[27], dw[25], dw[23], dw[21], dw[19], dw[17], dw[15], dw[13], dw[11], dw[9], dw[7], dw[5], dw[3], dw[1]}),
        .c1r2_q (qr1),
        .c1r3_cea (),
        .c1r3_ceb (),
        .c1r3_wea (),
        .c1r3_web (),
        .c1r3_clka (clkr),
        .c1r3_clkb (clkw),
        .c1r3_rstna (1'b1),
        .c1r3_rstnb (1'b1),
        .c1r3_aa (),
        .c1r3_ab (),
        .c1r3_da (),
        .c1r3_db ({2'b0, dw[30], dw[28], dw[26], dw[24], dw[22], dw[20], dw[18], dw[16], dw[14], dw[12], dw[10], dw[8], dw[6], dw[4], dw[2], dw[0]}),
        .c1r3_q (qr2),
        .c1r4_cea (),
        .c1r4_ceb (),
        .c1r4_wea (),
        .c1r4_web (),
        .c1r4_clka (clkr),
        .c1r4_clkb (clkw),
        .c1r4_rstna (1'b1),
        .c1r4_rstnb (1'b1),
        .c1r4_aa (),
        .c1r4_ab (),
        .c1r4_da (),
        .c1r4_db ({2'b0, dw[31], dw[29], dw[27], dw[25], dw[23], dw[21], dw[19], dw[17], dw[15], dw[13], dw[11], dw[9], dw[7], dw[5], dw[3], dw[1]}),
        .c1r4_q (qr3)
);

cme_ip_syn_fifo_v2 #(
        .wr_dw (32),
        .rd_dw (32),
        .wr_aw (9),
        .rd_aw (9),
        .wr_depth (512),
        .rd_depth (512),
        .fwft_en (1'b0),
        .tDLY (1),
        .gen_prog_full_type (3'b001),
        .gen_prog_empty_type (3'b001),
        .prog_full_const (6),
        .prog_empty_const (4),
        .prog_full_assert_const (250),
        .prog_full_negate_const (246),
        .prog_empty_assert_const (6),
        .prog_empty_negate_const (10),
        .gen_almost_full (1'b1),
        .gen_almost_empty (1'b1),
        .gen_prog_full (1'b1),
        .gen_prog_empty (1'b1),
        .gen_wr_data_cnt (1'b1),
        .gen_rd_data_cnt (1'b1),
        .gen_wr_ack (1'b1),
        .gen_rd_ack (1'b1),
        .gen_wr_overflow (1'b1),
        .gen_rd_underflow (1'b1),
        .need_syn_wr_clr (1'b1),
        .need_syn_rd_clr (1'b1)
)
u_syn_fifo (
        .clk (clk),
        .rst_n (rst_n),
        .wclr (wclr),
        .rclr (rclr),
        .wdata (wdata),
        .rdata (rdata),
        .wen (wen),
        .ren (ren),
        .almost_full (almost_full),
        .almost_empty (almost_empty),
        .prog_full (prog_full),
        .prog_empty (prog_empty),
        .wr_data_cnt (wr_data_cnt),
        .rd_data_cnt (rd_data_cnt),
        .rempty (rempty),
        .wfull (wfull),
        .prog_full_thresh (),
        .prog_empty_thresh (),
        .prog_full_assert (),
        .prog_full_negate (),
        .prog_empty_assert (),
        .prog_empty_negate (),
        .wr_ack (wr_ack),
        .rd_ack (rd_ack),
        .overflow (overflow),
        .underflow (underflow),
        .mem_waddr (aw),
        .mem_wdata (dw),
        .mem_cew (cew),
        .mem_cer (cer),
        .mem_raddr (ar),
        .mem_rdata (qr)
);

endmodule

// ============================================================
//                  fifo Setting
//
// Warning: This part is read by Primace, please don't modify it.
// ============================================================
// Device          : M7A12N0F484C7
// Module          : fifo_v2_sim
// IP core         : fifo
// IP Version      : 2

// AHBMode         : ahb_unused
// BaseAddr        : a0000000
// Simulation Files: ../ip_core/fifo_v2/sim/src_vp/syn_fifo.vp ../ip_core/fifo_v2/sim/src_vp/asyn_fifo.vp ../ip_core/fifo_v2/sim/src_vp/fifo_ahb.vp
// Synthesis Files : src/syn_fifo.v src/asyn_fifo.v src/fifo_ahb.v
// alempty         : 1
// alfull          : 1
// emptyassert     : 6
// emptynegate     : 10
// emptysingle     : 4
// emptytype       : 1
// fifoclr         : false
// fifotype        : software
// fullassert      : 250
// fullnegate      : 246
// fullsingle      : 6
// fulltype        : 1
// fwft            : false
// overflow        : 1
// rack            : 1
// raddr           : 9
// rclr            : 1
// rcnt            : 1
// rwidth          : 32
// underflow       : 1
// usehw           : false
// wack            : 1
// waddr           : 9
// wclr            : 1
// wcnt            : 1
// workmode        : 0
// wwidth          : 32
