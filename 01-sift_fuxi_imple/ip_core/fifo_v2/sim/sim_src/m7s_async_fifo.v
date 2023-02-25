`timescale 1ns / 1ps
//----------------------------------------
// functions: Asynchronous FIFO
// designer:  zhoujin
// data:      2007/02/02
//----------------------------------------
//$Log: async_fifo.v,v $
//Revision 1.4  2007/08/02 06:29:09  wanghongyu
//no message
//
`ifdef DLY
`else
`define DLY #1
`endif


module m7s_async_fifo (
    clr,
    wr_req_n,
    wclk,
    wrst_n,
    rd_req_n,
    rclk,
    rrst_n,
    wfull,
    wfull_almost,
    rempty,
    rempty_almost,
	waddr_mem, 
	raddr_mem,
	wr_mem_n,			
	rd_mem_n			
    );

parameter  DSIZE = 8;			// data width
parameter  ASIZE = 4;			// address size
parameter  AF_LEVEL = 12;		// almost full level
parameter  AE_LEVEL = 4;		// almost empty level

localparam DEPTH = 1 << ASIZE ; 

input               clr;						// fifo clear signal
input              	wr_req_n; 						// fifo wr enable
input				wclk; 						// write clock
input				wrst_n;						// reset of write clock
input              	rd_req_n; 						// fifo read enable
input				rclk; 						// read clock
input				rrst_n;						// reset of read clock
output             	wfull; 						// fifo full output
output				wfull_almost;				// fifo almost full output
output             	rempty; 					// fifo empty output
output				rempty_almost;				// fifo almost empty output

output  [ASIZE-1:0] waddr_mem; 
output  [ASIZE-1:0]	raddr_mem;
output              wr_mem_n;			
output              rd_mem_n;			


                                                
                                                
reg             	wfull; 						// fifo full output
reg					wfull_almost;				// fifo almost full output
reg             	rempty; 					// fifo empty output
reg					rempty_almost;				// fifo almost empty output

// memory control
wire   [ASIZE-1:0] 	waddr_mem; 
wire   [ASIZE-1:0]	raddr_mem;
wire               	wr_mem_n;			
wire               	rd_mem_n;			


// read clock domain
reg    [ASIZE:0]   rptr_bin;					// main read ptr
wire   [ASIZE:0]   rptr_bin_next;				// next read ptr
reg    [ASIZE:0]   rptr_gray;					// read ptr in gray, from rptr_bin
wire   [ASIZE:0]   rgraynext;					// rptr_gray comb 
reg    [ASIZE:0]   rq2_wptr_bin;				// write ptr from write clock domain
reg    [ASIZE:0]   rq2_wptr_bin_pre;			// rq2_wptr_bin comb
reg    [ASIZE:0]   rq1_wptr_gray;				// write ptr from write clock domain pre 1 clock 
reg    [ASIZE:0]   rq2_wptr_gray;				// write ptr from write clock domain pre 2 clock
reg	   [ASIZE:0]   r_counter;					// counter in read clock 

reg                r_clr1;						// clear in read clock pre 1 clock
reg                r_clr2;						// clear in read clock pre 2 clock

// write clock domain
reg    [ASIZE:0]   wptr_bin;					// main write ptr
wire   [ASIZE:0]   wptr_bin_next;				// next write ptr
reg    [ASIZE:0]   wptr_gray;					// write ptr in gray, from wptr_bin
wire   [ASIZE:0]   wgraynext; 					// wptr_gray comb
reg    [ASIZE:0]   wq2_rptr_bin;				// write ptr from read clock domain
reg    [ASIZE:0]   wq2_rptr_bin_pre;			// wq2_rptr_bin comb
reg    [ASIZE:0]   wq1_rptr_gray; 				// read ptr from read clock domain pre 1 clock
reg	   [ASIZE:0]   wq2_rptr_gray;				// read ptr from read clock domain pre 2 clock
reg	   [ASIZE:0]   w_counter;					// counter in write clock

reg                w_clr1;						// clear in write clock pre 1 clock
reg                w_clr2;						// clear in write clock pre 2 clock



//--------------------------------------------------------
// Read-domain synchronizer
//--------------------------------------------------------
// write point sync
always @(posedge rclk or negedge rrst_n) begin
  	if (!rrst_n) begin
	 	rq2_wptr_gray <= `DLY 0;
	 	rq1_wptr_gray <= `DLY 0;
	end
  	else begin
        rq2_wptr_gray <= `DLY rq1_wptr_gray;
        rq1_wptr_gray <= `DLY wptr_gray;
	end
end
// clear signal sync
always @(posedge rclk or negedge rrst_n) begin
    if (!rrst_n) begin
        r_clr2 <= `DLY 0;
        r_clr1 <= `DLY 0;
    end
    else begin
        r_clr2 <= `DLY r_clr1;
        r_clr1 <= `DLY clr;
    end
end



//--------------------------------------------------------
// Write-domain synchronizer 
//--------------------------------------------------------
// read point sync
always @(posedge wclk or negedge wrst_n) begin
  	if (!wrst_n) begin
	 	wq2_rptr_gray <= `DLY 0;
	 	wq1_rptr_gray <= `DLY 0;
	end
  	else begin
        wq2_rptr_gray <= `DLY wq1_rptr_gray;
        wq1_rptr_gray <= `DLY rptr_gray;
	end
end
// clear signal sync
always @(posedge wclk or negedge wrst_n) begin
    if (!wrst_n) begin
        w_clr2 <= `DLY 0;
        w_clr1 <= `DLY 0;
    end
    else begin
        w_clr2 <= `DLY w_clr1;
        w_clr1 <= `DLY clr;
    end
end



//--------------------------------------------------------
// Read pointer & empty generation logic
//--------------------------------------------------------

// main read ptr 
assign rptr_bin_next    = (~rd_req_n & ~rempty) ? rptr_bin + 1 : rptr_bin;
always @(posedge rclk or negedge rrst_n) begin
  	if (!rrst_n) begin
	 	rptr_bin 		<= `DLY 0;
	end
    else if (r_clr2) begin
	 	rptr_bin 		<= `DLY 0;
    end
  	else begin
	 	rptr_bin 		<= `DLY rptr_bin_next;
	end
