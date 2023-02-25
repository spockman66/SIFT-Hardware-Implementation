`timescale 1ns / 1ps

`define DLY #0
`define HSINGLE   3'b000 //Single burst
`define HINCR     3'b001 //Incrementing burst of undefined lengt
`define HWRAP4    3'b010 //4-beat wrapping burst
`define HINCR4    3'b011 //4-beat incrementing burst
`define HWRAP8    3'b100 //8-beat wrapping burst
`define HINCR8    3'b101 //8-beat incrementing burst
`define HWRAP16   3'b110 //16-beat wrapping burst
`define HINCR16   3'b111 //16-beat incrementing burst

`define HIDLE     2'b00
`define HBUSY     2'b01
`define HNSEQ     2'b10
`define HSEQ      2'b11

`define H8        3'b000
`define H16       3'b001
`define H32       3'b010

`define BUSOP_TO  5000

// print funcs
`define display       $write("%c[0m",27); $display
`define display_blue  $write("%c[0m",27); $write("%c[1;34m",27); $display
`define display_red   $write("%c[0m",27); $write("%c[1;31m",27); $display
`define display_green $write("%c[0m",27); $write("%c[1;32m",27); $display
`define display_bg    $write("%c[0m",27); $display("%c[7;34m",27); $display
`define flush_display_color               $write("%c[0m",27)
`define usbplay       $write("[usbVTB]"); $display


module m7s_ahb_bfm (

    hclk,
    haddr,
    hburst,
    hmasterlock,
    hprot,
    hsize,
    htrans,
    hwdata,
    hwrite,
    hsel,

    hrdata,
    hready,
    hresp,
	// for master signals
	m_hclk,
	m_hresetn,
    m_haddr,
    m_hburst,
    m_hmasterlock,
    m_hprot,
    m_hsize,
    m_htrans,
    m_hwdata,
    m_hwrite,
    m_hsel,

    m_hrdata,
    m_hready,
    m_hresp

);

parameter SIM_FIFO = 0;

input                  hclk;
input    [31:0]        hrdata        ;       
input                  hready     ;     
input                  hresp         ;     

output    [31:0]        haddr         ;
output    [2:0]         hburst        ;   
output                  hmasterlock   ;    
output    [3:0]         hprot         ;   
output    [2:0]         hsize         ;   
output    [1:0]         htrans        ;   
output    [31:0]        hwdata        ;   
output                  hwrite        ;     
output                  hsel;

reg    [31:0]        haddr         ;
reg    [2:0]         hburst        ;   
reg                  hmasterlock   ;    
reg    [3:0]         hprot         ;   
reg    [2:0]         hsize         ;   
reg    [1:0]         htrans        ;   
reg    [31:0]        hwdata        ;   
reg                  hwrite        ;     
reg                  hsel;


// for master
input                  m_hclk          ;
input                  m_hresetn       ;
output   [31:0]        m_hrdata        ;       
output                 m_hready        ;     
output                 m_hresp         ;     

input    [31:0]        m_haddr         ;
input    [2:0]         m_hburst        ;   
input                  m_hmasterlock   ;    
input    [3:0]         m_hprot         ;   
input    [2:0]         m_hsize         ;   
input    [1:0]         m_htrans        ;   
input    [31:0]        m_hwdata        ;   
input                  m_hwrite        ;     
input                  m_hsel          ;


reg    rw_dut_reg_done;     initial     rw_dut_reg_done = 1;
reg    rw_dut_d_reg_done ;  initial     rw_dut_d_reg_done =1 ;
reg    rw_dut_i_reg_done ;  initial     rw_dut_i_reg_done =1 ;

initial begin
    hprot = 4'b0;
    hmasterlock = 0;

    haddr = 0;
    hwdata = 0;
    hwrite = 0;
    hburst = 0;
    htrans = 0;
    hsize = 0;
    hsel = 0;
end

task single_wr_reg;
    input     [31:0]        addr        ;
    input     [31:0]        value       ;
    integer                 cnt         ;
begin
    cnt = 0         ;
    rw_dut_d_reg_done  =0;
    fork 
    begin
        while (rw_dut_d_reg_done == 0) begin
            if(hready == 0 )begin
                cnt = cnt + 1   ;
                if (cnt > `BUSOP_TO) begin
                    rw_dut_d_reg_done  =1;
                    `display_red ("[single_wr_reg] ahb write into %h can't see ready\n",addr);
                    sim_finish(1);
                end
            end
            @(posedge hclk);
        end
    end
    begin

        @(posedge hclk);// command phase  
        haddr         <= `DLY   addr      ;
        hburst        <= `DLY   `HSINGLE  ;
        hsize         <= `DLY   `H32      ;
        htrans        <= `DLY   `HNSEQ    ;
        hwrite        <= `DLY   1         ;
        hsel          <= `DLY   1         ;  
        @(negedge hclk);

        /*while(hready !== 1) begin
            @(posedge hclk);
        end */
         wait(hready == 1) begin
            //@(posedge hclk); //by mwang
        end  		

        // clean up all cmd!!!!!!!!!!!!!!!!!!!!!
        @(posedge hclk);
        hwdata        <=  `DLY  value     ;
        htrans        <=  `DLY  `HIDLE    ;
        haddr         <=  `DLY  0         ;
        hburst        <=  `DLY  0         ;
        hwrite        <=  `DLY  0         ;
        hsel          <=  `DLY  0         ;  
        hsize         <=  `DLY  0         ;
        @(negedge hclk);
        while(hready !== 1)
      begin
            @(negedge hclk);
        end  
        rw_dut_d_reg_done  =1;
        `display("[single_wr_reg] cpu wr %h into %h @%g", value, addr,$time);
    end  join 
end
endtask

  

task single_rd_reg;
    input     [31:0]        addr        ;
    output    [31:0]        value       ;
    integer                 cnt         ;
begin
    cnt = 0         ;
    rw_dut_d_reg_done  =0;
    fork begin
        while(  rw_dut_d_reg_done  ==0)begin
            if (hready == 0) begin
                cnt                 = cnt + 1   ;
                if (cnt > `BUSOP_TO) begin
                    rw_dut_d_reg_done  =1;
                    `display_red ("[single_rd_reg] cpu read from %h can't see ready\n",addr);
                    sim_finish(1);
                end
            end
            @(posedge hclk);
        end
    end
    begin
        @(posedge hclk);
        // command phase
        haddr         <=  `DLY addr      ;
        hburst        <=  `DLY `HSINGLE  ;
        hsize         <=  `DLY `H32      ;
        htrans        <=  `DLY `HNSEQ    ;
        hwrite        <=  `DLY 0         ;
        hsel          <=  `DLY 1         ;
        @(negedge hclk);

        while(hready !== 1)
        begin
            @(posedge hclk);
        end  

        @(posedge hclk);// wait for cmd accept
        // clean up all cmd !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        htrans      <= `DLY `HIDLE     ;
        haddr       <= `DLY 0          ;
        hburst      <= `DLY 0          ;
        hsize       <= `DLY 0          ;
        hsel        <= `DLY 0          ;

        @(negedge hclk);

        while(hready !== 1)
        begin
        @(negedge hclk);
        end  
        value       = hrdata;
        rw_dut_d_reg_done  =1;
      `display("[single_rd_reg] cpu rd %h from %h @%g", value, addr,$time);
    end join
end
endtask


task seq_wr_bst_wrap;
    input  [31:0]    addr         ;
    input  [2:0]     burst        ;
    input  [4:0]     hlen          ;
    integer          i,cnt;
    reg    [127:0]   tc_name       ;
    reg    [31:0]    tmp;
begin
    rw_dut_d_reg_done       = 0    ;

    fork begin
        while(rw_dut_d_reg_done == 0) begin
            if (hready == 0) begin
                cnt                 = cnt + 1   ;
                if (cnt > `BUSOP_TO) begin
                    rw_dut_d_reg_done = 1;
                    `display_red ("[%s] task can't work due to ready hunt\n",tc_name);
                    sim_finish(1);
                end
            end
            @(posedge hclk);
        end
    end
    begin
        tc_name = hlen == 4 ? "wr_bst_wrap4" : 
                  hlen == 8 ? "wr_bst_wrap8" : 
                  hlen ==16 ? "wr_bst_wrap16": "wr_bst_wrap_unkown";

        @(posedge hclk);// command phase  
        haddr         <=`DLY addr     ;
        hburst        <=`DLY burst    ;
        htrans        <=`DLY `HNSEQ    ;  //for burst operation, the first should be Non-seq
        hwrite        <=`DLY 1         ;
        hsel          <=`DLY 1;  
        @(negedge hclk);

        while(hready !== 1)
        begin
            @(posedge hclk);
        end  

        for (i=0;i<{hlen[4:1],1'b0};i=i+1) begin
            @(posedge hclk);

           haddr   <=  `DLY i == hlen - 1 ? 'hFFFFDEAD : 
			                 ((SIM_FIFO == 1) && (hlen == 4 || hlen == 8 || hlen == 16)) ? addr:
							 (SIM_FIFO == 0 && hlen == 4 )? (addr & 'hfffffff0) | ((addr[3:0]+(i+1)*4) & 'hf) :
                             (SIM_FIFO == 0 && hlen == 8 )? (addr & 'hffffffe0) | ((addr[4:0]+(i+1)*4) & 'h1f) : 
                      		 (SIM_FIFO == 0 && hlen == 16 )? (addr & 'hffffffc0) | ((addr[5:0]+(i+1)*4) & 'h3f) : 'hzzzzzzzz ;	
		   /* haddr <=`DLY  (i == hlen - 1) ? 'hFFFFDEAD : 
			              hlen == 4 ? addr : 
                          hlen == 8 ? addr : 
                          hlen == 16 ? addr : 'hzzzzzzzz;
                          //hlen == 4 ? (addr & 'hfffffff0) | ((addr[3:0]+(i+1)*4) & 'hf) : 
                          //hlen == 8 ? (addr & 'hffffffe0) | ((addr[4:0]+(i+1)*4) & 'h1f) : 
                          //hlen == 16 ? (addr & 'hffffffc0) | ((addr[5:0]+(i+1)*4) & 'h3f) : 'hzzzzzzzz;*/
            tmp = haddr;

            htrans <=`DLY i == hlen - 1 ? `HIDLE : `HSEQ;
            hwrite <=`DLY i == hlen - 1 ? 0      : 1;
            hsel   <=`DLY i == hlen - 1 ? 0      : 1;
            hwdata <=`DLY 'hF023_5AC3 | (( ( hlen == 4 ? (addr[3:0]+i*4) & 'hf : 
                          hlen == 8 ? (addr[4:0]+i*4) & 'h1f : 
                          hlen ==16 ? (addr[5:0]+i*4) & 'h3f : 'hzz & 'h3f)/4)<<24);

            @(negedge hclk);
            while(hready !== 1)
            begin
                @(negedge hclk);
            end  

            `display("[%s] bst wr %h to %h",tc_name,hwdata,haddr);
        end

        `display("[%s] bst wr to %h finished @%g",tc_name, haddr,$time);
        rw_dut_d_reg_done = 1;
    end join
