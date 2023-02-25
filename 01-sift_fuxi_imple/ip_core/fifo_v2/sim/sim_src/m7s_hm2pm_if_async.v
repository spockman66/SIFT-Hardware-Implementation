`timescale 1ns / 1ps
//*************************************************
//company:   capital-micro
//author:    nn.sun
//date:      20121106
//function:   1)AHB master interface transfer to pbus master interface ;
//            2)async clock domain transfer
//*************************************************
//$Log: .v,v $

`ifdef DLY
`else
`define DLY #1
`endif

module    m7s_hm2pm_if_async(
                clk_pbus,
                rst_pbus_n,

                clk_ahb,
                rst_ahb_n,

                 ahb_mastlock, // no care
                 ahb_prot, // no care
                 ahb_size, //

                 ahb_addr,
                 ahb_write,
                 ahb_burst,
                 ahb_trans,
                 ahb_wdata,

                 ahb_ready,
                 ahb_resp,
                 ahb_rdata,

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
                 pbus_rvalid            //rdata  valid

                );

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

//interface with ahb

input            ahb_mastlock;          // no care
input     [3:0]  ahb_prot;              // no care
input     [2:0]  ahb_size;              //
input    [31:0]  ahb_addr;
input            ahb_write;
input     [2:0]  ahb_burst;
input     [1:0]  ahb_trans;
input    [31:0]  ahb_wdata;
output           ahb_ready;
output           ahb_resp;
output   [31:0]  ahb_rdata;
output    [3:0]  pbus_aid;
output   [31:0]  pbus_addr;             // addr
output           pbus_write;            //1: write 0:read
output    [3:0]  pbus_length;           //burst length, 
output    [3:0]  pbus_wbyte_en;         //
output    [1:0]  pbus_type_burst;       //
output           pbus_avalid;           //addr valid, high active
input            pbus_aready;           //addr accept
output   [31:0]  pbus_wdata;    
output           pbus_wvalid;           //wdata valid,high active
input            pbus_wready;           //wdata accept
input     [3:0]  pbus_did;
input    [31:0]  pbus_rdata;            //rdata
output           pbus_rready;           //ready for rdata,high active
input            pbus_rvalid;           //rdata  valid

//----------------------------------------
// internal reg
//----------------------------------------

//----------------------------------------
// ahb clock domain
//----------------------------------------

parameter H_IDLE       = 3'd0 ,
          H_RDATA      = 3'd1 ,
          H_WDATA      = 3'd2 ,
          H_WDATA_WAIT = 3'd4 ;   

parameter P_IDLE     = 2'd0 ,
          P_CMD      = 2'd1 ,
          P_WDATA    = 2'd2 ,
          P_RDATA    = 2'd3 ;



reg [2:0]  h_pre_state,
           h_next_state;
reg [4:0]  h_data_cnt;

reg [1:0]  p_pre_state,
           p_next_state;
reg [4:0]  p_data_cnt;

reg [3:0]  wire_hbak_wbyte_en;
wire[31:0] wire_hbak_addr;
wire       wire_hbak_write;
reg [3:0]  wire_hbak_length;
reg [1:0]  wire_hbak_burst_type;


reg [3:0]  wait_hbak_wbyte_en;
reg [31:0] wait_hbak_addr;
reg        wait_hbak_write;
reg [3:0]  wait_hbak_length;
reg [1:0]  wait_hbak_burst_type;


reg [3:0]  next_hbak_wbyte_en;
reg [31:0] next_hbak_addr;
reg        next_hbak_write;
reg [3:0]  next_hbak_length;
reg [1:0]  next_hbak_burst_type;
//write,burst_type[1:0],length[3:0],addr[31:0],

wire         h_cmdfifo_wr                ;
wire         p_cmdfifo_rd                ;
wire         p_cmdfifo_empty             ;
wire         h_cmdfifo_full              ;
wire         cmd_waddr_mem               ;
wire         cmd_raddr_mem               ;
wire         cmd_wr_mem_n                ;
wire         cmd_rd_mem_n                ;
wire [38:0]  cmd_wdata_mem               ;  //write,burst_type[1:0],length[3:0],addr[31:0],
wire [38:0]  cmd_rdata_mem               ;  //write,burst_type[1:0],length[3:0],addr[31:0],
 
wire         h_wdfifo_wr                 ;
wire         p_wdfifo_rd                 ;
wire [5:0]   wdf_waddr_mem               ;
wire [5:0]   wdf_raddr_mem               ;
wire         wdf_wr_mem_n                ;
wire         wdf_rd_mem_n                ;
wire [35:0]  wdf_wdata_mem               ;  //byte_en[3:0],addr[31:0],
wire [35:0]  wdf_rdata_mem               ;  //byte_en[3:0],addr[31:0],

wire         p_rdfifo_wr                 ;
wire         h_rdfifo_rd                 ;
wire         h_rdfifo_empty              ;
wire [4:0]   rdf_waddr_mem               ;
wire [4:0]   rdf_raddr_mem               ;
wire         rdf_wr_mem_n                ;
wire         rdf_rd_mem_n                ;
wire [31:0]  rdf_wdata_mem               ;  //byte_en[3:0],addr[31:0],
wire [31:0]  rdf_rdata_mem               ;  //byte_en[3:0],addr[31:0],

reg  hrd_cmdfifo_wr;
wire hwr_cmdfifo_wr;
wire hwrwait_cmdfifo_wr;
reg  cmd_wait;

reg  ahb_ready_rd;
wire ahb_ready_write;
wire ahb_ready_idle;

reg  ahb_vld_wr;
reg  ahb_first_rd_fifo;
reg  ahb_rd_fifo_fail;


assign   wire_hbak_addr       =  ahb_addr;       
assign   wire_hbak_write      =  ahb_write;
always @(*) begin
        case(ahb_burst)
           SINGLE  :  wire_hbak_length =  1 - 1  ;
           INCR    :  wire_hbak_length =  1 - 1  ;
           WRAP4   :  wire_hbak_length =  4 - 1  ;
           INCR4   :  wire_hbak_length =  4 - 1  ;
           WRAP8   :  wire_hbak_length =  8 - 1  ;
           INCR8   :  wire_hbak_length =  8 - 1  ;
           WRAP16  :  wire_hbak_length =  16- 1  ;
         default   :  wire_hbak_length =  16- 1  ;
        //   INCR16  :  hbak_length = 16- 1  ;
        endcase
end
always @(*) begin
        case(ahb_burst)
           SINGLE  :  wire_hbak_burst_type =  2'b00  ;
           INCR    :  wire_hbak_burst_type =  2'b00  ;
           WRAP4   :  wire_hbak_burst_type =  2'b10  ;
           INCR4   :  wire_hbak_burst_type =  2'b01  ;
           WRAP8   :  wire_hbak_burst_type =  2'b10  ;
           INCR8   :  wire_hbak_burst_type =  2'b01  ;
           WRAP16  :  wire_hbak_burst_type =  2'b10  ;
          default  :  wire_hbak_burst_type =  2'b01  ;
       //    INCR16  :  hbak_burst_type =  2'b01  ;
        endcase
end
always @ (*)  begin
  if(ahb_write == 1) begin
      if(ahb_size == 2'd0) begin   //byte
          case(ahb_addr[1:0])
            2'b00:  wire_hbak_wbyte_en  =    4'b0001;
            2'b01:  wire_hbak_wbyte_en  =    4'b0010;
            2'b10:  wire_hbak_wbyte_en  =    4'b0100;
            default:wire_hbak_wbyte_en  =    4'b1000;
          endcase
      end
      else if(ahb_size == 2'd1) begin //half word
          case(ahb_addr[1])
            1'b0:    wire_hbak_wbyte_en  =    4'b0011;
            default: wire_hbak_wbyte_en  =    4'b1100;
          endcase
      end
      else begin  //word
          wire_hbak_wbyte_en    = 4'b1111;
      end
   end
   else begin
          wire_hbak_wbyte_en    = 4'b1111; //read ,for good look
   end
end
always @ (posedge clk_ahb or negedge rst_ahb_n)begin
    if    (rst_ahb_n==1'b0) begin
          wait_hbak_wbyte_en   <= `DLY 'h0;            
          wait_hbak_addr       <= `DLY 'h0;        
          wait_hbak_write      <= `DLY 'h0;         
          wait_hbak_length     <= `DLY 'h0;          
          wait_hbak_burst_type <= `DLY 'h0;              
    end