end
// read ptr change to gray code for write clock domain use
assign rgraynext  = (rptr_bin>>1) ^ rptr_bin; 
always @(posedge rclk or negedge rrst_n) begin
  	if (!rrst_n) begin
	 	rptr_gray 	<= `DLY 0;
	end
    else if (r_clr2) begin
	 	rptr_gray 	<= `DLY 0;
    end
  	else begin
	 	rptr_gray 	<= `DLY rgraynext;
	end
end

//memory control output
assign rd_mem_n = rd_req_n | rempty;
assign raddr_mem      	= rptr_bin[ASIZE-1:0];	// Memory read-address pointer


// FIFO almost empty && empty output

//gray write ptr from write clock domain change to bin
//use to generate almost_empty and empty
integer i;
always @(rq2_wptr_gray) begin   
    for(i=(ASIZE);i>=0;i=i-1)
        rq2_wptr_bin_pre[i] = ^(rq2_wptr_gray>>i);
end
always @(posedge rclk or negedge rrst_n) begin
  	if (!rrst_n) begin
        rq2_wptr_bin <= `DLY 0;
	end
    else if (r_clr2) begin
        rq2_wptr_bin <= `DLY 0;
    end
	else begin
        rq2_wptr_bin <= `DLY rq2_wptr_bin_pre;
	end
end
//counter for almost empty generate
always @(posedge rclk or negedge rrst_n) begin
  	if (!rrst_n) begin
        r_counter <= `DLY 0;
	end
    else if (r_clr2) begin
        r_counter <= `DLY 0;
    end
	else if(rptr_bin[ASIZE] == rq2_wptr_bin[ASIZE]) begin
          r_counter  <= `DLY {1'b0,rq2_wptr_bin[ASIZE-1:0]} - {1'b0,rptr_bin[ASIZE-1:0]};
//        r_counter  <= `DLY rq2_wptr_bin[ASIZE-1:0] - rptr_bin[ASIZE-1:0];
	end
	else begin
        r_counter  <= `DLY {1'b0,~(rptr_bin[ASIZE-1:0] - rq2_wptr_bin[ASIZE-1:0])} + 1 ;
//        r_counter  <= `DLY (1 << ASIZE) - (rptr_bin[ASIZE-1:0] - rq2_wptr_bin[ASIZE-1:0]) ;
	end
end

//FIFO empty when the next rptr_gray == synchronized wptr_gray or on reset
//real empty
always @(posedge rclk or negedge rrst_n) begin
  	if (!rrst_n) begin
		rempty <= `DLY 1'b1;
	end
    else if (r_clr2) begin
		rempty <= `DLY 1'b1;
    end
  	else if(rptr_bin_next == rq2_wptr_bin) begin   
		rempty <= `DLY 1'b1;
	end
	else begin
		rempty <= `DLY 1'b0;
	end