end
endtask

task seq_wr_bst_incr;
    input  [31:0]    addr         ;
    input  [2:0]     burst        ;
    input  [4:0]     hlen          ;
    integer          i,cnt;
    reg    [127:0]   tc_name       ;
begin
    rw_dut_d_reg_done       = 0         ;
    tc_name = "seq_wr_bst_incr";
    cnt = 0;
    fork begin
        while (rw_dut_d_reg_done == 0) begin
            if(hready == 0) begin
                cnt  = cnt + 1   ;
                if (cnt > `BUSOP_TO) begin
                    rw_dut_d_reg_done = 1;
                    `display_red ("[%s] task can't work due to ready hunt\n",tc_name);
                    sim_finish(1);
                end
            end
            @(posedge hclk);
        end
    end
    begin
        @(posedge hclk);// command phase  
        haddr         <= `DLY addr     ;
        hburst        <= `DLY burst    ;
        htrans        <= `DLY `HNSEQ    ;
        hwrite        <= `DLY 1         ;
        hsel          <= `DLY 1         ;
        @(negedge hclk);

        while(hready !== 1)
        begin
        @(posedge hclk);
        end  

        for (i=0;i<hlen;i=i+1) begin
            @(posedge hclk);
            haddr          <=`DLY i == hlen - 1 ? 'hFFFFDEAD : 
			                           SIM_FIFO == 1 ? addr : addr + (i+1)*4;
			//haddr         <=`DLY i == hlen - 1 ? 'hFFFFDEAD : addr + (i+1)*4;
			//haddr         <=`DLY i == hlen - 1 ? 'hFFFFDEAD : addr ;
            htrans        <=`DLY i == hlen - 1 ? `HIDLE : `HSEQ;
            hwrite        <=`DLY i == hlen - 1 ? 0      : 1;
            hsel          <=`DLY i == hlen - 1 ? 0      : 1;
            hwdata        <=`DLY 'hF023_5AC3 | (i<<24);

            @(negedge hclk);
            while(hready !== 1)
            begin
                @(negedge hclk);
            end  

            `display("[%s] bst wr %h to %h",tc_name,hwdata,haddr);
        end
        `display("[%s] bst wr to %h finished @%g",tc_name, addr,$time);
        rw_dut_d_reg_done = 1;
    end  join
end
endtask


task seq_rd_bst_wrap;
    input  [31:0]    addr         ;
    input  [2:0]     burst        ;
    input  [4:0]     hlen          ;
    integer          i,cnt,err_cnt;
    reg    [127:0]   tc_name       ;
begin
    rw_dut_d_reg_done      = 0         ;
    cnt  =0 ;
    fork begin
        while (rw_dut_d_reg_done == 0) begin
            if(hready == 0) begin
                @(posedge hclk);
                cnt  = cnt + 1   ;
                if (cnt > `BUSOP_TO) begin
                    rw_dut_d_reg_done = 1;
                    `display_red ("[%s] task can't work due to ready hunt\n",tc_name);
                    sim_finish(1);
                end
            end else begin
                @(posedge hclk);
            end
        end
    end
    begin
        tc_name =   hlen == 4 ? "rd_bst_wrap4" : 
                    hlen == 8 ? "rd_bst_wrap8" : 
                    hlen == 16? "rd_bst_wrap16" : "rd_bst_wrap_unkown";
        err_cnt       = 0         ;

        @(posedge hclk);// command phase  
        haddr         <=`DLY addr     ;
        hburst        <=`DLY burst    ;
        htrans        <=`DLY `HNSEQ    ;
        hwrite        <=`DLY 0         ;
        hsel          <=`DLY 1;

        @(negedge hclk);

        while(hready !== 1)
        begin
            @(posedge hclk);
        end  

        for (i=0;i<hlen;i=i+1) begin
            @(posedge hclk);

            haddr   <=  `DLY i == hlen - 1 ? 'hFFFFDEAD : 
			                 ((SIM_FIFO == 1) && (hlen == 4 || hlen == 8 || hlen == 16)) ? addr:
							 (SIM_FIFO == 0 && hlen == 4 )? (addr & 'hfffffff0) | ((addr[3:0]+(i+1)*4) & 'hf) :
                             (SIM_FIFO == 0 && hlen == 8 )? (addr & 'hffffffe0) | ((addr[4:0]+(i+1)*4) & 'h1f) : 
                      		 (SIM_FIFO == 0 && hlen == 16 )? (addr & 'hffffffc0) | ((addr[5:0]+(i+1)*4) & 'h3f) : 'hzzzzzzzz ;				 
							 	                 
			
			/*haddr   <=  `DLY i == hlen - 1 ? 'hFFFFDEAD : 
			                 hlen == 4 ? addr : 
                             hlen == 8 ? addr : 
                             hlen == 16 ? addr  : 'hzzzzzzzz ;
                             //hlen == 4 ? (addr & 'hfffffff0) | ((addr[3:0]+(i+1)*4) & 'hf) : 
                             //hlen == 8 ? (addr & 'hffffffe0) | ((addr[4:0]+(i+1)*4) & 'h1f) : 
                             //hlen == 16 ? (addr & 'hffffffc0) | ((addr[5:0]+(i+1)*4) & 'h3f) : 'hzzzzzzzz ;*/
            htrans  <=  `DLY i == hlen - 1 ? `HIDLE : `HSEQ;
            hsel    <=  `DLY i == hlen - 1 ? 1'b0 : 1'b1;

            @(negedge hclk);
            while(hready !== 1)
            begin
                @(negedge hclk);
            end  

            if (hrdata == ('hF023_5AC3 | (( ( hlen == 4 ? (addr[3:0]+i*4) & 'hf : 
               hlen == 8 ? (addr[4:0]+i*4) & 'h1f : 
               hlen ==16 ? (addr[5:0]+i*4) & 'h3f : 'hzz & 'h3f)/4)<<24)) ) begin
                `display_green("\t\tbeat%d pass\n",i);
            end else begin
                err_cnt = err_cnt + 1;
                `display_red("\t\tbeat%d failed, read from %h is %h\n",i,haddr,hrdata);
            end
        end
        `display("[%s] bst%d rd from %h finished @%g",tc_name,hlen, addr,$time);
        rw_dut_d_reg_done = 1;
    end  join
end
endtask


task seq_rd_bst_incr;
    input  [31:0]    addr         ;
    input  [2:0]     burst        ;
    input  [4:0]     hlen          ;
    reg    [127:0]   tc_name       ;
    integer          i,cnt,err_cnt;         
begin
    rw_dut_d_reg_done       = 0         ;
    cnt  = 0 ;

    fork begin
        while (rw_dut_d_reg_done == 0) begin
            if(hready == 0) begin
                @(posedge hclk);
                cnt  = cnt + 1   ;
                if (cnt > `BUSOP_TO) begin
                    rw_dut_d_reg_done = 1;
                    `display_red ("[%s] task can't work due to ready hunt\n",tc_name);
                    sim_finish(1);
                end
            end else begin
                @(posedge hclk);
            end
        end
    end
    begin
        err_cnt                   = 0         ;

        @(posedge hclk);// command phase  
        haddr         <=`DLY addr     ;
        hburst        <=`DLY burst    ;
        htrans        <=`DLY `HNSEQ    ;
        hwrite        <=`DLY 0         ;
        hsel          <=`DLY 1         ;

        @(negedge hclk);

        while(hready !== 1)
        begin
            @(posedge hclk);
        end  

        for (i=0;i<hlen;i=i+1) begin
            @(posedge hclk);
            
			haddr          <=`DLY i == hlen - 1 ? 'hFFFFDEAD : 
			                           SIM_FIFO == 1 ? addr : addr + (i+1)*4;
            //haddr          <=`DLY i == hlen - 1 ? 'hFFFFDEAD : addr + (i+1)*4;
			//haddr          <=`DLY i == hlen - 1 ? 'hFFFFDEAD : addr;
            htrans         <=`DLY i == hlen - 1 ? `HIDLE : `HSEQ;
            hsel           <=`DLY i == hlen - 1 ? 1'b0 : 1'b1;

            @(negedge hclk);

            while(hready !== 1)
            begin
                @(negedge hclk);
            end  

            if (hrdata == ('hF023_5AC3 | (i<<24)) ) begin
                `display_green("\t\tbeat%d pass\n",i);
            end else begin
                err_cnt = err_cnt + 1;
                `display_red("\t\tbeat%d failed, read from %h is %h\n",i,haddr,hrdata);
            end
        end

        `display("[dcode_rd_dut_bst_incr] bst%d rd from %h finished @%g",hlen, addr,$time);
        rw_dut_d_reg_done = 1;
    end  join
end
endtask




task sim_finish ;
    input     [7:0]         idx         ;
    begin
        `flush_display_color; // remove the color setting
        $finish(idx);
    end
endtask

task test_passed;
    begin
        `display_green ("        ++++++++++++++++++++++++++");
        `display_green ("        +  Final result: PASSED  +");
        `display_green ("        ++++++++++++++++++++++++++");
        `display_bg    ("  [tbtask]: Test done when sim %g at rtime %t! \n"
        , $time
        , $realtime );
        `display_green ("  ---------------------------------------------\n");
        sim_finish(0);
    end
endtask

task test_failed;
  begin
  `display_red ("        ++++++++++++++++++++++++++");
  `display_red ("        +  Final result: FAILED  +");
  `display_red ("        ++++++++++++++++++++++++++");
  `display_bg  ("  [tbtask]: Test failed when sim %g at rtime %t! \n"
               , $time
               , $realtime );
  `display_red ("-------------------------------------------------\n");
  sim_finish(1);
  end
endtask

////-----------------------------------------///
// for master                                //
//------------------------------------------- //
parameter START_ADDR = 32'ha000_0000;
parameter  ADDRESS_WIDTH = 9;
parameter  DATA_WIDTH = 32;
parameter  HADDR_WIDTH = 32;

  reg                               ce;
  reg                               we;
  reg     [HADDR_WIDTH-3:0]         addr;
  reg                               hready_out;

  wire    [ADDRESS_WIDTH-1:0]       a;
  wire    [DATA_WIDTH-1:0]          q;
  wire    [DATA_WIDTH-1:0]          d;
 
  wire    [HADDR_WIDTH-3:0]         addr_int;
  wire                              sel_emb;

  
  assign a   = addr[ADDRESS_WIDTH-1:0];
  assign addr_int = m_haddr[31:2] - START_ADDR[31:2];
  assign sel_emb = ((START_ADDR <= m_haddr)&&(m_haddr <= START_ADDR + 32'h7ff));
  
 
 always @ (posedge hclk or negedge m_hresetn) begin
      if (m_hresetn == 1'b0) 
        addr <= 30'b0;
      else if(m_hsel && m_htrans[1] && hready_out)
        addr <= addr_int; 
 end
 
  always @ (posedge hclk or negedge m_hresetn) begin
      if (m_hresetn == 1'b0) 
        we <= 1'b0;
      else if(m_hsel && m_htrans[1] && hready_out)
        we <= m_hwrite;
	  else  
		we <= 1'b0;
 end
 
 always @ (posedge hclk or negedge m_hresetn) begin
      if (m_hresetn == 1'b0) 
        ce <= 1'b0;
      else if(m_hsel && sel_emb)
        ce <= 1'b1;
	  else  
		ce <= 1'b0;
 end
 
 
  always @ (posedge hclk or negedge m_hresetn) begin
      if (m_hresetn == 1'b0) 
		hready_out <= 1'b1;
      else if(m_hsel && m_htrans[1] && hready_out && !m_hwrite)
		hready_out <= 1'b0; 
	 else
		hready_out <= 1'b1; 
 end
 

	
	assign  d   = m_hwdata[DATA_WIDTH -1:0];
	assign m_hrdata ={{(32-DATA_WIDTH){1'b0}},q};
	assign m_hready = hready_out;

m7s_emb u_emb(
    .clk(m_hclk),
    .a(a),
    .d(d),
    .ce(ce),
    .we(we),
    .q(q)
);


endmodule
