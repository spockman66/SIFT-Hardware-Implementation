`timescale 1ns / 1ps
 
`define SINGLE       3'b000
`define INCR         3'b001
`define WRAP4        3'b010
`define INCR4        3'b011
`define WRAP8        3'b100
`define INCR8        3'b101
`define WRAP16       3'b110
`define INCR16       3'b111
 
 
module syn_arm_w_r_tb;
 
parameter BASE_ADDR = 32'ha000_0000;
parameter WORK_MODE = 0;//1-asyn,0-syn
parameter WR_AHB_INF = 1;//1-AHB,0-FIFO
parameter RD_AHB_INF = 1;//1-AHB,0-FIFO

parameter WR_DATA_WIDTH = 32;
parameter RD_DATA_WIDTH = 32;
parameter WR_ADDR_WIDTH = 9;
parameter RD_ADDR_WIDTH = 9;

//------------------------------------------
//// AHB interface
////------------------------------------------
wire    [31:0]        hrdata; 
wire                  hready_out   ;
wire                  hresp         ;
 
 wire    [31:0]        haddr         ;
 wire    [2:0]         hburst        ;

 wire    [1:0]         htrans        ;
 wire    [31:0]        hwdata        ;
 wire                  hwrite        ;
 wire                  hsel;

 //---------------------------------------------
 //// FIFO PORT 
 ////---------------------------------------------
wire clk;
wire rst_n;
wire wclr;
wire rclr;
wire [31:0] wdata;
wire [31:0] rdata;
wire wen;
wire ren;
wire almost_full;
wire almost_empty;
wire prog_full;
wire prog_empty;
wire [8:0] wr_data_cnt;
wire [8:0] rd_data_cnt;
wire wr_ack;
wire rd_ack;
wire overflow;
wire underflow;
wire rempty;
wire wfull;
 
 //---------------------------------------------
 //// internal signals
 ////--------------------------------------------- 
   reg     hclk;
   reg     hresetn;
   reg     [31:0] addr;
   reg     [31:0] rdata1;

   integer step_of_tb;

cme_ip_fifo_ahb_v2 u_fifo_ahb(         
    .hclk(hclk), 
    .hresetn(hresetn),
    .haddr(haddr), 
    .hsel(hsel),
    .htrans(htrans), 
    .hwrite(hwrite),
    .hsize(), 
    .hburst(hburst),
    .hready_out(hready_out),
    .hwdata(hwdata), 
    .hrdata(hrdata),
    .hresp(hresp),
    //ahb_fifo_interrupt
    .ahb_fifo_int(),
    //connect with FIFO
    .clk(clk),
	.rst_n(rst_n),
	.wclk(),
    .rclk(),
    .wrst_n(),
    .rrst_n(),
    .wclr(wclr),
    .rclr(rclr),
    .wdata(wdata),
    .rdata(rdata),
    .wen(wen),
    .ren(ren),
    .almost_full(almost_full),
    .almost_empty(almost_empty),
    .prog_full(prog_full),
    .prog_empty(prog_empty),
    .wr_data_cnt(wr_data_cnt),
    .rd_data_cnt(rd_data_cnt),
    .rempty(rempty),
    .wfull(wfull)
);
 
defparam u_fifo_ahb.BASE_ADDR = BASE_ADDR;
defparam u_fifo_ahb.WORK_MODE = WORK_MODE;
defparam u_fifo_ahb.WR_AHB_INF = WR_AHB_INF;
defparam u_fifo_ahb.RD_AHB_INF = RD_AHB_INF;

defparam u_fifo_ahb.WR_DATA_WIDTH = WR_DATA_WIDTH;
defparam u_fifo_ahb.RD_DATA_WIDTH = RD_DATA_WIDTH;
defparam u_fifo_ahb.WR_ADDR_WIDTH = WR_ADDR_WIDTH;
defparam u_fifo_ahb.RD_ADDR_WIDTH = RD_ADDR_WIDTH;

		
M7S_SOC u_soc (		
    .clk_ahb_fp0(hclk) ,
    .rst_ahb_fp0_n(hresetn),
    .fp0_s_ahb_mastlock(),
    .fp0_s_ahb_prot(),
    .fp0_s_ahb_size(),
    .fp0_s_ahb_sel(hsel),
    .fp0_s_ahb_addr(haddr),
    .fp0_s_ahb_write(hwrite),
    .fp0_s_ahb_burst(hburst),
    .fp0_s_ahb_trans(htrans),
    .fp0_s_ahb_wdata(hwdata),
    .fp0_s_ahb_readyout(hready_out),
    .fp0_s_ahb_resp(1'b0),
    .fp0_s_ahb_rdata(hrdata)
	);
	
defparam u_soc.SIM_FIFO = 1;  
defparam u_soc.START_ADDR = 32'ha000_0000;
		
fifo_v2_sim u_fifo_syn_v2(
    .clk(clk),
    .rst_n(rst_n),
    .wclr(wclr),
    .rclr(rclr),
    .wdata(wdata),
    .rdata(rdata),
    .wen(wen),
    .ren(ren),
    .almost_full(almost_full),
    .almost_empty(almost_empty),
    .prog_full(prog_full),
    .prog_empty(prog_empty),
    .wr_data_cnt(wr_data_cnt),
    .rd_data_cnt(rd_data_cnt),
    .wr_ack(wr_ack),
    .rd_ack(rd_ack),
    .overflow(overflow),
    .underflow(underflow),
    .rempty(rempty),
    .wfull(wfull)
);
		

 initial hclk = 0;
    always #5 hclk = ~hclk;


    initial begin
        step_of_tb = 0;
        hresetn = 1'b0;
		
        #200;
        hresetn = 1'b1;
        //-------------------------------------------
        // single write test
        //-------------------------------------------
        @(posedge hclk);
        addr = BASE_ADDR;
        u_soc.u_ahb_bfm_fp0.single_wr_reg(addr,32'h1234_5678);
        
		
        @(posedge hclk);
        addr = BASE_ADDR;
        u_soc.u_ahb_bfm_fp0.single_wr_reg(addr,32'h2345_1234);
		
		@(posedge hclk);
        addr = BASE_ADDR;
        u_soc.u_ahb_bfm_fp0.single_wr_reg(addr,32'h2345_1122);
		
		@(posedge hclk);
        addr = BASE_ADDR;
        u_soc.u_ahb_bfm_fp0.single_wr_reg(addr,32'h1122_1234);
		
		@(posedge hclk);
        addr = BASE_ADDR +4;
        u_soc.u_ahb_bfm_fp0.single_wr_reg(addr,32'h54);
       
        
        //-------------------------------------------
        // single read test
        //-------------------------------------------
		step_of_tb = step_of_tb +1;
		@(posedge hclk);
        addr = BASE_ADDR +40;
        u_soc.u_ahb_bfm_fp0.single_rd_reg(addr, rdata1);
		
		 @(posedge hclk);
        addr = BASE_ADDR +44;
        u_soc.u_ahb_bfm_fp0.single_rd_reg(addr, rdata1);
		
        @(posedge hclk);
         addr = BASE_ADDR;
        u_soc.u_ahb_bfm_fp0.single_rd_reg(addr, rdata1);

        @(posedge hclk);
        addr = BASE_ADDR;
        u_soc.u_ahb_bfm_fp0.single_rd_reg(addr, rdata1);
		
		 @(posedge hclk);
         addr = BASE_ADDR;
        u_soc.u_ahb_bfm_fp0.single_rd_reg(addr, rdata1);

        @(posedge hclk);
        addr = BASE_ADDR;
        u_soc.u_ahb_bfm_fp0.single_rd_reg(addr, rdata1);
		
	    @(posedge hclk);
        addr = BASE_ADDR +4;
        u_soc.u_ahb_bfm_fp0.single_rd_reg(addr, rdata1);
        //-------------------------------------------
        // write burst wrap test
        //-------------------------------------------
		step_of_tb = step_of_tb +1;
        @(posedge hclk);
        addr = BASE_ADDR;
        u_soc.u_ahb_bfm_fp0.seq_wr_bst_wrap(addr,`WRAP4, 4);


        @(posedge hclk);
        addr = BASE_ADDR;
        u_soc.u_ahb_bfm_fp0.seq_wr_bst_wrap(addr,`WRAP8, 8);
  

        @(posedge hclk);
       addr = BASE_ADDR;
        u_soc.u_ahb_bfm_fp0.seq_wr_bst_wrap(addr,`WRAP16, 16);


        //-------------------------------------------
        // read burst wrap test
        //-------------------------------------------
		step_of_tb = step_of_tb +1;
        @(posedge hclk);
        addr = BASE_ADDR;
        u_soc.u_ahb_bfm_fp0.seq_rd_bst_wrap(addr,`WRAP4, 4);

        @(posedge hclk);
        addr = BASE_ADDR;
        u_soc.u_ahb_bfm_fp0.seq_rd_bst_wrap(addr,`WRAP8, 8);

        @(posedge hclk);
        addr = BASE_ADDR;
        u_soc.u_ahb_bfm_fp0.seq_rd_bst_wrap(addr,`WRAP16, 16);

        //-------------------------------------------
        // write burst incr test
        //-------------------------------------------
		step_of_tb = step_of_tb +1;
        @(posedge hclk);
        addr = BASE_ADDR;
        u_soc.u_ahb_bfm_fp0.seq_wr_bst_incr(addr,`INCR4, 4);
    

        @(posedge hclk);
        addr = BASE_ADDR;
        u_soc.u_ahb_bfm_fp0.seq_wr_bst_incr(addr,`INCR8, 8);


        @(posedge hclk);
        addr = BASE_ADDR;
        u_soc.u_ahb_bfm_fp0.seq_wr_bst_incr(addr,`INCR16, 16);


        //-------------------------------------------
        // read burst incr test
        //-------------------------------------------
		step_of_tb = step_of_tb +1;
        @(posedge hclk);
        addr = BASE_ADDR;
        u_soc.u_ahb_bfm_fp0.seq_rd_bst_incr(addr,`INCR4, 4);

        @(posedge hclk);
        addr = BASE_ADDR;
        u_soc.u_ahb_bfm_fp0.seq_rd_bst_incr(addr,`INCR8, 8);

        @(posedge hclk);
        addr = BASE_ADDR;
        u_soc.u_ahb_bfm_fp0.seq_rd_bst_incr(addr,`INCR16, 16);


        if(u_soc.u_ahb_bfm_fp0.seq_rd_bst_incr.err_cnt != 0 || u_soc.u_ahb_bfm_fp0.seq_rd_bst_wrap.err_cnt != 0)
            u_soc.u_ahb_bfm_fp0.test_failed;
        else
            u_soc.u_ahb_bfm_fp0.test_passed;

        #500;
        $finish;
	end
 
    initial begin
       `ifdef DUMP
         `ifdef POST_SIM
             $fsdbDumpfile({"fifo_ahb.fsdb"});
         `else
             $fsdbDumpfile({"fifo_ahb.fsdb"});
         `endif
             $fsdbDumpvars(15,syn_arm_w_r_tb);
       `endif
    end

endmodule