end

always @(posedge rclk or negedge rrst_n) begin
  	if (!rrst_n) begin
		rempty_almost <= `DLY 1'b1;
	end 
    else if (r_clr2) begin
		rempty_almost <= `DLY 1'b1;
    end
	else if(r_counter <= AE_LEVEL) begin
		rempty_almost <= `DLY 1'b1;
	end
	else begin
		rempty_almost <= `DLY 1'b0;
	end
end
 


//--------------------------------------------------------
// Write pointer & full generation logic
//--------------------------------------------------------
// main read ptr 
assign wptr_bin_next    = (~wr_req_n & ~wfull) ? wptr_bin + 1 : wptr_bin;
always @(posedge wclk or negedge wrst_n) begin
  	if (!wrst_n) begin
	 	wptr_bin 		<= `DLY 0;
	end
    else if (w_clr2) begin
	 	wptr_bin 		<= `DLY 0;
    end
  	else begin
	 	wptr_bin 		<= `DLY wptr_bin_next;
	end
end
// write ptr change to gray code for read clock domain use
assign wgraynext  = (wptr_bin>>1) ^ wptr_bin; 
always @(posedge wclk or negedge wrst_n) begin
  	if (!wrst_n) begin
	 	wptr_gray 	<= `DLY 0;
	end
    else if (w_clr2) begin
	 	wptr_gray 	<= `DLY 0;
    end
  	else begin
	 	wptr_gray 	<= `DLY wgraynext;
	end
end

//memory control output
assign wr_mem_n = wr_req_n | wfull;
assign waddr_mem      	= wptr_bin[ASIZE-1:0];	// Memory read-address pointer


// FIFO almost full && full output

// gray write ptr from write clock domain change to bin
// use to generate almost_empty and full
integer j;
always @(wq2_rptr_gray) begin   
    for(j=(ASIZE);j>=0;j=j-1)
        wq2_rptr_bin_pre[j] = ^(wq2_rptr_gray>>j);
end
always @(posedge wclk or negedge wrst_n) begin
  	if (!wrst_n) begin
        wq2_rptr_bin <= `DLY 0;
	end
    else if (w_clr2) begin
        wq2_rptr_bin <= `DLY 0;
    end
	else begin
        wq2_rptr_bin <= `DLY wq2_rptr_bin_pre;
	end
end
// counter for almost full generate
always @(posedge wclk or negedge wrst_n) begin
  	if (!wrst_n) begin
        w_counter <= `DLY 0;
	end
    else if (w_clr2) begin
        w_counter <= `DLY 0;
    end
	else if(wptr_bin[ASIZE] == wq2_rptr_bin[ASIZE]) begin
        w_counter  <= `DLY {1'b0,wptr_bin[ASIZE-1:0]} - {1'b0,wq2_rptr_bin[ASIZE-1:0]};
//        w_counter  <= `DLY wptr_bin[ASIZE-1:0] - wq2_rptr_bin[ASIZE-1:0];
	end
	else begin
        w_counter  <= `DLY {1'b0,~(wq2_rptr_bin[ASIZE-1:0] - wptr_bin[ASIZE-1:0])} + 1 ;
//        w_counter  <= `DLY (1 << ASIZE) - (wq2_rptr_bin[ASIZE-1:0] - wptr_bin[ASIZE-1:0]);
	end
end

// real full
always @(posedge wclk or negedge wrst_n) begin
  	if (!wrst_n) begin
		wfull <= `DLY 1'b0;
	end
    else if (w_clr2) begin
		wfull <= `DLY 1'b0;
    end
  	else if(wptr_bin_next == {~wq2_rptr_bin[ASIZE],wq2_rptr_bin[ASIZE-1:0]}) begin   
		wfull <= `DLY 1'b1;
	end
	else begin
		wfull <= `DLY 1'b0;
	end
end

always @(posedge wclk or negedge wrst_n) begin
  	if (!wrst_n) begin
		wfull_almost <= `DLY 1'b0;
	end 
    else if (w_clr2) begin
		wfull_almost <= `DLY 1'b0;
    end
	else if(w_counter >= AF_LEVEL) begin
		wfull_almost <= `DLY 1'b1;
	end
	else begin
		wfull_almost <= `DLY 1'b0;
	end
end




endmodule