//    else if(h_pre_state == H_WDATA && h_data_cnt == 1 && ahb_trans != 1) begin
    else if(h_pre_state == H_WDATA && h_data_cnt == 1 && ahb_vld_wr ) begin
          wait_hbak_wbyte_en   <= `DLY wire_hbak_wbyte_en  ;            
          wait_hbak_addr       <= `DLY wire_hbak_addr      ;        
          wait_hbak_write      <= `DLY wire_hbak_write     ;         
          wait_hbak_length     <= `DLY wire_hbak_length    ;          
          wait_hbak_burst_type <= `DLY wire_hbak_burst_type;              
    end
end
always @ (posedge clk_ahb or negedge rst_ahb_n)begin
    if    (rst_ahb_n==1'b0) begin
          next_hbak_wbyte_en   <= `DLY 'h0;            
          next_hbak_addr       <= `DLY 'h0;        
          next_hbak_write      <= `DLY 'h0;         
          next_hbak_length     <= `DLY 'h0;          
          next_hbak_burst_type <= `DLY 'h0;              
    end
    else if(h_pre_state == H_IDLE && cmd_wait == 1) begin
          next_hbak_wbyte_en   <= `DLY wait_hbak_wbyte_en  ;            
          next_hbak_addr       <= `DLY wait_hbak_addr      ;        
          next_hbak_write      <= `DLY wait_hbak_write     ;         
          next_hbak_length     <= `DLY wait_hbak_length    ;          
          next_hbak_burst_type <= `DLY wait_hbak_burst_type;              
    end
    else if(h_pre_state == H_IDLE && ahb_trans[1] == 1 && h_cmdfifo_full == 0) begin
          next_hbak_wbyte_en   <= `DLY wire_hbak_wbyte_en  ;            
          next_hbak_addr       <= `DLY wire_hbak_addr      ;        
          next_hbak_write      <= `DLY wire_hbak_write     ;         
          next_hbak_length     <= `DLY wire_hbak_length    ;          
          next_hbak_burst_type <= `DLY wire_hbak_burst_type;              
    end
