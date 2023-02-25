`timescale 1ns / 1ps
//*************************************************
//company:   capital-micro
//author:    nn.sun
//date:      20121106
//function:   1)pbus slave interface transfer to ahb slave interface ;
//            2)async clock domain transfer
//*************************************************
//$Log: .v,v $

`ifdef DLY
`else
`define DLY #1
`endif

module    m7s_ps2hs_if_async(
                clk_pbus,
                rst_pbus_n,

                clk_ahb,
                rst_ahb_n,

                pbus_aid,
                pbus_addr,            // addr
                pbus_write,            //1: write 0:read
                pbus_length,            //burst length, 
                pbus_wbyte_en,            //
                pbus_type_burst,            //
                pbus_avalid,           //addr valid, high active
                  pbus_aready,            //addr accept
                pbus_wdata,    //
                pbus_wvalid,           //wdata valid,high active
                  pbus_wready,            //wdata accept

                  pbus_did,
                  pbus_rdata,        //rdata
                pbus_rready,           //ready for rdata,high active
                  pbus_rvalid,            //rdata  valid

                  ahb_mastlock, // no care
                  ahb_prot, // no care
                  ahb_size, // 

                  ahb_sel,
                  ahb_addr,
                  ahb_write,
                  ahb_burst,
                  ahb_trans,
                  ahb_wdata,

                ahb_readyin,
                ahb_readyout,
                ahb_resp, //no care
                ahb_rdata

                );


parameter SIM_FIFO = 0;
// ahb trans
parameter IDLE     = 2'b00;
parameter BUSY     = 2'b01;
parameter NONSEQ   = 2'b10;
parameter SEQ      = 2'b11;

// ahb burst type
parameter SINGLE   = 3'b000;
parameter INCR     = 3'b001;
parameter WRAP4    = 3'b010;
parameter INCR4    = 3'b011;
parameter WRAP8    = 3'b100;
parameter INCR8    = 3'b101;
parameter WRAP16   = 3'b110;
parameter INCR16   = 3'b111;

                                  
//clk and reset
input           clk_pbus;
input           rst_pbus_n;

input           clk_ahb;
input           rst_ahb_n;

//interface with pbus
input    [7:0]  pbus_aid;
input   [31:0]  pbus_addr;            // addr
input           pbus_write;            //1: write 0:read
input    [3:0]  pbus_length;            //burst length, 
input    [3:0]  pbus_wbyte_en;            //
input    [1:0]  pbus_type_burst;            //
input           pbus_avalid;           //addr valid, high active
output            pbus_aready;            //addr accept
input   [31:0]  pbus_wdata;    //
input           pbus_wvalid;           //wdata valid,high active
output            pbus_wready;            //wdata accept

output   [7:0]    pbus_did;
output  [31:0]    pbus_rdata;        //rdata
input           pbus_rready;           //ready for rdata,high active
output            pbus_rvalid;            //rdata  valid


//interface with ahb

output            ahb_mastlock; // no care
output     [3:0]  ahb_prot; // no care
output     [2:0]  ahb_size; //

output            ahb_sel;
output    [31:0]  ahb_addr;
output            ahb_write;
output     [2:0]  ahb_burst;
output     [1:0]  ahb_trans;
output    [31:0]  ahb_wdata;

output          ahb_readyin;
input           ahb_readyout;
input           ahb_resp; //no care
input   [31:0]  ahb_rdata;
//----------------------------------------
// internal reg
//----------------------------------------
reg h_wr_single_gnt;
reg h_wr_brst_1st_gnt;
reg h_wr_brst_next_gnt;
reg h_rd_single_gnt;
reg h_rd_brst_1st_gnt;
reg h_rd_brst_next_gnt;
reg [1:0]    h_cur_state, h_next_state;
reg [4:0] h_gnt_count;
reg [1:0]    p_cur_state, p_next_state;
reg [4:0] p_cnt;
reg            pbus_rvalid ;
reg            ahb_write   ;
reg            ahb_sel     ;
reg [2:0]      ahb_burst   ;
reg [1:0]      ahb_trans   ;
reg [31:0]     ahb_addr    ;


wire       p_wsta_rfifo_over;
wire       p_rsta_rfifo_over;
wire       p_avld;
wire       wfifo_full;
wire       pbus_wvld;
wire       rfifo_empty;
wire       ahb_ready= ahb_readyout;
wire       h_avld;
wire       h_write;
wire       h_wsta_rfifo_over;
wire       h_rsta_wfifo_over;
wire [3:0] h_length;
wire       wfifo_empty;
wire [31:0] h_addr;
wire [1:0] h_type_burst;

reg [2:0] p_size ;
wire      p_wvld_1st ;
wire      h_wvld_1st ;
//----------------------------------------
// pbus clock domain
//----------------------------------------

assign p_avld = pbus_avalid & pbus_aready;
assign p_wvld = pbus_wvalid & pbus_wready;
assign p_rvld = pbus_rready & pbus_rvalid;

// pbus state
parameter P_IDLE   = 2'd0 ;
//parameter P_CMD    = 2'd1 ;
parameter P_WSTA   = 2'd2 ;
parameter P_RSTA   = 2'd3 ;
                                  
always @ (posedge clk_pbus or negedge rst_pbus_n)begin
    if    (rst_pbus_n==1'b0) begin
       p_cur_state  <= `DLY P_IDLE;
    end
    else begin
       p_cur_state  <= `DLY p_next_state;
    end
end
always @ (*) begin
    case(p_cur_state)
       P_IDLE : if(pbus_avalid)  begin
                  if (pbus_write)
                    p_next_state = P_WSTA;
                  else
                    p_next_state = P_RSTA;
               end
               else
                    p_next_state = p_cur_state;
       P_WSTA: if(p_wsta_rfifo_over) begin
                    p_next_state = P_IDLE;
               end
               else
                    p_next_state = p_cur_state;
       P_RSTA: if(p_rsta_rfifo_over) begin
                    p_next_state = P_IDLE;
               end
               else
                    p_next_state = p_cur_state;
     default:  p_next_state = P_IDLE;
    endcase
end

assign pbus_aready = (p_cur_state==P_IDLE) & pbus_avalid;

always @ (posedge clk_pbus or negedge rst_pbus_n)begin
    if    (rst_pbus_n==1'b0) begin
       p_cnt  <= `DLY 'd0;
    end
    else if (p_avld)begin
       p_cnt  <= `DLY pbus_length + 1;
    end
    else if (p_wvld || p_rvld)begin
       p_cnt  <= `DLY p_cnt -1;
    end