end

always @ (posedge clk_ahb or negedge rst_ahb_n)begin //if hready here, will be a valid write data
    if    (rst_ahb_n==1'b0) begin
       ahb_first_rd_fifo  <= `DLY 1'b0;
    end
    else if(h_pre_state != H_RDATA) begin
       ahb_first_rd_fifo  <= `DLY 1'b1;
    end
    else if(h_rdfifo_empty == 0) begin
//assign h_rdfifo_rd  = h_pre_state == H_RDATA && (ahb_trans[1] == 1 || ahb_first_rd_fifo == 1);
       ahb_first_rd_fifo  <= `DLY 1'b0;
    end
end
always @ (posedge clk_ahb or negedge rst_ahb_n)begin //if hready here, will be a valid write data
    if    (rst_ahb_n==1'b0) begin
       ahb_rd_fifo_fail  <= `DLY 1'b0;
    end
    else if(h_pre_state == H_RDATA && h_rdfifo_rd == 1 && h_rdfifo_empty == 1) begin
       ahb_rd_fifo_fail  <= `DLY 1'b1;
    end
    else if(h_rdfifo_empty == 0) begin
       ahb_rd_fifo_fail  <= `DLY 1'b0;
    end
end

//assign h_rdfifo_rd  = h_pre_state == H_RDATA && (ahb_trans[1] == 1 || ahb_first_rd_fifo == 1);
//reg  ahb_rd_fifo_fail;

always @ (posedge clk_ahb or negedge rst_ahb_n)begin //if hready here, will be a valid write data
    if    (rst_ahb_n==1'b0) begin
       ahb_vld_wr  <= `DLY 1'b0;
    end
    else if(ahb_trans[1] == 1 && ahb_write == 1 && ahb_ready == 1) begin
       ahb_vld_wr  <= `DLY 1'b1;
    end
    else if(h_pre_state == H_WDATA && ahb_ready == 1)begin
       ahb_vld_wr  <= `DLY 1'b0;
    end
end
always @ (posedge clk_ahb or negedge rst_ahb_n)begin
    if    (rst_ahb_n==1'b0) begin
       h_pre_state  <= `DLY H_IDLE;
    end
    else begin
       h_pre_state  <= `DLY h_next_state;
    end
end
always @ (posedge clk_ahb or negedge rst_ahb_n)begin
    if    (rst_ahb_n==1'b0) begin
       h_data_cnt  <= `DLY 4'h0;
    end
    else if (h_pre_state == H_IDLE && cmd_wait == 1) begin 
           h_data_cnt <= `DLY wait_hbak_length + 1;
    end
    else if(h_pre_state == H_IDLE) begin
        case(ahb_burst)
           SINGLE  :  h_data_cnt <= `DLY 1  ;
           INCR    :  h_data_cnt <= `DLY 1  ;
           WRAP4   :  h_data_cnt <= `DLY 4  ;
           INCR4   :  h_data_cnt <= `DLY 4  ;
           WRAP8   :  h_data_cnt <= `DLY 8  ;
           INCR8   :  h_data_cnt <= `DLY 8  ;
           WRAP16  :  h_data_cnt <= `DLY 16 ;
           INCR16  :  h_data_cnt <= `DLY 16 ;
        endcase
    end
//    else if (h_pre_state == H_RDATA && ahb_ready == 1 && ahb_trans[1] == 1) begin 
    else if (h_pre_state == H_RDATA && h_rdfifo_rd == 1 && h_rdfifo_empty == 0) begin //here count vld read cmd
           h_data_cnt <= `DLY h_data_cnt -1  ;
    end 
//    else if (h_pre_state == H_WDATA && ahb_ready == 1 && ahb_trans != 1) begin
    else if (h_pre_state == H_WDATA && ahb_ready == 1 && ahb_vld_wr == 1 ) begin //here count vld write data
           h_data_cnt <= `DLY h_data_cnt -1  ;
    end 
end

always @ (posedge clk_ahb or negedge rst_ahb_n)begin
    if    (rst_ahb_n==1'b0) begin
       hrd_cmdfifo_wr  <= `DLY 1'b0;
    end
    else if(h_pre_state == H_IDLE && ahb_trans[1] == 1 && ahb_ready == 1 && ahb_write == 0) begin // a valid read cmd
       hrd_cmdfifo_wr  <= `DLY 1'b1;
    end
    else if(h_pre_state == H_IDLE && cmd_wait == 1 && h_cmdfifo_full == 0 && wait_hbak_write == 0) begin
       hrd_cmdfifo_wr  <= `DLY 1'b1;
    end
    else begin
       hrd_cmdfifo_wr  <= `DLY 1'b0;
    end
end
//assign hwr_cmdfifo_wr = h_pre_state == H_WDATA && ahb_trans!= 1 && h_data_cnt == 1; 
assign hwr_cmdfifo_wr = h_pre_state == H_WDATA &&  h_data_cnt == 1 && ahb_vld_wr == 1; 
assign hwrwait_cmdfifo_wr = h_pre_state == H_WDATA_WAIT && h_cmdfifo_full == 0;
assign h_cmdfifo_wr = (hwr_cmdfifo_wr || hrd_cmdfifo_wr || hwrwait_cmdfifo_wr) && h_cmdfifo_full == 0;

always @ (*) begin
    case(h_pre_state)
       H_IDLE:  if(cmd_wait == 1 && h_cmdfifo_full == 0 && wait_hbak_write == 1)
                     h_next_state = H_WDATA;
                else if(cmd_wait == 1 && h_cmdfifo_full == 0 && wait_hbak_write == 0)
                     h_next_state = H_RDATA;
                else if(ahb_trans[1] == 1 && ahb_write == 0 && ahb_ready == 1 && h_cmdfifo_full == 0)
                     h_next_state = H_RDATA;
                else if(ahb_trans[1] == 1 && ahb_write == 1 && ahb_ready == 1 && h_cmdfifo_full == 0)
                     h_next_state = H_WDATA;
                else 
                     h_next_state = H_IDLE;
       H_RDATA: if(h_rdfifo_rd == 1 && h_rdfifo_empty == 0 && h_data_cnt == 1 ) //when read,1 cycle after fifo read, hready will become high
                     h_next_state = H_IDLE;
                else
                     h_next_state = H_RDATA;
//       H_WDATA: if(ahb_trans != 1 && h_data_cnt == 1)  //when write, hready will write data to fifo,hready always on
       H_WDATA: if(h_data_cnt == 1 && ahb_vld_wr == 1)  //when write, hready will write data to fifo,hready always on
                     if(h_cmdfifo_full == 1)
                       h_next_state = H_WDATA_WAIT;
                     else
                       h_next_state = H_IDLE;
                else
                     h_next_state = H_WDATA;
       H_WDATA_WAIT: if(h_cmdfifo_full == 0) 
                        h_next_state = H_IDLE;
                else
                     h_next_state = H_WDATA_WAIT;
       default:  h_next_state = H_IDLE;
    endcase
end

always @ (posedge clk_ahb or negedge rst_ahb_n)begin
    if    (rst_ahb_n==1'b0) begin
       cmd_wait  <= `DLY 1'b0;
    end
    else if(h_pre_state == H_WDATA && ahb_trans[1] == 1 && h_data_cnt == 1 && ahb_vld_wr == 1) begin
       cmd_wait  <= `DLY 1'b1;
    end
    else if(h_pre_state == H_IDLE && h_cmdfifo_full == 0)begin
       cmd_wait  <= `DLY 1'b0;
    end
end

always @ (posedge clk_ahb or negedge rst_ahb_n)begin
    if    (rst_ahb_n==1'b0) begin
       ahb_ready_rd  <= `DLY 1'b0;
    end
    else if(h_pre_state == H_RDATA)begin
         if(h_rdfifo_rd == 1 && h_rdfifo_empty == 1) begin //when read,1 cycle after fifo read, hready will become high
           ahb_ready_rd  <= `DLY 1'b0;
         end
         else begin
           ahb_ready_rd  <= `DLY 1'b1;
         end
    end
    else begin
       ahb_ready_rd  <= `DLY 1'b0;
    end
end
assign ahb_ready_write = h_pre_state == H_WDATA;
assign ahb_ready_idle  = h_cmdfifo_full == 0 && h_pre_state == IDLE && cmd_wait == 0;
assign ahb_resp = 'b0;
assign ahb_ready = (ahb_ready_rd && h_pre_state == H_RDATA) || ahb_ready_write || ahb_ready_idle;
assign cmd_wdata_mem = {
                          next_hbak_write,             //37  
                          next_hbak_burst_type[1:0],   //37:36  
                          next_hbak_length[3:0],       //35:32  
                          next_hbak_addr[31:0]         //31:0  
                };
//assign h_wdfifo_wr  = h_pre_state == H_WDATA && ahb_trans!= 1 ;
assign h_wdfifo_wr  = h_pre_state == H_WDATA && ahb_vld_wr;
assign  wdf_wdata_mem = {next_hbak_wbyte_en,ahb_wdata};
assign h_rdfifo_rd  = h_pre_state == H_RDATA && ((ahb_trans[1] == 1 && ahb_ready_rd == 1) || ahb_first_rd_fifo == 1 || ahb_rd_fifo_fail == 1);
//assign h_rdfifo_rd  = h_pre_state == H_RDATA && ahb_trans[1] == 1;
assign ahb_rdata    = rdf_rdata_mem;


//----------------------------------------
// pbus clock domain
//----------------------------------------


assign p_rdfifo_wr = pbus_rready && pbus_rvalid;
//wire pcmd_wdfifo_rd;
//wire pd_wdfifo_rd;
//assign pcmd_wdfifo_rd = p_pre_state == P_CMD && pbus_aready == 1 && pbus_write == 1;
//assign pd_wdfifo_rd   = p_pre_state == P_WDATA && pbus_wready && p_data_cnt != 1;
//assign pcmd_wdfifo_rd = pcmd_wdfifo_rd || pd_wdfifo_rd;
//
//wire pwd_cmdfifo_rd;
//wire prd_cmdfifo_rd;
//wire pidle_cmdfifo_rd;
//assign pwd_cmdfifo_rd = p_pre_state == P_WDATA && pbus_wready == 1 && p_data_cnt == 1;
//assign prd_cmdfifo_rd = p_pre_state == P_RDATA && pbus_rvalid == 1 && p_data_cnt == 1;
//assign pidle_cmdfifo_rd = p_pre_state == IDLE;
//

assign  rdf_wdata_mem = pbus_rdata;
assign  pbus_aid           = 0;
assign  pbus_addr          = {cmd_rdata_mem[31:2],2'b0};    //addr
assign  pbus_length        =  cmd_rdata_mem[35:32];   //burst length, 
assign  pbus_type_burst    =  cmd_rdata_mem[37:36];   //
assign  pbus_write         =  cmd_rdata_mem[38];      //1: write 0:read

assign  pbus_wbyte_en = wdf_rdata_mem[35:32];         //
assign  pbus_wdata    = wdf_rdata_mem[31:0];   
assign  pbus_avalid   = p_pre_state == P_CMD;
assign  pbus_wvalid   = p_pre_state == P_WDATA;
assign  pbus_rready   = p_pre_state == P_RDATA;


// pbus state
always @ (posedge clk_pbus or negedge rst_pbus_n)begin
    if    (rst_pbus_n==1'b0) begin
       p_data_cnt  <= `DLY 4'h0;
    end
    else if(p_pre_state == P_CMD) begin 
       p_data_cnt <= `DLY pbus_length +1  ;
    end
    else if (p_pre_state == P_RDATA && pbus_rvalid == 1) begin
           p_data_cnt <= `DLY p_data_cnt -1  ;
    end 
    else if (p_pre_state == P_WDATA && pbus_wready == 1) begin
           p_data_cnt <= `DLY p_data_cnt -1  ;
    end 
end
always @ (posedge clk_pbus or negedge rst_pbus_n)begin
    if    (rst_pbus_n==1'b0) begin
       p_pre_state  <= `DLY P_IDLE;
    end
    else begin
       p_pre_state  <= `DLY p_next_state;
    end
end
always @ (*) begin
    case(p_pre_state)
       P_IDLE: if(p_cmdfifo_empty == 1'b0) 
                    p_next_state = P_CMD;
               else 
                    p_next_state = P_IDLE;
       P_CMD : if(pbus_aready == 1)  
                  if (pbus_write)
                    p_next_state = P_WDATA;
                  else
                    p_next_state = P_RDATA;
               else
                    p_next_state = P_CMD;
       P_WDATA: if(pbus_wready== 1 && p_data_cnt == 1) 
                    if(p_cmdfifo_empty == 1)
                       p_next_state = P_IDLE;
                    else
                       p_next_state = P_CMD;
               else
                    p_next_state = P_WDATA;
       P_RDATA: if(pbus_rvalid  == 1 && p_data_cnt == 1) 
                    if(p_cmdfifo_empty == 1)
                       p_next_state = P_IDLE;
                    else
                       p_next_state = P_CMD;
               else
                    p_next_state = P_RDATA;
     default:  p_next_state = P_IDLE;
    endcase
end

assign p_cmdfifo_rd = (p_pre_state == IDLE) ||
                      (p_pre_state == P_WDATA && p_data_cnt == 1 && pbus_wready) ||
                      (p_pre_state == P_RDATA && p_data_cnt == 1 && pbus_rready);
assign p_wdfifo_rd = (p_pre_state == P_CMD && pbus_aready == 1 && pbus_write == 1) ||
                     (p_pre_state == P_WDATA && pbus_wready== 1 && p_data_cnt != 1);
//assign p_wdfifo_rd = (p_pre_state == P_CMD && pbus_aready == 1 && pbus_write == 1) ||
//                     (p_pre_state == P_WDATA && p_data_cnt != 1);
//assign p_wdfifo_rd = (p_pre_state == P_CMD && pbus_write == 1) ||
//                     (p_pre_state == P_WDATA && pbus_wready== 1 && p_data_cnt != 1);

//###############################################################
//         cmd fifo
//###############################################################

m7s_async_fifo #(39,   //data width
             1     //addr width
             ) U_cmd_afifo(
    .clr                   (1'b0),
    .wr_req_n              (!h_cmdfifo_wr      ),
    .wclk                  (clk_ahb            ),
    .wrst_n                (rst_ahb_n          ),
    .rd_req_n              (!p_cmdfifo_rd      ),
    .rclk                  (clk_pbus           ),
    .rrst_n                (rst_pbus_n         ),
    .wfull                 (h_cmdfifo_full     ),
    .wfull_almost          (),
    .rempty                (p_cmdfifo_empty    ),
    .rempty_almost         (),
    .waddr_mem             (cmd_waddr_mem      ),
    .raddr_mem             (cmd_raddr_mem      ),
    .wr_mem_n              (cmd_wr_mem_n       ),
    .rd_mem_n              (cmd_rd_mem_n       )
    );

m7s_regram  #(39,  //data width
         1     //addr width
          )  U_tpram2x39_cmd(
      .A_clk                 (clk_ahb      ),                                      
      .A_rst_n               (rst_ahb_n    ),
      .A_d                   (cmd_wdata_mem),                            
      .A_addr                (cmd_waddr_mem),                       
      .A_wr_n                (cmd_wr_mem_n ),                        
      .B_clk                 (clk_pbus     ),                      
      .B_rst_n               (rst_pbus_n   ), 
      .B_q                   (cmd_rdata_mem),                          
      .B_addr                (cmd_raddr_mem),                        
      .B_rd_n                (cmd_rd_mem_n )                       
);
//###############################################################
//         wd fifo
//###############################################################
 
m7s_async_fifo #(36,   //data width
             6     //addr width
             ) U_wd_afifo(
    .clr                   (1'b0),
    .wr_req_n              (!h_wdfifo_wr),
    .wclk                  (clk_ahb            ),
    .wrst_n                (rst_ahb_n          ),
    .rd_req_n              (!p_wdfifo_rd       ),
    .rclk                  (clk_pbus            ),
    .rrst_n                (rst_pbus_n          ),
    .wfull                 (),
    .wfull_almost          (),
    .rempty                (),
    .rempty_almost         (),
    .waddr_mem             (wdf_waddr_mem        ),
    .raddr_mem             (wdf_raddr_mem        ),
    .wr_mem_n              (wdf_wr_mem_n         ),
    .rd_mem_n              (wdf_rd_mem_n         )
    );

m7s_regram  #(36,  //data width
         6     //addr width
          )  U_tpram64x36_wd(
      .A_clk                 (clk_ahb      ),                                      
      .A_rst_n               (rst_ahb_n    ),
      .A_d                   (wdf_wdata_mem),                            
      .A_addr                (wdf_waddr_mem),                       
      .A_wr_n                (wdf_wr_mem_n ),                        
      .B_clk                 (clk_pbus     ),                      
      .B_rst_n               (rst_pbus_n   ), 
      .B_q                   (wdf_rdata_mem),                          
      .B_addr                (wdf_raddr_mem),                        
      .B_rd_n                (wdf_rd_mem_n )                       
);

//###############################################################
//         rd fifo
//###############################################################
 
m7s_async_fifo #(32,   //data width
             5     //addr width
             ) U_rd_afifo(
    .clr                   (1'b0),
    .wr_req_n              (!p_rdfifo_wr),
    .wclk                  (clk_pbus            ),
    .wrst_n                (rst_pbus_n          ),
    .rd_req_n              (!h_rdfifo_rd        ),
    .rclk                  (clk_ahb             ),
    .rrst_n                (rst_ahb_n           ),
    .wfull                 (),
    .wfull_almost          (),
    .rempty                (h_rdfifo_empty      ),
    .rempty_almost         (),
    .waddr_mem             (rdf_waddr_mem        ),
    .raddr_mem             (rdf_raddr_mem        ),
    .wr_mem_n              (rdf_wr_mem_n         ),
    .rd_mem_n              (rdf_rd_mem_n         )
    );

m7s_regram  #(32,  //data width
         5     //addr width
          )  U_tpram32x32_rd(
      .A_clk                 (clk_pbus      ),                                      
      .A_rst_n               (rst_pbus_n    ),
      .A_d                   (rdf_wdata_mem),                            
      .A_addr                (rdf_waddr_mem),                       
      .A_wr_n                (rdf_wr_mem_n ),                        
      .B_clk                 (clk_ahb     ),                      
      .B_rst_n               (rst_ahb_n   ), 
      .B_q                   (rdf_rdata_mem),                          
      .B_addr                (rdf_raddr_mem),                        
      .B_rd_n                (rdf_rd_mem_n )                       
);
//synopsys translate_off 
reg [31:0] wr_cnt_dbg;
reg [31:0] rd_cnt_dbg;
always @ (posedge clk_ahb or negedge rst_ahb_n)begin
    if    (rst_ahb_n==1'b0) begin
          wr_cnt_dbg   <= `DLY 'h0;            
    end
    else if(ahb_trans[1] ==1  && ahb_ready == 1 && ahb_write == 1) begin
          wr_cnt_dbg   <= `DLY wr_cnt_dbg + 4;
    end
end
always @ (posedge clk_ahb or negedge rst_ahb_n)begin
    if    (rst_ahb_n==1'b0) begin
          rd_cnt_dbg   <= `DLY 'h0;            
    end
    else if(ahb_trans[1] ==1  && ahb_ready == 1 && ahb_write == 0) begin
          rd_cnt_dbg   <= `DLY rd_cnt_dbg + 4;
    end
end

initial begin
//  #1300000 $finish();
end


//synopsys translate_on 


endmodule