end
//assign pbus_wready = !wfifo_full;
assign pbus_wready = !wfifo_full && (p_cur_state==P_WSTA) ;
assign p_wfifo_wr = p_wvld;
assign p_rfifo_rd = (!rfifo_empty) && (!pbus_rvalid);
assign p_rsta_rfifo_over = p_rvld & (p_cnt=='d1);

always @ (posedge clk_pbus or negedge rst_pbus_n)begin
    if    (rst_pbus_n==1'b0) begin
       pbus_rvalid  <= `DLY 1'b0;
    end
    else if (p_rfifo_rd)begin
       pbus_rvalid  <= `DLY 1'b1;
    end
    else if (p_rvld)begin
       pbus_rvalid  <= `DLY 1'b0;
    end
end

reg   [31:0]  p_addr;            // addr
reg           p_write;            //1: write 0:read
reg    [3:0]  p_length;            //burst length, 
reg    [1:0]  p_type_burst;            //

always @ (posedge clk_pbus or negedge rst_pbus_n)begin
    if    (rst_pbus_n==1'b0) begin
//       p_addr        <= `DLY 'd0;
       p_write       <= `DLY 'd0;
       p_length      <= `DLY 'd0;
       p_type_burst  <= `DLY 'd0;
    end
    else if (p_avld)begin
//       p_addr        <= `DLY pbus_addr        ;
       p_write       <= `DLY pbus_write       ;
       p_length      <= `DLY pbus_length      ;
       p_type_burst  <= `DLY pbus_type_burst  ;
    end
end

assign    pbus_did = pbus_aid;
assign   p_wvld_1st = p_wvld && (p_cnt==(p_length + 1));
always @ (posedge clk_pbus or negedge rst_pbus_n)begin
    if    (rst_pbus_n==1'b0) begin
       p_size  <= `DLY 'd2;
       p_addr        <= `DLY 'd0;
    end
    else if (p_avld)begin
       p_size  <= `DLY 'd2; // 32bit for read
       p_addr        <= `DLY pbus_addr        ;
    end
    else if (p_wvld_1st)begin //write , 1st wvld
       case (pbus_wbyte_en)
         4'b0001: begin 
                  p_size  <= `DLY 'd0;
                  p_addr  <= `DLY p_addr        ;
                  end
         4'b0010: begin 
                  p_size  <= `DLY 'd0;
                  p_addr  <= `DLY p_addr  + 1   ;
                  end
         4'b0100: begin 
                  p_size  <= `DLY 'd0;
                  p_addr  <= `DLY p_addr  + 2   ;
                  end
         4'b1000: begin 
                  p_size  <= `DLY 'd0;
                  p_addr  <= `DLY p_addr  + 3   ;
                  end
         4'b0011: begin 
                  p_size  <= `DLY 'd1;
                  p_addr  <= `DLY p_addr        ;
                  end
         4'b1100: begin 
                  p_size  <= `DLY 'd1;
                  p_addr  <= `DLY p_addr  + 2   ;
                  end
         default: begin 
                  p_size  <= `DLY 'd2;
                  p_addr  <= `DLY p_addr        ;
                  end
       endcase
    end
end
//----------------------------------------
// ahb clock domain
//----------------------------------------
always @ (*)begin
    if ((ahb_trans==NONSEQ)&& ahb_write && ahb_ready) // incr or wrap burst
          h_wr_brst_1st_gnt = 1'b1;
    else
          h_wr_brst_1st_gnt = 1'b0;
end
always @ (*)begin
    if ((ahb_trans==SEQ)&& ahb_write && ahb_ready) // incr or wrap burst
          h_wr_brst_next_gnt = 1'b1;
    else
          h_wr_brst_next_gnt = 1'b0;
end

always @ (*)begin
    if ((ahb_trans==NONSEQ)&& !ahb_write && ahb_ready) // incr or wrap burst
          h_rd_brst_1st_gnt = 1'b1;
    else
          h_rd_brst_1st_gnt = 1'b0;
end
always @ (*)begin
    if ((ahb_trans==SEQ)&& !ahb_write && ahb_ready) // incr or wrap burst
          h_rd_brst_next_gnt = 1'b1;
    else
          h_rd_brst_next_gnt = 1'b0;
end



// ahb state
parameter H_IDLE     = 2'd0 ;
parameter H_WSTA     = 2'd1 ;
//parameter H_WLST     = 2'd2 ;
parameter H_RSTA     = 2'd3 ;

always @ (posedge clk_ahb or negedge rst_ahb_n)begin
    if    (rst_ahb_n==1'b0) begin
       h_cur_state  <= `DLY H_IDLE;
    end
    else begin
       h_cur_state  <= `DLY h_next_state;
    end
end
always @ (*) begin
    case(h_cur_state)
       H_IDLE: if(h_avld)begin
                    if (h_write)
                    h_next_state = H_WSTA;
                    else 
                    h_next_state = H_RSTA;
               end
               else 
                    h_next_state = h_cur_state;
       H_WSTA: if(h_wsta_rfifo_over) begin
                    h_next_state = H_IDLE;
               end
               else
                    h_next_state = h_cur_state;
       H_RSTA: if(h_rsta_wfifo_over) begin
                    h_next_state = H_IDLE;
               end
               else
                    h_next_state = h_cur_state;
     default:  h_next_state = H_IDLE;
    endcase
end

always @ (posedge clk_ahb or negedge rst_ahb_n)begin
    if    (rst_ahb_n==1'b0) begin
       h_gnt_count  <= `DLY 'h0;
    end
    else if (h_avld) 
       h_gnt_count  <= `DLY h_length +1 ; //
    else if (h_wr_brst_1st_gnt || h_rd_brst_1st_gnt || h_wr_brst_next_gnt||h_rd_brst_next_gnt) begin
       h_gnt_count  <= `DLY h_gnt_count-1;
    end
end

assign  ahb_mastlock = 1'b0; // no care
assign  ahb_prot = 4'b0; // no care
//assign  ahb_size = 3'b010; // no care ,must be 32bit
assign  ahb_size =p_size; // 
always @ (posedge clk_ahb or negedge rst_ahb_n)begin
    if    (rst_ahb_n==1'b0) begin
       ahb_write  <= `DLY 1'd0;
       ahb_sel    <= `DLY 1'd0;
    end
    else if (h_avld) begin
       ahb_write  <= `DLY h_write;
       ahb_sel    <= `DLY 1'b1;
    end
    else if (h_wsta_rfifo_over || h_rsta_wfifo_over) begin
       ahb_write  <= `DLY 1'b0;
       ahb_sel    <= `DLY 1'b0;
    end
end

always @ (posedge clk_ahb or negedge rst_ahb_n)begin
    if    (rst_ahb_n==1'b0) begin
       ahb_burst  <= `DLY 3'd0;
    end
    else if (h_avld) begin
       if (h_length=='d0) begin //single
       ahb_burst  <= `DLY SINGLE;
       end
       else if (h_length=='d3) begin // burst4
           if (h_type_burst==2'b10)
       ahb_burst  <= `DLY WRAP4;
           else
       ahb_burst  <= `DLY INCR4;
       end
       else if (h_length=='d7) begin // burst8
           if (h_type_burst==2'b10)
       ahb_burst  <= `DLY WRAP8;
           else
       ahb_burst  <= `DLY INCR8;
       end
       else if (h_length=='d15) begin // burst16
           if (h_type_burst==2'b10)
       ahb_burst  <= `DLY WRAP16;
           else
       ahb_burst  <= `DLY INCR16;
       end
       else begin // burst
       ahb_burst  <= `DLY INCR;
       end
    end
end

always @ (*) begin
    if (h_cur_state==H_WSTA) begin
       if (wfifo_empty)
          ahb_trans = IDLE;
       else if (h_gnt_count==(h_length +1))
          ahb_trans = NONSEQ;
       else
          ahb_trans = SEQ;
    end
    else if (h_cur_state==H_RSTA) begin
       if (h_gnt_count=='d0)
          ahb_trans = IDLE;
       else if (h_gnt_count==(h_length +1))
          ahb_trans = NONSEQ;
       else
          ahb_trans = SEQ;
    end
    else
          ahb_trans = IDLE;
end

always @ (posedge clk_ahb or negedge rst_ahb_n)begin
    if    (rst_ahb_n==1'b0) begin
       ahb_addr  <= `DLY 'd0;
    end
    else if (h_avld) begin
       ahb_addr  <= `DLY h_addr;
    end
    else if (h_wvld_1st && h_write) begin
       ahb_addr  <= `DLY h_addr;
    end
    else if (h_wr_brst_1st_gnt || h_rd_brst_1st_gnt || h_wr_brst_next_gnt||h_rd_brst_next_gnt) begin
       if (h_type_burst==2'b00) //pbus fix
       ahb_addr  <= `DLY ahb_addr;
       else if (h_type_burst==2'b01) begin //pbus incr
            if (ahb_size==0)
            ahb_addr  <= `DLY ahb_addr + 1;
            else if (ahb_size==1)
            ahb_addr  <= `DLY ahb_addr + 2;
            else begin
			if(SIM_FIFO == 0)
            ahb_addr  <= `DLY ahb_addr + 4;
			else
			ahb_addr  <= `DLY ahb_addr;// added by mwang to fit FIFO-AHB_SIM
			end
       end else if (h_type_burst==2'b10) begin //pbus wrap
            if (h_length=='d15) begin
               if (ahb_size==0)
               ahb_addr  <= `DLY {ahb_addr[31:4],4'b0} + (ahb_addr + 1) % 16;
			   //ahb_addr  <= `DLY ahb_addr;// added by mwang to fit FIFO-AHB_SIM
               else if (ahb_size==1)
               ahb_addr  <= `DLY {ahb_addr[31:5],5'b0} + (ahb_addr + 2) % 32;
			   //ahb_addr  <= `DLY ahb_addr;// added by mwang to fit FIFO-AHB_SIM
               else begin
			   if(SIM_FIFO == 0)
               ahb_addr  <= `DLY {ahb_addr[31:6],6'b0} + (ahb_addr + 4) % 64;
			   else
			   ahb_addr  <= `DLY ahb_addr;// added by mwang to fit FIFO-AHB_SIM
			   end
            end
            else if (h_length=='d7) begin
               if (ahb_size==0)
               ahb_addr  <= `DLY {ahb_addr[31:3],3'b0} + (ahb_addr + 1) % 8;
			   //ahb_addr  <= `DLY ahb_addr;// added by mwang to fit FIFO-AHB_SIM
               else if (ahb_size==1)
               ahb_addr  <= `DLY {ahb_addr[31:4],4'b0} + (ahb_addr + 2) % 16;
			   //ahb_addr  <= `DLY ahb_addr;// added by mwang to fit FIFO-AHB_SIM
               else begin
			   if(SIM_FIFO == 0)
               ahb_addr  <= `DLY {ahb_addr[31:5],5'b0} + (ahb_addr + 4) % 32;
			   else
			   ahb_addr  <= `DLY ahb_addr;// added by mwang to fit FIFO-AHB_SIM
			   end
            end
            else if (h_length=='d3) begin
               if (ahb_size==0)
               ahb_addr  <= `DLY {ahb_addr[31:2],2'b0} + (ahb_addr + 1) % 4;
			   //ahb_addr  <= `DLY ahb_addr;// added by mwang to fit FIFO-AHB_SIM
               else if (ahb_size==1)
               ahb_addr  <= `DLY {ahb_addr[31:3],3'b0} + (ahb_addr + 2) % 8;
			   //ahb_addr  <= `DLY ahb_addr;// added by mwang to fit FIFO-AHB_SIM
               else begin
			   if(SIM_FIFO == 0)
               ahb_addr  <= `DLY {ahb_addr[31:4],4'b0} + (ahb_addr + 4) % 16; //len=4, 4*4=16
			   else
			   ahb_addr  <= `DLY ahb_addr;// added by mwang to fit FIFO-AHB_SIM
			   end
            end
       end
    end
end

assign h_wfifo_rd = ahb_ready & ahb_write & (h_cur_state==H_WSTA) & ((ahb_trans==NONSEQ)||(ahb_trans==SEQ));
assign h_wsta_rfifo_over = ahb_ready & ahb_write & (h_cur_state==H_WSTA) & (h_gnt_count=='d0);

assign h_rsta_wfifo_over = ahb_ready & !ahb_write & (h_cur_state==H_RSTA) & (h_gnt_count=='d0);
assign h_rfifo_wr = ahb_ready & !ahb_write & (h_cur_state==H_RSTA) & ((ahb_trans==IDLE)||(ahb_trans==SEQ));

//----------------------------------------
// between two clock domain
//----------------------------------------

assign  h_addr       =  p_addr;           // addr
assign  h_write      =  p_write;           //1: write 0:read
assign  h_length     =  p_length;           //burst length, 
assign  h_type_burst =  p_type_burst;           //

m7s_sync_pluse2pluse  U_sync_pluse_0(
      .src_rst_n               (rst_ahb_n),
      .src_clk                 (clk_ahb),
      .dst_rst_n               (rst_pbus_n),
      .dst_clk                 (clk_pbus),
      .src_pluse               (h_wsta_rfifo_over ),
      .dst_pluse               (p_wsta_rfifo_over)
);

m7s_sync_pluse2pluse  U_sync_pluse_1(
      .src_rst_n               (rst_pbus_n),
      .src_clk                 (clk_pbus),
      .dst_rst_n               (rst_ahb_n),
      .dst_clk                 (clk_ahb),
      .src_pluse               (p_avld ),
      .dst_pluse               (h_avld)
);

m7s_sync_pluse2pluse  U_sync_pluse_2(
      .src_rst_n               (rst_pbus_n),
      .src_clk                 (clk_pbus),
      .dst_rst_n               (rst_ahb_n),
      .dst_clk                 (clk_ahb),
      .src_pluse               (p_wvld_1st),
      .dst_pluse               (h_wvld_1st)
);



wire  [3:0] wrch_waddr_mem;
wire  [3:0] wrch_raddr_mem;
m7s_async_fifo #(32, 4) U_async_fifo_wr(
    .clr                   (1'b0),
    .wr_req_n              (!p_wfifo_wr),
    .wclk                  (clk_pbus            ),
    .wrst_n                (rst_pbus_n          ),
    .rd_req_n              (!h_wfifo_rd),
    .rclk                  (clk_ahb            ),
    .rrst_n                (rst_ahb_n          ),
    .wfull                 (wfifo_full         ),
    .wfull_almost          (),
    .rempty                (wfifo_empty),
    .rempty_almost         (),
    .waddr_mem             (wrch_waddr_mem        ),
    .raddr_mem             (wrch_raddr_mem        ),
    .wr_mem_n              (wrch_wr_mem_n         ),
    .rd_mem_n              (wrch_rd_mem_n         )
    );

//tpram16x32 U_tpram16x32_wr(
//    .A_clk                 (clk_pbus),  
//    .A_d                   (pbus_wdata),
//    .A_addr                (wrch_waddr_mem),
//    .A_wr_n                (wrch_wr_mem_n),  
//    .B_clk                 (clk_ahb),
//    .B_q                   (ahb_wdata),
//    .B_addr                (wrch_raddr_mem),
//    .B_rd_n                (wrch_rd_mem_n)  
//);

m7s_regram  #(32,4)  U_tpram16x32_wr(
      .A_clk                 (clk_pbus ),
      .A_rst_n               (rst_pbus_n ),
      .A_d                   (pbus_wdata),                      
      .A_addr                (wrch_waddr_mem),                  
      .A_wr_n                (wrch_wr_mem_n),                   
      .B_clk                 (clk_ahb), 
      .B_rst_n               (rst_ahb_n), 
      .B_q                   (ahb_wdata),                     
      .B_addr                (wrch_raddr_mem),                
      .B_rd_n                (wrch_rd_mem_n)                 
);


wire  [3:0] rdch_waddr_mem;
wire  [3:0] rdch_raddr_mem;
m7s_async_fifo #(32, 4) U_async_fifo_rd(
    .clr                   (1'b0),
    .wr_req_n              (!h_rfifo_wr),
    .wclk                  (clk_ahb            ),
    .wrst_n                (rst_ahb_n          ),
    .rd_req_n              (!p_rfifo_rd),
    .rclk                  (clk_pbus            ),
    .rrst_n                (rst_pbus_n          ),
    .wfull                 (),
    .wfull_almost          (),
    .rempty                (rfifo_empty),
    .rempty_almost         (),
    .waddr_mem             (rdch_waddr_mem        ),
    .raddr_mem             (rdch_raddr_mem        ),
    .wr_mem_n              (rdch_wr_mem_n         ),
    .rd_mem_n              (rdch_rd_mem_n         )
    );

//tpram16x32 U_tpram16x32_rd(
//    .A_clk                 (clk_ahb),  
//    .A_d                   (ahb_rdata),
//    .A_addr                (rdch_waddr_mem),
//    .A_wr_n                (rdch_wr_mem_n), 
//    .B_clk                 (clk_pbus),
//    .B_q                   (pbus_rdata),
//    .B_addr                (rdch_raddr_mem),
//    .B_rd_n                (rdch_rd_mem_n)  
//);


m7s_regram  #(32,4)  U_tpram16x32_rd(
      .A_clk                 (clk_ahb),                                      
      .A_rst_n               (rst_ahb_n),
      .A_d                   (ahb_rdata),                                            
      .A_addr                (rdch_waddr_mem),                                       
      .A_wr_n                (rdch_wr_mem_n),                                        
      .B_clk                 (clk_pbus),                      
      .B_rst_n               (rst_pbus_n), 
      .B_q                   (pbus_rdata),                                          
      .B_addr                (rdch_raddr_mem),                                        
      .B_rd_n                (rdch_rd_mem_n)                                       
);

//add by why 20130320
reg   hready_in_sel;  //0: use hready_out of slave, 1: use 1
always @ (posedge clk_ahb or negedge rst_ahb_n)begin
    if    (rst_ahb_n==1'b0) begin
       hready_in_sel  <= `DLY 1'b1;
    end
    else if(ahb_trans[1] == 1 && ahb_readyout == 1) begin
       hready_in_sel  <= `DLY 1'b0;
    end
    else if(ahb_trans[1] == 0 && ahb_readyout == 1) begin
       hready_in_sel  <= `DLY 1'b1;
    end
end
assign ahb_readyin = hready_in_sel == 1 ? 1'b1 : ahb_readyout;
//===========================================================
//synopsys translate_off 
reg [31:0] wr_cnt_dbg_slv;
reg [31:0] rd_cnt_dbg_slv;
always @ (posedge clk_ahb or negedge rst_ahb_n)begin
    if    (rst_ahb_n==1'b0) begin
          wr_cnt_dbg_slv   <= `DLY 'h0;            
    end
    else if(ahb_trans[1] ==1  && ahb_ready == 1 && ahb_write == 1) begin
          wr_cnt_dbg_slv   <= `DLY wr_cnt_dbg_slv + 4;
    end
end
always @ (posedge clk_ahb or negedge rst_ahb_n)begin
    if    (rst_ahb_n==1'b0) begin
          rd_cnt_dbg_slv   <= `DLY 'h0;            
    end
    else if(ahb_trans[1] ==1  && ahb_ready == 1 && ahb_write == 0) begin
          rd_cnt_dbg_slv   <= `DLY rd_cnt_dbg_slv + 4;
    end
end

initial begin
//  #1300000 $finish();
end

//synopsys translate_on 
endmodule

