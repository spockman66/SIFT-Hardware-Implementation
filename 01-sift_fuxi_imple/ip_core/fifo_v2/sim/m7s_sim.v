`timescale 1ns/1ns


module DELAY_BUF(in, out);
    input in;
    output out;
   
    buf (out, in);

endmodule

module GBUF(in, out);
    input in;
    output out;
	
	buf (out, in);
	
endmodule

module RBUF(in, out);
    input in;
    output out;
	
	buf (out, in);
	
endmodule

module GND (Y);

    output Y;

    assign Y = 0;

endmodule

module VCC (Y);

    output Y;

    assign Y = 1;

endmodule

module LUT4 (
	     dx,
	     f3,
	     f2,
	     f1,
	     f0
	     );

    input		f3;
    input		f2;
    input		f1;
    input		f0;

    output		dx;

    parameter    config_data = "0000";

//----------------------------------------------------------------------------------------------------------------
	function [16:1]	str_to_bin ;
	  input	[8*4:1]	s;
	  reg	[8*4:1]	reg_s;
	  reg	[4:1]	digit [8:1];
	  reg	[8:1]	tmp;
	  integer m;
	  integer ivalue ;
        begin
            ivalue = 0;
            reg_s = s;
            for (m=1; m<=4; m= m+1 )
            begin
                tmp = reg_s[32:25];
                digit[m] = tmp & 8'b00001111;
                reg_s = reg_s << 8;
                if (tmp[7] == 'b1)
                    digit[m] = digit[m] + 9;
            end
            str_to_bin = {digit[1], digit[2], digit[3], digit[4]};
        end   
	endfunction
    
    wire [15:0] 		mask = str_to_bin(config_data);
//----------------------------------------------------------------------------------------------------------------
`ifndef CS_SW_SKEL
      
    wire datad = f0;
    wire datac = f1;
    wire datab = f2;
    wire dataa = f3;
    reg lut4;

`ifdef HW_SIM
    always@(datad or datac or datab or dataa or mask) begin
        case({datad, datac, datab, dataa})
             4'b0000: lut4 = mask[0];
             4'b0001: lut4 = mask[1];
             4'b0010: lut4 = mask[2];
             4'b0011: lut4 = mask[3];
             4'b0100: lut4 = mask[4];
             4'b0101: lut4 = mask[5];
             4'b0110: lut4 = mask[6];
             4'b0111: lut4 = mask[7];
             4'b1000: lut4 = mask[8];
             4'b1001: lut4 = mask[9];
             4'b1010: lut4 = mask[10];
             4'b1011: lut4 = mask[11];
             4'b1100: lut4 = mask[12];
             4'b1101: lut4 = mask[13];
             4'b1110: lut4 = mask[14];
             4'b1111: lut4 = mask[15];
             default: lut4 = 1'bx;
         endcase
    end
`else
    always@(datad or datac or datab or dataa or mask) begin
     	if(datad)
     		if(datac)
     			if(datab)
     				if(dataa)   lut4 = mask[15];
     				else        lut4 = mask[14];
     			else
     				if(dataa)   lut4 = mask[13];
     				else        lut4 = mask[12];
     		else if(datab)
     				if(dataa)   lut4 = mask[11];
     				else        lut4 = mask[10];
     			else
     				if(dataa)   lut4 = mask[9];
     				else        lut4 = mask[8];
     	else
     		if(datac)
     			if(datab)
     				if(dataa)   lut4 = mask[7];
     				else        lut4 = mask[6];
     			else
     				if(dataa)   lut4 = mask[5];
     				else        lut4 = mask[4];
     		else if(datab)
     				if(dataa)   lut4 = mask[3];
     				else        lut4 = mask[2];
     			else
     				if(dataa)   lut4 = mask[1];
     				else        lut4 = mask[0];
    end
`endif
    assign		dx = lut4;

	specify
       
        ( f0 =>  dx    ) = (0,0);
        ( f1 =>  dx    ) = (0,0);
        ( f2 =>  dx    ) = (0,0);
        ( f3 =>  dx    ) = (0,0);
        
     endspecify
    
`endif

endmodule

module LUT4C (
	     dx,
         s,
         co,
	     f3,
	     f2,
	     f1,
	     f0,
         ci,
         ca

	     );

   input		f3;
   input		f2;
   input		f1;
   input		f0;
   input		ci;
   input		ca;

   output		dx;
   output		s;
   output       co;

   parameter    config_data = "0000";

//----------------------------------------------------------------------------------------------------------------
    parameter   is_le_cin_inv   = "false";  //le carry input invert, default is "true"
    parameter   is_ca_not_inv   = "true";   //lut4c ca input invert, default is "false"
    parameter   is_byp_used     = "false";  //set by router, whether bypass is used as ca input
    parameter   le_skip_en      = "false";  //le carry skip logic enable, default is "false"
    parameter   is_le_cin_below = "false";  //le carry input from local or from blow LE, default is "false"
    
    wire    ci_in = is_le_cin_inv == "true" ? ~ci : ci;
    wire    ca_in = is_ca_not_inv == "true" ?   (is_byp_used == "true" ? ~ca : ca) : 
                                                (is_byp_used == "true" ? ca : ~ca);
    
	function [16:1]	str_to_bin ;
	  input	[8*4:1]	s;
	  reg	[8*4:1]	reg_s;
	  reg	[4:1]	digit [8:1];
	  reg	[8:1]	tmp;
	  integer m;
	  integer ivalue ;
        begin
            ivalue = 0;
            reg_s = s;
            for (m=1; m<=4; m= m+1 )
            begin
                tmp = reg_s[32:25];
                digit[m] = tmp & 8'b00001111;
                reg_s = reg_s << 8;
                if (tmp[7] == 'b1)
                    digit[m] = digit[m] + 9;
            end
            str_to_bin = {digit[1], digit[2], digit[3], digit[4]};
        end   
	endfunction
    
    wire [15:0] 		mask = str_to_bin(config_data);
//----------------------------------------------------------------------------------------------------------------

`ifndef CS_SW_SKEL

   
   wire datad = f0;
   wire datac = f1;
   wire datab = f2;
   wire dataa = f3;
   reg lut4;

`ifdef HW_SIM
   always@(datad or datac or datab or dataa or mask) begin
       case({datad, datac, datab, dataa})
            4'b0000: lut4 = mask[0];
            4'b0001: lut4 = mask[1];
            4'b0010: lut4 = mask[2];
            4'b0011: lut4 = mask[3];
            4'b0100: lut4 = mask[4];
            4'b0101: lut4 = mask[5];
            4'b0110: lut4 = mask[6];
            4'b0111: lut4 = mask[7];
            4'b1000: lut4 = mask[8];
            4'b1001: lut4 = mask[9];
            4'b1010: lut4 = mask[10];
            4'b1011: lut4 = mask[11];
            4'b1100: lut4 = mask[12];
            4'b1101: lut4 = mask[13];
            4'b1110: lut4 = mask[14];
            4'b1111: lut4 = mask[15];
            //default: lut4 = 1'bx;
        endcase
   end
`else
    always@(datad or datac or datab or dataa or mask) begin
     	if(datad)
     		if(datac)
     			if(datab)
     				if(dataa)   lut4 = mask[15];
     				else        lut4 = mask[14];
     			else
     				if(dataa)   lut4 = mask[13];
     				else        lut4 = mask[12];
     		else if(datab)
     				if(dataa)   lut4 = mask[11];
     				else        lut4 = mask[10];
     			else
     				if(dataa)   lut4 = mask[9];
     				else        lut4 = mask[8];
     	else
     		if(datac)
     			if(datab)
     				if(dataa)   lut4 = mask[7];
     				else        lut4 = mask[6];
     			else
     				if(dataa)   lut4 = mask[5];
     				else        lut4 = mask[4];
     		else if(datab)
     				if(dataa)   lut4 = mask[3];
     				else        lut4 = mask[2];
     			else
     				if(dataa)   lut4 = mask[1];
     				else        lut4 = mask[0];
    end
`endif

    assign		dx = lut4;

    assign s = ci_in ^ dx;
    assign co = dx ? ci_in : ca_in;

	specify
       
        ( f0 =>  dx    ) = (0,0);
        ( f1 =>  dx    ) = (0,0);
        ( f2 =>  dx    ) = (0,0);
        ( f3 =>  dx    ) = (0,0);
        ( f0 =>  s     ) = (0,0);
        ( f1 =>  s     ) = (0,0);
        ( f2 =>  s     ) = (0,0);
        ( f3 =>  s     ) = (0,0);
        ( f0 =>  co    ) = (0,0);
        ( f1 =>  co    ) = (0,0);
        ( f2 =>  co    ) = (0,0);
        ( f3 =>  co    ) = (0,0);
        ( ci =>  s     ) = (0,0);
        ( ci =>  co    ) = (0,0);
        ( ca =>  co    ) = (0,0);
        
    endspecify


`endif


endmodule


module REGS (
	    qx,
	    di,
	    a_sr,
	    mclk_b,
	    sclk,
            shift,
            qs,
            up_i,
            up_o,
            down_i,
            down_o
	    );

   output		qx;
   output		qs;
   output		up_o;
   output		down_o;

   input		shift;
   input		di;
   input		a_sr;
   input		mclk_b;
   input		sclk;
   input		up_i;
   input		down_i;

   parameter    preset = 1'b0;
   parameter    ignore_shift = "false";
   parameter    shift_direct = "down";
   parameter    use_reg_fdbk = "false";

   reg 			qx_reg;
   reg 			qx_lat;
   reg          mout;

`ifndef CS_SW_SKEL

   wire sel = ~(~shift | (ignore_shift == "true"));

   wire	rst_= a_sr || (preset == 1'b1);
   wire	set	= !( a_sr ||  ~(preset == 1'b1));	
   
   always @(*) begin
       if (rst_ == 1'b0) begin
           mout <= 1;
       end else if (set) begin
           mout <= 0;
       end else if (mclk_b == 0) begin
           mout <= sel ? ~qs : ~di;
       end else if (mclk_b == 1) begin
           mout <= mout;
       end else
           mout <= 1'bx;
   end

   initial qx_reg = 1'b0;
   
   always @(*) begin
       if (rst_ == 1'b0) begin
           qx_reg <= 1;
       end else if (set) begin
           qx_reg <= 0;
       end else if (sclk == 1) begin
           qx_reg <= mout;
       end else if (sclk == 0) begin
           qx_reg <= qx_reg;
       end else
           qx_reg <= 1'bx;
   end 
   
   assign qx = ~qx_reg;

   assign up_o = qx;
   assign down_o = qx;
   wire s1 = 
       (shift_direct == "up") ? up_i : down_i;

   assign qs =
       (use_reg_fdbk == "true") ? qx : s1;

    specify
        (posedge sclk => ( qx  +: di) ) = (0, 0) ;
        (posedge sclk => ( qs  +: di) ) = (0, 0) ;
        
        (posedge mclk_b => ( qx  +: di) ) = (0, 0) ;
        (posedge mclk_b => ( qs  +: di) ) = (0, 0) ;
              
        $setuphold(posedge sclk, di, 0, 0);
        $recrem(a_sr, posedge sclk,  0, 0);
        
        $setuphold(posedge mclk_b, di, 0, 0);
        $recrem(a_sr, posedge mclk_b,  0, 0);
        
     endspecify
   

`endif

endmodule


module REG (
    qx,
    di,
    a_sr,
    en,
    mclk_b,
    sclk,
	shift ,
    qs,
    up_i,
    up_o,
    down_i,
    down_o
    );

//----------------------------------------------------------------------------------------------------------------
    //single register parameter
    parameter   preset          = 1'b0;     //register preset, default is "1'b0"
    parameter   ignore_shift    = "true";   //ignore shift, default is "true"
    parameter   use_reg_fdbk    = "false";  //use register feedback, default is "false"
    parameter   shift_direct    = "up";     //shift chain direction set, default is "up"
    
    //whole LE parameter
    parameter   is_en_used = "false";       //use external enable or always enable, default is "false"
    parameter 	is_le_clk_inv = "false";    //le input clock invert, default is "false"
    parameter 	is_le_has_clk = "true";     //le has clock input, default is "true"
    parameter 	le_lat_mode   = "false";    //all le reigisters used as latch, default is "false"
    parameter 	le_sync_mode  = "false";    //all le reigisters work at sync mode, default is "false"
    
    parameter 	le_sh0_always_en  = "false";    //le shift chain 03 always enable, default is "false"
    parameter 	le_sh1_always_en  = "false";    //le shift chain 47 always enable, default is "false"
    
    parameter   is_le_en_not_inv  = "true";     //le registers enable not invert, default is "true"
    parameter   is_le_sr_inv   = "false";       //le registers sr invert, default is "false"
    parameter   is_le_sh0_en_not_inv = "true";  //le shift chain 03 enable not invert, default is "true"
    parameter   is_le_sh1_en_not_inv = "true";  //le shift chain 47 enable not invert, default is "true"
//----------------------------------------------------------------------------------------------------------------

    output		qx;     // Data output
    output		qs;
    output		up_o;
    output		down_o;
    input		di;     // Data input
    input		a_sr;   // Asynchronous set/reset
    input		en;     // Clock enable
    input		mclk_b; // This clock is for latch mode
    input		sclk;   // This clock is for normal register mode
    input       shift;
    input		up_i;
    input		down_i;

//----------------------------------------------------------------------------------------------------------------
//LBUF
//----------------------------------------------------------------------------------------------------------------
    reg     sr_latch;
    reg 	en_latch;
    wire    clk1;
    wire    clk2;
    
    wire    en_in = is_le_en_not_inv == "true" ? en : ~en;
    wire    sr_in = is_le_sr_inv == "true" ? ~a_sr : a_sr;
    wire    sh_in = (is_le_sh0_en_not_inv == "false" || is_le_sh1_en_not_inv == "false") ? ~shift : shift;
    wire    sh_en = (le_sh0_always_en == "true" || le_sh1_always_en == "true") ? 1'b1 : sh_in;

    assign  clk1  = (is_le_has_clk == "true")  ? sclk : 1'b1;
    assign  clk2  = (is_le_clk_inv == "true")  ? !clk1: clk1;
    
    wire clkb = ~clk2;
    wire sri = ~sr_in;

    always @(clkb or sri) begin
       if (clkb == 1) sr_latch <= sri ;
    end

    wire a_sr_in  = (le_sync_mode == "true") ? ~(sr_latch&clk2) : sr_in ;

    wire mclk_b_in =    (le_lat_mode == "true")? 1'b0 :
    			        (is_en_used == "true")? (clk2 &en_latch) : 
    			        (is_en_used == "false")? clk2  :
     			        1'bx ;

    always @(clkb or en_in) begin
       if (clkb == 1) en_latch <= en_in;
    end
    
    wire sclk_in = (is_en_used == "true" ) ? (clk2 & en_latch) : clk2;

//----------------------------------------------------------------------------------------------------------------
//REGS
//----------------------------------------------------------------------------------------------------------------
    reg 			qx_reg;
    reg 			qx_lat;
    reg          mout;

    wire sel = ~(~sh_en | (ignore_shift == "true"));

    wire	rst_= a_sr_in || (preset == 1'b1);
    wire	set	= !( a_sr_in ||  ~(preset == 1'b1));	
    
    always @(*) begin
        if (rst_ == 1'b0) begin
            mout <= 1;
        end else if (set) begin
            mout <= 0;
        end else if (mclk_b_in == 0) begin
            mout <= sel ? ~qs : ~di;
        end else if (mclk_b_in == 1) begin
            mout <= mout;
        end else
            mout <= 1'bx;
    end

    initial qx_reg = 1'b0;
    
    always @(*) begin
        if (rst_ == 1'b0) begin
            qx_reg <= 1;
        end else if (set) begin
            qx_reg <= 0;
        end else if (sclk_in == 1) begin
            qx_reg <= mout;
        end else if (sclk_in == 0) begin
            qx_reg <= qx_reg;
        end else
            qx_reg <= 1'bx;
    end 
    
    assign qx = ~qx_reg;

    assign up_o = qx;
    assign down_o = qx;
    wire s1 = 
        (shift_direct == "up") ? up_i : down_i;

    assign qs =
       (use_reg_fdbk == "true") ? qx : s1;


    specify
        (posedge sclk => ( qx  +: di) ) = (0, 0) ;
        (posedge sclk => ( qs  +: di) ) = (0, 0) ;
              
        $setuphold(posedge sclk, di, 0, 0);
        $recrem(a_sr, posedge sclk,  0, 0);
        
     endspecify
   

endmodule


module LBUF (
		clk,
		en,
		sr,
		rc,
		sh,
		a_sr,
		mclk_b,
		sclk
		);

   input		clk;
   input		en;
   input   		sr;
   input  [1:0]	rc;

   output [1:0]	sh;
   output		a_sr;
   output		mclk_b;
   output		sclk;


   reg     		sr_latch;
   reg 			en_latch;
   wire         clk1;
   wire         clk2;

   parameter    is_en_used = "true";
   parameter    is_le_clk_inv = "false";
   parameter    is_le_has_clk = "false";
   parameter    le_lat_mode = "false";
   parameter    le_sh0_always_en = "false";
   parameter    le_sh1_always_en = "false";
   parameter    le_sync_mode = "false";
//----------------------------------------------------------------------------------------------------------------
	parameter   is_le_en_not_inv   = "true";   //le registers enable invert, default is "false"
	parameter   is_le_sr_inv   = "false";   //le registers sr invert, default is "false"
	parameter   is_le_sh0_en_not_inv = "true"; //le shift chain 03 enable invert, default is "false"
	parameter   is_le_sh1_en_not_inv = "true"; //le shift chain 47 enable invert, default is "false"

    wire    en_in = is_le_en_not_inv == "true" ? en : ~en;
    wire    sr_in = is_le_sr_inv == "true" ? ~sr : sr;
    wire    rc0_in = is_le_sh0_en_not_inv == "true" ? rc[0] : ~rc[0];
    wire    rc1_in = is_le_sh1_en_not_inv == "true" ? rc[1] : ~rc[1];
//----------------------------------------------------------------------------------------------------------------

`ifndef CS_SW_SKEL
    assign       clk1  = (is_le_has_clk == "true")  ?  clk : 1'b1;
    assign       clk2  = (is_le_clk_inv == "true")  ? !clk1: clk1;

    assign		sh[0] = (le_sh0_always_en == "true") ? 1'b1 : rc0_in;
    assign		sh[1] = (le_sh1_always_en == "true") ? 1'b1 : rc1_in;
    
    wire clkb = ~clk2;
    wire sri = ~sr_in;

    always @(clkb or sri) begin
       if (clkb == 1) sr_latch <= sri ;
    end

    assign  		a_sr  = (le_sync_mode == "true") ? ~(sr_latch&clk2) : sr_in ;

    assign 		mclk_b = (le_lat_mode == "true")? 1'b0 :
    						 (is_en_used == "true")? (clk2 &en_latch) : 
    						 (is_en_used == "false")? clk2  :
     			 		 1'bx ;

    always @(clkb or en_in) begin
       if (clkb == 1) en_latch <= en_in;
    end
   
    assign sclk = (is_en_used == "true" ) ? (clk2 & en_latch) : clk2;


	specify
       
        ( clk =>  sclk ) = (0,0);                     
        ( clk =>  mclk_b ) = (0,0);                     
  
            
    endspecify
   

`endif

endmodule


module CARRY_SKIP_OUT (
  p4_in_b,
  p0b,
  p1b,
  p2b,
  p3b,

  r4_out_b,
  p4_out_b,
  p8_out_b
);    

input p4_in_b;
input p0b;
input p1b;
input p2b;
input p3b;

output r4_out_b;
output p4_out_b;
output p8_out_b;

wire  p01 ;
wire  p23 ;

    parameter    is_le_cin_below = "false";
    parameter    le_skip_en = "false";

`ifndef CS_SW_IGNORE
    wire p4_in_b_logic = (~((is_le_cin_below == "true")&(le_skip_en == "true")) | p4_in_b);

    assign p01 = ~(~p0b|~p1b);
    assign p23 = ~(~p2b|~p3b);
    
    assign r4_out_b = p01&p23;
    assign p4_out_b = !(p01&p23&p4_in_b_logic);
    assign p8_out_b = !(p01&p23&~p4_in_b_logic);


	specify
       
        ( p0b =>  r4_out_b ) = (0,0);                     
        ( p1b =>  r4_out_b ) = (0,0);                     
        ( p2b =>  r4_out_b ) = (0,0);                 
        ( p3b =>  r4_out_b ) = (0,0);
        
        
        ( p0b =>  p4_out_b ) = (0,0);                     
        ( p1b =>  p4_out_b ) = (0,0);                     
        ( p2b =>  p4_out_b ) = (0,0);                 
        ( p3b =>  p4_out_b ) = (0,0);
        ( p4_in_b =>  p4_out_b ) = (0,0);
        
        ( p0b =>  p8_out_b ) = (0,0);                     
        ( p1b =>  p8_out_b ) = (0,0);                     
        ( p2b =>  p8_out_b ) = (0,0);                 
        ( p3b =>  p8_out_b ) = (0,0);
        ( p4_in_b =>  p8_out_b ) = (0,0);
            
    endspecify

`endif
    

endmodule


module CFG_CARRY_SKIP_IN (
  mux_alt_cin,
  c4_in,
  c_skip4_in,
  c_skip8_in,
  
  r4_in_b,
  p4_in_b,
  p8_in_b,

  c_in
);

input mux_alt_cin;
input c4_in;
input c_skip4_in;
input c_skip8_in;

input r4_in_b;
input p4_in_b;
input p8_in_b;

output c_in;

wire  [2:0] sel ;

    parameter    is_le_cin_below = "false";
    parameter    le_skip_en = "false";

//----------------------------------------------------------------------------------------------------------------
    parameter   is_le_cin_inv   = "false";   //le carry input invert, default is "true"
    wire    mux_alt_cin_in = (is_le_cin_inv == "false") ? mux_alt_cin : ~mux_alt_cin;
//----------------------------------------------------------------------------------------------------------------

`ifndef CS_SW_IGNORE
    assign sel = {!p8_in_b,!p4_in_b,!r4_in_b};
    assign c_in = 
             ( le_skip_en == "false" ) ? (( is_le_cin_below == "false" ) ? mux_alt_cin_in : c4_in) :
             (( is_le_cin_below == "false" ) ? mux_alt_cin_in :
    		 ( sel == 3'b001     ) ? c4_in       :
    		 ( sel == 3'b010     ) ? c_skip4_in  :
    		 ( sel == 3'b100     ) ? c_skip8_in  : 1'bx);


	specify
       
        ( mux_alt_cin =>  c_in ) = (0,0);                     
        ( c4_in =>  c_in ) = (0,0);                     
        ( c_skip4_in =>  c_in ) = (0,0);                 
        ( c_skip8_in =>  c_in ) = (0,0);       
        ( p8_in_b =>  c_in ) = (0,0);                     
        ( p4_in_b =>  c_in ) = (0,0);                     
        ( r4_in_b =>  c_in ) = (0,0);                 
        
            
    endspecify
    
`endif

endmodule


module CFG_DYN_SWITCH (
	      out,
	      in0,
	      in1
	      );

   input		in0;
   input		in1;

   output		out;

   parameter 		sel = 3'b000;
   parameter 		gclk_mux = 0; //0,1,2,3,4,5,6,7

   assign 		out =   (sel == 3'b000 || sel == "000") ? 1'b0 :
			            (sel == 3'b001 || sel == "001") ? in0 : 
			            (sel == 3'b010 || sel == "010") ? in1 :
                        (sel == 3'b011 || sel == "011") ? in0 : 
                        (sel == 3'b111 || sel == "111") ? in1 : 1'bx; 
endmodule

module CFG_DYN_SWITCH_S3 (
	      out,
	      in0,
	      in1,
		  fp_sel
	      );

   input		in0;
   input		in1;
   input		fp_sel;

   output		out;

   parameter 		sel = 3'b100;
   parameter 		gclk_mux = 0; //0,1,2,3

   assign 		out = 
						(sel == 3'b?00) ? 1'b0 :
                        (sel == 3'b?01) ? in0 :
						(sel == 3'b?10) ? in1 :
						(sel == 3'b111) ? fp_sel ? in1 : in0 : 1'bx;	   

endmodule


module CFGMUX2S (
	      out,
	      in0,
	      in1,
	      sel
	      );

   input		in0;
   input		in1;
   input		sel;

   output		out;
   assign 		out = (sel == 1'b0) ? in0 :
			      (sel == 1'b1) ? in1 : 1'bx;

	specify
       
        ( in0 =>  out ) = (0,0);                     
        ( in1 =>  out ) = (0,0);                     
        ( sel =>  out ) = (0,0);                                       
            
    endspecify
    

endmodule


module CONST (
	    out
	    );

   output		out;

   parameter    sel = 1'b0;

  
`ifndef CS_SW_SKEL
   assign 		out = (sel == 1'b1)? 1'b1 : 1'b0 ;
`endif


endmodule


module GBUF_GATE(
    clk,
    en,
    clk_out
);

    input clk;
    input en;
    output clk_out;

    reg en_latch;
    always @(*) begin
        if (clk == 0)
            en_latch <= en;
    end

    assign clk_out = clk & en_latch;


endmodule

module RBUF_GATE(
    clk,
    en,
    clk_out
);

    input clk;
    input en;
    output clk_out;

    reg en_latch;
    always @(*) begin
        if (clk == 0)
            en_latch <= en;
    end

    assign clk_out = clk & en_latch;


endmodule

module M7A_MAC (
    // Outputs
    a_mac_out, 
    b_mac_out, 
    a_overflow, 
    b_overflow,
    // Inputs
	a_dinxy_cen, b_dinxy_cen,
	a_dinz_cen, b_dinz_cen,
	a_mac_out_cen, b_mac_out_cen,
	a_in_sr, b_in_sr,
	a_out_sr, b_out_sr,
    a_dinx, a_diny, 
    b_dinx, b_diny, 
    a_dinz, b_dinz,
    clk, 
    a_sload, b_sload, 
    a_acc_en, a_dinz_en, 
    b_acc_en, b_dinz_en
);

    //a_mac_out = a_dinx * a_diny + a_dinz;
`ifdef CS_FORMALPRO_HACK
    wire [2:0] modea_sel;
    wire [2:0] modeb_sel;

    wire adinx_input_mode; 
    wire adiny_input_mode; 
    wire adinz_input_mode; 
    wire amac_output_mode; 

    wire bdinx_input_mode; 
    wire bdiny_input_mode; 
    wire bdinz_input_mode; 
    wire bmac_output_mode; 

    wire a_in_rstn_sel;
    wire a_in_setn_sel;
    wire a_sr_syn_sel;
    wire a_ovf_rstn_sel;
    wire [47:0] a_out_rstn_sel;
    wire [47:0] a_out_setn_sel;

    wire b_in_rstn_sel ;
    wire b_in_setn_sel ;
    wire b_sr_syn_sel ;
    wire b_ovf_rstn_sel;
    wire [27:0] b_out_rstn_sel;
    wire [27:0] b_out_setn_sel ;

`else
    parameter modea_sel = 3'b000;
    parameter modeb_sel = 3'b000;

    parameter adinx_input_mode = 1'b0; 
    parameter adiny_input_mode = 1'b0; 
    parameter adinz_input_mode = 1'b0; 
    parameter amac_output_mode = 1'b0; 

    parameter bdinx_input_mode = 1'b0; 
    parameter bdiny_input_mode = 1'b0; 
    parameter bdinz_input_mode = 1'b0; 
    parameter bmac_output_mode = 1'b0; 

    parameter a_in_rstn_sel = 1'b0;
    parameter a_in_setn_sel = 1'b0;
    parameter a_sr_syn_sel= 1'b0;
    parameter a_ovf_rstn_sel= 1'b0;
    parameter [47:0] a_out_rstn_sel= 48'b0;
    parameter [47:0] a_out_setn_sel= 48'b0;
    parameter a_out_rstn_sel_h = 24'b0;
    parameter a_out_rstn_sel_l = 24'b0;
    parameter a_out_setn_sel_h = 24'b0;
    parameter a_out_setn_sel_l = 24'b0;

    parameter b_in_rstn_sel = 1'b0;
    parameter b_in_setn_sel = 1'b0;
    parameter b_sr_syn_sel= 1'b0;
    parameter b_ovf_rstn_sel= 1'b0;
    parameter b_out_rstn_sel= 28'b0;
    parameter b_out_setn_sel= 28'b0;
`endif

//---------------------------------------------------------------------------------
//for SW
//---------------------------------------------------------------------------------
    //parameter modea_sel = ""; //"18x18", "12x9", "9x9"
    //parameter modeb_sel = ""; //"18x18", "12x9", "9x9"

    //parameter adinx_input_mode = "bypass"; //"register" 
    //parameter adiny_input_mode = "bypass"; //"register" 
    //parameter adinz_input_mode = "bypass"; //"register" 
    //parameter amac_output_mode = "bypass"; //"register" 

    //parameter bdinx_input_mode = "bypass"; //"register" 
    //parameter bdiny_input_mode = "bypass"; //"register" 
    //parameter bdinz_input_mode = "bypass"; //"register" 
    //parameter bmac_output_mode = "bypass"; //"register" 
//---------------------------------------------------------------------------------

	input	a_dinxy_cen, b_dinxy_cen;
	input	a_dinz_cen, b_dinz_cen;
	input	a_mac_out_cen, b_mac_out_cen;
	input	a_in_sr, b_in_sr;
	input	a_out_sr, b_out_sr;

    //Group A, multiplier input
    input [13:0] a_dinx ;
    input [9:0]  a_diny ;
    
    //Group B, multiplier input
    input [13:0] b_dinx ;
    input [9:0]  b_diny ;
    
    //Group A,B, post add input
    input [24:0] a_dinz;
    input [24:0] b_dinz;
    
    //global signal
    input clk;
    
    //acculate load 
    input a_sload;
    input b_sload;
    
    //acculate en
    input a_acc_en;
    input b_acc_en;
    
    //post add en
    input a_dinz_en;
    input b_dinz_en;
    
    //Group A,B multiplier/acculate output
    output [24:0] a_mac_out;
    output [24:0] b_mac_out;
    
    //Group A,B overflow
    output a_overflow;
    output b_overflow;

	wire clk_in;
	wire rstn_in;
	
	//a mac
	wire [12:0] a_x_in ;
	wire [9:0]  a_y_in ;
	wire [24:0] a_z_in;
	
	reg [12:0] a_qx_o_mux ;
	reg [12:0] a_qx_o_reg_syn ;
	reg [12:0] a_qx_o_reg_asyn ;
	wire [12:0] a_qx_o_reg ;
	
	reg [9:0] a_qy_o_mux ;
	reg [9:0] a_qy_o_reg_syn ;
	reg [9:0] a_qy_o_reg_asyn ;
	wire [9:0] a_qy_o_reg ;
	
	reg [24:0] a_qz_o_mux ;
	reg [24:0] a_qz_o_reg_syn ;
	reg [24:0] a_qz_o_reg_asyn ;
	wire [24:0] a_qz_o_reg ;
	
	wire [24:0] a_mult_o ;
	wire [24:0] a_qmac_o_reg;
	wire [24:0] a_qmac_i;
	wire  [24:0] a_qmac_o_reg_syn;
	wire  [24:0] a_qmac_o_reg_asyn;
	reg [24:0] a_add_mux ;
	wire [24:0] a_mac_o_mux ;
	wire [24:0] a_mac_o_out ;
	wire [24:0] a_add_o ;

	wire mac_a_overflow;
	wire a_overflow_tmp;
	wire b_overflow_tmp;
	wire mac_overflow_tmp;//for 18x18
	wire mac_overflow;//for 18x18

    wire  mac_a_overflow_d;
    reg   mac_a_overflow_d_asyn;
    reg   mac_a_overflow_d_syn;
	reg   mac_a_overflow_temp_asyn ;
	wire  mac_a_overflow_or ;
    wire  mac_b_overflow_d;
    reg   mac_b_overflow_d_asyn;
    reg   mac_b_overflow_d_syn;
	reg   mac_b_overflow_temp_asyn ;
	wire  mac_b_overflow_or ;
	reg   mac_overflow_d_asyn;//for 18x18
	reg   mac_overflow_d_syn;//for 18x18
	reg   mac_overflow_temp_asyn ;//for 18x18
	wire  mac_overflow_or ;//for 18x18
	wire  mac_overflow_d;//for 18x18
		
	wire a_signedx;
	wire a_signedy;
	wire a_signedz;
	
	wire a_sload_i;
	wire a_acc_en_i; 
    reg  a_dinz_en_i;
    wire  a_dinz_en_reg;
    reg  a_dinz_en_reg_asyn;
    reg  a_dinz_en_reg_syn;

	wire a_in_rstn ;
	wire a_in_setn ;
	wire a_ovf_rstn;
	wire a_0_out_rstn;
	wire a_1_out_rstn;
	wire a_2_out_rstn;
	wire a_3_out_rstn;
	wire a_4_out_rstn;
	wire a_5_out_rstn;
	wire a_6_out_rstn;
	wire a_7_out_rstn;
	wire a_8_out_rstn;
	wire a_9_out_rstn;
	wire a_10_out_rstn;
	wire a_11_out_rstn;
	wire a_12_out_rstn;
	wire a_13_out_rstn;
	wire a_14_out_rstn;
	wire a_15_out_rstn;
	wire a_16_out_rstn;
	wire a_17_out_rstn;
	wire a_18_out_rstn;
	wire a_19_out_rstn;
	wire a_20_out_rstn;
	wire a_21_out_rstn;
	wire a_22_out_rstn;
	wire a_23_out_rstn;
	wire a_24_out_rstn;
	wire a_25_out_rstn;
	wire a_26_out_rstn;
	wire a_27_out_rstn;
	wire a_28_out_rstn;
	wire a_29_out_rstn;
	wire a_30_out_rstn;
	wire a_31_out_rstn;
	wire a_32_out_rstn;
	wire a_33_out_rstn;
	wire a_34_out_rstn;
	wire a_35_out_rstn;
	wire a_36_out_rstn;
	wire a_37_out_rstn;
	wire a_38_out_rstn;
	wire a_39_out_rstn;
	wire a_40_out_rstn;
	wire a_41_out_rstn;
	wire a_42_out_rstn;
	wire a_43_out_rstn;
	wire a_44_out_rstn;
	wire a_45_out_rstn;
	wire a_46_out_rstn;
	wire a_47_out_rstn;

	wire a_0_out_setn;
	wire a_1_out_setn;
	wire a_2_out_setn;
	wire a_3_out_setn;
	wire a_4_out_setn;
	wire a_5_out_setn;
	wire a_6_out_setn;
	wire a_7_out_setn;
	wire a_8_out_setn;
	wire a_9_out_setn;
	wire a_10_out_setn;
	wire a_11_out_setn;
	wire a_12_out_setn;
	wire a_13_out_setn;
	wire a_14_out_setn;
	wire a_15_out_setn;
	wire a_16_out_setn;
	wire a_17_out_setn;
	wire a_18_out_setn;
	wire a_19_out_setn;
	wire a_20_out_setn;
	wire a_21_out_setn;
	wire a_22_out_setn;
	wire a_23_out_setn;
	wire a_24_out_setn;
	wire a_25_out_setn;
	wire a_26_out_setn;
	wire a_27_out_setn;
	wire a_28_out_setn;
	wire a_29_out_setn;
	wire a_30_out_setn;
	wire a_31_out_setn;
	wire a_32_out_setn;
	wire a_33_out_setn;
	wire a_34_out_setn;
	wire a_35_out_setn;
	wire a_36_out_setn;
	wire a_37_out_setn;
	wire a_38_out_setn;
	wire a_39_out_setn;
	wire a_40_out_setn;
	wire a_41_out_setn;
	wire a_42_out_setn;
	wire a_43_out_setn;
	wire a_44_out_setn;
	wire a_45_out_setn;
	wire a_46_out_setn;
	wire a_47_out_setn;
	
	wire b_in_rstn ;
	wire b_in_setn ;
	wire b_ovf_rstn ;
	wire b_0_out_rstn;
	wire b_1_out_rstn;
	wire b_2_out_rstn;
	wire b_3_out_rstn;
	wire b_4_out_rstn;
	wire b_5_out_rstn;
	wire b_6_out_rstn;
	wire b_7_out_rstn;
	wire b_8_out_rstn;
	wire b_9_out_rstn;
	wire b_10_out_rstn;
	wire b_11_out_rstn;
	wire b_12_out_rstn;
	wire b_13_out_rstn;
	wire b_14_out_rstn;
	wire b_15_out_rstn;
	wire b_16_out_rstn;
	wire b_17_out_rstn;
	wire b_18_out_rstn;
	wire b_19_out_rstn;
	wire b_20_out_rstn;
	wire b_21_out_rstn;
	wire b_22_out_rstn;
	wire b_23_out_rstn;
	wire b_24_out_rstn;

	wire b_0_out_setn;
	wire b_1_out_setn;
	wire b_2_out_setn;
	wire b_3_out_setn;
	wire b_4_out_setn;
	wire b_5_out_setn;
	wire b_6_out_setn;
	wire b_7_out_setn;
	wire b_8_out_setn;
	wire b_9_out_setn;
	wire b_10_out_setn;
	wire b_11_out_setn;
	wire b_12_out_setn;
	wire b_13_out_setn;
	wire b_14_out_setn;
	wire b_15_out_setn;
	wire b_16_out_setn;
	wire b_17_out_setn;
	wire b_18_out_setn;
	wire b_19_out_setn;
	wire b_20_out_setn;
	wire b_21_out_setn;
	wire b_22_out_setn;
	wire b_23_out_setn;
	wire b_24_out_setn;
//generate set/reset signal
assign a_in_rstn  = a_in_rstn_sel  == 1 ? a_in_sr : 1'b1;
assign a_in_setn  = a_in_setn_sel  == 1 ? a_in_sr : 1'b1;
assign a_ovf_rstn = a_ovf_rstn_sel == 1 ? a_out_sr : 1'b1;
assign a_0_out_rstn = a_out_rstn_sel[0] == 1 ? a_out_sr : 1'b1;
assign a_1_out_rstn = a_out_rstn_sel[1] == 1 ? a_out_sr : 1'b1;
assign a_2_out_rstn = a_out_rstn_sel[2] == 1 ? a_out_sr : 1'b1;
assign a_3_out_rstn = a_out_rstn_sel[3] == 1 ? a_out_sr : 1'b1;
assign a_4_out_rstn = a_out_rstn_sel[4] == 1 ? a_out_sr : 1'b1;
assign a_5_out_rstn = a_out_rstn_sel[5] == 1 ? a_out_sr : 1'b1;
assign a_6_out_rstn = a_out_rstn_sel[6] == 1 ? a_out_sr : 1'b1;
assign a_7_out_rstn = a_out_rstn_sel[7] == 1 ? a_out_sr : 1'b1;
assign a_8_out_rstn = a_out_rstn_sel[8] == 1 ? a_out_sr : 1'b1;
assign a_9_out_rstn = a_out_rstn_sel[9] == 1 ? a_out_sr : 1'b1;
assign a_10_out_rstn = a_out_rstn_sel[10] == 1 ? a_out_sr : 1'b1;
assign a_11_out_rstn = a_out_rstn_sel[11] == 1 ? a_out_sr : 1'b1;
assign a_12_out_rstn = a_out_rstn_sel[12] == 1 ? a_out_sr : 1'b1;
assign a_13_out_rstn = a_out_rstn_sel[13] == 1 ? a_out_sr : 1'b1;
assign a_14_out_rstn = a_out_rstn_sel[14] == 1 ? a_out_sr : 1'b1;
assign a_15_out_rstn = a_out_rstn_sel[15] == 1 ? a_out_sr : 1'b1;
assign a_16_out_rstn = a_out_rstn_sel[16] == 1 ? a_out_sr : 1'b1;
assign a_17_out_rstn = a_out_rstn_sel[17] == 1 ? a_out_sr : 1'b1;
assign a_18_out_rstn = a_out_rstn_sel[18] == 1 ? a_out_sr : 1'b1;
assign a_19_out_rstn = a_out_rstn_sel[19] == 1 ? a_out_sr : 1'b1;
assign a_20_out_rstn = a_out_rstn_sel[20] == 1 ? a_out_sr : 1'b1;
assign a_21_out_rstn = a_out_rstn_sel[21] == 1 ? a_out_sr : 1'b1;
assign a_22_out_rstn = a_out_rstn_sel[22] == 1 ? a_out_sr : 1'b1;
assign a_23_out_rstn = a_out_rstn_sel[23] == 1 ? a_out_sr : 1'b1;
assign a_24_out_rstn = a_out_rstn_sel[24] == 1 ? a_out_sr : 1'b1;
assign a_25_out_rstn = a_out_rstn_sel[25] == 1 ? a_out_sr : 1'b1;
assign a_26_out_rstn = a_out_rstn_sel[26] == 1 ? a_out_sr : 1'b1;
assign a_27_out_rstn = a_out_rstn_sel[27] == 1 ? a_out_sr : 1'b1;
assign a_28_out_rstn = a_out_rstn_sel[28] == 1 ? a_out_sr : 1'b1;
assign a_29_out_rstn = a_out_rstn_sel[29] == 1 ? a_out_sr : 1'b1;
assign a_30_out_rstn = a_out_rstn_sel[30] == 1 ? a_out_sr : 1'b1;
assign a_31_out_rstn = a_out_rstn_sel[31] == 1 ? a_out_sr : 1'b1;
assign a_32_out_rstn = a_out_rstn_sel[32] == 1 ? a_out_sr : 1'b1;
assign a_33_out_rstn = a_out_rstn_sel[33] == 1 ? a_out_sr : 1'b1;
assign a_34_out_rstn = a_out_rstn_sel[34] == 1 ? a_out_sr : 1'b1;
assign a_35_out_rstn = a_out_rstn_sel[35] == 1 ? a_out_sr : 1'b1;
assign a_36_out_rstn = a_out_rstn_sel[36] == 1 ? a_out_sr : 1'b1;
assign a_37_out_rstn = a_out_rstn_sel[37] == 1 ? a_out_sr : 1'b1;
assign a_38_out_rstn = a_out_rstn_sel[38] == 1 ? a_out_sr : 1'b1;
assign a_39_out_rstn = a_out_rstn_sel[39] == 1 ? a_out_sr : 1'b1;
assign a_40_out_rstn = a_out_rstn_sel[40] == 1 ? a_out_sr : 1'b1;
assign a_41_out_rstn = a_out_rstn_sel[41] == 1 ? a_out_sr : 1'b1;
assign a_42_out_rstn = a_out_rstn_sel[42] == 1 ? a_out_sr : 1'b1;
assign a_43_out_rstn = a_out_rstn_sel[43] == 1 ? a_out_sr : 1'b1;
assign a_44_out_rstn = a_out_rstn_sel[44] == 1 ? a_out_sr : 1'b1;
assign a_45_out_rstn = a_out_rstn_sel[45] == 1 ? a_out_sr : 1'b1;
assign a_46_out_rstn = a_out_rstn_sel[46] == 1 ? a_out_sr : 1'b1;
assign a_47_out_rstn = a_out_rstn_sel[47] == 1 ? a_out_sr : 1'b1;

assign a_0_out_setn = a_out_setn_sel[0] == 1 ? a_out_sr : 1'b1;
assign a_1_out_setn = a_out_setn_sel[1] == 1 ? a_out_sr : 1'b1;
assign a_2_out_setn = a_out_setn_sel[2] == 1 ? a_out_sr : 1'b1;
assign a_3_out_setn = a_out_setn_sel[3] == 1 ? a_out_sr : 1'b1;
assign a_4_out_setn = a_out_setn_sel[4] == 1 ? a_out_sr : 1'b1;
assign a_5_out_setn = a_out_setn_sel[5] == 1 ? a_out_sr : 1'b1;
assign a_6_out_setn = a_out_setn_sel[6] == 1 ? a_out_sr : 1'b1;
assign a_7_out_setn = a_out_setn_sel[7] == 1 ? a_out_sr : 1'b1;
assign a_8_out_setn = a_out_setn_sel[8] == 1 ? a_out_sr : 1'b1;
assign a_9_out_setn = a_out_setn_sel[9] == 1 ? a_out_sr : 1'b1;
assign a_10_out_setn = a_out_setn_sel[10] == 1 ? a_out_sr : 1'b1;
assign a_11_out_setn = a_out_setn_sel[11] == 1 ? a_out_sr : 1'b1;
assign a_12_out_setn = a_out_setn_sel[12] == 1 ? a_out_sr : 1'b1;
assign a_13_out_setn = a_out_setn_sel[13] == 1 ? a_out_sr : 1'b1;
assign a_14_out_setn = a_out_setn_sel[14] == 1 ? a_out_sr : 1'b1;
assign a_15_out_setn = a_out_setn_sel[15] == 1 ? a_out_sr : 1'b1;
assign a_16_out_setn = a_out_setn_sel[16] == 1 ? a_out_sr : 1'b1;
assign a_17_out_setn = a_out_setn_sel[17] == 1 ? a_out_sr : 1'b1;
assign a_18_out_setn = a_out_setn_sel[18] == 1 ? a_out_sr : 1'b1;
assign a_19_out_setn = a_out_setn_sel[19] == 1 ? a_out_sr : 1'b1;
assign a_20_out_setn = a_out_setn_sel[20] == 1 ? a_out_sr : 1'b1;
assign a_21_out_setn = a_out_setn_sel[21] == 1 ? a_out_sr : 1'b1;
assign a_22_out_setn = a_out_setn_sel[22] == 1 ? a_out_sr : 1'b1;
assign a_23_out_setn = a_out_setn_sel[23] == 1 ? a_out_sr : 1'b1;
assign a_24_out_setn = a_out_setn_sel[24] == 1 ? a_out_sr : 1'b1;
assign a_25_out_setn = a_out_setn_sel[25] == 1 ? a_out_sr : 1'b1;
assign a_26_out_setn = a_out_setn_sel[26] == 1 ? a_out_sr : 1'b1;
assign a_27_out_setn = a_out_setn_sel[27] == 1 ? a_out_sr : 1'b1;
assign a_28_out_setn = a_out_setn_sel[28] == 1 ? a_out_sr : 1'b1;
assign a_29_out_setn = a_out_setn_sel[29] == 1 ? a_out_sr : 1'b1;
assign a_30_out_setn = a_out_setn_sel[30] == 1 ? a_out_sr : 1'b1;
assign a_31_out_setn = a_out_setn_sel[31] == 1 ? a_out_sr : 1'b1;
assign a_32_out_setn = a_out_setn_sel[32] == 1 ? a_out_sr : 1'b1;
assign a_33_out_setn = a_out_setn_sel[33] == 1 ? a_out_sr : 1'b1;
assign a_34_out_setn = a_out_setn_sel[34] == 1 ? a_out_sr : 1'b1;
assign a_35_out_setn = a_out_setn_sel[35] == 1 ? a_out_sr : 1'b1;
assign a_36_out_setn = a_out_setn_sel[36] == 1 ? a_out_sr : 1'b1;
assign a_37_out_setn = a_out_setn_sel[37] == 1 ? a_out_sr : 1'b1;
assign a_38_out_setn = a_out_setn_sel[38] == 1 ? a_out_sr : 1'b1;
assign a_39_out_setn = a_out_setn_sel[39] == 1 ? a_out_sr : 1'b1;
assign a_40_out_setn = a_out_setn_sel[40] == 1 ? a_out_sr : 1'b1;
assign a_41_out_setn = a_out_setn_sel[41] == 1 ? a_out_sr : 1'b1;
assign a_42_out_setn = a_out_setn_sel[42] == 1 ? a_out_sr : 1'b1;
assign a_43_out_setn = a_out_setn_sel[43] == 1 ? a_out_sr : 1'b1;
assign a_44_out_setn = a_out_setn_sel[44] == 1 ? a_out_sr : 1'b1;
assign a_45_out_setn = a_out_setn_sel[45] == 1 ? a_out_sr : 1'b1;
assign a_46_out_setn = a_out_setn_sel[46] == 1 ? a_out_sr : 1'b1;
assign a_47_out_setn = a_out_setn_sel[47] == 1 ? a_out_sr : 1'b1;

assign b_in_rstn  = b_in_rstn_sel  == 1 ? b_in_sr : 1'b1;
assign b_in_setn  = b_in_setn_sel  == 1 ? b_in_sr : 1'b1;
assign b_ovf_rstn = b_ovf_rstn_sel == 1 ? b_out_sr : 1'b1;
assign b_0_out_rstn = b_out_rstn_sel[0] == 1 ? b_out_sr : 1'b1;
assign b_1_out_rstn = b_out_rstn_sel[1] == 1 ? b_out_sr : 1'b1;
assign b_2_out_rstn = b_out_rstn_sel[2] == 1 ? b_out_sr : 1'b1;
assign b_3_out_rstn = b_out_rstn_sel[3] == 1 ? b_out_sr : 1'b1;
assign b_4_out_rstn = b_out_rstn_sel[4] == 1 ? b_out_sr : 1'b1;
assign b_5_out_rstn = b_out_rstn_sel[5] == 1 ? b_out_sr : 1'b1;
assign b_6_out_rstn = b_out_rstn_sel[6] == 1 ? b_out_sr : 1'b1;
assign b_7_out_rstn = b_out_rstn_sel[7] == 1 ? b_out_sr : 1'b1;
assign b_8_out_rstn = b_out_rstn_sel[8] == 1 ? b_out_sr : 1'b1;
assign b_9_out_rstn = b_out_rstn_sel[9] == 1 ? b_out_sr : 1'b1;
assign b_10_out_rstn = b_out_rstn_sel[10] == 1 ? b_out_sr : 1'b1;
assign b_11_out_rstn = b_out_rstn_sel[11] == 1 ? b_out_sr : 1'b1;
assign b_12_out_rstn = b_out_rstn_sel[12] == 1 ? b_out_sr : 1'b1;
assign b_13_out_rstn = b_out_rstn_sel[13] == 1 ? b_out_sr : 1'b1;
assign b_14_out_rstn = b_out_rstn_sel[14] == 1 ? b_out_sr : 1'b1;
assign b_15_out_rstn = b_out_rstn_sel[15] == 1 ? b_out_sr : 1'b1;
assign b_16_out_rstn = b_out_rstn_sel[16] == 1 ? b_out_sr : 1'b1;
assign b_17_out_rstn = b_out_rstn_sel[17] == 1 ? b_out_sr : 1'b1;
assign b_18_out_rstn = b_out_rstn_sel[18] == 1 ? b_out_sr : 1'b1;
assign b_19_out_rstn = b_out_rstn_sel[19] == 1 ? b_out_sr : 1'b1;
assign b_20_out_rstn = b_out_rstn_sel[20] == 1 ? b_out_sr : 1'b1;
assign b_21_out_rstn = b_out_rstn_sel[21] == 1 ? b_out_sr : 1'b1;
assign b_22_out_rstn = b_out_rstn_sel[22] == 1 ? b_out_sr : 1'b1;
assign b_23_out_rstn = b_out_rstn_sel[23] == 1 ? b_out_sr : 1'b1;
assign b_24_out_rstn = b_out_rstn_sel[24] == 1 ? b_out_sr : 1'b1;

assign b_0_out_setn = b_out_setn_sel[0] == 1 ? b_out_sr : 1'b1;
assign b_1_out_setn = b_out_setn_sel[1] == 1 ? b_out_sr : 1'b1;
assign b_2_out_setn = b_out_setn_sel[2] == 1 ? b_out_sr : 1'b1;
assign b_3_out_setn = b_out_setn_sel[3] == 1 ? b_out_sr : 1'b1;
assign b_4_out_setn = b_out_setn_sel[4] == 1 ? b_out_sr : 1'b1;
assign b_5_out_setn = b_out_setn_sel[5] == 1 ? b_out_sr : 1'b1;
assign b_6_out_setn = b_out_setn_sel[6] == 1 ? b_out_sr : 1'b1;
assign b_7_out_setn = b_out_setn_sel[7] == 1 ? b_out_sr : 1'b1;
assign b_8_out_setn = b_out_setn_sel[8] == 1 ? b_out_sr : 1'b1;
assign b_9_out_setn = b_out_setn_sel[9] == 1 ? b_out_sr : 1'b1;
assign b_10_out_setn = b_out_setn_sel[10] == 1 ? b_out_sr : 1'b1;
assign b_11_out_setn = b_out_setn_sel[11] == 1 ? b_out_sr : 1'b1;
assign b_12_out_setn = b_out_setn_sel[12] == 1 ? b_out_sr : 1'b1;
assign b_13_out_setn = b_out_setn_sel[13] == 1 ? b_out_sr : 1'b1;
assign b_14_out_setn = b_out_setn_sel[14] == 1 ? b_out_sr : 1'b1;
assign b_15_out_setn = b_out_setn_sel[15] == 1 ? b_out_sr : 1'b1;
assign b_16_out_setn = b_out_setn_sel[16] == 1 ? b_out_sr : 1'b1;
assign b_17_out_setn = b_out_setn_sel[17] == 1 ? b_out_sr : 1'b1;
assign b_18_out_setn = b_out_setn_sel[18] == 1 ? b_out_sr : 1'b1;
assign b_19_out_setn = b_out_setn_sel[19] == 1 ? b_out_sr : 1'b1;
assign b_20_out_setn = b_out_setn_sel[20] == 1 ? b_out_sr : 1'b1;
assign b_21_out_setn = b_out_setn_sel[21] == 1 ? b_out_sr : 1'b1;
assign b_22_out_setn = b_out_setn_sel[22] == 1 ? b_out_sr : 1'b1;
assign b_23_out_setn = b_out_setn_sel[23] == 1 ? b_out_sr : 1'b1;
assign b_24_out_setn = b_out_setn_sel[24] == 1 ? b_out_sr : 1'b1;
	
	wire a_xreg = (adinx_input_mode == "register") || (adinx_input_mode == 1); 
	wire a_yreg = (adiny_input_mode == "register") || (adiny_input_mode == 1); 
	wire a_zreg = (adinz_input_mode == "register") || (adinz_input_mode == 1); 
	wire a_macreg = (amac_output_mode == "register") || (amac_output_mode == 1); 	
		
	//b mac
	wire [12:0] b_x_in ;
	wire [9:0]  b_y_in ;
	wire [24:0] b_z_in;
	
	reg [12:0] b_qx_o_mux ;
	wire [12:0] b_qx_o_reg ;
	reg  [12:0] b_qx_o_reg_asyn ;
	reg  [12:0] b_qx_o_reg_syn ;
	
	reg [9:0] b_qy_o_mux ;
	wire [9:0] b_qy_o_reg ;
	reg [9:0] b_qy_o_reg_asyn ;
	reg [9:0] b_qy_o_reg_syn ;
	
	reg [24:0] b_qz_o_mux ;
	wire [24:0] b_qz_o_reg ;
	reg [24:0] b_qz_o_reg_asyn ;
	reg [24:0] b_qz_o_reg_syn ;
	
	wire [24:0] b_mult_o ;
	wire [24:0] b_qmac_o_reg_asyn;
	wire [24:0] b_qmac_o_reg_syn;
	wire [24:0] b_qmac_o_reg;
	wire [24:0] b_qmac_i ;
	reg [24:0] b_add_mux ;
	wire [24:0] b_mac_o_mux ;
	wire [24:0] b_mac_o_out ;
	wire [24:0] b_add_o ;
		
	wire b_signedx;
	wire b_signedy;
	wire b_signedz;
	
	wire b_sload_i;
	wire b_acc_en_i; 
    reg  b_dinz_en_i;
    wire  b_dinz_en_reg;
    reg  b_dinz_en_reg_asyn;
    reg  b_dinz_en_reg_syn;
	
	wire b_xreg = (bdinx_input_mode == "register") || (bdinx_input_mode == 1); 
	wire b_yreg = (bdiny_input_mode == "register") || (bdiny_input_mode == 1); 
	wire b_zreg = (bdinz_input_mode == "register") || (bdinz_input_mode == 1); 
	wire b_macreg = (bmac_output_mode == "register") || (bmac_output_mode == 1); 
		
	//18x18 mac
	wire [17:0] x_in ;
	wire [17:0] y_in ;
	wire [47:0] z_in;
	
	wire [17:0] qx_o_mux ;
	
	wire [17:0] qy_o_mux ;
	
	wire [47:0] qz_o_mux ;
	
	wire [47:0] mult_o ;
	wire [47:0]  qmac_o_reg_asyn;
	wire [47:0]  qmac_o_reg_syn;
	wire [47:0] qmac_o_reg;
	wire [47:0] qmac_i;
	reg [47:0] add_mux ;
	wire [47:0] mac_o_mux ;
	wire [47:0] add_o ;
		
	wire signedx;
	wire signedy;
	wire signedz;
	
	wire sload_i;
	wire acc_en_i, dinz_en_i;
	
	wire xreg =   (adinx_input_mode == "register") || (adinx_input_mode == 1); 
	wire yreg =   (adiny_input_mode == "register") || (adiny_input_mode == 1); 
	wire zreg =   (adinz_input_mode == "register") || (adinz_input_mode == 1); 
	wire macreg = (amac_output_mode == "register") || (amac_output_mode == 1); 
	
	assign signedx = b_signedx;
	assign signedy = b_signedy;
	//assign signedz = b_z_in[19 ];
	assign signedz = b_qz_o_mux[23];
	
	assign sload_i = a_sload_i;
	assign acc_en_i = a_acc_en_i;
	assign dinz_en_i = a_dinz_en_i;
	
	buf b_clk (clk_in, clk);
		  
	//buf b_a_signedx	(a_signedx, a_dinx[13]);
	//buf b_a_signedy	(a_signedy, a_diny[9]);
	//buf b_a_signedz	(a_signedz, a_dinz[20]);
    assign a_signedx = a_qx_o_mux[12];
    assign a_signedy = a_qy_o_mux[9];
    assign a_signedz = a_qz_o_mux[24];
	   
	buf b_a_x_in_0 	(a_x_in[0 ], a_dinx[0 ]);
	buf b_a_x_in_1 	(a_x_in[1 ], a_dinx[1 ]);
	buf b_a_x_in_2 	(a_x_in[2 ], a_dinx[2 ]);
	buf b_a_x_in_3 	(a_x_in[3 ], a_dinx[3 ]);
	buf b_a_x_in_4 	(a_x_in[4 ], a_dinx[4 ]);
	buf b_a_x_in_5 	(a_x_in[5 ], a_dinx[5 ]);
	buf b_a_x_in_6 	(a_x_in[6 ], a_dinx[6 ]);
	buf b_a_x_in_7 	(a_x_in[7 ], a_dinx[7 ]);
	buf b_a_x_in_8 	(a_x_in[8 ], a_dinx[8 ]);
	buf b_a_x_in_9 	(a_x_in[9 ], a_dinx[9 ]);
	buf b_a_x_in_10 (a_x_in[10], a_dinx[10]);
	buf b_a_x_in_11 (a_x_in[11], a_dinx[11]);	
	buf b_a_x_in_12 (a_x_in[12], a_dinx[12]);	
	    
	buf b_a_y_in_0 	(a_y_in[0 ], a_diny[0 ]);
	buf b_a_y_in_1 	(a_y_in[1 ], a_diny[1 ]);
	buf b_a_y_in_2 	(a_y_in[2 ], a_diny[2 ]);
	buf b_a_y_in_3 	(a_y_in[3 ], a_diny[3 ]);
	buf b_a_y_in_4 	(a_y_in[4 ], a_diny[4 ]);
	buf b_a_y_in_5 	(a_y_in[5 ], a_diny[5 ]);
	buf b_a_y_in_6 	(a_y_in[6 ], a_diny[6 ]);
	buf b_a_y_in_7 	(a_y_in[7 ], a_diny[7 ]);
	buf b_a_y_in_8 	(a_y_in[8 ], a_diny[8 ]);
	buf b_a_y_in_9 	(a_y_in[9 ], a_diny[9 ]);
	   
	buf b_a_z_in_0 	(a_z_in[0  ], a_dinz[0 ]);
	buf b_a_z_in_1 	(a_z_in[1  ], a_dinz[1 ]);
	buf b_a_z_in_2 	(a_z_in[2  ], a_dinz[2 ]);
	buf b_a_z_in_3 	(a_z_in[3  ], a_dinz[3 ]);
	buf b_a_z_in_4 	(a_z_in[4  ], a_dinz[4 ]);
	buf b_a_z_in_5 	(a_z_in[5  ], a_dinz[5 ]);
	buf b_a_z_in_6 	(a_z_in[6  ], a_dinz[6 ]);
	buf b_a_z_in_7 	(a_z_in[7  ], a_dinz[7 ]);
	buf b_a_z_in_8 	(a_z_in[8  ], a_dinz[8 ]);
	buf b_a_z_in_9 	(a_z_in[9  ], a_dinz[9 ]);
	buf b_a_z_in_10 (a_z_in[10 ], a_dinz[10]);
	buf b_a_z_in_11 (a_z_in[11 ], a_dinz[11]);	
	buf b_a_z_in_12 (a_z_in[12 ], a_dinz[12]);
	buf b_a_z_in_13 (a_z_in[13 ], a_dinz[13]);
	buf b_a_z_in_14 (a_z_in[14 ], a_dinz[14]);
	buf b_a_z_in_15 (a_z_in[15 ], a_dinz[15]);
	buf b_a_z_in_16 (a_z_in[16 ], a_dinz[16]);
	buf b_a_z_in_17 (a_z_in[17 ], a_dinz[17]);
	buf b_a_z_in_18 (a_z_in[18 ], a_dinz[18]);
	buf b_a_z_in_19 (a_z_in[19 ], a_dinz[19]);
	buf b_a_z_in_20 (a_z_in[20 ], a_dinz[20]);
	buf b_a_z_in_21 (a_z_in[21 ], a_dinz[21]);
	buf b_a_z_in_22 (a_z_in[22 ], a_dinz[22]);
	buf b_a_z_in_23 (a_z_in[23 ], a_dinz[23]);
	buf b_a_z_in_24 (a_z_in[24 ], a_dinz[24]);
	
	//buf b_b_signedx (b_signedx, b_dinx[13]);
	//buf b_b_signedy (b_signedy, b_diny[9]);
	//buf b_b_signedz (b_signedz, b_dinz[20]);
    assign b_signedx = b_qx_o_mux[12];
    assign b_signedy = b_qy_o_mux[9];
    assign b_signedz = b_qz_o_mux[24];
	    
	buf b_b_x_in_0 	(b_x_in[0 ], b_dinx[0 ]);
	buf b_b_x_in_1 	(b_x_in[1 ], b_dinx[1 ]);
	buf b_b_x_in_2 	(b_x_in[2 ], b_dinx[2 ]);
	buf b_b_x_in_3 	(b_x_in[3 ], b_dinx[3 ]);
	buf b_b_x_in_4 	(b_x_in[4 ], b_dinx[4 ]);
	buf b_b_x_in_5 	(b_x_in[5 ], b_dinx[5 ]);
	buf b_b_x_in_6 	(b_x_in[6 ], b_dinx[6 ]);
	buf b_b_x_in_7 	(b_x_in[7 ], b_dinx[7 ]);
	buf b_b_x_in_8 	(b_x_in[8 ], b_dinx[8 ]);
	buf b_b_x_in_9 	(b_x_in[9 ], b_dinx[9 ]);
	buf b_b_x_in_10 (b_x_in[10], b_dinx[10]);
	buf b_b_x_in_11 (b_x_in[11], b_dinx[11]);	
	buf b_b_x_in_12 (b_x_in[12], b_dinx[12]);	
	  
	buf b_b_y_in_0 	(b_y_in[0 ], b_diny[0 ]);
	buf b_b_y_in_1 	(b_y_in[1 ], b_diny[1 ]);
	buf b_b_y_in_2 	(b_y_in[2 ], b_diny[2 ]);
	buf b_b_y_in_3 	(b_y_in[3 ], b_diny[3 ]);
	buf b_b_y_in_4 	(b_y_in[4 ], b_diny[4 ]);
	buf b_b_y_in_5 	(b_y_in[5 ], b_diny[5 ]);
	buf b_b_y_in_6 	(b_y_in[6 ], b_diny[6 ]);
	buf b_b_y_in_7 	(b_y_in[7 ], b_diny[7 ]);
	buf b_b_y_in_8 	(b_y_in[8 ], b_diny[8 ]);
	buf b_b_y_in_9 	(b_y_in[9 ], b_diny[9 ]);
	 
	buf b_b_z_in_0 	(b_z_in[0  ], b_dinz[0 ]);
	buf b_b_z_in_1 	(b_z_in[1  ], b_dinz[1 ]);
	buf b_b_z_in_2 	(b_z_in[2  ], b_dinz[2 ]);
	buf b_b_z_in_3 	(b_z_in[3  ], b_dinz[3 ]);
	buf b_b_z_in_4 	(b_z_in[4  ], b_dinz[4 ]);
	buf b_b_z_in_5 	(b_z_in[5  ], b_dinz[5 ]);
	buf b_b_z_in_6 	(b_z_in[6  ], b_dinz[6 ]);
	buf b_b_z_in_7 	(b_z_in[7  ], b_dinz[7 ]);
	buf b_b_z_in_8 	(b_z_in[8  ], b_dinz[8 ]);
	buf b_b_z_in_9 	(b_z_in[9  ], b_dinz[9 ]);
	buf b_b_z_in_10 (b_z_in[10 ], b_dinz[10]);
	buf b_b_z_in_11 (b_z_in[11 ], b_dinz[11]);	
	buf b_b_z_in_12 (b_z_in[12 ], b_dinz[12]);
	buf b_b_z_in_13 (b_z_in[13 ], b_dinz[13]);
	buf b_b_z_in_14 (b_z_in[14 ], b_dinz[14]);
	buf b_b_z_in_15 (b_z_in[15 ], b_dinz[15]);
	buf b_b_z_in_16 (b_z_in[16 ], b_dinz[16]);
	buf b_b_z_in_17 (b_z_in[17 ], b_dinz[17]);
	buf b_b_z_in_18 (b_z_in[18 ], b_dinz[18]);
	buf b_b_z_in_19 (b_z_in[19 ], b_dinz[19]);
	buf b_b_z_in_20 (b_z_in[20 ], b_dinz[20]);
	buf b_b_z_in_21 (b_z_in[21 ], b_dinz[21]);
	buf b_b_z_in_22 (b_z_in[22 ], b_dinz[22]);
	buf b_b_z_in_23 (b_z_in[23 ], b_dinz[23]);
	buf b_b_z_in_24 (b_z_in[24 ], b_dinz[24]);
	
	buf b_a_mac_out0  (a_mac_out[0  ], a_mac_o_out[0 ]);
	buf b_a_mac_out1  (a_mac_out[1  ], a_mac_o_out[1 ]);
	buf b_a_mac_out2  (a_mac_out[2  ], a_mac_o_out[2 ]);
	buf b_a_mac_out3  (a_mac_out[3  ], a_mac_o_out[3 ]);
	buf b_a_mac_out4  (a_mac_out[4  ], a_mac_o_out[4 ]);
	buf b_a_mac_out5  (a_mac_out[5  ], a_mac_o_out[5 ]);
	buf b_a_mac_out6  (a_mac_out[6  ], a_mac_o_out[6 ]);
	buf b_a_mac_out7  (a_mac_out[7  ], a_mac_o_out[7 ]);
	buf b_a_mac_out8  (a_mac_out[8  ], a_mac_o_out[8 ]);
	buf b_a_mac_out9  (a_mac_out[9  ], a_mac_o_out[9 ]);
	buf b_a_mac_out10 (a_mac_out[10 ], a_mac_o_out[10]);
	buf b_a_mac_out11 (a_mac_out[11 ], a_mac_o_out[11]);
	buf b_a_mac_out12 (a_mac_out[12 ], a_mac_o_out[12]);
	buf b_a_mac_out13 (a_mac_out[13 ], a_mac_o_out[13]);
	buf b_a_mac_out14 (a_mac_out[14 ], a_mac_o_out[14]);
	buf b_a_mac_out15 (a_mac_out[15 ], a_mac_o_out[15]);
	buf b_a_mac_out16 (a_mac_out[16 ], a_mac_o_out[16]);
	buf b_a_mac_out17 (a_mac_out[17 ], a_mac_o_out[17]);
	buf b_a_mac_out18 (a_mac_out[18 ], a_mac_o_out[18]);
	buf b_a_mac_out19 (a_mac_out[19 ], a_mac_o_out[19]);
	buf b_a_mac_out20 (a_mac_out[20 ], a_mac_o_out[20]);
	buf b_a_mac_out21 (a_mac_out[21 ], a_mac_o_out[21]);
	buf b_a_mac_out22 (a_mac_out[22 ], a_mac_o_out[22]);
	buf b_a_mac_out23 (a_mac_out[23 ], a_mac_o_out[23]);
	buf b_a_mac_out24 (a_mac_out[24 ], a_mac_o_out[24]);
	
	buf b_b_mac_out0  (b_mac_out[0  ], b_mac_o_out[0 ]);
	buf b_b_mac_out1  (b_mac_out[1  ], b_mac_o_out[1 ]);
	buf b_b_mac_out2  (b_mac_out[2  ], b_mac_o_out[2 ]);
	buf b_b_mac_out3  (b_mac_out[3  ], b_mac_o_out[3 ]);
	buf b_b_mac_out4  (b_mac_out[4  ], b_mac_o_out[4 ]);
	buf b_b_mac_out5  (b_mac_out[5  ], b_mac_o_out[5 ]);
	buf b_b_mac_out6  (b_mac_out[6  ], b_mac_o_out[6 ]);
	buf b_b_mac_out7  (b_mac_out[7  ], b_mac_o_out[7 ]);
	buf b_b_mac_out8  (b_mac_out[8  ], b_mac_o_out[8 ]);
	buf b_b_mac_out9  (b_mac_out[9  ], b_mac_o_out[9 ]);
	buf b_b_mac_out10 (b_mac_out[10 ], b_mac_o_out[10]);
	buf b_b_mac_out11 (b_mac_out[11 ], b_mac_o_out[11]);
	buf b_b_mac_out12 (b_mac_out[12 ], b_mac_o_out[12]);
	buf b_b_mac_out13 (b_mac_out[13 ], b_mac_o_out[13]);
	buf b_b_mac_out14 (b_mac_out[14 ], b_mac_o_out[14]);
	buf b_b_mac_out15 (b_mac_out[15 ], b_mac_o_out[15]);
	buf b_b_mac_out16 (b_mac_out[16 ], b_mac_o_out[16]);
	buf b_b_mac_out17 (b_mac_out[17 ], b_mac_o_out[17]);
	buf b_b_mac_out18 (b_mac_out[18 ], b_mac_o_out[18]);
	buf b_b_mac_out19 (b_mac_out[19 ], b_mac_o_out[19]);
	buf b_b_mac_out20 (b_mac_out[20 ], b_mac_o_out[20]);
	buf b_b_mac_out21 (b_mac_out[21 ], b_mac_o_out[21]);
	buf b_b_mac_out22 (b_mac_out[22 ], b_mac_o_out[22]);
	buf b_b_mac_out23 (b_mac_out[23 ], b_mac_o_out[23]);
	buf b_b_mac_out24 (b_mac_out[24 ], b_mac_o_out[24]);
	
	buf b_a_sload (a_sload_i, a_sload);
	buf b_a_acc_en (a_acc_en_i, a_acc_en);
	//buf b_a_dinz_en (a_dinz_en_i, a_dinz_en);
	
	buf b_b_sload   (b_sload_i,   b_sload);
	buf b_b_acc_en  (b_acc_en_i,  b_acc_en);
	//buf b_b_dinz_en (b_dinz_en_i, b_dinz_en);	   
    
	//*** Input a register x with 1 level deep of register

	always @(posedge clk_in or negedge a_in_rstn or negedge a_in_setn) begin
		if (!a_in_rstn)
			a_qx_o_reg_asyn <= 13'b0;
		else if(!a_in_setn)
			a_qx_o_reg_asyn <= 13'h1FFF;
		else if(a_dinxy_cen)
			a_qx_o_reg_asyn <= a_x_in;
	end

	always @(posedge clk_in) begin
		if (!a_in_rstn)
			a_qx_o_reg_syn <= 13'b0;
		else if(!a_in_setn)
			a_qx_o_reg_syn <= 13'h1FFF;
		else if(a_dinxy_cen)
			a_qx_o_reg_syn <= a_x_in;
	end
	assign a_qx_o_reg = a_sr_syn_sel == 1'b1 ? a_qx_o_reg_syn : a_qx_o_reg_asyn ;

	always @(a_x_in or a_qx_o_reg or a_xreg) begin
		case (a_xreg)
  	                0 : a_qx_o_mux <= a_x_in;
  	                1 : a_qx_o_mux <= a_qx_o_reg;
		endcase
	end

	//*** Input a register y with 1 level deep of registers
	always @(posedge clk_in or negedge a_in_rstn or negedge a_in_setn) begin
		if (!a_in_rstn)
			a_qy_o_reg_asyn <= 10'b0;
		else if(!a_in_setn)
			a_qy_o_reg_asyn <= 10'h3FF;
		else if(a_dinxy_cen)
			a_qy_o_reg_asyn <= a_y_in;
	end

	always @(posedge clk_in) begin
		if (!a_in_rstn)
			a_qy_o_reg_syn <= 10'b0;
		else if(!a_in_setn)
			a_qy_o_reg_syn <= 10'h3FF;
		else if(a_dinxy_cen)
			a_qy_o_reg_syn <= a_y_in;
	end
	assign a_qy_o_reg = a_sr_syn_sel == 1'b1 ? a_qy_o_reg_syn : a_qy_o_reg_asyn;

	always @(a_y_in or a_qy_o_reg or a_yreg) begin
		case (a_yreg)
  	                0 : a_qy_o_mux <= a_y_in;
  	                1 : a_qy_o_mux <= a_qy_o_reg;
		endcase
	end

	//*** Input a register z with 1 level deep of registers

	always @(posedge clk_in or negedge a_in_rstn or negedge a_in_setn) begin
		if (!a_in_rstn)
			a_qz_o_reg_asyn <= 25'b0;
		else if(!a_in_setn)
			a_qz_o_reg_asyn <= 25'h1FF_FFFF;
		else if(a_dinz_cen)
			a_qz_o_reg_asyn <= a_z_in;
	end

	always @(posedge clk_in) begin
		if (!a_in_rstn)
			a_qz_o_reg_syn <= 25'b0;
		else if(!a_in_setn)
			a_qz_o_reg_syn <= 25'h1FF_FFFF;
		else if(a_dinz_cen)
			a_qz_o_reg_syn <= a_z_in;
	end
	assign a_qz_o_reg = a_sr_syn_sel == 1'b1 ? a_qz_o_reg_syn : a_qz_o_reg_asyn ;

	always @(a_z_in or a_qz_o_reg or a_zreg) begin
		case (a_zreg)
  	                0 : a_qz_o_mux <= a_z_in;
  	                1 : a_qz_o_mux <= a_qz_o_reg;
		endcase
	end


	always @(posedge clk_in or negedge a_in_rstn) begin
		if (!a_in_rstn)
			a_dinz_en_reg_asyn <= 1'b0;
		else 
			a_dinz_en_reg_asyn <= a_dinz_en;
	end

	always @(posedge clk_in) begin
		if (!a_in_rstn)
			a_dinz_en_reg_syn <= 1'b0;
		else 
			a_dinz_en_reg_syn <= a_dinz_en;
	end
	assign a_dinz_en_reg = a_sr_syn_sel == 1'b1 ? a_dinz_en_reg_syn : a_dinz_en_reg_asyn ;

	always @(a_dinz_en or a_dinz_en_reg or a_zreg) begin
		case (a_zreg)
  	                0 : a_dinz_en_i <= a_dinz_en;
  	                1 : a_dinz_en_i <= a_dinz_en_reg;
		endcase
	end

	/*mac a	*/	
	//*** 12x9 Multiplier
	assign a_mult_o = (modea_sel == "12x9" || modea_sel == 3'b010)?{{12{a_signedx}}, a_qx_o_mux} * {{15{a_signedy}}, a_qy_o_mux}:0;

	//*** 25+25 adder
	assign a_add_o = (modea_sel == "12x9" || modea_sel == 3'b010)?((a_sload_i==1)?a_add_mux:(a_mult_o + a_add_mux)):0;

	//*** generate a_overflow
	assign a_overflow_tmp = (~(a_mult_o[24] ^ a_add_mux[24])) && (a_add_o[24] ^ a_add_mux[24]);

	always @(posedge clk_in or negedge a_ovf_rstn) begin
		if (!a_ovf_rstn)
  	          mac_a_overflow_d_asyn <= 1'b0;
		else if(a_mac_out_cen & mac_a_overflow_d_asyn)
  	          mac_a_overflow_d_asyn <= 1'b1;
		else if(a_mac_out_cen == 1'b0)
			  mac_a_overflow_d_asyn <= mac_a_overflow_d_asyn ;
		else
			  mac_a_overflow_d_asyn <= a_overflow_tmp ;
	end

	always @(posedge clk_in) begin
		if (!a_ovf_rstn)
  	          mac_a_overflow_d_syn <= 1'b0;
		else if(a_mac_out_cen & mac_a_overflow_d_syn)
  	          mac_a_overflow_d_syn <= 1'b1;
		else if(a_mac_out_cen == 1'b0)
			  mac_a_overflow_d_syn <= mac_a_overflow_d_syn ;	  
		else
			  mac_a_overflow_d_syn <= a_overflow_tmp ;
	end
	assign mac_a_overflow_d = a_sr_syn_sel == 1 ? mac_a_overflow_d_syn :  mac_a_overflow_d_asyn;

	always @(posedge clk_in or negedge a_out_sr) begin
		if (!a_out_sr)
  	          mac_a_overflow_temp_asyn <= 1'b0;
		else if(a_overflow_tmp)
  	          mac_a_overflow_temp_asyn <= 1'b1;
	end
	assign mac_a_overflow_or = mac_a_overflow_temp_asyn | a_overflow_tmp ;


    assign mac_a_overflow = a_macreg ? mac_a_overflow_d : mac_a_overflow_or;
    

	//*** adder/acc with 1 level of register
	mac_dff_sync dff_sync_a_0 (   .q(a_qmac_o_reg_syn[0]),.clk(clk_in),.d(a_qmac_i[0]),.rstn(a_6_out_rstn), .setn(a_6_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_a_1 (   .q(a_qmac_o_reg_syn[1]),.clk(clk_in),.d(a_qmac_i[1]),.rstn(a_7_out_rstn), .setn(a_7_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_a_2 (   .q(a_qmac_o_reg_syn[2]),.clk(clk_in),.d(a_qmac_i[2]),.rstn(a_8_out_rstn), .setn(a_8_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_a_3 (   .q(a_qmac_o_reg_syn[3]),.clk(clk_in),.d(a_qmac_i[3]),.rstn(a_9_out_rstn), .setn(a_9_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_a_4 (   .q(a_qmac_o_reg_syn[4]),.clk(clk_in),.d(a_qmac_i[4]),.rstn(a_10_out_rstn),.setn(a_10_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_a_5 (   .q(a_qmac_o_reg_syn[5]),.clk(clk_in),.d(a_qmac_i[5]),.rstn(a_11_out_rstn),.setn(a_11_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_a_6 (   .q(a_qmac_o_reg_syn[6]),.clk(clk_in),.d(a_qmac_i[6]),.rstn(a_12_out_rstn),.setn(a_12_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_a_7 (   .q(a_qmac_o_reg_syn[7]),.clk(clk_in),.d(a_qmac_i[7]),.rstn(a_13_out_rstn),.setn(a_13_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_a_8 (   .q(a_qmac_o_reg_syn[8]),.clk(clk_in),.d(a_qmac_i[8]),.rstn(a_14_out_rstn),.setn(a_14_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_a_9 (   .q(a_qmac_o_reg_syn[9]),.clk(clk_in),.d(a_qmac_i[9]),.rstn(a_15_out_rstn),.setn(a_15_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_a_10 (.q(a_qmac_o_reg_syn[10]),.clk(clk_in),.d(a_qmac_i[10]),.rstn(a_16_out_rstn),.setn(a_16_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_a_11 (.q(a_qmac_o_reg_syn[11]),.clk(clk_in),.d(a_qmac_i[11]),.rstn(a_17_out_rstn),.setn(a_17_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_a_12 (.q(a_qmac_o_reg_syn[12]),.clk(clk_in),.d(a_qmac_i[12]),.rstn(a_18_out_rstn),.setn(a_18_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_a_13 (.q(a_qmac_o_reg_syn[13]),.clk(clk_in),.d(a_qmac_i[13]),.rstn(a_19_out_rstn),.setn(a_19_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_a_14 (.q(a_qmac_o_reg_syn[14]),.clk(clk_in),.d(a_qmac_i[14]),.rstn(a_20_out_rstn),.setn(a_20_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_a_15 (.q(a_qmac_o_reg_syn[15]),.clk(clk_in),.d(a_qmac_i[15]),.rstn(a_21_out_rstn),.setn(a_21_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_a_16 (.q(a_qmac_o_reg_syn[16]),.clk(clk_in),.d(a_qmac_i[16]),.rstn(a_22_out_rstn),.setn(a_22_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_a_17 (.q(a_qmac_o_reg_syn[17]),.clk(clk_in),.d(a_qmac_i[17]),.rstn(a_23_out_rstn),.setn(a_23_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_a_18 (.q(a_qmac_o_reg_syn[18]),.clk(clk_in),.d(a_qmac_i[18]),.rstn(a_24_out_rstn),.setn(a_24_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_a_19 (.q(a_qmac_o_reg_syn[19]),.clk(clk_in),.d(a_qmac_i[19]),.rstn(a_25_out_rstn),.setn(a_25_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_a_20 (.q(a_qmac_o_reg_syn[20]),.clk(clk_in),.d(a_qmac_i[20]),.rstn(a_26_out_rstn),.setn(a_26_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_a_21 (.q(a_qmac_o_reg_syn[21]),.clk(clk_in),.d(a_qmac_i[21]),.rstn(a_27_out_rstn),.setn(a_27_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_a_22 (.q(a_qmac_o_reg_syn[22]),.clk(clk_in),.d(a_qmac_i[22]),.rstn(a_28_out_rstn),.setn(a_28_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_a_23 (.q(a_qmac_o_reg_syn[23]),.clk(clk_in),.d(a_qmac_i[23]),.rstn(a_29_out_rstn),.setn(a_29_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_a_24 (.q(a_qmac_o_reg_syn[24]),.clk(clk_in),.d(a_qmac_i[24]),.rstn(a_30_out_rstn),.setn(a_30_out_setn),.cen(a_mac_out_cen));

	mac_dff_async dff_async_a_0 (   .q(a_qmac_o_reg_asyn[0]),.clk(clk_in),.d(a_qmac_i[0]),.rstn(a_6_out_rstn), .setn(a_6_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_a_1 (   .q(a_qmac_o_reg_asyn[1]),.clk(clk_in),.d(a_qmac_i[1]),.rstn(a_7_out_rstn), .setn(a_7_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_a_2 (   .q(a_qmac_o_reg_asyn[2]),.clk(clk_in),.d(a_qmac_i[2]),.rstn(a_8_out_rstn), .setn(a_8_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_a_3 (   .q(a_qmac_o_reg_asyn[3]),.clk(clk_in),.d(a_qmac_i[3]),.rstn(a_9_out_rstn), .setn(a_9_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_a_4 (   .q(a_qmac_o_reg_asyn[4]),.clk(clk_in),.d(a_qmac_i[4]),.rstn(a_10_out_rstn),.setn(a_10_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_a_5 (   .q(a_qmac_o_reg_asyn[5]),.clk(clk_in),.d(a_qmac_i[5]),.rstn(a_11_out_rstn),.setn(a_11_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_a_6 (   .q(a_qmac_o_reg_asyn[6]),.clk(clk_in),.d(a_qmac_i[6]),.rstn(a_12_out_rstn),.setn(a_12_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_a_7 (   .q(a_qmac_o_reg_asyn[7]),.clk(clk_in),.d(a_qmac_i[7]),.rstn(a_13_out_rstn),.setn(a_13_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_a_8 (   .q(a_qmac_o_reg_asyn[8]),.clk(clk_in),.d(a_qmac_i[8]),.rstn(a_14_out_rstn),.setn(a_14_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_a_9 (   .q(a_qmac_o_reg_asyn[9]),.clk(clk_in),.d(a_qmac_i[9]),.rstn(a_15_out_rstn),.setn(a_15_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_a_10 (.q(a_qmac_o_reg_asyn[10]),.clk(clk_in),.d(a_qmac_i[10]),.rstn(a_16_out_rstn),.setn(a_16_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_a_11 (.q(a_qmac_o_reg_asyn[11]),.clk(clk_in),.d(a_qmac_i[11]),.rstn(a_17_out_rstn),.setn(a_17_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_a_12 (.q(a_qmac_o_reg_asyn[12]),.clk(clk_in),.d(a_qmac_i[12]),.rstn(a_18_out_rstn),.setn(a_18_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_a_13 (.q(a_qmac_o_reg_asyn[13]),.clk(clk_in),.d(a_qmac_i[13]),.rstn(a_19_out_rstn),.setn(a_19_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_a_14 (.q(a_qmac_o_reg_asyn[14]),.clk(clk_in),.d(a_qmac_i[14]),.rstn(a_20_out_rstn),.setn(a_20_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_a_15 (.q(a_qmac_o_reg_asyn[15]),.clk(clk_in),.d(a_qmac_i[15]),.rstn(a_21_out_rstn),.setn(a_21_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_a_16 (.q(a_qmac_o_reg_asyn[16]),.clk(clk_in),.d(a_qmac_i[16]),.rstn(a_22_out_rstn),.setn(a_22_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_a_17 (.q(a_qmac_o_reg_asyn[17]),.clk(clk_in),.d(a_qmac_i[17]),.rstn(a_23_out_rstn),.setn(a_23_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_a_18 (.q(a_qmac_o_reg_asyn[18]),.clk(clk_in),.d(a_qmac_i[18]),.rstn(a_24_out_rstn),.setn(a_24_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_a_19 (.q(a_qmac_o_reg_asyn[19]),.clk(clk_in),.d(a_qmac_i[19]),.rstn(a_25_out_rstn),.setn(a_25_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_a_20 (.q(a_qmac_o_reg_asyn[20]),.clk(clk_in),.d(a_qmac_i[20]),.rstn(a_26_out_rstn),.setn(a_26_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_a_21 (.q(a_qmac_o_reg_asyn[21]),.clk(clk_in),.d(a_qmac_i[21]),.rstn(a_27_out_rstn),.setn(a_27_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_a_22 (.q(a_qmac_o_reg_asyn[22]),.clk(clk_in),.d(a_qmac_i[22]),.rstn(a_28_out_rstn),.setn(a_28_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_a_23 (.q(a_qmac_o_reg_asyn[23]),.clk(clk_in),.d(a_qmac_i[23]),.rstn(a_29_out_rstn),.setn(a_29_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_a_24 (.q(a_qmac_o_reg_asyn[24]),.clk(clk_in),.d(a_qmac_i[24]),.rstn(a_30_out_rstn),.setn(a_30_out_setn),.cen(a_mac_out_cen));

	assign a_qmac_i = a_add_o ;
	assign a_qmac_o_reg = a_sr_syn_sel == 1 ? a_qmac_o_reg_syn :  a_qmac_o_reg_asyn ;
	always @(a_acc_en_i or a_dinz_en_i or a_qz_o_mux or a_qmac_o_reg or a_sload_i) begin
		if(a_sload_i == 1'b1)
			a_add_mux = a_qz_o_mux ;
		else if(a_acc_en_i == 1'b1)
			a_add_mux = a_qmac_o_reg ;
		else if(a_dinz_en_i == 1'b1)
			a_add_mux = a_qz_o_mux ;
		else
			a_add_mux = 25'b0;
	end

	
	//*** a mac output
	assign a_mac_o_mux = (modea_sel == "12x9" || modea_sel == 3'b010)?a_macreg?a_qmac_o_reg:a_add_o:0;	

	/*mac a	*/	
	
	//*** Input b register x with 1 level deep of register

	always @(posedge clk_in or negedge b_in_rstn or negedge b_in_setn) begin
		if (!b_in_rstn)
			b_qx_o_reg_asyn <= 13'b0;
		else if(!b_in_setn)
			b_qx_o_reg_asyn <= 13'h1FFF;
		else if(b_dinxy_cen)
			b_qx_o_reg_asyn <= b_x_in;
	end

	always @(posedge clk_in) begin
		if (!b_in_rstn)
			b_qx_o_reg_syn <= 13'b0;
		else if(!b_in_setn)
			b_qx_o_reg_syn <= 13'h1FFF;
		else if(b_dinxy_cen)
			b_qx_o_reg_syn <= b_x_in;
	end
	assign b_qx_o_reg = b_sr_syn_sel == 1 ? b_qx_o_reg_syn : b_qx_o_reg_asyn ;

	always @(b_x_in or b_qx_o_reg or b_xreg) begin
		case (b_xreg)
  	                0 : b_qx_o_mux <= b_x_in;
  	                1 : b_qx_o_mux <= b_qx_o_reg;
		endcase
	end

	//*** Input b register y with 1 level deep of registers

	always @(posedge clk_in or negedge b_in_rstn or negedge b_in_setn) begin
		if (!b_in_rstn)
			b_qy_o_reg_asyn <= 10'b0;
		else if(!b_in_setn)
			b_qy_o_reg_asyn <= 10'h3FF;
		else if(b_dinxy_cen)
			b_qy_o_reg_asyn <= b_y_in;
	end

	always @(posedge clk_in) begin
		if (!b_in_rstn)
			b_qy_o_reg_syn <= 10'b0;
		else if(!b_in_setn)
			b_qy_o_reg_syn <= 10'h3FF;
		else if(b_dinxy_cen)
			b_qy_o_reg_syn <= b_y_in;
	end
	assign b_qy_o_reg = b_sr_syn_sel == 1 ? b_qy_o_reg_syn : b_qy_o_reg_asyn ;
	always @(b_y_in or b_qy_o_reg or b_yreg) begin
		case (b_yreg)
  	                0 : b_qy_o_mux <= b_y_in;
  	                1 : b_qy_o_mux <= b_qy_o_reg;
		endcase
	end

	//*** Input b register z with 1 level deep of registers

	always @(posedge clk_in or negedge b_in_rstn or negedge b_in_setn) begin
		if (!b_in_rstn)
			b_qz_o_reg_asyn <= 25'b0;
		else if(!b_in_setn)
			b_qz_o_reg_asyn <= 25'h1FF_FFFF;
		else if(b_dinz_cen)
			b_qz_o_reg_asyn <= b_z_in;
	end

	always @(posedge clk_in) begin
		if (!b_in_rstn)
			b_qz_o_reg_syn <= 25'b0;
		else if(!b_in_setn)
			b_qz_o_reg_syn <= 25'h1FF_FFFF;
		else if(b_dinz_cen)
			b_qz_o_reg_syn <= b_z_in;
	end
	assign b_qz_o_reg = b_sr_syn_sel == 1 ? b_qz_o_reg_syn : b_qz_o_reg_asyn ;

	always @(b_z_in or b_qz_o_reg or b_zreg) begin
		case (b_zreg)
  	                0 : b_qz_o_mux <= b_z_in;
  	                1 : b_qz_o_mux <= b_qz_o_reg;
		endcase
	end


	always @(posedge clk_in or negedge b_in_rstn) begin
		if (!b_in_rstn)
			b_dinz_en_reg_asyn <= 1'b0;
		else 
			b_dinz_en_reg_asyn <= b_dinz_en;
	end

	always @(posedge clk_in) begin
		if (!b_in_rstn)
			b_dinz_en_reg_syn <= 1'b0;
		else 
			b_dinz_en_reg_syn <= b_dinz_en;
	end
	assign b_dinz_en_reg = b_sr_syn_sel == 1 ? b_dinz_en_reg_syn : b_dinz_en_reg_asyn ;

	always @(b_dinz_en or b_dinz_en_reg or b_zreg) begin
		case (b_zreg)
  	                0 : b_dinz_en_i <= b_dinz_en;
  	                1 : b_dinz_en_i <= b_dinz_en_reg;
		endcase
	end


	/*mac b	*/	
	//*** 12x9 Multiplier
	assign b_mult_o = (modeb_sel == "12x9" || modeb_sel == 3'b010)?{{12{b_signedx}}, b_qx_o_mux} * {{15{b_signedy}}, b_qy_o_mux}:0;

	//*** 25+25 adder
	assign b_add_o = (modeb_sel == "12x9" || modeb_sel == 3'b010)?((b_sload_i == 1)?b_add_mux:(b_mult_o + b_add_mux)):0;

	//*** generate b_overflow
	assign b_overflow_tmp = (~(b_mult_o[24] ^ b_add_mux[24])) && (b_add_o[24] ^ b_add_mux[24]);

	always @(posedge clk_in or negedge b_ovf_rstn) begin
		if (!b_ovf_rstn)
  	          mac_b_overflow_d_asyn <= 1'b0;
		else if(b_mac_out_cen & mac_b_overflow_d_asyn)
  	          mac_b_overflow_d_asyn <= 1'b1;
		else if(b_mac_out_cen == 1'b0)	  
			  mac_b_overflow_d_asyn <= mac_b_overflow_d_asyn ;
		else
			  mac_b_overflow_d_asyn <= b_overflow_tmp ;
	end

	always @(posedge clk_in) begin
		if (!b_ovf_rstn)
  	          mac_b_overflow_d_syn <= 1'b0;
		else if(b_mac_out_cen & mac_b_overflow_d_syn)
  	          mac_b_overflow_d_syn <= 1'b1;
		else if(b_mac_out_cen == 1'b0)	  
			  mac_b_overflow_d_syn <= mac_b_overflow_d_syn ;
		else
			  mac_b_overflow_d_syn <= b_overflow_tmp ;
	end
	assign mac_b_overflow_d = b_sr_syn_sel == 1 ? mac_b_overflow_d_syn : mac_b_overflow_d_asyn ;
	
	always @(posedge clk_in or negedge b_out_sr) begin
		if (!b_out_sr)
  	          mac_b_overflow_temp_asyn <= 1'b0;
		else if(b_overflow_tmp)
  	          mac_b_overflow_temp_asyn <= 1'b1;
	end
	assign mac_b_overflow_or = mac_b_overflow_temp_asyn | b_overflow_tmp ;

    assign b_overflow = b_macreg ? mac_b_overflow_d : mac_b_overflow_or;


	//*** adder/acc with 1 level of register
	mac_dff_sync dff_sync_b_0 (.q(b_qmac_o_reg_syn[0]),.clk(clk_in),.d(b_qmac_i[0]),.rstn(b_0_out_rstn),.setn(b_0_out_setn),.cen(b_mac_out_cen));
	mac_dff_sync dff_sync_b_1 (.q(b_qmac_o_reg_syn[1]),.clk(clk_in),.d(b_qmac_i[1]),.rstn(b_1_out_rstn),.setn(b_1_out_setn),.cen(b_mac_out_cen));
	mac_dff_sync dff_sync_b_2 (.q(b_qmac_o_reg_syn[2]),.clk(clk_in),.d(b_qmac_i[2]),.rstn(b_2_out_rstn),.setn(b_2_out_setn),.cen(b_mac_out_cen));
	mac_dff_sync dff_sync_b_3 (.q(b_qmac_o_reg_syn[3]),.clk(clk_in),.d(b_qmac_i[3]),.rstn(b_3_out_rstn),.setn(b_3_out_setn),.cen(b_mac_out_cen));
	mac_dff_sync dff_sync_b_4 (.q(b_qmac_o_reg_syn[4]),.clk(clk_in),.d(b_qmac_i[4]),.rstn(b_4_out_rstn),.setn(b_4_out_setn),.cen(b_mac_out_cen));
	mac_dff_sync dff_sync_b_5 (.q(b_qmac_o_reg_syn[5]),.clk(clk_in),.d(b_qmac_i[5]),.rstn(b_5_out_rstn),.setn(b_5_out_setn),.cen(b_mac_out_cen));
	mac_dff_sync dff_sync_b_6 (.q(b_qmac_o_reg_syn[6]),.clk(clk_in),.d(b_qmac_i[6]),.rstn(b_6_out_rstn),.setn(b_6_out_setn),.cen(b_mac_out_cen));
	mac_dff_sync dff_sync_b_7 (.q(b_qmac_o_reg_syn[7]),.clk(clk_in),.d(b_qmac_i[7]),.rstn(b_7_out_rstn),.setn(b_7_out_setn),.cen(b_mac_out_cen));
	mac_dff_sync dff_sync_b_8 (.q(b_qmac_o_reg_syn[8]),.clk(clk_in),.d(b_qmac_i[8]),.rstn(b_8_out_rstn),.setn(b_8_out_setn),.cen(b_mac_out_cen));
	mac_dff_sync dff_sync_b_9 (.q(b_qmac_o_reg_syn[9]),.clk(clk_in),.d(b_qmac_i[9]),.rstn(b_9_out_rstn),.setn(b_9_out_setn),.cen(b_mac_out_cen));
	mac_dff_sync dff_sync_b_10 (.q(b_qmac_o_reg_syn[10]),.clk(clk_in),.d(b_qmac_i[10]),.rstn(b_10_out_rstn),.setn(b_10_out_setn),.cen(b_mac_out_cen));
	mac_dff_sync dff_sync_b_11 (.q(b_qmac_o_reg_syn[11]),.clk(clk_in),.d(b_qmac_i[11]),.rstn(b_11_out_rstn),.setn(b_11_out_setn),.cen(b_mac_out_cen));
	mac_dff_sync dff_sync_b_12 (.q(b_qmac_o_reg_syn[12]),.clk(clk_in),.d(b_qmac_i[12]),.rstn(b_12_out_rstn),.setn(b_12_out_setn),.cen(b_mac_out_cen));
	mac_dff_sync dff_sync_b_13 (.q(b_qmac_o_reg_syn[13]),.clk(clk_in),.d(b_qmac_i[13]),.rstn(b_13_out_rstn),.setn(b_13_out_setn),.cen(b_mac_out_cen));
	mac_dff_sync dff_sync_b_14 (.q(b_qmac_o_reg_syn[14]),.clk(clk_in),.d(b_qmac_i[14]),.rstn(b_14_out_rstn),.setn(b_14_out_setn),.cen(b_mac_out_cen));
	mac_dff_sync dff_sync_b_15 (.q(b_qmac_o_reg_syn[15]),.clk(clk_in),.d(b_qmac_i[15]),.rstn(b_15_out_rstn),.setn(b_15_out_setn),.cen(b_mac_out_cen));
	mac_dff_sync dff_sync_b_16 (.q(b_qmac_o_reg_syn[16]),.clk(clk_in),.d(b_qmac_i[16]),.rstn(b_16_out_rstn),.setn(b_16_out_setn),.cen(b_mac_out_cen));
	mac_dff_sync dff_sync_b_17 (.q(b_qmac_o_reg_syn[17]),.clk(clk_in),.d(b_qmac_i[17]),.rstn(b_17_out_rstn),.setn(b_17_out_setn),.cen(b_mac_out_cen));
	mac_dff_sync dff_sync_b_18 (.q(b_qmac_o_reg_syn[18]),.clk(clk_in),.d(b_qmac_i[18]),.rstn(b_18_out_rstn),.setn(b_18_out_setn),.cen(b_mac_out_cen));
	mac_dff_sync dff_sync_b_19 (.q(b_qmac_o_reg_syn[19]),.clk(clk_in),.d(b_qmac_i[19]),.rstn(b_19_out_rstn),.setn(b_19_out_setn),.cen(b_mac_out_cen));
	mac_dff_sync dff_sync_b_20 (.q(b_qmac_o_reg_syn[20]),.clk(clk_in),.d(b_qmac_i[20]),.rstn(b_20_out_rstn),.setn(b_20_out_setn),.cen(b_mac_out_cen));
	mac_dff_sync dff_sync_b_21 (.q(b_qmac_o_reg_syn[21]),.clk(clk_in),.d(b_qmac_i[21]),.rstn(b_21_out_rstn),.setn(b_21_out_setn),.cen(b_mac_out_cen));
	mac_dff_sync dff_sync_b_22 (.q(b_qmac_o_reg_syn[22]),.clk(clk_in),.d(b_qmac_i[22]),.rstn(b_22_out_rstn),.setn(b_22_out_setn),.cen(b_mac_out_cen));
	mac_dff_sync dff_sync_b_23 (.q(b_qmac_o_reg_syn[23]),.clk(clk_in),.d(b_qmac_i[23]),.rstn(b_23_out_rstn),.setn(b_23_out_setn),.cen(b_mac_out_cen));
	mac_dff_sync dff_sync_b_24 (.q(b_qmac_o_reg_syn[24]),.clk(clk_in),.d(b_qmac_i[24]),.rstn(b_24_out_rstn),.setn(b_24_out_setn),.cen(b_mac_out_cen));

	mac_dff_async dff_async_b_0 (.q(b_qmac_o_reg_asyn[0]),.clk(clk_in),.d(b_qmac_i[0]),.rstn(b_0_out_rstn),.setn(b_0_out_setn),.cen(b_mac_out_cen));
	mac_dff_async dff_async_b_1 (.q(b_qmac_o_reg_asyn[1]),.clk(clk_in),.d(b_qmac_i[1]),.rstn(b_1_out_rstn),.setn(b_1_out_setn),.cen(b_mac_out_cen));
	mac_dff_async dff_async_b_2 (.q(b_qmac_o_reg_asyn[2]),.clk(clk_in),.d(b_qmac_i[2]),.rstn(b_2_out_rstn),.setn(b_2_out_setn),.cen(b_mac_out_cen));
	mac_dff_async dff_async_b_3 (.q(b_qmac_o_reg_asyn[3]),.clk(clk_in),.d(b_qmac_i[3]),.rstn(b_3_out_rstn),.setn(b_3_out_setn),.cen(b_mac_out_cen));
	mac_dff_async dff_async_b_4 (.q(b_qmac_o_reg_asyn[4]),.clk(clk_in),.d(b_qmac_i[4]),.rstn(b_4_out_rstn),.setn(b_4_out_setn),.cen(b_mac_out_cen));
	mac_dff_async dff_async_b_5 (.q(b_qmac_o_reg_asyn[5]),.clk(clk_in),.d(b_qmac_i[5]),.rstn(b_5_out_rstn),.setn(b_5_out_setn),.cen(b_mac_out_cen));
	mac_dff_async dff_async_b_6 (.q(b_qmac_o_reg_asyn[6]),.clk(clk_in),.d(b_qmac_i[6]),.rstn(b_6_out_rstn),.setn(b_6_out_setn),.cen(b_mac_out_cen));
	mac_dff_async dff_async_b_7 (.q(b_qmac_o_reg_asyn[7]),.clk(clk_in),.d(b_qmac_i[7]),.rstn(b_7_out_rstn),.setn(b_7_out_setn),.cen(b_mac_out_cen));
	mac_dff_async dff_async_b_8 (.q(b_qmac_o_reg_asyn[8]),.clk(clk_in),.d(b_qmac_i[8]),.rstn(b_8_out_rstn),.setn(b_8_out_setn),.cen(b_mac_out_cen));
	mac_dff_async dff_async_b_9 (.q(b_qmac_o_reg_asyn[9]),.clk(clk_in),.d(b_qmac_i[9]),.rstn(b_9_out_rstn),.setn(b_9_out_setn),.cen(b_mac_out_cen));
	mac_dff_async dff_async_b_10 (.q(b_qmac_o_reg_asyn[10]),.clk(clk_in),.d(b_qmac_i[10]),.rstn(b_10_out_rstn),.setn(b_10_out_setn),.cen(b_mac_out_cen));
	mac_dff_async dff_async_b_11 (.q(b_qmac_o_reg_asyn[11]),.clk(clk_in),.d(b_qmac_i[11]),.rstn(b_11_out_rstn),.setn(b_11_out_setn),.cen(b_mac_out_cen));
	mac_dff_async dff_async_b_12 (.q(b_qmac_o_reg_asyn[12]),.clk(clk_in),.d(b_qmac_i[12]),.rstn(b_12_out_rstn),.setn(b_12_out_setn),.cen(b_mac_out_cen));
	mac_dff_async dff_async_b_13 (.q(b_qmac_o_reg_asyn[13]),.clk(clk_in),.d(b_qmac_i[13]),.rstn(b_13_out_rstn),.setn(b_13_out_setn),.cen(b_mac_out_cen));
	mac_dff_async dff_async_b_14 (.q(b_qmac_o_reg_asyn[14]),.clk(clk_in),.d(b_qmac_i[14]),.rstn(b_14_out_rstn),.setn(b_14_out_setn),.cen(b_mac_out_cen));
	mac_dff_async dff_async_b_15 (.q(b_qmac_o_reg_asyn[15]),.clk(clk_in),.d(b_qmac_i[15]),.rstn(b_15_out_rstn),.setn(b_15_out_setn),.cen(b_mac_out_cen));
	mac_dff_async dff_async_b_16 (.q(b_qmac_o_reg_asyn[16]),.clk(clk_in),.d(b_qmac_i[16]),.rstn(b_16_out_rstn),.setn(b_16_out_setn),.cen(b_mac_out_cen));
	mac_dff_async dff_async_b_17 (.q(b_qmac_o_reg_asyn[17]),.clk(clk_in),.d(b_qmac_i[17]),.rstn(b_17_out_rstn),.setn(b_17_out_setn),.cen(b_mac_out_cen));
	mac_dff_async dff_async_b_18 (.q(b_qmac_o_reg_asyn[18]),.clk(clk_in),.d(b_qmac_i[18]),.rstn(b_18_out_rstn),.setn(b_18_out_setn),.cen(b_mac_out_cen));
	mac_dff_async dff_async_b_19 (.q(b_qmac_o_reg_asyn[19]),.clk(clk_in),.d(b_qmac_i[19]),.rstn(b_19_out_rstn),.setn(b_19_out_setn),.cen(b_mac_out_cen));
	mac_dff_async dff_async_b_20 (.q(b_qmac_o_reg_asyn[20]),.clk(clk_in),.d(b_qmac_i[20]),.rstn(b_20_out_rstn),.setn(b_20_out_setn),.cen(b_mac_out_cen));
	mac_dff_async dff_async_b_21 (.q(b_qmac_o_reg_asyn[21]),.clk(clk_in),.d(b_qmac_i[21]),.rstn(b_21_out_rstn),.setn(b_21_out_setn),.cen(b_mac_out_cen));
	mac_dff_async dff_async_b_22 (.q(b_qmac_o_reg_asyn[22]),.clk(clk_in),.d(b_qmac_i[22]),.rstn(b_22_out_rstn),.setn(b_22_out_setn),.cen(b_mac_out_cen));
	mac_dff_async dff_async_b_23 (.q(b_qmac_o_reg_asyn[23]),.clk(clk_in),.d(b_qmac_i[23]),.rstn(b_23_out_rstn),.setn(b_23_out_setn),.cen(b_mac_out_cen));
	mac_dff_async dff_async_b_24 (.q(b_qmac_o_reg_asyn[24]),.clk(clk_in),.d(b_qmac_i[24]),.rstn(b_24_out_rstn),.setn(b_24_out_setn),.cen(b_mac_out_cen));


	assign b_qmac_i = b_add_o ;
	assign b_qmac_o_reg =  b_sr_syn_sel == 1 ? b_qmac_o_reg_syn : b_qmac_o_reg_asyn ;
	always @(b_acc_en_i or b_dinz_en_i or b_qz_o_mux or b_qmac_o_reg or b_sload_i) begin
		if(b_sload_i == 1'b1)
			b_add_mux = b_qz_o_mux ;
		else if(b_acc_en_i == 1'b1)
			b_add_mux = b_qmac_o_reg;
		else if(b_dinz_en_i == 1'b1)
			b_add_mux = b_qz_o_mux ;
		else
			b_add_mux <= 25'b0 ;
	end
	
	//*** b mac output
	assign b_mac_o_mux = (modeb_sel == "12x9" || modeb_sel == 3'b010)?b_macreg?b_qmac_o_reg:b_add_o:0;	

	/*mac b	*/	
	
	/*mac 18x18	*/	
	assign qx_o_mux = (modea_sel == "18x18" || modea_sel == 3'b001)?{b_qx_o_mux[12:0],a_qx_o_mux[5:0]}:19'b0;
	assign qy_o_mux = (modea_sel == "18x18" || modea_sel == 3'b001)?{b_qy_o_mux[9:0],a_qy_o_mux[8:0]}:19'b0;
	assign qz_o_mux = (modea_sel == "18x18" || modea_sel == 3'b001)?{b_qz_o_mux[23:0],a_qz_o_mux[23:0]}:48'b0;
	//*** 18x18 Multiplier
	assign mult_o = (modea_sel == "18x18" || modea_sel == 3'b001)?{{30{signedx}}, qx_o_mux} * {{30{signedy}}, qy_o_mux}:48'b0;

	//*** 48+48 adder
	assign add_o = (modea_sel == "18x18" || modea_sel == 3'b001)?((sload_i == 1)?add_mux:(mult_o + add_mux)):0;

	//*** generate mac_overflow for 18x18
	assign mac_overflow_tmp = (~(mult_o[47] ^ add_mux[47])) && (add_o[47] ^ add_mux[47]);

	always @(posedge clk_in or negedge a_ovf_rstn) begin
		if (!a_ovf_rstn)
  	          mac_overflow_d_asyn <= 1'b0;
		else if(a_mac_out_cen & mac_overflow_d_asyn)
  	          mac_overflow_d_asyn <= 1'b1;
		else if(a_mac_out_cen == 1'b0)
			  mac_overflow_d_asyn <= mac_overflow_d_asyn ;
		else
			  mac_overflow_d_asyn <= mac_overflow_tmp ;
	end

	always @(posedge clk_in) begin
		if (!a_ovf_rstn)
  	          mac_overflow_d_syn <= 1'b0;
		else if(a_mac_out_cen & mac_overflow_d_syn)
  	          mac_overflow_d_syn <= 1'b1;
		else if(a_mac_out_cen == 1'b0)
			  mac_overflow_d_syn <= mac_overflow_d_syn ;	  
		else
			  mac_overflow_d_syn <= mac_overflow_tmp ;
	end
	assign mac_overflow_d = a_sr_syn_sel == 1 ? mac_overflow_d_syn : mac_overflow_d_asyn ;

	always @(posedge clk_in or negedge a_out_sr) begin
		if (!a_out_sr)
  	          mac_overflow_temp_asyn <= 1'b0;
		else if(mac_overflow_tmp)
  	          mac_overflow_temp_asyn <= 1'b1;
	end
	assign mac_overflow_or =  mac_overflow_temp_asyn | mac_overflow_tmp ;

    assign mac_overflow = a_macreg ? mac_overflow_d : mac_overflow_or;

	//*** adder/acc with 1 level of register
	assign qmac_i = add_o ;
	mac_dff_sync dff_sync_ab_0 (.q(qmac_o_reg_syn[0]),.clk(clk_in),.d(qmac_i[0]),.rstn(a_0_out_rstn),.setn(a_0_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_1 (.q(qmac_o_reg_syn[1]),.clk(clk_in),.d(qmac_i[1]),.rstn(a_1_out_rstn),.setn(a_1_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_2 (.q(qmac_o_reg_syn[2]),.clk(clk_in),.d(qmac_i[2]),.rstn(a_2_out_rstn),.setn(a_2_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_3 (.q(qmac_o_reg_syn[3]),.clk(clk_in),.d(qmac_i[3]),.rstn(a_3_out_rstn),.setn(a_3_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_4 (.q(qmac_o_reg_syn[4]),.clk(clk_in),.d(qmac_i[4]),.rstn(a_4_out_rstn),.setn(a_4_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_5 (.q(qmac_o_reg_syn[5]),.clk(clk_in),.d(qmac_i[5]),.rstn(a_5_out_rstn),.setn(a_5_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_6 (.q(qmac_o_reg_syn[6]),.clk(clk_in),.d(qmac_i[6]),.rstn(a_6_out_rstn),.setn(a_6_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_7 (.q(qmac_o_reg_syn[7]),.clk(clk_in),.d(qmac_i[7]),.rstn(a_7_out_rstn),.setn(a_7_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_8 (.q(qmac_o_reg_syn[8]),.clk(clk_in),.d(qmac_i[8]),.rstn(a_8_out_rstn),.setn(a_8_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_9 (.q(qmac_o_reg_syn[9]),.clk(clk_in),.d(qmac_i[9]),.rstn(a_9_out_rstn),.setn(a_9_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_10 (.q(qmac_o_reg_syn[10]),.clk(clk_in),.d(qmac_i[10]),.rstn(a_10_out_rstn),.setn(a_10_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_11 (.q(qmac_o_reg_syn[11]),.clk(clk_in),.d(qmac_i[11]),.rstn(a_11_out_rstn),.setn(a_11_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_12 (.q(qmac_o_reg_syn[12]),.clk(clk_in),.d(qmac_i[12]),.rstn(a_12_out_rstn),.setn(a_12_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_13 (.q(qmac_o_reg_syn[13]),.clk(clk_in),.d(qmac_i[13]),.rstn(a_13_out_rstn),.setn(a_13_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_14 (.q(qmac_o_reg_syn[14]),.clk(clk_in),.d(qmac_i[14]),.rstn(a_14_out_rstn),.setn(a_14_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_15 (.q(qmac_o_reg_syn[15]),.clk(clk_in),.d(qmac_i[15]),.rstn(a_15_out_rstn),.setn(a_15_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_16 (.q(qmac_o_reg_syn[16]),.clk(clk_in),.d(qmac_i[16]),.rstn(a_16_out_rstn),.setn(a_16_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_17 (.q(qmac_o_reg_syn[17]),.clk(clk_in),.d(qmac_i[17]),.rstn(a_17_out_rstn),.setn(a_17_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_18 (.q(qmac_o_reg_syn[18]),.clk(clk_in),.d(qmac_i[18]),.rstn(a_18_out_rstn),.setn(a_18_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_19 (.q(qmac_o_reg_syn[19]),.clk(clk_in),.d(qmac_i[19]),.rstn(a_19_out_rstn),.setn(a_19_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_20 (.q(qmac_o_reg_syn[20]),.clk(clk_in),.d(qmac_i[20]),.rstn(a_20_out_rstn),.setn(a_20_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_21 (.q(qmac_o_reg_syn[21]),.clk(clk_in),.d(qmac_i[21]),.rstn(a_21_out_rstn),.setn(a_21_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_22 (.q(qmac_o_reg_syn[22]),.clk(clk_in),.d(qmac_i[22]),.rstn(a_22_out_rstn),.setn(a_22_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_23 (.q(qmac_o_reg_syn[23]),.clk(clk_in),.d(qmac_i[23]),.rstn(a_23_out_rstn),.setn(a_23_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_24 (.q(qmac_o_reg_syn[24]),.clk(clk_in),.d(qmac_i[24]),.rstn(a_24_out_rstn),.setn(a_24_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_25 (.q(qmac_o_reg_syn[25]),.clk(clk_in),.d(qmac_i[25]),.rstn(a_25_out_rstn),.setn(a_25_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_26 (.q(qmac_o_reg_syn[26]),.clk(clk_in),.d(qmac_i[26]),.rstn(a_26_out_rstn),.setn(a_26_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_27 (.q(qmac_o_reg_syn[27]),.clk(clk_in),.d(qmac_i[27]),.rstn(a_27_out_rstn),.setn(a_27_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_28 (.q(qmac_o_reg_syn[28]),.clk(clk_in),.d(qmac_i[28]),.rstn(a_28_out_rstn),.setn(a_28_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_29 (.q(qmac_o_reg_syn[29]),.clk(clk_in),.d(qmac_i[29]),.rstn(a_29_out_rstn),.setn(a_29_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_30 (.q(qmac_o_reg_syn[30]),.clk(clk_in),.d(qmac_i[30]),.rstn(a_30_out_rstn),.setn(a_30_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_31 (.q(qmac_o_reg_syn[31]),.clk(clk_in),.d(qmac_i[31]),.rstn(a_31_out_rstn),.setn(a_31_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_32 (.q(qmac_o_reg_syn[32]),.clk(clk_in),.d(qmac_i[32]),.rstn(a_32_out_rstn),.setn(a_32_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_33 (.q(qmac_o_reg_syn[33]),.clk(clk_in),.d(qmac_i[33]),.rstn(a_33_out_rstn),.setn(a_33_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_34 (.q(qmac_o_reg_syn[34]),.clk(clk_in),.d(qmac_i[34]),.rstn(a_34_out_rstn),.setn(a_34_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_35 (.q(qmac_o_reg_syn[35]),.clk(clk_in),.d(qmac_i[35]),.rstn(a_35_out_rstn),.setn(a_35_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_36 (.q(qmac_o_reg_syn[36]),.clk(clk_in),.d(qmac_i[36]),.rstn(a_36_out_rstn),.setn(a_36_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_37 (.q(qmac_o_reg_syn[37]),.clk(clk_in),.d(qmac_i[37]),.rstn(a_37_out_rstn),.setn(a_37_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_38 (.q(qmac_o_reg_syn[38]),.clk(clk_in),.d(qmac_i[38]),.rstn(a_38_out_rstn),.setn(a_38_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_39 (.q(qmac_o_reg_syn[39]),.clk(clk_in),.d(qmac_i[39]),.rstn(a_39_out_rstn),.setn(a_39_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_40 (.q(qmac_o_reg_syn[40]),.clk(clk_in),.d(qmac_i[40]),.rstn(a_40_out_rstn),.setn(a_40_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_41 (.q(qmac_o_reg_syn[41]),.clk(clk_in),.d(qmac_i[41]),.rstn(a_41_out_rstn),.setn(a_41_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_42 (.q(qmac_o_reg_syn[42]),.clk(clk_in),.d(qmac_i[42]),.rstn(a_42_out_rstn),.setn(a_42_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_43 (.q(qmac_o_reg_syn[43]),.clk(clk_in),.d(qmac_i[43]),.rstn(a_43_out_rstn),.setn(a_43_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_44 (.q(qmac_o_reg_syn[44]),.clk(clk_in),.d(qmac_i[44]),.rstn(a_44_out_rstn),.setn(a_44_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_45 (.q(qmac_o_reg_syn[45]),.clk(clk_in),.d(qmac_i[45]),.rstn(a_45_out_rstn),.setn(a_45_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_46 (.q(qmac_o_reg_syn[46]),.clk(clk_in),.d(qmac_i[46]),.rstn(a_46_out_rstn),.setn(a_46_out_setn),.cen(a_mac_out_cen));
	mac_dff_sync dff_sync_ab_47 (.q(qmac_o_reg_syn[47]),.clk(clk_in),.d(qmac_i[47]),.rstn(a_47_out_rstn),.setn(a_47_out_setn),.cen(a_mac_out_cen));

	mac_dff_async dff_async_ab_0 (.q(qmac_o_reg_asyn[0]),.clk(clk_in),.d(qmac_i[0]),.rstn(a_0_out_rstn),.setn(a_0_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_1 (.q(qmac_o_reg_asyn[1]),.clk(clk_in),.d(qmac_i[1]),.rstn(a_1_out_rstn),.setn(a_1_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_2 (.q(qmac_o_reg_asyn[2]),.clk(clk_in),.d(qmac_i[2]),.rstn(a_2_out_rstn),.setn(a_2_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_3 (.q(qmac_o_reg_asyn[3]),.clk(clk_in),.d(qmac_i[3]),.rstn(a_3_out_rstn),.setn(a_3_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_4 (.q(qmac_o_reg_asyn[4]),.clk(clk_in),.d(qmac_i[4]),.rstn(a_4_out_rstn),.setn(a_4_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_5 (.q(qmac_o_reg_asyn[5]),.clk(clk_in),.d(qmac_i[5]),.rstn(a_5_out_rstn),.setn(a_5_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_6 (.q(qmac_o_reg_asyn[6]),.clk(clk_in),.d(qmac_i[6]),.rstn(a_6_out_rstn),.setn(a_6_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_7 (.q(qmac_o_reg_asyn[7]),.clk(clk_in),.d(qmac_i[7]),.rstn(a_7_out_rstn),.setn(a_7_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_8 (.q(qmac_o_reg_asyn[8]),.clk(clk_in),.d(qmac_i[8]),.rstn(a_8_out_rstn),.setn(a_8_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_9 (.q(qmac_o_reg_asyn[9]),.clk(clk_in),.d(qmac_i[9]),.rstn(a_9_out_rstn),.setn(a_9_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_10 (.q(qmac_o_reg_asyn[10]),.clk(clk_in),.d(qmac_i[10]),.rstn(a_10_out_rstn),.setn(a_10_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_11 (.q(qmac_o_reg_asyn[11]),.clk(clk_in),.d(qmac_i[11]),.rstn(a_11_out_rstn),.setn(a_11_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_12 (.q(qmac_o_reg_asyn[12]),.clk(clk_in),.d(qmac_i[12]),.rstn(a_12_out_rstn),.setn(a_12_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_13 (.q(qmac_o_reg_asyn[13]),.clk(clk_in),.d(qmac_i[13]),.rstn(a_13_out_rstn),.setn(a_13_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_14 (.q(qmac_o_reg_asyn[14]),.clk(clk_in),.d(qmac_i[14]),.rstn(a_14_out_rstn),.setn(a_14_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_15 (.q(qmac_o_reg_asyn[15]),.clk(clk_in),.d(qmac_i[15]),.rstn(a_15_out_rstn),.setn(a_15_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_16 (.q(qmac_o_reg_asyn[16]),.clk(clk_in),.d(qmac_i[16]),.rstn(a_16_out_rstn),.setn(a_16_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_17 (.q(qmac_o_reg_asyn[17]),.clk(clk_in),.d(qmac_i[17]),.rstn(a_17_out_rstn),.setn(a_17_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_18 (.q(qmac_o_reg_asyn[18]),.clk(clk_in),.d(qmac_i[18]),.rstn(a_18_out_rstn),.setn(a_18_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_19 (.q(qmac_o_reg_asyn[19]),.clk(clk_in),.d(qmac_i[19]),.rstn(a_19_out_rstn),.setn(a_19_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_20 (.q(qmac_o_reg_asyn[20]),.clk(clk_in),.d(qmac_i[20]),.rstn(a_20_out_rstn),.setn(a_20_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_21 (.q(qmac_o_reg_asyn[21]),.clk(clk_in),.d(qmac_i[21]),.rstn(a_21_out_rstn),.setn(a_21_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_22 (.q(qmac_o_reg_asyn[22]),.clk(clk_in),.d(qmac_i[22]),.rstn(a_22_out_rstn),.setn(a_22_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_23 (.q(qmac_o_reg_asyn[23]),.clk(clk_in),.d(qmac_i[23]),.rstn(a_23_out_rstn),.setn(a_23_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_24 (.q(qmac_o_reg_asyn[24]),.clk(clk_in),.d(qmac_i[24]),.rstn(a_24_out_rstn),.setn(a_24_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_25 (.q(qmac_o_reg_asyn[25]),.clk(clk_in),.d(qmac_i[25]),.rstn(a_25_out_rstn),.setn(a_25_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_26 (.q(qmac_o_reg_asyn[26]),.clk(clk_in),.d(qmac_i[26]),.rstn(a_26_out_rstn),.setn(a_26_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_27 (.q(qmac_o_reg_asyn[27]),.clk(clk_in),.d(qmac_i[27]),.rstn(a_27_out_rstn),.setn(a_27_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_28 (.q(qmac_o_reg_asyn[28]),.clk(clk_in),.d(qmac_i[28]),.rstn(a_28_out_rstn),.setn(a_28_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_29 (.q(qmac_o_reg_asyn[29]),.clk(clk_in),.d(qmac_i[29]),.rstn(a_29_out_rstn),.setn(a_29_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_30 (.q(qmac_o_reg_asyn[30]),.clk(clk_in),.d(qmac_i[30]),.rstn(a_30_out_rstn),.setn(a_30_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_31 (.q(qmac_o_reg_asyn[31]),.clk(clk_in),.d(qmac_i[31]),.rstn(a_31_out_rstn),.setn(a_31_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_32 (.q(qmac_o_reg_asyn[32]),.clk(clk_in),.d(qmac_i[32]),.rstn(a_32_out_rstn),.setn(a_32_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_33 (.q(qmac_o_reg_asyn[33]),.clk(clk_in),.d(qmac_i[33]),.rstn(a_33_out_rstn),.setn(a_33_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_34 (.q(qmac_o_reg_asyn[34]),.clk(clk_in),.d(qmac_i[34]),.rstn(a_34_out_rstn),.setn(a_34_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_35 (.q(qmac_o_reg_asyn[35]),.clk(clk_in),.d(qmac_i[35]),.rstn(a_35_out_rstn),.setn(a_35_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_36 (.q(qmac_o_reg_asyn[36]),.clk(clk_in),.d(qmac_i[36]),.rstn(a_36_out_rstn),.setn(a_36_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_37 (.q(qmac_o_reg_asyn[37]),.clk(clk_in),.d(qmac_i[37]),.rstn(a_37_out_rstn),.setn(a_37_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_38 (.q(qmac_o_reg_asyn[38]),.clk(clk_in),.d(qmac_i[38]),.rstn(a_38_out_rstn),.setn(a_38_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_39 (.q(qmac_o_reg_asyn[39]),.clk(clk_in),.d(qmac_i[39]),.rstn(a_39_out_rstn),.setn(a_39_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_40 (.q(qmac_o_reg_asyn[40]),.clk(clk_in),.d(qmac_i[40]),.rstn(a_40_out_rstn),.setn(a_40_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_41 (.q(qmac_o_reg_asyn[41]),.clk(clk_in),.d(qmac_i[41]),.rstn(a_41_out_rstn),.setn(a_41_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_42 (.q(qmac_o_reg_asyn[42]),.clk(clk_in),.d(qmac_i[42]),.rstn(a_42_out_rstn),.setn(a_42_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_43 (.q(qmac_o_reg_asyn[43]),.clk(clk_in),.d(qmac_i[43]),.rstn(a_43_out_rstn),.setn(a_43_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_44 (.q(qmac_o_reg_asyn[44]),.clk(clk_in),.d(qmac_i[44]),.rstn(a_44_out_rstn),.setn(a_44_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_45 (.q(qmac_o_reg_asyn[45]),.clk(clk_in),.d(qmac_i[45]),.rstn(a_45_out_rstn),.setn(a_45_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_46 (.q(qmac_o_reg_asyn[46]),.clk(clk_in),.d(qmac_i[46]),.rstn(a_46_out_rstn),.setn(a_46_out_setn),.cen(a_mac_out_cen));
	mac_dff_async dff_async_ab_47 (.q(qmac_o_reg_asyn[47]),.clk(clk_in),.d(qmac_i[47]),.rstn(a_47_out_rstn),.setn(a_47_out_setn),.cen(a_mac_out_cen));

	assign qmac_o_reg = a_sr_syn_sel == 1 ? qmac_o_reg_syn : qmac_o_reg_asyn ;
	//always @(acc_en_i or dinz_en_i or qz_o_mux or qmac_o_reg) begin
	//	case ({acc_en_i,dinz_en_i})
    //              2'b01 : add_mux <= qz_o_mux;
    //              2'b10 : add_mux <= qmac_o_reg;
    //              default:add_mux <= 40'b0;
	//	endcase
	//end
	always @(acc_en_i or dinz_en_i or qz_o_mux or qmac_o_reg or sload_i) begin
		if(sload_i == 1'b1)
			add_mux = qz_o_mux ;
		else if(acc_en_i)
			add_mux = qmac_o_reg ;
		else if(dinz_en_i)
			add_mux = qz_o_mux ;
		else
			add_mux = 48'b0;
	end
	
	//*** mac output
	assign mac_o_mux = (modea_sel == "18x18" || modea_sel == 3'b001)?macreg?qmac_o_reg:add_o:48'b0;	

	/*mac*/		
	assign a_mac_o_out = 	(modea_sel == "18x18" || modea_sel == 3'b001)?mac_o_mux[23:0]:
				(modea_sel == "12x9" || modea_sel == 3'b010)?a_mac_o_mux:0;
	assign b_mac_o_out = 	(modeb_sel == "18x18" || modeb_sel == 3'b001)?mac_o_mux[47:24]:
				(modeb_sel == "12x9" || modeb_sel == 3'b010)?b_mac_o_mux:0;
		
	//*** make mac_a_overflow and mac_overflow together be a_overflow
	assign a_overflow =	(modea_sel == "18x18" || modea_sel == 3'b001)?mac_overflow:
				(modea_sel == "12x9" || modea_sel == 3'b010)?mac_a_overflow:0; 
	specify
	//iopath
(clk          =>   a_mac_out[0]      ) = (0,0);
(clk          =>   a_mac_out[1]      ) = (0,0);
(clk          =>   a_mac_out[2]      ) = (0,0);
(clk          =>   a_mac_out[3]      ) = (0,0);
(clk          =>   a_mac_out[4]      ) = (0,0);
(clk          =>   a_mac_out[5]      ) = (0,0);
(clk          =>   a_mac_out[6]      ) = (0,0);
(clk          =>   a_mac_out[7]      ) = (0,0);
(clk          =>   a_mac_out[8]      ) = (0,0);
(clk          =>   a_mac_out[9]      ) = (0,0);
(clk          =>   a_mac_out[10]     ) = (0,0);
(clk          =>   a_mac_out[11]     ) = (0,0);
(clk          =>   a_mac_out[12]     ) = (0,0);
(clk          =>   a_mac_out[13]     ) = (0,0);
(clk          =>   a_mac_out[14]     ) = (0,0);
(clk          =>   a_mac_out[15]     ) = (0,0);
(clk          =>   a_mac_out[16]     ) = (0,0);
(clk          =>   a_mac_out[17]     ) = (0,0);
(clk          =>   a_mac_out[18]     ) = (0,0);
(clk          =>   a_mac_out[19]     ) = (0,0);
(clk          =>   a_mac_out[20]     ) = (0,0);
(clk          =>   a_mac_out[21]     ) = (0,0);
(clk          =>   a_mac_out[22]     ) = (0,0);
(clk          =>   a_mac_out[23]     ) = (0,0);
(clk          =>   b_mac_out[0]      ) = (0,0);
(clk          =>   b_mac_out[1]      ) = (0,0);
(clk          =>   b_mac_out[2]      ) = (0,0);
(clk          =>   b_mac_out[3]      ) = (0,0);
(clk          =>   b_mac_out[4]      ) = (0,0);
(clk          =>   b_mac_out[5]      ) = (0,0);
(clk          =>   b_mac_out[6]      ) = (0,0);
(clk          =>   b_mac_out[7]      ) = (0,0);
(clk          =>   b_mac_out[8]      ) = (0,0);
(clk          =>   b_mac_out[9]      ) = (0,0);
(clk          =>   b_mac_out[10]     ) = (0,0);
(clk          =>   b_mac_out[11]     ) = (0,0);
(clk          =>   b_mac_out[12]     ) = (0,0);
(clk          =>   b_mac_out[13]     ) = (0,0);
(clk          =>   b_mac_out[14]     ) = (0,0);
(clk          =>   b_mac_out[15]     ) = (0,0);
(clk          =>   b_mac_out[16]     ) = (0,0);
(clk          =>   b_mac_out[17]     ) = (0,0);
(clk          =>   b_mac_out[18]     ) = (0,0);
(clk          =>   b_mac_out[19]     ) = (0,0);
(clk          =>   b_mac_out[20]     ) = (0,0);
(clk          =>   b_mac_out[21]     ) = (0,0);
(clk          =>   b_mac_out[22]     ) = (0,0);
(clk          =>   b_mac_out[23]     ) = (0,0);
(clk          =>   a_overflow        ) = (0,0);
(a_dinx[0]    =>   a_mac_out[0]      ) = (0,0);
(a_dinx[1]    =>   a_mac_out[0]      ) = (0,0);
(a_dinx[2]    =>   a_mac_out[0]      ) = (0,0);
(a_dinx[3]    =>   a_mac_out[0]      ) = (0,0);
(a_dinx[4]    =>   a_mac_out[0]      ) = (0,0);
(a_dinx[5]    =>   a_mac_out[0]      ) = (0,0);
(b_dinx[0]    =>   a_mac_out[0]      ) = (0,0);
(a_diny[0]    =>   a_mac_out[0]      ) = (0,0);
(a_diny[1]    =>   a_mac_out[0]      ) = (0,0);
(a_diny[2]    =>   a_mac_out[0]      ) = (0,0);
(a_diny[3]    =>   a_mac_out[0]      ) = (0,0);
(a_diny[4]    =>   a_mac_out[0]      ) = (0,0);
(a_diny[5]    =>   a_mac_out[0]      ) = (0,0);
(a_diny[6]    =>   a_mac_out[0]      ) = (0,0);
(a_dinz[0]    =>   a_mac_out[0]      ) = (0,0);
(a_dinz[1]    =>   a_mac_out[0]      ) = (0,0);
(a_dinz[2]    =>   a_mac_out[0]      ) = (0,0);
(a_dinz[3]    =>   a_mac_out[0]      ) = (0,0);
(a_dinz[4]    =>   a_mac_out[0]      ) = (0,0);
(a_dinz[5]    =>   a_mac_out[0]      ) = (0,0);
(a_dinz[6]    =>   a_mac_out[0]      ) = (0,0);
(a_dinz_en    =>   a_mac_out[0]      ) = (0,0);
(a_dinx[0]    =>   a_mac_out[1]      ) = (0,0);
(a_dinx[1]    =>   a_mac_out[1]      ) = (0,0);
(a_dinx[2]    =>   a_mac_out[1]      ) = (0,0);
(a_dinx[3]    =>   a_mac_out[1]      ) = (0,0);
(a_dinx[4]    =>   a_mac_out[1]      ) = (0,0);
(a_dinx[5]    =>   a_mac_out[1]      ) = (0,0);
(b_dinx[0]    =>   a_mac_out[1]      ) = (0,0);
(b_dinx[1]    =>   a_mac_out[1]      ) = (0,0);
(a_diny[0]    =>   a_mac_out[1]      ) = (0,0);
(a_diny[1]    =>   a_mac_out[1]      ) = (0,0);
(a_diny[2]    =>   a_mac_out[1]      ) = (0,0);
(a_diny[3]    =>   a_mac_out[1]      ) = (0,0);
(a_diny[4]    =>   a_mac_out[1]      ) = (0,0);
(a_diny[5]    =>   a_mac_out[1]      ) = (0,0);
(a_diny[6]    =>   a_mac_out[1]      ) = (0,0);
(a_diny[7]    =>   a_mac_out[1]      ) = (0,0);
(a_dinz[0]    =>   a_mac_out[1]      ) = (0,0);
(a_dinz[1]    =>   a_mac_out[1]      ) = (0,0);
(a_dinz[2]    =>   a_mac_out[1]      ) = (0,0);
(a_dinz[3]    =>   a_mac_out[1]      ) = (0,0);
(a_dinz[4]    =>   a_mac_out[1]      ) = (0,0);
(a_dinz[5]    =>   a_mac_out[1]      ) = (0,0);
(a_dinz[6]    =>   a_mac_out[1]      ) = (0,0);
(a_dinz[7]    =>   a_mac_out[1]      ) = (0,0);
(a_dinz_en    =>   a_mac_out[1]      ) = (0,0);
(a_dinx[0]    =>   a_mac_out[2]      ) = (0,0);
(a_dinx[1]    =>   a_mac_out[2]      ) = (0,0);
(a_dinx[2]    =>   a_mac_out[2]      ) = (0,0);
(a_dinx[3]    =>   a_mac_out[2]      ) = (0,0);
(a_dinx[4]    =>   a_mac_out[2]      ) = (0,0);
(a_dinx[5]    =>   a_mac_out[2]      ) = (0,0);
(b_dinx[0]    =>   a_mac_out[2]      ) = (0,0);
(b_dinx[1]    =>   a_mac_out[2]      ) = (0,0);
(b_dinx[2]    =>   a_mac_out[2]      ) = (0,0);
(a_diny[0]    =>   a_mac_out[2]      ) = (0,0);
(a_diny[1]    =>   a_mac_out[2]      ) = (0,0);
(a_diny[2]    =>   a_mac_out[2]      ) = (0,0);
(a_diny[3]    =>   a_mac_out[2]      ) = (0,0);
(a_diny[4]    =>   a_mac_out[2]      ) = (0,0);
(a_diny[5]    =>   a_mac_out[2]      ) = (0,0);
(a_diny[6]    =>   a_mac_out[2]      ) = (0,0);
(a_diny[7]    =>   a_mac_out[2]      ) = (0,0);
(a_diny[8]    =>   a_mac_out[2]      ) = (0,0);
(a_dinz[0]    =>   a_mac_out[2]      ) = (0,0);
(a_dinz[1]    =>   a_mac_out[2]      ) = (0,0);
(a_dinz[2]    =>   a_mac_out[2]      ) = (0,0);
(a_dinz[3]    =>   a_mac_out[2]      ) = (0,0);
(a_dinz[4]    =>   a_mac_out[2]      ) = (0,0);
(a_dinz[5]    =>   a_mac_out[2]      ) = (0,0);
(a_dinz[6]    =>   a_mac_out[2]      ) = (0,0);
(a_dinz[7]    =>   a_mac_out[2]      ) = (0,0);
(a_dinz[8]    =>   a_mac_out[2]      ) = (0,0);
(a_dinz_en    =>   a_mac_out[2]      ) = (0,0);
(a_dinx[0]    =>   a_mac_out[3]      ) = (0,0);
(a_dinx[1]    =>   a_mac_out[3]      ) = (0,0);
(a_dinx[2]    =>   a_mac_out[3]      ) = (0,0);
(a_dinx[3]    =>   a_mac_out[3]      ) = (0,0);
(a_dinx[4]    =>   a_mac_out[3]      ) = (0,0);
(a_dinx[5]    =>   a_mac_out[3]      ) = (0,0);
(b_dinx[0]    =>   a_mac_out[3]      ) = (0,0);
(b_dinx[1]    =>   a_mac_out[3]      ) = (0,0);
(b_dinx[2]    =>   a_mac_out[3]      ) = (0,0);
(b_dinx[3]    =>   a_mac_out[3]      ) = (0,0);
(a_diny[0]    =>   a_mac_out[3]      ) = (0,0);
(a_diny[1]    =>   a_mac_out[3]      ) = (0,0);
(a_diny[2]    =>   a_mac_out[3]      ) = (0,0);
(a_diny[3]    =>   a_mac_out[3]      ) = (0,0);
(a_diny[4]    =>   a_mac_out[3]      ) = (0,0);
(a_diny[5]    =>   a_mac_out[3]      ) = (0,0);
(a_diny[6]    =>   a_mac_out[3]      ) = (0,0);
(a_diny[7]    =>   a_mac_out[3]      ) = (0,0);
(a_diny[8]    =>   a_mac_out[3]      ) = (0,0);
(a_diny[9]    =>   a_mac_out[3]      ) = (0,0);
(b_diny[0]    =>   a_mac_out[3]      ) = (0,0);
(a_dinz[0]    =>   a_mac_out[3]      ) = (0,0);
(a_dinz[1]    =>   a_mac_out[3]      ) = (0,0);
(a_dinz[2]    =>   a_mac_out[3]      ) = (0,0);
(a_dinz[3]    =>   a_mac_out[3]      ) = (0,0);
(a_dinz[4]    =>   a_mac_out[3]      ) = (0,0);
(a_dinz[5]    =>   a_mac_out[3]      ) = (0,0);
(a_dinz[6]    =>   a_mac_out[3]      ) = (0,0);
(a_dinz[7]    =>   a_mac_out[3]      ) = (0,0);
(a_dinz[8]    =>   a_mac_out[3]      ) = (0,0);
(a_dinz[9]    =>   a_mac_out[3]      ) = (0,0);
(a_dinz_en    =>   a_mac_out[3]      ) = (0,0);
(a_dinx[0]    =>   a_mac_out[4]      ) = (0,0);
(a_dinx[1]    =>   a_mac_out[4]      ) = (0,0);
(a_dinx[2]    =>   a_mac_out[4]      ) = (0,0);
(a_dinx[3]    =>   a_mac_out[4]      ) = (0,0);
(a_dinx[4]    =>   a_mac_out[4]      ) = (0,0);
(a_dinx[5]    =>   a_mac_out[4]      ) = (0,0);
(b_dinx[0]    =>   a_mac_out[4]      ) = (0,0);
(b_dinx[1]    =>   a_mac_out[4]      ) = (0,0);
(b_dinx[2]    =>   a_mac_out[4]      ) = (0,0);
(b_dinx[3]    =>   a_mac_out[4]      ) = (0,0);
(b_dinx[4]    =>   a_mac_out[4]      ) = (0,0);
(a_diny[0]    =>   a_mac_out[4]      ) = (0,0);
(a_diny[1]    =>   a_mac_out[4]      ) = (0,0);
(a_diny[2]    =>   a_mac_out[4]      ) = (0,0);
(a_diny[3]    =>   a_mac_out[4]      ) = (0,0);
(a_diny[4]    =>   a_mac_out[4]      ) = (0,0);
(a_diny[5]    =>   a_mac_out[4]      ) = (0,0);
(a_diny[6]    =>   a_mac_out[4]      ) = (0,0);
(a_diny[7]    =>   a_mac_out[4]      ) = (0,0);
(a_diny[8]    =>   a_mac_out[4]      ) = (0,0);
(a_diny[9]    =>   a_mac_out[4]      ) = (0,0);
(b_diny[0]    =>   a_mac_out[4]      ) = (0,0);
(b_diny[1]    =>   a_mac_out[4]      ) = (0,0);
(a_dinz[0]    =>   a_mac_out[4]      ) = (0,0);
(a_dinz[1]    =>   a_mac_out[4]      ) = (0,0);
(a_dinz[2]    =>   a_mac_out[4]      ) = (0,0);
(a_dinz[3]    =>   a_mac_out[4]      ) = (0,0);
(a_dinz[4]    =>   a_mac_out[4]      ) = (0,0);
(a_dinz[5]    =>   a_mac_out[4]      ) = (0,0);
(a_dinz[6]    =>   a_mac_out[4]      ) = (0,0);
(a_dinz[7]    =>   a_mac_out[4]      ) = (0,0);
(a_dinz[8]    =>   a_mac_out[4]      ) = (0,0);
(a_dinz[9]    =>   a_mac_out[4]      ) = (0,0);
(a_dinz[10]   =>   a_mac_out[4]      ) = (0,0);
(a_dinz_en    =>   a_mac_out[4]      ) = (0,0);
(a_dinx[0]    =>   a_mac_out[5]      ) = (0,0);
(a_dinx[1]    =>   a_mac_out[5]      ) = (0,0);
(a_dinx[2]    =>   a_mac_out[5]      ) = (0,0);
(a_dinx[3]    =>   a_mac_out[5]      ) = (0,0);
(a_dinx[4]    =>   a_mac_out[5]      ) = (0,0);
(a_dinx[5]    =>   a_mac_out[5]      ) = (0,0);
(b_dinx[0]    =>   a_mac_out[5]      ) = (0,0);
(b_dinx[1]    =>   a_mac_out[5]      ) = (0,0);
(b_dinx[2]    =>   a_mac_out[5]      ) = (0,0);
(b_dinx[3]    =>   a_mac_out[5]      ) = (0,0);
(b_dinx[4]    =>   a_mac_out[5]      ) = (0,0);
(b_dinx[5]    =>   a_mac_out[5]      ) = (0,0);
(a_diny[0]    =>   a_mac_out[5]      ) = (0,0);
(a_diny[1]    =>   a_mac_out[5]      ) = (0,0);
(a_diny[2]    =>   a_mac_out[5]      ) = (0,0);
(a_diny[3]    =>   a_mac_out[5]      ) = (0,0);
(a_diny[4]    =>   a_mac_out[5]      ) = (0,0);
(a_diny[5]    =>   a_mac_out[5]      ) = (0,0);
(a_diny[6]    =>   a_mac_out[5]      ) = (0,0);
(a_diny[7]    =>   a_mac_out[5]      ) = (0,0);
(a_diny[8]    =>   a_mac_out[5]      ) = (0,0);
(a_diny[9]    =>   a_mac_out[5]      ) = (0,0);
(b_diny[0]    =>   a_mac_out[5]      ) = (0,0);
(b_diny[1]    =>   a_mac_out[5]      ) = (0,0);
(b_diny[2]    =>   a_mac_out[5]      ) = (0,0);
(a_dinz[0]    =>   a_mac_out[5]      ) = (0,0);
(a_dinz[1]    =>   a_mac_out[5]      ) = (0,0);
(a_dinz[2]    =>   a_mac_out[5]      ) = (0,0);
(a_dinz[3]    =>   a_mac_out[5]      ) = (0,0);
(a_dinz[4]    =>   a_mac_out[5]      ) = (0,0);
(a_dinz[5]    =>   a_mac_out[5]      ) = (0,0);
(a_dinz[6]    =>   a_mac_out[5]      ) = (0,0);
(a_dinz[7]    =>   a_mac_out[5]      ) = (0,0);
(a_dinz[8]    =>   a_mac_out[5]      ) = (0,0);
(a_dinz[9]    =>   a_mac_out[5]      ) = (0,0);
(a_dinz[10]   =>   a_mac_out[5]      ) = (0,0);
(a_dinz[11]   =>   a_mac_out[5]      ) = (0,0);
(a_dinz_en    =>   a_mac_out[5]      ) = (0,0);
(a_dinx[0]    =>   a_mac_out[6]      ) = (0,0);
(a_dinx[1]    =>   a_mac_out[6]      ) = (0,0);
(a_dinx[2]    =>   a_mac_out[6]      ) = (0,0);
(a_dinx[3]    =>   a_mac_out[6]      ) = (0,0);
(a_dinx[4]    =>   a_mac_out[6]      ) = (0,0);
(a_dinx[5]    =>   a_mac_out[6]      ) = (0,0);
(a_dinx[6]    =>   a_mac_out[6]      ) = (0,0);
(b_dinx[0]    =>   a_mac_out[6]      ) = (0,0);
(b_dinx[1]    =>   a_mac_out[6]      ) = (0,0);
(b_dinx[2]    =>   a_mac_out[6]      ) = (0,0);
(b_dinx[3]    =>   a_mac_out[6]      ) = (0,0);
(b_dinx[4]    =>   a_mac_out[6]      ) = (0,0);
(b_dinx[5]    =>   a_mac_out[6]      ) = (0,0);
(b_dinx[6]    =>   a_mac_out[6]      ) = (0,0);
(a_diny[0]    =>   a_mac_out[6]      ) = (0,0);
(a_diny[1]    =>   a_mac_out[6]      ) = (0,0);
(a_diny[2]    =>   a_mac_out[6]      ) = (0,0);
(a_diny[3]    =>   a_mac_out[6]      ) = (0,0);
(a_diny[4]    =>   a_mac_out[6]      ) = (0,0);
(a_diny[5]    =>   a_mac_out[6]      ) = (0,0);
(a_diny[6]    =>   a_mac_out[6]      ) = (0,0);
(a_diny[7]    =>   a_mac_out[6]      ) = (0,0);
(a_diny[8]    =>   a_mac_out[6]      ) = (0,0);
(a_diny[9]    =>   a_mac_out[6]      ) = (0,0);
(b_diny[0]    =>   a_mac_out[6]      ) = (0,0);
(b_diny[1]    =>   a_mac_out[6]      ) = (0,0);
(b_diny[2]    =>   a_mac_out[6]      ) = (0,0);
(b_diny[3]    =>   a_mac_out[6]      ) = (0,0);
(a_dinz[0]    =>   a_mac_out[6]      ) = (0,0);
(a_dinz[1]    =>   a_mac_out[6]      ) = (0,0);
(a_dinz[2]    =>   a_mac_out[6]      ) = (0,0);
(a_dinz[3]    =>   a_mac_out[6]      ) = (0,0);
(a_dinz[4]    =>   a_mac_out[6]      ) = (0,0);
(a_dinz[5]    =>   a_mac_out[6]      ) = (0,0);
(a_dinz[6]    =>   a_mac_out[6]      ) = (0,0);
(a_dinz[7]    =>   a_mac_out[6]      ) = (0,0);
(a_dinz[8]    =>   a_mac_out[6]      ) = (0,0);
(a_dinz[9]    =>   a_mac_out[6]      ) = (0,0);
(a_dinz[10]   =>   a_mac_out[6]      ) = (0,0);
(a_dinz[11]   =>   a_mac_out[6]      ) = (0,0);
(a_dinz[12]   =>   a_mac_out[6]      ) = (0,0);
(a_dinz_en    =>   a_mac_out[6]      ) = (0,0);
(a_dinx[0]    =>   a_mac_out[7]      ) = (0,0);
(a_dinx[1]    =>   a_mac_out[7]      ) = (0,0);
(a_dinx[2]    =>   a_mac_out[7]      ) = (0,0);
(a_dinx[3]    =>   a_mac_out[7]      ) = (0,0);
(a_dinx[4]    =>   a_mac_out[7]      ) = (0,0);
(a_dinx[5]    =>   a_mac_out[7]      ) = (0,0);
(a_dinx[6]    =>   a_mac_out[7]      ) = (0,0);
(a_dinx[7]    =>   a_mac_out[7]      ) = (0,0);
(b_dinx[0]    =>   a_mac_out[7]      ) = (0,0);
(b_dinx[1]    =>   a_mac_out[7]      ) = (0,0);
(b_dinx[2]    =>   a_mac_out[7]      ) = (0,0);
(b_dinx[3]    =>   a_mac_out[7]      ) = (0,0);
(b_dinx[4]    =>   a_mac_out[7]      ) = (0,0);
(b_dinx[5]    =>   a_mac_out[7]      ) = (0,0);
(b_dinx[6]    =>   a_mac_out[7]      ) = (0,0);
(b_dinx[7]    =>   a_mac_out[7]      ) = (0,0);
(a_diny[0]    =>   a_mac_out[7]      ) = (0,0);
(a_diny[1]    =>   a_mac_out[7]      ) = (0,0);
(a_diny[2]    =>   a_mac_out[7]      ) = (0,0);
(a_diny[3]    =>   a_mac_out[7]      ) = (0,0);
(a_diny[4]    =>   a_mac_out[7]      ) = (0,0);
(a_diny[5]    =>   a_mac_out[7]      ) = (0,0);
(a_diny[6]    =>   a_mac_out[7]      ) = (0,0);
(a_diny[7]    =>   a_mac_out[7]      ) = (0,0);
(a_diny[8]    =>   a_mac_out[7]      ) = (0,0);
(a_diny[9]    =>   a_mac_out[7]      ) = (0,0);
(b_diny[0]    =>   a_mac_out[7]      ) = (0,0);
(b_diny[1]    =>   a_mac_out[7]      ) = (0,0);
(b_diny[2]    =>   a_mac_out[7]      ) = (0,0);
(b_diny[3]    =>   a_mac_out[7]      ) = (0,0);
(b_diny[4]    =>   a_mac_out[7]      ) = (0,0);
(a_dinz[0]    =>   a_mac_out[7]      ) = (0,0);
(a_dinz[1]    =>   a_mac_out[7]      ) = (0,0);
(a_dinz[2]    =>   a_mac_out[7]      ) = (0,0);
(a_dinz[3]    =>   a_mac_out[7]      ) = (0,0);
(a_dinz[4]    =>   a_mac_out[7]      ) = (0,0);
(a_dinz[5]    =>   a_mac_out[7]      ) = (0,0);
(a_dinz[6]    =>   a_mac_out[7]      ) = (0,0);
(a_dinz[7]    =>   a_mac_out[7]      ) = (0,0);
(a_dinz[8]    =>   a_mac_out[7]      ) = (0,0);
(a_dinz[9]    =>   a_mac_out[7]      ) = (0,0);
(a_dinz[10]   =>   a_mac_out[7]      ) = (0,0);
(a_dinz[11]   =>   a_mac_out[7]      ) = (0,0);
(a_dinz[12]   =>   a_mac_out[7]      ) = (0,0);
(a_dinz[13]   =>   a_mac_out[7]      ) = (0,0);
(a_dinz_en    =>   a_mac_out[7]      ) = (0,0);
(a_dinx[0]    =>   a_mac_out[8]      ) = (0,0);
(a_dinx[1]    =>   a_mac_out[8]      ) = (0,0);
(a_dinx[2]    =>   a_mac_out[8]      ) = (0,0);
(a_dinx[3]    =>   a_mac_out[8]      ) = (0,0);
(a_dinx[4]    =>   a_mac_out[8]      ) = (0,0);
(a_dinx[5]    =>   a_mac_out[8]      ) = (0,0);
(a_dinx[6]    =>   a_mac_out[8]      ) = (0,0);
(a_dinx[7]    =>   a_mac_out[8]      ) = (0,0);
(a_dinx[8]    =>   a_mac_out[8]      ) = (0,0);
(b_dinx[0]    =>   a_mac_out[8]      ) = (0,0);
(b_dinx[1]    =>   a_mac_out[8]      ) = (0,0);
(b_dinx[2]    =>   a_mac_out[8]      ) = (0,0);
(b_dinx[3]    =>   a_mac_out[8]      ) = (0,0);
(b_dinx[4]    =>   a_mac_out[8]      ) = (0,0);
(b_dinx[5]    =>   a_mac_out[8]      ) = (0,0);
(b_dinx[6]    =>   a_mac_out[8]      ) = (0,0);
(b_dinx[7]    =>   a_mac_out[8]      ) = (0,0);
(b_dinx[8]    =>   a_mac_out[8]      ) = (0,0);
(a_diny[0]    =>   a_mac_out[8]      ) = (0,0);
(a_diny[1]    =>   a_mac_out[8]      ) = (0,0);
(a_diny[2]    =>   a_mac_out[8]      ) = (0,0);
(a_diny[3]    =>   a_mac_out[8]      ) = (0,0);
(a_diny[4]    =>   a_mac_out[8]      ) = (0,0);
(a_diny[5]    =>   a_mac_out[8]      ) = (0,0);
(a_diny[6]    =>   a_mac_out[8]      ) = (0,0);
(a_diny[7]    =>   a_mac_out[8]      ) = (0,0);
(a_diny[8]    =>   a_mac_out[8]      ) = (0,0);
(a_diny[9]    =>   a_mac_out[8]      ) = (0,0);
(b_diny[0]    =>   a_mac_out[8]      ) = (0,0);
(b_diny[1]    =>   a_mac_out[8]      ) = (0,0);
(b_diny[2]    =>   a_mac_out[8]      ) = (0,0);
(b_diny[3]    =>   a_mac_out[8]      ) = (0,0);
(b_diny[4]    =>   a_mac_out[8]      ) = (0,0);
(b_diny[5]    =>   a_mac_out[8]      ) = (0,0);
(a_dinz[0]    =>   a_mac_out[8]      ) = (0,0);
(a_dinz[1]    =>   a_mac_out[8]      ) = (0,0);
(a_dinz[2]    =>   a_mac_out[8]      ) = (0,0);
(a_dinz[3]    =>   a_mac_out[8]      ) = (0,0);
(a_dinz[4]    =>   a_mac_out[8]      ) = (0,0);
(a_dinz[5]    =>   a_mac_out[8]      ) = (0,0);
(a_dinz[6]    =>   a_mac_out[8]      ) = (0,0);
(a_dinz[7]    =>   a_mac_out[8]      ) = (0,0);
(a_dinz[8]    =>   a_mac_out[8]      ) = (0,0);
(a_dinz[9]    =>   a_mac_out[8]      ) = (0,0);
(a_dinz[10]   =>   a_mac_out[8]      ) = (0,0);
(a_dinz[11]   =>   a_mac_out[8]      ) = (0,0);
(a_dinz[12]   =>   a_mac_out[8]      ) = (0,0);
(a_dinz[13]   =>   a_mac_out[8]      ) = (0,0);
(a_dinz[14]   =>   a_mac_out[8]      ) = (0,0);
(a_dinz_en    =>   a_mac_out[8]      ) = (0,0);
(a_dinx[0]    =>   a_mac_out[9]      ) = (0,0);
(a_dinx[1]    =>   a_mac_out[9]      ) = (0,0);
(a_dinx[2]    =>   a_mac_out[9]      ) = (0,0);
(a_dinx[3]    =>   a_mac_out[9]      ) = (0,0);
(a_dinx[4]    =>   a_mac_out[9]      ) = (0,0);
(a_dinx[5]    =>   a_mac_out[9]      ) = (0,0);
(a_dinx[6]    =>   a_mac_out[9]      ) = (0,0);
(a_dinx[7]    =>   a_mac_out[9]      ) = (0,0);
(a_dinx[8]    =>   a_mac_out[9]      ) = (0,0);
(a_dinx[9]    =>   a_mac_out[9]      ) = (0,0);
(b_dinx[0]    =>   a_mac_out[9]      ) = (0,0);
(b_dinx[1]    =>   a_mac_out[9]      ) = (0,0);
(b_dinx[2]    =>   a_mac_out[9]      ) = (0,0);
(b_dinx[3]    =>   a_mac_out[9]      ) = (0,0);
(b_dinx[4]    =>   a_mac_out[9]      ) = (0,0);
(b_dinx[5]    =>   a_mac_out[9]      ) = (0,0);
(b_dinx[6]    =>   a_mac_out[9]      ) = (0,0);
(b_dinx[7]    =>   a_mac_out[9]      ) = (0,0);
(b_dinx[8]    =>   a_mac_out[9]      ) = (0,0);
(b_dinx[9]    =>   a_mac_out[9]      ) = (0,0);
(a_diny[0]    =>   a_mac_out[9]      ) = (0,0);
(a_diny[1]    =>   a_mac_out[9]      ) = (0,0);
(a_diny[2]    =>   a_mac_out[9]      ) = (0,0);
(a_diny[3]    =>   a_mac_out[9]      ) = (0,0);
(a_diny[4]    =>   a_mac_out[9]      ) = (0,0);
(a_diny[5]    =>   a_mac_out[9]      ) = (0,0);
(a_diny[6]    =>   a_mac_out[9]      ) = (0,0);
(a_diny[7]    =>   a_mac_out[9]      ) = (0,0);
(a_diny[8]    =>   a_mac_out[9]      ) = (0,0);
(a_diny[9]    =>   a_mac_out[9]      ) = (0,0);
(b_diny[0]    =>   a_mac_out[9]      ) = (0,0);
(b_diny[1]    =>   a_mac_out[9]      ) = (0,0);
(b_diny[2]    =>   a_mac_out[9]      ) = (0,0);
(b_diny[3]    =>   a_mac_out[9]      ) = (0,0);
(b_diny[4]    =>   a_mac_out[9]      ) = (0,0);
(b_diny[5]    =>   a_mac_out[9]      ) = (0,0);
(b_diny[6]    =>   a_mac_out[9]      ) = (0,0);
(a_dinz[0]    =>   a_mac_out[9]      ) = (0,0);
(a_dinz[1]    =>   a_mac_out[9]      ) = (0,0);
(a_dinz[2]    =>   a_mac_out[9]      ) = (0,0);
(a_dinz[3]    =>   a_mac_out[9]      ) = (0,0);
(a_dinz[4]    =>   a_mac_out[9]      ) = (0,0);
(a_dinz[5]    =>   a_mac_out[9]      ) = (0,0);
(a_dinz[6]    =>   a_mac_out[9]      ) = (0,0);
(a_dinz[7]    =>   a_mac_out[9]      ) = (0,0);
(a_dinz[8]    =>   a_mac_out[9]      ) = (0,0);
(a_dinz[9]    =>   a_mac_out[9]      ) = (0,0);
(a_dinz[10]   =>   a_mac_out[9]      ) = (0,0);
(a_dinz[11]   =>   a_mac_out[9]      ) = (0,0);
(a_dinz[12]   =>   a_mac_out[9]      ) = (0,0);
(a_dinz[13]   =>   a_mac_out[9]      ) = (0,0);
(a_dinz[14]   =>   a_mac_out[9]      ) = (0,0);
(a_dinz[15]   =>   a_mac_out[9]      ) = (0,0);
(a_dinz_en    =>   a_mac_out[9]      ) = (0,0);
(a_dinx[0]    =>   a_mac_out[10]     ) = (0,0);
(a_dinx[1]    =>   a_mac_out[10]     ) = (0,0);
(a_dinx[2]    =>   a_mac_out[10]     ) = (0,0);
(a_dinx[3]    =>   a_mac_out[10]     ) = (0,0);
(a_dinx[4]    =>   a_mac_out[10]     ) = (0,0);
(a_dinx[5]    =>   a_mac_out[10]     ) = (0,0);
(a_dinx[6]    =>   a_mac_out[10]     ) = (0,0);
(a_dinx[7]    =>   a_mac_out[10]     ) = (0,0);
(a_dinx[8]    =>   a_mac_out[10]     ) = (0,0);
(a_dinx[9]    =>   a_mac_out[10]     ) = (0,0);
(a_dinx[10]   =>   a_mac_out[10]     ) = (0,0);
(b_dinx[0]    =>   a_mac_out[10]     ) = (0,0);
(b_dinx[1]    =>   a_mac_out[10]     ) = (0,0);
(b_dinx[2]    =>   a_mac_out[10]     ) = (0,0);
(b_dinx[3]    =>   a_mac_out[10]     ) = (0,0);
(b_dinx[4]    =>   a_mac_out[10]     ) = (0,0);
(b_dinx[5]    =>   a_mac_out[10]     ) = (0,0);
(b_dinx[6]    =>   a_mac_out[10]     ) = (0,0);
(b_dinx[7]    =>   a_mac_out[10]     ) = (0,0);
(b_dinx[8]    =>   a_mac_out[10]     ) = (0,0);
(b_dinx[9]    =>   a_mac_out[10]     ) = (0,0);
(b_dinx[10]   =>   a_mac_out[10]     ) = (0,0);
(a_diny[0]    =>   a_mac_out[10]     ) = (0,0);
(a_diny[1]    =>   a_mac_out[10]     ) = (0,0);
(a_diny[2]    =>   a_mac_out[10]     ) = (0,0);
(a_diny[3]    =>   a_mac_out[10]     ) = (0,0);
(a_diny[4]    =>   a_mac_out[10]     ) = (0,0);
(a_diny[5]    =>   a_mac_out[10]     ) = (0,0);
(a_diny[6]    =>   a_mac_out[10]     ) = (0,0);
(a_diny[7]    =>   a_mac_out[10]     ) = (0,0);
(a_diny[8]    =>   a_mac_out[10]     ) = (0,0);
(a_diny[9]    =>   a_mac_out[10]     ) = (0,0);
(b_diny[0]    =>   a_mac_out[10]     ) = (0,0);
(b_diny[1]    =>   a_mac_out[10]     ) = (0,0);
(b_diny[2]    =>   a_mac_out[10]     ) = (0,0);
(b_diny[3]    =>   a_mac_out[10]     ) = (0,0);
(b_diny[4]    =>   a_mac_out[10]     ) = (0,0);
(b_diny[5]    =>   a_mac_out[10]     ) = (0,0);
(b_diny[6]    =>   a_mac_out[10]     ) = (0,0);
(b_diny[7]    =>   a_mac_out[10]     ) = (0,0);
(a_dinz[0]    =>   a_mac_out[10]     ) = (0,0);
(a_dinz[1]    =>   a_mac_out[10]     ) = (0,0);
(a_dinz[2]    =>   a_mac_out[10]     ) = (0,0);
(a_dinz[3]    =>   a_mac_out[10]     ) = (0,0);
(a_dinz[4]    =>   a_mac_out[10]     ) = (0,0);
(a_dinz[5]    =>   a_mac_out[10]     ) = (0,0);
(a_dinz[6]    =>   a_mac_out[10]     ) = (0,0);
(a_dinz[7]    =>   a_mac_out[10]     ) = (0,0);
(a_dinz[8]    =>   a_mac_out[10]     ) = (0,0);
(a_dinz[9]    =>   a_mac_out[10]     ) = (0,0);
(a_dinz[10]   =>   a_mac_out[10]     ) = (0,0);
(a_dinz[11]   =>   a_mac_out[10]     ) = (0,0);
(a_dinz[12]   =>   a_mac_out[10]     ) = (0,0);
(a_dinz[13]   =>   a_mac_out[10]     ) = (0,0);
(a_dinz[14]   =>   a_mac_out[10]     ) = (0,0);
(a_dinz[15]   =>   a_mac_out[10]     ) = (0,0);
(a_dinz[16]   =>   a_mac_out[10]     ) = (0,0);
(a_dinz_en    =>   a_mac_out[10]     ) = (0,0);
(a_dinx[0]    =>   a_mac_out[11]     ) = (0,0);
(a_dinx[1]    =>   a_mac_out[11]     ) = (0,0);
(a_dinx[2]    =>   a_mac_out[11]     ) = (0,0);
(a_dinx[3]    =>   a_mac_out[11]     ) = (0,0);
(a_dinx[4]    =>   a_mac_out[11]     ) = (0,0);
(a_dinx[5]    =>   a_mac_out[11]     ) = (0,0);
(a_dinx[6]    =>   a_mac_out[11]     ) = (0,0);
(a_dinx[7]    =>   a_mac_out[11]     ) = (0,0);
(a_dinx[8]    =>   a_mac_out[11]     ) = (0,0);
(a_dinx[9]    =>   a_mac_out[11]     ) = (0,0);
(a_dinx[10]   =>   a_mac_out[11]     ) = (0,0);
(a_dinx[11]   =>   a_mac_out[11]     ) = (0,0);
(b_dinx[0]    =>   a_mac_out[11]     ) = (0,0);
(b_dinx[1]    =>   a_mac_out[11]     ) = (0,0);
(b_dinx[2]    =>   a_mac_out[11]     ) = (0,0);
(b_dinx[3]    =>   a_mac_out[11]     ) = (0,0);
(b_dinx[4]    =>   a_mac_out[11]     ) = (0,0);
(b_dinx[5]    =>   a_mac_out[11]     ) = (0,0);
(b_dinx[6]    =>   a_mac_out[11]     ) = (0,0);
(b_dinx[7]    =>   a_mac_out[11]     ) = (0,0);
(b_dinx[8]    =>   a_mac_out[11]     ) = (0,0);
(b_dinx[9]    =>   a_mac_out[11]     ) = (0,0);
(b_dinx[10]   =>   a_mac_out[11]     ) = (0,0);
(b_dinx[11]   =>   a_mac_out[11]     ) = (0,0);
(a_diny[0]    =>   a_mac_out[11]     ) = (0,0);
(a_diny[1]    =>   a_mac_out[11]     ) = (0,0);
(a_diny[2]    =>   a_mac_out[11]     ) = (0,0);
(a_diny[3]    =>   a_mac_out[11]     ) = (0,0);
(a_diny[4]    =>   a_mac_out[11]     ) = (0,0);
(a_diny[5]    =>   a_mac_out[11]     ) = (0,0);
(a_diny[6]    =>   a_mac_out[11]     ) = (0,0);
(a_diny[7]    =>   a_mac_out[11]     ) = (0,0);
(a_diny[8]    =>   a_mac_out[11]     ) = (0,0);
(a_diny[9]    =>   a_mac_out[11]     ) = (0,0);
(b_diny[0]    =>   a_mac_out[11]     ) = (0,0);
(b_diny[1]    =>   a_mac_out[11]     ) = (0,0);
(b_diny[2]    =>   a_mac_out[11]     ) = (0,0);
(b_diny[3]    =>   a_mac_out[11]     ) = (0,0);
(b_diny[4]    =>   a_mac_out[11]     ) = (0,0);
(b_diny[5]    =>   a_mac_out[11]     ) = (0,0);
(b_diny[6]    =>   a_mac_out[11]     ) = (0,0);
(b_diny[7]    =>   a_mac_out[11]     ) = (0,0);
(b_diny[8]    =>   a_mac_out[11]     ) = (0,0);
(a_dinz[0]    =>   a_mac_out[11]     ) = (0,0);
(a_dinz[1]    =>   a_mac_out[11]     ) = (0,0);
(a_dinz[2]    =>   a_mac_out[11]     ) = (0,0);
(a_dinz[3]    =>   a_mac_out[11]     ) = (0,0);
(a_dinz[4]    =>   a_mac_out[11]     ) = (0,0);
(a_dinz[5]    =>   a_mac_out[11]     ) = (0,0);
(a_dinz[6]    =>   a_mac_out[11]     ) = (0,0);
(a_dinz[7]    =>   a_mac_out[11]     ) = (0,0);
(a_dinz[8]    =>   a_mac_out[11]     ) = (0,0);
(a_dinz[9]    =>   a_mac_out[11]     ) = (0,0);
(a_dinz[10]   =>   a_mac_out[11]     ) = (0,0);
(a_dinz[11]   =>   a_mac_out[11]     ) = (0,0);
(a_dinz[12]   =>   a_mac_out[11]     ) = (0,0);
(a_dinz[13]   =>   a_mac_out[11]     ) = (0,0);
(a_dinz[14]   =>   a_mac_out[11]     ) = (0,0);
(a_dinz[15]   =>   a_mac_out[11]     ) = (0,0);
(a_dinz[16]   =>   a_mac_out[11]     ) = (0,0);
(a_dinz[17]   =>   a_mac_out[11]     ) = (0,0);
(a_dinz_en    =>   a_mac_out[11]     ) = (0,0);
(a_dinx[0]    =>   a_mac_out[12]     ) = (0,0);
(a_dinx[1]    =>   a_mac_out[12]     ) = (0,0);
(a_dinx[2]    =>   a_mac_out[12]     ) = (0,0);
(a_dinx[3]    =>   a_mac_out[12]     ) = (0,0);
(a_dinx[4]    =>   a_mac_out[12]     ) = (0,0);
(a_dinx[5]    =>   a_mac_out[12]     ) = (0,0);
(a_dinx[6]    =>   a_mac_out[12]     ) = (0,0);
(a_dinx[7]    =>   a_mac_out[12]     ) = (0,0);
(a_dinx[8]    =>   a_mac_out[12]     ) = (0,0);
(a_dinx[9]    =>   a_mac_out[12]     ) = (0,0);
(a_dinx[10]   =>   a_mac_out[12]     ) = (0,0);
(a_dinx[11]   =>   a_mac_out[12]     ) = (0,0);
(a_dinx[12]   =>   a_mac_out[12]     ) = (0,0);
(b_dinx[0]    =>   a_mac_out[12]     ) = (0,0);
(b_dinx[1]    =>   a_mac_out[12]     ) = (0,0);
(b_dinx[2]    =>   a_mac_out[12]     ) = (0,0);
(b_dinx[3]    =>   a_mac_out[12]     ) = (0,0);
(b_dinx[4]    =>   a_mac_out[12]     ) = (0,0);
(b_dinx[5]    =>   a_mac_out[12]     ) = (0,0);
(b_dinx[6]    =>   a_mac_out[12]     ) = (0,0);
(b_dinx[7]    =>   a_mac_out[12]     ) = (0,0);
(b_dinx[8]    =>   a_mac_out[12]     ) = (0,0);
(b_dinx[9]    =>   a_mac_out[12]     ) = (0,0);
(b_dinx[10]   =>   a_mac_out[12]     ) = (0,0);
(b_dinx[11]   =>   a_mac_out[12]     ) = (0,0);
(b_dinx[12]   =>   a_mac_out[12]     ) = (0,0);
(a_diny[0]    =>   a_mac_out[12]     ) = (0,0);
(a_diny[1]    =>   a_mac_out[12]     ) = (0,0);
(a_diny[2]    =>   a_mac_out[12]     ) = (0,0);
(a_diny[3]    =>   a_mac_out[12]     ) = (0,0);
(a_diny[4]    =>   a_mac_out[12]     ) = (0,0);
(a_diny[5]    =>   a_mac_out[12]     ) = (0,0);
(a_diny[6]    =>   a_mac_out[12]     ) = (0,0);
(a_diny[7]    =>   a_mac_out[12]     ) = (0,0);
(a_diny[8]    =>   a_mac_out[12]     ) = (0,0);
(a_diny[9]    =>   a_mac_out[12]     ) = (0,0);
(b_diny[0]    =>   a_mac_out[12]     ) = (0,0);
(b_diny[1]    =>   a_mac_out[12]     ) = (0,0);
(b_diny[2]    =>   a_mac_out[12]     ) = (0,0);
(b_diny[3]    =>   a_mac_out[12]     ) = (0,0);
(b_diny[4]    =>   a_mac_out[12]     ) = (0,0);
(b_diny[5]    =>   a_mac_out[12]     ) = (0,0);
(b_diny[6]    =>   a_mac_out[12]     ) = (0,0);
(b_diny[7]    =>   a_mac_out[12]     ) = (0,0);
(b_diny[8]    =>   a_mac_out[12]     ) = (0,0);
(b_diny[9]    =>   a_mac_out[12]     ) = (0,0);
(a_dinz[0]    =>   a_mac_out[12]     ) = (0,0);
(a_dinz[1]    =>   a_mac_out[12]     ) = (0,0);
(a_dinz[2]    =>   a_mac_out[12]     ) = (0,0);
(a_dinz[3]    =>   a_mac_out[12]     ) = (0,0);
(a_dinz[4]    =>   a_mac_out[12]     ) = (0,0);
(a_dinz[5]    =>   a_mac_out[12]     ) = (0,0);
(a_dinz[6]    =>   a_mac_out[12]     ) = (0,0);
(a_dinz[7]    =>   a_mac_out[12]     ) = (0,0);
(a_dinz[8]    =>   a_mac_out[12]     ) = (0,0);
(a_dinz[9]    =>   a_mac_out[12]     ) = (0,0);
(a_dinz[10]   =>   a_mac_out[12]     ) = (0,0);
(a_dinz[11]   =>   a_mac_out[12]     ) = (0,0);
(a_dinz[12]   =>   a_mac_out[12]     ) = (0,0);
(a_dinz[13]   =>   a_mac_out[12]     ) = (0,0);
(a_dinz[14]   =>   a_mac_out[12]     ) = (0,0);
(a_dinz[15]   =>   a_mac_out[12]     ) = (0,0);
(a_dinz[16]   =>   a_mac_out[12]     ) = (0,0);
(a_dinz[17]   =>   a_mac_out[12]     ) = (0,0);
(a_dinz[18]   =>   a_mac_out[12]     ) = (0,0);
(a_dinz_en    =>   a_mac_out[12]     ) = (0,0);
(a_dinx[0]    =>   a_mac_out[13]     ) = (0,0);
(a_dinx[1]    =>   a_mac_out[13]     ) = (0,0);
(a_dinx[2]    =>   a_mac_out[13]     ) = (0,0);
(a_dinx[3]    =>   a_mac_out[13]     ) = (0,0);
(a_dinx[4]    =>   a_mac_out[13]     ) = (0,0);
(a_dinx[5]    =>   a_mac_out[13]     ) = (0,0);
(a_dinx[6]    =>   a_mac_out[13]     ) = (0,0);
(a_dinx[7]    =>   a_mac_out[13]     ) = (0,0);
(a_dinx[8]    =>   a_mac_out[13]     ) = (0,0);
(a_dinx[9]    =>   a_mac_out[13]     ) = (0,0);
(a_dinx[10]   =>   a_mac_out[13]     ) = (0,0);
(a_dinx[11]   =>   a_mac_out[13]     ) = (0,0);
(a_dinx[12]   =>   a_mac_out[13]     ) = (0,0);
(b_dinx[0]    =>   a_mac_out[13]     ) = (0,0);
(b_dinx[1]    =>   a_mac_out[13]     ) = (0,0);
(b_dinx[2]    =>   a_mac_out[13]     ) = (0,0);
(b_dinx[3]    =>   a_mac_out[13]     ) = (0,0);
(b_dinx[4]    =>   a_mac_out[13]     ) = (0,0);
(b_dinx[5]    =>   a_mac_out[13]     ) = (0,0);
(b_dinx[6]    =>   a_mac_out[13]     ) = (0,0);
(b_dinx[7]    =>   a_mac_out[13]     ) = (0,0);
(b_dinx[8]    =>   a_mac_out[13]     ) = (0,0);
(b_dinx[9]    =>   a_mac_out[13]     ) = (0,0);
(b_dinx[10]   =>   a_mac_out[13]     ) = (0,0);
(b_dinx[11]   =>   a_mac_out[13]     ) = (0,0);
(b_dinx[12]   =>   a_mac_out[13]     ) = (0,0);
(a_diny[0]    =>   a_mac_out[13]     ) = (0,0);
(a_diny[1]    =>   a_mac_out[13]     ) = (0,0);
(a_diny[2]    =>   a_mac_out[13]     ) = (0,0);
(a_diny[3]    =>   a_mac_out[13]     ) = (0,0);
(a_diny[4]    =>   a_mac_out[13]     ) = (0,0);
(a_diny[5]    =>   a_mac_out[13]     ) = (0,0);
(a_diny[6]    =>   a_mac_out[13]     ) = (0,0);
(a_diny[7]    =>   a_mac_out[13]     ) = (0,0);
(a_diny[8]    =>   a_mac_out[13]     ) = (0,0);
(a_diny[9]    =>   a_mac_out[13]     ) = (0,0);
(b_diny[0]    =>   a_mac_out[13]     ) = (0,0);
(b_diny[1]    =>   a_mac_out[13]     ) = (0,0);
(b_diny[2]    =>   a_mac_out[13]     ) = (0,0);
(b_diny[3]    =>   a_mac_out[13]     ) = (0,0);
(b_diny[4]    =>   a_mac_out[13]     ) = (0,0);
(b_diny[5]    =>   a_mac_out[13]     ) = (0,0);
(b_diny[6]    =>   a_mac_out[13]     ) = (0,0);
(b_diny[7]    =>   a_mac_out[13]     ) = (0,0);
(b_diny[8]    =>   a_mac_out[13]     ) = (0,0);
(b_diny[9]    =>   a_mac_out[13]     ) = (0,0);
(a_dinz[0]    =>   a_mac_out[13]     ) = (0,0);
(a_dinz[1]    =>   a_mac_out[13]     ) = (0,0);
(a_dinz[2]    =>   a_mac_out[13]     ) = (0,0);
(a_dinz[3]    =>   a_mac_out[13]     ) = (0,0);
(a_dinz[4]    =>   a_mac_out[13]     ) = (0,0);
(a_dinz[5]    =>   a_mac_out[13]     ) = (0,0);
(a_dinz[6]    =>   a_mac_out[13]     ) = (0,0);
(a_dinz[7]    =>   a_mac_out[13]     ) = (0,0);
(a_dinz[8]    =>   a_mac_out[13]     ) = (0,0);
(a_dinz[9]    =>   a_mac_out[13]     ) = (0,0);
(a_dinz[10]   =>   a_mac_out[13]     ) = (0,0);
(a_dinz[11]   =>   a_mac_out[13]     ) = (0,0);
(a_dinz[12]   =>   a_mac_out[13]     ) = (0,0);
(a_dinz[13]   =>   a_mac_out[13]     ) = (0,0);
(a_dinz[14]   =>   a_mac_out[13]     ) = (0,0);
(a_dinz[15]   =>   a_mac_out[13]     ) = (0,0);
(a_dinz[16]   =>   a_mac_out[13]     ) = (0,0);
(a_dinz[17]   =>   a_mac_out[13]     ) = (0,0);
(a_dinz[18]   =>   a_mac_out[13]     ) = (0,0);
(a_dinz[19]   =>   a_mac_out[13]     ) = (0,0);
(a_dinz_en    =>   a_mac_out[13]     ) = (0,0);
(a_dinx[0]    =>   a_mac_out[14]     ) = (0,0);
(a_dinx[1]    =>   a_mac_out[14]     ) = (0,0);
(a_dinx[2]    =>   a_mac_out[14]     ) = (0,0);
(a_dinx[3]    =>   a_mac_out[14]     ) = (0,0);
(a_dinx[4]    =>   a_mac_out[14]     ) = (0,0);
(a_dinx[5]    =>   a_mac_out[14]     ) = (0,0);
(a_dinx[6]    =>   a_mac_out[14]     ) = (0,0);
(a_dinx[7]    =>   a_mac_out[14]     ) = (0,0);
(a_dinx[8]    =>   a_mac_out[14]     ) = (0,0);
(a_dinx[9]    =>   a_mac_out[14]     ) = (0,0);
(a_dinx[10]   =>   a_mac_out[14]     ) = (0,0);
(a_dinx[11]   =>   a_mac_out[14]     ) = (0,0);
(a_dinx[12]   =>   a_mac_out[14]     ) = (0,0);
(b_dinx[0]    =>   a_mac_out[14]     ) = (0,0);
(b_dinx[1]    =>   a_mac_out[14]     ) = (0,0);
(b_dinx[2]    =>   a_mac_out[14]     ) = (0,0);
(b_dinx[3]    =>   a_mac_out[14]     ) = (0,0);
(b_dinx[4]    =>   a_mac_out[14]     ) = (0,0);
(b_dinx[5]    =>   a_mac_out[14]     ) = (0,0);
(b_dinx[6]    =>   a_mac_out[14]     ) = (0,0);
(b_dinx[7]    =>   a_mac_out[14]     ) = (0,0);
(b_dinx[8]    =>   a_mac_out[14]     ) = (0,0);
(b_dinx[9]    =>   a_mac_out[14]     ) = (0,0);
(b_dinx[10]   =>   a_mac_out[14]     ) = (0,0);
(b_dinx[11]   =>   a_mac_out[14]     ) = (0,0);
(b_dinx[12]   =>   a_mac_out[14]     ) = (0,0);
(a_diny[0]    =>   a_mac_out[14]     ) = (0,0);
(a_diny[1]    =>   a_mac_out[14]     ) = (0,0);
(a_diny[2]    =>   a_mac_out[14]     ) = (0,0);
(a_diny[3]    =>   a_mac_out[14]     ) = (0,0);
(a_diny[4]    =>   a_mac_out[14]     ) = (0,0);
(a_diny[5]    =>   a_mac_out[14]     ) = (0,0);
(a_diny[6]    =>   a_mac_out[14]     ) = (0,0);
(a_diny[7]    =>   a_mac_out[14]     ) = (0,0);
(a_diny[8]    =>   a_mac_out[14]     ) = (0,0);
(a_diny[9]    =>   a_mac_out[14]     ) = (0,0);
(b_diny[0]    =>   a_mac_out[14]     ) = (0,0);
(b_diny[1]    =>   a_mac_out[14]     ) = (0,0);
(b_diny[2]    =>   a_mac_out[14]     ) = (0,0);
(b_diny[3]    =>   a_mac_out[14]     ) = (0,0);
(b_diny[4]    =>   a_mac_out[14]     ) = (0,0);
(b_diny[5]    =>   a_mac_out[14]     ) = (0,0);
(b_diny[6]    =>   a_mac_out[14]     ) = (0,0);
(b_diny[7]    =>   a_mac_out[14]     ) = (0,0);
(b_diny[8]    =>   a_mac_out[14]     ) = (0,0);
(b_diny[9]    =>   a_mac_out[14]     ) = (0,0);
(a_dinz[0]    =>   a_mac_out[14]     ) = (0,0);
(a_dinz[1]    =>   a_mac_out[14]     ) = (0,0);
(a_dinz[2]    =>   a_mac_out[14]     ) = (0,0);
(a_dinz[3]    =>   a_mac_out[14]     ) = (0,0);
(a_dinz[4]    =>   a_mac_out[14]     ) = (0,0);
(a_dinz[5]    =>   a_mac_out[14]     ) = (0,0);
(a_dinz[6]    =>   a_mac_out[14]     ) = (0,0);
(a_dinz[7]    =>   a_mac_out[14]     ) = (0,0);
(a_dinz[8]    =>   a_mac_out[14]     ) = (0,0);
(a_dinz[9]    =>   a_mac_out[14]     ) = (0,0);
(a_dinz[10]   =>   a_mac_out[14]     ) = (0,0);
(a_dinz[11]   =>   a_mac_out[14]     ) = (0,0);
(a_dinz[12]   =>   a_mac_out[14]     ) = (0,0);
(a_dinz[13]   =>   a_mac_out[14]     ) = (0,0);
(a_dinz[14]   =>   a_mac_out[14]     ) = (0,0);
(a_dinz[15]   =>   a_mac_out[14]     ) = (0,0);
(a_dinz[16]   =>   a_mac_out[14]     ) = (0,0);
(a_dinz[17]   =>   a_mac_out[14]     ) = (0,0);
(a_dinz[18]   =>   a_mac_out[14]     ) = (0,0);
(a_dinz[19]   =>   a_mac_out[14]     ) = (0,0);
(a_dinz[20]   =>   a_mac_out[14]     ) = (0,0);
(a_dinz_en    =>   a_mac_out[14]     ) = (0,0);
(a_dinx[0]    =>   a_mac_out[15]     ) = (0,0);
(a_dinx[1]    =>   a_mac_out[15]     ) = (0,0);
(a_dinx[2]    =>   a_mac_out[15]     ) = (0,0);
(a_dinx[3]    =>   a_mac_out[15]     ) = (0,0);
(a_dinx[4]    =>   a_mac_out[15]     ) = (0,0);
(a_dinx[5]    =>   a_mac_out[15]     ) = (0,0);
(a_dinx[6]    =>   a_mac_out[15]     ) = (0,0);
(a_dinx[7]    =>   a_mac_out[15]     ) = (0,0);
(a_dinx[8]    =>   a_mac_out[15]     ) = (0,0);
(a_dinx[9]    =>   a_mac_out[15]     ) = (0,0);
(a_dinx[10]   =>   a_mac_out[15]     ) = (0,0);
(a_dinx[11]   =>   a_mac_out[15]     ) = (0,0);
(a_dinx[12]   =>   a_mac_out[15]     ) = (0,0);
(b_dinx[0]    =>   a_mac_out[15]     ) = (0,0);
(b_dinx[1]    =>   a_mac_out[15]     ) = (0,0);
(b_dinx[2]    =>   a_mac_out[15]     ) = (0,0);
(b_dinx[3]    =>   a_mac_out[15]     ) = (0,0);
(b_dinx[4]    =>   a_mac_out[15]     ) = (0,0);
(b_dinx[5]    =>   a_mac_out[15]     ) = (0,0);
(b_dinx[6]    =>   a_mac_out[15]     ) = (0,0);
(b_dinx[7]    =>   a_mac_out[15]     ) = (0,0);
(b_dinx[8]    =>   a_mac_out[15]     ) = (0,0);
(b_dinx[9]    =>   a_mac_out[15]     ) = (0,0);
(b_dinx[10]   =>   a_mac_out[15]     ) = (0,0);
(b_dinx[11]   =>   a_mac_out[15]     ) = (0,0);
(b_dinx[12]   =>   a_mac_out[15]     ) = (0,0);
(a_diny[0]    =>   a_mac_out[15]     ) = (0,0);
(a_diny[1]    =>   a_mac_out[15]     ) = (0,0);
(a_diny[2]    =>   a_mac_out[15]     ) = (0,0);
(a_diny[3]    =>   a_mac_out[15]     ) = (0,0);
(a_diny[4]    =>   a_mac_out[15]     ) = (0,0);
(a_diny[5]    =>   a_mac_out[15]     ) = (0,0);
(a_diny[6]    =>   a_mac_out[15]     ) = (0,0);
(a_diny[7]    =>   a_mac_out[15]     ) = (0,0);
(a_diny[8]    =>   a_mac_out[15]     ) = (0,0);
(a_diny[9]    =>   a_mac_out[15]     ) = (0,0);
(b_diny[0]    =>   a_mac_out[15]     ) = (0,0);
(b_diny[1]    =>   a_mac_out[15]     ) = (0,0);
(b_diny[2]    =>   a_mac_out[15]     ) = (0,0);
(b_diny[3]    =>   a_mac_out[15]     ) = (0,0);
(b_diny[4]    =>   a_mac_out[15]     ) = (0,0);
(b_diny[5]    =>   a_mac_out[15]     ) = (0,0);
(b_diny[6]    =>   a_mac_out[15]     ) = (0,0);
(b_diny[7]    =>   a_mac_out[15]     ) = (0,0);
(b_diny[8]    =>   a_mac_out[15]     ) = (0,0);
(b_diny[9]    =>   a_mac_out[15]     ) = (0,0);
(a_dinz[0]    =>   a_mac_out[15]     ) = (0,0);
(a_dinz[1]    =>   a_mac_out[15]     ) = (0,0);
(a_dinz[2]    =>   a_mac_out[15]     ) = (0,0);
(a_dinz[3]    =>   a_mac_out[15]     ) = (0,0);
(a_dinz[4]    =>   a_mac_out[15]     ) = (0,0);
(a_dinz[5]    =>   a_mac_out[15]     ) = (0,0);
(a_dinz[6]    =>   a_mac_out[15]     ) = (0,0);
(a_dinz[7]    =>   a_mac_out[15]     ) = (0,0);
(a_dinz[8]    =>   a_mac_out[15]     ) = (0,0);
(a_dinz[9]    =>   a_mac_out[15]     ) = (0,0);
(a_dinz[10]   =>   a_mac_out[15]     ) = (0,0);
(a_dinz[11]   =>   a_mac_out[15]     ) = (0,0);
(a_dinz[12]   =>   a_mac_out[15]     ) = (0,0);
(a_dinz[13]   =>   a_mac_out[15]     ) = (0,0);
(a_dinz[14]   =>   a_mac_out[15]     ) = (0,0);
(a_dinz[15]   =>   a_mac_out[15]     ) = (0,0);
(a_dinz[16]   =>   a_mac_out[15]     ) = (0,0);
(a_dinz[17]   =>   a_mac_out[15]     ) = (0,0);
(a_dinz[18]   =>   a_mac_out[15]     ) = (0,0);
(a_dinz[19]   =>   a_mac_out[15]     ) = (0,0);
(a_dinz[20]   =>   a_mac_out[15]     ) = (0,0);
(a_dinz[21]   =>   a_mac_out[15]     ) = (0,0);
(a_dinz_en    =>   a_mac_out[15]     ) = (0,0);
(a_dinx[0]    =>   a_mac_out[16]     ) = (0,0);
(a_dinx[1]    =>   a_mac_out[16]     ) = (0,0);
(a_dinx[2]    =>   a_mac_out[16]     ) = (0,0);
(a_dinx[3]    =>   a_mac_out[16]     ) = (0,0);
(a_dinx[4]    =>   a_mac_out[16]     ) = (0,0);
(a_dinx[5]    =>   a_mac_out[16]     ) = (0,0);
(a_dinx[6]    =>   a_mac_out[16]     ) = (0,0);
(a_dinx[7]    =>   a_mac_out[16]     ) = (0,0);
(a_dinx[8]    =>   a_mac_out[16]     ) = (0,0);
(a_dinx[9]    =>   a_mac_out[16]     ) = (0,0);
(a_dinx[10]   =>   a_mac_out[16]     ) = (0,0);
(a_dinx[11]   =>   a_mac_out[16]     ) = (0,0);
(a_dinx[12]   =>   a_mac_out[16]     ) = (0,0);
(b_dinx[0]    =>   a_mac_out[16]     ) = (0,0);
(b_dinx[1]    =>   a_mac_out[16]     ) = (0,0);
(b_dinx[2]    =>   a_mac_out[16]     ) = (0,0);
(b_dinx[3]    =>   a_mac_out[16]     ) = (0,0);
(b_dinx[4]    =>   a_mac_out[16]     ) = (0,0);
(b_dinx[5]    =>   a_mac_out[16]     ) = (0,0);
(b_dinx[6]    =>   a_mac_out[16]     ) = (0,0);
(b_dinx[7]    =>   a_mac_out[16]     ) = (0,0);
(b_dinx[8]    =>   a_mac_out[16]     ) = (0,0);
(b_dinx[9]    =>   a_mac_out[16]     ) = (0,0);
(b_dinx[10]   =>   a_mac_out[16]     ) = (0,0);
(b_dinx[11]   =>   a_mac_out[16]     ) = (0,0);
(b_dinx[12]   =>   a_mac_out[16]     ) = (0,0);
(a_diny[0]    =>   a_mac_out[16]     ) = (0,0);
(a_diny[1]    =>   a_mac_out[16]     ) = (0,0);
(a_diny[2]    =>   a_mac_out[16]     ) = (0,0);
(a_diny[3]    =>   a_mac_out[16]     ) = (0,0);
(a_diny[4]    =>   a_mac_out[16]     ) = (0,0);
(a_diny[5]    =>   a_mac_out[16]     ) = (0,0);
(a_diny[6]    =>   a_mac_out[16]     ) = (0,0);
(a_diny[7]    =>   a_mac_out[16]     ) = (0,0);
(a_diny[8]    =>   a_mac_out[16]     ) = (0,0);
(a_diny[9]    =>   a_mac_out[16]     ) = (0,0);
(b_diny[0]    =>   a_mac_out[16]     ) = (0,0);
(b_diny[1]    =>   a_mac_out[16]     ) = (0,0);
(b_diny[2]    =>   a_mac_out[16]     ) = (0,0);
(b_diny[3]    =>   a_mac_out[16]     ) = (0,0);
(b_diny[4]    =>   a_mac_out[16]     ) = (0,0);
(b_diny[5]    =>   a_mac_out[16]     ) = (0,0);
(b_diny[6]    =>   a_mac_out[16]     ) = (0,0);
(b_diny[7]    =>   a_mac_out[16]     ) = (0,0);
(b_diny[8]    =>   a_mac_out[16]     ) = (0,0);
(b_diny[9]    =>   a_mac_out[16]     ) = (0,0);
(a_dinz[0]    =>   a_mac_out[16]     ) = (0,0);
(a_dinz[1]    =>   a_mac_out[16]     ) = (0,0);
(a_dinz[2]    =>   a_mac_out[16]     ) = (0,0);
(a_dinz[3]    =>   a_mac_out[16]     ) = (0,0);
(a_dinz[4]    =>   a_mac_out[16]     ) = (0,0);
(a_dinz[5]    =>   a_mac_out[16]     ) = (0,0);
(a_dinz[6]    =>   a_mac_out[16]     ) = (0,0);
(a_dinz[7]    =>   a_mac_out[16]     ) = (0,0);
(a_dinz[8]    =>   a_mac_out[16]     ) = (0,0);
(a_dinz[9]    =>   a_mac_out[16]     ) = (0,0);
(a_dinz[10]   =>   a_mac_out[16]     ) = (0,0);
(a_dinz[11]   =>   a_mac_out[16]     ) = (0,0);
(a_dinz[12]   =>   a_mac_out[16]     ) = (0,0);
(a_dinz[13]   =>   a_mac_out[16]     ) = (0,0);
(a_dinz[14]   =>   a_mac_out[16]     ) = (0,0);
(a_dinz[15]   =>   a_mac_out[16]     ) = (0,0);
(a_dinz[16]   =>   a_mac_out[16]     ) = (0,0);
(a_dinz[17]   =>   a_mac_out[16]     ) = (0,0);
(a_dinz[18]   =>   a_mac_out[16]     ) = (0,0);
(a_dinz[19]   =>   a_mac_out[16]     ) = (0,0);
(a_dinz[20]   =>   a_mac_out[16]     ) = (0,0);
(a_dinz[21]   =>   a_mac_out[16]     ) = (0,0);
(a_dinz[22]   =>   a_mac_out[16]     ) = (0,0);
(a_dinz_en    =>   a_mac_out[16]     ) = (0,0);
(a_dinx[0]    =>   a_mac_out[17]     ) = (0,0);
(a_dinx[1]    =>   a_mac_out[17]     ) = (0,0);
(a_dinx[2]    =>   a_mac_out[17]     ) = (0,0);
(a_dinx[3]    =>   a_mac_out[17]     ) = (0,0);
(a_dinx[4]    =>   a_mac_out[17]     ) = (0,0);
(a_dinx[5]    =>   a_mac_out[17]     ) = (0,0);
(a_dinx[6]    =>   a_mac_out[17]     ) = (0,0);
(a_dinx[7]    =>   a_mac_out[17]     ) = (0,0);
(a_dinx[8]    =>   a_mac_out[17]     ) = (0,0);
(a_dinx[9]    =>   a_mac_out[17]     ) = (0,0);
(a_dinx[10]   =>   a_mac_out[17]     ) = (0,0);
(a_dinx[11]   =>   a_mac_out[17]     ) = (0,0);
(a_dinx[12]   =>   a_mac_out[17]     ) = (0,0);
(b_dinx[0]    =>   a_mac_out[17]     ) = (0,0);
(b_dinx[1]    =>   a_mac_out[17]     ) = (0,0);
(b_dinx[2]    =>   a_mac_out[17]     ) = (0,0);
(b_dinx[3]    =>   a_mac_out[17]     ) = (0,0);
(b_dinx[4]    =>   a_mac_out[17]     ) = (0,0);
(b_dinx[5]    =>   a_mac_out[17]     ) = (0,0);
(b_dinx[6]    =>   a_mac_out[17]     ) = (0,0);
(b_dinx[7]    =>   a_mac_out[17]     ) = (0,0);
(b_dinx[8]    =>   a_mac_out[17]     ) = (0,0);
(b_dinx[9]    =>   a_mac_out[17]     ) = (0,0);
(b_dinx[10]   =>   a_mac_out[17]     ) = (0,0);
(b_dinx[11]   =>   a_mac_out[17]     ) = (0,0);
(b_dinx[12]   =>   a_mac_out[17]     ) = (0,0);
(a_diny[0]    =>   a_mac_out[17]     ) = (0,0);
(a_diny[1]    =>   a_mac_out[17]     ) = (0,0);
(a_diny[2]    =>   a_mac_out[17]     ) = (0,0);
(a_diny[3]    =>   a_mac_out[17]     ) = (0,0);
(a_diny[4]    =>   a_mac_out[17]     ) = (0,0);
(a_diny[5]    =>   a_mac_out[17]     ) = (0,0);
(a_diny[6]    =>   a_mac_out[17]     ) = (0,0);
(a_diny[7]    =>   a_mac_out[17]     ) = (0,0);
(a_diny[8]    =>   a_mac_out[17]     ) = (0,0);
(a_diny[9]    =>   a_mac_out[17]     ) = (0,0);
(b_diny[0]    =>   a_mac_out[17]     ) = (0,0);
(b_diny[1]    =>   a_mac_out[17]     ) = (0,0);
(b_diny[2]    =>   a_mac_out[17]     ) = (0,0);
(b_diny[3]    =>   a_mac_out[17]     ) = (0,0);
(b_diny[4]    =>   a_mac_out[17]     ) = (0,0);
(b_diny[5]    =>   a_mac_out[17]     ) = (0,0);
(b_diny[6]    =>   a_mac_out[17]     ) = (0,0);
(b_diny[7]    =>   a_mac_out[17]     ) = (0,0);
(b_diny[8]    =>   a_mac_out[17]     ) = (0,0);
(b_diny[9]    =>   a_mac_out[17]     ) = (0,0);
(a_dinz[0]    =>   a_mac_out[17]     ) = (0,0);
(a_dinz[1]    =>   a_mac_out[17]     ) = (0,0);
(a_dinz[2]    =>   a_mac_out[17]     ) = (0,0);
(a_dinz[3]    =>   a_mac_out[17]     ) = (0,0);
(a_dinz[4]    =>   a_mac_out[17]     ) = (0,0);
(a_dinz[5]    =>   a_mac_out[17]     ) = (0,0);
(a_dinz[6]    =>   a_mac_out[17]     ) = (0,0);
(a_dinz[7]    =>   a_mac_out[17]     ) = (0,0);
(a_dinz[8]    =>   a_mac_out[17]     ) = (0,0);
(a_dinz[9]    =>   a_mac_out[17]     ) = (0,0);
(a_dinz[10]   =>   a_mac_out[17]     ) = (0,0);
(a_dinz[11]   =>   a_mac_out[17]     ) = (0,0);
(a_dinz[12]   =>   a_mac_out[17]     ) = (0,0);
(a_dinz[13]   =>   a_mac_out[17]     ) = (0,0);
(a_dinz[14]   =>   a_mac_out[17]     ) = (0,0);
(a_dinz[15]   =>   a_mac_out[17]     ) = (0,0);
(a_dinz[16]   =>   a_mac_out[17]     ) = (0,0);
(a_dinz[17]   =>   a_mac_out[17]     ) = (0,0);
(a_dinz[18]   =>   a_mac_out[17]     ) = (0,0);
(a_dinz[19]   =>   a_mac_out[17]     ) = (0,0);
(a_dinz[20]   =>   a_mac_out[17]     ) = (0,0);
(a_dinz[21]   =>   a_mac_out[17]     ) = (0,0);
(a_dinz[22]   =>   a_mac_out[17]     ) = (0,0);
(a_dinz[23]   =>   a_mac_out[17]     ) = (0,0);
(a_dinz_en    =>   a_mac_out[17]     ) = (0,0);
(a_dinx[0]    =>   a_mac_out[18]     ) = (0,0);
(a_dinx[1]    =>   a_mac_out[18]     ) = (0,0);
(a_dinx[2]    =>   a_mac_out[18]     ) = (0,0);
(a_dinx[3]    =>   a_mac_out[18]     ) = (0,0);
(a_dinx[4]    =>   a_mac_out[18]     ) = (0,0);
(a_dinx[5]    =>   a_mac_out[18]     ) = (0,0);
(a_dinx[6]    =>   a_mac_out[18]     ) = (0,0);
(a_dinx[7]    =>   a_mac_out[18]     ) = (0,0);
(a_dinx[8]    =>   a_mac_out[18]     ) = (0,0);
(a_dinx[9]    =>   a_mac_out[18]     ) = (0,0);
(a_dinx[10]   =>   a_mac_out[18]     ) = (0,0);
(a_dinx[11]   =>   a_mac_out[18]     ) = (0,0);
(a_dinx[12]   =>   a_mac_out[18]     ) = (0,0);
(b_dinx[0]    =>   a_mac_out[18]     ) = (0,0);
(b_dinx[1]    =>   a_mac_out[18]     ) = (0,0);
(b_dinx[2]    =>   a_mac_out[18]     ) = (0,0);
(b_dinx[3]    =>   a_mac_out[18]     ) = (0,0);
(b_dinx[4]    =>   a_mac_out[18]     ) = (0,0);
(b_dinx[5]    =>   a_mac_out[18]     ) = (0,0);
(b_dinx[6]    =>   a_mac_out[18]     ) = (0,0);
(b_dinx[7]    =>   a_mac_out[18]     ) = (0,0);
(b_dinx[8]    =>   a_mac_out[18]     ) = (0,0);
(b_dinx[9]    =>   a_mac_out[18]     ) = (0,0);
(b_dinx[10]   =>   a_mac_out[18]     ) = (0,0);
(b_dinx[11]   =>   a_mac_out[18]     ) = (0,0);
(b_dinx[12]   =>   a_mac_out[18]     ) = (0,0);
(a_diny[0]    =>   a_mac_out[18]     ) = (0,0);
(a_diny[1]    =>   a_mac_out[18]     ) = (0,0);
(a_diny[2]    =>   a_mac_out[18]     ) = (0,0);
(a_diny[3]    =>   a_mac_out[18]     ) = (0,0);
(a_diny[4]    =>   a_mac_out[18]     ) = (0,0);
(a_diny[5]    =>   a_mac_out[18]     ) = (0,0);
(a_diny[6]    =>   a_mac_out[18]     ) = (0,0);
(a_diny[7]    =>   a_mac_out[18]     ) = (0,0);
(a_diny[8]    =>   a_mac_out[18]     ) = (0,0);
(a_diny[9]    =>   a_mac_out[18]     ) = (0,0);
(b_diny[0]    =>   a_mac_out[18]     ) = (0,0);
(b_diny[1]    =>   a_mac_out[18]     ) = (0,0);
(b_diny[2]    =>   a_mac_out[18]     ) = (0,0);
(b_diny[3]    =>   a_mac_out[18]     ) = (0,0);
(b_diny[4]    =>   a_mac_out[18]     ) = (0,0);
(b_diny[5]    =>   a_mac_out[18]     ) = (0,0);
(b_diny[6]    =>   a_mac_out[18]     ) = (0,0);
(b_diny[7]    =>   a_mac_out[18]     ) = (0,0);
(b_diny[8]    =>   a_mac_out[18]     ) = (0,0);
(b_diny[9]    =>   a_mac_out[18]     ) = (0,0);
(a_dinz[0]    =>   a_mac_out[18]     ) = (0,0);
(a_dinz[1]    =>   a_mac_out[18]     ) = (0,0);
(a_dinz[2]    =>   a_mac_out[18]     ) = (0,0);
(a_dinz[3]    =>   a_mac_out[18]     ) = (0,0);
(a_dinz[4]    =>   a_mac_out[18]     ) = (0,0);
(a_dinz[5]    =>   a_mac_out[18]     ) = (0,0);
(a_dinz[6]    =>   a_mac_out[18]     ) = (0,0);
(a_dinz[7]    =>   a_mac_out[18]     ) = (0,0);
(a_dinz[8]    =>   a_mac_out[18]     ) = (0,0);
(a_dinz[9]    =>   a_mac_out[18]     ) = (0,0);
(a_dinz[10]   =>   a_mac_out[18]     ) = (0,0);
(a_dinz[11]   =>   a_mac_out[18]     ) = (0,0);
(a_dinz[12]   =>   a_mac_out[18]     ) = (0,0);
(a_dinz[13]   =>   a_mac_out[18]     ) = (0,0);
(a_dinz[14]   =>   a_mac_out[18]     ) = (0,0);
(a_dinz[15]   =>   a_mac_out[18]     ) = (0,0);
(a_dinz[16]   =>   a_mac_out[18]     ) = (0,0);
(a_dinz[17]   =>   a_mac_out[18]     ) = (0,0);
(a_dinz[18]   =>   a_mac_out[18]     ) = (0,0);
(a_dinz[19]   =>   a_mac_out[18]     ) = (0,0);
(a_dinz[20]   =>   a_mac_out[18]     ) = (0,0);
(a_dinz[21]   =>   a_mac_out[18]     ) = (0,0);
(a_dinz[22]   =>   a_mac_out[18]     ) = (0,0);
(a_dinz[23]   =>   a_mac_out[18]     ) = (0,0);
(b_dinz[0]    =>   a_mac_out[18]     ) = (0,0);
(a_dinz_en    =>   a_mac_out[18]     ) = (0,0);
(a_dinx[0]    =>   a_mac_out[19]     ) = (0,0);
(a_dinx[1]    =>   a_mac_out[19]     ) = (0,0);
(a_dinx[2]    =>   a_mac_out[19]     ) = (0,0);
(a_dinx[3]    =>   a_mac_out[19]     ) = (0,0);
(a_dinx[4]    =>   a_mac_out[19]     ) = (0,0);
(a_dinx[5]    =>   a_mac_out[19]     ) = (0,0);
(a_dinx[6]    =>   a_mac_out[19]     ) = (0,0);
(a_dinx[7]    =>   a_mac_out[19]     ) = (0,0);
(a_dinx[8]    =>   a_mac_out[19]     ) = (0,0);
(a_dinx[9]    =>   a_mac_out[19]     ) = (0,0);
(a_dinx[10]   =>   a_mac_out[19]     ) = (0,0);
(a_dinx[11]   =>   a_mac_out[19]     ) = (0,0);
(a_dinx[12]   =>   a_mac_out[19]     ) = (0,0);
(b_dinx[0]    =>   a_mac_out[19]     ) = (0,0);
(b_dinx[1]    =>   a_mac_out[19]     ) = (0,0);
(b_dinx[2]    =>   a_mac_out[19]     ) = (0,0);
(b_dinx[3]    =>   a_mac_out[19]     ) = (0,0);
(b_dinx[4]    =>   a_mac_out[19]     ) = (0,0);
(b_dinx[5]    =>   a_mac_out[19]     ) = (0,0);
(b_dinx[6]    =>   a_mac_out[19]     ) = (0,0);
(b_dinx[7]    =>   a_mac_out[19]     ) = (0,0);
(b_dinx[8]    =>   a_mac_out[19]     ) = (0,0);
(b_dinx[9]    =>   a_mac_out[19]     ) = (0,0);
(b_dinx[10]   =>   a_mac_out[19]     ) = (0,0);
(b_dinx[11]   =>   a_mac_out[19]     ) = (0,0);
(b_dinx[12]   =>   a_mac_out[19]     ) = (0,0);
(a_diny[0]    =>   a_mac_out[19]     ) = (0,0);
(a_diny[1]    =>   a_mac_out[19]     ) = (0,0);
(a_diny[2]    =>   a_mac_out[19]     ) = (0,0);
(a_diny[3]    =>   a_mac_out[19]     ) = (0,0);
(a_diny[4]    =>   a_mac_out[19]     ) = (0,0);
(a_diny[5]    =>   a_mac_out[19]     ) = (0,0);
(a_diny[6]    =>   a_mac_out[19]     ) = (0,0);
(a_diny[7]    =>   a_mac_out[19]     ) = (0,0);
(a_diny[8]    =>   a_mac_out[19]     ) = (0,0);
(a_diny[9]    =>   a_mac_out[19]     ) = (0,0);
(b_diny[0]    =>   a_mac_out[19]     ) = (0,0);
(b_diny[1]    =>   a_mac_out[19]     ) = (0,0);
(b_diny[2]    =>   a_mac_out[19]     ) = (0,0);
(b_diny[3]    =>   a_mac_out[19]     ) = (0,0);
(b_diny[4]    =>   a_mac_out[19]     ) = (0,0);
(b_diny[5]    =>   a_mac_out[19]     ) = (0,0);
(b_diny[6]    =>   a_mac_out[19]     ) = (0,0);
(b_diny[7]    =>   a_mac_out[19]     ) = (0,0);
(b_diny[8]    =>   a_mac_out[19]     ) = (0,0);
(b_diny[9]    =>   a_mac_out[19]     ) = (0,0);
(a_dinz[0]    =>   a_mac_out[19]     ) = (0,0);
(a_dinz[1]    =>   a_mac_out[19]     ) = (0,0);
(a_dinz[2]    =>   a_mac_out[19]     ) = (0,0);
(a_dinz[3]    =>   a_mac_out[19]     ) = (0,0);
(a_dinz[4]    =>   a_mac_out[19]     ) = (0,0);
(a_dinz[5]    =>   a_mac_out[19]     ) = (0,0);
(a_dinz[6]    =>   a_mac_out[19]     ) = (0,0);
(a_dinz[7]    =>   a_mac_out[19]     ) = (0,0);
(a_dinz[8]    =>   a_mac_out[19]     ) = (0,0);
(a_dinz[9]    =>   a_mac_out[19]     ) = (0,0);
(a_dinz[10]   =>   a_mac_out[19]     ) = (0,0);
(a_dinz[11]   =>   a_mac_out[19]     ) = (0,0);
(a_dinz[12]   =>   a_mac_out[19]     ) = (0,0);
(a_dinz[13]   =>   a_mac_out[19]     ) = (0,0);
(a_dinz[14]   =>   a_mac_out[19]     ) = (0,0);
(a_dinz[15]   =>   a_mac_out[19]     ) = (0,0);
(a_dinz[16]   =>   a_mac_out[19]     ) = (0,0);
(a_dinz[17]   =>   a_mac_out[19]     ) = (0,0);
(a_dinz[18]   =>   a_mac_out[19]     ) = (0,0);
(a_dinz[19]   =>   a_mac_out[19]     ) = (0,0);
(a_dinz[20]   =>   a_mac_out[19]     ) = (0,0);
(a_dinz[21]   =>   a_mac_out[19]     ) = (0,0);
(a_dinz[22]   =>   a_mac_out[19]     ) = (0,0);
(a_dinz[23]   =>   a_mac_out[19]     ) = (0,0);
(b_dinz[0]    =>   a_mac_out[19]     ) = (0,0);
(b_dinz[1]    =>   a_mac_out[19]     ) = (0,0);
(a_dinz_en    =>   a_mac_out[19]     ) = (0,0);
(a_dinx[0]    =>   a_mac_out[20]     ) = (0,0);
(a_dinx[1]    =>   a_mac_out[20]     ) = (0,0);
(a_dinx[2]    =>   a_mac_out[20]     ) = (0,0);
(a_dinx[3]    =>   a_mac_out[20]     ) = (0,0);
(a_dinx[4]    =>   a_mac_out[20]     ) = (0,0);
(a_dinx[5]    =>   a_mac_out[20]     ) = (0,0);
(a_dinx[6]    =>   a_mac_out[20]     ) = (0,0);
(a_dinx[7]    =>   a_mac_out[20]     ) = (0,0);
(a_dinx[8]    =>   a_mac_out[20]     ) = (0,0);
(a_dinx[9]    =>   a_mac_out[20]     ) = (0,0);
(a_dinx[10]   =>   a_mac_out[20]     ) = (0,0);
(a_dinx[11]   =>   a_mac_out[20]     ) = (0,0);
(a_dinx[12]   =>   a_mac_out[20]     ) = (0,0);
(b_dinx[0]    =>   a_mac_out[20]     ) = (0,0);
(b_dinx[1]    =>   a_mac_out[20]     ) = (0,0);
(b_dinx[2]    =>   a_mac_out[20]     ) = (0,0);
(b_dinx[3]    =>   a_mac_out[20]     ) = (0,0);
(b_dinx[4]    =>   a_mac_out[20]     ) = (0,0);
(b_dinx[5]    =>   a_mac_out[20]     ) = (0,0);
(b_dinx[6]    =>   a_mac_out[20]     ) = (0,0);
(b_dinx[7]    =>   a_mac_out[20]     ) = (0,0);
(b_dinx[8]    =>   a_mac_out[20]     ) = (0,0);
(b_dinx[9]    =>   a_mac_out[20]     ) = (0,0);
(b_dinx[10]   =>   a_mac_out[20]     ) = (0,0);
(b_dinx[11]   =>   a_mac_out[20]     ) = (0,0);
(b_dinx[12]   =>   a_mac_out[20]     ) = (0,0);
(a_diny[0]    =>   a_mac_out[20]     ) = (0,0);
(a_diny[1]    =>   a_mac_out[20]     ) = (0,0);
(a_diny[2]    =>   a_mac_out[20]     ) = (0,0);
(a_diny[3]    =>   a_mac_out[20]     ) = (0,0);
(a_diny[4]    =>   a_mac_out[20]     ) = (0,0);
(a_diny[5]    =>   a_mac_out[20]     ) = (0,0);
(a_diny[6]    =>   a_mac_out[20]     ) = (0,0);
(a_diny[7]    =>   a_mac_out[20]     ) = (0,0);
(a_diny[8]    =>   a_mac_out[20]     ) = (0,0);
(a_diny[9]    =>   a_mac_out[20]     ) = (0,0);
(b_diny[0]    =>   a_mac_out[20]     ) = (0,0);
(b_diny[1]    =>   a_mac_out[20]     ) = (0,0);
(b_diny[2]    =>   a_mac_out[20]     ) = (0,0);
(b_diny[3]    =>   a_mac_out[20]     ) = (0,0);
(b_diny[4]    =>   a_mac_out[20]     ) = (0,0);
(b_diny[5]    =>   a_mac_out[20]     ) = (0,0);
(b_diny[6]    =>   a_mac_out[20]     ) = (0,0);
(b_diny[7]    =>   a_mac_out[20]     ) = (0,0);
(b_diny[8]    =>   a_mac_out[20]     ) = (0,0);
(b_diny[9]    =>   a_mac_out[20]     ) = (0,0);
(a_dinz[0]    =>   a_mac_out[20]     ) = (0,0);
(a_dinz[1]    =>   a_mac_out[20]     ) = (0,0);
(a_dinz[2]    =>   a_mac_out[20]     ) = (0,0);
(a_dinz[3]    =>   a_mac_out[20]     ) = (0,0);
(a_dinz[4]    =>   a_mac_out[20]     ) = (0,0);
(a_dinz[5]    =>   a_mac_out[20]     ) = (0,0);
(a_dinz[6]    =>   a_mac_out[20]     ) = (0,0);
(a_dinz[7]    =>   a_mac_out[20]     ) = (0,0);
(a_dinz[8]    =>   a_mac_out[20]     ) = (0,0);
(a_dinz[9]    =>   a_mac_out[20]     ) = (0,0);
(a_dinz[10]   =>   a_mac_out[20]     ) = (0,0);
(a_dinz[11]   =>   a_mac_out[20]     ) = (0,0);
(a_dinz[12]   =>   a_mac_out[20]     ) = (0,0);
(a_dinz[13]   =>   a_mac_out[20]     ) = (0,0);
(a_dinz[14]   =>   a_mac_out[20]     ) = (0,0);
(a_dinz[15]   =>   a_mac_out[20]     ) = (0,0);
(a_dinz[16]   =>   a_mac_out[20]     ) = (0,0);
(a_dinz[17]   =>   a_mac_out[20]     ) = (0,0);
(a_dinz[18]   =>   a_mac_out[20]     ) = (0,0);
(a_dinz[19]   =>   a_mac_out[20]     ) = (0,0);
(a_dinz[20]   =>   a_mac_out[20]     ) = (0,0);
(a_dinz[21]   =>   a_mac_out[20]     ) = (0,0);
(a_dinz[22]   =>   a_mac_out[20]     ) = (0,0);
(a_dinz[23]   =>   a_mac_out[20]     ) = (0,0);
(b_dinz[0]    =>   a_mac_out[20]     ) = (0,0);
(b_dinz[1]    =>   a_mac_out[20]     ) = (0,0);
(b_dinz[2]    =>   a_mac_out[20]     ) = (0,0);
(a_dinz_en    =>   a_mac_out[20]     ) = (0,0);
(a_dinx[0]    =>   a_mac_out[21]     ) = (0,0);
(a_dinx[1]    =>   a_mac_out[21]     ) = (0,0);
(a_dinx[2]    =>   a_mac_out[21]     ) = (0,0);
(a_dinx[3]    =>   a_mac_out[21]     ) = (0,0);
(a_dinx[4]    =>   a_mac_out[21]     ) = (0,0);
(a_dinx[5]    =>   a_mac_out[21]     ) = (0,0);
(a_dinx[6]    =>   a_mac_out[21]     ) = (0,0);
(a_dinx[7]    =>   a_mac_out[21]     ) = (0,0);
(a_dinx[8]    =>   a_mac_out[21]     ) = (0,0);
(a_dinx[9]    =>   a_mac_out[21]     ) = (0,0);
(a_dinx[10]   =>   a_mac_out[21]     ) = (0,0);
(a_dinx[11]   =>   a_mac_out[21]     ) = (0,0);
(a_dinx[12]   =>   a_mac_out[21]     ) = (0,0);
(b_dinx[0]    =>   a_mac_out[21]     ) = (0,0);
(b_dinx[1]    =>   a_mac_out[21]     ) = (0,0);
(b_dinx[2]    =>   a_mac_out[21]     ) = (0,0);
(b_dinx[3]    =>   a_mac_out[21]     ) = (0,0);
(b_dinx[4]    =>   a_mac_out[21]     ) = (0,0);
(b_dinx[5]    =>   a_mac_out[21]     ) = (0,0);
(b_dinx[6]    =>   a_mac_out[21]     ) = (0,0);
(b_dinx[7]    =>   a_mac_out[21]     ) = (0,0);
(b_dinx[8]    =>   a_mac_out[21]     ) = (0,0);
(b_dinx[9]    =>   a_mac_out[21]     ) = (0,0);
(b_dinx[10]   =>   a_mac_out[21]     ) = (0,0);
(b_dinx[11]   =>   a_mac_out[21]     ) = (0,0);
(b_dinx[12]   =>   a_mac_out[21]     ) = (0,0);
(a_diny[0]    =>   a_mac_out[21]     ) = (0,0);
(a_diny[1]    =>   a_mac_out[21]     ) = (0,0);
(a_diny[2]    =>   a_mac_out[21]     ) = (0,0);
(a_diny[3]    =>   a_mac_out[21]     ) = (0,0);
(a_diny[4]    =>   a_mac_out[21]     ) = (0,0);
(a_diny[5]    =>   a_mac_out[21]     ) = (0,0);
(a_diny[6]    =>   a_mac_out[21]     ) = (0,0);
(a_diny[7]    =>   a_mac_out[21]     ) = (0,0);
(a_diny[8]    =>   a_mac_out[21]     ) = (0,0);
(a_diny[9]    =>   a_mac_out[21]     ) = (0,0);
(b_diny[0]    =>   a_mac_out[21]     ) = (0,0);
(b_diny[1]    =>   a_mac_out[21]     ) = (0,0);
(b_diny[2]    =>   a_mac_out[21]     ) = (0,0);
(b_diny[3]    =>   a_mac_out[21]     ) = (0,0);
(b_diny[4]    =>   a_mac_out[21]     ) = (0,0);
(b_diny[5]    =>   a_mac_out[21]     ) = (0,0);
(b_diny[6]    =>   a_mac_out[21]     ) = (0,0);
(b_diny[7]    =>   a_mac_out[21]     ) = (0,0);
(b_diny[8]    =>   a_mac_out[21]     ) = (0,0);
(b_diny[9]    =>   a_mac_out[21]     ) = (0,0);
(a_dinz[0]    =>   a_mac_out[21]     ) = (0,0);
(a_dinz[1]    =>   a_mac_out[21]     ) = (0,0);
(a_dinz[2]    =>   a_mac_out[21]     ) = (0,0);
(a_dinz[3]    =>   a_mac_out[21]     ) = (0,0);
(a_dinz[4]    =>   a_mac_out[21]     ) = (0,0);
(a_dinz[5]    =>   a_mac_out[21]     ) = (0,0);
(a_dinz[6]    =>   a_mac_out[21]     ) = (0,0);
(a_dinz[7]    =>   a_mac_out[21]     ) = (0,0);
(a_dinz[8]    =>   a_mac_out[21]     ) = (0,0);
(a_dinz[9]    =>   a_mac_out[21]     ) = (0,0);
(a_dinz[10]   =>   a_mac_out[21]     ) = (0,0);
(a_dinz[11]   =>   a_mac_out[21]     ) = (0,0);
(a_dinz[12]   =>   a_mac_out[21]     ) = (0,0);
(a_dinz[13]   =>   a_mac_out[21]     ) = (0,0);
(a_dinz[14]   =>   a_mac_out[21]     ) = (0,0);
(a_dinz[15]   =>   a_mac_out[21]     ) = (0,0);
(a_dinz[16]   =>   a_mac_out[21]     ) = (0,0);
(a_dinz[17]   =>   a_mac_out[21]     ) = (0,0);
(a_dinz[18]   =>   a_mac_out[21]     ) = (0,0);
(a_dinz[19]   =>   a_mac_out[21]     ) = (0,0);
(a_dinz[20]   =>   a_mac_out[21]     ) = (0,0);
(a_dinz[21]   =>   a_mac_out[21]     ) = (0,0);
(a_dinz[22]   =>   a_mac_out[21]     ) = (0,0);
(a_dinz[23]   =>   a_mac_out[21]     ) = (0,0);
(b_dinz[0]    =>   a_mac_out[21]     ) = (0,0);
(b_dinz[1]    =>   a_mac_out[21]     ) = (0,0);
(b_dinz[2]    =>   a_mac_out[21]     ) = (0,0);
(b_dinz[3]    =>   a_mac_out[21]     ) = (0,0);
(a_dinz_en    =>   a_mac_out[21]     ) = (0,0);
(a_dinx[0]    =>   a_mac_out[22]     ) = (0,0);
(a_dinx[1]    =>   a_mac_out[22]     ) = (0,0);
(a_dinx[2]    =>   a_mac_out[22]     ) = (0,0);
(a_dinx[3]    =>   a_mac_out[22]     ) = (0,0);
(a_dinx[4]    =>   a_mac_out[22]     ) = (0,0);
(a_dinx[5]    =>   a_mac_out[22]     ) = (0,0);
(a_dinx[6]    =>   a_mac_out[22]     ) = (0,0);
(a_dinx[7]    =>   a_mac_out[22]     ) = (0,0);
(a_dinx[8]    =>   a_mac_out[22]     ) = (0,0);
(a_dinx[9]    =>   a_mac_out[22]     ) = (0,0);
(a_dinx[10]   =>   a_mac_out[22]     ) = (0,0);
(a_dinx[11]   =>   a_mac_out[22]     ) = (0,0);
(a_dinx[12]   =>   a_mac_out[22]     ) = (0,0);
(b_dinx[0]    =>   a_mac_out[22]     ) = (0,0);
(b_dinx[1]    =>   a_mac_out[22]     ) = (0,0);
(b_dinx[2]    =>   a_mac_out[22]     ) = (0,0);
(b_dinx[3]    =>   a_mac_out[22]     ) = (0,0);
(b_dinx[4]    =>   a_mac_out[22]     ) = (0,0);
(b_dinx[5]    =>   a_mac_out[22]     ) = (0,0);
(b_dinx[6]    =>   a_mac_out[22]     ) = (0,0);
(b_dinx[7]    =>   a_mac_out[22]     ) = (0,0);
(b_dinx[8]    =>   a_mac_out[22]     ) = (0,0);
(b_dinx[9]    =>   a_mac_out[22]     ) = (0,0);
(b_dinx[10]   =>   a_mac_out[22]     ) = (0,0);
(b_dinx[11]   =>   a_mac_out[22]     ) = (0,0);
(b_dinx[12]   =>   a_mac_out[22]     ) = (0,0);
(a_diny[0]    =>   a_mac_out[22]     ) = (0,0);
(a_diny[1]    =>   a_mac_out[22]     ) = (0,0);
(a_diny[2]    =>   a_mac_out[22]     ) = (0,0);
(a_diny[3]    =>   a_mac_out[22]     ) = (0,0);
(a_diny[4]    =>   a_mac_out[22]     ) = (0,0);
(a_diny[5]    =>   a_mac_out[22]     ) = (0,0);
(a_diny[6]    =>   a_mac_out[22]     ) = (0,0);
(a_diny[7]    =>   a_mac_out[22]     ) = (0,0);
(a_diny[8]    =>   a_mac_out[22]     ) = (0,0);
(a_diny[9]    =>   a_mac_out[22]     ) = (0,0);
(b_diny[0]    =>   a_mac_out[22]     ) = (0,0);
(b_diny[1]    =>   a_mac_out[22]     ) = (0,0);
(b_diny[2]    =>   a_mac_out[22]     ) = (0,0);
(b_diny[3]    =>   a_mac_out[22]     ) = (0,0);
(b_diny[4]    =>   a_mac_out[22]     ) = (0,0);
(b_diny[5]    =>   a_mac_out[22]     ) = (0,0);
(b_diny[6]    =>   a_mac_out[22]     ) = (0,0);
(b_diny[7]    =>   a_mac_out[22]     ) = (0,0);
(b_diny[8]    =>   a_mac_out[22]     ) = (0,0);
(b_diny[9]    =>   a_mac_out[22]     ) = (0,0);
(a_dinz[0]    =>   a_mac_out[22]     ) = (0,0);
(a_dinz[1]    =>   a_mac_out[22]     ) = (0,0);
(a_dinz[2]    =>   a_mac_out[22]     ) = (0,0);
(a_dinz[3]    =>   a_mac_out[22]     ) = (0,0);
(a_dinz[4]    =>   a_mac_out[22]     ) = (0,0);
(a_dinz[5]    =>   a_mac_out[22]     ) = (0,0);
(a_dinz[6]    =>   a_mac_out[22]     ) = (0,0);
(a_dinz[7]    =>   a_mac_out[22]     ) = (0,0);
(a_dinz[8]    =>   a_mac_out[22]     ) = (0,0);
(a_dinz[9]    =>   a_mac_out[22]     ) = (0,0);
(a_dinz[10]   =>   a_mac_out[22]     ) = (0,0);
(a_dinz[11]   =>   a_mac_out[22]     ) = (0,0);
(a_dinz[12]   =>   a_mac_out[22]     ) = (0,0);
(a_dinz[13]   =>   a_mac_out[22]     ) = (0,0);
(a_dinz[14]   =>   a_mac_out[22]     ) = (0,0);
(a_dinz[15]   =>   a_mac_out[22]     ) = (0,0);
(a_dinz[16]   =>   a_mac_out[22]     ) = (0,0);
(a_dinz[17]   =>   a_mac_out[22]     ) = (0,0);
(a_dinz[18]   =>   a_mac_out[22]     ) = (0,0);
(a_dinz[19]   =>   a_mac_out[22]     ) = (0,0);
(a_dinz[20]   =>   a_mac_out[22]     ) = (0,0);
(a_dinz[21]   =>   a_mac_out[22]     ) = (0,0);
(a_dinz[22]   =>   a_mac_out[22]     ) = (0,0);
(a_dinz[23]   =>   a_mac_out[22]     ) = (0,0);
(b_dinz[0]    =>   a_mac_out[22]     ) = (0,0);
(b_dinz[1]    =>   a_mac_out[22]     ) = (0,0);
(b_dinz[2]    =>   a_mac_out[22]     ) = (0,0);
(b_dinz[3]    =>   a_mac_out[22]     ) = (0,0);
(b_dinz[4]    =>   a_mac_out[22]     ) = (0,0);
(a_dinz_en    =>   a_mac_out[22]     ) = (0,0);
(a_dinx[0]    =>   a_mac_out[23]     ) = (0,0);
(a_dinx[1]    =>   a_mac_out[23]     ) = (0,0);
(a_dinx[2]    =>   a_mac_out[23]     ) = (0,0);
(a_dinx[3]    =>   a_mac_out[23]     ) = (0,0);
(a_dinx[4]    =>   a_mac_out[23]     ) = (0,0);
(a_dinx[5]    =>   a_mac_out[23]     ) = (0,0);
(a_dinx[6]    =>   a_mac_out[23]     ) = (0,0);
(a_dinx[7]    =>   a_mac_out[23]     ) = (0,0);
(a_dinx[8]    =>   a_mac_out[23]     ) = (0,0);
(a_dinx[9]    =>   a_mac_out[23]     ) = (0,0);
(a_dinx[10]   =>   a_mac_out[23]     ) = (0,0);
(a_dinx[11]   =>   a_mac_out[23]     ) = (0,0);
(a_dinx[12]   =>   a_mac_out[23]     ) = (0,0);
(b_dinx[0]    =>   a_mac_out[23]     ) = (0,0);
(b_dinx[1]    =>   a_mac_out[23]     ) = (0,0);
(b_dinx[2]    =>   a_mac_out[23]     ) = (0,0);
(b_dinx[3]    =>   a_mac_out[23]     ) = (0,0);
(b_dinx[4]    =>   a_mac_out[23]     ) = (0,0);
(b_dinx[5]    =>   a_mac_out[23]     ) = (0,0);
(b_dinx[6]    =>   a_mac_out[23]     ) = (0,0);
(b_dinx[7]    =>   a_mac_out[23]     ) = (0,0);
(b_dinx[8]    =>   a_mac_out[23]     ) = (0,0);
(b_dinx[9]    =>   a_mac_out[23]     ) = (0,0);
(b_dinx[10]   =>   a_mac_out[23]     ) = (0,0);
(b_dinx[11]   =>   a_mac_out[23]     ) = (0,0);
(b_dinx[12]   =>   a_mac_out[23]     ) = (0,0);
(a_diny[0]    =>   a_mac_out[23]     ) = (0,0);
(a_diny[1]    =>   a_mac_out[23]     ) = (0,0);
(a_diny[2]    =>   a_mac_out[23]     ) = (0,0);
(a_diny[3]    =>   a_mac_out[23]     ) = (0,0);
(a_diny[4]    =>   a_mac_out[23]     ) = (0,0);
(a_diny[5]    =>   a_mac_out[23]     ) = (0,0);
(a_diny[6]    =>   a_mac_out[23]     ) = (0,0);
(a_diny[7]    =>   a_mac_out[23]     ) = (0,0);
(a_diny[8]    =>   a_mac_out[23]     ) = (0,0);
(a_diny[9]    =>   a_mac_out[23]     ) = (0,0);
(b_diny[0]    =>   a_mac_out[23]     ) = (0,0);
(b_diny[1]    =>   a_mac_out[23]     ) = (0,0);
(b_diny[2]    =>   a_mac_out[23]     ) = (0,0);
(b_diny[3]    =>   a_mac_out[23]     ) = (0,0);
(b_diny[4]    =>   a_mac_out[23]     ) = (0,0);
(b_diny[5]    =>   a_mac_out[23]     ) = (0,0);
(b_diny[6]    =>   a_mac_out[23]     ) = (0,0);
(b_diny[7]    =>   a_mac_out[23]     ) = (0,0);
(b_diny[8]    =>   a_mac_out[23]     ) = (0,0);
(b_diny[9]    =>   a_mac_out[23]     ) = (0,0);
(a_dinz[0]    =>   a_mac_out[23]     ) = (0,0);
(a_dinz[1]    =>   a_mac_out[23]     ) = (0,0);
(a_dinz[2]    =>   a_mac_out[23]     ) = (0,0);
(a_dinz[3]    =>   a_mac_out[23]     ) = (0,0);
(a_dinz[4]    =>   a_mac_out[23]     ) = (0,0);
(a_dinz[5]    =>   a_mac_out[23]     ) = (0,0);
(a_dinz[6]    =>   a_mac_out[23]     ) = (0,0);
(a_dinz[7]    =>   a_mac_out[23]     ) = (0,0);
(a_dinz[8]    =>   a_mac_out[23]     ) = (0,0);
(a_dinz[9]    =>   a_mac_out[23]     ) = (0,0);
(a_dinz[10]   =>   a_mac_out[23]     ) = (0,0);
(a_dinz[11]   =>   a_mac_out[23]     ) = (0,0);
(a_dinz[12]   =>   a_mac_out[23]     ) = (0,0);
(a_dinz[13]   =>   a_mac_out[23]     ) = (0,0);
(a_dinz[14]   =>   a_mac_out[23]     ) = (0,0);
(a_dinz[15]   =>   a_mac_out[23]     ) = (0,0);
(a_dinz[16]   =>   a_mac_out[23]     ) = (0,0);
(a_dinz[17]   =>   a_mac_out[23]     ) = (0,0);
(a_dinz[18]   =>   a_mac_out[23]     ) = (0,0);
(a_dinz[19]   =>   a_mac_out[23]     ) = (0,0);
(a_dinz[20]   =>   a_mac_out[23]     ) = (0,0);
(a_dinz[21]   =>   a_mac_out[23]     ) = (0,0);
(a_dinz[22]   =>   a_mac_out[23]     ) = (0,0);
(a_dinz[23]   =>   a_mac_out[23]     ) = (0,0);
(b_dinz[0]    =>   a_mac_out[23]     ) = (0,0);
(b_dinz[1]    =>   a_mac_out[23]     ) = (0,0);
(b_dinz[2]    =>   a_mac_out[23]     ) = (0,0);
(b_dinz[3]    =>   a_mac_out[23]     ) = (0,0);
(b_dinz[4]    =>   a_mac_out[23]     ) = (0,0);
(b_dinz[5]    =>   a_mac_out[23]     ) = (0,0);
(a_dinz_en    =>   a_mac_out[23]     ) = (0,0);
(a_dinx[0]    =>   a_mac_out[24]     ) = (0,0);
(a_dinx[1]    =>   a_mac_out[24]     ) = (0,0);
(a_dinx[2]    =>   a_mac_out[24]     ) = (0,0);
(a_dinx[3]    =>   a_mac_out[24]     ) = (0,0);
(a_dinx[4]    =>   a_mac_out[24]     ) = (0,0);
(a_dinx[5]    =>   a_mac_out[24]     ) = (0,0);
(a_dinx[6]    =>   a_mac_out[24]     ) = (0,0);
(a_dinx[7]    =>   a_mac_out[24]     ) = (0,0);
(a_dinx[8]    =>   a_mac_out[24]     ) = (0,0);
(a_dinx[9]    =>   a_mac_out[24]     ) = (0,0);
(a_dinx[10]   =>   a_mac_out[24]     ) = (0,0);
(a_dinx[11]   =>   a_mac_out[24]     ) = (0,0);
(a_dinx[12]   =>   a_mac_out[24]     ) = (0,0);
(b_dinx[0]    =>   a_mac_out[24]     ) = (0,0);
(b_dinx[1]    =>   a_mac_out[24]     ) = (0,0);
(b_dinx[2]    =>   a_mac_out[24]     ) = (0,0);
(b_dinx[3]    =>   a_mac_out[24]     ) = (0,0);
(b_dinx[4]    =>   a_mac_out[24]     ) = (0,0);
(b_dinx[5]    =>   a_mac_out[24]     ) = (0,0);
(b_dinx[6]    =>   a_mac_out[24]     ) = (0,0);
(b_dinx[7]    =>   a_mac_out[24]     ) = (0,0);
(b_dinx[8]    =>   a_mac_out[24]     ) = (0,0);
(b_dinx[9]    =>   a_mac_out[24]     ) = (0,0);
(b_dinx[10]   =>   a_mac_out[24]     ) = (0,0);
(b_dinx[11]   =>   a_mac_out[24]     ) = (0,0);
(b_dinx[12]   =>   a_mac_out[24]     ) = (0,0);
(a_diny[0]    =>   a_mac_out[24]     ) = (0,0);
(a_diny[1]    =>   a_mac_out[24]     ) = (0,0);
(a_diny[2]    =>   a_mac_out[24]     ) = (0,0);
(a_diny[3]    =>   a_mac_out[24]     ) = (0,0);
(a_diny[4]    =>   a_mac_out[24]     ) = (0,0);
(a_diny[5]    =>   a_mac_out[24]     ) = (0,0);
(a_diny[6]    =>   a_mac_out[24]     ) = (0,0);
(a_diny[7]    =>   a_mac_out[24]     ) = (0,0);
(a_diny[8]    =>   a_mac_out[24]     ) = (0,0);
(a_diny[9]    =>   a_mac_out[24]     ) = (0,0);
(b_diny[0]    =>   a_mac_out[24]     ) = (0,0);
(b_diny[1]    =>   a_mac_out[24]     ) = (0,0);
(b_diny[2]    =>   a_mac_out[24]     ) = (0,0);
(b_diny[3]    =>   a_mac_out[24]     ) = (0,0);
(b_diny[4]    =>   a_mac_out[24]     ) = (0,0);
(b_diny[5]    =>   a_mac_out[24]     ) = (0,0);
(b_diny[6]    =>   a_mac_out[24]     ) = (0,0);
(b_diny[7]    =>   a_mac_out[24]     ) = (0,0);
(b_diny[8]    =>   a_mac_out[24]     ) = (0,0);
(b_diny[9]    =>   a_mac_out[24]     ) = (0,0);
(a_dinz[0]    =>   a_mac_out[24]     ) = (0,0);
(a_dinz[1]    =>   a_mac_out[24]     ) = (0,0);
(a_dinz[2]    =>   a_mac_out[24]     ) = (0,0);
(a_dinz[3]    =>   a_mac_out[24]     ) = (0,0);
(a_dinz[4]    =>   a_mac_out[24]     ) = (0,0);
(a_dinz[5]    =>   a_mac_out[24]     ) = (0,0);
(a_dinz[6]    =>   a_mac_out[24]     ) = (0,0);
(a_dinz[7]    =>   a_mac_out[24]     ) = (0,0);
(a_dinz[8]    =>   a_mac_out[24]     ) = (0,0);
(a_dinz[9]    =>   a_mac_out[24]     ) = (0,0);
(a_dinz[10]   =>   a_mac_out[24]     ) = (0,0);
(a_dinz[11]   =>   a_mac_out[24]     ) = (0,0);
(a_dinz[12]   =>   a_mac_out[24]     ) = (0,0);
(a_dinz[13]   =>   a_mac_out[24]     ) = (0,0);
(a_dinz[14]   =>   a_mac_out[24]     ) = (0,0);
(a_dinz[15]   =>   a_mac_out[24]     ) = (0,0);
(a_dinz[16]   =>   a_mac_out[24]     ) = (0,0);
(a_dinz[17]   =>   a_mac_out[24]     ) = (0,0);
(a_dinz[18]   =>   a_mac_out[24]     ) = (0,0);
(a_dinz[19]   =>   a_mac_out[24]     ) = (0,0);
(a_dinz[20]   =>   a_mac_out[24]     ) = (0,0);
(a_dinz[21]   =>   a_mac_out[24]     ) = (0,0);
(a_dinz[22]   =>   a_mac_out[24]     ) = (0,0);
(a_dinz[23]   =>   a_mac_out[24]     ) = (0,0);
(a_dinz[24]   =>   a_mac_out[24]     ) = (0,0);
(b_dinz[0]    =>   a_mac_out[24]     ) = (0,0);
(b_dinz[1]    =>   a_mac_out[24]     ) = (0,0);
(b_dinz[2]    =>   a_mac_out[24]     ) = (0,0);
(b_dinz[3]    =>   a_mac_out[24]     ) = (0,0);
(b_dinz[4]    =>   a_mac_out[24]     ) = (0,0);
(b_dinz[5]    =>   a_mac_out[24]     ) = (0,0);
(b_dinz[6]    =>   a_mac_out[24]     ) = (0,0);
(a_dinz_en    =>   a_mac_out[24]     ) = (0,0);
(a_dinx[0]    =>   b_mac_out[0]      ) = (0,0);
(a_dinx[1]    =>   b_mac_out[0]      ) = (0,0);
(a_dinx[2]    =>   b_mac_out[0]      ) = (0,0);
(a_dinx[3]    =>   b_mac_out[0]      ) = (0,0);
(a_dinx[4]    =>   b_mac_out[0]      ) = (0,0);
(a_dinx[5]    =>   b_mac_out[0]      ) = (0,0);
(a_dinx[6]    =>   b_mac_out[0]      ) = (0,0);
(a_dinx[7]    =>   b_mac_out[0]      ) = (0,0);
(a_dinx[8]    =>   b_mac_out[0]      ) = (0,0);
(a_dinx[9]    =>   b_mac_out[0]      ) = (0,0);
(a_dinx[10]   =>   b_mac_out[0]      ) = (0,0);
(a_dinx[11]   =>   b_mac_out[0]      ) = (0,0);
(a_dinx[12]   =>   b_mac_out[0]      ) = (0,0);
(b_dinx[0]    =>   b_mac_out[0]      ) = (0,0);
(b_dinx[1]    =>   b_mac_out[0]      ) = (0,0);
(b_dinx[2]    =>   b_mac_out[0]      ) = (0,0);
(b_dinx[3]    =>   b_mac_out[0]      ) = (0,0);
(b_dinx[4]    =>   b_mac_out[0]      ) = (0,0);
(b_dinx[5]    =>   b_mac_out[0]      ) = (0,0);
(b_dinx[6]    =>   b_mac_out[0]      ) = (0,0);
(b_dinx[7]    =>   b_mac_out[0]      ) = (0,0);
(b_dinx[8]    =>   b_mac_out[0]      ) = (0,0);
(b_dinx[9]    =>   b_mac_out[0]      ) = (0,0);
(b_dinx[10]   =>   b_mac_out[0]      ) = (0,0);
(b_dinx[11]   =>   b_mac_out[0]      ) = (0,0);
(b_dinx[12]   =>   b_mac_out[0]      ) = (0,0);
(a_diny[0]    =>   b_mac_out[0]      ) = (0,0);
(a_diny[1]    =>   b_mac_out[0]      ) = (0,0);
(a_diny[2]    =>   b_mac_out[0]      ) = (0,0);
(a_diny[3]    =>   b_mac_out[0]      ) = (0,0);
(a_diny[4]    =>   b_mac_out[0]      ) = (0,0);
(a_diny[5]    =>   b_mac_out[0]      ) = (0,0);
(a_diny[6]    =>   b_mac_out[0]      ) = (0,0);
(a_diny[7]    =>   b_mac_out[0]      ) = (0,0);
(a_diny[8]    =>   b_mac_out[0]      ) = (0,0);
(a_diny[9]    =>   b_mac_out[0]      ) = (0,0);
(b_diny[0]    =>   b_mac_out[0]      ) = (0,0);
(b_diny[1]    =>   b_mac_out[0]      ) = (0,0);
(b_diny[2]    =>   b_mac_out[0]      ) = (0,0);
(b_diny[3]    =>   b_mac_out[0]      ) = (0,0);
(b_diny[4]    =>   b_mac_out[0]      ) = (0,0);
(b_diny[5]    =>   b_mac_out[0]      ) = (0,0);
(b_diny[6]    =>   b_mac_out[0]      ) = (0,0);
(b_diny[7]    =>   b_mac_out[0]      ) = (0,0);
(b_diny[8]    =>   b_mac_out[0]      ) = (0,0);
(b_diny[9]    =>   b_mac_out[0]      ) = (0,0);
(a_dinz[0]    =>   b_mac_out[0]      ) = (0,0);
(a_dinz[1]    =>   b_mac_out[0]      ) = (0,0);
(a_dinz[2]    =>   b_mac_out[0]      ) = (0,0);
(a_dinz[3]    =>   b_mac_out[0]      ) = (0,0);
(a_dinz[4]    =>   b_mac_out[0]      ) = (0,0);
(a_dinz[5]    =>   b_mac_out[0]      ) = (0,0);
(a_dinz[6]    =>   b_mac_out[0]      ) = (0,0);
(a_dinz[7]    =>   b_mac_out[0]      ) = (0,0);
(a_dinz[8]    =>   b_mac_out[0]      ) = (0,0);
(a_dinz[9]    =>   b_mac_out[0]      ) = (0,0);
(a_dinz[10]   =>   b_mac_out[0]      ) = (0,0);
(a_dinz[11]   =>   b_mac_out[0]      ) = (0,0);
(a_dinz[12]   =>   b_mac_out[0]      ) = (0,0);
(a_dinz[13]   =>   b_mac_out[0]      ) = (0,0);
(a_dinz[14]   =>   b_mac_out[0]      ) = (0,0);
(a_dinz[15]   =>   b_mac_out[0]      ) = (0,0);
(a_dinz[16]   =>   b_mac_out[0]      ) = (0,0);
(a_dinz[17]   =>   b_mac_out[0]      ) = (0,0);
(a_dinz[18]   =>   b_mac_out[0]      ) = (0,0);
(a_dinz[19]   =>   b_mac_out[0]      ) = (0,0);
(a_dinz[20]   =>   b_mac_out[0]      ) = (0,0);
(a_dinz[21]   =>   b_mac_out[0]      ) = (0,0);
(a_dinz[22]   =>   b_mac_out[0]      ) = (0,0);
(a_dinz[23]   =>   b_mac_out[0]      ) = (0,0);
(b_dinz[0]    =>   b_mac_out[0]      ) = (0,0);
(b_dinz[1]    =>   b_mac_out[0]      ) = (0,0);
(b_dinz[2]    =>   b_mac_out[0]      ) = (0,0);
(b_dinz[3]    =>   b_mac_out[0]      ) = (0,0);
(a_dinz_en    =>   b_mac_out[0]      ) = (0,0);
(b_dinz_en    =>   b_mac_out[0]      ) = (0,0);
(a_dinx[0]    =>   b_mac_out[1]      ) = (0,0);
(a_dinx[1]    =>   b_mac_out[1]      ) = (0,0);
(a_dinx[2]    =>   b_mac_out[1]      ) = (0,0);
(a_dinx[3]    =>   b_mac_out[1]      ) = (0,0);
(a_dinx[4]    =>   b_mac_out[1]      ) = (0,0);
(a_dinx[5]    =>   b_mac_out[1]      ) = (0,0);
(a_dinx[6]    =>   b_mac_out[1]      ) = (0,0);
(a_dinx[7]    =>   b_mac_out[1]      ) = (0,0);
(a_dinx[8]    =>   b_mac_out[1]      ) = (0,0);
(a_dinx[9]    =>   b_mac_out[1]      ) = (0,0);
(a_dinx[10]   =>   b_mac_out[1]      ) = (0,0);
(a_dinx[11]   =>   b_mac_out[1]      ) = (0,0);
(a_dinx[12]   =>   b_mac_out[1]      ) = (0,0);
(b_dinx[0]    =>   b_mac_out[1]      ) = (0,0);
(b_dinx[1]    =>   b_mac_out[1]      ) = (0,0);
(b_dinx[2]    =>   b_mac_out[1]      ) = (0,0);
(b_dinx[3]    =>   b_mac_out[1]      ) = (0,0);
(b_dinx[4]    =>   b_mac_out[1]      ) = (0,0);
(b_dinx[5]    =>   b_mac_out[1]      ) = (0,0);
(b_dinx[6]    =>   b_mac_out[1]      ) = (0,0);
(b_dinx[7]    =>   b_mac_out[1]      ) = (0,0);
(b_dinx[8]    =>   b_mac_out[1]      ) = (0,0);
(b_dinx[9]    =>   b_mac_out[1]      ) = (0,0);
(b_dinx[10]   =>   b_mac_out[1]      ) = (0,0);
(b_dinx[11]   =>   b_mac_out[1]      ) = (0,0);
(b_dinx[12]   =>   b_mac_out[1]      ) = (0,0);
(a_diny[0]    =>   b_mac_out[1]      ) = (0,0);
(a_diny[1]    =>   b_mac_out[1]      ) = (0,0);
(a_diny[2]    =>   b_mac_out[1]      ) = (0,0);
(a_diny[3]    =>   b_mac_out[1]      ) = (0,0);
(a_diny[4]    =>   b_mac_out[1]      ) = (0,0);
(a_diny[5]    =>   b_mac_out[1]      ) = (0,0);
(a_diny[6]    =>   b_mac_out[1]      ) = (0,0);
(a_diny[7]    =>   b_mac_out[1]      ) = (0,0);
(a_diny[8]    =>   b_mac_out[1]      ) = (0,0);
(a_diny[9]    =>   b_mac_out[1]      ) = (0,0);
(b_diny[0]    =>   b_mac_out[1]      ) = (0,0);
(b_diny[1]    =>   b_mac_out[1]      ) = (0,0);
(b_diny[2]    =>   b_mac_out[1]      ) = (0,0);
(b_diny[3]    =>   b_mac_out[1]      ) = (0,0);
(b_diny[4]    =>   b_mac_out[1]      ) = (0,0);
(b_diny[5]    =>   b_mac_out[1]      ) = (0,0);
(b_diny[6]    =>   b_mac_out[1]      ) = (0,0);
(b_diny[7]    =>   b_mac_out[1]      ) = (0,0);
(b_diny[8]    =>   b_mac_out[1]      ) = (0,0);
(b_diny[9]    =>   b_mac_out[1]      ) = (0,0);
(a_dinz[0]    =>   b_mac_out[1]      ) = (0,0);
(a_dinz[1]    =>   b_mac_out[1]      ) = (0,0);
(a_dinz[2]    =>   b_mac_out[1]      ) = (0,0);
(a_dinz[3]    =>   b_mac_out[1]      ) = (0,0);
(a_dinz[4]    =>   b_mac_out[1]      ) = (0,0);
(a_dinz[5]    =>   b_mac_out[1]      ) = (0,0);
(a_dinz[6]    =>   b_mac_out[1]      ) = (0,0);
(a_dinz[7]    =>   b_mac_out[1]      ) = (0,0);
(a_dinz[8]    =>   b_mac_out[1]      ) = (0,0);
(a_dinz[9]    =>   b_mac_out[1]      ) = (0,0);
(a_dinz[10]   =>   b_mac_out[1]      ) = (0,0);
(a_dinz[11]   =>   b_mac_out[1]      ) = (0,0);
(a_dinz[12]   =>   b_mac_out[1]      ) = (0,0);
(a_dinz[13]   =>   b_mac_out[1]      ) = (0,0);
(a_dinz[14]   =>   b_mac_out[1]      ) = (0,0);
(a_dinz[15]   =>   b_mac_out[1]      ) = (0,0);
(a_dinz[16]   =>   b_mac_out[1]      ) = (0,0);
(a_dinz[17]   =>   b_mac_out[1]      ) = (0,0);
(a_dinz[18]   =>   b_mac_out[1]      ) = (0,0);
(a_dinz[19]   =>   b_mac_out[1]      ) = (0,0);
(a_dinz[20]   =>   b_mac_out[1]      ) = (0,0);
(a_dinz[21]   =>   b_mac_out[1]      ) = (0,0);
(a_dinz[22]   =>   b_mac_out[1]      ) = (0,0);
(a_dinz[23]   =>   b_mac_out[1]      ) = (0,0);
(b_dinz[0]    =>   b_mac_out[1]      ) = (0,0);
(b_dinz[1]    =>   b_mac_out[1]      ) = (0,0);
(b_dinz[2]    =>   b_mac_out[1]      ) = (0,0);
(b_dinz[3]    =>   b_mac_out[1]      ) = (0,0);
(b_dinz[4]    =>   b_mac_out[1]      ) = (0,0);
(a_dinz_en    =>   b_mac_out[1]      ) = (0,0);
(b_dinz_en    =>   b_mac_out[1]      ) = (0,0);
(a_dinx[0]    =>   b_mac_out[2]      ) = (0,0);
(a_dinx[1]    =>   b_mac_out[2]      ) = (0,0);
(a_dinx[2]    =>   b_mac_out[2]      ) = (0,0);
(a_dinx[3]    =>   b_mac_out[2]      ) = (0,0);
(a_dinx[4]    =>   b_mac_out[2]      ) = (0,0);
(a_dinx[5]    =>   b_mac_out[2]      ) = (0,0);
(a_dinx[6]    =>   b_mac_out[2]      ) = (0,0);
(a_dinx[7]    =>   b_mac_out[2]      ) = (0,0);
(a_dinx[8]    =>   b_mac_out[2]      ) = (0,0);
(a_dinx[9]    =>   b_mac_out[2]      ) = (0,0);
(a_dinx[10]   =>   b_mac_out[2]      ) = (0,0);
(a_dinx[11]   =>   b_mac_out[2]      ) = (0,0);
(a_dinx[12]   =>   b_mac_out[2]      ) = (0,0);
(b_dinx[0]    =>   b_mac_out[2]      ) = (0,0);
(b_dinx[1]    =>   b_mac_out[2]      ) = (0,0);
(b_dinx[2]    =>   b_mac_out[2]      ) = (0,0);
(b_dinx[3]    =>   b_mac_out[2]      ) = (0,0);
(b_dinx[4]    =>   b_mac_out[2]      ) = (0,0);
(b_dinx[5]    =>   b_mac_out[2]      ) = (0,0);
(b_dinx[6]    =>   b_mac_out[2]      ) = (0,0);
(b_dinx[7]    =>   b_mac_out[2]      ) = (0,0);
(b_dinx[8]    =>   b_mac_out[2]      ) = (0,0);
(b_dinx[9]    =>   b_mac_out[2]      ) = (0,0);
(b_dinx[10]   =>   b_mac_out[2]      ) = (0,0);
(b_dinx[11]   =>   b_mac_out[2]      ) = (0,0);
(b_dinx[12]   =>   b_mac_out[2]      ) = (0,0);
(a_diny[0]    =>   b_mac_out[2]      ) = (0,0);
(a_diny[1]    =>   b_mac_out[2]      ) = (0,0);
(a_diny[2]    =>   b_mac_out[2]      ) = (0,0);
(a_diny[3]    =>   b_mac_out[2]      ) = (0,0);
(a_diny[4]    =>   b_mac_out[2]      ) = (0,0);
(a_diny[5]    =>   b_mac_out[2]      ) = (0,0);
(a_diny[6]    =>   b_mac_out[2]      ) = (0,0);
(a_diny[7]    =>   b_mac_out[2]      ) = (0,0);
(a_diny[8]    =>   b_mac_out[2]      ) = (0,0);
(a_diny[9]    =>   b_mac_out[2]      ) = (0,0);
(b_diny[0]    =>   b_mac_out[2]      ) = (0,0);
(b_diny[1]    =>   b_mac_out[2]      ) = (0,0);
(b_diny[2]    =>   b_mac_out[2]      ) = (0,0);
(b_diny[3]    =>   b_mac_out[2]      ) = (0,0);
(b_diny[4]    =>   b_mac_out[2]      ) = (0,0);
(b_diny[5]    =>   b_mac_out[2]      ) = (0,0);
(b_diny[6]    =>   b_mac_out[2]      ) = (0,0);
(b_diny[7]    =>   b_mac_out[2]      ) = (0,0);
(b_diny[8]    =>   b_mac_out[2]      ) = (0,0);
(b_diny[9]    =>   b_mac_out[2]      ) = (0,0);
(a_dinz[0]    =>   b_mac_out[2]      ) = (0,0);
(a_dinz[1]    =>   b_mac_out[2]      ) = (0,0);
(a_dinz[2]    =>   b_mac_out[2]      ) = (0,0);
(a_dinz[3]    =>   b_mac_out[2]      ) = (0,0);
(a_dinz[4]    =>   b_mac_out[2]      ) = (0,0);
(a_dinz[5]    =>   b_mac_out[2]      ) = (0,0);
(a_dinz[6]    =>   b_mac_out[2]      ) = (0,0);
(a_dinz[7]    =>   b_mac_out[2]      ) = (0,0);
(a_dinz[8]    =>   b_mac_out[2]      ) = (0,0);
(a_dinz[9]    =>   b_mac_out[2]      ) = (0,0);
(a_dinz[10]   =>   b_mac_out[2]      ) = (0,0);
(a_dinz[11]   =>   b_mac_out[2]      ) = (0,0);
(a_dinz[12]   =>   b_mac_out[2]      ) = (0,0);
(a_dinz[13]   =>   b_mac_out[2]      ) = (0,0);
(a_dinz[14]   =>   b_mac_out[2]      ) = (0,0);
(a_dinz[15]   =>   b_mac_out[2]      ) = (0,0);
(a_dinz[16]   =>   b_mac_out[2]      ) = (0,0);
(a_dinz[17]   =>   b_mac_out[2]      ) = (0,0);
(a_dinz[18]   =>   b_mac_out[2]      ) = (0,0);
(a_dinz[19]   =>   b_mac_out[2]      ) = (0,0);
(a_dinz[20]   =>   b_mac_out[2]      ) = (0,0);
(a_dinz[21]   =>   b_mac_out[2]      ) = (0,0);
(a_dinz[22]   =>   b_mac_out[2]      ) = (0,0);
(a_dinz[23]   =>   b_mac_out[2]      ) = (0,0);
(b_dinz[0]    =>   b_mac_out[2]      ) = (0,0);
(b_dinz[1]    =>   b_mac_out[2]      ) = (0,0);
(b_dinz[2]    =>   b_mac_out[2]      ) = (0,0);
(b_dinz[3]    =>   b_mac_out[2]      ) = (0,0);
(b_dinz[4]    =>   b_mac_out[2]      ) = (0,0);
(b_dinz[5]    =>   b_mac_out[2]      ) = (0,0);
(a_dinz_en    =>   b_mac_out[2]      ) = (0,0);
(b_dinz_en    =>   b_mac_out[2]      ) = (0,0);
(a_dinx[0]    =>   b_mac_out[3]      ) = (0,0);
(a_dinx[1]    =>   b_mac_out[3]      ) = (0,0);
(a_dinx[2]    =>   b_mac_out[3]      ) = (0,0);
(a_dinx[3]    =>   b_mac_out[3]      ) = (0,0);
(a_dinx[4]    =>   b_mac_out[3]      ) = (0,0);
(a_dinx[5]    =>   b_mac_out[3]      ) = (0,0);
(a_dinx[6]    =>   b_mac_out[3]      ) = (0,0);
(a_dinx[7]    =>   b_mac_out[3]      ) = (0,0);
(a_dinx[8]    =>   b_mac_out[3]      ) = (0,0);
(a_dinx[9]    =>   b_mac_out[3]      ) = (0,0);
(a_dinx[10]   =>   b_mac_out[3]      ) = (0,0);
(a_dinx[11]   =>   b_mac_out[3]      ) = (0,0);
(a_dinx[12]   =>   b_mac_out[3]      ) = (0,0);
(b_dinx[0]    =>   b_mac_out[3]      ) = (0,0);
(b_dinx[1]    =>   b_mac_out[3]      ) = (0,0);
(b_dinx[2]    =>   b_mac_out[3]      ) = (0,0);
(b_dinx[3]    =>   b_mac_out[3]      ) = (0,0);
(b_dinx[4]    =>   b_mac_out[3]      ) = (0,0);
(b_dinx[5]    =>   b_mac_out[3]      ) = (0,0);
(b_dinx[6]    =>   b_mac_out[3]      ) = (0,0);
(b_dinx[7]    =>   b_mac_out[3]      ) = (0,0);
(b_dinx[8]    =>   b_mac_out[3]      ) = (0,0);
(b_dinx[9]    =>   b_mac_out[3]      ) = (0,0);
(b_dinx[10]   =>   b_mac_out[3]      ) = (0,0);
(b_dinx[11]   =>   b_mac_out[3]      ) = (0,0);
(b_dinx[12]   =>   b_mac_out[3]      ) = (0,0);
(a_diny[0]    =>   b_mac_out[3]      ) = (0,0);
(a_diny[1]    =>   b_mac_out[3]      ) = (0,0);
(a_diny[2]    =>   b_mac_out[3]      ) = (0,0);
(a_diny[3]    =>   b_mac_out[3]      ) = (0,0);
(a_diny[4]    =>   b_mac_out[3]      ) = (0,0);
(a_diny[5]    =>   b_mac_out[3]      ) = (0,0);
(a_diny[6]    =>   b_mac_out[3]      ) = (0,0);
(a_diny[7]    =>   b_mac_out[3]      ) = (0,0);
(a_diny[8]    =>   b_mac_out[3]      ) = (0,0);
(a_diny[9]    =>   b_mac_out[3]      ) = (0,0);
(b_diny[0]    =>   b_mac_out[3]      ) = (0,0);
(b_diny[1]    =>   b_mac_out[3]      ) = (0,0);
(b_diny[2]    =>   b_mac_out[3]      ) = (0,0);
(b_diny[3]    =>   b_mac_out[3]      ) = (0,0);
(b_diny[4]    =>   b_mac_out[3]      ) = (0,0);
(b_diny[5]    =>   b_mac_out[3]      ) = (0,0);
(b_diny[6]    =>   b_mac_out[3]      ) = (0,0);
(b_diny[7]    =>   b_mac_out[3]      ) = (0,0);
(b_diny[8]    =>   b_mac_out[3]      ) = (0,0);
(b_diny[9]    =>   b_mac_out[3]      ) = (0,0);
(a_dinz[0]    =>   b_mac_out[3]      ) = (0,0);
(a_dinz[1]    =>   b_mac_out[3]      ) = (0,0);
(a_dinz[2]    =>   b_mac_out[3]      ) = (0,0);
(a_dinz[3]    =>   b_mac_out[3]      ) = (0,0);
(a_dinz[4]    =>   b_mac_out[3]      ) = (0,0);
(a_dinz[5]    =>   b_mac_out[3]      ) = (0,0);
(a_dinz[6]    =>   b_mac_out[3]      ) = (0,0);
(a_dinz[7]    =>   b_mac_out[3]      ) = (0,0);
(a_dinz[8]    =>   b_mac_out[3]      ) = (0,0);
(a_dinz[9]    =>   b_mac_out[3]      ) = (0,0);
(a_dinz[10]   =>   b_mac_out[3]      ) = (0,0);
(a_dinz[11]   =>   b_mac_out[3]      ) = (0,0);
(a_dinz[12]   =>   b_mac_out[3]      ) = (0,0);
(a_dinz[13]   =>   b_mac_out[3]      ) = (0,0);
(a_dinz[14]   =>   b_mac_out[3]      ) = (0,0);
(a_dinz[15]   =>   b_mac_out[3]      ) = (0,0);
(a_dinz[16]   =>   b_mac_out[3]      ) = (0,0);
(a_dinz[17]   =>   b_mac_out[3]      ) = (0,0);
(a_dinz[18]   =>   b_mac_out[3]      ) = (0,0);
(a_dinz[19]   =>   b_mac_out[3]      ) = (0,0);
(a_dinz[20]   =>   b_mac_out[3]      ) = (0,0);
(a_dinz[21]   =>   b_mac_out[3]      ) = (0,0);
(a_dinz[22]   =>   b_mac_out[3]      ) = (0,0);
(a_dinz[23]   =>   b_mac_out[3]      ) = (0,0);
(b_dinz[0]    =>   b_mac_out[3]      ) = (0,0);
(b_dinz[1]    =>   b_mac_out[3]      ) = (0,0);
(b_dinz[2]    =>   b_mac_out[3]      ) = (0,0);
(b_dinz[3]    =>   b_mac_out[3]      ) = (0,0);
(b_dinz[4]    =>   b_mac_out[3]      ) = (0,0);
(b_dinz[5]    =>   b_mac_out[3]      ) = (0,0);
(b_dinz[6]    =>   b_mac_out[3]      ) = (0,0);
(a_dinz_en    =>   b_mac_out[3]      ) = (0,0);
(b_dinz_en    =>   b_mac_out[3]      ) = (0,0);
(a_dinx[0]    =>   b_mac_out[4]      ) = (0,0);
(a_dinx[1]    =>   b_mac_out[4]      ) = (0,0);
(a_dinx[2]    =>   b_mac_out[4]      ) = (0,0);
(a_dinx[3]    =>   b_mac_out[4]      ) = (0,0);
(a_dinx[4]    =>   b_mac_out[4]      ) = (0,0);
(a_dinx[5]    =>   b_mac_out[4]      ) = (0,0);
(a_dinx[6]    =>   b_mac_out[4]      ) = (0,0);
(a_dinx[7]    =>   b_mac_out[4]      ) = (0,0);
(a_dinx[8]    =>   b_mac_out[4]      ) = (0,0);
(a_dinx[9]    =>   b_mac_out[4]      ) = (0,0);
(a_dinx[10]   =>   b_mac_out[4]      ) = (0,0);
(a_dinx[11]   =>   b_mac_out[4]      ) = (0,0);
(a_dinx[12]   =>   b_mac_out[4]      ) = (0,0);
(b_dinx[0]    =>   b_mac_out[4]      ) = (0,0);
(b_dinx[1]    =>   b_mac_out[4]      ) = (0,0);
(b_dinx[2]    =>   b_mac_out[4]      ) = (0,0);
(b_dinx[3]    =>   b_mac_out[4]      ) = (0,0);
(b_dinx[4]    =>   b_mac_out[4]      ) = (0,0);
(b_dinx[5]    =>   b_mac_out[4]      ) = (0,0);
(b_dinx[6]    =>   b_mac_out[4]      ) = (0,0);
(b_dinx[7]    =>   b_mac_out[4]      ) = (0,0);
(b_dinx[8]    =>   b_mac_out[4]      ) = (0,0);
(b_dinx[9]    =>   b_mac_out[4]      ) = (0,0);
(b_dinx[10]   =>   b_mac_out[4]      ) = (0,0);
(b_dinx[11]   =>   b_mac_out[4]      ) = (0,0);
(b_dinx[12]   =>   b_mac_out[4]      ) = (0,0);
(a_diny[0]    =>   b_mac_out[4]      ) = (0,0);
(a_diny[1]    =>   b_mac_out[4]      ) = (0,0);
(a_diny[2]    =>   b_mac_out[4]      ) = (0,0);
(a_diny[3]    =>   b_mac_out[4]      ) = (0,0);
(a_diny[4]    =>   b_mac_out[4]      ) = (0,0);
(a_diny[5]    =>   b_mac_out[4]      ) = (0,0);
(a_diny[6]    =>   b_mac_out[4]      ) = (0,0);
(a_diny[7]    =>   b_mac_out[4]      ) = (0,0);
(a_diny[8]    =>   b_mac_out[4]      ) = (0,0);
(a_diny[9]    =>   b_mac_out[4]      ) = (0,0);
(b_diny[0]    =>   b_mac_out[4]      ) = (0,0);
(b_diny[1]    =>   b_mac_out[4]      ) = (0,0);
(b_diny[2]    =>   b_mac_out[4]      ) = (0,0);
(b_diny[3]    =>   b_mac_out[4]      ) = (0,0);
(b_diny[4]    =>   b_mac_out[4]      ) = (0,0);
(b_diny[5]    =>   b_mac_out[4]      ) = (0,0);
(b_diny[6]    =>   b_mac_out[4]      ) = (0,0);
(b_diny[7]    =>   b_mac_out[4]      ) = (0,0);
(b_diny[8]    =>   b_mac_out[4]      ) = (0,0);
(b_diny[9]    =>   b_mac_out[4]      ) = (0,0);
(a_dinz[0]    =>   b_mac_out[4]      ) = (0,0);
(a_dinz[1]    =>   b_mac_out[4]      ) = (0,0);
(a_dinz[2]    =>   b_mac_out[4]      ) = (0,0);
(a_dinz[3]    =>   b_mac_out[4]      ) = (0,0);
(a_dinz[4]    =>   b_mac_out[4]      ) = (0,0);
(a_dinz[5]    =>   b_mac_out[4]      ) = (0,0);
(a_dinz[6]    =>   b_mac_out[4]      ) = (0,0);
(a_dinz[7]    =>   b_mac_out[4]      ) = (0,0);
(a_dinz[8]    =>   b_mac_out[4]      ) = (0,0);
(a_dinz[9]    =>   b_mac_out[4]      ) = (0,0);
(a_dinz[10]   =>   b_mac_out[4]      ) = (0,0);
(a_dinz[11]   =>   b_mac_out[4]      ) = (0,0);
(a_dinz[12]   =>   b_mac_out[4]      ) = (0,0);
(a_dinz[13]   =>   b_mac_out[4]      ) = (0,0);
(a_dinz[14]   =>   b_mac_out[4]      ) = (0,0);
(a_dinz[15]   =>   b_mac_out[4]      ) = (0,0);
(a_dinz[16]   =>   b_mac_out[4]      ) = (0,0);
(a_dinz[17]   =>   b_mac_out[4]      ) = (0,0);
(a_dinz[18]   =>   b_mac_out[4]      ) = (0,0);
(a_dinz[19]   =>   b_mac_out[4]      ) = (0,0);
(a_dinz[20]   =>   b_mac_out[4]      ) = (0,0);
(a_dinz[21]   =>   b_mac_out[4]      ) = (0,0);
(a_dinz[22]   =>   b_mac_out[4]      ) = (0,0);
(a_dinz[23]   =>   b_mac_out[4]      ) = (0,0);
(b_dinz[0]    =>   b_mac_out[4]      ) = (0,0);
(b_dinz[1]    =>   b_mac_out[4]      ) = (0,0);
(b_dinz[2]    =>   b_mac_out[4]      ) = (0,0);
(b_dinz[3]    =>   b_mac_out[4]      ) = (0,0);
(b_dinz[4]    =>   b_mac_out[4]      ) = (0,0);
(b_dinz[5]    =>   b_mac_out[4]      ) = (0,0);
(b_dinz[6]    =>   b_mac_out[4]      ) = (0,0);
(b_dinz[7]    =>   b_mac_out[4]      ) = (0,0);
(a_dinz_en    =>   b_mac_out[4]      ) = (0,0);
(b_dinz_en    =>   b_mac_out[4]      ) = (0,0);
(a_dinx[0]    =>   b_mac_out[5]      ) = (0,0);
(a_dinx[1]    =>   b_mac_out[5]      ) = (0,0);
(a_dinx[2]    =>   b_mac_out[5]      ) = (0,0);
(a_dinx[3]    =>   b_mac_out[5]      ) = (0,0);
(a_dinx[4]    =>   b_mac_out[5]      ) = (0,0);
(a_dinx[5]    =>   b_mac_out[5]      ) = (0,0);
(a_dinx[6]    =>   b_mac_out[5]      ) = (0,0);
(a_dinx[7]    =>   b_mac_out[5]      ) = (0,0);
(a_dinx[8]    =>   b_mac_out[5]      ) = (0,0);
(a_dinx[9]    =>   b_mac_out[5]      ) = (0,0);
(a_dinx[10]   =>   b_mac_out[5]      ) = (0,0);
(a_dinx[11]   =>   b_mac_out[5]      ) = (0,0);
(a_dinx[12]   =>   b_mac_out[5]      ) = (0,0);
(b_dinx[0]    =>   b_mac_out[5]      ) = (0,0);
(b_dinx[1]    =>   b_mac_out[5]      ) = (0,0);
(b_dinx[2]    =>   b_mac_out[5]      ) = (0,0);
(b_dinx[3]    =>   b_mac_out[5]      ) = (0,0);
(b_dinx[4]    =>   b_mac_out[5]      ) = (0,0);
(b_dinx[5]    =>   b_mac_out[5]      ) = (0,0);
(b_dinx[6]    =>   b_mac_out[5]      ) = (0,0);
(b_dinx[7]    =>   b_mac_out[5]      ) = (0,0);
(b_dinx[8]    =>   b_mac_out[5]      ) = (0,0);
(b_dinx[9]    =>   b_mac_out[5]      ) = (0,0);
(b_dinx[10]   =>   b_mac_out[5]      ) = (0,0);
(b_dinx[11]   =>   b_mac_out[5]      ) = (0,0);
(b_dinx[12]   =>   b_mac_out[5]      ) = (0,0);
(a_diny[0]    =>   b_mac_out[5]      ) = (0,0);
(a_diny[1]    =>   b_mac_out[5]      ) = (0,0);
(a_diny[2]    =>   b_mac_out[5]      ) = (0,0);
(a_diny[3]    =>   b_mac_out[5]      ) = (0,0);
(a_diny[4]    =>   b_mac_out[5]      ) = (0,0);
(a_diny[5]    =>   b_mac_out[5]      ) = (0,0);
(a_diny[6]    =>   b_mac_out[5]      ) = (0,0);
(a_diny[7]    =>   b_mac_out[5]      ) = (0,0);
(a_diny[8]    =>   b_mac_out[5]      ) = (0,0);
(a_diny[9]    =>   b_mac_out[5]      ) = (0,0);
(b_diny[0]    =>   b_mac_out[5]      ) = (0,0);
(b_diny[1]    =>   b_mac_out[5]      ) = (0,0);
(b_diny[2]    =>   b_mac_out[5]      ) = (0,0);
(b_diny[3]    =>   b_mac_out[5]      ) = (0,0);
(b_diny[4]    =>   b_mac_out[5]      ) = (0,0);
(b_diny[5]    =>   b_mac_out[5]      ) = (0,0);
(b_diny[6]    =>   b_mac_out[5]      ) = (0,0);
(b_diny[7]    =>   b_mac_out[5]      ) = (0,0);
(b_diny[8]    =>   b_mac_out[5]      ) = (0,0);
(b_diny[9]    =>   b_mac_out[5]      ) = (0,0);
(a_dinz[0]    =>   b_mac_out[5]      ) = (0,0);
(a_dinz[1]    =>   b_mac_out[5]      ) = (0,0);
(a_dinz[2]    =>   b_mac_out[5]      ) = (0,0);
(a_dinz[3]    =>   b_mac_out[5]      ) = (0,0);
(a_dinz[4]    =>   b_mac_out[5]      ) = (0,0);
(a_dinz[5]    =>   b_mac_out[5]      ) = (0,0);
(a_dinz[6]    =>   b_mac_out[5]      ) = (0,0);
(a_dinz[7]    =>   b_mac_out[5]      ) = (0,0);
(a_dinz[8]    =>   b_mac_out[5]      ) = (0,0);
(a_dinz[9]    =>   b_mac_out[5]      ) = (0,0);
(a_dinz[10]   =>   b_mac_out[5]      ) = (0,0);
(a_dinz[11]   =>   b_mac_out[5]      ) = (0,0);
(a_dinz[12]   =>   b_mac_out[5]      ) = (0,0);
(a_dinz[13]   =>   b_mac_out[5]      ) = (0,0);
(a_dinz[14]   =>   b_mac_out[5]      ) = (0,0);
(a_dinz[15]   =>   b_mac_out[5]      ) = (0,0);
(a_dinz[16]   =>   b_mac_out[5]      ) = (0,0);
(a_dinz[17]   =>   b_mac_out[5]      ) = (0,0);
(a_dinz[18]   =>   b_mac_out[5]      ) = (0,0);
(a_dinz[19]   =>   b_mac_out[5]      ) = (0,0);
(a_dinz[20]   =>   b_mac_out[5]      ) = (0,0);
(a_dinz[21]   =>   b_mac_out[5]      ) = (0,0);
(a_dinz[22]   =>   b_mac_out[5]      ) = (0,0);
(a_dinz[23]   =>   b_mac_out[5]      ) = (0,0);
(b_dinz[0]    =>   b_mac_out[5]      ) = (0,0);
(b_dinz[1]    =>   b_mac_out[5]      ) = (0,0);
(b_dinz[2]    =>   b_mac_out[5]      ) = (0,0);
(b_dinz[3]    =>   b_mac_out[5]      ) = (0,0);
(b_dinz[4]    =>   b_mac_out[5]      ) = (0,0);
(b_dinz[5]    =>   b_mac_out[5]      ) = (0,0);
(b_dinz[6]    =>   b_mac_out[5]      ) = (0,0);
(b_dinz[7]    =>   b_mac_out[5]      ) = (0,0);
(b_dinz[8]    =>   b_mac_out[5]      ) = (0,0);
(a_dinz_en    =>   b_mac_out[5]      ) = (0,0);
(b_dinz_en    =>   b_mac_out[5]      ) = (0,0);
(a_dinx[0]    =>   b_mac_out[6]      ) = (0,0);
(a_dinx[1]    =>   b_mac_out[6]      ) = (0,0);
(a_dinx[2]    =>   b_mac_out[6]      ) = (0,0);
(a_dinx[3]    =>   b_mac_out[6]      ) = (0,0);
(a_dinx[4]    =>   b_mac_out[6]      ) = (0,0);
(a_dinx[5]    =>   b_mac_out[6]      ) = (0,0);
(a_dinx[6]    =>   b_mac_out[6]      ) = (0,0);
(a_dinx[7]    =>   b_mac_out[6]      ) = (0,0);
(a_dinx[8]    =>   b_mac_out[6]      ) = (0,0);
(a_dinx[9]    =>   b_mac_out[6]      ) = (0,0);
(a_dinx[10]   =>   b_mac_out[6]      ) = (0,0);
(a_dinx[11]   =>   b_mac_out[6]      ) = (0,0);
(a_dinx[12]   =>   b_mac_out[6]      ) = (0,0);
(b_dinx[0]    =>   b_mac_out[6]      ) = (0,0);
(b_dinx[1]    =>   b_mac_out[6]      ) = (0,0);
(b_dinx[2]    =>   b_mac_out[6]      ) = (0,0);
(b_dinx[3]    =>   b_mac_out[6]      ) = (0,0);
(b_dinx[4]    =>   b_mac_out[6]      ) = (0,0);
(b_dinx[5]    =>   b_mac_out[6]      ) = (0,0);
(b_dinx[6]    =>   b_mac_out[6]      ) = (0,0);
(b_dinx[7]    =>   b_mac_out[6]      ) = (0,0);
(b_dinx[8]    =>   b_mac_out[6]      ) = (0,0);
(b_dinx[9]    =>   b_mac_out[6]      ) = (0,0);
(b_dinx[10]   =>   b_mac_out[6]      ) = (0,0);
(b_dinx[11]   =>   b_mac_out[6]      ) = (0,0);
(b_dinx[12]   =>   b_mac_out[6]      ) = (0,0);
(a_diny[0]    =>   b_mac_out[6]      ) = (0,0);
(a_diny[1]    =>   b_mac_out[6]      ) = (0,0);
(a_diny[2]    =>   b_mac_out[6]      ) = (0,0);
(a_diny[3]    =>   b_mac_out[6]      ) = (0,0);
(a_diny[4]    =>   b_mac_out[6]      ) = (0,0);
(a_diny[5]    =>   b_mac_out[6]      ) = (0,0);
(a_diny[6]    =>   b_mac_out[6]      ) = (0,0);
(a_diny[7]    =>   b_mac_out[6]      ) = (0,0);
(a_diny[8]    =>   b_mac_out[6]      ) = (0,0);
(a_diny[9]    =>   b_mac_out[6]      ) = (0,0);
(b_diny[0]    =>   b_mac_out[6]      ) = (0,0);
(b_diny[1]    =>   b_mac_out[6]      ) = (0,0);
(b_diny[2]    =>   b_mac_out[6]      ) = (0,0);
(b_diny[3]    =>   b_mac_out[6]      ) = (0,0);
(b_diny[4]    =>   b_mac_out[6]      ) = (0,0);
(b_diny[5]    =>   b_mac_out[6]      ) = (0,0);
(b_diny[6]    =>   b_mac_out[6]      ) = (0,0);
(b_diny[7]    =>   b_mac_out[6]      ) = (0,0);
(b_diny[8]    =>   b_mac_out[6]      ) = (0,0);
(b_diny[9]    =>   b_mac_out[6]      ) = (0,0);
(a_dinz[0]    =>   b_mac_out[6]      ) = (0,0);
(a_dinz[1]    =>   b_mac_out[6]      ) = (0,0);
(a_dinz[2]    =>   b_mac_out[6]      ) = (0,0);
(a_dinz[3]    =>   b_mac_out[6]      ) = (0,0);
(a_dinz[4]    =>   b_mac_out[6]      ) = (0,0);
(a_dinz[5]    =>   b_mac_out[6]      ) = (0,0);
(a_dinz[6]    =>   b_mac_out[6]      ) = (0,0);
(a_dinz[7]    =>   b_mac_out[6]      ) = (0,0);
(a_dinz[8]    =>   b_mac_out[6]      ) = (0,0);
(a_dinz[9]    =>   b_mac_out[6]      ) = (0,0);
(a_dinz[10]   =>   b_mac_out[6]      ) = (0,0);
(a_dinz[11]   =>   b_mac_out[6]      ) = (0,0);
(a_dinz[12]   =>   b_mac_out[6]      ) = (0,0);
(a_dinz[13]   =>   b_mac_out[6]      ) = (0,0);
(a_dinz[14]   =>   b_mac_out[6]      ) = (0,0);
(a_dinz[15]   =>   b_mac_out[6]      ) = (0,0);
(a_dinz[16]   =>   b_mac_out[6]      ) = (0,0);
(a_dinz[17]   =>   b_mac_out[6]      ) = (0,0);
(a_dinz[18]   =>   b_mac_out[6]      ) = (0,0);
(a_dinz[19]   =>   b_mac_out[6]      ) = (0,0);
(a_dinz[20]   =>   b_mac_out[6]      ) = (0,0);
(a_dinz[21]   =>   b_mac_out[6]      ) = (0,0);
(a_dinz[22]   =>   b_mac_out[6]      ) = (0,0);
(a_dinz[23]   =>   b_mac_out[6]      ) = (0,0);
(a_dinz[24]   =>   b_mac_out[6]      ) = (0,0);
(b_dinz[0]    =>   b_mac_out[6]      ) = (0,0);
(b_dinz[1]    =>   b_mac_out[6]      ) = (0,0);
(b_dinz[2]    =>   b_mac_out[6]      ) = (0,0);
(b_dinz[3]    =>   b_mac_out[6]      ) = (0,0);
(b_dinz[4]    =>   b_mac_out[6]      ) = (0,0);
(b_dinz[5]    =>   b_mac_out[6]      ) = (0,0);
(b_dinz[6]    =>   b_mac_out[6]      ) = (0,0);
(b_dinz[7]    =>   b_mac_out[6]      ) = (0,0);
(b_dinz[8]    =>   b_mac_out[6]      ) = (0,0);
(b_dinz[9]    =>   b_mac_out[6]      ) = (0,0);
(a_dinz_en    =>   b_mac_out[6]      ) = (0,0);
(b_dinz_en    =>   b_mac_out[6]      ) = (0,0);
(a_dinx[0]    =>   b_mac_out[7]      ) = (0,0);
(a_dinx[1]    =>   b_mac_out[7]      ) = (0,0);
(a_dinx[2]    =>   b_mac_out[7]      ) = (0,0);
(a_dinx[3]    =>   b_mac_out[7]      ) = (0,0);
(a_dinx[4]    =>   b_mac_out[7]      ) = (0,0);
(a_dinx[5]    =>   b_mac_out[7]      ) = (0,0);
(a_dinx[6]    =>   b_mac_out[7]      ) = (0,0);
(a_dinx[7]    =>   b_mac_out[7]      ) = (0,0);
(a_dinx[8]    =>   b_mac_out[7]      ) = (0,0);
(a_dinx[9]    =>   b_mac_out[7]      ) = (0,0);
(a_dinx[10]   =>   b_mac_out[7]      ) = (0,0);
(a_dinx[11]   =>   b_mac_out[7]      ) = (0,0);
(a_dinx[12]   =>   b_mac_out[7]      ) = (0,0);
(b_dinx[0]    =>   b_mac_out[7]      ) = (0,0);
(b_dinx[1]    =>   b_mac_out[7]      ) = (0,0);
(b_dinx[2]    =>   b_mac_out[7]      ) = (0,0);
(b_dinx[3]    =>   b_mac_out[7]      ) = (0,0);
(b_dinx[4]    =>   b_mac_out[7]      ) = (0,0);
(b_dinx[5]    =>   b_mac_out[7]      ) = (0,0);
(b_dinx[6]    =>   b_mac_out[7]      ) = (0,0);
(b_dinx[7]    =>   b_mac_out[7]      ) = (0,0);
(b_dinx[8]    =>   b_mac_out[7]      ) = (0,0);
(b_dinx[9]    =>   b_mac_out[7]      ) = (0,0);
(b_dinx[10]   =>   b_mac_out[7]      ) = (0,0);
(b_dinx[11]   =>   b_mac_out[7]      ) = (0,0);
(b_dinx[12]   =>   b_mac_out[7]      ) = (0,0);
(a_diny[0]    =>   b_mac_out[7]      ) = (0,0);
(a_diny[1]    =>   b_mac_out[7]      ) = (0,0);
(a_diny[2]    =>   b_mac_out[7]      ) = (0,0);
(a_diny[3]    =>   b_mac_out[7]      ) = (0,0);
(a_diny[4]    =>   b_mac_out[7]      ) = (0,0);
(a_diny[5]    =>   b_mac_out[7]      ) = (0,0);
(a_diny[6]    =>   b_mac_out[7]      ) = (0,0);
(a_diny[7]    =>   b_mac_out[7]      ) = (0,0);
(a_diny[8]    =>   b_mac_out[7]      ) = (0,0);
(a_diny[9]    =>   b_mac_out[7]      ) = (0,0);
(b_diny[0]    =>   b_mac_out[7]      ) = (0,0);
(b_diny[1]    =>   b_mac_out[7]      ) = (0,0);
(b_diny[2]    =>   b_mac_out[7]      ) = (0,0);
(b_diny[3]    =>   b_mac_out[7]      ) = (0,0);
(b_diny[4]    =>   b_mac_out[7]      ) = (0,0);
(b_diny[5]    =>   b_mac_out[7]      ) = (0,0);
(b_diny[6]    =>   b_mac_out[7]      ) = (0,0);
(b_diny[7]    =>   b_mac_out[7]      ) = (0,0);
(b_diny[8]    =>   b_mac_out[7]      ) = (0,0);
(b_diny[9]    =>   b_mac_out[7]      ) = (0,0);
(a_dinz[0]    =>   b_mac_out[7]      ) = (0,0);
(a_dinz[1]    =>   b_mac_out[7]      ) = (0,0);
(a_dinz[2]    =>   b_mac_out[7]      ) = (0,0);
(a_dinz[3]    =>   b_mac_out[7]      ) = (0,0);
(a_dinz[4]    =>   b_mac_out[7]      ) = (0,0);
(a_dinz[5]    =>   b_mac_out[7]      ) = (0,0);
(a_dinz[6]    =>   b_mac_out[7]      ) = (0,0);
(a_dinz[7]    =>   b_mac_out[7]      ) = (0,0);
(a_dinz[8]    =>   b_mac_out[7]      ) = (0,0);
(a_dinz[9]    =>   b_mac_out[7]      ) = (0,0);
(a_dinz[10]   =>   b_mac_out[7]      ) = (0,0);
(a_dinz[11]   =>   b_mac_out[7]      ) = (0,0);
(a_dinz[12]   =>   b_mac_out[7]      ) = (0,0);
(a_dinz[13]   =>   b_mac_out[7]      ) = (0,0);
(a_dinz[14]   =>   b_mac_out[7]      ) = (0,0);
(a_dinz[15]   =>   b_mac_out[7]      ) = (0,0);
(a_dinz[16]   =>   b_mac_out[7]      ) = (0,0);
(a_dinz[17]   =>   b_mac_out[7]      ) = (0,0);
(a_dinz[18]   =>   b_mac_out[7]      ) = (0,0);
(a_dinz[19]   =>   b_mac_out[7]      ) = (0,0);
(a_dinz[20]   =>   b_mac_out[7]      ) = (0,0);
(a_dinz[21]   =>   b_mac_out[7]      ) = (0,0);
(a_dinz[22]   =>   b_mac_out[7]      ) = (0,0);
(a_dinz[23]   =>   b_mac_out[7]      ) = (0,0);
(a_dinz[24]   =>   b_mac_out[7]      ) = (0,0);
(b_dinz[0]    =>   b_mac_out[7]      ) = (0,0);
(b_dinz[1]    =>   b_mac_out[7]      ) = (0,0);
(b_dinz[2]    =>   b_mac_out[7]      ) = (0,0);
(b_dinz[3]    =>   b_mac_out[7]      ) = (0,0);
(b_dinz[4]    =>   b_mac_out[7]      ) = (0,0);
(b_dinz[5]    =>   b_mac_out[7]      ) = (0,0);
(b_dinz[6]    =>   b_mac_out[7]      ) = (0,0);
(b_dinz[7]    =>   b_mac_out[7]      ) = (0,0);
(b_dinz[8]    =>   b_mac_out[7]      ) = (0,0);
(b_dinz[9]    =>   b_mac_out[7]      ) = (0,0);
(b_dinz[10]   =>   b_mac_out[7]      ) = (0,0);
(a_dinz_en    =>   b_mac_out[7]      ) = (0,0);
(b_dinz_en    =>   b_mac_out[7]      ) = (0,0);
(a_dinx[0]    =>   b_mac_out[8]      ) = (0,0);
(a_dinx[1]    =>   b_mac_out[8]      ) = (0,0);
(a_dinx[2]    =>   b_mac_out[8]      ) = (0,0);
(a_dinx[3]    =>   b_mac_out[8]      ) = (0,0);
(a_dinx[4]    =>   b_mac_out[8]      ) = (0,0);
(a_dinx[5]    =>   b_mac_out[8]      ) = (0,0);
(a_dinx[6]    =>   b_mac_out[8]      ) = (0,0);
(a_dinx[7]    =>   b_mac_out[8]      ) = (0,0);
(a_dinx[8]    =>   b_mac_out[8]      ) = (0,0);
(a_dinx[9]    =>   b_mac_out[8]      ) = (0,0);
(a_dinx[10]   =>   b_mac_out[8]      ) = (0,0);
(a_dinx[11]   =>   b_mac_out[8]      ) = (0,0);
(a_dinx[12]   =>   b_mac_out[8]      ) = (0,0);
(b_dinx[0]    =>   b_mac_out[8]      ) = (0,0);
(b_dinx[1]    =>   b_mac_out[8]      ) = (0,0);
(b_dinx[2]    =>   b_mac_out[8]      ) = (0,0);
(b_dinx[3]    =>   b_mac_out[8]      ) = (0,0);
(b_dinx[4]    =>   b_mac_out[8]      ) = (0,0);
(b_dinx[5]    =>   b_mac_out[8]      ) = (0,0);
(b_dinx[6]    =>   b_mac_out[8]      ) = (0,0);
(b_dinx[7]    =>   b_mac_out[8]      ) = (0,0);
(b_dinx[8]    =>   b_mac_out[8]      ) = (0,0);
(b_dinx[9]    =>   b_mac_out[8]      ) = (0,0);
(b_dinx[10]   =>   b_mac_out[8]      ) = (0,0);
(b_dinx[11]   =>   b_mac_out[8]      ) = (0,0);
(b_dinx[12]   =>   b_mac_out[8]      ) = (0,0);
(a_diny[0]    =>   b_mac_out[8]      ) = (0,0);
(a_diny[1]    =>   b_mac_out[8]      ) = (0,0);
(a_diny[2]    =>   b_mac_out[8]      ) = (0,0);
(a_diny[3]    =>   b_mac_out[8]      ) = (0,0);
(a_diny[4]    =>   b_mac_out[8]      ) = (0,0);
(a_diny[5]    =>   b_mac_out[8]      ) = (0,0);
(a_diny[6]    =>   b_mac_out[8]      ) = (0,0);
(a_diny[7]    =>   b_mac_out[8]      ) = (0,0);
(a_diny[8]    =>   b_mac_out[8]      ) = (0,0);
(a_diny[9]    =>   b_mac_out[8]      ) = (0,0);
(b_diny[0]    =>   b_mac_out[8]      ) = (0,0);
(b_diny[1]    =>   b_mac_out[8]      ) = (0,0);
(b_diny[2]    =>   b_mac_out[8]      ) = (0,0);
(b_diny[3]    =>   b_mac_out[8]      ) = (0,0);
(b_diny[4]    =>   b_mac_out[8]      ) = (0,0);
(b_diny[5]    =>   b_mac_out[8]      ) = (0,0);
(b_diny[6]    =>   b_mac_out[8]      ) = (0,0);
(b_diny[7]    =>   b_mac_out[8]      ) = (0,0);
(b_diny[8]    =>   b_mac_out[8]      ) = (0,0);
(b_diny[9]    =>   b_mac_out[8]      ) = (0,0);
(a_dinz[0]    =>   b_mac_out[8]      ) = (0,0);
(a_dinz[1]    =>   b_mac_out[8]      ) = (0,0);
(a_dinz[2]    =>   b_mac_out[8]      ) = (0,0);
(a_dinz[3]    =>   b_mac_out[8]      ) = (0,0);
(a_dinz[4]    =>   b_mac_out[8]      ) = (0,0);
(a_dinz[5]    =>   b_mac_out[8]      ) = (0,0);
(a_dinz[6]    =>   b_mac_out[8]      ) = (0,0);
(a_dinz[7]    =>   b_mac_out[8]      ) = (0,0);
(a_dinz[8]    =>   b_mac_out[8]      ) = (0,0);
(a_dinz[9]    =>   b_mac_out[8]      ) = (0,0);
(a_dinz[10]   =>   b_mac_out[8]      ) = (0,0);
(a_dinz[11]   =>   b_mac_out[8]      ) = (0,0);
(a_dinz[12]   =>   b_mac_out[8]      ) = (0,0);
(a_dinz[13]   =>   b_mac_out[8]      ) = (0,0);
(a_dinz[14]   =>   b_mac_out[8]      ) = (0,0);
(a_dinz[15]   =>   b_mac_out[8]      ) = (0,0);
(a_dinz[16]   =>   b_mac_out[8]      ) = (0,0);
(a_dinz[17]   =>   b_mac_out[8]      ) = (0,0);
(a_dinz[18]   =>   b_mac_out[8]      ) = (0,0);
(a_dinz[19]   =>   b_mac_out[8]      ) = (0,0);
(a_dinz[20]   =>   b_mac_out[8]      ) = (0,0);
(a_dinz[21]   =>   b_mac_out[8]      ) = (0,0);
(a_dinz[22]   =>   b_mac_out[8]      ) = (0,0);
(a_dinz[23]   =>   b_mac_out[8]      ) = (0,0);
(a_dinz[24]   =>   b_mac_out[8]      ) = (0,0);
(b_dinz[0]    =>   b_mac_out[8]      ) = (0,0);
(b_dinz[1]    =>   b_mac_out[8]      ) = (0,0);
(b_dinz[2]    =>   b_mac_out[8]      ) = (0,0);
(b_dinz[3]    =>   b_mac_out[8]      ) = (0,0);
(b_dinz[4]    =>   b_mac_out[8]      ) = (0,0);
(b_dinz[5]    =>   b_mac_out[8]      ) = (0,0);
(b_dinz[6]    =>   b_mac_out[8]      ) = (0,0);
(b_dinz[7]    =>   b_mac_out[8]      ) = (0,0);
(b_dinz[8]    =>   b_mac_out[8]      ) = (0,0);
(b_dinz[9]    =>   b_mac_out[8]      ) = (0,0);
(b_dinz[10]   =>   b_mac_out[8]      ) = (0,0);
(b_dinz[11]   =>   b_mac_out[8]      ) = (0,0);
(b_dinz[21]   =>   b_mac_out[8]      ) = (0,0);
(a_dinz_en    =>   b_mac_out[8]      ) = (0,0);
(b_dinz_en    =>   b_mac_out[8]      ) = (0,0);
(a_dinx[0]    =>   b_mac_out[9]      ) = (0,0);
(a_dinx[1]    =>   b_mac_out[9]      ) = (0,0);
(a_dinx[2]    =>   b_mac_out[9]      ) = (0,0);
(a_dinx[3]    =>   b_mac_out[9]      ) = (0,0);
(a_dinx[4]    =>   b_mac_out[9]      ) = (0,0);
(a_dinx[5]    =>   b_mac_out[9]      ) = (0,0);
(a_dinx[6]    =>   b_mac_out[9]      ) = (0,0);
(a_dinx[7]    =>   b_mac_out[9]      ) = (0,0);
(a_dinx[8]    =>   b_mac_out[9]      ) = (0,0);
(a_dinx[9]    =>   b_mac_out[9]      ) = (0,0);
(a_dinx[10]   =>   b_mac_out[9]      ) = (0,0);
(a_dinx[11]   =>   b_mac_out[9]      ) = (0,0);
(a_dinx[12]   =>   b_mac_out[9]      ) = (0,0);
(b_dinx[0]    =>   b_mac_out[9]      ) = (0,0);
(b_dinx[1]    =>   b_mac_out[9]      ) = (0,0);
(b_dinx[2]    =>   b_mac_out[9]      ) = (0,0);
(b_dinx[3]    =>   b_mac_out[9]      ) = (0,0);
(b_dinx[4]    =>   b_mac_out[9]      ) = (0,0);
(b_dinx[5]    =>   b_mac_out[9]      ) = (0,0);
(b_dinx[6]    =>   b_mac_out[9]      ) = (0,0);
(b_dinx[7]    =>   b_mac_out[9]      ) = (0,0);
(b_dinx[8]    =>   b_mac_out[9]      ) = (0,0);
(b_dinx[9]    =>   b_mac_out[9]      ) = (0,0);
(b_dinx[10]   =>   b_mac_out[9]      ) = (0,0);
(b_dinx[11]   =>   b_mac_out[9]      ) = (0,0);
(b_dinx[12]   =>   b_mac_out[9]      ) = (0,0);
(a_diny[0]    =>   b_mac_out[9]      ) = (0,0);
(a_diny[1]    =>   b_mac_out[9]      ) = (0,0);
(a_diny[2]    =>   b_mac_out[9]      ) = (0,0);
(a_diny[3]    =>   b_mac_out[9]      ) = (0,0);
(a_diny[4]    =>   b_mac_out[9]      ) = (0,0);
(a_diny[5]    =>   b_mac_out[9]      ) = (0,0);
(a_diny[6]    =>   b_mac_out[9]      ) = (0,0);
(a_diny[7]    =>   b_mac_out[9]      ) = (0,0);
(a_diny[8]    =>   b_mac_out[9]      ) = (0,0);
(a_diny[9]    =>   b_mac_out[9]      ) = (0,0);
(b_diny[0]    =>   b_mac_out[9]      ) = (0,0);
(b_diny[1]    =>   b_mac_out[9]      ) = (0,0);
(b_diny[2]    =>   b_mac_out[9]      ) = (0,0);
(b_diny[3]    =>   b_mac_out[9]      ) = (0,0);
(b_diny[4]    =>   b_mac_out[9]      ) = (0,0);
(b_diny[5]    =>   b_mac_out[9]      ) = (0,0);
(b_diny[6]    =>   b_mac_out[9]      ) = (0,0);
(b_diny[7]    =>   b_mac_out[9]      ) = (0,0);
(b_diny[8]    =>   b_mac_out[9]      ) = (0,0);
(b_diny[9]    =>   b_mac_out[9]      ) = (0,0);
(a_dinz[0]    =>   b_mac_out[9]      ) = (0,0);
(a_dinz[1]    =>   b_mac_out[9]      ) = (0,0);
(a_dinz[2]    =>   b_mac_out[9]      ) = (0,0);
(a_dinz[3]    =>   b_mac_out[9]      ) = (0,0);
(a_dinz[4]    =>   b_mac_out[9]      ) = (0,0);
(a_dinz[5]    =>   b_mac_out[9]      ) = (0,0);
(a_dinz[6]    =>   b_mac_out[9]      ) = (0,0);
(a_dinz[7]    =>   b_mac_out[9]      ) = (0,0);
(a_dinz[8]    =>   b_mac_out[9]      ) = (0,0);
(a_dinz[9]    =>   b_mac_out[9]      ) = (0,0);
(a_dinz[10]   =>   b_mac_out[9]      ) = (0,0);
(a_dinz[11]   =>   b_mac_out[9]      ) = (0,0);
(a_dinz[12]   =>   b_mac_out[9]      ) = (0,0);
(a_dinz[13]   =>   b_mac_out[9]      ) = (0,0);
(a_dinz[14]   =>   b_mac_out[9]      ) = (0,0);
(a_dinz[15]   =>   b_mac_out[9]      ) = (0,0);
(a_dinz[16]   =>   b_mac_out[9]      ) = (0,0);
(a_dinz[17]   =>   b_mac_out[9]      ) = (0,0);
(a_dinz[18]   =>   b_mac_out[9]      ) = (0,0);
(a_dinz[19]   =>   b_mac_out[9]      ) = (0,0);
(a_dinz[20]   =>   b_mac_out[9]      ) = (0,0);
(a_dinz[21]   =>   b_mac_out[9]      ) = (0,0);
(a_dinz[22]   =>   b_mac_out[9]      ) = (0,0);
(a_dinz[23]   =>   b_mac_out[9]      ) = (0,0);
(a_dinz[24]   =>   b_mac_out[9]      ) = (0,0);
(b_dinz[0]    =>   b_mac_out[9]      ) = (0,0);
(b_dinz[1]    =>   b_mac_out[9]      ) = (0,0);
(b_dinz[2]    =>   b_mac_out[9]      ) = (0,0);
(b_dinz[3]    =>   b_mac_out[9]      ) = (0,0);
(b_dinz[4]    =>   b_mac_out[9]      ) = (0,0);
(b_dinz[5]    =>   b_mac_out[9]      ) = (0,0);
(b_dinz[6]    =>   b_mac_out[9]      ) = (0,0);
(b_dinz[7]    =>   b_mac_out[9]      ) = (0,0);
(b_dinz[8]    =>   b_mac_out[9]      ) = (0,0);
(b_dinz[9]    =>   b_mac_out[9]      ) = (0,0);
(b_dinz[10]   =>   b_mac_out[9]      ) = (0,0);
(b_dinz[11]   =>   b_mac_out[9]      ) = (0,0);
(b_dinz[12]   =>   b_mac_out[9]      ) = (0,0);
(a_dinz_en    =>   b_mac_out[9]      ) = (0,0);
(b_dinz_en    =>   b_mac_out[9]      ) = (0,0);
(a_dinx[0]    =>   b_mac_out[10]     ) = (0,0);
(a_dinx[1]    =>   b_mac_out[10]     ) = (0,0);
(a_dinx[2]    =>   b_mac_out[10]     ) = (0,0);
(a_dinx[3]    =>   b_mac_out[10]     ) = (0,0);
(a_dinx[4]    =>   b_mac_out[10]     ) = (0,0);
(a_dinx[5]    =>   b_mac_out[10]     ) = (0,0);
(a_dinx[6]    =>   b_mac_out[10]     ) = (0,0);
(a_dinx[7]    =>   b_mac_out[10]     ) = (0,0);
(a_dinx[8]    =>   b_mac_out[10]     ) = (0,0);
(a_dinx[9]    =>   b_mac_out[10]     ) = (0,0);
(a_dinx[10]   =>   b_mac_out[10]     ) = (0,0);
(a_dinx[11]   =>   b_mac_out[10]     ) = (0,0);
(a_dinx[12]   =>   b_mac_out[10]     ) = (0,0);
(b_dinx[0]    =>   b_mac_out[10]     ) = (0,0);
(b_dinx[1]    =>   b_mac_out[10]     ) = (0,0);
(b_dinx[2]    =>   b_mac_out[10]     ) = (0,0);
(b_dinx[3]    =>   b_mac_out[10]     ) = (0,0);
(b_dinx[4]    =>   b_mac_out[10]     ) = (0,0);
(b_dinx[5]    =>   b_mac_out[10]     ) = (0,0);
(b_dinx[6]    =>   b_mac_out[10]     ) = (0,0);
(b_dinx[7]    =>   b_mac_out[10]     ) = (0,0);
(b_dinx[8]    =>   b_mac_out[10]     ) = (0,0);
(b_dinx[9]    =>   b_mac_out[10]     ) = (0,0);
(b_dinx[10]   =>   b_mac_out[10]     ) = (0,0);
(b_dinx[11]   =>   b_mac_out[10]     ) = (0,0);
(b_dinx[12]   =>   b_mac_out[10]     ) = (0,0);
(a_diny[0]    =>   b_mac_out[10]     ) = (0,0);
(a_diny[1]    =>   b_mac_out[10]     ) = (0,0);
(a_diny[2]    =>   b_mac_out[10]     ) = (0,0);
(a_diny[3]    =>   b_mac_out[10]     ) = (0,0);
(a_diny[4]    =>   b_mac_out[10]     ) = (0,0);
(a_diny[5]    =>   b_mac_out[10]     ) = (0,0);
(a_diny[6]    =>   b_mac_out[10]     ) = (0,0);
(a_diny[7]    =>   b_mac_out[10]     ) = (0,0);
(a_diny[8]    =>   b_mac_out[10]     ) = (0,0);
(a_diny[9]    =>   b_mac_out[10]     ) = (0,0);
(b_diny[0]    =>   b_mac_out[10]     ) = (0,0);
(b_diny[1]    =>   b_mac_out[10]     ) = (0,0);
(b_diny[2]    =>   b_mac_out[10]     ) = (0,0);
(b_diny[3]    =>   b_mac_out[10]     ) = (0,0);
(b_diny[4]    =>   b_mac_out[10]     ) = (0,0);
(b_diny[5]    =>   b_mac_out[10]     ) = (0,0);
(b_diny[6]    =>   b_mac_out[10]     ) = (0,0);
(b_diny[7]    =>   b_mac_out[10]     ) = (0,0);
(b_diny[8]    =>   b_mac_out[10]     ) = (0,0);
(b_diny[9]    =>   b_mac_out[10]     ) = (0,0);
(a_dinz[0]    =>   b_mac_out[10]     ) = (0,0);
(a_dinz[1]    =>   b_mac_out[10]     ) = (0,0);
(a_dinz[2]    =>   b_mac_out[10]     ) = (0,0);
(a_dinz[3]    =>   b_mac_out[10]     ) = (0,0);
(a_dinz[4]    =>   b_mac_out[10]     ) = (0,0);
(a_dinz[5]    =>   b_mac_out[10]     ) = (0,0);
(a_dinz[6]    =>   b_mac_out[10]     ) = (0,0);
(a_dinz[7]    =>   b_mac_out[10]     ) = (0,0);
(a_dinz[8]    =>   b_mac_out[10]     ) = (0,0);
(a_dinz[9]    =>   b_mac_out[10]     ) = (0,0);
(a_dinz[10]   =>   b_mac_out[10]     ) = (0,0);
(a_dinz[11]   =>   b_mac_out[10]     ) = (0,0);
(a_dinz[12]   =>   b_mac_out[10]     ) = (0,0);
(a_dinz[13]   =>   b_mac_out[10]     ) = (0,0);
(a_dinz[14]   =>   b_mac_out[10]     ) = (0,0);
(a_dinz[15]   =>   b_mac_out[10]     ) = (0,0);
(a_dinz[16]   =>   b_mac_out[10]     ) = (0,0);
(a_dinz[17]   =>   b_mac_out[10]     ) = (0,0);
(a_dinz[18]   =>   b_mac_out[10]     ) = (0,0);
(a_dinz[19]   =>   b_mac_out[10]     ) = (0,0);
(a_dinz[20]   =>   b_mac_out[10]     ) = (0,0);
(a_dinz[21]   =>   b_mac_out[10]     ) = (0,0);
(a_dinz[22]   =>   b_mac_out[10]     ) = (0,0);
(a_dinz[23]   =>   b_mac_out[10]     ) = (0,0);
(a_dinz[24]   =>   b_mac_out[10]     ) = (0,0);
(b_dinz[0]    =>   b_mac_out[10]     ) = (0,0);
(b_dinz[1]    =>   b_mac_out[10]     ) = (0,0);
(b_dinz[2]    =>   b_mac_out[10]     ) = (0,0);
(b_dinz[3]    =>   b_mac_out[10]     ) = (0,0);
(b_dinz[4]    =>   b_mac_out[10]     ) = (0,0);
(b_dinz[5]    =>   b_mac_out[10]     ) = (0,0);
(b_dinz[6]    =>   b_mac_out[10]     ) = (0,0);
(b_dinz[7]    =>   b_mac_out[10]     ) = (0,0);
(b_dinz[8]    =>   b_mac_out[10]     ) = (0,0);
(b_dinz[9]    =>   b_mac_out[10]     ) = (0,0);
(b_dinz[10]   =>   b_mac_out[10]     ) = (0,0);
(b_dinz[11]   =>   b_mac_out[10]     ) = (0,0);
(b_dinz[12]   =>   b_mac_out[10]     ) = (0,0);
(b_dinz[13]   =>   b_mac_out[10]     ) = (0,0);
(a_dinz_en    =>   b_mac_out[10]     ) = (0,0);
(b_dinz_en    =>   b_mac_out[10]     ) = (0,0);
(a_dinx[0]    =>   b_mac_out[11]     ) = (0,0);
(a_dinx[1]    =>   b_mac_out[11]     ) = (0,0);
(a_dinx[2]    =>   b_mac_out[11]     ) = (0,0);
(a_dinx[3]    =>   b_mac_out[11]     ) = (0,0);
(a_dinx[4]    =>   b_mac_out[11]     ) = (0,0);
(a_dinx[5]    =>   b_mac_out[11]     ) = (0,0);
(a_dinx[6]    =>   b_mac_out[11]     ) = (0,0);
(a_dinx[7]    =>   b_mac_out[11]     ) = (0,0);
(a_dinx[8]    =>   b_mac_out[11]     ) = (0,0);
(a_dinx[9]    =>   b_mac_out[11]     ) = (0,0);
(a_dinx[10]   =>   b_mac_out[11]     ) = (0,0);
(a_dinx[11]   =>   b_mac_out[11]     ) = (0,0);
(a_dinx[12]   =>   b_mac_out[11]     ) = (0,0);
(b_dinx[0]    =>   b_mac_out[11]     ) = (0,0);
(b_dinx[1]    =>   b_mac_out[11]     ) = (0,0);
(b_dinx[2]    =>   b_mac_out[11]     ) = (0,0);
(b_dinx[3]    =>   b_mac_out[11]     ) = (0,0);
(b_dinx[4]    =>   b_mac_out[11]     ) = (0,0);
(b_dinx[5]    =>   b_mac_out[11]     ) = (0,0);
(b_dinx[6]    =>   b_mac_out[11]     ) = (0,0);
(b_dinx[7]    =>   b_mac_out[11]     ) = (0,0);
(b_dinx[8]    =>   b_mac_out[11]     ) = (0,0);
(b_dinx[9]    =>   b_mac_out[11]     ) = (0,0);
(b_dinx[10]   =>   b_mac_out[11]     ) = (0,0);
(b_dinx[11]   =>   b_mac_out[11]     ) = (0,0);
(b_dinx[12]   =>   b_mac_out[11]     ) = (0,0);
(a_diny[0]    =>   b_mac_out[11]     ) = (0,0);
(a_diny[1]    =>   b_mac_out[11]     ) = (0,0);
(a_diny[2]    =>   b_mac_out[11]     ) = (0,0);
(a_diny[3]    =>   b_mac_out[11]     ) = (0,0);
(a_diny[4]    =>   b_mac_out[11]     ) = (0,0);
(a_diny[5]    =>   b_mac_out[11]     ) = (0,0);
(a_diny[6]    =>   b_mac_out[11]     ) = (0,0);
(a_diny[7]    =>   b_mac_out[11]     ) = (0,0);
(a_diny[8]    =>   b_mac_out[11]     ) = (0,0);
(a_diny[9]    =>   b_mac_out[11]     ) = (0,0);
(b_diny[0]    =>   b_mac_out[11]     ) = (0,0);
(b_diny[1]    =>   b_mac_out[11]     ) = (0,0);
(b_diny[2]    =>   b_mac_out[11]     ) = (0,0);
(b_diny[3]    =>   b_mac_out[11]     ) = (0,0);
(b_diny[4]    =>   b_mac_out[11]     ) = (0,0);
(b_diny[5]    =>   b_mac_out[11]     ) = (0,0);
(b_diny[6]    =>   b_mac_out[11]     ) = (0,0);
(b_diny[7]    =>   b_mac_out[11]     ) = (0,0);
(b_diny[8]    =>   b_mac_out[11]     ) = (0,0);
(b_diny[9]    =>   b_mac_out[11]     ) = (0,0);
(a_dinz[0]    =>   b_mac_out[11]     ) = (0,0);
(a_dinz[1]    =>   b_mac_out[11]     ) = (0,0);
(a_dinz[2]    =>   b_mac_out[11]     ) = (0,0);
(a_dinz[3]    =>   b_mac_out[11]     ) = (0,0);
(a_dinz[4]    =>   b_mac_out[11]     ) = (0,0);
(a_dinz[5]    =>   b_mac_out[11]     ) = (0,0);
(a_dinz[6]    =>   b_mac_out[11]     ) = (0,0);
(a_dinz[7]    =>   b_mac_out[11]     ) = (0,0);
(a_dinz[8]    =>   b_mac_out[11]     ) = (0,0);
(a_dinz[9]    =>   b_mac_out[11]     ) = (0,0);
(a_dinz[10]   =>   b_mac_out[11]     ) = (0,0);
(a_dinz[11]   =>   b_mac_out[11]     ) = (0,0);
(a_dinz[12]   =>   b_mac_out[11]     ) = (0,0);
(a_dinz[13]   =>   b_mac_out[11]     ) = (0,0);
(a_dinz[14]   =>   b_mac_out[11]     ) = (0,0);
(a_dinz[15]   =>   b_mac_out[11]     ) = (0,0);
(a_dinz[16]   =>   b_mac_out[11]     ) = (0,0);
(a_dinz[17]   =>   b_mac_out[11]     ) = (0,0);
(a_dinz[18]   =>   b_mac_out[11]     ) = (0,0);
(a_dinz[19]   =>   b_mac_out[11]     ) = (0,0);
(a_dinz[20]   =>   b_mac_out[11]     ) = (0,0);
(a_dinz[21]   =>   b_mac_out[11]     ) = (0,0);
(a_dinz[22]   =>   b_mac_out[11]     ) = (0,0);
(a_dinz[23]   =>   b_mac_out[11]     ) = (0,0);
(a_dinz[24]   =>   b_mac_out[11]     ) = (0,0);
(b_dinz[0]    =>   b_mac_out[11]     ) = (0,0);
(b_dinz[1]    =>   b_mac_out[11]     ) = (0,0);
(b_dinz[2]    =>   b_mac_out[11]     ) = (0,0);
(b_dinz[3]    =>   b_mac_out[11]     ) = (0,0);
(b_dinz[4]    =>   b_mac_out[11]     ) = (0,0);
(b_dinz[5]    =>   b_mac_out[11]     ) = (0,0);
(b_dinz[6]    =>   b_mac_out[11]     ) = (0,0);
(b_dinz[7]    =>   b_mac_out[11]     ) = (0,0);
(b_dinz[8]    =>   b_mac_out[11]     ) = (0,0);
(b_dinz[9]    =>   b_mac_out[11]     ) = (0,0);
(b_dinz[10]   =>   b_mac_out[11]     ) = (0,0);
(b_dinz[11]   =>   b_mac_out[11]     ) = (0,0);
(b_dinz[12]   =>   b_mac_out[11]     ) = (0,0);
(b_dinz[13]   =>   b_mac_out[11]     ) = (0,0);
(b_dinz[14]   =>   b_mac_out[11]     ) = (0,0);
(a_dinz_en    =>   b_mac_out[11]     ) = (0,0);
(b_dinz_en    =>   b_mac_out[11]     ) = (0,0);
(a_dinx[0]    =>   b_mac_out[12]     ) = (0,0);
(a_dinx[1]    =>   b_mac_out[12]     ) = (0,0);
(a_dinx[2]    =>   b_mac_out[12]     ) = (0,0);
(a_dinx[3]    =>   b_mac_out[12]     ) = (0,0);
(a_dinx[4]    =>   b_mac_out[12]     ) = (0,0);
(a_dinx[5]    =>   b_mac_out[12]     ) = (0,0);
(a_dinx[6]    =>   b_mac_out[12]     ) = (0,0);
(a_dinx[7]    =>   b_mac_out[12]     ) = (0,0);
(a_dinx[8]    =>   b_mac_out[12]     ) = (0,0);
(a_dinx[9]    =>   b_mac_out[12]     ) = (0,0);
(a_dinx[10]   =>   b_mac_out[12]     ) = (0,0);
(a_dinx[11]   =>   b_mac_out[12]     ) = (0,0);
(a_dinx[12]   =>   b_mac_out[12]     ) = (0,0);
(b_dinx[0]    =>   b_mac_out[12]     ) = (0,0);
(b_dinx[1]    =>   b_mac_out[12]     ) = (0,0);
(b_dinx[2]    =>   b_mac_out[12]     ) = (0,0);
(b_dinx[3]    =>   b_mac_out[12]     ) = (0,0);
(b_dinx[4]    =>   b_mac_out[12]     ) = (0,0);
(b_dinx[5]    =>   b_mac_out[12]     ) = (0,0);
(b_dinx[6]    =>   b_mac_out[12]     ) = (0,0);
(b_dinx[7]    =>   b_mac_out[12]     ) = (0,0);
(b_dinx[8]    =>   b_mac_out[12]     ) = (0,0);
(b_dinx[9]    =>   b_mac_out[12]     ) = (0,0);
(b_dinx[10]   =>   b_mac_out[12]     ) = (0,0);
(b_dinx[11]   =>   b_mac_out[12]     ) = (0,0);
(b_dinx[12]   =>   b_mac_out[12]     ) = (0,0);
(a_diny[0]    =>   b_mac_out[12]     ) = (0,0);
(a_diny[1]    =>   b_mac_out[12]     ) = (0,0);
(a_diny[2]    =>   b_mac_out[12]     ) = (0,0);
(a_diny[3]    =>   b_mac_out[12]     ) = (0,0);
(a_diny[4]    =>   b_mac_out[12]     ) = (0,0);
(a_diny[5]    =>   b_mac_out[12]     ) = (0,0);
(a_diny[6]    =>   b_mac_out[12]     ) = (0,0);
(a_diny[7]    =>   b_mac_out[12]     ) = (0,0);
(a_diny[8]    =>   b_mac_out[12]     ) = (0,0);
(a_diny[9]    =>   b_mac_out[12]     ) = (0,0);
(b_diny[0]    =>   b_mac_out[12]     ) = (0,0);
(b_diny[1]    =>   b_mac_out[12]     ) = (0,0);
(b_diny[2]    =>   b_mac_out[12]     ) = (0,0);
(b_diny[3]    =>   b_mac_out[12]     ) = (0,0);
(b_diny[4]    =>   b_mac_out[12]     ) = (0,0);
(b_diny[5]    =>   b_mac_out[12]     ) = (0,0);
(b_diny[6]    =>   b_mac_out[12]     ) = (0,0);
(b_diny[7]    =>   b_mac_out[12]     ) = (0,0);
(b_diny[8]    =>   b_mac_out[12]     ) = (0,0);
(b_diny[9]    =>   b_mac_out[12]     ) = (0,0);
(a_dinz[0]    =>   b_mac_out[12]     ) = (0,0);
(a_dinz[1]    =>   b_mac_out[12]     ) = (0,0);
(a_dinz[2]    =>   b_mac_out[12]     ) = (0,0);
(a_dinz[3]    =>   b_mac_out[12]     ) = (0,0);
(a_dinz[4]    =>   b_mac_out[12]     ) = (0,0);
(a_dinz[5]    =>   b_mac_out[12]     ) = (0,0);
(a_dinz[6]    =>   b_mac_out[12]     ) = (0,0);
(a_dinz[7]    =>   b_mac_out[12]     ) = (0,0);
(a_dinz[8]    =>   b_mac_out[12]     ) = (0,0);
(a_dinz[9]    =>   b_mac_out[12]     ) = (0,0);
(a_dinz[10]   =>   b_mac_out[12]     ) = (0,0);
(a_dinz[11]   =>   b_mac_out[12]     ) = (0,0);
(a_dinz[12]   =>   b_mac_out[12]     ) = (0,0);
(a_dinz[13]   =>   b_mac_out[12]     ) = (0,0);
(a_dinz[14]   =>   b_mac_out[12]     ) = (0,0);
(a_dinz[15]   =>   b_mac_out[12]     ) = (0,0);
(a_dinz[16]   =>   b_mac_out[12]     ) = (0,0);
(a_dinz[17]   =>   b_mac_out[12]     ) = (0,0);
(a_dinz[18]   =>   b_mac_out[12]     ) = (0,0);
(a_dinz[19]   =>   b_mac_out[12]     ) = (0,0);
(a_dinz[20]   =>   b_mac_out[12]     ) = (0,0);
(a_dinz[21]   =>   b_mac_out[12]     ) = (0,0);
(a_dinz[22]   =>   b_mac_out[12]     ) = (0,0);
(a_dinz[23]   =>   b_mac_out[12]     ) = (0,0);
(a_dinz[24]   =>   b_mac_out[12]     ) = (0,0);
(b_dinz[0]    =>   b_mac_out[12]     ) = (0,0);
(b_dinz[1]    =>   b_mac_out[12]     ) = (0,0);
(b_dinz[2]    =>   b_mac_out[12]     ) = (0,0);
(b_dinz[3]    =>   b_mac_out[12]     ) = (0,0);
(b_dinz[4]    =>   b_mac_out[12]     ) = (0,0);
(b_dinz[5]    =>   b_mac_out[12]     ) = (0,0);
(b_dinz[6]    =>   b_mac_out[12]     ) = (0,0);
(b_dinz[7]    =>   b_mac_out[12]     ) = (0,0);
(b_dinz[8]    =>   b_mac_out[12]     ) = (0,0);
(b_dinz[9]    =>   b_mac_out[12]     ) = (0,0);
(b_dinz[10]   =>   b_mac_out[12]     ) = (0,0);
(b_dinz[11]   =>   b_mac_out[12]     ) = (0,0);
(b_dinz[12]   =>   b_mac_out[12]     ) = (0,0);
(b_dinz[13]   =>   b_mac_out[12]     ) = (0,0);
(b_dinz[14]   =>   b_mac_out[12]     ) = (0,0);
(b_dinz[15]   =>   b_mac_out[12]     ) = (0,0);
(a_dinz_en    =>   b_mac_out[12]     ) = (0,0);
(b_dinz_en    =>   b_mac_out[12]     ) = (0,0);
(a_dinx[0]    =>   b_mac_out[13]     ) = (0,0);
(a_dinx[1]    =>   b_mac_out[13]     ) = (0,0);
(a_dinx[2]    =>   b_mac_out[13]     ) = (0,0);
(a_dinx[3]    =>   b_mac_out[13]     ) = (0,0);
(a_dinx[4]    =>   b_mac_out[13]     ) = (0,0);
(a_dinx[5]    =>   b_mac_out[13]     ) = (0,0);
(a_dinx[6]    =>   b_mac_out[13]     ) = (0,0);
(a_dinx[7]    =>   b_mac_out[13]     ) = (0,0);
(a_dinx[8]    =>   b_mac_out[13]     ) = (0,0);
(a_dinx[9]    =>   b_mac_out[13]     ) = (0,0);
(a_dinx[10]   =>   b_mac_out[13]     ) = (0,0);
(a_dinx[11]   =>   b_mac_out[13]     ) = (0,0);
(a_dinx[12]   =>   b_mac_out[13]     ) = (0,0);
(b_dinx[0]    =>   b_mac_out[13]     ) = (0,0);
(b_dinx[1]    =>   b_mac_out[13]     ) = (0,0);
(b_dinx[2]    =>   b_mac_out[13]     ) = (0,0);
(b_dinx[3]    =>   b_mac_out[13]     ) = (0,0);
(b_dinx[4]    =>   b_mac_out[13]     ) = (0,0);
(b_dinx[5]    =>   b_mac_out[13]     ) = (0,0);
(b_dinx[6]    =>   b_mac_out[13]     ) = (0,0);
(b_dinx[7]    =>   b_mac_out[13]     ) = (0,0);
(b_dinx[8]    =>   b_mac_out[13]     ) = (0,0);
(b_dinx[9]    =>   b_mac_out[13]     ) = (0,0);
(b_dinx[10]   =>   b_mac_out[13]     ) = (0,0);
(b_dinx[11]   =>   b_mac_out[13]     ) = (0,0);
(b_dinx[12]   =>   b_mac_out[13]     ) = (0,0);
(a_diny[0]    =>   b_mac_out[13]     ) = (0,0);
(a_diny[1]    =>   b_mac_out[13]     ) = (0,0);
(a_diny[2]    =>   b_mac_out[13]     ) = (0,0);
(a_diny[3]    =>   b_mac_out[13]     ) = (0,0);
(a_diny[4]    =>   b_mac_out[13]     ) = (0,0);
(a_diny[5]    =>   b_mac_out[13]     ) = (0,0);
(a_diny[6]    =>   b_mac_out[13]     ) = (0,0);
(a_diny[7]    =>   b_mac_out[13]     ) = (0,0);
(a_diny[8]    =>   b_mac_out[13]     ) = (0,0);
(a_diny[9]    =>   b_mac_out[13]     ) = (0,0);
(b_diny[0]    =>   b_mac_out[13]     ) = (0,0);
(b_diny[1]    =>   b_mac_out[13]     ) = (0,0);
(b_diny[2]    =>   b_mac_out[13]     ) = (0,0);
(b_diny[3]    =>   b_mac_out[13]     ) = (0,0);
(b_diny[4]    =>   b_mac_out[13]     ) = (0,0);
(b_diny[5]    =>   b_mac_out[13]     ) = (0,0);
(b_diny[6]    =>   b_mac_out[13]     ) = (0,0);
(b_diny[7]    =>   b_mac_out[13]     ) = (0,0);
(b_diny[8]    =>   b_mac_out[13]     ) = (0,0);
(b_diny[9]    =>   b_mac_out[13]     ) = (0,0);
(a_dinz[0]    =>   b_mac_out[13]     ) = (0,0);
(a_dinz[1]    =>   b_mac_out[13]     ) = (0,0);
(a_dinz[2]    =>   b_mac_out[13]     ) = (0,0);
(a_dinz[3]    =>   b_mac_out[13]     ) = (0,0);
(a_dinz[4]    =>   b_mac_out[13]     ) = (0,0);
(a_dinz[5]    =>   b_mac_out[13]     ) = (0,0);
(a_dinz[6]    =>   b_mac_out[13]     ) = (0,0);
(a_dinz[7]    =>   b_mac_out[13]     ) = (0,0);
(a_dinz[8]    =>   b_mac_out[13]     ) = (0,0);
(a_dinz[9]    =>   b_mac_out[13]     ) = (0,0);
(a_dinz[10]   =>   b_mac_out[13]     ) = (0,0);
(a_dinz[11]   =>   b_mac_out[13]     ) = (0,0);
(a_dinz[12]   =>   b_mac_out[13]     ) = (0,0);
(a_dinz[13]   =>   b_mac_out[13]     ) = (0,0);
(a_dinz[14]   =>   b_mac_out[13]     ) = (0,0);
(a_dinz[15]   =>   b_mac_out[13]     ) = (0,0);
(a_dinz[16]   =>   b_mac_out[13]     ) = (0,0);
(a_dinz[17]   =>   b_mac_out[13]     ) = (0,0);
(a_dinz[18]   =>   b_mac_out[13]     ) = (0,0);
(a_dinz[19]   =>   b_mac_out[13]     ) = (0,0);
(a_dinz[20]   =>   b_mac_out[13]     ) = (0,0);
(a_dinz[21]   =>   b_mac_out[13]     ) = (0,0);
(a_dinz[22]   =>   b_mac_out[13]     ) = (0,0);
(a_dinz[23]   =>   b_mac_out[13]     ) = (0,0);
(a_dinz[24]   =>   b_mac_out[13]     ) = (0,0);
(b_dinz[0]    =>   b_mac_out[13]     ) = (0,0);
(b_dinz[1]    =>   b_mac_out[13]     ) = (0,0);
(b_dinz[2]    =>   b_mac_out[13]     ) = (0,0);
(b_dinz[3]    =>   b_mac_out[13]     ) = (0,0);
(b_dinz[4]    =>   b_mac_out[13]     ) = (0,0);
(b_dinz[5]    =>   b_mac_out[13]     ) = (0,0);
(b_dinz[6]    =>   b_mac_out[13]     ) = (0,0);
(b_dinz[7]    =>   b_mac_out[13]     ) = (0,0);
(b_dinz[8]    =>   b_mac_out[13]     ) = (0,0);
(b_dinz[9]    =>   b_mac_out[13]     ) = (0,0);
(b_dinz[10]   =>   b_mac_out[13]     ) = (0,0);
(b_dinz[11]   =>   b_mac_out[13]     ) = (0,0);
(b_dinz[12]   =>   b_mac_out[13]     ) = (0,0);
(b_dinz[13]   =>   b_mac_out[13]     ) = (0,0);
(b_dinz[14]   =>   b_mac_out[13]     ) = (0,0);
(b_dinz[15]   =>   b_mac_out[13]     ) = (0,0);
(b_dinz[16]   =>   b_mac_out[13]     ) = (0,0);
(a_dinz_en    =>   b_mac_out[13]     ) = (0,0);
(b_dinz_en    =>   b_mac_out[13]     ) = (0,0);
(a_dinx[0]    =>   b_mac_out[14]     ) = (0,0);
(a_dinx[1]    =>   b_mac_out[14]     ) = (0,0);
(a_dinx[2]    =>   b_mac_out[14]     ) = (0,0);
(a_dinx[3]    =>   b_mac_out[14]     ) = (0,0);
(a_dinx[4]    =>   b_mac_out[14]     ) = (0,0);
(a_dinx[5]    =>   b_mac_out[14]     ) = (0,0);
(a_dinx[6]    =>   b_mac_out[14]     ) = (0,0);
(a_dinx[7]    =>   b_mac_out[14]     ) = (0,0);
(a_dinx[8]    =>   b_mac_out[14]     ) = (0,0);
(a_dinx[9]    =>   b_mac_out[14]     ) = (0,0);
(a_dinx[10]   =>   b_mac_out[14]     ) = (0,0);
(a_dinx[11]   =>   b_mac_out[14]     ) = (0,0);
(a_dinx[12]   =>   b_mac_out[14]     ) = (0,0);
(b_dinx[0]    =>   b_mac_out[14]     ) = (0,0);
(b_dinx[1]    =>   b_mac_out[14]     ) = (0,0);
(b_dinx[2]    =>   b_mac_out[14]     ) = (0,0);
(b_dinx[3]    =>   b_mac_out[14]     ) = (0,0);
(b_dinx[4]    =>   b_mac_out[14]     ) = (0,0);
(b_dinx[5]    =>   b_mac_out[14]     ) = (0,0);
(b_dinx[6]    =>   b_mac_out[14]     ) = (0,0);
(b_dinx[7]    =>   b_mac_out[14]     ) = (0,0);
(b_dinx[8]    =>   b_mac_out[14]     ) = (0,0);
(b_dinx[9]    =>   b_mac_out[14]     ) = (0,0);
(b_dinx[10]   =>   b_mac_out[14]     ) = (0,0);
(b_dinx[11]   =>   b_mac_out[14]     ) = (0,0);
(b_dinx[12]   =>   b_mac_out[14]     ) = (0,0);
(a_diny[0]    =>   b_mac_out[14]     ) = (0,0);
(a_diny[1]    =>   b_mac_out[14]     ) = (0,0);
(a_diny[2]    =>   b_mac_out[14]     ) = (0,0);
(a_diny[3]    =>   b_mac_out[14]     ) = (0,0);
(a_diny[4]    =>   b_mac_out[14]     ) = (0,0);
(a_diny[5]    =>   b_mac_out[14]     ) = (0,0);
(a_diny[6]    =>   b_mac_out[14]     ) = (0,0);
(a_diny[7]    =>   b_mac_out[14]     ) = (0,0);
(a_diny[8]    =>   b_mac_out[14]     ) = (0,0);
(a_diny[9]    =>   b_mac_out[14]     ) = (0,0);
(b_diny[0]    =>   b_mac_out[14]     ) = (0,0);
(b_diny[1]    =>   b_mac_out[14]     ) = (0,0);
(b_diny[2]    =>   b_mac_out[14]     ) = (0,0);
(b_diny[3]    =>   b_mac_out[14]     ) = (0,0);
(b_diny[4]    =>   b_mac_out[14]     ) = (0,0);
(b_diny[5]    =>   b_mac_out[14]     ) = (0,0);
(b_diny[6]    =>   b_mac_out[14]     ) = (0,0);
(b_diny[7]    =>   b_mac_out[14]     ) = (0,0);
(b_diny[8]    =>   b_mac_out[14]     ) = (0,0);
(b_diny[9]    =>   b_mac_out[14]     ) = (0,0);
(a_dinz[0]    =>   b_mac_out[14]     ) = (0,0);
(a_dinz[1]    =>   b_mac_out[14]     ) = (0,0);
(a_dinz[2]    =>   b_mac_out[14]     ) = (0,0);
(a_dinz[3]    =>   b_mac_out[14]     ) = (0,0);
(a_dinz[4]    =>   b_mac_out[14]     ) = (0,0);
(a_dinz[5]    =>   b_mac_out[14]     ) = (0,0);
(a_dinz[6]    =>   b_mac_out[14]     ) = (0,0);
(a_dinz[7]    =>   b_mac_out[14]     ) = (0,0);
(a_dinz[8]    =>   b_mac_out[14]     ) = (0,0);
(a_dinz[9]    =>   b_mac_out[14]     ) = (0,0);
(a_dinz[10]   =>   b_mac_out[14]     ) = (0,0);
(a_dinz[11]   =>   b_mac_out[14]     ) = (0,0);
(a_dinz[12]   =>   b_mac_out[14]     ) = (0,0);
(a_dinz[13]   =>   b_mac_out[14]     ) = (0,0);
(a_dinz[14]   =>   b_mac_out[14]     ) = (0,0);
(a_dinz[15]   =>   b_mac_out[14]     ) = (0,0);
(a_dinz[16]   =>   b_mac_out[14]     ) = (0,0);
(a_dinz[17]   =>   b_mac_out[14]     ) = (0,0);
(a_dinz[18]   =>   b_mac_out[14]     ) = (0,0);
(a_dinz[19]   =>   b_mac_out[14]     ) = (0,0);
(a_dinz[20]   =>   b_mac_out[14]     ) = (0,0);
(a_dinz[21]   =>   b_mac_out[14]     ) = (0,0);
(a_dinz[22]   =>   b_mac_out[14]     ) = (0,0);
(a_dinz[23]   =>   b_mac_out[14]     ) = (0,0);
(a_dinz[24]   =>   b_mac_out[14]     ) = (0,0);
(b_dinz[0]    =>   b_mac_out[14]     ) = (0,0);
(b_dinz[1]    =>   b_mac_out[14]     ) = (0,0);
(b_dinz[2]    =>   b_mac_out[14]     ) = (0,0);
(b_dinz[3]    =>   b_mac_out[14]     ) = (0,0);
(b_dinz[4]    =>   b_mac_out[14]     ) = (0,0);
(b_dinz[5]    =>   b_mac_out[14]     ) = (0,0);
(b_dinz[6]    =>   b_mac_out[14]     ) = (0,0);
(b_dinz[7]    =>   b_mac_out[14]     ) = (0,0);
(b_dinz[8]    =>   b_mac_out[14]     ) = (0,0);
(b_dinz[9]    =>   b_mac_out[14]     ) = (0,0);
(b_dinz[10]   =>   b_mac_out[14]     ) = (0,0);
(b_dinz[11]   =>   b_mac_out[14]     ) = (0,0);
(b_dinz[12]   =>   b_mac_out[14]     ) = (0,0);
(b_dinz[13]   =>   b_mac_out[14]     ) = (0,0);
(b_dinz[14]   =>   b_mac_out[14]     ) = (0,0);
(b_dinz[15]   =>   b_mac_out[14]     ) = (0,0);
(b_dinz[16]   =>   b_mac_out[14]     ) = (0,0);
(b_dinz[17]   =>   b_mac_out[14]     ) = (0,0);
(a_dinz_en    =>   b_mac_out[14]     ) = (0,0);
(b_dinz_en    =>   b_mac_out[14]     ) = (0,0);
(a_dinx[0]    =>   b_mac_out[15]     ) = (0,0);
(a_dinx[1]    =>   b_mac_out[15]     ) = (0,0);
(a_dinx[2]    =>   b_mac_out[15]     ) = (0,0);
(a_dinx[3]    =>   b_mac_out[15]     ) = (0,0);
(a_dinx[4]    =>   b_mac_out[15]     ) = (0,0);
(a_dinx[5]    =>   b_mac_out[15]     ) = (0,0);
(a_dinx[6]    =>   b_mac_out[15]     ) = (0,0);
(a_dinx[7]    =>   b_mac_out[15]     ) = (0,0);
(a_dinx[8]    =>   b_mac_out[15]     ) = (0,0);
(a_dinx[9]    =>   b_mac_out[15]     ) = (0,0);
(a_dinx[10]   =>   b_mac_out[15]     ) = (0,0);
(a_dinx[11]   =>   b_mac_out[15]     ) = (0,0);
(a_dinx[12]   =>   b_mac_out[15]     ) = (0,0);
(b_dinx[0]    =>   b_mac_out[15]     ) = (0,0);
(b_dinx[1]    =>   b_mac_out[15]     ) = (0,0);
(b_dinx[2]    =>   b_mac_out[15]     ) = (0,0);
(b_dinx[3]    =>   b_mac_out[15]     ) = (0,0);
(b_dinx[4]    =>   b_mac_out[15]     ) = (0,0);
(b_dinx[5]    =>   b_mac_out[15]     ) = (0,0);
(b_dinx[6]    =>   b_mac_out[15]     ) = (0,0);
(b_dinx[7]    =>   b_mac_out[15]     ) = (0,0);
(b_dinx[8]    =>   b_mac_out[15]     ) = (0,0);
(b_dinx[9]    =>   b_mac_out[15]     ) = (0,0);
(b_dinx[10]   =>   b_mac_out[15]     ) = (0,0);
(b_dinx[11]   =>   b_mac_out[15]     ) = (0,0);
(b_dinx[12]   =>   b_mac_out[15]     ) = (0,0);
(a_diny[0]    =>   b_mac_out[15]     ) = (0,0);
(a_diny[1]    =>   b_mac_out[15]     ) = (0,0);
(a_diny[2]    =>   b_mac_out[15]     ) = (0,0);
(a_diny[3]    =>   b_mac_out[15]     ) = (0,0);
(a_diny[4]    =>   b_mac_out[15]     ) = (0,0);
(a_diny[5]    =>   b_mac_out[15]     ) = (0,0);
(a_diny[6]    =>   b_mac_out[15]     ) = (0,0);
(a_diny[7]    =>   b_mac_out[15]     ) = (0,0);
(a_diny[8]    =>   b_mac_out[15]     ) = (0,0);
(a_diny[9]    =>   b_mac_out[15]     ) = (0,0);
(b_diny[0]    =>   b_mac_out[15]     ) = (0,0);
(b_diny[1]    =>   b_mac_out[15]     ) = (0,0);
(b_diny[2]    =>   b_mac_out[15]     ) = (0,0);
(b_diny[3]    =>   b_mac_out[15]     ) = (0,0);
(b_diny[4]    =>   b_mac_out[15]     ) = (0,0);
(b_diny[5]    =>   b_mac_out[15]     ) = (0,0);
(b_diny[6]    =>   b_mac_out[15]     ) = (0,0);
(b_diny[7]    =>   b_mac_out[15]     ) = (0,0);
(b_diny[8]    =>   b_mac_out[15]     ) = (0,0);
(b_diny[9]    =>   b_mac_out[15]     ) = (0,0);
(a_dinz[0]    =>   b_mac_out[15]     ) = (0,0);
(a_dinz[1]    =>   b_mac_out[15]     ) = (0,0);
(a_dinz[2]    =>   b_mac_out[15]     ) = (0,0);
(a_dinz[3]    =>   b_mac_out[15]     ) = (0,0);
(a_dinz[4]    =>   b_mac_out[15]     ) = (0,0);
(a_dinz[5]    =>   b_mac_out[15]     ) = (0,0);
(a_dinz[6]    =>   b_mac_out[15]     ) = (0,0);
(a_dinz[7]    =>   b_mac_out[15]     ) = (0,0);
(a_dinz[8]    =>   b_mac_out[15]     ) = (0,0);
(a_dinz[9]    =>   b_mac_out[15]     ) = (0,0);
(a_dinz[10]   =>   b_mac_out[15]     ) = (0,0);
(a_dinz[11]   =>   b_mac_out[15]     ) = (0,0);
(a_dinz[12]   =>   b_mac_out[15]     ) = (0,0);
(a_dinz[13]   =>   b_mac_out[15]     ) = (0,0);
(a_dinz[14]   =>   b_mac_out[15]     ) = (0,0);
(a_dinz[15]   =>   b_mac_out[15]     ) = (0,0);
(a_dinz[16]   =>   b_mac_out[15]     ) = (0,0);
(a_dinz[17]   =>   b_mac_out[15]     ) = (0,0);
(a_dinz[18]   =>   b_mac_out[15]     ) = (0,0);
(a_dinz[19]   =>   b_mac_out[15]     ) = (0,0);
(a_dinz[20]   =>   b_mac_out[15]     ) = (0,0);
(a_dinz[21]   =>   b_mac_out[15]     ) = (0,0);
(a_dinz[22]   =>   b_mac_out[15]     ) = (0,0);
(a_dinz[23]   =>   b_mac_out[15]     ) = (0,0);
(a_dinz[24]   =>   b_mac_out[15]     ) = (0,0);
(b_dinz[0]    =>   b_mac_out[15]     ) = (0,0);
(b_dinz[1]    =>   b_mac_out[15]     ) = (0,0);
(b_dinz[2]    =>   b_mac_out[15]     ) = (0,0);
(b_dinz[3]    =>   b_mac_out[15]     ) = (0,0);
(b_dinz[4]    =>   b_mac_out[15]     ) = (0,0);
(b_dinz[5]    =>   b_mac_out[15]     ) = (0,0);
(b_dinz[6]    =>   b_mac_out[15]     ) = (0,0);
(b_dinz[7]    =>   b_mac_out[15]     ) = (0,0);
(b_dinz[8]    =>   b_mac_out[15]     ) = (0,0);
(b_dinz[9]    =>   b_mac_out[15]     ) = (0,0);
(b_dinz[10]   =>   b_mac_out[15]     ) = (0,0);
(b_dinz[11]   =>   b_mac_out[15]     ) = (0,0);
(b_dinz[12]   =>   b_mac_out[15]     ) = (0,0);
(b_dinz[13]   =>   b_mac_out[15]     ) = (0,0);
(b_dinz[14]   =>   b_mac_out[15]     ) = (0,0);
(b_dinz[15]   =>   b_mac_out[15]     ) = (0,0);
(b_dinz[16]   =>   b_mac_out[15]     ) = (0,0);
(b_dinz[17]   =>   b_mac_out[15]     ) = (0,0);
(b_dinz[18]   =>   b_mac_out[15]     ) = (0,0);
(a_dinz_en    =>   b_mac_out[15]     ) = (0,0);
(b_dinz_en    =>   b_mac_out[15]     ) = (0,0);
(a_dinx[0]    =>   b_mac_out[16]     ) = (0,0);
(a_dinx[1]    =>   b_mac_out[16]     ) = (0,0);
(a_dinx[2]    =>   b_mac_out[16]     ) = (0,0);
(a_dinx[3]    =>   b_mac_out[16]     ) = (0,0);
(a_dinx[4]    =>   b_mac_out[16]     ) = (0,0);
(a_dinx[5]    =>   b_mac_out[16]     ) = (0,0);
(a_dinx[6]    =>   b_mac_out[16]     ) = (0,0);
(a_dinx[7]    =>   b_mac_out[16]     ) = (0,0);
(a_dinx[8]    =>   b_mac_out[16]     ) = (0,0);
(a_dinx[9]    =>   b_mac_out[16]     ) = (0,0);
(a_dinx[10]   =>   b_mac_out[16]     ) = (0,0);
(a_dinx[11]   =>   b_mac_out[16]     ) = (0,0);
(a_dinx[12]   =>   b_mac_out[16]     ) = (0,0);
(b_dinx[0]    =>   b_mac_out[16]     ) = (0,0);
(b_dinx[1]    =>   b_mac_out[16]     ) = (0,0);
(b_dinx[2]    =>   b_mac_out[16]     ) = (0,0);
(b_dinx[3]    =>   b_mac_out[16]     ) = (0,0);
(b_dinx[4]    =>   b_mac_out[16]     ) = (0,0);
(b_dinx[5]    =>   b_mac_out[16]     ) = (0,0);
(b_dinx[6]    =>   b_mac_out[16]     ) = (0,0);
(b_dinx[7]    =>   b_mac_out[16]     ) = (0,0);
(b_dinx[8]    =>   b_mac_out[16]     ) = (0,0);
(b_dinx[9]    =>   b_mac_out[16]     ) = (0,0);
(b_dinx[10]   =>   b_mac_out[16]     ) = (0,0);
(b_dinx[11]   =>   b_mac_out[16]     ) = (0,0);
(b_dinx[12]   =>   b_mac_out[16]     ) = (0,0);
(a_diny[0]    =>   b_mac_out[16]     ) = (0,0);
(a_diny[1]    =>   b_mac_out[16]     ) = (0,0);
(a_diny[2]    =>   b_mac_out[16]     ) = (0,0);
(a_diny[3]    =>   b_mac_out[16]     ) = (0,0);
(a_diny[4]    =>   b_mac_out[16]     ) = (0,0);
(a_diny[5]    =>   b_mac_out[16]     ) = (0,0);
(a_diny[6]    =>   b_mac_out[16]     ) = (0,0);
(a_diny[7]    =>   b_mac_out[16]     ) = (0,0);
(a_diny[8]    =>   b_mac_out[16]     ) = (0,0);
(a_diny[9]    =>   b_mac_out[16]     ) = (0,0);
(b_diny[0]    =>   b_mac_out[16]     ) = (0,0);
(b_diny[1]    =>   b_mac_out[16]     ) = (0,0);
(b_diny[2]    =>   b_mac_out[16]     ) = (0,0);
(b_diny[3]    =>   b_mac_out[16]     ) = (0,0);
(b_diny[4]    =>   b_mac_out[16]     ) = (0,0);
(b_diny[5]    =>   b_mac_out[16]     ) = (0,0);
(b_diny[6]    =>   b_mac_out[16]     ) = (0,0);
(b_diny[7]    =>   b_mac_out[16]     ) = (0,0);
(b_diny[8]    =>   b_mac_out[16]     ) = (0,0);
(b_diny[9]    =>   b_mac_out[16]     ) = (0,0);
(a_dinz[0]    =>   b_mac_out[16]     ) = (0,0);
(a_dinz[1]    =>   b_mac_out[16]     ) = (0,0);
(a_dinz[2]    =>   b_mac_out[16]     ) = (0,0);
(a_dinz[3]    =>   b_mac_out[16]     ) = (0,0);
(a_dinz[4]    =>   b_mac_out[16]     ) = (0,0);
(a_dinz[5]    =>   b_mac_out[16]     ) = (0,0);
(a_dinz[6]    =>   b_mac_out[16]     ) = (0,0);
(a_dinz[7]    =>   b_mac_out[16]     ) = (0,0);
(a_dinz[8]    =>   b_mac_out[16]     ) = (0,0);
(a_dinz[9]    =>   b_mac_out[16]     ) = (0,0);
(a_dinz[10]   =>   b_mac_out[16]     ) = (0,0);
(a_dinz[11]   =>   b_mac_out[16]     ) = (0,0);
(a_dinz[12]   =>   b_mac_out[16]     ) = (0,0);
(a_dinz[13]   =>   b_mac_out[16]     ) = (0,0);
(a_dinz[14]   =>   b_mac_out[16]     ) = (0,0);
(a_dinz[15]   =>   b_mac_out[16]     ) = (0,0);
(a_dinz[16]   =>   b_mac_out[16]     ) = (0,0);
(a_dinz[17]   =>   b_mac_out[16]     ) = (0,0);
(a_dinz[18]   =>   b_mac_out[16]     ) = (0,0);
(a_dinz[19]   =>   b_mac_out[16]     ) = (0,0);
(a_dinz[20]   =>   b_mac_out[16]     ) = (0,0);
(a_dinz[21]   =>   b_mac_out[16]     ) = (0,0);
(a_dinz[22]   =>   b_mac_out[16]     ) = (0,0);
(a_dinz[23]   =>   b_mac_out[16]     ) = (0,0);
(a_dinz[24]   =>   b_mac_out[16]     ) = (0,0);
(b_dinz[0]    =>   b_mac_out[16]     ) = (0,0);
(b_dinz[1]    =>   b_mac_out[16]     ) = (0,0);
(b_dinz[2]    =>   b_mac_out[16]     ) = (0,0);
(b_dinz[3]    =>   b_mac_out[16]     ) = (0,0);
(b_dinz[4]    =>   b_mac_out[16]     ) = (0,0);
(b_dinz[5]    =>   b_mac_out[16]     ) = (0,0);
(b_dinz[6]    =>   b_mac_out[16]     ) = (0,0);
(b_dinz[7]    =>   b_mac_out[16]     ) = (0,0);
(b_dinz[8]    =>   b_mac_out[16]     ) = (0,0);
(b_dinz[9]    =>   b_mac_out[16]     ) = (0,0);
(b_dinz[10]   =>   b_mac_out[16]     ) = (0,0);
(b_dinz[11]   =>   b_mac_out[16]     ) = (0,0);
(b_dinz[12]   =>   b_mac_out[16]     ) = (0,0);
(b_dinz[13]   =>   b_mac_out[16]     ) = (0,0);
(b_dinz[14]   =>   b_mac_out[16]     ) = (0,0);
(b_dinz[15]   =>   b_mac_out[16]     ) = (0,0);
(b_dinz[16]   =>   b_mac_out[16]     ) = (0,0);
(b_dinz[17]   =>   b_mac_out[16]     ) = (0,0);
(b_dinz[18]   =>   b_mac_out[16]     ) = (0,0);
(b_dinz[19]   =>   b_mac_out[16]     ) = (0,0);
(a_dinz_en    =>   b_mac_out[16]     ) = (0,0);
(b_dinz_en    =>   b_mac_out[16]     ) = (0,0);
(a_dinx[0]    =>   b_mac_out[17]     ) = (0,0);
(a_dinx[1]    =>   b_mac_out[17]     ) = (0,0);
(a_dinx[2]    =>   b_mac_out[17]     ) = (0,0);
(a_dinx[3]    =>   b_mac_out[17]     ) = (0,0);
(a_dinx[4]    =>   b_mac_out[17]     ) = (0,0);
(a_dinx[5]    =>   b_mac_out[17]     ) = (0,0);
(a_dinx[6]    =>   b_mac_out[17]     ) = (0,0);
(a_dinx[7]    =>   b_mac_out[17]     ) = (0,0);
(a_dinx[8]    =>   b_mac_out[17]     ) = (0,0);
(a_dinx[9]    =>   b_mac_out[17]     ) = (0,0);
(a_dinx[10]   =>   b_mac_out[17]     ) = (0,0);
(a_dinx[11]   =>   b_mac_out[17]     ) = (0,0);
(a_dinx[12]   =>   b_mac_out[17]     ) = (0,0);
(b_dinx[0]    =>   b_mac_out[17]     ) = (0,0);
(b_dinx[1]    =>   b_mac_out[17]     ) = (0,0);
(b_dinx[2]    =>   b_mac_out[17]     ) = (0,0);
(b_dinx[3]    =>   b_mac_out[17]     ) = (0,0);
(b_dinx[4]    =>   b_mac_out[17]     ) = (0,0);
(b_dinx[5]    =>   b_mac_out[17]     ) = (0,0);
(b_dinx[6]    =>   b_mac_out[17]     ) = (0,0);
(b_dinx[7]    =>   b_mac_out[17]     ) = (0,0);
(b_dinx[8]    =>   b_mac_out[17]     ) = (0,0);
(b_dinx[9]    =>   b_mac_out[17]     ) = (0,0);
(b_dinx[10]   =>   b_mac_out[17]     ) = (0,0);
(b_dinx[11]   =>   b_mac_out[17]     ) = (0,0);
(b_dinx[12]   =>   b_mac_out[17]     ) = (0,0);
(a_diny[0]    =>   b_mac_out[17]     ) = (0,0);
(a_diny[1]    =>   b_mac_out[17]     ) = (0,0);
(a_diny[2]    =>   b_mac_out[17]     ) = (0,0);
(a_diny[3]    =>   b_mac_out[17]     ) = (0,0);
(a_diny[4]    =>   b_mac_out[17]     ) = (0,0);
(a_diny[5]    =>   b_mac_out[17]     ) = (0,0);
(a_diny[6]    =>   b_mac_out[17]     ) = (0,0);
(a_diny[7]    =>   b_mac_out[17]     ) = (0,0);
(a_diny[8]    =>   b_mac_out[17]     ) = (0,0);
(a_diny[9]    =>   b_mac_out[17]     ) = (0,0);
(b_diny[0]    =>   b_mac_out[17]     ) = (0,0);
(b_diny[1]    =>   b_mac_out[17]     ) = (0,0);
(b_diny[2]    =>   b_mac_out[17]     ) = (0,0);
(b_diny[3]    =>   b_mac_out[17]     ) = (0,0);
(b_diny[4]    =>   b_mac_out[17]     ) = (0,0);
(b_diny[5]    =>   b_mac_out[17]     ) = (0,0);
(b_diny[6]    =>   b_mac_out[17]     ) = (0,0);
(b_diny[7]    =>   b_mac_out[17]     ) = (0,0);
(b_diny[8]    =>   b_mac_out[17]     ) = (0,0);
(b_diny[9]    =>   b_mac_out[17]     ) = (0,0);
(a_dinz[0]    =>   b_mac_out[17]     ) = (0,0);
(a_dinz[1]    =>   b_mac_out[17]     ) = (0,0);
(a_dinz[2]    =>   b_mac_out[17]     ) = (0,0);
(a_dinz[3]    =>   b_mac_out[17]     ) = (0,0);
(a_dinz[4]    =>   b_mac_out[17]     ) = (0,0);
(a_dinz[5]    =>   b_mac_out[17]     ) = (0,0);
(a_dinz[6]    =>   b_mac_out[17]     ) = (0,0);
(a_dinz[7]    =>   b_mac_out[17]     ) = (0,0);
(a_dinz[8]    =>   b_mac_out[17]     ) = (0,0);
(a_dinz[9]    =>   b_mac_out[17]     ) = (0,0);
(a_dinz[10]   =>   b_mac_out[17]     ) = (0,0);
(a_dinz[11]   =>   b_mac_out[17]     ) = (0,0);
(a_dinz[12]   =>   b_mac_out[17]     ) = (0,0);
(a_dinz[13]   =>   b_mac_out[17]     ) = (0,0);
(a_dinz[14]   =>   b_mac_out[17]     ) = (0,0);
(a_dinz[15]   =>   b_mac_out[17]     ) = (0,0);
(a_dinz[16]   =>   b_mac_out[17]     ) = (0,0);
(a_dinz[17]   =>   b_mac_out[17]     ) = (0,0);
(a_dinz[18]   =>   b_mac_out[17]     ) = (0,0);
(a_dinz[19]   =>   b_mac_out[17]     ) = (0,0);
(a_dinz[20]   =>   b_mac_out[17]     ) = (0,0);
(a_dinz[21]   =>   b_mac_out[17]     ) = (0,0);
(a_dinz[22]   =>   b_mac_out[17]     ) = (0,0);
(a_dinz[23]   =>   b_mac_out[17]     ) = (0,0);
(a_dinz[24]   =>   b_mac_out[17]     ) = (0,0);
(b_dinz[0]    =>   b_mac_out[17]     ) = (0,0);
(b_dinz[1]    =>   b_mac_out[17]     ) = (0,0);
(b_dinz[2]    =>   b_mac_out[17]     ) = (0,0);
(b_dinz[3]    =>   b_mac_out[17]     ) = (0,0);
(b_dinz[4]    =>   b_mac_out[17]     ) = (0,0);
(b_dinz[5]    =>   b_mac_out[17]     ) = (0,0);
(b_dinz[6]    =>   b_mac_out[17]     ) = (0,0);
(b_dinz[7]    =>   b_mac_out[17]     ) = (0,0);
(b_dinz[8]    =>   b_mac_out[17]     ) = (0,0);
(b_dinz[9]    =>   b_mac_out[17]     ) = (0,0);
(b_dinz[10]   =>   b_mac_out[17]     ) = (0,0);
(b_dinz[11]   =>   b_mac_out[17]     ) = (0,0);
(b_dinz[12]   =>   b_mac_out[17]     ) = (0,0);
(b_dinz[13]   =>   b_mac_out[17]     ) = (0,0);
(b_dinz[14]   =>   b_mac_out[17]     ) = (0,0);
(b_dinz[15]   =>   b_mac_out[17]     ) = (0,0);
(b_dinz[16]   =>   b_mac_out[17]     ) = (0,0);
(b_dinz[17]   =>   b_mac_out[17]     ) = (0,0);
(b_dinz[18]   =>   b_mac_out[17]     ) = (0,0);
(b_dinz[19]   =>   b_mac_out[17]     ) = (0,0);
(b_dinz[20]   =>   b_mac_out[17]     ) = (0,0);
(a_dinz_en    =>   b_mac_out[17]     ) = (0,0);
(b_dinz_en    =>   b_mac_out[17]     ) = (0,0);
(a_dinx[0]    =>   b_mac_out[18]     ) = (0,0);
(a_dinx[1]    =>   b_mac_out[18]     ) = (0,0);
(a_dinx[2]    =>   b_mac_out[18]     ) = (0,0);
(a_dinx[3]    =>   b_mac_out[18]     ) = (0,0);
(a_dinx[4]    =>   b_mac_out[18]     ) = (0,0);
(a_dinx[5]    =>   b_mac_out[18]     ) = (0,0);
(a_dinx[6]    =>   b_mac_out[18]     ) = (0,0);
(a_dinx[7]    =>   b_mac_out[18]     ) = (0,0);
(a_dinx[8]    =>   b_mac_out[18]     ) = (0,0);
(a_dinx[9]    =>   b_mac_out[18]     ) = (0,0);
(a_dinx[10]   =>   b_mac_out[18]     ) = (0,0);
(a_dinx[11]   =>   b_mac_out[18]     ) = (0,0);
(a_dinx[12]   =>   b_mac_out[18]     ) = (0,0);
(b_dinx[0]    =>   b_mac_out[18]     ) = (0,0);
(b_dinx[1]    =>   b_mac_out[18]     ) = (0,0);
(b_dinx[2]    =>   b_mac_out[18]     ) = (0,0);
(b_dinx[3]    =>   b_mac_out[18]     ) = (0,0);
(b_dinx[4]    =>   b_mac_out[18]     ) = (0,0);
(b_dinx[5]    =>   b_mac_out[18]     ) = (0,0);
(b_dinx[6]    =>   b_mac_out[18]     ) = (0,0);
(b_dinx[7]    =>   b_mac_out[18]     ) = (0,0);
(b_dinx[8]    =>   b_mac_out[18]     ) = (0,0);
(b_dinx[9]    =>   b_mac_out[18]     ) = (0,0);
(b_dinx[10]   =>   b_mac_out[18]     ) = (0,0);
(b_dinx[11]   =>   b_mac_out[18]     ) = (0,0);
(b_dinx[12]   =>   b_mac_out[18]     ) = (0,0);
(a_diny[0]    =>   b_mac_out[18]     ) = (0,0);
(a_diny[1]    =>   b_mac_out[18]     ) = (0,0);
(a_diny[2]    =>   b_mac_out[18]     ) = (0,0);
(a_diny[3]    =>   b_mac_out[18]     ) = (0,0);
(a_diny[4]    =>   b_mac_out[18]     ) = (0,0);
(a_diny[5]    =>   b_mac_out[18]     ) = (0,0);
(a_diny[6]    =>   b_mac_out[18]     ) = (0,0);
(a_diny[7]    =>   b_mac_out[18]     ) = (0,0);
(a_diny[8]    =>   b_mac_out[18]     ) = (0,0);
(a_diny[9]    =>   b_mac_out[18]     ) = (0,0);
(b_diny[0]    =>   b_mac_out[18]     ) = (0,0);
(b_diny[1]    =>   b_mac_out[18]     ) = (0,0);
(b_diny[2]    =>   b_mac_out[18]     ) = (0,0);
(b_diny[3]    =>   b_mac_out[18]     ) = (0,0);
(b_diny[4]    =>   b_mac_out[18]     ) = (0,0);
(b_diny[5]    =>   b_mac_out[18]     ) = (0,0);
(b_diny[6]    =>   b_mac_out[18]     ) = (0,0);
(b_diny[7]    =>   b_mac_out[18]     ) = (0,0);
(b_diny[8]    =>   b_mac_out[18]     ) = (0,0);
(b_diny[9]    =>   b_mac_out[18]     ) = (0,0);
(a_dinz[0]    =>   b_mac_out[18]     ) = (0,0);
(a_dinz[1]    =>   b_mac_out[18]     ) = (0,0);
(a_dinz[2]    =>   b_mac_out[18]     ) = (0,0);
(a_dinz[3]    =>   b_mac_out[18]     ) = (0,0);
(a_dinz[4]    =>   b_mac_out[18]     ) = (0,0);
(a_dinz[5]    =>   b_mac_out[18]     ) = (0,0);
(a_dinz[6]    =>   b_mac_out[18]     ) = (0,0);
(a_dinz[7]    =>   b_mac_out[18]     ) = (0,0);
(a_dinz[8]    =>   b_mac_out[18]     ) = (0,0);
(a_dinz[9]    =>   b_mac_out[18]     ) = (0,0);
(a_dinz[10]   =>   b_mac_out[18]     ) = (0,0);
(a_dinz[11]   =>   b_mac_out[18]     ) = (0,0);
(a_dinz[12]   =>   b_mac_out[18]     ) = (0,0);
(a_dinz[13]   =>   b_mac_out[18]     ) = (0,0);
(a_dinz[14]   =>   b_mac_out[18]     ) = (0,0);
(a_dinz[15]   =>   b_mac_out[18]     ) = (0,0);
(a_dinz[16]   =>   b_mac_out[18]     ) = (0,0);
(a_dinz[17]   =>   b_mac_out[18]     ) = (0,0);
(a_dinz[18]   =>   b_mac_out[18]     ) = (0,0);
(a_dinz[19]   =>   b_mac_out[18]     ) = (0,0);
(a_dinz[20]   =>   b_mac_out[18]     ) = (0,0);
(a_dinz[21]   =>   b_mac_out[18]     ) = (0,0);
(a_dinz[22]   =>   b_mac_out[18]     ) = (0,0);
(a_dinz[23]   =>   b_mac_out[18]     ) = (0,0);
(a_dinz[24]   =>   b_mac_out[18]     ) = (0,0);
(b_dinz[0]    =>   b_mac_out[18]     ) = (0,0);
(b_dinz[1]    =>   b_mac_out[18]     ) = (0,0);
(b_dinz[2]    =>   b_mac_out[18]     ) = (0,0);
(b_dinz[3]    =>   b_mac_out[18]     ) = (0,0);
(b_dinz[4]    =>   b_mac_out[18]     ) = (0,0);
(b_dinz[5]    =>   b_mac_out[18]     ) = (0,0);
(b_dinz[6]    =>   b_mac_out[18]     ) = (0,0);
(b_dinz[7]    =>   b_mac_out[18]     ) = (0,0);
(b_dinz[8]    =>   b_mac_out[18]     ) = (0,0);
(b_dinz[9]    =>   b_mac_out[18]     ) = (0,0);
(b_dinz[10]   =>   b_mac_out[18]     ) = (0,0);
(b_dinz[11]   =>   b_mac_out[18]     ) = (0,0);
(b_dinz[12]   =>   b_mac_out[18]     ) = (0,0);
(b_dinz[13]   =>   b_mac_out[18]     ) = (0,0);
(b_dinz[14]   =>   b_mac_out[18]     ) = (0,0);
(b_dinz[15]   =>   b_mac_out[18]     ) = (0,0);
(b_dinz[16]   =>   b_mac_out[18]     ) = (0,0);
(b_dinz[17]   =>   b_mac_out[18]     ) = (0,0);
(b_dinz[18]   =>   b_mac_out[18]     ) = (0,0);
(b_dinz[19]   =>   b_mac_out[18]     ) = (0,0);
(b_dinz[20]   =>   b_mac_out[18]     ) = (0,0);
(b_dinz[21]   =>   b_mac_out[18]     ) = (0,0);
(a_dinz_en    =>   b_mac_out[18]     ) = (0,0);
(b_dinz_en    =>   b_mac_out[18]     ) = (0,0);
(a_dinx[0]    =>   b_mac_out[19]     ) = (0,0);
(a_dinx[1]    =>   b_mac_out[19]     ) = (0,0);
(a_dinx[2]    =>   b_mac_out[19]     ) = (0,0);
(a_dinx[3]    =>   b_mac_out[19]     ) = (0,0);
(a_dinx[4]    =>   b_mac_out[19]     ) = (0,0);
(a_dinx[5]    =>   b_mac_out[19]     ) = (0,0);
(a_dinx[6]    =>   b_mac_out[19]     ) = (0,0);
(a_dinx[7]    =>   b_mac_out[19]     ) = (0,0);
(a_dinx[8]    =>   b_mac_out[19]     ) = (0,0);
(a_dinx[9]    =>   b_mac_out[19]     ) = (0,0);
(a_dinx[10]   =>   b_mac_out[19]     ) = (0,0);
(a_dinx[11]   =>   b_mac_out[19]     ) = (0,0);
(a_dinx[12]   =>   b_mac_out[19]     ) = (0,0);
(b_dinx[0]    =>   b_mac_out[19]     ) = (0,0);
(b_dinx[1]    =>   b_mac_out[19]     ) = (0,0);
(b_dinx[2]    =>   b_mac_out[19]     ) = (0,0);
(b_dinx[3]    =>   b_mac_out[19]     ) = (0,0);
(b_dinx[4]    =>   b_mac_out[19]     ) = (0,0);
(b_dinx[5]    =>   b_mac_out[19]     ) = (0,0);
(b_dinx[6]    =>   b_mac_out[19]     ) = (0,0);
(b_dinx[7]    =>   b_mac_out[19]     ) = (0,0);
(b_dinx[8]    =>   b_mac_out[19]     ) = (0,0);
(b_dinx[9]    =>   b_mac_out[19]     ) = (0,0);
(b_dinx[10]   =>   b_mac_out[19]     ) = (0,0);
(b_dinx[11]   =>   b_mac_out[19]     ) = (0,0);
(b_dinx[12]   =>   b_mac_out[19]     ) = (0,0);
(a_diny[0]    =>   b_mac_out[19]     ) = (0,0);
(a_diny[1]    =>   b_mac_out[19]     ) = (0,0);
(a_diny[2]    =>   b_mac_out[19]     ) = (0,0);
(a_diny[3]    =>   b_mac_out[19]     ) = (0,0);
(a_diny[4]    =>   b_mac_out[19]     ) = (0,0);
(a_diny[5]    =>   b_mac_out[19]     ) = (0,0);
(a_diny[6]    =>   b_mac_out[19]     ) = (0,0);
(a_diny[7]    =>   b_mac_out[19]     ) = (0,0);
(a_diny[8]    =>   b_mac_out[19]     ) = (0,0);
(a_diny[9]    =>   b_mac_out[19]     ) = (0,0);
(b_diny[0]    =>   b_mac_out[19]     ) = (0,0);
(b_diny[1]    =>   b_mac_out[19]     ) = (0,0);
(b_diny[2]    =>   b_mac_out[19]     ) = (0,0);
(b_diny[3]    =>   b_mac_out[19]     ) = (0,0);
(b_diny[4]    =>   b_mac_out[19]     ) = (0,0);
(b_diny[5]    =>   b_mac_out[19]     ) = (0,0);
(b_diny[6]    =>   b_mac_out[19]     ) = (0,0);
(b_diny[7]    =>   b_mac_out[19]     ) = (0,0);
(b_diny[8]    =>   b_mac_out[19]     ) = (0,0);
(b_diny[9]    =>   b_mac_out[19]     ) = (0,0);
(a_dinz[0]    =>   b_mac_out[19]     ) = (0,0);
(a_dinz[1]    =>   b_mac_out[19]     ) = (0,0);
(a_dinz[2]    =>   b_mac_out[19]     ) = (0,0);
(a_dinz[3]    =>   b_mac_out[19]     ) = (0,0);
(a_dinz[4]    =>   b_mac_out[19]     ) = (0,0);
(a_dinz[5]    =>   b_mac_out[19]     ) = (0,0);
(a_dinz[6]    =>   b_mac_out[19]     ) = (0,0);
(a_dinz[7]    =>   b_mac_out[19]     ) = (0,0);
(a_dinz[8]    =>   b_mac_out[19]     ) = (0,0);
(a_dinz[9]    =>   b_mac_out[19]     ) = (0,0);
(a_dinz[10]   =>   b_mac_out[19]     ) = (0,0);
(a_dinz[11]   =>   b_mac_out[19]     ) = (0,0);
(a_dinz[12]   =>   b_mac_out[19]     ) = (0,0);
(a_dinz[13]   =>   b_mac_out[19]     ) = (0,0);
(a_dinz[14]   =>   b_mac_out[19]     ) = (0,0);
(a_dinz[15]   =>   b_mac_out[19]     ) = (0,0);
(a_dinz[16]   =>   b_mac_out[19]     ) = (0,0);
(a_dinz[17]   =>   b_mac_out[19]     ) = (0,0);
(a_dinz[18]   =>   b_mac_out[19]     ) = (0,0);
(a_dinz[19]   =>   b_mac_out[19]     ) = (0,0);
(a_dinz[20]   =>   b_mac_out[19]     ) = (0,0);
(a_dinz[21]   =>   b_mac_out[19]     ) = (0,0);
(a_dinz[22]   =>   b_mac_out[19]     ) = (0,0);
(a_dinz[23]   =>   b_mac_out[19]     ) = (0,0);
(a_dinz[24]   =>   b_mac_out[19]     ) = (0,0);
(b_dinz[0]    =>   b_mac_out[19]     ) = (0,0);
(b_dinz[1]    =>   b_mac_out[19]     ) = (0,0);
(b_dinz[2]    =>   b_mac_out[19]     ) = (0,0);
(b_dinz[3]    =>   b_mac_out[19]     ) = (0,0);
(b_dinz[4]    =>   b_mac_out[19]     ) = (0,0);
(b_dinz[5]    =>   b_mac_out[19]     ) = (0,0);
(b_dinz[6]    =>   b_mac_out[19]     ) = (0,0);
(b_dinz[7]    =>   b_mac_out[19]     ) = (0,0);
(b_dinz[8]    =>   b_mac_out[19]     ) = (0,0);
(b_dinz[9]    =>   b_mac_out[19]     ) = (0,0);
(b_dinz[10]   =>   b_mac_out[19]     ) = (0,0);
(b_dinz[11]   =>   b_mac_out[19]     ) = (0,0);
(b_dinz[12]   =>   b_mac_out[19]     ) = (0,0);
(b_dinz[13]   =>   b_mac_out[19]     ) = (0,0);
(b_dinz[14]   =>   b_mac_out[19]     ) = (0,0);
(b_dinz[15]   =>   b_mac_out[19]     ) = (0,0);
(b_dinz[16]   =>   b_mac_out[19]     ) = (0,0);
(b_dinz[17]   =>   b_mac_out[19]     ) = (0,0);
(b_dinz[18]   =>   b_mac_out[19]     ) = (0,0);
(b_dinz[19]   =>   b_mac_out[19]     ) = (0,0);
(b_dinz[20]   =>   b_mac_out[19]     ) = (0,0);
(b_dinz[21]   =>   b_mac_out[19]     ) = (0,0);
(b_dinz[22]   =>   b_mac_out[19]     ) = (0,0);
(a_dinz_en    =>   b_mac_out[19]     ) = (0,0);
(b_dinz_en    =>   b_mac_out[19]     ) = (0,0);
(a_dinx[0]    =>   b_mac_out[20]     ) = (0,0);
(a_dinx[1]    =>   b_mac_out[20]     ) = (0,0);
(a_dinx[2]    =>   b_mac_out[20]     ) = (0,0);
(a_dinx[3]    =>   b_mac_out[20]     ) = (0,0);
(a_dinx[4]    =>   b_mac_out[20]     ) = (0,0);
(a_dinx[5]    =>   b_mac_out[20]     ) = (0,0);
(a_dinx[6]    =>   b_mac_out[20]     ) = (0,0);
(a_dinx[7]    =>   b_mac_out[20]     ) = (0,0);
(a_dinx[8]    =>   b_mac_out[20]     ) = (0,0);
(a_dinx[9]    =>   b_mac_out[20]     ) = (0,0);
(a_dinx[10]   =>   b_mac_out[20]     ) = (0,0);
(a_dinx[11]   =>   b_mac_out[20]     ) = (0,0);
(a_dinx[12]   =>   b_mac_out[20]     ) = (0,0);
(b_dinx[0]    =>   b_mac_out[20]     ) = (0,0);
(b_dinx[1]    =>   b_mac_out[20]     ) = (0,0);
(b_dinx[2]    =>   b_mac_out[20]     ) = (0,0);
(b_dinx[3]    =>   b_mac_out[20]     ) = (0,0);
(b_dinx[4]    =>   b_mac_out[20]     ) = (0,0);
(b_dinx[5]    =>   b_mac_out[20]     ) = (0,0);
(b_dinx[6]    =>   b_mac_out[20]     ) = (0,0);
(b_dinx[7]    =>   b_mac_out[20]     ) = (0,0);
(b_dinx[8]    =>   b_mac_out[20]     ) = (0,0);
(b_dinx[9]    =>   b_mac_out[20]     ) = (0,0);
(b_dinx[10]   =>   b_mac_out[20]     ) = (0,0);
(b_dinx[11]   =>   b_mac_out[20]     ) = (0,0);
(b_dinx[12]   =>   b_mac_out[20]     ) = (0,0);
(a_diny[0]    =>   b_mac_out[20]     ) = (0,0);
(a_diny[1]    =>   b_mac_out[20]     ) = (0,0);
(a_diny[2]    =>   b_mac_out[20]     ) = (0,0);
(a_diny[3]    =>   b_mac_out[20]     ) = (0,0);
(a_diny[4]    =>   b_mac_out[20]     ) = (0,0);
(a_diny[5]    =>   b_mac_out[20]     ) = (0,0);
(a_diny[6]    =>   b_mac_out[20]     ) = (0,0);
(a_diny[7]    =>   b_mac_out[20]     ) = (0,0);
(a_diny[8]    =>   b_mac_out[20]     ) = (0,0);
(a_diny[9]    =>   b_mac_out[20]     ) = (0,0);
(b_diny[0]    =>   b_mac_out[20]     ) = (0,0);
(b_diny[1]    =>   b_mac_out[20]     ) = (0,0);
(b_diny[2]    =>   b_mac_out[20]     ) = (0,0);
(b_diny[3]    =>   b_mac_out[20]     ) = (0,0);
(b_diny[4]    =>   b_mac_out[20]     ) = (0,0);
(b_diny[5]    =>   b_mac_out[20]     ) = (0,0);
(b_diny[6]    =>   b_mac_out[20]     ) = (0,0);
(b_diny[7]    =>   b_mac_out[20]     ) = (0,0);
(b_diny[8]    =>   b_mac_out[20]     ) = (0,0);
(b_diny[9]    =>   b_mac_out[20]     ) = (0,0);
(a_dinz[0]    =>   b_mac_out[20]     ) = (0,0);
(a_dinz[1]    =>   b_mac_out[20]     ) = (0,0);
(a_dinz[2]    =>   b_mac_out[20]     ) = (0,0);
(a_dinz[3]    =>   b_mac_out[20]     ) = (0,0);
(a_dinz[4]    =>   b_mac_out[20]     ) = (0,0);
(a_dinz[5]    =>   b_mac_out[20]     ) = (0,0);
(a_dinz[6]    =>   b_mac_out[20]     ) = (0,0);
(a_dinz[7]    =>   b_mac_out[20]     ) = (0,0);
(a_dinz[8]    =>   b_mac_out[20]     ) = (0,0);
(a_dinz[9]    =>   b_mac_out[20]     ) = (0,0);
(a_dinz[10]   =>   b_mac_out[20]     ) = (0,0);
(a_dinz[11]   =>   b_mac_out[20]     ) = (0,0);
(a_dinz[12]   =>   b_mac_out[20]     ) = (0,0);
(a_dinz[13]   =>   b_mac_out[20]     ) = (0,0);
(a_dinz[14]   =>   b_mac_out[20]     ) = (0,0);
(a_dinz[15]   =>   b_mac_out[20]     ) = (0,0);
(a_dinz[16]   =>   b_mac_out[20]     ) = (0,0);
(a_dinz[17]   =>   b_mac_out[20]     ) = (0,0);
(a_dinz[18]   =>   b_mac_out[20]     ) = (0,0);
(a_dinz[19]   =>   b_mac_out[20]     ) = (0,0);
(a_dinz[20]   =>   b_mac_out[20]     ) = (0,0);
(a_dinz[21]   =>   b_mac_out[20]     ) = (0,0);
(a_dinz[22]   =>   b_mac_out[20]     ) = (0,0);
(a_dinz[23]   =>   b_mac_out[20]     ) = (0,0);
(a_dinz[24]   =>   b_mac_out[20]     ) = (0,0);
(b_dinz[0]    =>   b_mac_out[20]     ) = (0,0);
(b_dinz[1]    =>   b_mac_out[20]     ) = (0,0);
(b_dinz[2]    =>   b_mac_out[20]     ) = (0,0);
(b_dinz[3]    =>   b_mac_out[20]     ) = (0,0);
(b_dinz[4]    =>   b_mac_out[20]     ) = (0,0);
(b_dinz[5]    =>   b_mac_out[20]     ) = (0,0);
(b_dinz[6]    =>   b_mac_out[20]     ) = (0,0);
(b_dinz[7]    =>   b_mac_out[20]     ) = (0,0);
(b_dinz[8]    =>   b_mac_out[20]     ) = (0,0);
(b_dinz[9]    =>   b_mac_out[20]     ) = (0,0);
(b_dinz[10]   =>   b_mac_out[20]     ) = (0,0);
(b_dinz[11]   =>   b_mac_out[20]     ) = (0,0);
(b_dinz[12]   =>   b_mac_out[20]     ) = (0,0);
(b_dinz[13]   =>   b_mac_out[20]     ) = (0,0);
(b_dinz[14]   =>   b_mac_out[20]     ) = (0,0);
(b_dinz[15]   =>   b_mac_out[20]     ) = (0,0);
(b_dinz[16]   =>   b_mac_out[20]     ) = (0,0);
(b_dinz[17]   =>   b_mac_out[20]     ) = (0,0);
(b_dinz[18]   =>   b_mac_out[20]     ) = (0,0);
(b_dinz[19]   =>   b_mac_out[20]     ) = (0,0);
(b_dinz[20]   =>   b_mac_out[20]     ) = (0,0);
(b_dinz[21]   =>   b_mac_out[20]     ) = (0,0);
(b_dinz[22]   =>   b_mac_out[20]     ) = (0,0);
(b_dinz[23]   =>   b_mac_out[20]     ) = (0,0);
(a_dinz_en    =>   b_mac_out[20]     ) = (0,0);
(b_dinz_en    =>   b_mac_out[20]     ) = (0,0);
(a_dinx[0]    =>   b_mac_out[21]     ) = (0,0);
(a_dinx[1]    =>   b_mac_out[21]     ) = (0,0);
(a_dinx[2]    =>   b_mac_out[21]     ) = (0,0);
(a_dinx[3]    =>   b_mac_out[21]     ) = (0,0);
(a_dinx[4]    =>   b_mac_out[21]     ) = (0,0);
(a_dinx[5]    =>   b_mac_out[21]     ) = (0,0);
(a_dinx[6]    =>   b_mac_out[21]     ) = (0,0);
(a_dinx[7]    =>   b_mac_out[21]     ) = (0,0);
(a_dinx[8]    =>   b_mac_out[21]     ) = (0,0);
(a_dinx[9]    =>   b_mac_out[21]     ) = (0,0);
(a_dinx[10]   =>   b_mac_out[21]     ) = (0,0);
(a_dinx[11]   =>   b_mac_out[21]     ) = (0,0);
(a_dinx[12]   =>   b_mac_out[21]     ) = (0,0);
(b_dinx[0]    =>   b_mac_out[21]     ) = (0,0);
(b_dinx[1]    =>   b_mac_out[21]     ) = (0,0);
(b_dinx[2]    =>   b_mac_out[21]     ) = (0,0);
(b_dinx[3]    =>   b_mac_out[21]     ) = (0,0);
(b_dinx[4]    =>   b_mac_out[21]     ) = (0,0);
(b_dinx[5]    =>   b_mac_out[21]     ) = (0,0);
(b_dinx[6]    =>   b_mac_out[21]     ) = (0,0);
(b_dinx[7]    =>   b_mac_out[21]     ) = (0,0);
(b_dinx[8]    =>   b_mac_out[21]     ) = (0,0);
(b_dinx[9]    =>   b_mac_out[21]     ) = (0,0);
(b_dinx[10]   =>   b_mac_out[21]     ) = (0,0);
(b_dinx[11]   =>   b_mac_out[21]     ) = (0,0);
(b_dinx[12]   =>   b_mac_out[21]     ) = (0,0);
(a_diny[0]    =>   b_mac_out[21]     ) = (0,0);
(a_diny[1]    =>   b_mac_out[21]     ) = (0,0);
(a_diny[2]    =>   b_mac_out[21]     ) = (0,0);
(a_diny[3]    =>   b_mac_out[21]     ) = (0,0);
(a_diny[4]    =>   b_mac_out[21]     ) = (0,0);
(a_diny[5]    =>   b_mac_out[21]     ) = (0,0);
(a_diny[6]    =>   b_mac_out[21]     ) = (0,0);
(a_diny[7]    =>   b_mac_out[21]     ) = (0,0);
(a_diny[8]    =>   b_mac_out[21]     ) = (0,0);
(a_diny[9]    =>   b_mac_out[21]     ) = (0,0);
(b_diny[0]    =>   b_mac_out[21]     ) = (0,0);
(b_diny[1]    =>   b_mac_out[21]     ) = (0,0);
(b_diny[2]    =>   b_mac_out[21]     ) = (0,0);
(b_diny[3]    =>   b_mac_out[21]     ) = (0,0);
(b_diny[4]    =>   b_mac_out[21]     ) = (0,0);
(b_diny[5]    =>   b_mac_out[21]     ) = (0,0);
(b_diny[6]    =>   b_mac_out[21]     ) = (0,0);
(b_diny[7]    =>   b_mac_out[21]     ) = (0,0);
(b_diny[8]    =>   b_mac_out[21]     ) = (0,0);
(b_diny[9]    =>   b_mac_out[21]     ) = (0,0);
(a_dinz[0]    =>   b_mac_out[21]     ) = (0,0);
(a_dinz[1]    =>   b_mac_out[21]     ) = (0,0);
(a_dinz[2]    =>   b_mac_out[21]     ) = (0,0);
(a_dinz[3]    =>   b_mac_out[21]     ) = (0,0);
(a_dinz[4]    =>   b_mac_out[21]     ) = (0,0);
(a_dinz[5]    =>   b_mac_out[21]     ) = (0,0);
(a_dinz[6]    =>   b_mac_out[21]     ) = (0,0);
(a_dinz[7]    =>   b_mac_out[21]     ) = (0,0);
(a_dinz[8]    =>   b_mac_out[21]     ) = (0,0);
(a_dinz[9]    =>   b_mac_out[21]     ) = (0,0);
(a_dinz[10]   =>   b_mac_out[21]     ) = (0,0);
(a_dinz[11]   =>   b_mac_out[21]     ) = (0,0);
(a_dinz[12]   =>   b_mac_out[21]     ) = (0,0);
(a_dinz[13]   =>   b_mac_out[21]     ) = (0,0);
(a_dinz[14]   =>   b_mac_out[21]     ) = (0,0);
(a_dinz[15]   =>   b_mac_out[21]     ) = (0,0);
(a_dinz[16]   =>   b_mac_out[21]     ) = (0,0);
(a_dinz[17]   =>   b_mac_out[21]     ) = (0,0);
(a_dinz[18]   =>   b_mac_out[21]     ) = (0,0);
(a_dinz[19]   =>   b_mac_out[21]     ) = (0,0);
(a_dinz[20]   =>   b_mac_out[21]     ) = (0,0);
(a_dinz[21]   =>   b_mac_out[21]     ) = (0,0);
(a_dinz[22]   =>   b_mac_out[21]     ) = (0,0);
(a_dinz[23]   =>   b_mac_out[21]     ) = (0,0);
(a_dinz[24]   =>   b_mac_out[21]     ) = (0,0);
(b_dinz[0]    =>   b_mac_out[21]     ) = (0,0);
(b_dinz[1]    =>   b_mac_out[21]     ) = (0,0);
(b_dinz[2]    =>   b_mac_out[21]     ) = (0,0);
(b_dinz[3]    =>   b_mac_out[21]     ) = (0,0);
(b_dinz[4]    =>   b_mac_out[21]     ) = (0,0);
(b_dinz[5]    =>   b_mac_out[21]     ) = (0,0);
(b_dinz[6]    =>   b_mac_out[21]     ) = (0,0);
(b_dinz[7]    =>   b_mac_out[21]     ) = (0,0);
(b_dinz[8]    =>   b_mac_out[21]     ) = (0,0);
(b_dinz[9]    =>   b_mac_out[21]     ) = (0,0);
(b_dinz[10]   =>   b_mac_out[21]     ) = (0,0);
(b_dinz[11]   =>   b_mac_out[21]     ) = (0,0);
(b_dinz[12]   =>   b_mac_out[21]     ) = (0,0);
(b_dinz[13]   =>   b_mac_out[21]     ) = (0,0);
(b_dinz[14]   =>   b_mac_out[21]     ) = (0,0);
(b_dinz[15]   =>   b_mac_out[21]     ) = (0,0);
(b_dinz[16]   =>   b_mac_out[21]     ) = (0,0);
(b_dinz[17]   =>   b_mac_out[21]     ) = (0,0);
(b_dinz[18]   =>   b_mac_out[21]     ) = (0,0);
(b_dinz[19]   =>   b_mac_out[21]     ) = (0,0);
(b_dinz[20]   =>   b_mac_out[21]     ) = (0,0);
(b_dinz[21]   =>   b_mac_out[21]     ) = (0,0);
(b_dinz[22]   =>   b_mac_out[21]     ) = (0,0);
(b_dinz[23]   =>   b_mac_out[21]     ) = (0,0);
(b_dinz[24]   =>   b_mac_out[21]     ) = (0,0);
(a_dinz_en    =>   b_mac_out[21]     ) = (0,0);
(b_dinz_en    =>   b_mac_out[21]     ) = (0,0);
(a_dinx[0]    =>   b_mac_out[22]     ) = (0,0);
(a_dinx[1]    =>   b_mac_out[22]     ) = (0,0);
(a_dinx[2]    =>   b_mac_out[22]     ) = (0,0);
(a_dinx[3]    =>   b_mac_out[22]     ) = (0,0);
(a_dinx[4]    =>   b_mac_out[22]     ) = (0,0);
(a_dinx[5]    =>   b_mac_out[22]     ) = (0,0);
(a_dinx[6]    =>   b_mac_out[22]     ) = (0,0);
(a_dinx[7]    =>   b_mac_out[22]     ) = (0,0);
(a_dinx[8]    =>   b_mac_out[22]     ) = (0,0);
(a_dinx[9]    =>   b_mac_out[22]     ) = (0,0);
(a_dinx[10]   =>   b_mac_out[22]     ) = (0,0);
(a_dinx[11]   =>   b_mac_out[22]     ) = (0,0);
(a_dinx[12]   =>   b_mac_out[22]     ) = (0,0);
(b_dinx[0]    =>   b_mac_out[22]     ) = (0,0);
(b_dinx[1]    =>   b_mac_out[22]     ) = (0,0);
(b_dinx[2]    =>   b_mac_out[22]     ) = (0,0);
(b_dinx[3]    =>   b_mac_out[22]     ) = (0,0);
(b_dinx[4]    =>   b_mac_out[22]     ) = (0,0);
(b_dinx[5]    =>   b_mac_out[22]     ) = (0,0);
(b_dinx[6]    =>   b_mac_out[22]     ) = (0,0);
(b_dinx[7]    =>   b_mac_out[22]     ) = (0,0);
(b_dinx[8]    =>   b_mac_out[22]     ) = (0,0);
(b_dinx[9]    =>   b_mac_out[22]     ) = (0,0);
(b_dinx[10]   =>   b_mac_out[22]     ) = (0,0);
(b_dinx[11]   =>   b_mac_out[22]     ) = (0,0);
(b_dinx[12]   =>   b_mac_out[22]     ) = (0,0);
(a_diny[0]    =>   b_mac_out[22]     ) = (0,0);
(a_diny[1]    =>   b_mac_out[22]     ) = (0,0);
(a_diny[2]    =>   b_mac_out[22]     ) = (0,0);
(a_diny[3]    =>   b_mac_out[22]     ) = (0,0);
(a_diny[4]    =>   b_mac_out[22]     ) = (0,0);
(a_diny[5]    =>   b_mac_out[22]     ) = (0,0);
(a_diny[6]    =>   b_mac_out[22]     ) = (0,0);
(a_diny[7]    =>   b_mac_out[22]     ) = (0,0);
(a_diny[8]    =>   b_mac_out[22]     ) = (0,0);
(a_diny[9]    =>   b_mac_out[22]     ) = (0,0);
(b_diny[0]    =>   b_mac_out[22]     ) = (0,0);
(b_diny[1]    =>   b_mac_out[22]     ) = (0,0);
(b_diny[2]    =>   b_mac_out[22]     ) = (0,0);
(b_diny[3]    =>   b_mac_out[22]     ) = (0,0);
(b_diny[4]    =>   b_mac_out[22]     ) = (0,0);
(b_diny[5]    =>   b_mac_out[22]     ) = (0,0);
(b_diny[6]    =>   b_mac_out[22]     ) = (0,0);
(b_diny[7]    =>   b_mac_out[22]     ) = (0,0);
(b_diny[8]    =>   b_mac_out[22]     ) = (0,0);
(b_diny[9]    =>   b_mac_out[22]     ) = (0,0);
(a_dinz[0]    =>   b_mac_out[22]     ) = (0,0);
(a_dinz[1]    =>   b_mac_out[22]     ) = (0,0);
(a_dinz[2]    =>   b_mac_out[22]     ) = (0,0);
(a_dinz[3]    =>   b_mac_out[22]     ) = (0,0);
(a_dinz[4]    =>   b_mac_out[22]     ) = (0,0);
(a_dinz[5]    =>   b_mac_out[22]     ) = (0,0);
(a_dinz[6]    =>   b_mac_out[22]     ) = (0,0);
(a_dinz[7]    =>   b_mac_out[22]     ) = (0,0);
(a_dinz[8]    =>   b_mac_out[22]     ) = (0,0);
(a_dinz[9]    =>   b_mac_out[22]     ) = (0,0);
(a_dinz[10]   =>   b_mac_out[22]     ) = (0,0);
(a_dinz[11]   =>   b_mac_out[22]     ) = (0,0);
(a_dinz[12]   =>   b_mac_out[22]     ) = (0,0);
(a_dinz[13]   =>   b_mac_out[22]     ) = (0,0);
(a_dinz[14]   =>   b_mac_out[22]     ) = (0,0);
(a_dinz[15]   =>   b_mac_out[22]     ) = (0,0);
(a_dinz[16]   =>   b_mac_out[22]     ) = (0,0);
(a_dinz[17]   =>   b_mac_out[22]     ) = (0,0);
(a_dinz[18]   =>   b_mac_out[22]     ) = (0,0);
(a_dinz[19]   =>   b_mac_out[22]     ) = (0,0);
(a_dinz[20]   =>   b_mac_out[22]     ) = (0,0);
(a_dinz[21]   =>   b_mac_out[22]     ) = (0,0);
(a_dinz[22]   =>   b_mac_out[22]     ) = (0,0);
(a_dinz[23]   =>   b_mac_out[22]     ) = (0,0);
(a_dinz[24]   =>   b_mac_out[22]     ) = (0,0);
(b_dinz[0]    =>   b_mac_out[22]     ) = (0,0);
(b_dinz[1]    =>   b_mac_out[22]     ) = (0,0);
(b_dinz[2]    =>   b_mac_out[22]     ) = (0,0);
(b_dinz[3]    =>   b_mac_out[22]     ) = (0,0);
(b_dinz[4]    =>   b_mac_out[22]     ) = (0,0);
(b_dinz[5]    =>   b_mac_out[22]     ) = (0,0);
(b_dinz[6]    =>   b_mac_out[22]     ) = (0,0);
(b_dinz[7]    =>   b_mac_out[22]     ) = (0,0);
(b_dinz[8]    =>   b_mac_out[22]     ) = (0,0);
(b_dinz[9]    =>   b_mac_out[22]     ) = (0,0);
(b_dinz[10]   =>   b_mac_out[22]     ) = (0,0);
(b_dinz[11]   =>   b_mac_out[22]     ) = (0,0);
(b_dinz[12]   =>   b_mac_out[22]     ) = (0,0);
(b_dinz[13]   =>   b_mac_out[22]     ) = (0,0);
(b_dinz[14]   =>   b_mac_out[22]     ) = (0,0);
(b_dinz[15]   =>   b_mac_out[22]     ) = (0,0);
(b_dinz[16]   =>   b_mac_out[22]     ) = (0,0);
(b_dinz[17]   =>   b_mac_out[22]     ) = (0,0);
(b_dinz[18]   =>   b_mac_out[22]     ) = (0,0);
(b_dinz[19]   =>   b_mac_out[22]     ) = (0,0);
(b_dinz[20]   =>   b_mac_out[22]     ) = (0,0);
(b_dinz[21]   =>   b_mac_out[22]     ) = (0,0);
(b_dinz[22]   =>   b_mac_out[22]     ) = (0,0);
(b_dinz[23]   =>   b_mac_out[22]     ) = (0,0);
(b_dinz[24]   =>   b_mac_out[22]     ) = (0,0);
(a_dinz_en    =>   b_mac_out[22]     ) = (0,0);
(b_dinz_en    =>   b_mac_out[22]     ) = (0,0);
(a_dinx[0]    =>   b_mac_out[23]     ) = (0,0);
(a_dinx[1]    =>   b_mac_out[23]     ) = (0,0);
(a_dinx[2]    =>   b_mac_out[23]     ) = (0,0);
(a_dinx[3]    =>   b_mac_out[23]     ) = (0,0);
(a_dinx[4]    =>   b_mac_out[23]     ) = (0,0);
(a_dinx[5]    =>   b_mac_out[23]     ) = (0,0);
(a_dinx[6]    =>   b_mac_out[23]     ) = (0,0);
(a_dinx[7]    =>   b_mac_out[23]     ) = (0,0);
(a_dinx[8]    =>   b_mac_out[23]     ) = (0,0);
(a_dinx[9]    =>   b_mac_out[23]     ) = (0,0);
(a_dinx[10]   =>   b_mac_out[23]     ) = (0,0);
(a_dinx[11]   =>   b_mac_out[23]     ) = (0,0);
(a_dinx[12]   =>   b_mac_out[23]     ) = (0,0);
(b_dinx[0]    =>   b_mac_out[23]     ) = (0,0);
(b_dinx[1]    =>   b_mac_out[23]     ) = (0,0);
(b_dinx[2]    =>   b_mac_out[23]     ) = (0,0);
(b_dinx[3]    =>   b_mac_out[23]     ) = (0,0);
(b_dinx[4]    =>   b_mac_out[23]     ) = (0,0);
(b_dinx[5]    =>   b_mac_out[23]     ) = (0,0);
(b_dinx[6]    =>   b_mac_out[23]     ) = (0,0);
(b_dinx[7]    =>   b_mac_out[23]     ) = (0,0);
(b_dinx[8]    =>   b_mac_out[23]     ) = (0,0);
(b_dinx[9]    =>   b_mac_out[23]     ) = (0,0);
(b_dinx[10]   =>   b_mac_out[23]     ) = (0,0);
(b_dinx[11]   =>   b_mac_out[23]     ) = (0,0);
(b_dinx[12]   =>   b_mac_out[23]     ) = (0,0);
(a_diny[0]    =>   b_mac_out[23]     ) = (0,0);
(a_diny[1]    =>   b_mac_out[23]     ) = (0,0);
(a_diny[2]    =>   b_mac_out[23]     ) = (0,0);
(a_diny[3]    =>   b_mac_out[23]     ) = (0,0);
(a_diny[4]    =>   b_mac_out[23]     ) = (0,0);
(a_diny[5]    =>   b_mac_out[23]     ) = (0,0);
(a_diny[6]    =>   b_mac_out[23]     ) = (0,0);
(a_diny[7]    =>   b_mac_out[23]     ) = (0,0);
(a_diny[8]    =>   b_mac_out[23]     ) = (0,0);
(a_diny[9]    =>   b_mac_out[23]     ) = (0,0);
(b_diny[0]    =>   b_mac_out[23]     ) = (0,0);
(b_diny[1]    =>   b_mac_out[23]     ) = (0,0);
(b_diny[2]    =>   b_mac_out[23]     ) = (0,0);
(b_diny[3]    =>   b_mac_out[23]     ) = (0,0);
(b_diny[4]    =>   b_mac_out[23]     ) = (0,0);
(b_diny[5]    =>   b_mac_out[23]     ) = (0,0);
(b_diny[6]    =>   b_mac_out[23]     ) = (0,0);
(b_diny[7]    =>   b_mac_out[23]     ) = (0,0);
(b_diny[8]    =>   b_mac_out[23]     ) = (0,0);
(b_diny[9]    =>   b_mac_out[23]     ) = (0,0);
(a_dinz[0]    =>   b_mac_out[23]     ) = (0,0);
(a_dinz[1]    =>   b_mac_out[23]     ) = (0,0);
(a_dinz[2]    =>   b_mac_out[23]     ) = (0,0);
(a_dinz[3]    =>   b_mac_out[23]     ) = (0,0);
(a_dinz[4]    =>   b_mac_out[23]     ) = (0,0);
(a_dinz[5]    =>   b_mac_out[23]     ) = (0,0);
(a_dinz[6]    =>   b_mac_out[23]     ) = (0,0);
(a_dinz[7]    =>   b_mac_out[23]     ) = (0,0);
(a_dinz[8]    =>   b_mac_out[23]     ) = (0,0);
(a_dinz[9]    =>   b_mac_out[23]     ) = (0,0);
(a_dinz[10]   =>   b_mac_out[23]     ) = (0,0);
(a_dinz[11]   =>   b_mac_out[23]     ) = (0,0);
(a_dinz[12]   =>   b_mac_out[23]     ) = (0,0);
(a_dinz[13]   =>   b_mac_out[23]     ) = (0,0);
(a_dinz[14]   =>   b_mac_out[23]     ) = (0,0);
(a_dinz[15]   =>   b_mac_out[23]     ) = (0,0);
(a_dinz[16]   =>   b_mac_out[23]     ) = (0,0);
(a_dinz[17]   =>   b_mac_out[23]     ) = (0,0);
(a_dinz[18]   =>   b_mac_out[23]     ) = (0,0);
(a_dinz[19]   =>   b_mac_out[23]     ) = (0,0);
(a_dinz[20]   =>   b_mac_out[23]     ) = (0,0);
(a_dinz[21]   =>   b_mac_out[23]     ) = (0,0);
(a_dinz[22]   =>   b_mac_out[23]     ) = (0,0);
(a_dinz[23]   =>   b_mac_out[23]     ) = (0,0);
(a_dinz[24]   =>   b_mac_out[23]     ) = (0,0);
(b_dinz[0]    =>   b_mac_out[23]     ) = (0,0);
(b_dinz[1]    =>   b_mac_out[23]     ) = (0,0);
(b_dinz[2]    =>   b_mac_out[23]     ) = (0,0);
(b_dinz[3]    =>   b_mac_out[23]     ) = (0,0);
(b_dinz[4]    =>   b_mac_out[23]     ) = (0,0);
(b_dinz[5]    =>   b_mac_out[23]     ) = (0,0);
(b_dinz[6]    =>   b_mac_out[23]     ) = (0,0);
(b_dinz[7]    =>   b_mac_out[23]     ) = (0,0);
(b_dinz[8]    =>   b_mac_out[23]     ) = (0,0);
(b_dinz[9]    =>   b_mac_out[23]     ) = (0,0);
(b_dinz[10]   =>   b_mac_out[23]     ) = (0,0);
(b_dinz[11]   =>   b_mac_out[23]     ) = (0,0);
(b_dinz[12]   =>   b_mac_out[23]     ) = (0,0);
(b_dinz[13]   =>   b_mac_out[23]     ) = (0,0);
(b_dinz[14]   =>   b_mac_out[23]     ) = (0,0);
(b_dinz[15]   =>   b_mac_out[23]     ) = (0,0);
(b_dinz[16]   =>   b_mac_out[23]     ) = (0,0);
(b_dinz[17]   =>   b_mac_out[23]     ) = (0,0);
(b_dinz[18]   =>   b_mac_out[23]     ) = (0,0);
(b_dinz[19]   =>   b_mac_out[23]     ) = (0,0);
(b_dinz[20]   =>   b_mac_out[23]     ) = (0,0);
(b_dinz[21]   =>   b_mac_out[23]     ) = (0,0);
(b_dinz[22]   =>   b_mac_out[23]     ) = (0,0);
(b_dinz[23]   =>   b_mac_out[23]     ) = (0,0);
(b_dinz[24]   =>   b_mac_out[23]     ) = (0,0);
(a_dinz_en    =>   b_mac_out[23]     ) = (0,0);
(b_dinz_en    =>   b_mac_out[23]     ) = (0,0);
(a_dinx[0]    =>   b_mac_out[24]     ) = (0,0);
(a_dinx[1]    =>   b_mac_out[24]     ) = (0,0);
(a_dinx[2]    =>   b_mac_out[24]     ) = (0,0);
(a_dinx[3]    =>   b_mac_out[24]     ) = (0,0);
(a_dinx[4]    =>   b_mac_out[24]     ) = (0,0);
(a_dinx[5]    =>   b_mac_out[24]     ) = (0,0);
(b_dinx[0]    =>   b_mac_out[24]     ) = (0,0);
(b_dinx[1]    =>   b_mac_out[24]     ) = (0,0);
(b_dinx[2]    =>   b_mac_out[24]     ) = (0,0);
(b_dinx[3]    =>   b_mac_out[24]     ) = (0,0);
(b_dinx[4]    =>   b_mac_out[24]     ) = (0,0);
(b_dinx[5]    =>   b_mac_out[24]     ) = (0,0);
(b_dinx[6]    =>   b_mac_out[24]     ) = (0,0);
(b_dinx[7]    =>   b_mac_out[24]     ) = (0,0);
(b_dinx[8]    =>   b_mac_out[24]     ) = (0,0);
(b_dinx[9]    =>   b_mac_out[24]     ) = (0,0);
(b_dinx[10]   =>   b_mac_out[24]     ) = (0,0);
(b_dinx[11]   =>   b_mac_out[24]     ) = (0,0);
(b_dinx[12]   =>   b_mac_out[24]     ) = (0,0);
(b_diny[0]    =>   b_mac_out[24]     ) = (0,0);
(b_diny[1]    =>   b_mac_out[24]     ) = (0,0);
(b_diny[2]    =>   b_mac_out[24]     ) = (0,0);
(b_diny[3]    =>   b_mac_out[24]     ) = (0,0);
(b_diny[4]    =>   b_mac_out[24]     ) = (0,0);
(b_diny[5]    =>   b_mac_out[24]     ) = (0,0);
(b_diny[6]    =>   b_mac_out[24]     ) = (0,0);
(b_diny[7]    =>   b_mac_out[24]     ) = (0,0);
(b_diny[8]    =>   b_mac_out[24]     ) = (0,0);
(b_diny[9]    =>   b_mac_out[24]     ) = (0,0);
(b_dinz[0]    =>   b_mac_out[24]     ) = (0,0);
(b_dinz[1]    =>   b_mac_out[24]     ) = (0,0);
(b_dinz[2]    =>   b_mac_out[24]     ) = (0,0);
(b_dinz[3]    =>   b_mac_out[24]     ) = (0,0);
(b_dinz[4]    =>   b_mac_out[24]     ) = (0,0);
(b_dinz[5]    =>   b_mac_out[24]     ) = (0,0);
(b_dinz[6]    =>   b_mac_out[24]     ) = (0,0);
(b_dinz[7]    =>   b_mac_out[24]     ) = (0,0);
(b_dinz[8]    =>   b_mac_out[24]     ) = (0,0);
(b_dinz[9]    =>   b_mac_out[24]     ) = (0,0);
(b_dinz[10]   =>   b_mac_out[24]     ) = (0,0);
(b_dinz[11]   =>   b_mac_out[24]     ) = (0,0);
(b_dinz[12]   =>   b_mac_out[24]     ) = (0,0);
(b_dinz[13]   =>   b_mac_out[24]     ) = (0,0);
(b_dinz[14]   =>   b_mac_out[24]     ) = (0,0);
(b_dinz[15]   =>   b_mac_out[24]     ) = (0,0);
(b_dinz[16]   =>   b_mac_out[24]     ) = (0,0);
(b_dinz[17]   =>   b_mac_out[24]     ) = (0,0);
(b_dinz[18]   =>   b_mac_out[24]     ) = (0,0);
(b_dinz[19]   =>   b_mac_out[24]     ) = (0,0);
(b_dinz[20]   =>   b_mac_out[24]     ) = (0,0);
(b_dinz[21]   =>   b_mac_out[24]     ) = (0,0);
(b_dinz[22]   =>   b_mac_out[24]     ) = (0,0);
(b_dinz[23]   =>   b_mac_out[24]     ) = (0,0);
(b_dinz[24]   =>   b_mac_out[24]     ) = (0,0);
(b_dinz_en    =>   b_mac_out[24]     ) = (0,0);
(a_dinx[0]    =>   a_overflow        ) = (0,0);
(a_dinx[1]    =>   a_overflow        ) = (0,0);
(a_dinx[2]    =>   a_overflow        ) = (0,0);
(a_dinx[3]    =>   a_overflow        ) = (0,0);
(a_dinx[4]    =>   a_overflow        ) = (0,0);
(a_dinx[5]    =>   a_overflow        ) = (0,0);
(a_dinx[6]    =>   a_overflow        ) = (0,0);
(a_dinx[7]    =>   a_overflow        ) = (0,0);
(a_dinx[8]    =>   a_overflow        ) = (0,0);
(a_dinx[9]    =>   a_overflow        ) = (0,0);
(a_dinx[10]   =>   a_overflow        ) = (0,0);
(a_dinx[11]   =>   a_overflow        ) = (0,0);
(a_dinx[12]   =>   a_overflow        ) = (0,0);
(b_dinx[0]    =>   a_overflow        ) = (0,0);
(b_dinx[1]    =>   a_overflow        ) = (0,0);
(b_dinx[2]    =>   a_overflow        ) = (0,0);
(b_dinx[3]    =>   a_overflow        ) = (0,0);
(b_dinx[4]    =>   a_overflow        ) = (0,0);
(b_dinx[5]    =>   a_overflow        ) = (0,0);
(b_dinx[6]    =>   a_overflow        ) = (0,0);
(b_dinx[7]    =>   a_overflow        ) = (0,0);
(b_dinx[8]    =>   a_overflow        ) = (0,0);
(b_dinx[9]    =>   a_overflow        ) = (0,0);
(b_dinx[10]   =>   a_overflow        ) = (0,0);
(b_dinx[11]   =>   a_overflow        ) = (0,0);
(b_dinx[12]   =>   a_overflow        ) = (0,0);
(a_diny[0]    =>   a_overflow        ) = (0,0);
(a_diny[1]    =>   a_overflow        ) = (0,0);
(a_diny[2]    =>   a_overflow        ) = (0,0);
(a_diny[3]    =>   a_overflow        ) = (0,0);
(a_diny[4]    =>   a_overflow        ) = (0,0);
(a_diny[5]    =>   a_overflow        ) = (0,0);
(a_diny[6]    =>   a_overflow        ) = (0,0);
(a_diny[7]    =>   a_overflow        ) = (0,0);
(a_diny[8]    =>   a_overflow        ) = (0,0);
(a_diny[9]    =>   a_overflow        ) = (0,0);
(b_diny[0]    =>   a_overflow        ) = (0,0);
(b_diny[1]    =>   a_overflow        ) = (0,0);
(b_diny[2]    =>   a_overflow        ) = (0,0);
(b_diny[3]    =>   a_overflow        ) = (0,0);
(b_diny[4]    =>   a_overflow        ) = (0,0);
(b_diny[5]    =>   a_overflow        ) = (0,0);
(b_diny[6]    =>   a_overflow        ) = (0,0);
(b_diny[7]    =>   a_overflow        ) = (0,0);
(b_diny[8]    =>   a_overflow        ) = (0,0);
(b_diny[9]    =>   a_overflow        ) = (0,0);
(a_dinz[0]    =>   a_overflow        ) = (0,0);
(a_dinz[1]    =>   a_overflow        ) = (0,0);
(a_dinz[2]    =>   a_overflow        ) = (0,0);
(a_dinz[3]    =>   a_overflow        ) = (0,0);
(a_dinz[4]    =>   a_overflow        ) = (0,0);
(a_dinz[5]    =>   a_overflow        ) = (0,0);
(a_dinz[6]    =>   a_overflow        ) = (0,0);
(a_dinz[7]    =>   a_overflow        ) = (0,0);
(a_dinz[8]    =>   a_overflow        ) = (0,0);
(a_dinz[9]    =>   a_overflow        ) = (0,0);
(a_dinz[10]   =>   a_overflow        ) = (0,0);
(a_dinz[11]   =>   a_overflow        ) = (0,0);
(a_dinz[12]   =>   a_overflow        ) = (0,0);
(a_dinz[13]   =>   a_overflow        ) = (0,0);
(a_dinz[14]   =>   a_overflow        ) = (0,0);
(a_dinz[15]   =>   a_overflow        ) = (0,0);
(a_dinz[16]   =>   a_overflow        ) = (0,0);
(a_dinz[17]   =>   a_overflow        ) = (0,0);
(a_dinz[18]   =>   a_overflow        ) = (0,0);
(a_dinz[19]   =>   a_overflow        ) = (0,0);
(a_dinz[20]   =>   a_overflow        ) = (0,0);
(a_dinz[21]   =>   a_overflow        ) = (0,0);
(a_dinz[22]   =>   a_overflow        ) = (0,0);
(a_dinz[23]   =>   a_overflow        ) = (0,0);
(a_dinz[24]   =>   a_overflow        ) = (0,0);
(b_dinz[0]    =>   a_overflow        ) = (0,0);
(b_dinz[1]    =>   a_overflow        ) = (0,0);
(b_dinz[2]    =>   a_overflow        ) = (0,0);
(b_dinz[3]    =>   a_overflow        ) = (0,0);
(b_dinz[4]    =>   a_overflow        ) = (0,0);
(b_dinz[5]    =>   a_overflow        ) = (0,0);
(b_dinz[6]    =>   a_overflow        ) = (0,0);
(b_dinz[7]    =>   a_overflow        ) = (0,0);
(b_dinz[8]    =>   a_overflow        ) = (0,0);
(b_dinz[9]    =>   a_overflow        ) = (0,0);
(b_dinz[10]   =>   a_overflow        ) = (0,0);
(b_dinz[11]   =>   a_overflow        ) = (0,0);
(b_dinz[12]   =>   a_overflow        ) = (0,0);
(b_dinz[13]   =>   a_overflow        ) = (0,0);
(b_dinz[14]   =>   a_overflow        ) = (0,0);
(b_dinz[15]   =>   a_overflow        ) = (0,0);
(b_dinz[16]   =>   a_overflow        ) = (0,0);
(b_dinz[17]   =>   a_overflow        ) = (0,0);
(b_dinz[18]   =>   a_overflow        ) = (0,0);
(b_dinz[19]   =>   a_overflow        ) = (0,0);
(b_dinz[20]   =>   a_overflow        ) = (0,0);
(b_dinz[21]   =>   a_overflow        ) = (0,0);
(b_dinz[22]   =>   a_overflow        ) = (0,0);
(b_dinz[23]   =>   a_overflow        ) = (0,0);
(a_dinz_en    =>   a_overflow        ) = (0,0);
(a_dinx[0]    =>   b_overflow        ) = (0,0);
(a_dinx[1]    =>   b_overflow        ) = (0,0);
(a_dinx[2]    =>   b_overflow        ) = (0,0);
(a_dinx[3]    =>   b_overflow        ) = (0,0);
(a_dinx[4]    =>   b_overflow        ) = (0,0);
(a_dinx[5]    =>   b_overflow        ) = (0,0);
(b_dinx[0]    =>   b_overflow        ) = (0,0);
(b_dinx[1]    =>   b_overflow        ) = (0,0);
(b_dinx[2]    =>   b_overflow        ) = (0,0);
(b_dinx[3]    =>   b_overflow        ) = (0,0);
(b_dinx[4]    =>   b_overflow        ) = (0,0);
(b_dinx[5]    =>   b_overflow        ) = (0,0);
(b_dinx[6]    =>   b_overflow        ) = (0,0);
(b_dinx[7]    =>   b_overflow        ) = (0,0);
(b_dinx[8]    =>   b_overflow        ) = (0,0);
(b_dinx[9]    =>   b_overflow        ) = (0,0);
(b_dinx[10]   =>   b_overflow        ) = (0,0);
(b_dinx[11]   =>   b_overflow        ) = (0,0);
(b_dinx[12]   =>   b_overflow        ) = (0,0);
(b_diny[0]    =>   b_overflow        ) = (0,0);
(b_diny[1]    =>   b_overflow        ) = (0,0);
(b_diny[2]    =>   b_overflow        ) = (0,0);
(b_diny[3]    =>   b_overflow        ) = (0,0);
(b_diny[4]    =>   b_overflow        ) = (0,0);
(b_diny[5]    =>   b_overflow        ) = (0,0);
(b_diny[6]    =>   b_overflow        ) = (0,0);
(b_diny[7]    =>   b_overflow        ) = (0,0);
(b_diny[8]    =>   b_overflow        ) = (0,0);
(b_diny[9]    =>   b_overflow        ) = (0,0);
(b_dinz[0]    =>   b_overflow        ) = (0,0);
(b_dinz[1]    =>   b_overflow        ) = (0,0);
(b_dinz[2]    =>   b_overflow        ) = (0,0);
(b_dinz[3]    =>   b_overflow        ) = (0,0);
(b_dinz[4]    =>   b_overflow        ) = (0,0);
(b_dinz[5]    =>   b_overflow        ) = (0,0);
(b_dinz[6]    =>   b_overflow        ) = (0,0);
(b_dinz[7]    =>   b_overflow        ) = (0,0);
(b_dinz[8]    =>   b_overflow        ) = (0,0);
(b_dinz[9]    =>   b_overflow        ) = (0,0);
(b_dinz[10]   =>   b_overflow        ) = (0,0);
(b_dinz[11]   =>   b_overflow        ) = (0,0);
(b_dinz[12]   =>   b_overflow        ) = (0,0);
(b_dinz[13]   =>   b_overflow        ) = (0,0);
(b_dinz[14]   =>   b_overflow        ) = (0,0);
(b_dinz[15]   =>   b_overflow        ) = (0,0);
(b_dinz[16]   =>   b_overflow        ) = (0,0);
(b_dinz[17]   =>   b_overflow        ) = (0,0);
(b_dinz[18]   =>   b_overflow        ) = (0,0);
(b_dinz[19]   =>   b_overflow        ) = (0,0);
(b_dinz[20]   =>   b_overflow        ) = (0,0);
(b_dinz[21]   =>   b_overflow        ) = (0,0);
(b_dinz[22]   =>   b_overflow        ) = (0,0);
(b_dinz[23]   =>   b_overflow        ) = (0,0);
(b_dinz[24]   =>   b_overflow        ) = (0,0);
(b_dinz_en    =>   b_overflow        ) = (0,0);


//timingcheck
$setuphold(posedge clk,    a_dinx[0] , 0,0); 
$setuphold(posedge clk,    a_dinx[1] , 0,0); 
$setuphold(posedge clk,    a_dinx[10], 0,0);  
$setuphold(posedge clk,    a_dinx[11], 0,0);  
$setuphold(posedge clk,    a_dinx[12], 0,0); 
$setuphold(posedge clk,    a_dinx[2] , 0,0); 
$setuphold(posedge clk,    a_dinx[3] , 0,0); 
$setuphold(posedge clk,    a_dinx[4] , 0,0);  
$setuphold(posedge clk,    a_dinx[5] , 0,0);  
$setuphold(posedge clk,    a_dinx[6] , 0,0);  
$setuphold(posedge clk,    a_dinx[7] , 0,0); 
$setuphold(posedge clk,    a_dinx[8] , 0,0); 
$setuphold(posedge clk,    a_dinx[9] , 0,0);  
$setuphold(posedge clk,    a_diny[0] , 0,0);  
$setuphold(posedge clk,    a_diny[1] , 0,0);  
$setuphold(posedge clk,    a_diny[2] , 0,0);  
$setuphold(posedge clk,    a_diny[3] , 0,0); 
$setuphold(posedge clk,    a_diny[4] , 0,0);  
$setuphold(posedge clk,    a_diny[5] , 0,0);  
$setuphold(posedge clk,    a_diny[6] , 0,0);  
$setuphold(posedge clk,    a_diny[7] , 0,0);  
$setuphold(posedge clk,    a_diny[8] , 0,0);  
$setuphold(posedge clk,    a_diny[9] , 0,0);  
$setuphold(posedge clk,    a_dinz[0] , 0,0); 
$setuphold(posedge clk,    a_dinz[1] , 0,0);  
$setuphold(posedge clk,    a_dinz[10], 0,0); 
$setuphold(posedge clk,    a_dinz[11], 0,0); 
$setuphold(posedge clk,    a_dinz[12], 0,0); 
$setuphold(posedge clk,    a_dinz[13], 0,0);  
$setuphold(posedge clk,    a_dinz[14], 0,0); 
$setuphold(posedge clk,    a_dinz[15], 0,0);  
$setuphold(posedge clk,    a_dinz[16], 0,0); 
$setuphold(posedge clk,    a_dinz[17], 0,0);  
$setuphold(posedge clk,    a_dinz[18], 0,0);  
$setuphold(posedge clk,    a_dinz[19], 0,0);   
$setuphold(posedge clk,    a_dinz[2] , 0,0);  
$setuphold(posedge clk,    a_dinz[20], 0,0);   
$setuphold(posedge clk,    a_dinz[21], 0,0); 
$setuphold(posedge clk,    a_dinz[22], 0,0); 
$setuphold(posedge clk,    a_dinz[23], 0,0); 
$setuphold(posedge clk,    a_dinz[24], 0,0); 
$setuphold(posedge clk,    a_dinz[3] , 0,0);  
$setuphold(posedge clk,    a_dinz[4] , 0,0);  
$setuphold(posedge clk,    a_dinz[5] , 0,0); 
$setuphold(posedge clk,    a_dinz[6] , 0,0); 
$setuphold(posedge clk,    a_dinz[7] , 0,0); 
$setuphold(posedge clk,    a_dinz[8] , 0,0); 
$setuphold(posedge clk,    a_dinz[9] , 0,0); 
$setuphold(posedge clk,    a_dinz_en , 0,0);  
$setuphold(posedge clk,    a_mac_out_cen ,0,0);
$setuphold(posedge clk,    a_out_sr   ,0,0);
$setuphold(posedge clk,    b_dinx[0]  ,0,0);  
$setuphold(posedge clk,    b_dinx[1]  ,0,0); 
$setuphold(posedge clk,    b_dinx[10] ,0,0);  
$setuphold(posedge clk,    b_dinx[11] ,0,0); 
$setuphold(posedge clk,    b_dinx[12] ,0,0); 
$setuphold(posedge clk,    b_dinx[2]  ,0,0); 
$setuphold(posedge clk,    b_dinx[3]  ,0,0); 
$setuphold(posedge clk,    b_dinx[4]  ,0,0); 
$setuphold(posedge clk,    b_dinx[5]  ,0,0); 
$setuphold(posedge clk,    b_dinx[6]  ,0,0); 
$setuphold(posedge clk,    b_dinx[7]  ,0,0); 
$setuphold(posedge clk,    b_dinx[8]  ,0,0); 
$setuphold(posedge clk,    b_dinx[9]  ,0,0); 
$setuphold(posedge clk,    b_diny[0]  ,0,0); 
$setuphold(posedge clk,    b_diny[1]  ,0,0); 
$setuphold(posedge clk,    b_diny[2]  ,0,0); 
$setuphold(posedge clk,    b_diny[3]  ,0,0); 
$setuphold(posedge clk,    b_diny[4]  ,0,0); 
$setuphold(posedge clk,    b_diny[5]  ,0,0); 
$setuphold(posedge clk,    b_diny[6]  ,0,0); 
$setuphold(posedge clk,    b_diny[7]  ,0,0); 
$setuphold(posedge clk,    b_diny[8]  ,0,0);  
$setuphold(posedge clk,    b_diny[9]  ,0,0); 
$setuphold(posedge clk,    b_dinz[0]  ,0,0); 
$setuphold(posedge clk,    b_dinz[1]  ,0,0); 
$setuphold(posedge clk,    b_dinz[10] ,0,0); 
$setuphold(posedge clk,    b_dinz[11] ,0,0); 
$setuphold(posedge clk,    b_dinz[12] ,0,0);  
$setuphold(posedge clk,    b_dinz[13] ,0,0); 
$setuphold(posedge clk,    b_dinz[14] ,0,0); 
$setuphold(posedge clk,    b_dinz[15] ,0,0); 
$setuphold(posedge clk,    b_dinz[16] ,0,0); 
$setuphold(posedge clk,    b_dinz[17] ,0,0); 
$setuphold(posedge clk,    b_dinz[18] ,0,0); 
$setuphold(posedge clk,    b_dinz[19] ,0,0); 
$setuphold(posedge clk,    b_dinz[2]  ,0,0);   
$setuphold(posedge clk,    b_dinz[20] ,0,0); 
$setuphold(posedge clk,    b_dinz[21] ,0,0); 
$setuphold(posedge clk,    b_dinz[22] ,0,0);  
$setuphold(posedge clk,    b_dinz[23] ,0,0);  
$setuphold(posedge clk,    b_dinz[3]  ,0,0); 
$setuphold(posedge clk,    b_dinz[4]  ,0,0); 
$setuphold(posedge clk,    b_dinz[5]  ,0,0); 
$setuphold(posedge clk,    b_dinz[6]  ,0,0); 
$setuphold(posedge clk,    b_dinz[7]  ,0,0); 
$setuphold(posedge clk,    b_dinz[8]  ,0,0); 
$setuphold(posedge clk,    b_dinz[9]  ,0,0); 
		endspecify

endmodule

module mac_dff_async(q,clk,d,rstn,setn,cen);
input clk;
input d;
input rstn;
input setn;
input cen;
output q;
reg q;
always@(posedge clk or negedge rstn or negedge setn)
begin
  if(!rstn)
    q <= 1'b0;
  else if(!setn)
    q <= 1'b1;
  else if(cen)
    q <= d;
end

endmodule

module mac_dff_sync(q,clk,d,rstn,setn,cen);
input clk;
input d;
input rstn;
input setn;
input cen;
output q;
reg q;
always@(posedge clk)
begin
  if(!rstn)
    q <= 1'b0;
  else if(!setn)
    q <= 1'b1;
  else if(cen)
    q <= d;
end

endmodule

`timescale 1ns/1ns
module M7S_EMB5K(
    clka,
    clkb,
    rstna,
    rstnb,
    cea,
    ceb,
    wea,
    web,
    aa,
    ab,
    da,
    db,
    q
);

//========================================
//cfg_bit           mode_sel
//========================================
//0000            256 x 18
//1000            512 x 9
//1100             1k x 4
//1110             2k x 2
//1111             4k x 1
//========================================

`ifdef CS_FORMALPRO_HACK
    wire [3:0] modea_sel;
    wire [3:0] modeb_sel;
    wire [1:0] porta_wr_mode;
    wire [1:0] portb_wr_mode;

    //parameter just for simulation
    wire [2:0] operation_mode;
    wire porta_data_width;
    wire portb_data_width;

    //parameter user can not set
    wire [7:0] porta_prog;
    wire [7:0] portb_prog;

`else
    parameter modea_sel =  4'b0000;
    parameter modeb_sel =  4'b0000;
    
    parameter porta_wr_mode = 2'b00;
    parameter portb_wr_mode = 2'b00;
    //00, write no change
    //01, write first
    //1x, read first

    parameter porta_reg_out = 1'b0;
    parameter portb_reg_out = 1'b0;
    parameter reset_value_a = 9'b0;
    parameter reset_value_b = 9'b0;

    parameter porta_data_width  = 18;
    parameter portb_data_width  = 18;
    parameter operation_mode = "simple_dual_port";//"true_dual_port","single_port","simple_dual_port"
    parameter init_file = " ";

    //parameter user can not set
    parameter porta_prog = 8'b0000_0000;
    parameter portb_prog = 8'b0000_0000;
`endif

//---------------------------------------------------------------------------------
//for SW
//---------------------------------------------------------------------------------
    //parameter modea_sel   =  "256x18"; //"256x18", "512x9", "1kx4", "2kx2", "4kx1", "wtdp"
    //parameter modeb_sel   =  "256x18"; //"256x18", "512x9", "1kx4", "2kx2", "4kx1", "wtdp"
    //parameter porta_wr_mode = "false";
    //parameter portb_wr_mode = "false";
    
    //parameter operation_mode = "";//"true_dual_port","single_port","simple_dual_port"
    //parameter porta_data_width    = 1'b0;
    //parameter portb_data_width    = 1'b0;
    
    //parameter porta_prog = 8'b0000_0000;
    //parameter portb_prog = 8'b0000_0000;
//---------------------------------------------------------------------------------

    input clka,clkb;
    input rstna,rstnb;
    input cea,ceb;
    input wea,web;
    
    input [11:0] aa;
    input [11:0] ab;
    
    input [17:0] da;
    input [17:0] db;
    
    output [17:0] q;
    
    reg debug;
    
    // INTERNAL REGISTERS DECLARATION
    parameter porta_addr_width =    (porta_data_width == 18)?8:
                    (porta_data_width == 16)?8:
                    (porta_data_width == 9)?9:
                    (porta_data_width == 8)?9:
                    (porta_data_width == 4)?10:
                    (porta_data_width == 2)?11:
                    12;     
                                                            
    parameter portb_addr_width =    (portb_data_width == 18)?8:
                    (portb_data_width == 16)?8:
                    (portb_data_width == 9)?9:
                    (portb_data_width == 8)?9:
                    (portb_data_width == 4)?10:
                    (portb_data_width == 2)?11:
                    12;     
    
    reg [portb_data_width-1:0] mem_data [0:((1<<portb_addr_width)-1)];
    
    // reg [portb_data_width-1:0] temp_word_b; 
    reg [portb_data_width-1:0] temp_word_b [0:((1<<portb_addr_width)-1)]; 
    reg [portb_data_width-1:0] temp_wb2a;   
    reg [porta_data_width-1:0] temp_word_a;     
    reg [porta_data_width-1:0] i_q_tmp_a;
    reg [portb_data_width-1:0] i_q_tmp_b;
    wire [17:0] ox_do;
    wire [17:0] ox_do_rstn;
    reg [17:0] ox_do_rstn_reg;
    wire clk_reg_out_b;
        
    wire [porta_addr_width-1:0] i_aa;
    wire [portb_addr_width-1:0] i_ab;
    
    wire [porta_data_width-1:0] i_da;
    wire [portb_data_width-1:0] i_db;   
    
    wire i_clka;
    wire i_cea;
    wire i_wea;
    
    wire i_clkb;
    wire i_ceb;
    wire i_web;
        
    // INTERNAL REGISTERS DECLARATION
    
    // LOCAL INTEGER DECLARATION
    // for loop iterators
    integer i;
    integer j;
    integer j_plus_i_div_db;
    integer j_plus_i;
  
    
    assign i_da =   (porta_data_width   ==  18)?((operation_mode == "simple_dual_port" || operation_mode == "single_port") ? {da[17],da[15:8],da[16],da[7:0]} : da[17:0]):
            (porta_data_width   ==  16)?da[15:0]:
            (porta_data_width   ==  9)?da[16:8]:
            (porta_data_width   ==  8)?da[7:0]:
            (porta_data_width   ==  4)?da[3:0]:
            (porta_data_width   ==  2)?da[1:0]:
            {da[0]};
    
    assign i_db =   (portb_data_width   ==  18)?((operation_mode == "simple_dual_port" || operation_mode == "single_port") ? {db[17],db[15:8],db[16],db[7:0]} : db[17:0]):
            (portb_data_width   ==  16)?db[15:0]:
            (portb_data_width   ==  9)?db[16:8]:
            (portb_data_width   ==  8)?db[7:0]:
            (portb_data_width   ==  4)?db[3:0]:
            (portb_data_width   ==  2)?db[1:0]:
            {db[0]};
                                                        
    assign i_aa =   (porta_data_width   ==  18)?aa[11:4]:
            (porta_data_width   ==  16)?aa[11:4]:
            (porta_data_width   ==  9)?aa[11:3]:
            (porta_data_width   ==  8)?aa[11:3]:
            (porta_data_width   ==  4)?aa[11:2]:
            (porta_data_width   ==  2)?aa[11:1]:
            {aa[11:0]}; 
                                                        
    assign i_ab =   (portb_data_width   ==  18)?ab[11:4]:
            (portb_data_width   ==  16)?ab[11:4]:
            (portb_data_width   ==  9)?ab[11:3]:
            (portb_data_width   ==  8)?ab[11:3]:
            (portb_data_width   ==  4)?ab[11:2]:
            (portb_data_width   ==  2)?ab[11:1]:
            {ab[11:0]}; 

    // check writing conflicting
    event clk_edge;
    always @(posedge clka,posedge clkb)
    begin
        -> clk_edge;
    end
    time prev_edge_t = 0;
    time cur_edge_t;
    time interval_t;
    always @(clk_edge)
    begin
        cur_edge_t = $time;
        interval_t = cur_edge_t - prev_edge_t;
        if(prev_edge_t != 0)
           if(interval_t < 2) // clka and clkb's edge trigger nearly at the same time
              begin
                  if(cea && ceb && (aa[11:4] == ab[11:4]))
                  begin
                      if(wea && web)
                          $display("%t - Warning: both ports writing the same memory cell at the same time!!!\n",$time);
                      else if(wea ^ web)
                      begin
                          $display("%t - Warning: one port reading the same memory cell data while the other port writing at the same time!!!\n",$time);
                          $display("              read data will be a X/unkown value!!!\n");
                      end
                  end
              end
        prev_edge_t = cur_edge_t;
    end
                                                                
    assign i_clka = clka;
    assign i_cea = cea;
    assign i_wea = wea;     
    assign i_clkb = clkb;
    assign i_ceb = ceb;
    assign i_web = web;     
   
    initial // check init_file
    begin
        i = 0;

        // Initialize mem_data
        if (init_file == " " || init_file == "")
        begin
            //$display("emb does not need data file for memory initialization.\n");
        end
        else  // Memory initialization file is used
        begin
            $display("Initialize the emb.\n");
            $readmemh(init_file, mem_data);
            if(portb_data_width   ==  18 && (operation_mode == "simple_dual_port" || operation_mode == "single_port")) begin
                for(i=0; i<(1<<portb_addr_width); i=i+1) begin
                    temp_word_b[i] = mem_data[i];
                    mem_data[i] = {temp_word_b[i][17],temp_word_b[i][15:8],temp_word_b[i][16],temp_word_b[i][7:0]};
                end
            end
        end
    end
    initial // check operation_mode, model_sel and port_data_width
    begin
        //operation_mode check
        if((operation_mode != "single_port") && (operation_mode != "simple_dual_port") && (operation_mode != "true_dual_port"))
        begin
            $display("operation_mode ERROR!!!\n");
        end
        //Port A, check model_sel and port_data_width
        if(modea_sel == "wtdp" || modea_sel ==  24)
        begin
            if(porta_data_width != 9)
                $display("modea_sel does not fit porta_data_width, ERROR!!!\n");
        end
        else if(modea_sel == "256x18" || modea_sel == 0)
        begin
            if((porta_data_width != 18) && (porta_data_width != 16))
                $display("modea_sel does not fit porta_data_width, ERROR!!!\n");
            if(operation_mode == "true_dual_port")
                $display("true_dual_port does not have 256x18 mode(porta), ERROR!!!\n");
        end
        else if(modea_sel == "512x9" || modea_sel == 8)
        begin
            if((porta_data_width != 9) && (porta_data_width != 8))
                $display("modea_sel does not fit porta_data_width, ERROR!!!\n");
        end
        else if(modea_sel == "1kx4" || modea_sel == 12)
        begin
            if(porta_data_width != 4)
                $display("modea_sel does not fit porta_data_width, ERROR!!!\n");
        end
        else if(modea_sel == "2kx2" || modea_sel == 14)
        begin
            if(porta_data_width != 2)
                $display("modea_sel does not fit porta_data_width, ERROR!!!\n");
        end
        else if(modea_sel == "4kx1" || modea_sel == 15)
        begin
            if(porta_data_width != 1)
                $display("modea_sel does not fit porta_data_width, ERROR!!!\n");
        end
        else // error
        begin
            $display("modea_sel is configured ERROR!!!\n");
        end
        //Port B, check model_sel and port_data_width
        if(modeb_sel == "wtdp" || modeb_sel ==  24)
        begin
            if(portb_data_width != 9)
                $display("modeb_sel does not fit portb_data_width, ERROR!!!\n");
        end
        else if(modeb_sel == "256x18" || modeb_sel == 0)
        begin
            if((portb_data_width != 18) && (portb_data_width != 16))
                $display("modeb_sel does not fit portb_data_width, ERROR!!!\n");
            if(operation_mode == "true_dual_port")
                $display("true_dual_port does not have 256x18 mode(portb), ERROR!!!\n");
        end
        else if(modeb_sel == "512x9" || modeb_sel == 8)
        begin
            if((portb_data_width != 9) && (portb_data_width != 8))
                $display("modeb_sel does not fit portb_data_width, ERROR!!!\n");
        end
        else if(modeb_sel == "1kx4" || modeb_sel == 12)
        begin
            if(portb_data_width != 4)
                $display("modeb_sel does not fit portb_data_width, ERROR!!!\n");
        end
        else if(modeb_sel == "2kx2" || modeb_sel == 14)
        begin
            if(portb_data_width != 2)
                $display("modeb_sel does not fit portb_data_width, ERROR!!!\n");
        end
        else if(modeb_sel == "4kx1" || modeb_sel == 15)
        begin
            if(portb_data_width != 1)
                $display("modeb_sel does not fit portb_data_width, ERROR!!!\n");
        end
        else // error
        begin
            $display("modeb_sel is configured ERROR!!!\n");
        end
    end

    always @(posedge i_clkb)
    begin
        if (i_ceb) begin
            if (i_web) begin
                if(portb_wr_mode == 2'b10 || portb_wr_mode == 2'b11) begin //check if read-first
                    i_q_tmp_b = #0 mem_data[i_ab];
                end
                mem_data[i_ab] = i_db;// Port B writting
                if(portb_wr_mode == 2'b01) begin //check if write-first
                    i_q_tmp_b = #0 mem_data[i_ab]; // Port B output value
                end
            end
            else begin
                i_q_tmp_b = #0 mem_data[i_ab]; // Port B output
            end
        end
    end
      
    always @(posedge i_clka)
    begin
        if (i_cea) begin
            if (i_wea) begin
                if(porta_wr_mode == 2'b10 || porta_wr_mode == 2'b11) begin //check if read-first
                    if(porta_data_width == portb_data_width) begin
                        temp_word_a = mem_data[i_aa];
                    end
                    else begin
                        j = i_aa * porta_data_width;
                        for (i = 0; i < porta_data_width; i = i+1)
                        begin
                            j_plus_i = j + i;
                            j_plus_i_div_db = j_plus_i / portb_data_width;
                            temp_wb2a = mem_data[j_plus_i_div_db];
                            temp_word_a[i] = temp_wb2a[j_plus_i % portb_data_width];
                        end
                    end
                    i_q_tmp_a = #0 temp_word_a; // Port A output
                end

                temp_word_a = i_da;

                if(porta_data_width == portb_data_width) begin
                    mem_data[i_aa] = temp_word_a;
                end
                else begin
                    j = i_aa * porta_data_width;
                    for (i = 0; i < porta_data_width; i = i+1)
                    begin
                        debug = 0;
                        //#1
                        j_plus_i = j + i;
                        j_plus_i_div_db = j_plus_i / portb_data_width;
                        temp_word_b[j_plus_i_div_db][j_plus_i % portb_data_width] = temp_word_a[i];
                        mem_data[j_plus_i_div_db] = temp_word_b[j_plus_i_div_db];
                        debug = 1;
                    end
                end
                
                if(porta_wr_mode == 2'b01) begin //check if write-first
                    i_q_tmp_a = #0 temp_word_a; // Port A output value
                end
                
            end // read
            else begin
                if(porta_data_width == portb_data_width) begin
                    temp_word_a = mem_data[i_aa];
                end
                else begin
                    j = i_aa * porta_data_width;
                    for (i = 0; i < porta_data_width; i = i+1)
                    begin
                        j_plus_i = j + i;
                        j_plus_i_div_db = j_plus_i / portb_data_width;
                        temp_wb2a = mem_data[j_plus_i_div_db];
                        temp_word_a[i] = temp_wb2a[j_plus_i % portb_data_width];
                    end
                end
                
                i_q_tmp_a = #0 temp_word_a; // Port A output
            end
        end
    end 

    //Original output           
    assign ox_do[17:0] = (modea_sel   ==  "256x18" || modea_sel ==  0)?(((operation_mode == "simple_dual_port" || operation_mode == "single_port") && (porta_data_width == 18)) ? {i_q_tmp_a[17],i_q_tmp_a[8],i_q_tmp_a[16:9],i_q_tmp_a[7:0]} : i_q_tmp_a):
            (modea_sel  ==  "512x9" || modea_sel ==  8)?{9'b0,i_q_tmp_b[portb_data_width-1:0],i_q_tmp_a[8:0]}:
            (modea_sel  ==  "1kx4" || modea_sel ==  12)?{9'b0,i_q_tmp_b[portb_data_width-1:0],5'b0,i_q_tmp_a[3:0]}:
            (modea_sel  ==  "2kx2" || modea_sel ==  14)?{9'b0,i_q_tmp_b[portb_data_width-1:0],7'b0,i_q_tmp_a[1:0]}:
            {9'b0,i_q_tmp_b[portb_data_width-1:0],8'b0,i_q_tmp_a[0]};

    //add reset value and registers upon output
    reg rstna_reg, rstnb_reg;
    wire rstnb_t;
    assign clk_reg_out_b = (modea_sel != 4'b0000) ? i_clkb : i_clka;
    assign rstnb_t = (modea_sel != 4'b0000) ? rstnb : rstna;
    always @(posedge i_clka)
	rstna_reg <= rstna;
    always @(posedge clk_reg_out_b)
	rstnb_reg <= rstnb_t;
    assign ox_do_rstn[8:0]  = rstna_reg ? ox_do[8:0]  : reset_value_a;
    //assign ox_do_rstn[17:9] = ((modea_sel != 4'b0000) ? rstnb : rstna) ? ox_do[17:9] : reset_value_b;
    assign ox_do_rstn[17:9] = rstnb_reg ? ox_do[17:9] : reset_value_b;

    always @(posedge i_clka)
        ox_do_rstn_reg[8:0] <= ox_do_rstn[8:0];
    //assign clk_reg_out_b = (modea_sel != 4'b0000) ? i_clkb : i_clka;
    always @(posedge clk_reg_out_b)
        ox_do_rstn_reg[17:9] <= ox_do_rstn[17:9];

    //Final output
    assign q[8:0]  = porta_reg_out ? ox_do_rstn_reg[8:0] : ox_do_rstn[8:0];
    assign q[17:9] = ((modea_sel != 4'b0000) ? portb_reg_out : porta_reg_out) ? ox_do_rstn_reg[17:9] : ox_do_rstn[17:9];

endmodule


module M7S_DGPIO (
	clk0 ,
	rstn ,
	setn ,
	clk_en ,
	oen ,
	od_d ,
	id_q ,
	pad 
);
    parameter    io_type = "input";     //"input", "output", "inout"
    parameter    fast_input = 1'b0;
    parameter    fast_output = 1'b0;
    parameter    fast_oe = 1'b0;
    parameter    cfg_fclk_gate_sel = 1'b0;
    parameter    cfg_fclk_en = 1'b0;

    parameter    cfg_fclk_inv            = 1'b0;
    parameter    cfg_oen_inv             = 1'b0;
    parameter    cfg_od_inv              = 1'b0;   
    parameter    cfg_oen_setn_en         = 1'b0;
    parameter    cfg_id_setn_en          = 1'b0;
    parameter    cfg_od_setn_en          = 1'b0;
    parameter    cfg_setn_inv            = 1'b0;

    parameter    cfg_oen_rstn_en         = 1'b0;
    parameter    cfg_id_rstn_en          = 1'b0;
    parameter    cfg_od_rstn_en          = 1'b0;
    parameter    cfg_rstn_inv            = 1'b0;
	parameter	 optional_function		 = "";

    input	clk0 ;
    input	rstn ;
    input	setn ;
    input	clk_en ;
    input	oen ;
    input	od_d ;
    output	id_q ;
    inout	pad ;

	wire i_clk;
	wire i_rstn;
	wire i_setn;
	wire i_oen;
    wire i_od;
	
	reg id_reg;
    reg od_reg;
    reg oen_reg;

    wire    id_rstn;
    wire    id_setn;
    wire    od_rstn;
    wire    od_setn;
    wire    oen_setn;
    wire    oen_rstn;

    wire    inv_clk;
    wire    gate_clk;
    wire    out_en;
    wire    out_data;

	
//---------------------------------------------------------------------------------
//basic setting
//---------------------------------------------------------------------------------
	assign inv_clk  = (cfg_fclk_inv == 1'b1) ? ~clk0 : clk0;  	
	assign i_oen    = (cfg_oen_inv  == 1'b1) ? ~oen : oen;   	
	assign i_od     = (cfg_od_inv   == 1'b1) ? ~od_d : od_d;   	

    //assign en       = (is_en_used  == 1'b1) ? clk_en : 1'b0;
    assign gate_clk = (cfg_fclk_gate_sel == 1'b1) ? inv_clk : inv_clk & clk_en;
    assign i_clk    = (cfg_fclk_en == 1'b1) ? gate_clk : 1'b0;

	assign i_rstn   = (cfg_rstn_inv == 1'b1) ? ~rstn : rstn;   	
	assign i_setn   = (cfg_setn_inv == 1'b1) ? ~setn : setn;   	

    assign id_rstn  = (cfg_id_rstn_en == 1'b1) ? i_rstn : 1'b1;
    assign id_setn  = (cfg_id_setn_en == 1'b1) ? i_setn : 1'b1;

    assign od_rstn  = (cfg_od_rstn_en == 1'b1) ? i_rstn : 1'b1;
    assign od_setn  = (cfg_od_setn_en == 1'b1) ? i_setn : 1'b1;

    assign oen_rstn  = (cfg_oen_rstn_en == 1'b1) ? i_rstn : 1'b1;
    assign oen_setn  = (cfg_oen_setn_en == 1'b1) ? i_setn : 1'b1;

//---------------------------------------------------------------------------------
//id/od/oen reg
//---------------------------------------------------------------------------------
    always @ (posedge i_clk or negedge id_rstn or negedge id_setn) begin
        if(~id_rstn)        id_reg <= 0;
        else if(~id_setn)   id_reg <= 1;
        else                id_reg <= pad;
    end
	
    always @ (posedge i_clk or negedge od_rstn or negedge od_setn) begin
        if(~od_rstn)        od_reg <= 0;
        else if(~od_setn)   od_reg <= 1;
        else                od_reg <= i_od;
    end

    always @ (posedge i_clk or negedge oen_rstn or negedge oen_setn) begin
        if(~oen_rstn)        oen_reg <= 0;
        else if(~oen_setn)   oen_reg <= 1;
        else                 oen_reg <= i_oen;
    end
	

//---------------------------------------------------------------------------------
//input, oen, output generation
//---------------------------------------------------------------------------------
	assign id_q = (fast_input == 1'b1) ? id_reg : pad;
	
	assign out_en = (fast_oe == 1'b1) ? oen_reg : 
                    (io_type == "input") ? 1'b1 :
                    (io_type == "output") ? 1'b0 :
                    (io_type == "inout") ? i_oen :  1'bx;
									
    assign out_data = (fast_output == 1'b1) ? od_reg : i_od;

    assign pad = ~out_en ? out_data : 1'bz;

endmodule


`timescale 1ps/1ps
module M7S_DLL (
    clkin,      // input reference clock - up to 1 can be used
    pwrdown,    // power down, low active
    dllrst,
    fp_dll_rst,
    clkout0,
    clkout1,
    clkout2,
    dll_msel0_user,
    clkout3,
    locked      // indicates when the DLL locks onto the input clock  
);

    parameter cfg_dllpd_sel       = 2'b00;   // DLL power down select
                                             //== 00: always off       01: always on
                                             //== 10: DYN_CTRL_PWRDOWN 11: powerdown
    parameter cfg_mrst_sel        = 2'b00;   // DLL reset select
                                             //== 11: dllrst,     10: dyn_dll_rst
                                             //== 01: fp_dll_rst, 00: auto_rst
    parameter dll_sel = "auto"; //default: "auto", can be "0", "1", "2" or "3".

    parameter dll_bypass          = 1'b0;    // 1: bypass
    parameter dll_msel0           = 4'b0000; // clock phase select, 22.5 per step, total 360
    parameter dll_msel1           = 4'b0000; // clock phase select, 22.5 per step, total 360
    parameter dll_msel2           = 4'b0000; // clock phase select, 22.5 per step, total 360
    parameter dll_msel3           = 4'b0000; // clock phase select, 22.5 per step, total 360
    parameter dll_lfm             = 1'b0;    // 0: high frequency(150~450M)  0: high frequency(50~250M)

    //parameter not set by user
    parameter dll_cpsel           = 2'b00;   // DLL Charge pump current select
    parameter dll_ibufsel         = 2'b00;   // DLL Buffer current select
    parameter dll_mfb0_trm        = 3'b000;  // DLL Feedback 0 delay trim
    parameter dll_mfb16_trm       = 3'b000;  // DLL Feedback 16 delay trim
    parameter dll_ldrange         = 1'b0;    // DLL Lock detector phase error range select
    parameter dll_fle_en          = 1'b0;    // DLL False lock eliminator enable control
    parameter dll_force_lock      = 1'b0;    // DLL Force lock
    parameter dll_atest_en        = 1'b0;    // DLL Test control enable for analog test output
    parameter dll_dtest_en        = 1'b0;    // DLL Test control enable for digital test output
    parameter dll_atest_sel       = 1'b0;    // DLL Analog test select
    parameter dll_dtest_sel       = 1'b0;    // DLL Digital test select
    parameter dll_bk              = 2'b00;   // DLL Digital test select

    //parameter d2s_en              = 1'b0;    // DLL D2S of VCDL power save control
    parameter dyn_dll_rst         = 1'b0;    // Dynamic reset control
    parameter dyn_dll_pwrdown     = 1'b1;    // Dynamic powerdown control, default power on.

    parameter cfg_dllphase0_ctrl  = 1'b0;  //DLL MSEL0 control: 0: dll_msel0, 1: dll_msel0_user;
	
    // INPUT PORT DECLARATION
    input      clkin;
    input      pwrdown;
    input      dllrst;
    input      fp_dll_rst;
	input	[3:0]	dll_msel0_user;

    // OUTPUT PORT DECLARATION
    output     clkout0;
    output     clkout1;
    output     clkout2;
    output     clkout3;
    output     locked;


    //assert a suspend value
    tri1 pwrdown;
    tri0 fp_dll_rst;

    //internal signals
    reg tmp_clkout0;
    reg tmp_clkout1;
    reg tmp_clkout2;
    reg tmp_clkout3;
    time edge_1st_t;
    time edge_2nd_t;
    time period;
    reg dll_locked;
    integer lock_counter;

    //behavior logic of dll
    initial begin //initial value
        edge_1st_t = 0;
        edge_2nd_t = 0;
        period = 0;
        dll_locked = 0;
        lock_counter = 0;
    end

    //calculate the period of the clkin, and generate dll locked signal
    always@(pwrdown, fp_dll_rst, clkin)
    begin
        if((cfg_dllpd_sel == 2'b11 && !pwrdown) || (cfg_mrst_sel == 2'b01 && fp_dll_rst)) begin
            //re-init the value
            lock_counter = 0;
            edge_1st_t = 0;
            edge_2nd_t = 0;
            period = 0;
            dll_locked = 0;
        end
        else if(clkin == 1'b0 && lock_counter < 3) begin //when locked, lock_counter will keep equal to 3
            @(posedge clkin);
            lock_counter = lock_counter + 1;
            if(lock_counter == 1)
                edge_1st_t = $time;
            else if(lock_counter == 2) begin
                edge_2nd_t = $time;
                period = edge_2nd_t - edge_1st_t;
            end
            else if(lock_counter == 3 && cfg_dllpd_sel != 2'b00)
                dll_locked = 1;
        end
    end

    //generate the 4 clkout with configured phase delay value
    always @(clkin) begin
        tmp_clkout0 <= #(period * dll_msel0 / 16) clkin; 
        tmp_clkout1 <= #(period * dll_msel1 / 16) clkin; 
        tmp_clkout2 <= #(period * dll_msel2 / 16) clkin; 
        tmp_clkout3 <= #(period * dll_msel3 / 16) clkin; 
    end

    //the final locked and 4 clkout signals
    assign locked = dll_locked;
    assign clkout0 = (cfg_dllpd_sel == 2'b00 || (cfg_dllpd_sel == 2'b11 && !pwrdown)) ? 1'b0 : (dll_bypass || !dll_locked ? clkin : tmp_clkout0);
    assign clkout1 = (cfg_dllpd_sel == 2'b00 || (cfg_dllpd_sel == 2'b11 && !pwrdown)) ? 1'b0 : (dll_bypass || !dll_locked ? clkin : tmp_clkout1);
    assign clkout2 = (cfg_dllpd_sel == 2'b00 || (cfg_dllpd_sel == 2'b11 && !pwrdown)) ? 1'b0 : (dll_bypass || !dll_locked ? clkin : tmp_clkout2);
    assign clkout3 = (cfg_dllpd_sel == 2'b00 || (cfg_dllpd_sel == 2'b11 && !pwrdown)) ? 1'b0 : (dll_bypass || !dll_locked ? clkin : tmp_clkout3);
	specify
	// IOPATH
(clkin => clkout0  ) = (0,0);
(clkin => clkout1  ) = (0,0);
(clkin => clkout2  ) = (0,0);
(clkin => clkout3  ) = (0,0);
		endspecify
endmodule 


module M7S_PLL (
    clkin0,      // input reference clock - up to 2 can be used
    clkin1,      // input reference clock - up to 2 can be used
    fbclkin,    // external feedback input port
    pwrdown,    // power down, low active, can be used as asynchronous reset
    pllrst,
    fp_pll_rst,
	ACTIVECK,
	CKBAD0,
	CKBAD1,
    clkout0,
    clkout1,
    clkout2,
    clkout3,
    locked      // indicates when the PLL locks onto the input clock  
);
    //parameter INMUX_CFG
	parameter cfg_nc         = 3'b000 ;
	parameter cfg_ldo_cfg    = 5'b00000 ;
	
    parameter pll_sel = "auto"; //default: "auto", can be "0", "1", "2" or "3".
    parameter pwrmode            = 2'b00;          // PLL Power down control
                                                   //==00: always off
                                                   //==01:always on  
                                                   //==10:DYN_PLL_PWRDOWE
                                                   //==11:pwrdown
    parameter rst_pll_sel        = 2'b00;          // PLL RST select
                                                   //== 11: pllrst,     10: dyn_pll_rst
                                                   //== 01: fp_pll_rst, 00: ccb_rst
    parameter sel_fbpath         = 1'b0;           //Select the feedback signal to PFD 
                                                   //== 0: Feedback signal is from VCO  (default)
                                                   //== 1: Feedback signal is from CFBCK pin (Deskew mode)
    parameter pll_divm               = 8'b0000_0000;   // PLL Loop divider control, range within[1,256]
    parameter pll_divn               = 8'b0000_0000;   // PLL Input divider control, range within[1,256]
    parameter pll_divc0              = 8'b0000_0000;   // PLL Output divider control for channel 0, range within[1,256]
    parameter pll_divc1              = 8'b0000_0000;   // PLL Output divider control for channel 1, range within[1,256]
    parameter pll_divc2              = 8'b0000_0000;   // PLL Output divider control for channel 2, range within[1,256]
    parameter pll_divc3              = 8'b0000_0000;   // PLL Output divider control for channel 3, range within[1,256]
    parameter pll_mken0              = 1'b0;           // Output enable for channel 0
    parameter pll_mken1              = 1'b0;           // Output enable for channel 1
    parameter pll_mken2              = 1'b0;           // Output enable for channel 2
    parameter pll_mken3              = 1'b0;           // Output enable for channel 3
    parameter pll_bps0               = 1'b0;           // Bypass output of channel 0
    parameter pll_bps1               = 1'b0;           // Bypass output of channel 1
    parameter pll_bps2               = 1'b0;           // Bypass output of channel 2
    parameter pll_bps3               = 1'b0;           // Bypass output of channel 3
    parameter pll_co0dly             = 8'b0000_0000;   // PLL Channel 0 coarse delay control, Delay range within [0, 255] 
    parameter pll_co1dly             = 8'b0000_0000;   // PLL Channel 1 coarse delay control, Delay range within [0, 255] 
    parameter pll_co2dly             = 8'b0000_0000;   // PLL Channel 2 coarse delay control, Delay range within [0, 255] 
    parameter pll_co3dly             = 8'b0000_0000;   // PLL Channel 3 coarse delay control, Delay range within [0, 255] 
    parameter pll_divmp              = 3'b000;         // PLL VCO post divider control
                                                   //== 000: divide by 1        001: divide by 2
                                                   //== 010: divide by 4        011: divide by 8
                                                   //== 100~111: divider by 16
    parameter pll_sel_c0phase        = 3'b000;         // Select different phase clock for channel PLL 0, 45 per step
    parameter pll_sel_c1phase        = 3'b000;         // Select different phase clock for channel PLL 1, 45 per step
    parameter pll_sel_c2phase        = 3'b000;         // Select different phase clock for channel PLL 2, 45 per step
    parameter pll_sel_c3phase        = 3'b000;         // Select different phase clock for channel PLL 3, 45 per step
 
    //parameter not set by user
    parameter dyn_pll_rst			 = 1'b0;           // Dynamic powerdown control, default power on.
    parameter dyn_pll_pwrdown		 = 1'b1;           // Dynamic powerdown control, default power on.

    parameter pll_mp_autor_en        = 1'b0;           // Enable the auto-reset function in DIV_MP module when the input change
    parameter pll_lpf                = 2'b00;          // PLL Loop filter resistance value adjustment
    parameter pll_vrsel              = 2'b01;          // Select the reference voltage for regulator
                                                   //== 00: 1.1V        01: 1.2V   (default)
                                                   //== 10: 1.25V       11: 1.3V
    parameter pll_cpsel_cr           = 2'b00;          // Select Charge pump current, coarse tune
    parameter pll_cpsel_fn           = 3'b000;         // Select Charge pump current, fine tune
    parameter pll_kvsel              = 2'b00;          // KVCO select
    parameter pll_fldd               = 2'b00;          // Lock detector phase error range select
    parameter pll_force_lock         = 1'b0;           // PLL Force PLOCK signal to high
    parameter pll_atest_en           = 1'b0;           // PLL Test control enable for analog test output
    parameter pll_dtest_en           = 1'b0;           // PLL Test control enable for digital test output
    parameter pll_atest_sel          = 1'b0;           // PLL Analog test select
    parameter pll_dtest_sel          = 1'b0;           // PLL Digital test select
    parameter pll_bp_dvdd12          = 1'b0;           // Bypass dvdd to vddd
	parameter pll_divfb              = 1'b0;
	parameter pll_cksel              = 1'b0;
	parameter pll_ck_switch_en       = 1'b0;
	parameter pll_lkd_tol            = 1'b0;
	parameter pll_lkd_hold           = 1'b0;
	parameter pll_ssen               = 1'b0;
	parameter pll_ssrg               = 2'b00;
	parameter pll_ssdivh             = 2'b00;
	parameter pll_ssdivl             = 8'b0000_0000;
	parameter pll_bk                 = 2'b00;
	parameter pll_fbck_del           = 4'b0000;

    parameter amux_sel               = 6'b00_0000;     // Select AMUX output

    // INPUT PORT DECLARATION
    input      clkin0;
    input      clkin1;
    input      fbclkin;
    input      pwrdown;
    input      pllrst;
    input      fp_pll_rst;

    // OUTPUT PORT DECLARATION
    output     clkout0;
    output     clkout1;
    output     clkout2;
    output     clkout3;
    output     locked;
	output	   ACTIVECK;
	output	   CKBAD0;
	output	   CKBAD1;

wire PDB;
wire RSTPLL;

assign PDB   = pwrmode[1:0] == 2'b11 ? pwrdown    :
               pwrmode[1:0] == 2'b10 ? 1'b0       :
               pwrmode[1:0] == 2'b01 ? 1'b1       :
                                       1'b0       ;

assign RSTPLL = rst_pll_sel[1:0] == 2'b11 ? 1'b1       :
                rst_pll_sel[1:0] == 2'b10 ? 1'b0       :
                rst_pll_sel[1:0] == 2'b01 ? fp_pll_rst :
                                            1'b0       ;
PLL_SIM u0_pll_sim(
     .VDDIO         (1'b1                          )
    ,.VSSIO         (1'b0                          )
    ,.DVDD          (1'b1                          )
    ,.DVSS          (1'b0                          )
    ,.AVSS_VCO      (1'b0                          )
    ,.AVSS          (1'b0                          )
    ,.PLLCK0        (clkin0                        )
    ,.PLLCK1        (clkin1                        )
    ,.CFBCK         (fbclkin                       )
    ,.VREF          (1'b1                          )
    ,.CO0           (clkout0                       )
    ,.CO1           (clkout1                       )
    ,.CO2           (clkout2                       )
    ,.CO3           (clkout3                       )
    ,.PLOCK         (locked                        )
    ,.ACTIVECK      (ACTIVECK                      )
    ,.ATEST_PLL     (                              )
    ,.DTEST_PLL     (                              )
    ,.PDB           (PDB                           )
    ,.RSTPLL        (RSTPLL                        )
    ,.MKEN0         (pll_mken0                     )
    ,.MKEN1         (pll_mken1                     )
    ,.MKEN2         (pll_mken2                     )
    ,.MKEN3         (pll_mken3                     )
    ,.BPS0          (pll_bps0                      )
    ,.BPS1          (pll_bps1                      )
    ,.BPS2          (pll_bps2                      )
    ,.BPS3          (pll_bps3                      )
    ,.DIVN          (pll_divn                      )
    ,.DIVM          (pll_divm                      )
    ,.DIVC0         (pll_divc0                     )
    ,.DIVC1         (pll_divc1                     )
    ,.DIVC2         (pll_divc2                     )
    ,.DIVC3         (pll_divc3                     )
    ,.CO0DLY        (pll_co0dly                    )
    ,.CO1DLY        (pll_co1dly                    )
    ,.CO2DLY        (pll_co2dly                    )
    ,.CO3DLY        (pll_co3dly                    )
    ,.SEL_FBPATH    (sel_fbpath                    )
    ,.DIVMP         (pll_divmp                     )
    ,.SEL_C0PHASE   (pll_sel_c0phase               )
    ,.SEL_C1PHASE   (pll_sel_c1phase               )
    ,.SEL_C2PHASE   (pll_sel_c2phase               )
    ,.SEL_C3PHASE   (pll_sel_c3phase               )
    ,.MP_AUTOR_EN   (pll_mp_autor_en               )
    ,.LPF           (pll_lpf                       )
    ,.VRSEL         (pll_vrsel                     )
    ,.CPSEL_CR      (pll_cpsel_cr                  )
    ,.CPSEL_FN      (pll_cpsel_fn                  )
    ,.KVSEL         (pll_kvsel                     )
    ,.FLDD          (pll_fldd                      )
    ,.FORCE_LOCK    (pll_force_lock                )
    ,.ATEST_EN      (pll_atest_en                  )
    ,.DTEST_EN      (pll_dtest_en                  )
    ,.ATEST_SEL     (pll_atest_sel                 )
    ,.DTEST_SEL     (pll_dtest_sel                 )
    ,.BP_DVDD12     (pll_bp_dvdd12                 )
    ,.DIVFB         (pll_divfb                     )
    ,.CKSEL         (pll_cksel                     )
    ,.CK_SWITCH_EN  (pll_ck_switch_en              )
    ,.LKD_TOL       (pll_lkd_tol                   )
    ,.LKD_HOLD      (pll_lkd_hold                  )
    ,.SSEN          (pll_ssen                      )
    ,.SSRG          (pll_ssrg                      )
    ,.SSDIVH        (pll_ssdivh                    )
    ,.SSDIVL        (pll_ssdivl                    )
    ,.BK            (pll_bk                        )
    ,.CKBAD0        (CKBAD0                        )
    ,.CKBAD1        (CKBAD1                        )
  );
endmodule 

`timescale 1ns/1ps
module PLL_SIM(
                 VDDIO        ,  //io power supply for regulator  
                 VSSIO        ,  //io ground for regulator
                 DVDD         ,  //digital power supply
                 DVSS         ,  //digital ground
                 AVSS_VCO     ,  //VCO ground
                 AVSS         ,  //analog ground
                 PLLCK0       ,  //PLL reference clock
                 PLLCK1       ,  //PLL reference clock
                 CFBCK        ,  //feedback clock for deskew mode
                 VREF         ,  //reference voltage for regulator
                 CO0          ,  //PLL output clock channel 0
                 CO1          ,  //PLL output clock channel 1
                 CO2          ,  //PLL output clock channel 2
                 CO3          ,  //PLL output clock channel 3
                 PLOCK        ,  //PLL lock status output
                 ACTIVECK     ,  //Indicated that which clock is selected now
                 ATEST_PLL    ,  //analog signal test output
                 DTEST_PLL    ,  //digital signal test output
                 PDB          ,  //power-down mode control
                 RSTPLL       ,  //reset PLL control
                 MKEN0        ,  //output enable for channel 0
                 MKEN1        ,  //output enable for channel 1
                 MKEN2        ,  //output enable for channel 2
                 MKEN3        ,  //output enable for channel 3
                 BPS0         ,  //bypass output of channel 0
                 BPS1         ,  //bypass output of channel 1
                 BPS2         ,  //bypass output of channel 2
                 BPS3         ,  //bypass output of channel 3
                 DIVN         ,  //input divider control
                 DIVM         ,  //loop divider control
                 DIVC0        ,  //output divider control for channel 0
                 DIVC1        ,  //output divider control for channel 1
                 DIVC2        ,  //output divider control for channel 2
                 DIVC3        ,  //output divider control for channel 3
                 CO0DLY       ,  //channel 0 coarse delay control
                 CO1DLY       ,  //channel 1 coarse delay control
                 CO2DLY       ,  //channel 2 coarse delay control
                 CO3DLY       ,  //channel 3 coarse delay control
                 SEL_FBPATH   ,  //select the feedback signal to PFD
                 DIVMP        ,  //VCO post divider control
                 SEL_C0PHASE  ,  //select phase for channel 0
                 SEL_C1PHASE  ,  //select phase for channel 1
                 SEL_C2PHASE  ,  //select phase for channel 2
                 SEL_C3PHASE  ,  //select phase for channel 3
                 MP_AUTOR_EN  ,  //MP divider auto reset enable
                 LPF          ,  //loop filter resistance value adjustment
                 VRSEL        ,  //select the reference voltage for regulator
                 CPSEL_CR     ,  //select CP current,coarse tune
                 CPSEL_FN     ,  //select CP current,fine tune
                 KVSEL        ,  //select KVCO value
                 FLDD         ,  //lock detector range select
                 FORCE_LOCK   ,  //force PLOCK signal to high
                 ATEST_EN     ,  //test control enable for analog test 
                 DTEST_EN     ,  //test control enable for digital test 
                 ATEST_SEL    ,  //analog test select
                 DTEST_SEL    ,  //digital test select
                 BP_DVDD12    ,  //bypass dvdd(core) to vddd
                 DIVFB        ,  //internal feedback clock of VCO control
                 CKSEL        ,  //Select input clock from PLLCK0 or PLLCK1 in manual selection mode 0: from PLLCK0  (default) 1: from PLLCK1
                 CK_SWITCH_EN ,  //Input clock automatic selection enable 0:manual select  (default) 1:automatic select
                 LKD_TOL      ,  //Lock Detector tolerance (TBD)
                 LKD_HOLD     ,  // Lock Detector hold number (TBD)
                 SSEN         ,  //Spread spectrum function enable 0:don't use SSCG function  (default) 1:enable
                 SSRG         ,  //Spread ratio select (TBD)
                 SSDIVH       ,  //Spread frequency-divider 1 control, range within[1,16] divider value NH=SSDIVH<3:0>+1
                 SSDIVL       ,  //Spread frequency-divider 2 control, range within[1,256] divider value NH=SSDIVL<7:0>+1
                 BK           ,  //Back up register
                 CKBAD0       ,
                 CKBAD1
  );

//port definition

input         VDDIO        ;  //io power supply for regulator  
input         VSSIO        ;  //io ground for regulator
input         DVDD         ;  //digital power supply
input         DVSS         ;  //digital ground
input         AVSS_VCO     ;  //VCO ground
input         AVSS         ;  //analog ground
input         PLLCK0       ;  //PLL reference clock
input         PLLCK1       ;  //PLL reference clock
input         CFBCK        ;  //feedback clock for deskew mode
input         VREF         ;  //reference voltage for regulator
output        CO0          ;  //PLL output clock channel 0
output        CO1          ;  //PLL output clock channel 1
output        CO2          ;  //PLL output clock channel 2
output        CO3          ;  //PLL output clock channel 3
output        PLOCK        ;  //PLL lock status output
output        ACTIVECK     ;  //Indicated that which clock is selected now
output        ATEST_PLL    ;  //analog signal test output
output        DTEST_PLL    ;  //digital signal test output
input         PDB          ;  //power-down mode control
input         RSTPLL       ;  //reset PLL control
input         MKEN0        ;  //output enable for channel 0
input         MKEN1        ;  //output enable for channel 1
input         MKEN2        ;  //output enable for channel 2
input         MKEN3        ;  //output enable for channel 3
input         BPS0         ;  //bypass output of channel 0
input         BPS1         ;  //bypass output of channel 1
input         BPS2         ;  //bypass output of channel 2
input         BPS3         ;  //bypass output of channel 3
input  [7:0]  DIVN         ;  //input divider control
input  [7:0]  DIVM         ;  //loop divider control
input  [7:0]  DIVC0        ;  //output divider control for channel 0
input  [7:0]  DIVC1        ;  //output divider control for channel 1
input  [7:0]  DIVC2        ;  //output divider control for channel 2
input  [7:0]  DIVC3        ;  //output divider control for channel 3
input  [7:0]  CO0DLY       ;  //channel 0 coarse delay control
input  [7:0]  CO1DLY       ;  //channel 1 coarse delay control
input  [7:0]  CO2DLY       ;  //channel 2 coarse delay control
input  [7:0]  CO3DLY       ;  //channel 3 coarse delay control
input         SEL_FBPATH   ;  //select the feedback signal to PFD
input  [2:0]  DIVMP        ;  //VCO post divider control
input  [2:0]  SEL_C0PHASE  ;  //select phase for channel 0
input  [2:0]  SEL_C1PHASE  ;  //select phase for channel 1
input  [2:0]  SEL_C2PHASE  ;  //select phase for channel 2
input  [2:0]  SEL_C3PHASE  ;  //select phase for channel 3
input         MP_AUTOR_EN  ;  //MP divider auto reset enable
input  [1:0]  LPF          ;  //loop filter resistance value adjustment
input  [1:0]  VRSEL        ;  //select the reference voltage for regulator
input  [1:0]  CPSEL_CR     ;  //select CP current,coarse tune
input  [2:0]  CPSEL_FN     ;  //select CP current,fine tune
input  [1:0]  KVSEL        ;  //select KVCO value
input  [1:0]  FLDD         ;  //lock detector range select
input         FORCE_LOCK   ;  //force PLOCK signal to high
input         ATEST_EN     ;  //test control enable for analog test 
input         DTEST_EN     ;  //test control enable for digital test 
input         ATEST_SEL    ;  //analog test select
input         DTEST_SEL    ;  //digital test select
input         BP_DVDD12    ;  //bypass dvdd(core) to vddd
input         DIVFB        ;  //internal feedback clock of VCO control
input         CKSEL        ;  //Select input clock from PLLCK0 or PLLCK1 in manual selection mode 0: from PLLCK0  (default) 1: from PLLCK1
input         CK_SWITCH_EN ;  //Input clock automatic selection enable 0:manual select  (default) 1:automatic select
input         LKD_TOL      ;  //Lock Detector tolerance (TBD)
input         LKD_HOLD     ;  // Lock Detector hold number (TBD)
input         SSEN         ;  //Spread spectrum function enable 0:don't use SSCG function  (default) 1:enable
input  [1:0]  SSRG         ;  //Spread ratio select (TBD)
input  [1:0]  SSDIVH       ;  //Spread frequency-divider 1 control, range within[1,16] divider value NH=SSDIVH<3:0>+1
input  [7:0]  SSDIVL       ;  //Spread frequency-divider 2 control, range within[1,256] divider value NH=SSDIVL<7:0>+1
input  [1:0]  BK           ;  //Back up register
output        CKBAD0       ;
output        CKBAD1       ;

//parameters definition

parameter MAX_INPUT_PERIOD  = 500;    // input freq       : 2MHZ--500MHz
parameter MIN_INPUT_PERIOD  = 2;         //
parameter MAX_PFD_PERIOD  = 500;        // PFD input freq   : 2MHZ--400MHz
parameter MIN_PFD_PERIOD  = 2.5;          //
parameter MAX_VCO_PERIOD  = 1.667;        // VCO operate freq : 600MHZ--1250MHz
parameter MIN_VCO_PERIOD  = 0.8;          //
parameter MAX_OUTPUT_PERIOD  = 100;        // output freq      : 10MHZ--1250MHz
parameter MIN_OUTPUT_PERIOD  = 0.8;          //
parameter LOCK_TIME    = 200;       //lock time range is several us. Now we set the default value 200ns.

//internal signal definition

wire  ck_bps;
wire  ckin;
wire  fs_input_range;
wire  fs_pfd_range;
wire  fs_vco_range;
wire  dsk_input_range;
wire  dsk_pfd_range;
wire  dsk_vco_range;
wire  lock_pd;
wire  lock_fl;
wire  lock_fs;
wire  lock_dsk;
wire  lock_val_loop;
wire  lock_val;
wire  [5:0]  lock_th;
reg  [5:0]  lock_cnt;
reg  lock_tmp;
reg  PLOCK;
reg  plock_en;
wire  [8:0]  divn_num;
wire  [8:0]  divm_num;
wire  [4:0]  divmp_num;
wire  [1:0]  divfb_num;
wire  [8:0]  divc0_num;
wire  [8:0]  divc1_num;
wire  [8:0]  divc2_num;
wire  [8:0]  divc3_num;
reg  vco_mp_tmp;
reg  [7:0]  vco_mp_p;
wire  vco_mp_loop;

wire  C0_sel;
wire  C0_rb_en;
wire  C0_rb;
reg  C0_rb_tmp;
reg  [7:0]  C0_dlycnt;
wire  C0_divcnt_en;
reg  [7:0]  C0_divcnt;
wire  [8:0]  C0_half_period;
reg  C0_pos_level;
reg  C0_neg_level;
wire  C0_out_tmp;

wire  C1_sel;
wire  C1_rb_en;
wire  C1_rb;
reg  C1_rb_tmp;
reg  [7:0]  C1_dlycnt;
wire  C1_divcnt_en;
reg  [7:0]  C1_divcnt;
wire  [8:0]  C1_half_period;
reg  C1_pos_level;
reg  C1_neg_level;
wire  C1_out_tmp;

wire  C2_sel;
wire  C2_rb_en;
wire  C2_rb;
reg  C2_rb_tmp;
reg  [7:0]  C2_dlycnt;
wire  C2_divcnt_en;
reg  [7:0]  C2_divcnt;
wire  [8:0]  C2_half_period;
reg  C2_pos_level;
reg  C2_neg_level;
wire  C2_out_tmp;

wire  C3_sel;
wire  C3_rb_en;
wire  C3_rb;
reg  C3_rb_tmp;
reg  [7:0]  C3_dlycnt;
wire  C3_divcnt_en;
reg  [7:0]  C3_divcnt;
wire  [8:0]  C3_half_period;
reg  C3_pos_level;
reg  C3_neg_level;
wire  C3_out_tmp;

realtime t1;
realtime t2;
real  period_in; //integer period_in;
real  period_mp; //integer period_mp;

//initial the state

  initial begin
        period_in  = 50.000;
        period_mp  = 50.000;
        t1         = 50;
        t2         = 0;

  end

  assign lock_th = 6'b111111;
  assign divn_num = DIVN + 9'd1;
  assign divm_num = DIVM + 9'd1;
  assign divfb_num = DIVFB + 1'b1;
  assign divmp_num = (DIVMP == 3'b000) ? 5'b00001 :
         (DIVMP == 3'b001) ? 5'b00010 :
         (DIVMP == 3'b010) ? 5'b00100 :
         (DIVMP == 3'b011) ? 5'b01000 :
                   5'b10000 ;
  assign divc0_num = DIVC0 + 9'd1;
  assign divc1_num = DIVC1 + 9'd1;
  assign divc2_num = DIVC2 + 9'd1;
  assign divc3_num = DIVC3 + 9'd1;

//detect the input clock period

 assign ckin = (PDB==1'b0) ? 1'b0 : 
                             CKSEL == 0 ? PLLCK0 : 
                                          PLLCK1;
 assign ck_bps = CKSEL == 0 ? PLLCK0 : PLLCK1;
 always @(posedge ckin) begin
        t2=t1;
        t1=$realtime;
        if(t2 == 50) 
          period_in = 50;
        else
          period_in = t1 -t2;
        end

//lock judgement

  assign fs_input_range = ((period_in <= MAX_INPUT_PERIOD) && (period_in >= MIN_INPUT_PERIOD)) ? 1'b1 : 1'b0;
  assign fs_pfd_range = ((period_in*divn_num <= MAX_PFD_PERIOD) && (period_in*divn_num >= MIN_PFD_PERIOD)) ? 1'b1 : 1'b0;
  assign fs_vco_range = ((period_in*divn_num/(divm_num*divfb_num) <= MAX_VCO_PERIOD) && (period_in*divn_num/(divm_num*divfb_num) >= MIN_VCO_PERIOD)) ? 1'b1 : 1'b0;
  assign dsk_input_range = ((period_in <= MAX_INPUT_PERIOD) && (period_in >= MIN_INPUT_PERIOD)) ? 1'b1 : 1'b0;
  assign dsk_pfd_range = ((period_in*divn_num <= MAX_PFD_PERIOD) && (period_in*divn_num >= MIN_PFD_PERIOD)) ? 1'b1 : 1'b0;
  assign dsk_vco_range = ((period_in*divn_num/(divm_num*divmp_num*divc0_num) <= MAX_VCO_PERIOD) && (period_in*divn_num/(divm_num*divmp_num*divc0_num) >= MIN_VCO_PERIOD)) ? 1'b1 : 1'b0;
  assign lock_pd = 1'b0;
  assign lock_fl = 1'b1;
  assign lock_fs = (fs_input_range && fs_pfd_range && fs_vco_range) ? 1'b1 : 1'b0;
  assign lock_dsk = (dsk_input_range && dsk_pfd_range && dsk_vco_range) ? 1'b1 : 1'b0;
  assign lock_val_loop = (RSTPLL || !PDB) ? lock_pd :
        (!SEL_FBPATH) ? lock_fs :
        (BPS0) ? lock_pd :
        lock_dsk ;
  assign lock_val = (RSTPLL || !PDB) ? lock_pd :
                    FORCE_LOCK ? lock_fl : lock_val_loop;
  initial begin
  lock_cnt = 6'b000000;
  lock_tmp = 1'b0;
  PLOCK = 1'b0;
  end 
  always @(posedge ckin) begin
  if (lock_val == 1'b0) begin
        lock_tmp <= 1'b0;
        lock_cnt <= 6'b000000;
            end
  else if (lock_cnt[5:0] == lock_th[5:0]) begin
         lock_tmp <= 1'b1;
         lock_cnt <= lock_th[5:0];
                end
  else lock_cnt <= lock_cnt + 7'd1;
  end

  always @(posedge lock_tmp) PLOCK <= #LOCK_TIME lock_tmp;
  always @(negedge lock_tmp) PLOCK <= lock_tmp;

//PLL loop model

  initial begin
  vco_mp_tmp = 1'b0;
  vco_mp_p = 8'b00000000;
  end
  always @(*) begin
  if (!SEL_FBPATH) period_mp = period_in*divn_num*divmp_num/(divm_num*divfb_num*1.000);
  else      period_mp = period_in*divn_num/(divm_num*divc0_num*1.000);
  end
  //always #(period_mp/2) vco_mp_tmp = !vco_mp_tmp;
  //`ifdef SIM_VERSION
  initial begin
    wait (VDDIO);
    #300;
    forever vco_mp_tmp = #(period_mp/2.000) !vco_mp_tmp;
  end
  //`endif

  assign vco_mp_loop = (!PDB || RSTPLL) ? 1'b0 :
      (lock_val_loop) ? vco_mp_tmp : 1'b0;
  always @(negedge vco_mp_loop or negedge PDB or posedge RSTPLL) 
  if (!PDB || RSTPLL) plock_en <= 1'b0;
  else        plock_en <= PLOCK;
  always @(*) begin
  if (!plock_en) vco_mp_p = 8'b00000000;
  else begin  vco_mp_p[0] <= vco_mp_loop;
      vco_mp_p[1] <= #(1*period_mp/8.000) vco_mp_loop;  
      vco_mp_p[2] <= #(2*period_mp/8.000) vco_mp_loop;  
      vco_mp_p[3] <= #(3*period_mp/8.000) vco_mp_loop;  
      vco_mp_p[4] <= #(4*period_mp/8.000) vco_mp_loop;  
      vco_mp_p[5] <= #(5*period_mp/8.000) vco_mp_loop;  
      vco_mp_p[6] <= #(6*period_mp/8.000) vco_mp_loop;  
      vco_mp_p[7] <= #(7*period_mp/8.000) vco_mp_loop;
       end  
  end

//output C0 assignment

  assign C0_sel = (SEL_C0PHASE[2:0] == 3'b000) ? vco_mp_p[0] :
      (SEL_C0PHASE[2:0] == 3'b001) ? vco_mp_p[1] :
      (SEL_C0PHASE[2:0] == 3'b010) ? vco_mp_p[2] :
      (SEL_C0PHASE[2:0] == 3'b011) ? vco_mp_p[3] :
      (SEL_C0PHASE[2:0] == 3'b100) ? vco_mp_p[4] :
      (SEL_C0PHASE[2:0] == 3'b101) ? vco_mp_p[5] :
      (SEL_C0PHASE[2:0] == 3'b110) ? vco_mp_p[6] :
                     vco_mp_p[7] ;
  assign C0_rb_en = (PDB && !RSTPLL && MKEN0) ? 1'b1 : 1'b0;
  assign C0_rb = (PLOCK && C0_rb_en) ? 1'b1 : 1'b0;
  always @(negedge C0_sel or negedge C0_rb) begin
  if (!C0_rb)  C0_rb_tmp <= 1'b0;
  else    C0_rb_tmp <= 1'b1;
  end
  always @(posedge C0_sel or negedge C0_rb_tmp) begin
  if (!C0_rb_tmp)        C0_dlycnt <= 8'd0;
  else if (C0_dlycnt[7:0] == CO0DLY[7:0])  C0_dlycnt <= CO0DLY[7:0];
  else          C0_dlycnt <= C0_dlycnt + 8'd1;
  end

  assign C0_divcnt_en = (C0_dlycnt[7:0] == CO0DLY[7:0]) ;
  always @(posedge C0_sel or negedge C0_rb_tmp) begin
  if (!C0_rb_tmp)        C0_divcnt <= 8'd0;
  else if (!C0_divcnt_en)      C0_divcnt <= 8'd0;
  else if (C0_divcnt[7:0] == DIVC0[7:0])  C0_divcnt <= 8'd0;
  else          C0_divcnt <= C0_divcnt + 8'd1;
  end

  assign C0_half_period = {1'b0,DIVC0[7:0]} + 9'd1;
  always @(posedge C0_sel or negedge C0_rb_tmp) begin
  if (!C0_rb_tmp)          C0_pos_level <= 1'b0;
  else if (!C0_divcnt_en)        C0_pos_level <= 1'b0;
  else if (C0_divcnt[7:0] == 8'd0)    C0_pos_level <= 1'b1;
  else if (C0_divcnt[7:0] == C0_half_period[8:1])  C0_pos_level <= 1'b0;
  end
  always @(negedge C0_sel or negedge C0_rb_tmp) begin
  if (!C0_rb_tmp)    C0_neg_level <= 1'b0;
  else if (!C0_divcnt_en)  C0_neg_level <= 1'b0;
  else      C0_neg_level <= C0_pos_level;
  end
  assign C0_out_tmp =   (!C0_rb_tmp) ? 1'b0 :
      (!C0_divcnt_en) ? 1'b0 :
      (DIVC0[7:0] == 8'd0) ? C0_sel :
        (DIVC0[0] ? C0_pos_level : (C0_pos_level | C0_neg_level));
  assign CO0 = (BPS0) ? ck_bps : C0_out_tmp ;

//output C1 assignment

  assign C1_sel = (SEL_C1PHASE[2:0] == 3'b000) ? vco_mp_p[0] :
      (SEL_C1PHASE[2:0] == 3'b001) ? vco_mp_p[1] :
      (SEL_C1PHASE[2:0] == 3'b010) ? vco_mp_p[2] :
      (SEL_C1PHASE[2:0] == 3'b011) ? vco_mp_p[3] :
      (SEL_C1PHASE[2:0] == 3'b100) ? vco_mp_p[4] :
      (SEL_C1PHASE[2:0] == 3'b101) ? vco_mp_p[5] :
      (SEL_C1PHASE[2:0] == 3'b110) ? vco_mp_p[6] :
                     vco_mp_p[7] ;
  assign C1_rb_en = (PDB && !RSTPLL && MKEN0) ? 1'b1 : 1'b0;
  assign C1_rb = (PLOCK && C1_rb_en) ? 1'b1 : 1'b0;
  always @(negedge C1_sel or negedge C1_rb) begin
  if (!C1_rb)  C1_rb_tmp <= 1'b0;
  else    C1_rb_tmp <= 1'b1;
  end
  always @(posedge C1_sel or negedge C1_rb_tmp) begin
  if (!C1_rb_tmp)        C1_dlycnt <= 8'd0;
  else if (C1_dlycnt[7:0] == CO1DLY[7:0])  C1_dlycnt <= CO1DLY[7:0];
  else          C1_dlycnt <= C1_dlycnt + 8'd1;
  end

  assign C1_divcnt_en = (C1_dlycnt[7:0] == CO1DLY[7:0]) ;
  always @(posedge C1_sel or negedge C1_rb_tmp) begin
  if (!C1_rb_tmp)        C1_divcnt <= 8'd0;
  else if (!C1_divcnt_en)      C1_divcnt <= 8'd0;
  else if (C1_divcnt[7:0] == DIVC1[7:0])  C1_divcnt <= 8'd0;
  else          C1_divcnt <= C1_divcnt + 8'd1;
  end

  assign C1_half_period = {1'b0,DIVC1[7:0]} + 9'd1;
  always @(posedge C1_sel or negedge C1_rb_tmp) begin
  if (!C1_rb_tmp)          C1_pos_level <= 1'b0;
  else if (!C1_divcnt_en)        C1_pos_level <= 1'b0;
  else if (C1_divcnt[7:0] == 8'd0)    C1_pos_level <= 1'b1;
  else if (C1_divcnt[7:0] == C1_half_period[8:1])  C1_pos_level <= 1'b0;
  end
  always @(negedge C1_sel or negedge C1_rb_tmp) begin
  if (!C1_rb_tmp)    C1_neg_level <= 1'b0;
  else if (!C1_divcnt_en)  C1_neg_level <= 1'b0;
  else      C1_neg_level <= C1_pos_level;
  end
  assign C1_out_tmp =   (!C1_rb_tmp) ? 1'b0 :
      (!C1_divcnt_en) ? 1'b0 :
      (DIVC1[7:0] == 8'd0) ? C1_sel :
        (DIVC1[0] ? C1_pos_level : (C1_pos_level | C1_neg_level));
  assign CO1 = (BPS0) ? ck_bps : C1_out_tmp ;

//output C2 assignment

  assign C2_sel = (SEL_C2PHASE[2:0] == 3'b000) ? vco_mp_p[0] :
      (SEL_C2PHASE[2:0] == 3'b001) ? vco_mp_p[1] :
      (SEL_C2PHASE[2:0] == 3'b010) ? vco_mp_p[2] :
      (SEL_C2PHASE[2:0] == 3'b011) ? vco_mp_p[3] :
      (SEL_C2PHASE[2:0] == 3'b100) ? vco_mp_p[4] :
      (SEL_C2PHASE[2:0] == 3'b101) ? vco_mp_p[5] :
      (SEL_C2PHASE[2:0] == 3'b110) ? vco_mp_p[6] :
                     vco_mp_p[7] ;
  assign C2_rb_en = (PDB && !RSTPLL && MKEN0) ? 1'b1 : 1'b0;
  assign C2_rb = (PLOCK && C2_rb_en) ? 1'b1 : 1'b0;
  always @(negedge C2_sel or negedge C2_rb) begin
  if (!C2_rb)  C2_rb_tmp <= 1'b0;
  else    C2_rb_tmp <= 1'b1;
  end
  always @(posedge C2_sel or negedge C2_rb_tmp) begin
  if (!C2_rb_tmp)        C2_dlycnt <= 8'd0;
  else if (C2_dlycnt[7:0] == CO2DLY[7:0])  C2_dlycnt <= CO2DLY[7:0];
  else          C2_dlycnt <= C2_dlycnt + 8'd1;
  end

  assign C2_divcnt_en = (C2_dlycnt[7:0] == CO2DLY[7:0]) ;
  always @(posedge C2_sel or negedge C2_rb_tmp) begin
  if (!C2_rb_tmp)        C2_divcnt <= 8'd0;
  else if (!C2_divcnt_en)      C2_divcnt <= 8'd0;
  else if (C2_divcnt[7:0] == DIVC2[7:0])  C2_divcnt <= 8'd0;
  else          C2_divcnt <= C2_divcnt + 8'd1;
  end

  assign C2_half_period = {1'b0,DIVC2[7:0]} + 9'd1;
  always @(posedge C2_sel or negedge C2_rb_tmp) begin
  if (!C2_rb_tmp)          C2_pos_level <= 1'b0;
  else if (!C2_divcnt_en)        C2_pos_level <= 1'b0;
  else if (C2_divcnt[7:0] == 8'd0)    C2_pos_level <= 1'b1;
  else if (C2_divcnt[7:0] == C2_half_period[8:1])  C2_pos_level <= 1'b0;
  end
  always @(negedge C2_sel or negedge C2_rb_tmp) begin
  if (!C2_rb_tmp)    C2_neg_level <= 1'b0;
  else if (!C2_divcnt_en)  C2_neg_level <= 1'b0;
  else      C2_neg_level <= C2_pos_level;
  end
  assign C2_out_tmp =   (!C2_rb_tmp) ? 1'b0 :
      (!C2_divcnt_en) ? 1'b0 :
      (DIVC2[7:0] == 8'd0) ? C2_sel :
        (DIVC2[0] ? C2_pos_level : (C2_pos_level | C2_neg_level));
  assign CO2 = (BPS0) ? ck_bps : C2_out_tmp ;

//output C3 assignment

  assign C3_sel = (SEL_C3PHASE[2:0] == 3'b000) ? vco_mp_p[0] :
      (SEL_C3PHASE[2:0] == 3'b001) ? vco_mp_p[1] :
      (SEL_C3PHASE[2:0] == 3'b010) ? vco_mp_p[2] :
      (SEL_C3PHASE[2:0] == 3'b011) ? vco_mp_p[3] :
      (SEL_C3PHASE[2:0] == 3'b100) ? vco_mp_p[4] :
      (SEL_C3PHASE[2:0] == 3'b101) ? vco_mp_p[5] :
      (SEL_C3PHASE[2:0] == 3'b110) ? vco_mp_p[6] :
                     vco_mp_p[7] ;
  assign C3_rb_en = (PDB && !RSTPLL && MKEN0) ? 1'b1 : 1'b0;
  assign C3_rb = (PLOCK && C3_rb_en) ? 1'b1 : 1'b0;
  always @(negedge C3_sel or negedge C3_rb) begin
  if (!C3_rb)  C3_rb_tmp <= 1'b0;
  else    C3_rb_tmp <= 1'b1;
  end
  always @(posedge C3_sel or negedge C3_rb_tmp) begin
  if (!C3_rb_tmp)        C3_dlycnt <= 8'd0;
  else if (C3_dlycnt[7:0] == CO3DLY[7:0])  C3_dlycnt <= CO3DLY[7:0];
  else          C3_dlycnt <= C3_dlycnt + 8'd1;
  end

  assign C3_divcnt_en = (C3_dlycnt[7:0] == CO3DLY[7:0]) ;
  always @(posedge C3_sel or negedge C3_rb_tmp) begin
  if (!C3_rb_tmp)        C3_divcnt <= 8'd0;
  else if (!C3_divcnt_en)      C3_divcnt <= 8'd0;
  else if (C3_divcnt[7:0] == DIVC3[7:0])  C3_divcnt <= 8'd0;
  else          C3_divcnt <= C3_divcnt + 8'd1;
  end

  assign C3_half_period = {1'b0,DIVC3[7:0]} + 9'd1;
  always @(posedge C3_sel or negedge C3_rb_tmp) begin
  if (!C3_rb_tmp)          C3_pos_level <= 1'b0;
  else if (!C3_divcnt_en)        C3_pos_level <= 1'b0;
  else if (C3_divcnt[7:0] == 8'd0)    C3_pos_level <= 1'b1;
  else if (C3_divcnt[7:0] == C3_half_period[8:1])  C3_pos_level <= 1'b0;
  end
  always @(negedge C3_sel or negedge C3_rb_tmp) begin
  if (!C3_rb_tmp)    C3_neg_level <= 1'b0;
  else if (!C3_divcnt_en)  C3_neg_level <= 1'b0;
  else      C3_neg_level <= C3_pos_level;
  end
  assign C3_out_tmp =   (!C3_rb_tmp) ? 1'b0 :
      (!C3_divcnt_en) ? 1'b0 :
      (DIVC3[7:0] == 8'd0) ? C3_sel :
      (DIVC3[0] ? C3_pos_level : (C3_pos_level | C3_neg_level));
  assign CO3 = (BPS0) ? ck_bps : C3_out_tmp ;

endmodule

module M7A_SPRAM (
    // Outputs
	fp_r_data ,
    // Inputs
	clk_mem_fp,
	rst_mem_fp_n,
	fp_ce_n,
	fp_wr,
	fp_w_data,
	fp_addr,
	fp_byte_en
);

    parameter spram_mode = 2'b01;
    parameter init_file = "";

    // Outputs
	output [31:0] fp_r_data ;
    // Inputs
	input  clk_mem_fp;
	input  rst_mem_fp_n;
	input  fp_ce_n;
	input  fp_wr;
	input  [31:0] fp_w_data;
	input  [15:0] fp_addr;
	input  [3:0] fp_byte_en;

    integer addr;

    reg [31:0] mem [0:(1<<16)-1];
    reg [7:0] mem0 [0:(1<<16)-1];
    reg [7:0] mem1 [0:(1<<16)-1];
    reg [7:0] mem2 [0:(1<<16)-1];
    reg [7:0] mem3 [0:(1<<16)-1];

    reg [31:0] tmp;

    initial begin
        if(init_file == " " || init_file == "")
        begin
             //$display("sram does not need data file for memory initialization.\n");
        end
        else
        begin
            $display("Initialize the sram.\n");
            $readmemh(init_file, mem);
        end
    end

    initial begin
        for(addr=0;addr<(1<<16);addr=addr+1) begin
            tmp = mem[addr];
            mem0[addr] = tmp[7:0];
            mem1[addr] = tmp[15:8];
            mem2[addr] = tmp[23:16];
            mem3[addr] = tmp[31:24];
        end
    end

    wire sram_clk;
    wire sram_cen;
    wire sram_wen;
    wire [15:0] sram_addr;
    wire [31:0] sram_datai;
    wire [3:0]  sram_byte_en;
    reg  [31:0] sram_datao;

    assign sram_clk = clk_mem_fp;
    assign sram_cen = fp_ce_n;
    assign sram_wen = ~fp_wr;
    assign sram_addr = fp_addr;
    assign sram_datai = fp_w_data;
    assign sram_byte_en = fp_byte_en;

    always@(posedge sram_clk)
    begin
        if(!sram_cen)
        begin
            if(!sram_wen)
            begin
                if(sram_byte_en[0])
                    mem0[sram_addr] = sram_datai[7:0];

                if(sram_byte_en[1])
                    mem1[sram_addr] = sram_datai[15:8];

                if(sram_byte_en[2])
                    mem2[sram_addr] = sram_datai[23:16];

                if(sram_byte_en[3])
                    mem3[sram_addr] = sram_datai[31:24];

                sram_datao = sram_datai;
            end
            else
                sram_datao = {mem3[sram_addr],mem2[sram_addr],mem1[sram_addr],mem0[sram_addr]};
        end
    end
    assign fp_r_data = sram_datao;
    specify
    //timingcheck
$setuphold(posedge clk_mem_fp, rst_mem_fp_n, 0, 0);
$setuphold(posedge clk_mem_fp, fp_ce_n, 0, 0);
$setuphold(posedge clk_mem_fp, fp_wr, 0, 0);
$setuphold(posedge clk_mem_fp, fp_w_data[0], 0, 0);
$setuphold(posedge clk_mem_fp, fp_w_data[1], 0, 0);
$setuphold(posedge clk_mem_fp, fp_w_data[2], 0, 0);
$setuphold(posedge clk_mem_fp, fp_w_data[3], 0, 0);
$setuphold(posedge clk_mem_fp, fp_w_data[4], 0, 0);
$setuphold(posedge clk_mem_fp, fp_w_data[5], 0, 0);
$setuphold(posedge clk_mem_fp, fp_w_data[6], 0, 0);
$setuphold(posedge clk_mem_fp, fp_w_data[7], 0, 0);
$setuphold(posedge clk_mem_fp, fp_w_data[8], 0, 0);
$setuphold(posedge clk_mem_fp, fp_w_data[9], 0, 0);
$setuphold(posedge clk_mem_fp, fp_w_data[10], 0, 0);
$setuphold(posedge clk_mem_fp, fp_w_data[11], 0, 0);
$setuphold(posedge clk_mem_fp, fp_w_data[12], 0, 0);
$setuphold(posedge clk_mem_fp, fp_w_data[13], 0, 0);
$setuphold(posedge clk_mem_fp, fp_w_data[14], 0, 0);
$setuphold(posedge clk_mem_fp, fp_w_data[15], 0, 0);
$setuphold(posedge clk_mem_fp, fp_w_data[16], 0, 0);
$setuphold(posedge clk_mem_fp, fp_w_data[17], 0, 0);
$setuphold(posedge clk_mem_fp, fp_w_data[18], 0, 0);
$setuphold(posedge clk_mem_fp, fp_w_data[19], 0, 0);
$setuphold(posedge clk_mem_fp, fp_w_data[20], 0, 0);
$setuphold(posedge clk_mem_fp, fp_w_data[21], 0, 0);
$setuphold(posedge clk_mem_fp, fp_w_data[22], 0, 0);
$setuphold(posedge clk_mem_fp, fp_w_data[23], 0, 0);
$setuphold(posedge clk_mem_fp, fp_w_data[24], 0, 0);
$setuphold(posedge clk_mem_fp, fp_w_data[25], 0, 0);
$setuphold(posedge clk_mem_fp, fp_w_data[26], 0, 0);
$setuphold(posedge clk_mem_fp, fp_w_data[27], 0, 0);
$setuphold(posedge clk_mem_fp, fp_w_data[28], 0, 0);
$setuphold(posedge clk_mem_fp, fp_w_data[29], 0, 0);
$setuphold(posedge clk_mem_fp, fp_w_data[30], 0, 0);
$setuphold(posedge clk_mem_fp, fp_w_data[31], 0, 0);
$setuphold(posedge clk_mem_fp, fp_byte_en[0], 0, 0);
$setuphold(posedge clk_mem_fp, fp_byte_en[1], 0, 0);
$setuphold(posedge clk_mem_fp, fp_byte_en[2], 0, 0);
$setuphold(posedge clk_mem_fp, fp_byte_en[3], 0, 0);
$setuphold(posedge clk_mem_fp, fp_addr[0], 0, 0);
$setuphold(posedge clk_mem_fp, fp_addr[1], 0, 0);
$setuphold(posedge clk_mem_fp, fp_addr[2], 0, 0);
$setuphold(posedge clk_mem_fp, fp_addr[3], 0, 0);
$setuphold(posedge clk_mem_fp, fp_addr[4], 0, 0);
$setuphold(posedge clk_mem_fp, fp_addr[5], 0, 0);
$setuphold(posedge clk_mem_fp, fp_addr[6], 0, 0);
$setuphold(posedge clk_mem_fp, fp_addr[7], 0, 0);
$setuphold(posedge clk_mem_fp, fp_addr[8], 0, 0);
$setuphold(posedge clk_mem_fp, fp_addr[9], 0, 0);
$setuphold(posedge  clk_mem_fp,fp_addr[10], 0, 0);
$setuphold(posedge  clk_mem_fp,fp_addr[11], 0, 0);
$setuphold(posedge  clk_mem_fp,fp_addr[12], 0, 0);
$setuphold(posedge  clk_mem_fp,fp_addr[13], 0, 0);
$setuphold(posedge  clk_mem_fp,fp_addr[14], 0, 0);
$setuphold(posedge  clk_mem_fp,fp_addr[15], 0, 0);

//iopath
(clk_mem_fp=> fp_r_data[0] ) = (0,0);
(clk_mem_fp=> fp_r_data[1] ) = (0,0);
(clk_mem_fp=> fp_r_data[2] ) = (0,0);
(clk_mem_fp=> fp_r_data[3] ) = (0,0);
(clk_mem_fp=> fp_r_data[4] ) = (0,0);
(clk_mem_fp=> fp_r_data[5] ) = (0,0);
(clk_mem_fp=> fp_r_data[6] ) = (0,0);
(clk_mem_fp=> fp_r_data[7] ) = (0,0);
(clk_mem_fp=> fp_r_data[8] ) = (0,0);
(clk_mem_fp=> fp_r_data[9] ) = (0,0);
(clk_mem_fp => fp_r_data[10]) = (0,0);
(clk_mem_fp => fp_r_data[11]) = (0,0);
(clk_mem_fp => fp_r_data[12]) = (0,0);
(clk_mem_fp => fp_r_data[13]) = (0,0);
(clk_mem_fp => fp_r_data[14]) = (0,0);
(clk_mem_fp => fp_r_data[15]) = (0,0);
(clk_mem_fp => fp_r_data[16]) = (0,0);
(clk_mem_fp => fp_r_data[17]) = (0,0);
(clk_mem_fp => fp_r_data[18]) = (0,0);
(clk_mem_fp => fp_r_data[19]) = (0,0);
(clk_mem_fp => fp_r_data[20]) = (0,0);
(clk_mem_fp => fp_r_data[21]) = (0,0);
(clk_mem_fp => fp_r_data[22]) = (0,0);
(clk_mem_fp => fp_r_data[23]) = (0,0);
(clk_mem_fp => fp_r_data[24]) = (0,0);
(clk_mem_fp => fp_r_data[25]) = (0,0);
(clk_mem_fp => fp_r_data[26]) = (0,0);
(clk_mem_fp => fp_r_data[27]) = (0,0);
(clk_mem_fp => fp_r_data[28]) = (0,0);
(clk_mem_fp => fp_r_data[29]) = (0,0);
(clk_mem_fp => fp_r_data[30]) = (0,0);
(clk_mem_fp => fp_r_data[31]) = (0,0);
		endspecify
    
endmodule


module M7S_EMB18K (
    wfull,
    wfull_almost,
    rempty,
    rempty_almost,
    overflow,
    wr_ack,
    underflow,
    rd_ack,
    rd_ha,
    rd_la,
    c1r4_q,
    c1r3_q,
    c1r2_q,
    c1r1_q,
    c1r4_aa,
    c1r4_ab,
    c1r4_cea,
    c1r4_ceb,
    c1r4_clka,
    c1r4_clkb,
    c1r4_da,
    c1r4_db,
    c1r4_rstna,
    c1r4_rstnb,
    c1r4_wea,
    c1r4_web,
    c1r3_aa,
    c1r3_ab,
    c1r3_cea,
    c1r3_ceb,
    c1r3_clka,
    c1r3_clkb,
    c1r3_da,
    c1r3_db,
    c1r3_rstna,
    c1r3_rstnb,
    c1r3_wea,
    c1r3_web,
    c1r2_aa,
    c1r2_ab,
    c1r2_cea,
    c1r2_ceb,
    c1r2_clka,
    c1r2_clkb,
    c1r2_da,
    c1r2_db,
    c1r2_rstna,
    c1r2_rstnb,
    c1r2_wea,
    c1r2_web,
    c1r1_aa,
    c1r1_ab,
    c1r1_cea,
    c1r1_ceb,
    c1r1_clka,
    c1r1_clkb,
    c1r1_da,
    c1r1_db,
    c1r1_rstna,
    c1r1_rstnb,
    c1r1_wea,
    c1r1_web,
    cea,
    ceb,
    fifo_clr,
    wr_req_n,
    rd_req_n,
    haa,
    hab,
    wea,
    web 
);

output      wfull;
output      wfull_almost;
output      rempty;
output      rempty_almost;
output      overflow;
output      wr_ack;
output      underflow;
output      rd_ack;
output  [1:0]   rd_ha;
output  [5:0]   rd_la;
output  [17:0]  c1r4_q;
output  [17:0]  c1r3_q;
output  [17:0]  c1r2_q;
output  [17:0]  c1r1_q;
input   [11:0]  c1r4_aa;
input   [11:0]  c1r4_ab;
input       c1r4_cea;
input       c1r4_ceb;
input       c1r4_clka;
input       c1r4_clkb;
input   [17:0]  c1r4_da;
input   [17:0]  c1r4_db;
input       c1r4_rstna;
input       c1r4_rstnb;
input       c1r4_wea;
input       c1r4_web;
input   [11:0]  c1r3_aa;
input   [11:0]  c1r3_ab;
input       c1r3_cea;
input       c1r3_ceb;
input       c1r3_clka;
input       c1r3_clkb;
input   [17:0]  c1r3_da;
input   [17:0]  c1r3_db;
input       c1r3_rstna;
input       c1r3_rstnb;
input       c1r3_wea;
input       c1r3_web;
input   [11:0]  c1r2_aa;
input   [11:0]  c1r2_ab;
input       c1r2_cea;
input       c1r2_ceb;
input       c1r2_clka;
input       c1r2_clkb;
input   [17:0]  c1r2_da;
input   [17:0]  c1r2_db;
input       c1r2_rstna;
input       c1r2_rstnb;
input       c1r2_wea;
input       c1r2_web;
input   [11:0]  c1r1_aa;
input   [11:0]  c1r1_ab;
input       c1r1_cea;
input       c1r1_ceb;
input       c1r1_clka;
input       c1r1_clkb;
input   [17:0]  c1r1_da;
input   [17:0]  c1r1_db;
input       c1r1_rstna;
input       c1r1_rstnb;
input       c1r1_wea;
input       c1r1_web;
input       cea;
input       ceb;
input       fifo_clr;
input       wr_req_n;
input       rd_req_n;
input   [1:0]   haa;
input   [1:0]   hab;
input       wea;
input       web;

wire   [13:0]  fifo_rda;
wire       fifo_rdn;
wire   [13:0]  fifo_wra;
wire       fifo_wrn;

//parameter for emb18k
parameter width_ext_mode = 1'b0;
parameter depth_ext_mode = 1'b0;
parameter dedicated_cfg = 16'hffff;

//parameter for fifo_ctrl
parameter fifo_en   =  1'b0;
parameter async_en  =  1'b0;
parameter r_width   =  5'b0_0000;
parameter w_width   =  5'b0_0000;
parameter af_level  = 15'b0;
parameter ae_level  = 15'b0;

//parameter for 4 emb5k
parameter emb5k_1_modea_sel =  4'b0000;
parameter emb5k_1_modeb_sel =  4'b0000;
parameter emb5k_1_porta_wr_mode = 2'b00;
parameter emb5k_1_portb_wr_mode = 2'b00;
parameter emb5k_1_porta_reg_out = 1'b0;
parameter emb5k_1_portb_reg_out = 1'b0;
parameter emb5k_1_reset_value_a = 9'b0;
parameter emb5k_1_reset_value_b = 9'b0;
parameter emb5k_1_operation_mode = "simple_dual_port";//"true_dual_port","single_port","simple_dual_port"
parameter emb5k_1_porta_data_width  = 18;
parameter emb5k_1_portb_data_width  = 18;
parameter emb5k_1_init_file = " ";
parameter emb5k_1_porta_prog = 8'b0000_0000;
parameter emb5k_1_portb_prog = 8'b0000_0000;

parameter emb5k_2_modea_sel =  4'b0000;
parameter emb5k_2_modeb_sel =  4'b0000;
parameter emb5k_2_porta_wr_mode = 2'b00;
parameter emb5k_2_portb_wr_mode = 2'b00;
parameter emb5k_2_porta_reg_out = 1'b0;
parameter emb5k_2_portb_reg_out = 1'b0;
parameter emb5k_2_reset_value_a = 9'b0;
parameter emb5k_2_reset_value_b = 9'b0;
parameter emb5k_2_operation_mode = "simple_dual_port";//"true_dual_port","single_port","simple_dual_port"
parameter emb5k_2_porta_data_width  = 18;
parameter emb5k_2_portb_data_width  = 18;
parameter emb5k_2_init_file = " ";
parameter emb5k_2_porta_prog = 8'b0000_0000;
parameter emb5k_2_portb_prog = 8'b0000_0000;

parameter emb5k_3_modea_sel =  4'b0000;
parameter emb5k_3_modeb_sel =  4'b0000;
parameter emb5k_3_porta_wr_mode = 2'b00;
parameter emb5k_3_portb_wr_mode = 2'b00;
parameter emb5k_3_porta_reg_out = 1'b0;
parameter emb5k_3_portb_reg_out = 1'b0;
parameter emb5k_3_reset_value_a = 9'b0;
parameter emb5k_3_reset_value_b = 9'b0;
parameter emb5k_3_operation_mode = "simple_dual_port";//"true_dual_port","single_port","simple_dual_port"
parameter emb5k_3_porta_data_width  = 18;
parameter emb5k_3_portb_data_width  = 18;
parameter emb5k_3_init_file = " ";
parameter emb5k_3_porta_prog = 8'b0000_0000;
parameter emb5k_3_portb_prog = 8'b0000_0000;

parameter emb5k_4_modea_sel =  4'b0000;
parameter emb5k_4_modeb_sel =  4'b0000;
parameter emb5k_4_porta_wr_mode = 2'b00;
parameter emb5k_4_portb_wr_mode = 2'b00;
parameter emb5k_4_porta_reg_out = 1'b0;
parameter emb5k_4_portb_reg_out = 1'b0;
parameter emb5k_4_reset_value_a = 9'b0;
parameter emb5k_4_reset_value_b = 9'b0;
parameter emb5k_4_operation_mode = "simple_dual_port";//"true_dual_port","single_port","simple_dual_port"
parameter emb5k_4_porta_data_width  = 18;
parameter emb5k_4_portb_data_width  = 18;
parameter emb5k_4_init_file = " ";
parameter emb5k_4_porta_prog = 8'b0000_0000;
parameter emb5k_4_portb_prog = 8'b0000_0000;

//special handling for manual placement
parameter    emb5k_1_inst             = "NONE";
parameter    emb5k_2_inst             = "NONE";
parameter    emb5k_3_inst             = "NONE";
parameter    emb5k_4_inst             = "NONE";

//internal wires and regs
//emb5k_1
wire emb5k_1_clka;
wire emb5k_1_rstna;
wire emb5k_1_cea_mem;
wire emb5k_1_cea_fifo;
wire emb5k_1_cea;
wire emb5k_1_wea_mem;
wire emb5k_1_wea_fifo;
wire emb5k_1_wea;
wire [11:0] emb5k_1_aa;
wire [17:0] emb5k_1_da;

wire emb5k_1_clkb;
wire emb5k_1_rstnb;
wire emb5k_1_ceb_mem;
wire emb5k_1_ceb_fifo;
wire emb5k_1_ceb;
wire emb5k_1_web_mem;
wire emb5k_1_web_fifo;
wire emb5k_1_web;
wire [11:0] emb5k_1_ab;
wire [17:0] emb5k_1_db;
wire [17:0] emb5k_1_q;

//emb5k_2
wire emb5k_2_clka;
wire emb5k_2_rstna;
wire emb5k_2_cea_mem;
wire emb5k_2_cea_fifo;
wire emb5k_2_cea;
wire emb5k_2_wea_mem;
wire emb5k_2_wea_fifo;
wire emb5k_2_wea;
wire [11:0] emb5k_2_aa;
wire [17:0] emb5k_2_da;

wire emb5k_2_clkb;
wire emb5k_2_rstnb;
wire emb5k_2_ceb_mem;
wire emb5k_2_ceb_fifo;
wire emb5k_2_ceb;
wire emb5k_2_web_mem;
wire emb5k_2_web_fifo;
wire emb5k_2_web;
wire [11:0] emb5k_2_ab;
wire [17:0] emb5k_2_db;
wire [17:0] emb5k_2_q;

//emb5k_3
wire emb5k_3_clka;
wire emb5k_3_rstna;
wire emb5k_3_cea;
wire emb5k_3_cea_mem;
wire emb5k_3_cea_fifo;
wire emb5k_3_wea;
wire emb5k_3_wea_mem;
wire emb5k_3_wea_fifo;
wire [11:0] emb5k_3_aa;
wire [17:0] emb5k_3_da;

wire emb5k_3_clkb;
wire emb5k_3_rstnb;
wire emb5k_3_ceb_mem;
wire emb5k_3_ceb_fifo;
wire emb5k_3_ceb;
wire emb5k_3_web_mem;
wire emb5k_3_web_fifo;
wire emb5k_3_web;
wire [11:0] emb5k_3_ab;
wire [17:0] emb5k_3_db;
wire [17:0] emb5k_3_q;

//emb5k_4
wire emb5k_4_clka;
wire emb5k_4_rstna;
wire emb5k_4_cea_mem;
wire emb5k_4_cea_fifo;
wire emb5k_4_cea;
wire emb5k_4_wea;
wire emb5k_4_wea_mem;
wire emb5k_4_wea_fifo;
wire [11:0] emb5k_4_aa;
wire [17:0] emb5k_4_da;

wire emb5k_4_clkb;
wire emb5k_4_rstnb;
wire emb5k_4_ceb_mem;
wire emb5k_4_ceb_fifo;
wire emb5k_4_ceb;
wire emb5k_4_web_mem;
wire emb5k_4_web_fifo;
wire emb5k_4_web;
wire [11:0] emb5k_4_ab;
wire [17:0] emb5k_4_db;
wire [17:0] emb5k_4_q;

//========================================
//cfg_bit           mode_sel
//========================================
//0000            256 x 18
//1000            512 x 9
//1100             1k x 4
//1110             2k x 2
//1111             4k x 1
//========================================

wire [13:0] fifo_rda_tmp;
wire [13:0] fifo_wra_tmp;

assign fifo_rda_tmp = (width_ext_mode == 1) ? {1'b0,fifo_rda[13:1]} : fifo_rda;
assign fifo_wra_tmp = (width_ext_mode == 1) ? {1'b0,fifo_wra[13:1]} : fifo_wra;

//internal logic
//---------------------------------------------------------------------------------------------------------------------------------------------
// emb5k_1
//---------------------------------------------------------------------------------------------------------------------------------------------
assign emb5k_1_clka     = c1r1_clka;
assign emb5k_1_rstna    = c1r1_rstna;
assign emb5k_1_cea_mem  = (depth_ext_mode == 0 && width_ext_mode == 0) ? c1r1_cea :
                          (depth_ext_mode == 0 && width_ext_mode == 1) ? cea & (haa[0] == 1'b0) :
                          (depth_ext_mode == 1 && width_ext_mode == 0) ? cea & (haa[1:0] == 2'b00) :
                          1'bx; //depth_ext_mode and width_ext_mode can not both be 1
assign emb5k_1_cea_fifo = (depth_ext_mode == 0 && width_ext_mode == 0) ? 1'b0:
                          (depth_ext_mode == 0 && width_ext_mode == 1) ? ~fifo_rdn& (fifo_rda_tmp[12] == 1'b0) :
                          (depth_ext_mode == 1 && width_ext_mode == 0) ? ~fifo_rdn& (fifo_rda_tmp[13:12] == 2'b00) :
                          1'bx; //depth_ext_mode and width_ext_mode can not both be 1
assign emb5k_1_wea_mem  = (depth_ext_mode == 0 && width_ext_mode == 0) ? c1r1_wea : wea;
assign emb5k_1_wea_fifo = 1'b0;
assign emb5k_1_cea      = (fifo_en == 1'b1) ? emb5k_1_cea_fifo : emb5k_1_cea_mem;
assign emb5k_1_wea      = (fifo_en == 1'b1) ? emb5k_1_wea_fifo : emb5k_1_wea_mem;
assign emb5k_1_aa       = (fifo_en == 1'b1) ? fifo_rda_tmp[11:0] : c1r1_aa[11:0]; //when depth-extend and width mode, aa and ab all use emb5k_1's
assign emb5k_1_da       = c1r1_da[17:0];

//---------------------------------------------------------------------------------------------------------------------------------------------
assign emb5k_1_clkb     = c1r1_clkb;
assign emb5k_1_rstnb    = c1r1_rstnb;
assign emb5k_1_ceb_mem  = (depth_ext_mode == 0 && width_ext_mode == 0) ? c1r1_ceb :
                          (depth_ext_mode == 0 && width_ext_mode == 1) ? ceb & (hab[0] == 1'b0) :
                          (depth_ext_mode == 1 && width_ext_mode == 0) ? ceb & (hab[1:0] == 2'b00) :
                          1'bx; //depth_ext_mode and width_ext_mode can not both be 1
assign emb5k_1_ceb_fifo = (depth_ext_mode == 0 && width_ext_mode == 0) ? 1'b0 :
                          (depth_ext_mode == 0 && width_ext_mode == 1) ? ~fifo_wrn & (fifo_wra_tmp[12] == 1'b0) :
                          (depth_ext_mode == 1 && width_ext_mode == 0) ? ~fifo_wrn & (fifo_wra_tmp[13:12] == 2'b00) :
                          1'bx; //depth_ext_mode and width_ext_mode can not both be 1
assign emb5k_1_web_mem  = (depth_ext_mode == 0 && width_ext_mode == 0) ? c1r1_web : web;
assign emb5k_1_web_fifo = ~fifo_wrn;
assign emb5k_1_ceb      = (fifo_en == 1'b1) ? emb5k_1_ceb_fifo : emb5k_1_ceb_mem;
assign emb5k_1_web      = (fifo_en == 1'b1) ? emb5k_1_web_fifo : emb5k_1_web_mem;
assign emb5k_1_ab       = (fifo_en == 1'b1) ? fifo_wra_tmp[11:0] : c1r1_ab[11:0];
assign emb5k_1_db       = c1r1_db;

assign c1r1_q   = emb5k_1_q;

//---------------------------------------------------------------------------------------------------------------------------------------------
// emb5k_2
//---------------------------------------------------------------------------------------------------------------------------------------------
assign emb5k_2_clka     = c1r2_clka;
assign emb5k_2_rstna    = c1r2_rstna;
assign emb5k_2_cea_mem  = (depth_ext_mode == 0 && width_ext_mode == 0) ? c1r2_cea :
                          (depth_ext_mode == 0 && width_ext_mode == 1) ? cea & (haa[0] == 1'b0) :
                          (depth_ext_mode == 1 && width_ext_mode == 0) ? cea & (haa[1:0] == 2'b01) :
                          1'bx; //depth_ext_mode and width_ext_mode can not both be 1
assign emb5k_2_cea_fifo = (depth_ext_mode == 0 && width_ext_mode == 0) ? 1'b0:
                          (depth_ext_mode == 0 && width_ext_mode == 1) ? ~fifo_rdn& (fifo_rda_tmp[12] == 1'b0) :
                          (depth_ext_mode == 1 && width_ext_mode == 0) ? ~fifo_rdn& (fifo_rda_tmp[13:12] == 2'b01) :
                          1'bx; //depth_ext_mode and width_ext_mode can not both be 1
assign emb5k_2_wea_mem  = (depth_ext_mode == 0 && width_ext_mode == 0) ? c1r2_wea : wea;
assign emb5k_2_wea_fifo = 1'b0;
assign emb5k_2_cea      = (fifo_en == 1'b1) ? emb5k_2_cea_fifo : emb5k_2_cea_mem;
assign emb5k_2_wea      = (fifo_en == 1'b1) ? emb5k_2_wea_fifo : emb5k_2_wea_mem;
assign emb5k_2_aa       = (fifo_en == 1'b1) ? fifo_rda_tmp[11:0] : 
                          (depth_ext_mode == 0 && width_ext_mode == 0) ? c1r2_aa[11:0] : c1r1_aa[11:0];
assign emb5k_2_da       = c1r2_da[17:0];
//---------------------------------------------------------------------------------------------------------------------------------------------
assign emb5k_2_clkb     = c1r2_clkb;
assign emb5k_2_rstnb    = c1r2_rstnb;

assign emb5k_2_ceb_mem  = (depth_ext_mode == 0 && width_ext_mode == 0) ? c1r2_ceb :
                          (depth_ext_mode == 0 && width_ext_mode == 1) ? ceb & (hab[0] == 1'b0) :
                          (depth_ext_mode == 1 && width_ext_mode == 0) ? ceb & (hab[1:0] == 2'b01) :
                          1'bx; //depth_ext_mode and width_ext_mode can not both be 1
assign emb5k_2_ceb_fifo = (depth_ext_mode == 0 && width_ext_mode == 0) ? 1'b0 :
                          (depth_ext_mode == 0 && width_ext_mode == 1) ? ~fifo_wrn & (fifo_wra_tmp[12] == 1'b0) :
                          (depth_ext_mode == 1 && width_ext_mode == 0) ? ~fifo_wrn & (fifo_wra_tmp[13:12] == 2'b01) :
                          1'bx; //depth_ext_mode and width_ext_mode can not both be 1
assign emb5k_2_web_mem  = (depth_ext_mode == 0 && width_ext_mode == 0) ? c1r2_web : web;
assign emb5k_2_web_fifo = ~fifo_wrn;
assign emb5k_2_ceb      = (fifo_en == 1'b1) ? emb5k_2_ceb_fifo : emb5k_2_ceb_mem;
assign emb5k_2_web      = (fifo_en == 1'b1) ? emb5k_2_web_fifo : emb5k_2_web_mem;
assign emb5k_2_ab       = (fifo_en == 1'b1) ? fifo_wra_tmp[11:0] : 
                          (depth_ext_mode == 0 && width_ext_mode == 0) ? c1r2_ab[11:0] : c1r1_ab[11:0];
assign emb5k_2_db       = c1r2_db;
assign c1r2_q   = emb5k_2_q;

//---------------------------------------------------------------------------------------------------------------------------------------------
// emb5k_3
//---------------------------------------------------------------------------------------------------------------------------------------------
assign emb5k_3_clka     = c1r3_clka;
assign emb5k_3_rstna    = c1r3_rstna;
assign emb5k_3_cea_mem  = (depth_ext_mode == 0 && width_ext_mode == 0) ? c1r3_cea :
                          (depth_ext_mode == 0 && width_ext_mode == 1) ? cea & (haa[0] == 1'b1) :
                          (depth_ext_mode == 1 && width_ext_mode == 0) ? cea & (haa[1:0] == 2'b10) :
                          1'bx; //depth_ext_mode and width_ext_mode can not both be 1
assign emb5k_3_cea_fifo = (depth_ext_mode == 0 && width_ext_mode == 0) ? 1'b0:
                          (depth_ext_mode == 0 && width_ext_mode == 1) ? ~fifo_rdn& (fifo_rda_tmp[12] == 1'b1) :
                          (depth_ext_mode == 1 && width_ext_mode == 0) ? ~fifo_rdn& (fifo_rda_tmp[13:12] == 2'b10) :
                          1'bx; //depth_ext_mode and width_ext_mode can not both be 1
assign emb5k_3_wea_mem  = (depth_ext_mode == 0 && width_ext_mode == 0) ? c1r3_wea : wea;
assign emb5k_3_wea_fifo = 1'b0;
assign emb5k_3_cea      = (fifo_en == 1'b1) ? emb5k_3_cea_fifo : emb5k_3_cea_mem;
assign emb5k_3_wea      = (fifo_en == 1'b1) ? emb5k_3_wea_fifo : emb5k_3_wea_mem;
assign emb5k_3_aa       = (fifo_en == 1'b1) ? fifo_rda_tmp[11:0] : 
                          (depth_ext_mode == 0 && width_ext_mode == 0) ? c1r3_aa[11:0] : c1r1_aa[11:0];
assign emb5k_3_da       = c1r3_da[17:0];
//---------------------------------------------------------------------------------------------------------------------------------------------
assign emb5k_3_clkb     = c1r3_clkb;
assign emb5k_3_rstnb    = c1r3_rstnb;

assign emb5k_3_ceb_mem  = (depth_ext_mode == 0 && width_ext_mode == 0) ? c1r3_ceb :
                          (depth_ext_mode == 0 && width_ext_mode == 1) ? ceb & (hab[0] == 1'b1) :
                          (depth_ext_mode == 1 && width_ext_mode == 0) ? ceb & (hab[1:0] == 2'b10) :
                          1'bx; //depth_ext_mode and width_ext_mode can not both be 1
assign emb5k_3_ceb_fifo = (depth_ext_mode == 0 && width_ext_mode == 0) ? 1'b0 :
                          (depth_ext_mode == 0 && width_ext_mode == 1) ? ~fifo_wrn & (fifo_wra_tmp[12] == 1'b1) :
                          (depth_ext_mode == 1 && width_ext_mode == 0) ? ~fifo_wrn & (fifo_wra_tmp[13:12] == 2'b10) :
                          1'bx; //depth_ext_mode and width_ext_mode can not both be 1
assign emb5k_3_web_mem  = (depth_ext_mode == 0 && width_ext_mode == 0) ? c1r3_web : web;
assign emb5k_3_web_fifo = ~fifo_wrn;
assign emb5k_3_ceb      = (fifo_en == 1'b1) ? emb5k_3_ceb_fifo : emb5k_3_ceb_mem;
assign emb5k_3_web      = (fifo_en == 1'b1) ? emb5k_3_web_fifo : emb5k_3_web_mem;
assign emb5k_3_ab       = (fifo_en == 1'b1) ? fifo_wra_tmp[11:0] : 
                          (depth_ext_mode == 0 && width_ext_mode == 0) ? c1r3_ab[11:0] : c1r1_ab[11:0];
assign emb5k_3_db       = c1r3_db;
assign c1r3_q   = emb5k_3_q;

//---------------------------------------------------------------------------------------------------------------------------------------------
// emb5k_4
//---------------------------------------------------------------------------------------------------------------------------------------------
assign emb5k_4_clka     = c1r4_clka;
assign emb5k_4_rstna    = c1r4_rstna;
assign emb5k_4_cea_mem  = (depth_ext_mode == 0 && width_ext_mode == 0) ? c1r4_cea :
                          (depth_ext_mode == 0 && width_ext_mode == 1) ? cea & (haa[0] == 1'b1) :
                          (depth_ext_mode == 1 && width_ext_mode == 0) ? cea & (haa[1:0] == 2'b11) :
                          1'bx; //depth_ext_mode and width_ext_mode can not both be 1
assign emb5k_4_cea_fifo = (depth_ext_mode == 0 && width_ext_mode == 0) ? 1'b0:
                          (depth_ext_mode == 0 && width_ext_mode == 1) ? ~fifo_rdn& (fifo_rda_tmp[12] == 1'b1) :
                          (depth_ext_mode == 1 && width_ext_mode == 0) ? ~fifo_rdn& (fifo_rda_tmp[13:12] == 2'b11) :
                          1'bx; //depth_ext_mode and width_ext_mode can not both be 1
assign emb5k_4_wea_mem  = (depth_ext_mode == 0 && width_ext_mode == 0) ? c1r4_wea : wea;
assign emb5k_4_wea_fifo = 1'b0;
assign emb5k_4_cea      = (fifo_en == 1'b1) ? emb5k_4_cea_fifo : emb5k_4_cea_mem;
assign emb5k_4_wea      = (fifo_en == 1'b1) ? emb5k_4_wea_fifo : emb5k_4_wea_mem;
assign emb5k_4_aa       = (fifo_en == 1'b1) ? fifo_rda_tmp[11:0] : 
                          (depth_ext_mode == 0 && width_ext_mode == 0) ? c1r4_aa[11:0] : c1r1_aa[11:0];
assign emb5k_4_da       = c1r4_da[17:0];
//---------------------------------------------------------------------------------------------------------------------------------------------
assign emb5k_4_clkb     = c1r4_clkb;
assign emb5k_4_rstnb    = c1r4_rstnb;
assign emb5k_4_ceb_mem  = (depth_ext_mode == 0 && width_ext_mode == 0) ? c1r4_ceb :
                          (depth_ext_mode == 0 && width_ext_mode == 1) ? ceb & (hab[0] == 1'b1) :
                          (depth_ext_mode == 1 && width_ext_mode == 0) ? ceb & (hab[1:0] == 2'b11) :
                          1'bx; //depth_ext_mode and width_ext_mode can not both be 1
assign emb5k_4_ceb_fifo = (depth_ext_mode == 0 && width_ext_mode == 0) ? 1'b0 :
                          (depth_ext_mode == 0 && width_ext_mode == 1) ? ~fifo_wrn & (fifo_wra_tmp[12] == 1'b1) :
                          (depth_ext_mode == 1 && width_ext_mode == 0) ? ~fifo_wrn & (fifo_wra_tmp[13:12] == 2'b11) :
                          1'bx; //depth_ext_mode and width_ext_mode can not both be 1
assign emb5k_4_web_mem  = (depth_ext_mode == 0 && width_ext_mode == 0) ? c1r4_web : web;
assign emb5k_4_web_fifo = ~fifo_wrn;
assign emb5k_4_ceb      = (fifo_en == 1'b1) ? emb5k_4_ceb_fifo : emb5k_4_ceb_mem;
assign emb5k_4_web      = (fifo_en == 1'b1) ? emb5k_4_web_fifo : emb5k_4_web_mem;
assign emb5k_4_ab       = (fifo_en == 1'b1) ? fifo_wra_tmp[11:0] : 
                          (depth_ext_mode == 0 && width_ext_mode == 0) ? c1r4_ab[11:0] : c1r1_ab[11:0];
assign emb5k_4_db       = c1r4_db;
assign c1r4_q   = emb5k_4_q;

assign rd_ha[1:0] = fifo_rda_tmp[13:12];//MSB 2 bits of fifo read-address
assign rd_la[5:0] = fifo_rda_tmp[5:0]; //LSB 6 bits of fifo read-address

//instances, M7A_EMB18K is consist of 1 M7A_FIFO_CTRL and 4 M7A_EMB5K.
M7A_FIFO_CTRL fifo_ctrl(
    .clka           (c1r1_clka      ),
    .clkb           (c1r1_clkb      ),
    .rstna          (c1r1_rstna     ),
    .rstnb          (c1r1_rstnb     ),
    .fifo_clr       (fifo_clr       ),
    .wr_req_n       (wr_req_n       ),
    .rd_req_n       (rd_req_n       ),
    .wfull          (wfull          ),
    .wfull_almost   (wfull_almost   ),
    .rempty         (rempty         ),
    .rempty_almost  (rempty_almost  ),
    .overflow       (overflow       ),
    .wr_ack         (wr_ack         ),
    .underflow      (underflow      ),
    .rd_ack         (rd_ack         ),
    .fifo_rda       (fifo_rda       ),
    .fifo_rdn       (fifo_rdn       ),
    .fifo_wra       (fifo_wra       ),
    .fifo_wrn       (fifo_wrn       )
);
defparam fifo_ctrl.r_width   = r_width;
defparam fifo_ctrl.w_width   = w_width;
defparam fifo_ctrl.af_level  = af_level;
defparam fifo_ctrl.ae_level  = ae_level;
defparam fifo_ctrl.fifo_en   = fifo_en;
defparam fifo_ctrl.async_en  = async_en;

M7S_EMB5K emb5k_1 (
    .clka   (emb5k_1_clka),
    .clkb   (emb5k_1_clkb),
    .rstna  (emb5k_1_rstna),
    .rstnb  (emb5k_1_rstnb),
    .cea    (emb5k_1_cea),
    .ceb    (emb5k_1_ceb),
    .wea    (emb5k_1_wea),
    .web    (emb5k_1_web),
    .aa (emb5k_1_aa[11:0]),
    .ab (emb5k_1_ab[11:0]),
    .da (emb5k_1_da[17:0]),
    .db (emb5k_1_db[17:0]),

    .q  (emb5k_1_q[17:0]) 
);
defparam emb5k_1.modea_sel          = emb5k_1_modea_sel;
defparam emb5k_1.modeb_sel          = emb5k_1_modeb_sel;
defparam emb5k_1.porta_wr_mode      = emb5k_1_porta_wr_mode;
defparam emb5k_1.portb_wr_mode      = emb5k_1_portb_wr_mode;
defparam emb5k_1.porta_reg_out      = emb5k_1_porta_reg_out;
defparam emb5k_1.portb_reg_out      = emb5k_1_portb_reg_out;
defparam emb5k_1.reset_value_a      = emb5k_1_reset_value_a;
defparam emb5k_1.reset_value_b      = emb5k_1_reset_value_b;
defparam emb5k_1.operation_mode     = emb5k_1_operation_mode;
defparam emb5k_1.porta_data_width   = emb5k_1_porta_data_width;
defparam emb5k_1.portb_data_width   = emb5k_1_portb_data_width;
defparam emb5k_1.init_file          = emb5k_1_init_file;
defparam emb5k_1.porta_prog         = emb5k_1_porta_prog;
defparam emb5k_1.portb_prog         = emb5k_1_portb_prog;

M7S_EMB5K emb5k_2 (
    .clka   (emb5k_2_clka),
    .clkb   (emb5k_2_clkb),
    .rstna  (emb5k_2_rstna),
    .rstnb  (emb5k_2_rstnb),
    .cea    (emb5k_2_cea),
    .ceb    (emb5k_2_ceb),
    .wea    (emb5k_2_wea),
    .web    (emb5k_2_web),
    .aa (emb5k_2_aa[11:0]),
    .ab (emb5k_2_ab[11:0]),
    .da (emb5k_2_da[17:0]),
    .db (emb5k_2_db[17:0]),

    .q  (emb5k_2_q[17:0]) 
);
defparam emb5k_2.modea_sel          = emb5k_2_modea_sel;
defparam emb5k_2.modeb_sel          = emb5k_2_modeb_sel;
defparam emb5k_2.porta_wr_mode      = emb5k_2_porta_wr_mode;
defparam emb5k_2.portb_wr_mode      = emb5k_2_portb_wr_mode;
defparam emb5k_2.porta_reg_out      = emb5k_2_porta_reg_out;
defparam emb5k_2.portb_reg_out      = emb5k_2_portb_reg_out;
defparam emb5k_2.reset_value_a      = emb5k_2_reset_value_a;
defparam emb5k_2.reset_value_b      = emb5k_2_reset_value_b;
defparam emb5k_2.operation_mode     = emb5k_2_operation_mode;
defparam emb5k_2.porta_data_width   = emb5k_2_porta_data_width;
defparam emb5k_2.portb_data_width   = emb5k_2_portb_data_width;
defparam emb5k_2.init_file          = emb5k_2_init_file;
defparam emb5k_2.porta_prog         = emb5k_2_porta_prog;
defparam emb5k_2.portb_prog         = emb5k_2_portb_prog;

M7S_EMB5K emb5k_3 (
    .clka   (emb5k_3_clka),
    .clkb   (emb5k_3_clkb),
    .rstna  (emb5k_3_rstna),
    .rstnb  (emb5k_3_rstnb),
    .cea    (emb5k_3_cea),
    .ceb    (emb5k_3_ceb),
    .wea    (emb5k_3_wea),
    .web    (emb5k_3_web),
    .aa (emb5k_3_aa[11:0]),
    .ab (emb5k_3_ab[11:0]),
    .da (emb5k_3_da[17:0]),
    .db (emb5k_3_db[17:0]),

    .q  (emb5k_3_q[17:0]) 
);
defparam emb5k_3.modea_sel          = emb5k_3_modea_sel;
defparam emb5k_3.modeb_sel          = emb5k_3_modeb_sel;
defparam emb5k_3.porta_wr_mode      = emb5k_3_porta_wr_mode;
defparam emb5k_3.portb_wr_mode      = emb5k_3_portb_wr_mode;
defparam emb5k_3.porta_reg_out      = emb5k_3_porta_reg_out;
defparam emb5k_3.portb_reg_out      = emb5k_3_portb_reg_out;
defparam emb5k_3.reset_value_a      = emb5k_3_reset_value_a;
defparam emb5k_3.reset_value_b      = emb5k_3_reset_value_b;
defparam emb5k_3.operation_mode     = emb5k_3_operation_mode;
defparam emb5k_3.porta_data_width   = emb5k_3_porta_data_width;
defparam emb5k_3.portb_data_width   = emb5k_3_portb_data_width;
defparam emb5k_3.init_file          = emb5k_3_init_file;
defparam emb5k_3.porta_prog         = emb5k_3_porta_prog;
defparam emb5k_3.portb_prog         = emb5k_3_portb_prog;

M7S_EMB5K emb5k_4 (
    .clka   (emb5k_4_clka),
    .clkb   (emb5k_4_clkb),
    .rstna  (emb5k_4_rstna),
    .rstnb  (emb5k_4_rstnb),
    .cea    (emb5k_4_cea),
    .ceb    (emb5k_4_ceb),
    .wea    (emb5k_4_wea),
    .web    (emb5k_4_web),
    .aa (emb5k_4_aa[11:0]),
    .ab (emb5k_4_ab[11:0]),
    .da (emb5k_4_da[17:0]),
    .db (emb5k_4_db[17:0]),

    .q  (emb5k_4_q[17:0]) 
);
defparam emb5k_4.modea_sel          = emb5k_4_modea_sel;
defparam emb5k_4.modeb_sel          = emb5k_4_modeb_sel;
defparam emb5k_4.porta_wr_mode      = emb5k_4_porta_wr_mode;
defparam emb5k_4.portb_wr_mode      = emb5k_4_portb_wr_mode;
defparam emb5k_4.porta_reg_out      = emb5k_4_porta_reg_out;
defparam emb5k_4.portb_reg_out      = emb5k_4_portb_reg_out;
defparam emb5k_4.reset_value_a      = emb5k_4_reset_value_a;
defparam emb5k_4.reset_value_b      = emb5k_4_reset_value_b;
defparam emb5k_4.operation_mode     = emb5k_4_operation_mode;
defparam emb5k_4.porta_data_width   = emb5k_4_porta_data_width;
defparam emb5k_4.portb_data_width   = emb5k_4_portb_data_width;
defparam emb5k_4.init_file          = emb5k_4_init_file;
defparam emb5k_4.porta_prog         = emb5k_4_porta_prog;
defparam emb5k_4.portb_prog         = emb5k_4_portb_prog;
specify
( c1r1_clka => wfull            ) = (0,0) ; 
(	c1r1_clka => rempty           ) = (0,0) ;
(	c1r1_clka => overflow         ) = (0,0) ;
(	c1r1_clka => underflow        ) = (0,0) ;
(	c1r1_clka => wr_ack           ) = (0,0) ;
(	c1r1_clka => rd_ack           ) = (0,0) ;
(	c1r1_clka => c1r1_q[17]  ) = (0,0) ;  
( c1r1_clka => c1r1_q[16]  ) = (0,0) ;  
( c1r1_clka => c1r1_q[15]  ) = (0,0) ;  
( c1r1_clka => c1r1_q[14]  ) = (0,0) ;  
( c1r1_clka => c1r1_q[13]  ) = (0,0) ;  
( c1r1_clka => c1r1_q[12]  ) = (0,0) ;  
( c1r1_clka => c1r1_q[11]  ) = (0,0) ;  
( c1r1_clka => c1r1_q[10]  ) = (0,0) ;  
( c1r1_clka => c1r1_q[9]   ) = (0,0) ;  
( c1r1_clka => c1r1_q[8]   ) = (0,0) ;  
( c1r1_clka => c1r1_q[7]   ) = (0,0) ;  
( c1r1_clka => c1r1_q[6]   ) = (0,0) ;  
( c1r1_clka => c1r1_q[5]   ) = (0,0) ;  
( c1r1_clka => c1r1_q[4]   ) = (0,0) ;  
( c1r1_clka => c1r1_q[3]   ) = (0,0) ;  
( c1r1_clka => c1r1_q[2]   ) = (0,0) ;  
( c1r1_clka => c1r1_q[1]   ) = (0,0) ;  
( c1r1_clka => c1r1_q[0]   ) = (0,0) ;  
( c1r4_clka => c1r4_q[17]  ) = (0,0) ;  
( c1r4_clka => c1r4_q[16]  ) = (0,0) ;  
( c1r4_clka => c1r4_q[15]  ) = (0,0) ;  
( c1r4_clka => c1r4_q[14]  ) = (0,0) ;  
( c1r4_clka => c1r4_q[13]  ) = (0,0) ;  
( c1r4_clka => c1r4_q[12]  ) = (0,0) ;  
( c1r4_clka => c1r4_q[11]  ) = (0,0) ;  
( c1r4_clka => c1r4_q[10]  ) = (0,0) ;  
( c1r4_clka => c1r4_q[9]   ) = (0,0) ;  
( c1r4_clka => c1r4_q[8]   ) = (0,0) ;  
( c1r4_clka => c1r4_q[7]   ) = (0,0) ;  
( c1r4_clka => c1r4_q[6]   ) = (0,0) ;  
( c1r4_clka => c1r4_q[5]   ) = (0,0) ;  
( c1r4_clka => c1r4_q[4]   ) = (0,0) ;  
( c1r4_clka => c1r4_q[3]   ) = (0,0) ;  
( c1r4_clka => c1r4_q[2]   ) = (0,0) ;  
( c1r4_clka => c1r4_q[1]   ) = (0,0) ;  
( c1r4_clka => c1r4_q[0]   ) = (0,0) ;  
( c1r2_clka => c1r2_q[17]  ) = (0,0) ;  
( c1r2_clka => c1r2_q[16]  ) = (0,0) ;  
( c1r2_clka => c1r2_q[15]  ) = (0,0) ;  
( c1r2_clka => c1r2_q[14]  ) = (0,0) ;  
( c1r2_clka => c1r2_q[13]  ) = (0,0) ;  
( c1r2_clka => c1r2_q[12]  ) = (0,0) ;  
( c1r2_clka => c1r2_q[11]  ) = (0,0) ;  
( c1r2_clka => c1r2_q[10]  ) = (0,0) ;  
( c1r2_clka => c1r2_q[9]   ) = (0,0) ;  
( c1r2_clka => c1r2_q[8]   ) = (0,0) ;  
( c1r2_clka => c1r2_q[7]   ) = (0,0) ;  
( c1r2_clka => c1r2_q[6]   ) = (0,0) ;  
( c1r2_clka => c1r2_q[5]   ) = (0,0) ;  
( c1r2_clka => c1r2_q[4]   ) = (0,0) ;  
( c1r2_clka => c1r2_q[3]   ) = (0,0) ;  
( c1r2_clka => c1r2_q[2]   ) = (0,0) ;  
( c1r2_clka => c1r2_q[1]   ) = (0,0) ;  
( c1r2_clka => c1r2_q[0]   ) = (0,0) ;  
( c1r3_clka => c1r3_q[17]  ) = (0,0) ;  
( c1r3_clka => c1r3_q[16]  ) = (0,0) ;  
( c1r3_clka => c1r3_q[15]  ) = (0,0) ;  
( c1r3_clka => c1r3_q[14]  ) = (0,0) ;  
( c1r3_clka => c1r3_q[13]  ) = (0,0) ;  
( c1r3_clka => c1r3_q[12]  ) = (0,0) ;  
( c1r3_clka => c1r3_q[11]  ) = (0,0) ;  
( c1r3_clka => c1r3_q[10]  ) = (0,0) ;  
( c1r3_clka => c1r3_q[9]   ) = (0,0) ;  
( c1r3_clka => c1r3_q[8]   ) = (0,0) ;  
( c1r3_clka => c1r3_q[7]   ) = (0,0) ;  
( c1r3_clka => c1r3_q[6]   ) = (0,0) ;  
( c1r3_clka => c1r3_q[5]   ) = (0,0) ;  
( c1r3_clka => c1r3_q[4]   ) = (0,0) ;  
( c1r3_clka => c1r3_q[3]   ) = (0,0) ;  
( c1r3_clka => c1r3_q[2]   ) = (0,0) ;  
( c1r3_clka => c1r3_q[1]   ) = (0,0) ;  
( c1r3_clka => c1r3_q[0]   ) = (0,0) ;  
( c1r1_clkb => c1r1_q[17]  ) = (0,0) ;  
( c1r1_clkb => c1r1_q[16]  ) = (0,0) ;  
( c1r1_clkb => c1r1_q[15]  ) = (0,0) ;  
( c1r1_clkb => c1r1_q[14]  ) = (0,0) ;  
( c1r1_clkb => c1r1_q[13]  ) = (0,0) ;  
( c1r1_clkb => c1r1_q[12]  ) = (0,0) ;  
( c1r1_clkb => c1r1_q[11]  ) = (0,0) ;  
( c1r1_clkb => c1r1_q[10]  ) = (0,0) ;  
( c1r1_clkb => c1r1_q[9]   ) = (0,0) ;  
( c1r4_clkb => c1r4_q[17]  ) = (0,0) ;  
( c1r4_clkb => c1r4_q[16]  ) = (0,0) ;  
( c1r4_clkb => c1r4_q[15]  ) = (0,0) ;  
( c1r4_clkb => c1r4_q[14]  ) = (0,0) ;  
( c1r4_clkb => c1r4_q[13]  ) = (0,0) ;  
( c1r4_clkb => c1r4_q[12]  ) = (0,0) ;  
( c1r4_clkb => c1r4_q[11]  ) = (0,0) ;  
( c1r4_clkb => c1r4_q[10]  ) = (0,0) ;  
( c1r4_clkb => c1r4_q[9]   ) = (0,0) ;  
( c1r2_clkb => c1r2_q[17]  ) = (0,0) ;  
( c1r2_clkb => c1r2_q[16]  ) = (0,0) ;  
( c1r2_clkb => c1r2_q[15]  ) = (0,0) ;  
( c1r2_clkb => c1r2_q[14]  ) = (0,0) ;  
( c1r2_clkb => c1r2_q[13]  ) = (0,0) ;  
( c1r2_clkb => c1r2_q[12]  ) = (0,0) ;  
( c1r2_clkb => c1r2_q[11]  ) = (0,0) ;  
( c1r2_clkb => c1r2_q[10]  ) = (0,0) ;  
( c1r2_clkb => c1r2_q[9]   ) = (0,0) ;  
( c1r3_clkb => c1r3_q[17]  ) = (0,0) ;  
( c1r3_clkb => c1r3_q[16]  ) = (0,0) ;  
( c1r3_clkb => c1r3_q[15]  ) = (0,0) ;  
( c1r3_clkb => c1r3_q[14]  ) = (0,0) ;  
( c1r3_clkb => c1r3_q[13]  ) = (0,0) ;  
( c1r3_clkb => c1r3_q[12]  ) = (0,0) ;  
( c1r3_clkb => c1r3_q[11]  ) = (0,0) ;  
( c1r3_clkb => c1r3_q[10]  ) = (0,0) ;  
( c1r3_clkb => c1r3_q[9]   ) = (0,0) ; 
$setuphold ( posedge c1r1_clkb,  c1r1_clka   , 0, 0);
$setuphold ( posedge c1r1_clka,  c1r1_cea    , 0, 0);
$setuphold ( posedge c1r1_clka,  c1r1_wea    , 0, 0);
$setuphold ( posedge c1r1_clka,  c1r1_aa[11] , 0, 0);
$setuphold ( posedge c1r1_clka,  c1r1_aa[10] , 0, 0);
$setuphold ( posedge c1r1_clka,  c1r1_aa[9]  , 0, 0);
$setuphold ( posedge c1r1_clka,  c1r1_aa[8]  , 0, 0);
$setuphold ( posedge c1r1_clka,  c1r1_aa[7]  , 0, 0);
$setuphold ( posedge c1r1_clka,  c1r1_aa[6]  , 0, 0);
$setuphold ( posedge c1r1_clka,  c1r1_aa[5]  , 0, 0);
$setuphold ( posedge c1r1_clka,  c1r1_aa[4]  , 0, 0);
$setuphold ( posedge c1r1_clka,  c1r1_aa[3]  , 0, 0);
$setuphold ( posedge c1r1_clka,  c1r1_aa[2]  , 0, 0);
$setuphold ( posedge c1r1_clka,  c1r1_aa[1]  , 0, 0);
$setuphold ( posedge c1r1_clka,  c1r1_aa[0]  , 0, 0);
$setuphold ( posedge c1r1_clka,  c1r1_da[17] , 0, 0);
$setuphold ( posedge c1r1_clka,  c1r1_da[16] , 0, 0);
$setuphold ( posedge c1r1_clka,  c1r1_da[15] , 0, 0);
$setuphold ( posedge c1r1_clka,  c1r1_da[14] , 0, 0);
$setuphold ( posedge c1r1_clka,  c1r1_da[13] , 0, 0);
$setuphold ( posedge c1r1_clka,  c1r1_da[12] , 0, 0);
$setuphold ( posedge c1r1_clka,  c1r1_da[11] , 0, 0);
$setuphold ( posedge c1r1_clka,  c1r1_da[10] , 0, 0);
$setuphold ( posedge c1r1_clka,  c1r1_da[9]  , 0, 0);
$setuphold ( posedge c1r1_clka,  c1r1_da[8]  , 0, 0);
$setuphold ( posedge c1r1_clka,  c1r1_da[7]  , 0, 0);
$setuphold ( posedge c1r1_clka,  c1r1_da[6]  , 0, 0);
$setuphold ( posedge c1r1_clka,  c1r1_da[5]  , 0, 0);
$setuphold ( posedge c1r1_clka,  c1r1_da[4]  , 0, 0);
$setuphold ( posedge c1r1_clka,  c1r1_da[3]  , 0, 0);
$setuphold ( posedge c1r1_clka,  c1r1_da[2]  , 0, 0);
$setuphold ( posedge c1r1_clka,  c1r1_da[1]  , 0, 0);
$setuphold ( posedge c1r1_clka,  c1r1_da[0]  , 0, 0);
$setuphold ( posedge c1r1_clka,  c1r1_clkb   , 0, 0);
$setuphold ( posedge c1r1_clkb,  c1r1_ceb    , 0, 0);
$setuphold ( posedge c1r1_clkb,  c1r1_web    , 0, 0);
$setuphold ( posedge c1r1_clkb,  c1r1_ab[11] , 0, 0);
$setuphold ( posedge c1r1_clkb,  c1r1_ab[10] , 0, 0);
$setuphold ( posedge c1r1_clkb,  c1r1_ab[9]  , 0, 0);
$setuphold ( posedge c1r1_clkb,  c1r1_ab[8]  , 0, 0);
$setuphold ( posedge c1r1_clkb,  c1r1_ab[7]  , 0, 0);
$setuphold ( posedge c1r1_clkb,  c1r1_ab[6]  , 0, 0);
$setuphold ( posedge c1r1_clkb,  c1r1_ab[5]  , 0, 0);
$setuphold ( posedge c1r1_clkb,  c1r1_ab[4]  , 0, 0);
$setuphold ( posedge c1r1_clkb,  c1r1_ab[3]  , 0, 0);
$setuphold ( posedge c1r1_clkb,  c1r1_ab[2]  , 0, 0);
$setuphold ( posedge c1r1_clkb,  c1r1_ab[1]  , 0, 0);
$setuphold ( posedge c1r1_clkb,  c1r1_ab[0]  , 0, 0);
$setuphold ( posedge c1r1_clkb,  c1r1_db[17] , 0, 0);
$setuphold ( posedge c1r1_clkb,  c1r1_db[16] , 0, 0);
$setuphold ( posedge c1r1_clkb,  c1r1_db[15] , 0, 0);
$setuphold ( posedge c1r1_clkb,  c1r1_db[14] , 0, 0);
$setuphold ( posedge c1r1_clkb,  c1r1_db[13] , 0, 0);
$setuphold ( posedge c1r1_clkb,  c1r1_db[12] , 0, 0);
$setuphold ( posedge c1r1_clkb,  c1r1_db[11] , 0, 0);
$setuphold ( posedge c1r1_clkb,  c1r1_db[10] , 0, 0);
$setuphold ( posedge c1r1_clkb,  c1r1_db[9]  , 0, 0);
$setuphold ( posedge c1r1_clkb,  c1r1_db[8]  , 0, 0);
$setuphold ( posedge c1r1_clkb,  c1r1_db[7]  , 0, 0);
$setuphold ( posedge c1r1_clkb,  c1r1_db[6]  , 0, 0);
$setuphold ( posedge c1r1_clkb,  c1r1_db[5]  , 0, 0);
$setuphold ( posedge c1r1_clkb,  c1r1_db[4]  , 0, 0);
$setuphold ( posedge c1r1_clkb,  c1r1_db[3]  , 0, 0);
$setuphold ( posedge c1r1_clkb,  c1r1_db[2]  , 0, 0);
$setuphold ( posedge c1r1_clkb,  c1r1_db[1]  , 0, 0);
$setuphold ( posedge c1r1_clkb,  c1r1_db[0]  , 0, 0);
$setuphold ( posedge c1r4_clkb,  c1r4_clka   , 0, 0);
$setuphold ( posedge c1r4_clka,  c1r4_cea    , 0, 0);
$setuphold ( posedge c1r4_clka,  c1r4_wea    , 0, 0);
$setuphold ( posedge c1r4_clka,  c1r4_aa[11] , 0, 0);
$setuphold ( posedge c1r4_clka,  c1r4_aa[10] , 0, 0);
$setuphold ( posedge c1r4_clka,  c1r4_aa[9]  , 0, 0);
$setuphold ( posedge c1r4_clka,  c1r4_aa[8]  , 0, 0);
$setuphold ( posedge c1r4_clka,  c1r4_aa[7]  , 0, 0);
$setuphold ( posedge c1r4_clka,  c1r4_aa[6]  , 0, 0);
$setuphold ( posedge c1r4_clka,  c1r4_aa[5]  , 0, 0);
$setuphold ( posedge c1r4_clka,  c1r4_aa[4]  , 0, 0);
$setuphold ( posedge c1r4_clka,  c1r4_aa[3]  , 0, 0);
$setuphold ( posedge c1r4_clka,  c1r4_aa[2]  , 0, 0);
$setuphold ( posedge c1r4_clka,  c1r4_aa[1]  , 0, 0);
$setuphold ( posedge c1r4_clka,  c1r4_aa[0]  , 0, 0);
$setuphold ( posedge c1r4_clka,  c1r4_da[17] , 0, 0);
$setuphold ( posedge c1r4_clka,  c1r4_da[16] , 0, 0);
$setuphold ( posedge c1r4_clka,  c1r4_da[15] , 0, 0);
$setuphold ( posedge c1r4_clka,  c1r4_da[14] , 0, 0);
$setuphold ( posedge c1r4_clka,  c1r4_da[13] , 0, 0);
$setuphold ( posedge c1r4_clka,  c1r4_da[12] , 0, 0);
$setuphold ( posedge c1r4_clka,  c1r4_da[11] , 0, 0);
$setuphold ( posedge c1r4_clka,  c1r4_da[10] , 0, 0);
$setuphold ( posedge c1r4_clka,  c1r4_da[9]  , 0, 0);
$setuphold ( posedge c1r4_clka,  c1r4_da[8]  , 0, 0);
$setuphold ( posedge c1r4_clka,  c1r4_da[7]  , 0, 0);
$setuphold ( posedge c1r4_clka,  c1r4_da[6]  , 0, 0);
$setuphold ( posedge c1r4_clka,  c1r4_da[5]  , 0, 0);
$setuphold ( posedge c1r4_clka,  c1r4_da[4]  , 0, 0);
$setuphold ( posedge c1r4_clka,  c1r4_da[3]  , 0, 0);
$setuphold ( posedge c1r4_clka,  c1r4_da[2]  , 0, 0);
$setuphold ( posedge c1r4_clka,  c1r4_da[1]  , 0, 0);
$setuphold ( posedge c1r4_clka,  c1r4_da[0]  , 0, 0);
$setuphold ( posedge c1r4_clka,  c1r4_clkb   , 0, 0);
$setuphold ( posedge c1r4_clkb,  c1r4_ceb    , 0, 0);
$setuphold ( posedge c1r4_clkb,  c1r4_web    , 0, 0);
$setuphold ( posedge c1r4_clkb,  c1r4_ab[11] , 0, 0);
$setuphold ( posedge c1r4_clkb,  c1r4_ab[10] , 0, 0);
$setuphold ( posedge c1r4_clkb,  c1r4_ab[9]  , 0, 0);
$setuphold ( posedge c1r4_clkb,  c1r4_ab[8]  , 0, 0);
$setuphold ( posedge c1r4_clkb,  c1r4_ab[7]  , 0, 0);
$setuphold ( posedge c1r4_clkb,  c1r4_ab[6]  , 0, 0);
$setuphold ( posedge c1r4_clkb,  c1r4_ab[5]  , 0, 0);
$setuphold ( posedge c1r4_clkb,  c1r4_ab[4]  , 0, 0);
$setuphold ( posedge c1r4_clkb,  c1r4_ab[3]  , 0, 0);
$setuphold ( posedge c1r4_clkb,  c1r4_ab[2]  , 0, 0);
$setuphold ( posedge c1r4_clkb,  c1r4_ab[1]  , 0, 0);
$setuphold ( posedge c1r4_clkb,  c1r4_ab[0]  , 0, 0);
$setuphold ( posedge c1r4_clkb,  c1r4_db[17] , 0, 0);
$setuphold ( posedge c1r4_clkb,  c1r4_db[16] , 0, 0);
$setuphold ( posedge c1r4_clkb,  c1r4_db[15] , 0, 0);
$setuphold ( posedge c1r4_clkb,  c1r4_db[14] , 0, 0);
$setuphold ( posedge c1r4_clkb,  c1r4_db[13] , 0, 0);
$setuphold ( posedge c1r4_clkb,  c1r4_db[12] , 0, 0);
$setuphold ( posedge c1r4_clkb,  c1r4_db[11] , 0, 0);
$setuphold ( posedge c1r4_clkb,  c1r4_db[10] , 0, 0);
$setuphold ( posedge c1r4_clkb,  c1r4_db[9]  , 0, 0);
$setuphold ( posedge c1r4_clkb,  c1r4_db[8]  , 0, 0);
$setuphold ( posedge c1r4_clkb,  c1r4_db[7]  , 0, 0);
$setuphold ( posedge c1r4_clkb,  c1r4_db[6]  , 0, 0);
$setuphold ( posedge c1r4_clkb,  c1r4_db[5]  , 0, 0);
$setuphold ( posedge c1r4_clkb,  c1r4_db[4]  , 0, 0);
$setuphold ( posedge c1r4_clkb,  c1r4_db[3]  , 0, 0);
$setuphold ( posedge c1r4_clkb,  c1r4_db[2]  , 0, 0);
$setuphold ( posedge c1r4_clkb,  c1r4_db[1]  , 0, 0);
$setuphold ( posedge c1r4_clkb,  c1r4_db[0]  , 0, 0);
$setuphold ( posedge c1r2_clkb,  c1r2_clka   , 0, 0);
$setuphold ( posedge c1r2_clka,  c1r2_cea    , 0, 0);
$setuphold ( posedge c1r2_clka,  c1r2_wea    , 0, 0);
$setuphold ( posedge c1r2_clka,  c1r2_aa[11] , 0, 0);
$setuphold ( posedge c1r2_clka,  c1r2_aa[10] , 0, 0);
$setuphold ( posedge c1r2_clka,  c1r2_aa[9]  , 0, 0);
$setuphold ( posedge c1r2_clka,  c1r2_aa[8]  , 0, 0);
$setuphold ( posedge c1r2_clka,  c1r2_aa[7]  , 0, 0);
$setuphold ( posedge c1r2_clka,  c1r2_aa[6]  , 0, 0);
$setuphold ( posedge c1r2_clka,  c1r2_aa[5]  , 0, 0);
$setuphold ( posedge c1r2_clka,  c1r2_aa[4]  , 0, 0);
$setuphold ( posedge c1r2_clka,  c1r2_aa[3]  , 0, 0);
$setuphold ( posedge c1r2_clka,  c1r2_aa[2]  , 0, 0);
$setuphold ( posedge c1r2_clka,  c1r2_aa[1]  , 0, 0);
$setuphold ( posedge c1r2_clka,  c1r2_aa[0]  , 0, 0);
$setuphold ( posedge c1r2_clka,  c1r2_da[17] , 0, 0);
$setuphold ( posedge c1r2_clka,  c1r2_da[16] , 0, 0);
$setuphold ( posedge c1r2_clka,  c1r2_da[15] , 0, 0);
$setuphold ( posedge c1r2_clka,  c1r2_da[14] , 0, 0);
$setuphold ( posedge c1r2_clka,  c1r2_da[13] , 0, 0);
$setuphold ( posedge c1r2_clka,  c1r2_da[12] , 0, 0);
$setuphold ( posedge c1r2_clka,  c1r2_da[11] , 0, 0);
$setuphold ( posedge c1r2_clka,  c1r2_da[10] , 0, 0);
$setuphold ( posedge c1r2_clka,  c1r2_da[9]  , 0, 0);
$setuphold ( posedge c1r2_clka,  c1r2_da[8]  , 0, 0);
$setuphold ( posedge c1r2_clka,  c1r2_da[7]  , 0, 0);
$setuphold ( posedge c1r2_clka,  c1r2_da[6]  , 0, 0);
$setuphold ( posedge c1r2_clka,  c1r2_da[5]  , 0, 0);
$setuphold ( posedge c1r2_clka,  c1r2_da[4]  , 0, 0);
$setuphold ( posedge c1r2_clka,  c1r2_da[3]  , 0, 0);
$setuphold ( posedge c1r2_clka,  c1r2_da[2]  , 0, 0);
$setuphold ( posedge c1r2_clka,  c1r2_da[1]  , 0, 0);
$setuphold ( posedge c1r2_clka,  c1r2_da[0]  , 0, 0);
$setuphold ( posedge c1r2_clka,  c1r2_clkb   , 0, 0);
$setuphold ( posedge c1r2_clkb,  c1r2_ceb    , 0, 0);
$setuphold ( posedge c1r2_clkb,  c1r2_web    , 0, 0);
$setuphold ( posedge c1r2_clkb,  c1r2_ab[11] , 0, 0);
$setuphold ( posedge c1r2_clkb,  c1r2_ab[10] , 0, 0);
$setuphold ( posedge c1r2_clkb,  c1r2_ab[9]  , 0, 0);
$setuphold ( posedge c1r2_clkb,  c1r2_ab[8]  , 0, 0);
$setuphold ( posedge c1r2_clkb,  c1r2_ab[7]  , 0, 0);
$setuphold ( posedge c1r2_clkb,  c1r2_ab[6]  , 0, 0);
$setuphold ( posedge c1r2_clkb,  c1r2_ab[5]  , 0, 0);
$setuphold ( posedge c1r2_clkb,  c1r2_ab[4]  , 0, 0);
$setuphold ( posedge c1r2_clkb,  c1r2_ab[3]  , 0, 0);
$setuphold ( posedge c1r2_clkb,  c1r2_ab[2]  , 0, 0);
$setuphold ( posedge c1r2_clkb,  c1r2_ab[1]  , 0, 0);
$setuphold ( posedge c1r2_clkb,  c1r2_ab[0]  , 0, 0);
$setuphold ( posedge c1r2_clkb,  c1r2_db[17] , 0, 0);
$setuphold ( posedge c1r2_clkb,  c1r2_db[16] , 0, 0);
$setuphold ( posedge c1r2_clkb,  c1r2_db[15] , 0, 0);
$setuphold ( posedge c1r2_clkb,  c1r2_db[14] , 0, 0);
$setuphold ( posedge c1r2_clkb,  c1r2_db[13] , 0, 0);
$setuphold ( posedge c1r2_clkb,  c1r2_db[12] , 0, 0);
$setuphold ( posedge c1r2_clkb,  c1r2_db[11] , 0, 0);
$setuphold ( posedge c1r2_clkb,  c1r2_db[10] , 0, 0);
$setuphold ( posedge c1r2_clkb,  c1r2_db[9]  , 0, 0);
$setuphold ( posedge c1r2_clkb,  c1r2_db[8]  , 0, 0);
$setuphold ( posedge c1r2_clkb,  c1r2_db[7]  , 0, 0);
$setuphold ( posedge c1r2_clkb,  c1r2_db[6]  , 0, 0);
$setuphold ( posedge c1r2_clkb,  c1r2_db[5]  , 0, 0);
$setuphold ( posedge c1r2_clkb,  c1r2_db[4]  , 0, 0);
$setuphold ( posedge c1r2_clkb,  c1r2_db[3]  , 0, 0);
$setuphold ( posedge c1r2_clkb,  c1r2_db[2]  , 0, 0);
$setuphold ( posedge c1r2_clkb,  c1r2_db[1]  , 0, 0);
$setuphold ( posedge c1r2_clkb,  c1r2_db[0]  , 0, 0);
$setuphold ( posedge c1r3_clkb,  c1r3_clka   , 0, 0);
$setuphold ( posedge c1r3_clka,  c1r3_cea    , 0, 0);
$setuphold ( posedge c1r3_clka,  c1r3_wea    , 0, 0);
$setuphold ( posedge c1r3_clka,  c1r3_aa[11] , 0, 0);
$setuphold ( posedge c1r3_clka,  c1r3_aa[10] , 0, 0);
$setuphold ( posedge c1r3_clka,  c1r3_aa[9]  , 0, 0);
$setuphold ( posedge c1r3_clka,  c1r3_aa[8]  , 0, 0);
$setuphold ( posedge c1r3_clka,  c1r3_aa[7]  , 0, 0);
$setuphold ( posedge c1r3_clka,  c1r3_aa[6]  , 0, 0);
$setuphold ( posedge c1r3_clka,  c1r3_aa[5]  , 0, 0);
$setuphold ( posedge c1r3_clka,  c1r3_aa[4]  , 0, 0);
$setuphold ( posedge c1r3_clka,  c1r3_aa[3]  , 0, 0);
$setuphold ( posedge c1r3_clka,  c1r3_aa[2]  , 0, 0);
$setuphold ( posedge c1r3_clka,  c1r3_aa[1]  , 0, 0);
$setuphold ( posedge c1r3_clka,  c1r3_aa[0]  , 0, 0);
$setuphold ( posedge c1r3_clka,  c1r3_da[17] , 0, 0);
$setuphold ( posedge c1r3_clka,  c1r3_da[16] , 0, 0);
$setuphold ( posedge c1r3_clka,  c1r3_da[15] , 0, 0);
$setuphold ( posedge c1r3_clka,  c1r3_da[14] , 0, 0);
$setuphold ( posedge c1r3_clka,  c1r3_da[13] , 0, 0);
$setuphold ( posedge c1r3_clka,  c1r3_da[12] , 0, 0);
$setuphold ( posedge c1r3_clka,  c1r3_da[11] , 0, 0);
$setuphold ( posedge c1r3_clka,  c1r3_da[10] , 0, 0);
$setuphold ( posedge c1r3_clka,  c1r3_da[9]  , 0, 0);
$setuphold ( posedge c1r3_clka,  c1r3_da[8]  , 0, 0);
$setuphold ( posedge c1r3_clka,  c1r3_da[7]  , 0, 0);
$setuphold ( posedge c1r3_clka,  c1r3_da[6]  , 0, 0);
$setuphold ( posedge c1r3_clka,  c1r3_da[5]  , 0, 0);
$setuphold ( posedge c1r3_clka,  c1r3_da[4]  , 0, 0);
$setuphold ( posedge c1r3_clka,  c1r3_da[3]  , 0, 0);
$setuphold ( posedge c1r3_clka,  c1r3_da[2]  , 0, 0);
$setuphold ( posedge c1r3_clka,  c1r3_da[1]  , 0, 0);
$setuphold ( posedge c1r3_clka,  c1r3_da[0]  , 0, 0);
$setuphold ( posedge c1r3_clka,  c1r3_clkb   , 0, 0);
$setuphold ( posedge c1r3_clkb,  c1r3_ceb    , 0, 0);
$setuphold ( posedge c1r3_clkb,  c1r3_web    , 0, 0);
$setuphold ( posedge c1r3_clkb,  c1r3_ab[11] , 0, 0);
$setuphold ( posedge c1r3_clkb,  c1r3_ab[10] , 0, 0);
$setuphold ( posedge c1r3_clkb,  c1r3_ab[9]  , 0, 0);
$setuphold ( posedge c1r3_clkb,  c1r3_ab[8]  , 0, 0);
$setuphold ( posedge c1r3_clkb,  c1r3_ab[7]  , 0, 0);
$setuphold ( posedge c1r3_clkb,  c1r3_ab[6]  , 0, 0);
$setuphold ( posedge c1r3_clkb,  c1r3_ab[5]  , 0, 0);
$setuphold ( posedge c1r3_clkb,  c1r3_ab[4]  , 0, 0);
$setuphold ( posedge c1r3_clkb,  c1r3_ab[3]  , 0, 0);
$setuphold ( posedge c1r3_clkb,  c1r3_ab[2]  , 0, 0);
$setuphold ( posedge c1r3_clkb,  c1r3_ab[1]  , 0, 0);
$setuphold ( posedge c1r3_clkb,  c1r3_ab[0]  , 0, 0);
$setuphold ( posedge c1r3_clkb,  c1r3_db[17] , 0, 0);
$setuphold ( posedge c1r3_clkb,  c1r3_db[16] , 0, 0);
$setuphold ( posedge c1r3_clkb,  c1r3_db[15] , 0, 0);
$setuphold ( posedge c1r3_clkb,  c1r3_db[14] , 0, 0);
$setuphold ( posedge c1r3_clkb,  c1r3_db[13] , 0, 0);
$setuphold ( posedge c1r3_clkb,  c1r3_db[12] , 0, 0);
$setuphold ( posedge c1r3_clkb,  c1r3_db[11] , 0, 0);
$setuphold ( posedge c1r3_clkb,  c1r3_db[10] , 0, 0);
$setuphold ( posedge c1r3_clkb,  c1r3_db[9]  , 0, 0);
$setuphold ( posedge c1r3_clkb,  c1r3_db[8]  , 0, 0);
$setuphold ( posedge c1r3_clkb,  c1r3_db[7]  , 0, 0);
$setuphold ( posedge c1r3_clkb,  c1r3_db[6]  , 0, 0);
$setuphold ( posedge c1r3_clkb,  c1r3_db[5]  , 0, 0);
$setuphold ( posedge c1r3_clkb,  c1r3_db[4]  , 0, 0);
$setuphold ( posedge c1r3_clkb,  c1r3_db[3]  , 0, 0);
$setuphold ( posedge c1r3_clkb,  c1r3_db[2]  , 0, 0);
$setuphold ( posedge c1r3_clkb,  c1r3_db[1]  , 0, 0);
$setuphold ( posedge c1r3_clkb,  c1r3_db[0]  , 0, 0);
$setuphold ( posedge c1r1_clka,     wr_req_n   , 0, 0  );    
$setuphold ( posedge c1r1_clkb,     wr_req_n   , 0, 0  );    
$setuphold ( posedge c1r1_clka,     rd_req_n   , 0, 0  );    
$setuphold ( posedge c1r1_clkb,     rd_req_n   , 0, 0  );    
 endspecify
 
endmodule


module M7A_FIFO_CTRL (
    clka,
    clkb,
    rstna,
    rstnb,
	fifo_clr ,
	wr_req_n ,
	rd_req_n ,
	wfull ,
	wfull_almost ,
	rempty ,
	rempty_almost ,
	overflow ,
	wr_ack ,
	underflow ,
	rd_ack ,
	fifo_rda,
	fifo_rdn,
	fifo_wra,
	fifo_wrn
);
parameter r_width   =  5'b0_0000;
parameter w_width   =  5'b0_0000;
parameter af_level  = 15'b0;
parameter ae_level  = 15'b0;

parameter fifo_en   =  1'b0;
parameter async_en  =  1'b0;

input   clka;
input   clkb;
input   rstna;
input   rstnb;
input	fifo_clr ;
input	wr_req_n ;
input	rd_req_n ;
output	wfull ;
output	wfull_almost ;
output	rempty ;
output	rempty_almost ;
output	overflow ;
output	wr_ack ;
output	underflow ;
output	rd_ack ;
output	[13:0]	fifo_rda; 
output	    	fifo_rdn; 
output	[13:0]	fifo_wra; 
output	    	fifo_wrn; 

generate 
    if(async_en == 1'b1) begin
        M7A_ASYN_FIFO_SIM u_asyn_fifo(
            .wclk(clkb),
            .wrst_n(rstnb),
            .rclk(clka),
            .rrst_n(rstna),
            .fifo_clr(fifo_clr),

            .w_width(w_width),
            .r_width(r_width),
            .af_level(af_level),
            .ae_level(ae_level),
            .wr_req_n(wr_req_n),
            .rd_req_n(rd_req_n),
            .wfull(wfull),
            .wfull_almost(wfull_almost),
            .rempty(rempty),
            .rempty_almost(rempty_almost),
        	.overflow(overflow),
        	.underflow(underflow),
        	.wr_ack(wr_ack),
        	.rd_ack(rd_ack),
            .waddr_mem(fifo_wra), 
            .raddr_mem(fifo_rda),
            .wr_mem_n(fifo_wrn),            
            .rd_mem_n(fifo_rdn)            
        );

    end else begin
        M7A_SYN_FIFO_SIM u_syn_fifo(
            .wr_req_n(wr_req_n),
            .rd_req_n(rd_req_n),
            .rst_n(rstna),
            .clk(clka),
        	.w_width(w_width),
        	.r_width(r_width),
        	.af_level(af_level),
        	.ae_level(ae_level),
            .wfull(wfull),
            .wfull_almost(wfull_almost),
            .rempty(rempty),
            .rempty_almost(rempty_almost),
        	.waddr_mem(fifo_wra), 
        	.raddr_mem(fifo_rda), 
        	.wr_mem_n(fifo_wrn),			
        	.rd_mem_n(fifo_rdn),
        	.overflow(overflow),
        	.underflow(underflow),
        	.wr_ack(wr_ack),
        	.rd_ack(rd_ack),
        	.fifo_clr(fifo_clr)
        );
    end
endgenerate


endmodule

module M7A_ASYN_FIFO_SIM(
    fifo_clr,
    w_width,
    r_width,
    af_level,
    ae_level,
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
	overflow,
	underflow,
	wr_ack,
	rd_ack,
    waddr_mem, 
    raddr_mem,
    wr_mem_n,            
    rd_mem_n            
    );

parameter  DWSIZE = 5;            // data width
parameter  DRSIZE = 5;            // data width
parameter  ASIZE = 14;            // address size

input                  fifo_clr;                        // fifo clear signal
input                  wr_req_n;                         // fifo wr enable
input                  wclk;                         // write clock
input                  wrst_n;                        // reset of write clock
input                  rd_req_n;                         // fifo read enable
input                  rclk;                         // read clock
input                  rrst_n;                        // reset of read clock
input    [ASIZE:0]     af_level;
input    [ASIZE:0]     ae_level;
input    [DWSIZE-1:0]  w_width;
input    [DRSIZE-1:0]  r_width;
output                 wfull;                         // fifo full output
output                 wfull_almost;                // fifo almost full output
output                 rempty;                     // fifo empty output
output                 rempty_almost;                // fifo almost empty output

output  [ASIZE-1:0]    waddr_mem; 
output  [ASIZE-1:0]    raddr_mem;
output                 wr_mem_n;            
output                 rd_mem_n;            

output	            overflow;
output	            underflow;
output	            wr_ack;
output	            rd_ack;

wire	[ASIZE:0]	   depth=1<<ASIZE;
                                                
reg                    wfull;                         // fifo full output
reg                    wfull_almost;                // fifo almost full output
reg                    rempty;                     // fifo empty output
reg                    rempty_almost;                // fifo almost empty output
reg		            overflow;
reg		            underflow;
reg		            wr_ack;
reg		            rd_ack;

// memory control
wire   [ASIZE-1:0]     waddr_mem; 
wire   [ASIZE-1:0]     raddr_mem;
wire                   wr_mem_n;            
wire                   rd_mem_n;            

// read clock domain
reg    [ASIZE:0]   rptr_bin;                    // main read ptr
wire   [ASIZE:0]   rptr_bin_next;                // next read ptr
reg    [ASIZE:0]   rptr_gray;                    // read ptr in gray, from rptr_bin
wire   [ASIZE:0]   rgraynext;                    // rptr_gray comb 
wire   [ASIZE:0]   rq2_wptr_bin;                // write ptr from write clock domain
reg    [ASIZE:0]   rq2_wptr_bin_pre;            // rq2_wptr_bin comb
reg    [ASIZE:0]   rq1_wptr_gray;                // write ptr from write clock domain pre 1 clock 
reg    [ASIZE:0]   rq2_wptr_gray;                // write ptr from write clock domain pre 2 clock
reg    [ASIZE:0]   r_counter;                    // counter in read clock 

reg                r_clr1;                        // clear in read clock pre 1 clock
reg                r_clr2;                        // clear in read clock pre 2 clock

// write clock domain
reg    [ASIZE:0]   wptr_bin;                    // main write ptr
wire   [ASIZE:0]   wptr_bin_next;                // next write ptr
reg    [ASIZE:0]   wptr_gray;                    // write ptr in gray, from wptr_bin
wire   [ASIZE:0]   wgraynext;                     // wptr_gray comb
wire   [ASIZE:0]   wq2_rptr_bin;                // write ptr from read clock domain
reg    [ASIZE:0]   wq2_rptr_bin_pre;            // wq2_rptr_bin comb
reg    [ASIZE:0]   wq1_rptr_gray;                 // read ptr from read clock domain pre 1 clock
reg    [ASIZE:0]   wq2_rptr_gray;                // read ptr from read clock domain pre 2 clock
reg    [ASIZE:0]   w_counter;                    // counter in write clock

reg                w_clr1;                        // clear in write clock pre 1 clock
reg                w_clr2;                        // clear in write clock pre 2 clock


reg                wq1_rd_mem_n;
reg                wq2_rd_mem_n;
reg                wq1_wr_mem_n;
reg                wq2_wr_mem_n;
reg    [ASIZE:0]   r_count_reg;                    // counter in read clock 
reg    [ASIZE:0]   w_count_reg;                    // counter in read clock 

wire    [ASIZE:0]     going_full_threshold = depth>>1;
wire    [ASIZE:0]     going_empty_threshold = depth>>1;
reg  direction_flagrd;
reg  direction_flagwr;

wire    [ASIZE:0]  w_depth;
wire    [ASIZE:0]  r_depth;
wire    [ASIZE:0]  wptr_bin_shift;
wire    [ASIZE:0]  wptr_bin_next_shift;
wire    [ASIZE:0]  wq2_rptr_bin_shift;
wire    [ASIZE:0]  rptr_bin_shift;
wire    [ASIZE:0]  rptr_bin_next_shift;
wire    [ASIZE:0]  rq2_wptr_bin_shift;

wire   [DWSIZE:0] w_step;
wire   [DRSIZE:0] r_step;
wire   rempty_val;
wire   wfull_val;

assign w_step = w_width[DWSIZE-1]? 32 :
                w_width[DWSIZE-2]? 16 :
                w_width[DWSIZE-3]?  8 :
                w_width[DWSIZE-4]?  4 :
                w_width[DWSIZE-5]?  2 : 1 ;
assign r_step = r_width[DRSIZE-1]? 32 :
                r_width[DRSIZE-2]? 16 :
                r_width[DRSIZE-3]?  8 :
                r_width[DRSIZE-4]?  4 :
                r_width[DRSIZE-5]?  2 : 1 ;

//--------------------------------------------------------
// Read-domain synchronizer
//--------------------------------------------------------
// write point sync
always @(posedge rclk or negedge rrst_n) begin
      if (!rrst_n) begin
         rq2_wptr_gray <=   0;
         rq1_wptr_gray <=   0;
    end
      else begin
        rq2_wptr_gray <=   rq1_wptr_gray;
        rq1_wptr_gray <=   wptr_gray;
    end
end
// clear signal sync
always @(posedge rclk or negedge rrst_n) begin
    if (!rrst_n) begin
        r_clr2 <=   0;
        r_clr1 <=   0;
    end
    else begin
        r_clr2 <=   r_clr1;
        r_clr1 <=   fifo_clr;
    end
end

//--------------------------------------------------------
// Write-domain synchronizer 
//--------------------------------------------------------
// read point sync
always @(posedge wclk or negedge wrst_n) begin
      if (!wrst_n) begin
         wq2_rptr_gray <=   0;
         wq1_rptr_gray <=   0;
    end
      else begin
        wq2_rptr_gray <=   wq1_rptr_gray;
        wq1_rptr_gray <=   rptr_gray;
    end
end
// clear signal sync
always @(posedge wclk or negedge wrst_n) begin
    if (!wrst_n) begin
        w_clr2 <=   0;
        w_clr1 <=   0;
    end
    else begin
        w_clr2 <=   w_clr1;
        w_clr1 <=   fifo_clr;
    end
end

//--------------------------------------------------------
// Read pointer & empty generation logic
//--------------------------------------------------------
assign rptr_bin_next    = (~rd_req_n & ~rempty) ?(((rptr_bin+1)==r_depth) ? 0 : rptr_bin+1 ):rptr_bin;
always @(posedge rclk or negedge rrst_n) begin
      if (!rrst_n) begin
         rptr_bin         <=   0;
    end
    else if (r_clr2) begin
         rptr_bin         <=   0;
    end
      else begin
         rptr_bin         <=   rptr_bin_next;
    end
end
// read ptr change to gray code for write clock domain use
assign rgraynext  = (rptr_bin>>1) ^ rptr_bin; 
always @(posedge rclk or negedge rrst_n) begin
      if (!rrst_n) begin
         rptr_gray     <=   0;
    end
    else if (r_clr2) begin
         rptr_gray     <=   0;
    end
      else begin
         rptr_gray     <=   rgraynext;
    end
end

//memory control output
assign rd_mem_n = rd_req_n | rempty;
assign rptr_bin_next_shift = 
					r_width[DRSIZE-1] ? {rptr_bin_next[ASIZE-5:0],5'b0}:
                    r_width[DRSIZE-2] ? {rptr_bin_next[ASIZE-4:0],4'b0}:
                    r_width[DRSIZE-3] ? {rptr_bin_next[ASIZE-3:0],3'b0}:
                    r_width[DRSIZE-4] ? {rptr_bin_next[ASIZE-2:0],2'b0}:
                    r_width[DRSIZE-5] ? {rptr_bin_next[ASIZE-1:0],1'b0}:
                    rptr_bin_next[ASIZE:0];  
assign rptr_bin_shift = 
					r_width[DRSIZE-1] ? {rptr_bin[ASIZE-5:0],5'b0}:
                    r_width[DRSIZE-2] ? {rptr_bin[ASIZE-4:0],4'b0}:
                    r_width[DRSIZE-3] ? {rptr_bin[ASIZE-3:0],3'b0}:
                    r_width[DRSIZE-4] ? {rptr_bin[ASIZE-2:0],2'b0}:
                    r_width[DRSIZE-5] ? {rptr_bin[ASIZE-1:0],1'b0}:
                    rptr_bin[ASIZE:0]; 
assign raddr_mem  = rptr_bin_shift[ASIZE-1:0];   // Memory read-address pointer

assign rq2_wptr_bin_shift  = 
					w_width[DWSIZE-1] ? {rq2_wptr_bin[ASIZE-5:0],5'b0}:
                    w_width[DWSIZE-2] ? {rq2_wptr_bin[ASIZE-4:0],4'b0}:
                    w_width[DWSIZE-3] ? {rq2_wptr_bin[ASIZE-3:0],3'b0}:
                    w_width[DWSIZE-4] ? {rq2_wptr_bin[ASIZE-2:0],2'b0}:
                    w_width[DWSIZE-5] ? {rq2_wptr_bin[ASIZE-1:0],1'b0}:
                    rq2_wptr_bin[ASIZE:0];    

assign r_depth  = 
					r_width[DRSIZE-1] ? {5'b0,depth[ASIZE:5]}:
                    r_width[DRSIZE-2] ? {4'b0,depth[ASIZE:4]}:
                    r_width[DRSIZE-3] ? {3'b0,depth[ASIZE:3]}:
                    r_width[DRSIZE-4] ? {2'b0,depth[ASIZE:2]}:
                    r_width[DRSIZE-5] ? {1'b0,depth[ASIZE:1]}:
                    depth[ASIZE:0];    

reg    [ASIZE:0]   r_counter_tmp;                    // counter in read clock 
always @(posedge rclk ) begin
        r_counter_tmp <=   r_counter;
    end
always @(*) begin
    if (!rrst_n) begin
        r_counter = 0;
    end else if (r_clr2) begin
        r_counter =  0;
    end else if (rq2_wptr_bin_shift>rptr_bin_next_shift) begin
        r_counter =  rq2_wptr_bin_shift - rptr_bin_next_shift;
    end else if (rq2_wptr_bin_shift<rptr_bin_next_shift) begin
        r_counter =  depth - (rptr_bin_next_shift - rq2_wptr_bin_shift) ;
	end else begin
        r_counter = r_counter_tmp;
    end
end
reg direction_flagrd_tmp;
always @(posedge rclk ) begin
        direction_flagrd_tmp <=   direction_flagrd;
    end
always @(*) begin
    if (r_counter > going_full_threshold) begin
        direction_flagrd = 0;
    end else if (r_counter < going_empty_threshold) begin
        direction_flagrd = 1;
    end else begin
        direction_flagrd = direction_flagrd_tmp;
    end
end

//real empty
assign rempty_val = direction_flagrd&&(
                  (rq2_wptr_bin_shift==rptr_bin_next_shift)||
				  ((rptr_bin_next_shift+r_step>{1'b0,rq2_wptr_bin_shift})&&(rptr_bin_next_shift<rq2_wptr_bin_shift))
				  );
always @(posedge rclk or negedge rrst_n) begin
      if (!rrst_n) begin
        rempty <=   1'b1;
    end
    else if (r_clr2) begin
        rempty <=   1'b1;
    end
      else if(rempty_val) begin   
        rempty <=   1'b1;
    end
    else begin
        rempty <=   1'b0;
    end
end

always @(posedge rclk or negedge rrst_n) begin
      if (!rrst_n) begin
        rempty_almost <=   1'b1;
    end 
    else if (r_clr2) begin
        rempty_almost <=   1'b1;
    end
    else if(r_counter <=  ae_level) begin
        rempty_almost <=   1'b1;
    end
    else begin
        rempty_almost <=   1'b0;
    end
end
 


//--------------------------------------------------------
// Write pointer & full generation logic
//--------------------------------------------------------
assign wptr_bin_next    = (~wr_req_n & ~wfull) ? (((wptr_bin+1)==w_depth) ? 0 : wptr_bin + 1 ): wptr_bin;
always @(posedge wclk or negedge wrst_n) begin
      if (!wrst_n) begin
         wptr_bin         <=   0;
    end
    else if (w_clr2) begin
         wptr_bin         <=   0;
    end
      else begin
         wptr_bin         <=   wptr_bin_next;
    end
end
// write ptr change to gray code for read clock domain use
assign wgraynext  = (wptr_bin>>1) ^ wptr_bin; 
always @(posedge wclk or negedge wrst_n) begin
      if (!wrst_n) begin
         wptr_gray     <=   0;
    end
    else if (w_clr2) begin
         wptr_gray     <=   0;
    end
      else begin
         wptr_gray     <=   wgraynext;
    end
end

//memory control output
assign wr_mem_n = wr_req_n | wfull;
assign wptr_bin_next_shift  = 
					w_width[DWSIZE-1] ? {wptr_bin_next[ASIZE-5:0],5'b0}:
                    w_width[DWSIZE-2] ? {wptr_bin_next[ASIZE-4:0],4'b0}:
                    w_width[DWSIZE-3] ? {wptr_bin_next[ASIZE-3:0],3'b0}:
                    w_width[DWSIZE-4] ? {wptr_bin_next[ASIZE-2:0],2'b0}:
                    w_width[DWSIZE-5] ? {wptr_bin_next[ASIZE-1:0],1'b0}:
                    wptr_bin_next[ASIZE:0];    
assign wptr_bin_shift  = 
					w_width[DWSIZE-1] ? {wptr_bin[ASIZE-5:0],5'b0}:
                    w_width[DWSIZE-2] ? {wptr_bin[ASIZE-4:0],4'b0}:
                    w_width[DWSIZE-3] ? {wptr_bin[ASIZE-3:0],3'b0}:
                    w_width[DWSIZE-4] ? {wptr_bin[ASIZE-2:0],2'b0}:
                    w_width[DWSIZE-5] ? {wptr_bin[ASIZE-1:0],1'b0}:
                    wptr_bin[ASIZE:0];    
assign waddr_mem  = wptr_bin_shift[ASIZE-1:0];// Memory read-address pointer

assign wq2_rptr_bin_shift  = 
					r_width[DRSIZE-1] ? {wq2_rptr_bin[ASIZE-5:0],5'b0}:
                    r_width[DRSIZE-2] ? {wq2_rptr_bin[ASIZE-4:0],4'b0}:
                    r_width[DRSIZE-3] ? {wq2_rptr_bin[ASIZE-3:0],3'b0}:
                    r_width[DRSIZE-4] ? {wq2_rptr_bin[ASIZE-2:0],2'b0}:
                    r_width[DRSIZE-5] ? {wq2_rptr_bin[ASIZE-1:0],1'b0}:
                    wq2_rptr_bin[ASIZE:0];    

assign w_depth  = 
					w_width[DWSIZE-1] ? {5'b0,depth[ASIZE:5]}:
                    w_width[DWSIZE-2] ? {4'b0,depth[ASIZE:4]}:
                    w_width[DWSIZE-3] ? {3'b0,depth[ASIZE:3]}:
                    w_width[DWSIZE-4] ? {2'b0,depth[ASIZE:2]}:
                    w_width[DWSIZE-5] ? {1'b0,depth[ASIZE:1]}:
                    depth[ASIZE:0];    

//---------------------------------------------------------------------
// common logic for almost_full/empty and prog_full/empty generation
//---------------------------------------------------------------------
assign wq2_rptr_bin = gray2bin(wq2_rptr_gray);
assign rq2_wptr_bin = gray2bin(rq2_wptr_gray);

reg    [ASIZE:0]   w_counter_tmp;                    // counter in read clock 
always @(posedge wclk ) begin
        w_counter_tmp <=   w_counter;
    end
always @(*) begin
    if (!wrst_n) begin
        w_counter =  0;
    end
    else if (w_clr2) begin
        w_counter =  0;
    end
    else if(wptr_bin_shift > wq2_rptr_bin_shift) begin
        w_counter =  wptr_bin_shift - wq2_rptr_bin_shift ;
    end
    else if(wptr_bin_shift < wq2_rptr_bin_shift)  begin
        w_counter =  depth - (wq2_rptr_bin_shift - wptr_bin_shift) ;
    end else begin
        w_counter =  w_counter_tmp;
    end
end

reg direction_flagwr_tmp;
always @(posedge wclk ) begin
        direction_flagwr_tmp <=   direction_flagwr;
    end
always @(*) begin
    if (w_counter > going_full_threshold) begin
        direction_flagwr = 1;
    end else if (w_counter < going_empty_threshold) begin
        direction_flagwr = 0;
    end else begin
        direction_flagwr = direction_flagwr_tmp;
    end
end

assign wfull_val = direction_flagwr&&(
                 (wq2_rptr_bin_shift==wptr_bin_next_shift)||
				 ((wptr_bin_next_shift+w_step>{1'b0,wq2_rptr_bin_shift})&&(wptr_bin_next_shift<wq2_rptr_bin_shift))
				 );
// real full
always @(posedge wclk or negedge wrst_n) begin
      if (!wrst_n) begin
        wfull <=   1'b0;
    end
    else if (w_clr2) begin
        wfull <=   1'b0;
    end
      else if(wfull_val) begin   
        wfull <=   1'b1;
    end
    else begin
        wfull <=   1'b0;
    end
end

always @(posedge wclk or negedge wrst_n) begin
      if (!wrst_n) begin
        wfull_almost <=   1'b0;
    end 
    else if (w_clr2) begin
        wfull_almost <=   1'b0;
    end
    else if(w_counter >= af_level) begin
        wfull_almost <=   1'b1;
    end
    else begin
        wfull_almost <=   1'b0;
    end
end

always @ (posedge wclk or negedge wrst_n)
    if(~wrst_n)
        wr_ack <=  0;
    else if(w_clr2)
        wr_ack <=  0;
    else
        wr_ack <=  (~wr_req_n) & (~wfull);

always @ (posedge rclk or negedge rrst_n)
    if(~rrst_n)
        rd_ack <=  0;
    else if(r_clr2)
        rd_ack <=  0;
    else
        rd_ack <=  (~rd_req_n) & (~rempty);

always @ (posedge wclk or negedge wrst_n)
    if(~wrst_n)
        overflow <=  0;
    else if(w_clr2)
        overflow <=  0;
    else
        overflow <=  (~wr_req_n) & wfull;

always @ (posedge rclk or negedge rrst_n)
    if(~rrst_n)
        underflow <=  0;
    else if(r_clr2)
        underflow <=  0;
    else
        underflow <=  (~rd_req_n) & rempty;

//---------------------------------------------------------------------
// gray to bin transform
//---------------------------------------------------------------------
function [ASIZE:0] gray2bin;
input [ASIZE:0] gray;
reg [ASIZE:0] bin;
integer i;
begin
	bin = gray;
	for (i=1; i<=ASIZE; i=i+1) begin
		bin = bin ^ (gray>>i);
	end
	gray2bin = bin;
end
endfunction


endmodule


module M7A_SYN_FIFO_SIM(
    wr_req_n,
    rd_req_n,
    rst_n,
    clk,
	w_width,
	r_width,
	af_level,
	ae_level,
    wfull,
    wfull_almost,
    rempty,
    rempty_almost,
	waddr_mem, 
	raddr_mem, 
	wr_mem_n,			
	rd_mem_n,
	overflow,
	underflow,
	wr_ack,
	rd_ack,
	fifo_clr
    );

parameter  DWSIZE = 5;			// data width
parameter  DRSIZE = 5;			// data width
parameter  ASIZE = 14;			// address size

input              	wr_req_n; 					// fifo wr enable
input              	rd_req_n; 					// fifo read enable
input				rst_n;						// reset
input				clk; 						// clock
input	[DWSIZE-1:0]	w_width;
input	[DRSIZE-1:0]	r_width;
input	[ASIZE:0]	af_level;
input	[ASIZE:0]	ae_level;
output             	wfull; 						// fifo full output
output				wfull_almost;				// fifo almost full output
output             	rempty; 					// fifo empty output
output				rempty_almost;				// fifo almost empty output
output [ASIZE-1:0] 	waddr_mem; 
output [ASIZE-1:0] 	raddr_mem; 
output              wr_mem_n;			
output              rd_mem_n;			
input				fifo_clr;
                                                
output	            overflow;
output	            underflow;
output	            wr_ack;
output	            rd_ack;
                                                
reg             	wfull; 						// fifo full output
reg					wfull_almost;				// fifo almost full output
reg             	rempty; 					// fifo empty output
reg					rempty_almost;				// fifo almost empty output
reg		            overflow;
reg		            underflow;
reg		            wr_ack;
reg		            rd_ack;

// memory control
wire   [ASIZE-1:0] 	waddr_mem; 
wire   [ASIZE-1:0]	raddr_mem;
wire               	wr_mem_n;			
wire               	rd_mem_n;			

reg    [ASIZE-1:0] 	wptr_mem; 
wire   [ASIZE-1:0] 	wptr_next; 
reg    [ASIZE-1:0]	rptr_mem;
wire   [ASIZE-1:0]	rptr_next;
reg    [ASIZE:0]	count;
reg    [ASIZE:0]	count_next;

wire   [DWSIZE:0] w_step;
wire   [DRSIZE:0] r_step;
wire	[ASIZE:0]	depth=1<<ASIZE;
wire   rempty_val;
wire   wfull_val;

wire    [ASIZE:0]     going_full_threshold = depth>>1;
wire    [ASIZE:0]     going_empty_threshold = depth>>1;
reg  direction_flagrd;
reg  direction_flagwr;

//--------------------------------------------------------
//  address point & counter state
//--------------------------------------------------------
assign wr_mem_n = wr_req_n |  wfull ;
assign rd_mem_n = rd_req_n | rempty;

assign w_step = w_width[DWSIZE-1]? 32 :
                w_width[DWSIZE-2]? 16 :
                w_width[DWSIZE-3]?  8 :
                w_width[DWSIZE-4]?  4 :
                w_width[DWSIZE-5]?  2 : 1 ;
assign r_step = r_width[DRSIZE-1]? 32 :
                r_width[DRSIZE-2]? 16 :
                r_width[DRSIZE-3]?  8 :
                r_width[DRSIZE-4]?  4 :
                r_width[DRSIZE-5]?  2 : 1 ;

assign wptr_next = (wr_mem_n)? wptr_mem : wptr_mem + w_step;
assign rptr_next = (rd_mem_n)? rptr_mem : rptr_mem + r_step;

always @(*) begin
  case ({wr_mem_n, rd_mem_n}) 
    2'b00:  count_next = ((count+w_step>=r_step)&&(count+w_step<=r_step+depth))?count + w_step - r_step:count;  
    2'b11:  count_next = count;
    2'b01:  count_next = (count+w_step<=depth)?count + w_step:count;
    2'b10:  count_next = (count>=r_step)?count - r_step:count;
  endcase
end

reg direction_flagrd_tmp;
always @(posedge clk ) begin
        direction_flagrd_tmp <=   direction_flagrd;
    end
always @(*) begin
    if (count_next > going_full_threshold) begin
        direction_flagrd = 0;
    end else if (count_next < going_empty_threshold) begin
        direction_flagrd = 1;
    end else begin
        direction_flagrd = direction_flagrd_tmp;
    end
end
reg direction_flagwr_tmp;
always @(posedge clk ) begin
        direction_flagwr_tmp <=   direction_flagwr;
    end
always @(*) begin
    if (count_next > going_full_threshold) begin
        direction_flagwr = 1;
    end else if (count_next < going_empty_threshold) begin
        direction_flagwr = 0;
    end else begin
        direction_flagwr = direction_flagwr_tmp;
    end
end

always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    wptr_mem    <=    0;
    rptr_mem    <=    0; 
    count   	<=    0;
  end
  else if(fifo_clr) begin
    wptr_mem    <=    0;
    rptr_mem    <=    0;
    count   	<=    0;
  end
  else begin
    wptr_mem    <=    wptr_next;
    rptr_mem    <=    rptr_next;
    count   	<=    count_next;
  end
end

assign waddr_mem  = wptr_mem[ASIZE-1:0];
assign raddr_mem  = rptr_mem[ASIZE-1:0];

//--------------------------------------------------------
// read empty & write full generation
//--------------------------------------------------------
assign rempty_val = direction_flagrd&&(
                  (wptr_next==rptr_next)||
				  ((rptr_next+r_step>{1'b0,wptr_next})&&(rptr_next<wptr_next))
				  );

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    rempty        <=    1;
  end
  else if(fifo_clr) begin
    rempty        <=    1;
  end
  else if (rempty_val) begin
    rempty        <=    1;
  end
  else begin
    rempty        <=    0;
  end
end


always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    rempty_almost <=    1;
  end
  else if(fifo_clr) begin
    rempty_almost <=    1;
  end
  else if (count_next <=  ae_level) begin
    rempty_almost <=    1;
  end
  else begin
    rempty_almost <=    0;
  end
end



always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    wfull_almost  <=    0;
  end
  else if(fifo_clr) begin
    wfull_almost  <=    0;
  end
  else if (count_next >= af_level) begin
    wfull_almost  <=    1;
  end
  else begin
    wfull_almost  <=    0;
  end
end


assign wfull_val = direction_flagwr&&(
                 (rptr_next==wptr_next)||
				 ((wptr_next+w_step>{1'b0,rptr_next})&&(wptr_next<rptr_next))
				 );

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    wfull         <=    0;
  end
  else if(fifo_clr) begin
    wfull		  <=    0;
  end
  else if (wfull_val) begin
    wfull         <=    1;
  end
  else begin
    wfull         <=    0;
  end
end

always @ (posedge clk or negedge rst_n)
    if(~rst_n)
        wr_ack <=  0;
    else if(fifo_clr)
        wr_ack <=  0;
    else
        wr_ack <=  (~wr_req_n) & (~wfull);

always @ (posedge clk or negedge rst_n)
    if(~rst_n)
        rd_ack <=  0;
    else if(fifo_clr)
        rd_ack <=  0;
    else
        rd_ack <=  (~rd_req_n) & (~rempty);

always @ (posedge clk or negedge rst_n)
    if(~rst_n)
        overflow <=  0;
    else if(fifo_clr)
        overflow <=  0;
    else
        overflow <=  (~wr_req_n) & wfull;

always @ (posedge clk or negedge rst_n)
    if(~rst_n)
        underflow <=  0;
    else if(fifo_clr)
        underflow <=  0;
    else
        underflow <=  (~rd_req_n) & rempty;

endmodule


//******************************************************************************
//company  :   Capital-Micro
//date     :   20130320
//function :   Software model for calibration io
//******************************************************************************
module M7S_IO_CAL (
	id_q_1,
	id_q_0,
	NDR_out,
	PDR_out,
	TPD_out,
	TPU_out,
	clk_en_1,
	clk_en_0,
	clkpol_0,
	clkpol_1,
	dqsr90_0,
	dqsr90_1,
	gsclk270_in,
	gsclk180_in,
	gsclk90_in,
	gsclk_in,
	od_d_1,
	od_d_0,
	oen_1,
	oen_0,
	clk_0,
	clk_1,
	rstn_0,
	rstn_1,
	setn_0,
	setn_1,
	cal_done,
	cal_start,
	PAD1,
	PAD0
);
parameter    cfg_nc                = 1'b0 ;
parameter    cfg_use_cal1_1        = 1'b0 ;
parameter    cfg_use_cal1_0        = 1'b0 ;
parameter    para_ref              = 3'b000 ;
parameter    seri_ref              = 3'b000 ;
parameter    manual_en             = 1'b0 ;
parameter    vref_en               = 1'b0 ;
//parameter    cfg_rclk0_sel         = 2'b00 ;
//parameter    cfg_rclk1_sel         = 2'b00 ;
//parameter    cfg_rclk2_sel         = 2'b00 ;
//parameter    cfg_rclk3_sel         = 2'b00 ;
//parameter    cfg_rclk4_sel         = 2'b00 ;
//parameter    cfg_rclk5_sel         = 2'b00 ;
parameter    vref_sel              = 1'b0 ;

parameter    odt_cfg_1             = 1'b0 ;
parameter    ns_lv_cfg_1           = 2'b00 ;
parameter    pdr_cfg_1             = 5'b00000 ;
parameter    ndr_cfg_1             = 5'b00000 ;
parameter    keep_cfg_1            = 2'b00 ;
parameter    term_pu_en_1          = 1'b0 ;
parameter    term_pd_en_1          = 1'b0 ;
parameter    rx_dig_en_cfg_1       = 1'b0 ;
parameter    rx_hstl_sstl_en_cfg_1 = 1'b0 ;
parameter    tpd_cfg_1             = 8'b00000000 ;
parameter    tpu_cfg_1             = 8'b00000000 ;
parameter    cfg_trm_1             = 3'b000 ;
parameter    cfg_trm_sel_1         = 1'b0 ;
parameter    in_del_1              = 4'b0000 ;
parameter    out_del_1             = 4'b0000 ;
parameter    ns_lv_fastestn_1      = 1'b0 ;
parameter    cfg_userio_en_1       = 1'b0 ;
parameter    cfg_use_cal0_1        = 1'b0 ;
//parameter    cfg_fclk_sel_1        = 2'b00 ;
//parameter    cfg_rstn_sel_1        = 2'b00 ;
//parameter    cfg_setn_sel_1        = 2'b00 ;
parameter    cfg_fclk_inv_1        = 1'b0 ;
parameter    cfg_gsclk_inv_1       = 1'b0 ;
parameter    cfg_gsclk90_inv_1     = 1'b0 ;
parameter    cfg_gsclk180_inv_1    = 1'b0 ;
parameter    cfg_gsclk270_inv_1    = 1'b0 ;
parameter    cfg_fclk_gate_sel_1   = 1'b0 ;
parameter    cfg_sclk_gate_sel_1   = 1'b0 ;
parameter    cfg_sclk_en_1         = 1'b0 ;
parameter    cfg_fclk_en_1         = 1'b0 ;
parameter    cfg_rstn_inv_1        = 1'b0 ;
parameter    cfg_oen_rstn_en_1     = 1'b0 ;
parameter    cfg_od_rstn_en_1      = 1'b0 ;
parameter    cfg_id_rstn_en_1      = 1'b0 ;
parameter    cfg_setn_inv_1        = 1'b0 ;
parameter    cfg_oen_setn_en_1     = 1'b0 ;
parameter    cfg_od_setn_en_1      = 1'b0 ;
parameter    cfg_id_setn_en_1      = 1'b0 ;
parameter    cfg_ddr_1             = 1'b0 ;
parameter    cfg_id_sel_1          = 1'b0 ;
parameter    cfg_oen_inv_1         = 1'b0 ;
parameter    cfg_oen_sel_1         = 2'b00 ;
parameter    cfg_dqs_1             = 1'b0 ;
parameter    cfg_txd0_inv_1        = 1'b0 ;
parameter    cfg_txd1_inv_1        = 1'b0 ;
parameter    cfg_d_en_1            = 1'b0 ;
parameter    cfg_clkout_sel_1      = 1'b0 ;
parameter    cfg_sclk_out_1        = 1'b0 ;
parameter    cfg_od_sel_1          = 2'b00 ;

parameter    odt_cfg_0             = 1'b0 ;
parameter    ns_lv_cfg_0           = 2'b00 ;
parameter    pdr_cfg_0             = 5'b00000 ;
parameter    ndr_cfg_0             = 5'b00000 ;
parameter    keep_cfg_0            = 2'b00 ;
parameter    term_pu_en_0          = 1'b0 ;
parameter    term_pd_en_0          = 1'b0 ;
parameter    rx_dig_en_cfg_0       = 1'b0 ;
parameter    rx_hstl_sstl_en_cfg_0 = 1'b0 ;
parameter    tpd_cfg_0             = 8'b00000000 ;
parameter    tpu_cfg_0             = 8'b00000000 ;
parameter    cfg_trm_0             = 3'b000 ;
parameter    cfg_trm_sel_0         = 1'b0 ;
parameter    in_del_0              = 4'b0000 ;
parameter    out_del_0             = 4'b0000 ;
parameter    ns_lv_fastestn_0      = 1'b0 ;
parameter    cfg_userio_en_0       = 1'b0 ;
parameter    cfg_use_cal0_0        = 1'b0 ;
//parameter    cfg_fclk_sel_0        = 2'b00 ;
//parameter    cfg_rstn_sel_0        = 2'b00 ;
//parameter    cfg_setn_sel_0        = 2'b00 ;
parameter    cfg_fclk_inv_0        = 1'b0 ;
parameter    cfg_gsclk_inv_0       = 1'b0 ;
parameter    cfg_gsclk90_inv_0     = 1'b0 ;
parameter    cfg_gsclk180_inv_0    = 1'b0 ;
parameter    cfg_gsclk270_inv_0    = 1'b0 ;
parameter    cfg_fclk_gate_sel_0   = 1'b0 ;
parameter    cfg_sclk_gate_sel_0   = 1'b0 ;
parameter    cfg_sclk_en_0         = 1'b0 ;
parameter    cfg_fclk_en_0         = 1'b0 ;
parameter    cfg_rstn_inv_0        = 1'b0 ;
parameter    cfg_oen_rstn_en_0     = 1'b0 ;
parameter    cfg_od_rstn_en_0      = 1'b0 ;
parameter    cfg_id_rstn_en_0      = 1'b0 ;
parameter    cfg_setn_inv_0        = 1'b0 ;
parameter    cfg_oen_setn_en_0     = 1'b0 ;
parameter    cfg_od_setn_en_0      = 1'b0 ;
parameter    cfg_id_setn_en_0      = 1'b0 ;
parameter    cfg_ddr_0             = 1'b0 ;
parameter    cfg_id_sel_0          = 1'b0 ;
parameter    cfg_oen_inv_0         = 1'b0 ;
parameter    cfg_oen_sel_0         = 2'b00 ;
parameter    cfg_dqs_0             = 1'b0 ;
parameter    cfg_txd0_inv_0        = 1'b0 ;
parameter    cfg_txd1_inv_0        = 1'b0 ;
parameter    cfg_d_en_0            = 1'b0 ;
parameter    cfg_clkout_sel_0      = 1'b0 ;
parameter    cfg_sclk_out_0        = 1'b0 ;
parameter    cfg_od_sel_0          = 2'b00 ;

parameter    optional_function       = "";

output	[1:0]	id_q_1;
output	[1:0]	id_q_0;
output	[4:0]	NDR_out;
output	[4:0]	PDR_out;
output	[7:0]	TPD_out;
output	[7:0]	TPU_out;
output		cal_done;
input		clk_en_1;
input		clk_en_0;
input		clkpol_0;
input		clkpol_1;
input		dqsr90_0;
input		dqsr90_1;
input		gsclk270_in;
input		gsclk180_in;
input		gsclk90_in;
input		gsclk_in;
input	[1:0]	od_d_1;
input	[1:0]	od_d_0;
input		oen_1;
input		oen_0;
input		clk_0;
input		clk_1;
input		rstn_0;
input		rstn_1;
input		setn_0;
input		setn_1;
input		cal_start;
inout		PAD1;
inout		PAD0;
//---------------------------------------------------------------------------------
// For basic IO function
//---------------------------------------------------------------------------------
	wire clk_n_0;
	wire clk_ng_0;
	wire i_clk_0;
	wire i_rstn_0;
	wire i_setn_0;
	wire i_oen_0;
	wire i_od_0;
	wire i_od_n_0;
	wire i_id_0;
	
	reg id_reg_0;
    reg od_reg_0;
    reg oen_reg_0;

    wire    id_rstn_0;
    wire    id_setn_0;
    wire    od_rstn_0;
    wire    od_setn_0;
    wire    oen_setn_0;
    wire    oen_rstn_0;

    wire    out_en_0;
    wire    out_data_0;

	wire clk_n_1;
	wire clk_ng_1;
	wire i_clk_1;
	wire i_rstn_1;
	wire i_setn_1;
	wire i_oen_1;
	wire i_od_1;
	wire i_od_n_1;
	wire i_id_1;
	
	reg id_reg_1;
    reg od_reg_1;
    reg oen_reg_1;

    wire    id_rstn_1;
    wire    id_setn_1;
    wire    od_rstn_1;
    wire    od_setn_1;
    wire    oen_setn_1;
    wire    oen_rstn_1;

    wire    out_en_1;
    wire    out_data_1;
//---------------------------------------------------------------------------------
//basic setting 0
//---------------------------------------------------------------------------------
	assign clk_n_0    = (cfg_fclk_inv_0 == "true" || cfg_fclk_inv_0 == 1'b1) ? ~clk_0 : clk_0;
	assign clk_ng_0   = (cfg_fclk_gate_sel_0 == "true" || cfg_fclk_gate_sel_0 == 1) ? clk_n_0 : clk_n_0 & clk_en_0 ;
	assign i_clk_0    = (cfg_fclk_en_0 == "true" || cfg_fclk_en_0 == 1) ? clk_ng_0 : 1'b0 ;

	assign i_oen_0    = (cfg_oen_inv_0 == "true"  || cfg_oen_inv_0 ==1'b1) ? ~oen_0 : oen_0;   	
	assign i_od_n_0   = (cfg_d_en_0  == "true" || cfg_d_en_0 == 1'b1) ? od_d_0[0]  : 1'b0;   	
	assign i_od_0     = (cfg_txd0_inv_0  == "true" || cfg_txd0_inv_0 == 1'b1) ? ~i_od_n_0  : i_od_n_0;   	
	assign i_id_0     = (rx_dig_en_cfg_0 == "true" || rx_dig_en_cfg_0 == 1'b1) ? PAD0 : 1'bz;

	assign i_rstn_0   = (cfg_rstn_inv_0 == "true" || cfg_rstn_inv_0 == 1'b1) ? ~rstn_0 : rstn_0;   	
	assign i_setn_0   = (cfg_setn_inv_0 == "true" || cfg_setn_inv_0 == 1'b1) ? ~setn_0 : setn_0;   	

    assign id_rstn_0  = (cfg_id_rstn_en_0 == "true" || cfg_id_rstn_en_0 == 1'b1) ? i_rstn_0 : 1'b1;
    assign id_setn_0  = (cfg_id_setn_en_0 == "true" || cfg_id_setn_en_0 == 1'b1) ? i_setn_0 : 1'b1;

    assign od_rstn_0  = (cfg_od_rstn_en_0 == "true" || cfg_od_rstn_en_0 == 1'b1) ? i_rstn_0 : 1'b1;
    assign od_setn_0  = (cfg_od_setn_en_0 == "true" || cfg_od_setn_en_0 == 1'b1) ? i_setn_0 : 1'b1;

    assign oen_rstn_0  = (cfg_oen_rstn_en_0 == "true" || cfg_oen_rstn_en_0 == 1'b1) ? i_rstn_0 : 1'b1;
    assign oen_setn_0  = (cfg_oen_setn_en_0 == "true" || cfg_oen_setn_en_0 == 1'b1) ? i_setn_0 : 1'b1;

//---------------------------------------------------------------------------------
//id/od/oen reg 0
//---------------------------------------------------------------------------------
    always @ (posedge i_clk_0 or negedge id_rstn_0 or negedge id_setn_0) begin
        if(~id_rstn_0)            id_reg_0 <= 0;
        else if(~id_setn_0)       id_reg_0 <= 1;
        else                      id_reg_0 <= i_id_0;
    end
	
    always @ (posedge i_clk_0 or negedge od_rstn_0 or negedge od_setn_0) begin
        if(~od_rstn_0)        od_reg_0 <= 0;
        else if(~od_setn_0)   od_reg_0 <= 1;
        else                  od_reg_0 <= i_od_0;
    end

    always @ (posedge i_clk_0 or negedge oen_rstn_0 or negedge oen_setn_0) begin
        if(~oen_rstn_0)        oen_reg_0 <= 0;
        else if(~oen_setn_0)   oen_reg_0 <= 1;
        else                   oen_reg_0 <= i_oen_0;
    end
	

//---------------------------------------------------------------------------------
//input, oen, output generation 0
//---------------------------------------------------------------------------------
	assign id_q_0[0]     = (cfg_id_sel_0 == "register" || cfg_id_sel_0 == 1'b1) ? id_reg_0 : i_id_0;
	
	assign out_en_0 = (cfg_oen_sel_0 == "register" || cfg_oen_sel_0 == 2'b11) ? oen_reg_0 :
                      (cfg_oen_sel_0 == "bypass"   || cfg_oen_sel_0 == 2'b10) ? i_oen_0   :
                      (cfg_oen_sel_0 == "gnd"      || cfg_oen_sel_0 == 2'b01) ? 1'b0      :
                      (cfg_oen_sel_0 == "vcc"      || cfg_oen_sel_0 == 2'b00) ? 1'b1      : 1'bx;
									
    assign out_data_0 = (cfg_od_sel_0 == "register" || cfg_od_sel_0 == 2'b11) ? od_reg_0 :
                        (cfg_od_sel_0 == "bypass"   || cfg_od_sel_0 == 2'b10) ? i_od_0   :
                        (cfg_od_sel_0 == "gnd"      || cfg_od_sel_0 == 2'b00) ? 1'b0     :
                        (cfg_od_sel_0 == "vcc"      || cfg_od_sel_0 == 2'b01) ? 1'b1     : 1'bx;

    assign PAD0 = ~out_en_0 ? out_data_0 : 1'bz;

//---------------------------------------------------------------------------------
//basic setting 1
//---------------------------------------------------------------------------------
	assign clk_n_1    = (cfg_fclk_inv_1 == "true" || cfg_fclk_inv_1 == 1'b1) ? ~clk_1 : clk_1;
	assign clk_ng_1   = (cfg_fclk_gate_sel_1 == "true" || cfg_fclk_gate_sel_1 == 1) ? clk_n_1 : clk_n_1 & clk_en_1 ;
	assign i_clk_1    = (cfg_fclk_en_1 == "true" || cfg_fclk_en_1 == 1) ? clk_ng_1 : 1'b0 ;

	assign i_oen_1    = (cfg_oen_inv_1 == "true"  || cfg_oen_inv_1 ==1'b1) ? ~oen_1 : oen_1;   	
	assign i_od_n_1   = (cfg_d_en_1  == "true" || cfg_d_en_1 == 1'b1) ? od_d_1[0]  : 1'b0;   	
	assign i_od_1     = (cfg_txd0_inv_1  == "true" || cfg_txd0_inv_1 == 1'b1) ? ~i_od_n_1  : i_od_n_1;   	
	assign i_id_1     = (rx_dig_en_cfg_1 == "true" || rx_dig_en_cfg_1 == 1'b1) ? PAD1 : 1'bz;

	assign i_rstn_1   = (cfg_rstn_inv_1 == "true" || cfg_rstn_inv_1 == 1'b1) ? ~rstn_1 : rstn_1;   	
	assign i_setn_1   = (cfg_setn_inv_1 == "true" || cfg_setn_inv_1 == 1'b1) ? ~setn_1 : setn_1;   	

    assign id_rstn_1  = (cfg_id_rstn_en_1 == "true" || cfg_id_rstn_en_1 == 1'b1) ? i_rstn_1 : 1'b1;
    assign id_setn_1  = (cfg_id_setn_en_1 == "true" || cfg_id_setn_en_1 == 1'b1) ? i_setn_1 : 1'b1;

    assign od_rstn_1  = (cfg_od_rstn_en_1 == "true" || cfg_od_rstn_en_1 == 1'b1) ? i_rstn_1 : 1'b1;
    assign od_setn_1  = (cfg_od_setn_en_1 == "true" || cfg_od_setn_en_1 == 1'b1) ? i_setn_1 : 1'b1;

    assign oen_rstn_1  = (cfg_oen_rstn_en_1 == "true" || cfg_oen_rstn_en_1 == 1'b1) ? i_rstn_1 : 1'b1;
    assign oen_setn_1  = (cfg_oen_setn_en_1 == "true" || cfg_oen_setn_en_1 == 1'b1) ? i_setn_1 : 1'b1;

//---------------------------------------------------------------------------------
//id/od/oen reg 1
//---------------------------------------------------------------------------------
    always @ (posedge i_clk_1 or negedge id_rstn_1 or negedge id_setn_1) begin
        if(~id_rstn_1)            id_reg_1 <= 0;
        else if(~id_setn_1)       id_reg_1 <= 1;
        else                      id_reg_1 <= i_id_1;
    end
	
    always @ (posedge i_clk_1 or negedge od_rstn_1 or negedge od_setn_1) begin
        if(~od_rstn_1)        od_reg_1 <= 0;
        else if(~od_setn_1)   od_reg_1 <= 1;
        else                  od_reg_1 <= i_od_1;
    end

    always @ (posedge i_clk_1 or negedge oen_rstn_1 or negedge oen_setn_1) begin
        if(~oen_rstn_1)        oen_reg_1 <= 0;
        else if(~oen_setn_1)   oen_reg_1 <= 1;
        else                   oen_reg_1 <= i_oen_1;
    end
	

//---------------------------------------------------------------------------------
//input, oen, output generation 1
//---------------------------------------------------------------------------------
	assign id_q_1[0]     = (cfg_id_sel_1 == "register" || cfg_id_sel_1 == 1'b1) ? id_reg_1 : i_id_1;
	
	assign out_en_1 = (cfg_oen_sel_1 == "register" || cfg_oen_sel_1 == 2'b11) ? oen_reg_1 :
                      (cfg_oen_sel_1 == "bypass"   || cfg_oen_sel_1 == 2'b10) ? i_oen_1   :
                      (cfg_oen_sel_1 == "gnd"      || cfg_oen_sel_1 == 2'b01) ? 1'b0      :
                      (cfg_oen_sel_1 == "vcc"      || cfg_oen_sel_1 == 2'b00) ? 1'b1      : 1'bx;
									
    assign out_data_1 = (cfg_od_sel_1 == "register" || cfg_od_sel_1 == 2'b11) ? od_reg_1 :
                        (cfg_od_sel_1 == "bypass"   || cfg_od_sel_1 == 2'b10) ? i_od_1   :
                        (cfg_od_sel_1 == "gnd"      || cfg_od_sel_1 == 2'b00) ? 1'b0     :
                        (cfg_od_sel_1 == "vcc"      || cfg_od_sel_1 == 2'b01) ? 1'b1     : 1'bx;

    assign PAD1 = ~out_en_1 ? out_data_1 : 1'bz;

endmodule
//******************************************************************************
//company  :   Capital-Micro
//date     :   20130320
//function :   Software model for ddrsg io
//******************************************************************************
module  M7A_IO_DDRSG(
	id_q,
	NDR_in,
	PDR_in,
	TPD_in,
	TPU_in,
	clk_en,
	clkpol,
	dqsr90,
	gsclk270_in,
	gsclk180_in,
	gsclk90_in,
	gsclk_in,
	od_d,
	oen,
	clk,
	rstn,
	setn,
	PAD
);
parameter    cfg_nc               = 1'b0 ;
parameter    cfg_use_cal1         = 1'b0 ;
//parameter    cfg_rclk0_sel         = 2'b00 ;
//parameter    cfg_rclk1_sel         = 2'b00 ;
//parameter    cfg_rclk2_sel         = 2'b00 ;
//parameter    cfg_rclk3_sel         = 2'b00 ;
//parameter    cfg_rclk4_sel         = 2'b00 ;
//parameter    cfg_rclk5_sel         = 2'b00 ;
parameter    odt_cfg               = 1'b0 ;
parameter    ns_lv_cfg             = 2'b00 ;
parameter    pdr_cfg               = 5'b00000 ;
parameter    ndr_cfg               = 5'b00000 ;
parameter    keep_cfg              = 2'b00 ;
parameter    term_pu_en            = 1'b0 ;
parameter    term_pd_en            = 1'b0 ;
parameter    rx_dig_en_cfg         = 1'b0 ;
parameter    rx_hstl_sstl_en_cfg   = 1'b0 ;
parameter    tpd_cfg               = 8'b00000000 ;
parameter    tpu_cfg               = 8'b00000000 ;
parameter    cfg_trm               = 3'b000 ;
parameter    cfg_trm_sel           = 1'b0 ;
parameter    in_del                = 4'b0000 ;
parameter    out_del               = 4'b0000 ;
parameter    cfg_test_en           = 1'b0 ;
parameter    cfg_userio_en         = 1'b0 ;
parameter    cfg_use_cal0          = 1'b0 ;
//parameter    cfg_fclk_sel          = 2'b00 ;
//parameter    cfg_rstn_sel          = 2'b00 ;
//parameter    cfg_setn_sel          = 2'b00 ;
parameter    cfg_fclk_inv          = 1'b0 ;
parameter    cfg_gsclk_inv         = 1'b0 ;
parameter    cfg_gsclk90_inv       = 1'b0 ;
parameter    cfg_gsclk180_inv      = 1'b0 ;
parameter    cfg_gsclk270_inv      = 1'b0 ;
parameter    cfg_fclk_gate_sel     = 1'b0 ;
parameter    cfg_sclk_gate_sel     = 1'b0 ;
parameter    cfg_sclk_en           = 1'b0 ;
parameter    cfg_fclk_en           = 1'b0 ;
parameter    cfg_rstn_inv          = 1'b0 ;
parameter    cfg_oen_rstn_en       = 1'b0 ;
parameter    cfg_od_rstn_en        = 1'b0 ;
parameter    cfg_id_rstn_en        = 1'b0 ;
parameter    cfg_setn_inv          = 1'b0 ;
parameter    cfg_oen_setn_en       = 1'b0 ;
parameter    cfg_od_setn_en        = 1'b0 ;
parameter    cfg_id_setn_en        = 1'b0 ;
parameter    cfg_ddr               = 1'b0 ;
parameter    cfg_id_sel            = 1'b0 ;
parameter    cfg_oen_inv           = 1'b0 ;
parameter    cfg_oen_sel           = 2'b00 ;
parameter    cfg_dqs               = 1'b0 ;
parameter    cfg_txd0_inv          = 1'b0 ;
parameter    cfg_txd1_inv          = 1'b0 ;
parameter    cfg_d_en              = 1'b0 ;
parameter    cfg_clkout_sel        = 1'b0 ;
parameter    cfg_sclk_out          = 1'b0 ;
parameter    cfg_od_sel            = 2'b00 ;

output	[1:0]	id_q;
input	[4:0]	NDR_in;
input	[4:0]	PDR_in;
input	[7:0]	TPD_in;
input	[7:0]	TPU_in;
input		clk_en;
input		clkpol;
input		dqsr90;
input		gsclk270_in;
input		gsclk180_in;
input		gsclk90_in;
input		gsclk_in;
input	[1:0]	od_d;
input		oen;
input		clk;
input		setn;
input		rstn;
inout		PAD;
//---------------------------------------------------------------------------------
// For basic IO function
//---------------------------------------------------------------------------------
	wire clk_n;
	wire clk_ng;
	wire i_clk;
	wire i_rstn;
	wire i_setn;
	wire i_oen;
	wire i_od;
	wire i_id;
	
	reg id_reg;
    reg od_reg;
    reg oen_reg;

    wire    id_rstn;
    wire    id_setn;
    wire    od_rstn;
    wire    od_setn;
    wire    oen_setn;
    wire    oen_rstn;

    wire    out_en;
    wire    out_data;

	
//---------------------------------------------------------------------------------
//basic setting
//---------------------------------------------------------------------------------
	assign clk_n    = (cfg_fclk_inv == "true" || cfg_fclk_inv == 1'b1) ? ~clk : clk;
	assign clk_ng   = (cfg_fclk_gate_sel == "true" || cfg_fclk_gate_sel == 1) ? clk_n : clk_n & clk_en ;
	assign i_clk    = (cfg_fclk_en == "true" || cfg_fclk_en == 1) ? clk_ng : 1'b0 ;

	assign i_oen    = (cfg_oen_inv == "true"  || cfg_oen_inv ==1'b1) ? ~oen : oen;   	
	assign i_od     = (cfg_txd0_inv  == "true"  || cfg_txd0_inv ==1'b1)  ? ~od_d[0]  : od_d[0];   	
	assign i_id     = (rx_dig_en_cfg == "true"|| rx_dig_en_cfg == 1'b1) ? PAD : 1'bz;

	assign i_rstn   = (cfg_rstn_inv == "true" || cfg_rstn_inv == 1'b1) ? ~rstn : rstn;   	
	assign i_setn   = (cfg_setn_inv == "true" || cfg_setn_inv == 1'b1) ? ~setn : setn;   	

    assign id_rstn  = (cfg_id_rstn_en == "true" || cfg_id_rstn_en == 1'b1) ? i_rstn : 1'b1;
    assign id_setn  = (cfg_id_setn_en == "true" || cfg_id_setn_en == 1'b1) ? i_setn : 1'b1;

    assign od_rstn  = (cfg_od_rstn_en == "true" || cfg_od_rstn_en == 1'b1) ? i_rstn : 1'b1;
    assign od_setn  = (cfg_od_setn_en == "true" || cfg_od_setn_en == 1'b1) ? i_setn : 1'b1;

    assign oen_rstn  = (cfg_oen_rstn_en == "true" || cfg_oen_rstn_en == 1'b1) ? i_rstn : 1'b1;
    assign oen_setn  = (cfg_oen_setn_en == "true" || cfg_oen_setn_en == 1'b1) ? i_setn : 1'b1;

//---------------------------------------------------------------------------------
//id/od/oen reg
//---------------------------------------------------------------------------------
    always @ (posedge i_clk or negedge id_rstn or negedge id_setn) begin
        if(~id_rstn)            id_reg <= 0;
        else if(~id_setn)       id_reg <= 1;
        else                    id_reg <= i_id;
    end
	
    always @ (posedge i_clk or negedge od_rstn or negedge od_setn) begin
        if(~od_rstn)        od_reg <= 0;
        else if(~od_setn)   od_reg <= 1;
        else                od_reg <= i_od;
    end

    always @ (posedge i_clk or negedge oen_rstn or negedge oen_setn) begin
        if(~oen_rstn)        oen_reg <= 0;
        else if(~oen_setn)   oen_reg <= 1;
        else                 oen_reg <= i_oen;
    end
	

//---------------------------------------------------------------------------------
//input, oen, output generation
//---------------------------------------------------------------------------------
	assign id_q[1]     = (cfg_id_sel == "register" || cfg_id_sel == 1'b1) ? id_reg : i_id;
	
	assign out_en = (cfg_oen_sel == "register" || cfg_oen_sel == 2'b11) ? oen_reg :
                    (cfg_oen_sel == "bypass"   || cfg_oen_sel == 2'b10) ? i_oen   :
                    (cfg_oen_sel == "gnd"      || cfg_oen_sel == 2'b01) ? 1'b0    :
                    (cfg_oen_sel == "vcc"      || cfg_oen_sel == 2'b00) ? 1'b1    : 1'bx;
									
    assign out_data = (cfg_od_sel == "register" || cfg_od_sel == 2'b11) ? od_reg :
                      (cfg_od_sel == "bypass"   || cfg_od_sel == 2'b10) ? i_od   :
                      (cfg_od_sel == "gnd"      || cfg_od_sel == 2'b00) ? 1'b0   :
                      (cfg_od_sel == "vcc"      || cfg_od_sel == 2'b01) ? 1'b1   : 1'bx;

    assign PAD = ~out_en ? out_data : 1'bz;

endmodule
//******************************************************************************
//company  :   Capital-Micro
//date     :   20130320
//function :   Software model for ddr io
//******************************************************************************
module M7S_IO_DDR (
	id_q_1,
	id_q_0,
	NDR_in,
	PDR_in,
	TPD_in,
	TPU_in,
	clk_0,
	clk_1,
	clk_en_1,
	clk_en_0,
	clkpol_0,
	clkpol_1,
	dqsr90_0,
	dqsr90_1,
	gsclk270_in,
	gsclk180_in,
	gsclk90_in,
	gsclk_in,
	od_d_1,
	od_d_0,
	oen_1,
	oen_0,
	rstn_0,
	rstn_1,
	setn_0,
	setn_1,

	PAD1,
	PAD0
);
parameter    cfg_nc                = 1'b0 ;
parameter    cfg_use_cal1_1        = 1'b0 ;
parameter    cfg_use_cal1_0        = 1'b0 ;
parameter    para_ref              = 3'b000 ;
parameter    seri_ref              = 3'b000 ;
parameter    manual_en             = 1'b0 ;
parameter    vref_en               = 1'b0 ;
//parameter    cfg_rclk0_sel         = 2'b00 ;
//parameter    cfg_rclk1_sel         = 2'b00 ;
//parameter    cfg_rclk2_sel         = 2'b00 ;
//parameter    cfg_rclk3_sel         = 2'b00 ;
//parameter    cfg_rclk4_sel         = 2'b00 ;
//parameter    cfg_rclk5_sel         = 2'b00 ;
parameter    vref_sel              = 1'b0 ;

parameter    odt_cfg_1             = 1'b0 ;
parameter    ns_lv_cfg_1           = 2'b00 ;
parameter    pdr_cfg_1             = 5'b00000 ;
parameter    ndr_cfg_1             = 5'b00000 ;
parameter    keep_cfg_1            = 2'b00 ;
parameter    term_pu_en_1          = 1'b0 ;
parameter    term_pd_en_1          = 1'b0 ;
parameter    rx_dig_en_cfg_1       = 1'b0 ;
parameter    rx_hstl_sstl_en_cfg_1 = 1'b0 ;
parameter    tpd_cfg_1             = 8'b00000000 ;
parameter    tpu_cfg_1             = 8'b00000000 ;
parameter    cfg_trm_1             = 3'b000 ;
parameter    cfg_trm_sel_1         = 1'b0 ;
parameter    in_del_1              = 4'b0000 ;
parameter    out_del_1             = 4'b0000 ;
parameter    ns_lv_fastestn_1      = 1'b0 ;
parameter    cfg_userio_en_1       = 1'b0 ;
parameter    cfg_use_cal0_1        = 1'b0 ;
//parameter    cfg_fclk_sel_1        = 2'b00 ;
//parameter    cfg_rstn_sel_1        = 2'b00 ;
//parameter    cfg_setn_sel_1        = 2'b00 ;
parameter    cfg_fclk_inv_1        = 1'b0 ;
parameter    cfg_gsclk_inv_1       = 1'b0 ;
parameter    cfg_gsclk90_inv_1     = 1'b0 ;
parameter    cfg_gsclk180_inv_1    = 1'b0 ;
parameter    cfg_gsclk270_inv_1    = 1'b0 ;
parameter    cfg_fclk_gate_sel_1   = 1'b0 ;
parameter    cfg_sclk_gate_sel_1   = 1'b0 ;
parameter    cfg_sclk_en_1         = 1'b0 ;
parameter    cfg_fclk_en_1         = 1'b0 ;
parameter    cfg_rstn_inv_1        = 1'b0 ;
parameter    cfg_oen_rstn_en_1     = 1'b0 ;
parameter    cfg_od_rstn_en_1      = 1'b0 ;
parameter    cfg_id_rstn_en_1      = 1'b0 ;
parameter    cfg_setn_inv_1        = 1'b0 ;
parameter    cfg_oen_setn_en_1     = 1'b0 ;
parameter    cfg_od_setn_en_1      = 1'b0 ;
parameter    cfg_id_setn_en_1      = 1'b0 ;
parameter    cfg_ddr_1             = 1'b0 ;
parameter    cfg_id_sel_1          = 1'b0 ;
parameter    cfg_oen_inv_1         = 1'b0 ;
parameter    cfg_oen_sel_1         = 2'b00 ;
parameter    cfg_dqs_1             = 1'b0 ;
parameter    cfg_txd0_inv_1        = 1'b0 ;
parameter    cfg_txd1_inv_1        = 1'b0 ;
parameter    cfg_d_en_1            = 1'b0 ;
parameter    cfg_clkout_sel_1      = 1'b0 ;
parameter    cfg_sclk_out_1        = 1'b0 ;
parameter    cfg_od_sel_1          = 2'b00 ;

parameter    odt_cfg_0             = 1'b0 ;
parameter    ns_lv_cfg_0           = 2'b00 ;
parameter    pdr_cfg_0             = 5'b00000 ;
parameter    ndr_cfg_0             = 5'b00000 ;
parameter    keep_cfg_0            = 2'b00 ;
parameter    term_pu_en_0          = 1'b0 ;
parameter    term_pd_en_0          = 1'b0 ;
parameter    rx_dig_en_cfg_0       = 1'b0 ;
parameter    rx_hstl_sstl_en_cfg_0 = 1'b0 ;
parameter    tpd_cfg_0             = 8'b00000000 ;
parameter    tpu_cfg_0             = 8'b00000000 ;
parameter    cfg_trm_0             = 3'b000 ;
parameter    cfg_trm_sel_0         = 1'b0 ;
parameter    in_del_0              = 4'b0000 ;
parameter    out_del_0             = 4'b0000 ;
parameter    ns_lv_fastestn_0      = 1'b0 ;
parameter    cfg_userio_en_0       = 1'b0 ;
parameter    cfg_use_cal0_0        = 1'b0 ;
//parameter    cfg_fclk_sel_0        = 2'b00 ;
//parameter    cfg_rstn_sel_0        = 2'b00 ;
//parameter    cfg_setn_sel_0        = 2'b00 ;
parameter    cfg_fclk_inv_0        = 1'b0 ;
parameter    cfg_gsclk_inv_0       = 1'b0 ;
parameter    cfg_gsclk90_inv_0     = 1'b0 ;
parameter    cfg_gsclk180_inv_0    = 1'b0 ;
parameter    cfg_gsclk270_inv_0    = 1'b0 ;
parameter    cfg_fclk_gate_sel_0   = 1'b0 ;
parameter    cfg_sclk_gate_sel_0   = 1'b0 ;
parameter    cfg_sclk_en_0         = 1'b0 ;
parameter    cfg_fclk_en_0         = 1'b0 ;
parameter    cfg_rstn_inv_0        = 1'b0 ;
parameter    cfg_oen_rstn_en_0     = 1'b0 ;
parameter    cfg_od_rstn_en_0      = 1'b0 ;
parameter    cfg_id_rstn_en_0      = 1'b0 ;
parameter    cfg_setn_inv_0        = 1'b0 ;
parameter    cfg_oen_setn_en_0     = 1'b0 ;
parameter    cfg_od_setn_en_0      = 1'b0 ;
parameter    cfg_id_setn_en_0      = 1'b0 ;
parameter    cfg_ddr_0             = 1'b0 ;
parameter    cfg_id_sel_0          = 1'b0 ;
parameter    cfg_oen_inv_0         = 1'b0 ;
parameter    cfg_oen_sel_0         = 2'b00 ;
parameter    cfg_dqs_0             = 1'b0 ;
parameter    cfg_txd0_inv_0        = 1'b0 ;
parameter    cfg_txd1_inv_0        = 1'b0 ;
parameter    cfg_d_en_0            = 1'b0 ;
parameter    cfg_clkout_sel_0      = 1'b0 ;
parameter    cfg_sclk_out_0        = 1'b0 ;
parameter    cfg_od_sel_0          = 2'b00 ;

parameter    optional_function       = "";

output	[1:0]	id_q_1;
output	[1:0]	id_q_0;
input	[4:0]	NDR_in;
input	[4:0]	PDR_in;
input	[7:0]	TPD_in;
input	[7:0]	TPU_in;
input		clk_en_1;
input		clk_en_0;
input		clkpol_0;
input		clkpol_1;
input		dqsr90_0;
input		dqsr90_1;
input		gsclk270_in;
input		gsclk180_in;
input		gsclk90_in;
input		gsclk_in;
input	[1:0]	od_d_1;
input	[1:0]	od_d_0;
input		oen_1;
input		oen_0;
input		clk_0;
input		clk_1;
input		rstn_0;
input		rstn_1;
input		setn_0;
input		setn_1;
inout		PAD1;
inout		PAD0;

//---------------------------------------------------------------------------------
// For basic IO function
//---------------------------------------------------------------------------------
	wire clk_n_0;
	wire clk_ng_0;
	wire i_clk_0;
	wire i_rstn_0;
	wire i_setn_0;
	wire i_oen_0;
	wire i_od_0;
	wire i_od_n_0;
	wire i_id_0;
	
	reg id_reg_0;
    reg od_reg_0;
    reg oen_reg_0;

    wire    id_rstn_0;
    wire    id_setn_0;
    wire    od_rstn_0;
    wire    od_setn_0;
    wire    oen_setn_0;
    wire    oen_rstn_0;

    wire    out_en_0;
    wire    out_data_0;

	wire clk_n_1;
	wire clk_ng_1;
	wire i_clk_1;
	wire i_rstn_1;
	wire i_setn_1;
	wire i_oen_1;
	wire i_od_1;
	wire i_od_n_1;
	wire i_id_1;
	
	reg id_reg_1;
    reg od_reg_1;
    reg oen_reg_1;

    wire    id_rstn_1;
    wire    id_setn_1;
    wire    od_rstn_1;
    wire    od_setn_1;
    wire    oen_setn_1;
    wire    oen_rstn_1;

    wire    out_en_1;
    wire    out_data_1;
//---------------------------------------------------------------------------------
//basic setting 0
//---------------------------------------------------------------------------------
	assign clk_n_0    = (cfg_fclk_inv_0 == "true" || cfg_fclk_inv_0 == 1'b1) ? ~clk_0 : clk_0;
	assign clk_ng_0   = (cfg_fclk_gate_sel_0 == "true" || cfg_fclk_gate_sel_0 == 1) ? clk_n_0 : clk_n_0 & clk_en_0 ;
	assign i_clk_0    = (cfg_fclk_en_0 == "true" || cfg_fclk_en_0 == 1) ? clk_ng_0 : 1'b0 ;

	assign i_oen_0    = (cfg_oen_inv_0 == "true"  || cfg_oen_inv_0 ==1'b1) ? ~oen_0 : oen_0;   	
	assign i_od_n_0   = (cfg_d_en_0  == "true" || cfg_d_en_0 == 1'b1) ? od_d_0[0]  : 1'b0;   	
	assign i_od_0     = (cfg_txd0_inv_0  == "true" || cfg_txd0_inv_0 == 1'b1) ? ~i_od_n_0  : i_od_n_0;   	
	assign i_id_0     = (rx_dig_en_cfg_0 == "true" || rx_dig_en_cfg_0 == 1'b1) ? PAD0 : 1'bz;

	assign i_rstn_0   = (cfg_rstn_inv_0 == "true" || cfg_rstn_inv_0 == 1'b1) ? ~rstn_0 : rstn_0;   	
	assign i_setn_0   = (cfg_setn_inv_0 == "true" || cfg_setn_inv_0 == 1'b1) ? ~setn_0 : setn_0;   	

    assign id_rstn_0  = (cfg_id_rstn_en_0 == "true" || cfg_id_rstn_en_0 == 1'b1) ? i_rstn_0 : 1'b1;
    assign id_setn_0  = (cfg_id_setn_en_0 == "true" || cfg_id_setn_en_0 == 1'b1) ? i_setn_0 : 1'b1;

    assign od_rstn_0  = (cfg_od_rstn_en_0 == "true" || cfg_od_rstn_en_0 == 1'b1) ? i_rstn_0 : 1'b1;
    assign od_setn_0  = (cfg_od_setn_en_0 == "true" || cfg_od_setn_en_0 == 1'b1) ? i_setn_0 : 1'b1;

    assign oen_rstn_0  = (cfg_oen_rstn_en_0 == "true" || cfg_oen_rstn_en_0 == 1'b1) ? i_rstn_0 : 1'b1;
    assign oen_setn_0  = (cfg_oen_setn_en_0 == "true" || cfg_oen_setn_en_0 == 1'b1) ? i_setn_0 : 1'b1;

//---------------------------------------------------------------------------------
//id/od/oen reg 0
//---------------------------------------------------------------------------------
    always @ (posedge i_clk_0 or negedge id_rstn_0 or negedge id_setn_0) begin
        if(~id_rstn_0)            id_reg_0 <= 0;
        else if(~id_setn_0)       id_reg_0 <= 1;
        else                      id_reg_0 <= i_id_0;
    end
	
    always @ (posedge i_clk_0 or negedge od_rstn_0 or negedge od_setn_0) begin
        if(~od_rstn_0)        od_reg_0 <= 0;
        else if(~od_setn_0)   od_reg_0 <= 1;
        else                  od_reg_0 <= i_od_0;
    end

    always @ (posedge i_clk_0 or negedge oen_rstn_0 or negedge oen_setn_0) begin
        if(~oen_rstn_0)        oen_reg_0 <= 0;
        else if(~oen_setn_0)   oen_reg_0 <= 1;
        else                   oen_reg_0 <= i_oen_0;
    end
	

//---------------------------------------------------------------------------------
//input, oen, output generation 0
//---------------------------------------------------------------------------------
	assign id_q_0[0]     = (cfg_id_sel_0 == "register" || cfg_id_sel_0 == 1'b1) ? id_reg_0 : i_id_0;
	
	assign out_en_0 = (cfg_oen_sel_0 == "register" || cfg_oen_sel_0 == 2'b11) ? oen_reg_0 :
                      (cfg_oen_sel_0 == "bypass"   || cfg_oen_sel_0 == 2'b10) ? i_oen_0   :
                      (cfg_oen_sel_0 == "gnd"      || cfg_oen_sel_0 == 2'b01) ? 1'b0      :
                      (cfg_oen_sel_0 == "vcc"      || cfg_oen_sel_0 == 2'b00) ? 1'b1      : 1'bx;
									
    assign out_data_0 = (cfg_od_sel_0 == "register" || cfg_od_sel_0 == 2'b11) ? od_reg_0 :
                        (cfg_od_sel_0 == "bypass"   || cfg_od_sel_0 == 2'b10) ? i_od_0   :
                        (cfg_od_sel_0 == "gnd"      || cfg_od_sel_0 == 2'b00) ? 1'b0     :
                        (cfg_od_sel_0 == "vcc"      || cfg_od_sel_0 == 2'b01) ? 1'b1     : 1'bx;

    assign PAD0 = ~out_en_0 ? out_data_0 : 1'bz;

//---------------------------------------------------------------------------------
//basic setting 1
//---------------------------------------------------------------------------------
	assign clk_n_1    = (cfg_fclk_inv_1 == "true" || cfg_fclk_inv_1 == 1'b1) ? ~clk_1 : clk_1;
	assign clk_ng_1   = (cfg_fclk_gate_sel_1 == "true" || cfg_fclk_gate_sel_1 == 1) ? clk_n_1 : clk_n_1 & clk_en_1 ;
	assign i_clk_1    = (cfg_fclk_en_1 == "true" || cfg_fclk_en_1 == 1) ? clk_ng_1 : 1'b0 ;

	assign i_oen_1    = (cfg_oen_inv_1 == "true"  || cfg_oen_inv_1 ==1'b1) ? ~oen_1 : oen_1;   	
	assign i_od_n_1   = (cfg_d_en_1  == "true" || cfg_d_en_1 == 1'b1) ? od_d_1[0]  : 1'b0;   	
	assign i_od_1     = (cfg_txd0_inv_1  == "true" || cfg_txd0_inv_1 == 1'b1) ? ~i_od_n_1  : i_od_n_1;   	
	assign i_id_1     = (rx_dig_en_cfg_1 == "true" || rx_dig_en_cfg_1 == 1'b1) ? PAD1 : 1'bz;

	assign i_rstn_1   = (cfg_rstn_inv_1 == "true" || cfg_rstn_inv_1 == 1'b1) ? ~rstn_1 : rstn_1;   	
	assign i_setn_1   = (cfg_setn_inv_1 == "true" || cfg_setn_inv_1 == 1'b1) ? ~setn_1 : setn_1;   	

    assign id_rstn_1  = (cfg_id_rstn_en_1 == "true" || cfg_id_rstn_en_1 == 1'b1) ? i_rstn_1 : 1'b1;
    assign id_setn_1  = (cfg_id_setn_en_1 == "true" || cfg_id_setn_en_1 == 1'b1) ? i_setn_1 : 1'b1;

    assign od_rstn_1  = (cfg_od_rstn_en_1 == "true" || cfg_od_rstn_en_1 == 1'b1) ? i_rstn_1 : 1'b1;
    assign od_setn_1  = (cfg_od_setn_en_1 == "true" || cfg_od_setn_en_1 == 1'b1) ? i_setn_1 : 1'b1;

    assign oen_rstn_1  = (cfg_oen_rstn_en_1 == "true" || cfg_oen_rstn_en_1 == 1'b1) ? i_rstn_1 : 1'b1;
    assign oen_setn_1  = (cfg_oen_setn_en_1 == "true" || cfg_oen_setn_en_1 == 1'b1) ? i_setn_1 : 1'b1;

//---------------------------------------------------------------------------------
//id/od/oen reg 1
//---------------------------------------------------------------------------------
    always @ (posedge i_clk_1 or negedge id_rstn_1 or negedge id_setn_1) begin
        if(~id_rstn_1)            id_reg_1 <= 0;
        else if(~id_setn_1)       id_reg_1 <= 1;
        else                      id_reg_1 <= i_id_1;
    end
	
    always @ (posedge i_clk_1 or negedge od_rstn_1 or negedge od_setn_1) begin
        if(~od_rstn_1)        od_reg_1 <= 0;
        else if(~od_setn_1)   od_reg_1 <= 1;
        else                  od_reg_1 <= i_od_1;
    end

    always @ (posedge i_clk_1 or negedge oen_rstn_1 or negedge oen_setn_1) begin
        if(~oen_rstn_1)        oen_reg_1 <= 0;
        else if(~oen_setn_1)   oen_reg_1 <= 1;
        else                   oen_reg_1 <= i_oen_1;
    end
	

//---------------------------------------------------------------------------------
//input, oen, output generation 1
//---------------------------------------------------------------------------------
	assign id_q_1[0]     = (cfg_id_sel_1 == "register" || cfg_id_sel_1 == 1'b1) ? id_reg_1 : i_id_1;
	
	assign out_en_1 = (cfg_oen_sel_1 == "register" || cfg_oen_sel_1 == 2'b11) ? oen_reg_1 :
                      (cfg_oen_sel_1 == "bypass"   || cfg_oen_sel_1 == 2'b10) ? i_oen_1   :
                      (cfg_oen_sel_1 == "gnd"      || cfg_oen_sel_1 == 2'b01) ? 1'b0      :
                      (cfg_oen_sel_1 == "vcc"      || cfg_oen_sel_1 == 2'b00) ? 1'b1      : 1'bx;
									
    assign out_data_1 = (cfg_od_sel_1 == "register" || cfg_od_sel_1 == 2'b11) ? od_reg_1 :
                        (cfg_od_sel_1 == "bypass"   || cfg_od_sel_1 == 2'b10) ? i_od_1   :
                        (cfg_od_sel_1 == "gnd"      || cfg_od_sel_1 == 2'b00) ? 1'b0     :
                        (cfg_od_sel_1 == "vcc"      || cfg_od_sel_1 == 2'b01) ? 1'b1     : 1'bx;

    assign PAD1 = ~out_en_1 ? out_data_1 : 1'bz;
endmodule
//******************************************************************************
//company  :   Capital-Micro
//date     :   20130320
//function :   Software model for dqs io
//******************************************************************************

module  M7S_IO_DQS(
	clkpol_o,
	dqsr90_o,
	dqsr_en,
	id_q_1,
	id_q_0,
	NDR_in,
	PDR_in,
	TPD_in,
	TPU_in,
	clk_en_1,
	clk_en_0,
	clkpol_0,
	clkpol_1,
	clkpol_user,
	dqsr90_0,
	dqsr90_1,
	dqsr_en_rstn,
	gsclk270_in,
	gsclk180_in,
	gsclk90_in,
	gsclk_in,
	od_d_1,
	od_d_0,
	oen_1,
	oen_0,
	clk_0,
	clk_1,
	rstn_0,
	rstn_1,
	setn_0,
	setn_1,
	PAD1,
	PAD0
);
parameter    cfg_nc                = 1'b0 ;
parameter    cfg_use_cal1_1        = 1'b0 ;
parameter    cfg_use_cal1_0        = 1'b0 ;
parameter    para_ref              = 3'b000 ;
parameter    seri_ref              = 3'b000 ;
parameter    manual_en             = 1'b0 ;
parameter    vref_en               = 1'b0 ;
//parameter    cfg_rclk0_sel         = 2'b00 ;
//parameter    cfg_rclk1_sel         = 2'b00 ;
//parameter    cfg_rclk2_sel         = 2'b00 ;
//parameter    cfg_rclk3_sel         = 2'b00 ;
//parameter    cfg_rclk4_sel         = 2'b00 ;
//parameter    cfg_rclk5_sel         = 2'b00 ;
parameter    vref_sel              = 1'b0 ;

parameter    odt_cfg_1             = 1'b0 ;
parameter    ns_lv_cfg_1           = 2'b00 ;
parameter    pdr_cfg_1             = 5'b00000 ;
parameter    ndr_cfg_1             = 5'b00000 ;
parameter    keep_cfg_1            = 2'b00 ;
parameter    term_pu_en_1          = 1'b0 ;
parameter    term_pd_en_1          = 1'b0 ;
parameter    rx_dig_en_cfg_1       = 1'b0 ;
parameter    rx_hstl_sstl_en_cfg_1 = 1'b0 ;
parameter    tpd_cfg_1             = 8'b00000000 ;
parameter    tpu_cfg_1             = 8'b00000000 ;
parameter    cfg_trm_1             = 3'b000 ;
parameter    cfg_trm_sel_1         = 1'b0 ;
parameter    in_del_1              = 4'b0000 ;
parameter    out_del_1             = 4'b0000 ;
parameter    cfg_test_en_1         = 1'b0 ;
parameter    cfg_userio_en_1       = 1'b0 ;
parameter    cfg_use_cal0_1        = 1'b0 ;
//parameter    cfg_fclk_sel_1        = 2'b00 ;
//parameter    cfg_rstn_sel_1        = 2'b00 ;
//parameter    cfg_setn_sel_1        = 2'b00 ;
parameter    cfg_fclk_inv_1        = 1'b0 ;
parameter    cfg_gsclk_inv_1       = 1'b0 ;
parameter    cfg_gsclk90_inv_1     = 1'b0 ;
parameter    cfg_gsclk180_inv_1    = 1'b0 ;
parameter    cfg_gsclk270_inv_1    = 1'b0 ;
parameter    cfg_fclk_gate_sel_1   = 1'b0 ;
parameter    cfg_sclk_gate_sel_1   = 1'b0 ;
parameter    cfg_sclk_en_1         = 1'b0 ;
parameter    cfg_fclk_en_1         = 1'b0 ;
parameter    cfg_rstn_inv_1        = 1'b0 ;
parameter    cfg_oen_rstn_en_1     = 1'b0 ;
parameter    cfg_od_rstn_en_1      = 1'b0 ;
parameter    cfg_id_rstn_en_1      = 1'b0 ;
parameter    cfg_setn_inv_1        = 1'b0 ;
parameter    cfg_oen_setn_en_1     = 1'b0 ;
parameter    cfg_od_setn_en_1      = 1'b0 ;
parameter    cfg_id_setn_en_1      = 1'b0 ;
parameter    cfg_ddr_1             = 1'b0 ;
parameter    cfg_id_sel_1          = 1'b0 ;
parameter    cfg_oen_inv_1         = 1'b0 ;
parameter    cfg_oen_sel_1         = 2'b00 ;
parameter    cfg_dqs_1             = 1'b0 ;
parameter    cfg_txd0_inv_1        = 1'b0 ;
parameter    cfg_txd1_inv_1        = 1'b0 ;
parameter    cfg_d_en_1            = 1'b0 ;
parameter    cfg_clkout_sel_1      = 1'b0 ;
parameter    cfg_sclk_out_1        = 1'b0 ;
parameter    cfg_od_sel_1          = 2'b00 ;

parameter    odt_cfg_0             = 1'b0 ;
parameter    ns_lv_cfg_0           = 2'b00 ;
parameter    pdr_cfg_0             = 5'b00000 ;
parameter    ndr_cfg_0             = 5'b00000 ;
parameter    keep_cfg_0            = 2'b00 ;
parameter    term_pu_en_0          = 1'b0 ;
parameter    term_pd_en_0          = 1'b0 ;
parameter    rx_dig_en_cfg_0       = 1'b0 ;
parameter    rx_hstl_sstl_en_cfg_0 = 1'b0 ;
parameter    tpd_cfg_0             = 8'b00000000 ;
parameter    tpu_cfg_0             = 8'b00000000 ;
parameter    cfg_trm_0             = 3'b000 ;
parameter    cfg_trm_sel_0         = 1'b0 ;
parameter    in_del_0              = 4'b0000 ;
parameter    out_del_0             = 4'b0000 ;
parameter    cfg_test_en_0         = 1'b0 ;
parameter    cfg_userio_en_0       = 1'b0 ;
parameter    cfg_use_cal0_0        = 1'b0 ;
//parameter    cfg_fclk_sel_0        = 2'b00 ;
//parameter    cfg_rstn_sel_0        = 2'b00 ;
//parameter    cfg_setn_sel_0        = 2'b00 ;
parameter    cfg_fclk_inv_0        = 1'b0 ;
parameter    cfg_gsclk_inv_0       = 1'b0 ;
parameter    cfg_gsclk90_inv_0     = 1'b0 ;
parameter    cfg_gsclk180_inv_0    = 1'b0 ;
parameter    cfg_gsclk270_inv_0    = 1'b0 ;
parameter    cfg_fclk_gate_sel_0   = 1'b0 ;
parameter    cfg_sclk_gate_sel_0   = 1'b0 ;
parameter    cfg_sclk_en_0         = 1'b0 ;
parameter    cfg_fclk_en_0         = 1'b0 ;
parameter    cfg_rstn_inv_0        = 1'b0 ;
parameter    cfg_oen_rstn_en_0     = 1'b0 ;
parameter    cfg_od_rstn_en_0      = 1'b0 ;
parameter    cfg_id_rstn_en_0      = 1'b0 ;
parameter    cfg_setn_inv_0        = 1'b0 ;
parameter    cfg_oen_setn_en_0     = 1'b0 ;
parameter    cfg_od_setn_en_0      = 1'b0 ;
parameter    cfg_id_setn_en_0      = 1'b0 ;
parameter    cfg_ddr_0             = 1'b0 ;
parameter    cfg_id_sel_0          = 1'b0 ;
parameter    cfg_oen_inv_0         = 1'b0 ;
parameter    cfg_oen_sel_0         = 2'b00 ;
parameter    cfg_dqs_0             = 1'b0 ;
parameter    cfg_txd0_inv_0        = 1'b0 ;
parameter    cfg_txd1_inv_0        = 1'b0 ;
parameter    cfg_d_en_0            = 1'b0 ;
parameter    cfg_clkout_sel_0      = 1'b0 ;
parameter    cfg_sclk_out_0        = 1'b0 ;
parameter    cfg_od_sel_0          = 2'b00 ;
//dqs parmaters
parameter    cfg_nc_dqs            = 1'b0 ;
parameter    cfg_burst_len         = 2'b00 ;
parameter    cfg_dqsr_rstn_sel     = 1'b0 ;
parameter    cfg_clkpol_sel        = 1'b0 ;
parameter    pdn_cfg               = 1'b0 ;
parameter    bypassn_cfg_90        = 1'b0 ;
parameter    ssel1_90              = 4'b0000 ;
parameter    lfm_90                = 1'b0 ;
parameter    vcsel_90              = 1'b0 ;
parameter    bypassn_cfg_0         = 1'b0 ;
parameter    ssel1_0               = 4'b0000 ;
parameter    lfm_0                 = 1'b0 ;
parameter    vcsel_0               = 1'b0 ;

parameter    optional_function       = "";

output		clkpol_o;
output		dqsr90_o;
output		dqsr_en;
output	[1:0]	id_q_1;
output	[1:0]	id_q_0;
input	[4:0]	NDR_in;
input	[4:0]	PDR_in;
input	[7:0]	TPD_in;
input	[7:0]	TPU_in;
input		clk_en_1;
input		clk_en_0;
input		clkpol_0;
input		clkpol_1;
input		clkpol_user;
input		dqsr90_0;
input		dqsr90_1;
input		dqsr_en_rstn;
input		gsclk270_in;
input		gsclk180_in;
input		gsclk90_in;
input		gsclk_in;
input	[1:0]	od_d_1;
input	[1:0]	od_d_0;
input		oen_1;
input		oen_0;
input		clk_0;
input		clk_1;
input		rstn_0;
input		rstn_1;
input		setn_0;
input		setn_1;
inout		PAD1;
inout		PAD0;
//---------------------------------------------------------------------------------
// For basic IO function
//---------------------------------------------------------------------------------
	wire clk_n_0;
	wire clk_ng_0;
	wire i_clk_0;
	wire i_rstn_0;
	wire i_setn_0;
	wire i_oen_0;
	wire i_od_0;
	wire i_od_n_0;
	wire i_id_0;
	
	reg id_reg_0;
    reg od_reg_0;
    reg oen_reg_0;

    wire    id_rstn_0;
    wire    id_setn_0;
    wire    od_rstn_0;
    wire    od_setn_0;
    wire    oen_setn_0;
    wire    oen_rstn_0;

    wire    out_en_0;
    wire    out_data_0;

	wire clk_n_1;
	wire clk_ng_1;
	wire i_clk_1;
	wire i_rstn_1;
	wire i_setn_1;
	wire i_oen_1;
	wire i_od_1;
	wire i_od_n_1;
	wire i_id_1;
	
	reg id_reg_1;
    reg od_reg_1;
    reg oen_reg_1;

    wire    id_rstn_1;
    wire    id_setn_1;
    wire    od_rstn_1;
    wire    od_setn_1;
    wire    oen_setn_1;
    wire    oen_rstn_1;

    wire    out_en_1;
    wire    out_data_1;
//---------------------------------------------------------------------------------
//basic setting 0
//---------------------------------------------------------------------------------
	assign clk_n_0    = (cfg_fclk_inv_0 == "true" || cfg_fclk_inv_0 == 1'b1) ? ~clk_0 : clk_0;
	assign clk_ng_0   = (cfg_fclk_gate_sel_0 == "true" || cfg_fclk_gate_sel_0 == 1) ? clk_n_0 : clk_n_0 & clk_en_0 ;
	assign i_clk_0    = (cfg_fclk_en_0 == "true" || cfg_fclk_en_0 == 1) ? clk_ng_0 : 1'b0 ;

	assign i_oen_0    = (cfg_oen_inv_0 == "true"  || cfg_oen_inv_0 ==1'b1) ? ~oen_0 : oen_0;   	
	assign i_od_n_0   = (cfg_d_en_0  == "true" || cfg_d_en_0 == 1'b1) ? od_d_0[0]  : 1'b0;   	
	assign i_od_0     = (cfg_txd0_inv_0  == "true" || cfg_txd0_inv_0 == 1'b1) ? ~i_od_n_0  : i_od_n_0;   	
	assign i_id_0     = (rx_dig_en_cfg_0 == "true" || rx_dig_en_cfg_0 == 1'b1) ? PAD0 : 1'bz;

	assign i_rstn_0   = (cfg_rstn_inv_0 == "true" || cfg_rstn_inv_0 == 1'b1) ? ~rstn_0 : rstn_0;   	
	assign i_setn_0   = (cfg_setn_inv_0 == "true" || cfg_setn_inv_0 == 1'b1) ? ~setn_0 : setn_0;   	

    assign id_rstn_0  = (cfg_id_rstn_en_0 == "true" || cfg_id_rstn_en_0 == 1'b1) ? i_rstn_0 : 1'b1;
    assign id_setn_0  = (cfg_id_setn_en_0 == "true" || cfg_id_setn_en_0 == 1'b1) ? i_setn_0 : 1'b1;

    assign od_rstn_0  = (cfg_od_rstn_en_0 == "true" || cfg_od_rstn_en_0 == 1'b1) ? i_rstn_0 : 1'b1;
    assign od_setn_0  = (cfg_od_setn_en_0 == "true" || cfg_od_setn_en_0 == 1'b1) ? i_setn_0 : 1'b1;

    assign oen_rstn_0  = (cfg_oen_rstn_en_0 == "true" || cfg_oen_rstn_en_0 == 1'b1) ? i_rstn_0 : 1'b1;
    assign oen_setn_0  = (cfg_oen_setn_en_0 == "true" || cfg_oen_setn_en_0 == 1'b1) ? i_setn_0 : 1'b1;

//---------------------------------------------------------------------------------
//id/od/oen reg 0
//---------------------------------------------------------------------------------
    always @ (posedge i_clk_0 or negedge id_rstn_0 or negedge id_setn_0) begin
        if(~id_rstn_0)            id_reg_0 <= 0;
        else if(~id_setn_0)       id_reg_0 <= 1;
        else                      id_reg_0 <= i_id_0;
    end
	
    always @ (posedge i_clk_0 or negedge od_rstn_0 or negedge od_setn_0) begin
        if(~od_rstn_0)        od_reg_0 <= 0;
        else if(~od_setn_0)   od_reg_0 <= 1;
        else                  od_reg_0 <= i_od_0;
    end

    always @ (posedge i_clk_0 or negedge oen_rstn_0 or negedge oen_setn_0) begin
        if(~oen_rstn_0)        oen_reg_0 <= 0;
        else if(~oen_setn_0)   oen_reg_0 <= 1;
        else                   oen_reg_0 <= i_oen_0;
    end
	

//---------------------------------------------------------------------------------
//input, oen, output generation 0
//---------------------------------------------------------------------------------
	assign id_q_0[0]     = (cfg_id_sel_0 == "register" || cfg_id_sel_0 == 1'b1) ? id_reg_0 : i_id_0;
	
	assign out_en_0 = (cfg_oen_sel_0 == "register" || cfg_oen_sel_0 == 2'b11) ? oen_reg_0 :
                      (cfg_oen_sel_0 == "bypass"   || cfg_oen_sel_0 == 2'b10) ? i_oen_0   :
                      (cfg_oen_sel_0 == "gnd"      || cfg_oen_sel_0 == 2'b01) ? 1'b0      :
                      (cfg_oen_sel_0 == "vcc"      || cfg_oen_sel_0 == 2'b00) ? 1'b1      : 1'bx;
									
    assign out_data_0 = (cfg_od_sel_0 == "register" || cfg_od_sel_0 == 2'b11) ? od_reg_0 :
                        (cfg_od_sel_0 == "bypass"   || cfg_od_sel_0 == 2'b10) ? i_od_0   :
                        (cfg_od_sel_0 == "gnd"      || cfg_od_sel_0 == 2'b00) ? 1'b0     :
                        (cfg_od_sel_0 == "vcc"      || cfg_od_sel_0 == 2'b01) ? 1'b1     : 1'bx;

    assign PAD0 = ~out_en_0 ? out_data_0 : 1'bz;

//---------------------------------------------------------------------------------
//basic setting 1
//---------------------------------------------------------------------------------
	assign clk_n_1    = (cfg_fclk_inv_1 == "true" || cfg_fclk_inv_1 == 1'b1) ? ~clk_1 : clk_1;
	assign clk_ng_1   = (cfg_fclk_gate_sel_1 == "true" || cfg_fclk_gate_sel_1 == 1) ? clk_n_1 : clk_n_1 & clk_en_1 ;
	assign i_clk_1    = (cfg_fclk_en_1 == "true" || cfg_fclk_en_1 == 1) ? clk_ng_1 : 1'b0 ;

	assign i_oen_1    = (cfg_oen_inv_1 == "true"  || cfg_oen_inv_1 ==1'b1) ? ~oen_1 : oen_1;   	
	assign i_od_n_1   = (cfg_d_en_1  == "true" || cfg_d_en_1 == 1'b1) ? od_d_1[0]  : 1'b0;   	
	assign i_od_1     = (cfg_txd0_inv_1  == "true" || cfg_txd0_inv_1 == 1'b1) ? ~i_od_n_1  : i_od_n_1;   	
	assign i_id_1     = (rx_dig_en_cfg_1 == "true" || rx_dig_en_cfg_1 == 1'b1) ? PAD1 : 1'bz;

	assign i_rstn_1   = (cfg_rstn_inv_1 == "true" || cfg_rstn_inv_1 == 1'b1) ? ~rstn_1 : rstn_1;   	
	assign i_setn_1   = (cfg_setn_inv_1 == "true" || cfg_setn_inv_1 == 1'b1) ? ~setn_1 : setn_1;   	

    assign id_rstn_1  = (cfg_id_rstn_en_1 == "true" || cfg_id_rstn_en_1 == 1'b1) ? i_rstn_1 : 1'b1;
    assign id_setn_1  = (cfg_id_setn_en_1 == "true" || cfg_id_setn_en_1 == 1'b1) ? i_setn_1 : 1'b1;

    assign od_rstn_1  = (cfg_od_rstn_en_1 == "true" || cfg_od_rstn_en_1 == 1'b1) ? i_rstn_1 : 1'b1;
    assign od_setn_1  = (cfg_od_setn_en_1 == "true" || cfg_od_setn_en_1 == 1'b1) ? i_setn_1 : 1'b1;

    assign oen_rstn_1  = (cfg_oen_rstn_en_1 == "true" || cfg_oen_rstn_en_1 == 1'b1) ? i_rstn_1 : 1'b1;
    assign oen_setn_1  = (cfg_oen_setn_en_1 == "true" || cfg_oen_setn_en_1 == 1'b1) ? i_setn_1 : 1'b1;

//---------------------------------------------------------------------------------
//id/od/oen reg 1
//---------------------------------------------------------------------------------
    always @ (posedge i_clk_1 or negedge id_rstn_1 or negedge id_setn_1) begin
        if(~id_rstn_1)            id_reg_1 <= 0;
        else if(~id_setn_1)       id_reg_1 <= 1;
        else                      id_reg_1 <= i_id_1;
    end
	
    always @ (posedge i_clk_1 or negedge od_rstn_1 or negedge od_setn_1) begin
        if(~od_rstn_1)        od_reg_1 <= 0;
        else if(~od_setn_1)   od_reg_1 <= 1;
        else                  od_reg_1 <= i_od_1;
    end

    always @ (posedge i_clk_1 or negedge oen_rstn_1 or negedge oen_setn_1) begin
        if(~oen_rstn_1)        oen_reg_1 <= 0;
        else if(~oen_setn_1)   oen_reg_1 <= 1;
        else                   oen_reg_1 <= i_oen_1;
    end
	

//---------------------------------------------------------------------------------
//input, oen, output generation 1
//---------------------------------------------------------------------------------
	assign id_q_1[0]     = (cfg_id_sel_1 == "register" || cfg_id_sel_1 == 1'b1) ? id_reg_1 : i_id_1;
	
	assign out_en_1 = (cfg_oen_sel_1 == "register" || cfg_oen_sel_1 == 2'b11) ? oen_reg_1 :
                      (cfg_oen_sel_1 == "bypass"   || cfg_oen_sel_1 == 2'b10) ? i_oen_1   :
                      (cfg_oen_sel_1 == "gnd"      || cfg_oen_sel_1 == 2'b01) ? 1'b0      :
                      (cfg_oen_sel_1 == "vcc"      || cfg_oen_sel_1 == 2'b00) ? 1'b1      : 1'bx;
									
    assign out_data_1 = (cfg_od_sel_1 == "register" || cfg_od_sel_1 == 2'b11) ? od_reg_1 :
                        (cfg_od_sel_1 == "bypass"   || cfg_od_sel_1 == 2'b10) ? i_od_1   :
                        (cfg_od_sel_1 == "gnd"      || cfg_od_sel_1 == 2'b00) ? 1'b0     :
                        (cfg_od_sel_1 == "vcc"      || cfg_od_sel_1 == 2'b01) ? 1'b1     : 1'bx;

    assign PAD1 = ~out_en_1 ? out_data_1 : 1'bz;
    specify
    //iopath
  (oen_1 => PAD1) = (0,0) ;
	(od_d_1[0] => PAD1) = (0,0) ;
	(PAD1 => id_q_1[0]) = (0,0) ;
	(posedge clk_1 => ( id_q_1[0]  +: PAD1) ) = (0, 0) ;
  (posedge clk_1 => ( PAD1  +: od_d_1[0]) ) = (0, 0) ;
  (posedge clk_1 => ( PAD1  +: oen_1 ) ) = (0, 0) ;
	(posedge clk_0 => ( PAD0  +: oen_0 ) ) = (0, 0) ;
  (posedge clk_0 => ( PAD0  +: od_d_0[0]) ) = (0, 0) ;
	(oen_0 => PAD0) = (0,0) ;
	(od_d_0[0] => PAD0) = (0,0) ;
	(PAD0 => id_q_0[0]) = (0,0) ;
	(posedge clk_0 => ( id_q_0[0]  +: PAD0) ) = (0, 0) ;
	
  //timingcheck
   $setuphold(posedge clk_0, PAD0, 0, 0);
   $setuphold(posedge clk_0, od_d_0[0], 0, 0);
   $setuphold(posedge clk_0, oen_0, 0, 0);
$setuphold(posedge clk_0, clk_en_0, 0, 0);
	$setuphold(posedge clk_1, clk_en_1, 0, 0);
   $setuphold(posedge clk_1, PAD1, 0, 0); 
   $setuphold(posedge clk_1, od_d_1[0], 0, 0); 
   $setuphold(posedge clk_1, oen_1, 0, 0);
		endspecify

endmodule
//******************************************************************************
//company  :   Capital-Micro
//date     :   20130320
//function :   Software model for lvds io
//******************************************************************************
module  M7S_IO_LVDS(
	id_1,
	id_0,
	id_q_1,
	id_q_0,
	align_rstn,
	alignwd,
	clk_en_1,
	clk_en_0,
	io_reg_clk,
	geclk,
	geclk90,
	geclk180,
	geclk270,
	od_d_1,
	od_d_0,
	oen_1,
	oen_0,
	clk_0,
	clk_1,
	rstn_0,
	rstn_1,
	setn_0,
	setn_1,
	PAD1,
	PAD0
);
parameter    cfg_nc                = 4'b0000 ;
parameter    ldr_cfg               = 4'b0000 ;
parameter    rx_lvds_en_cfg        = 1'b0 ;
parameter    term_diff_en_cfg      = 1'b0 ;
parameter    lvds_tx_en_cfg        = 1'b0 ;
parameter    cml_tx_en_cfg         = 1'b0 ;
parameter    td_cfg                = 4'b0000 ;
parameter    cfg_gear_mode48       = 1'b0 ;
parameter    cfg_gear_mode7        = 1'b0 ;
parameter    cfg_algn_rsn_sel      = 1'b0 ;
//parameter    cfg_rclk0_sel         = 2'b00 ;
//parameter    cfg_rclk1_sel         = 2'b00 ;
//parameter    cfg_rclk2_sel         = 2'b00 ;
//parameter    cfg_rclk3_sel         = 2'b00 ;
//parameter    cfg_rclk4_sel         = 2'b00 ;
//parameter    cfg_rclk5_sel         = 2'b00 ;

parameter    ns_lv_fastestn_1      = 1'b0 ;
parameter    cfg_userio_en_1       = 1'b0 ;
//parameter    cfg_clk0_sel_1        = 2'b00 ;
//parameter    cfg_geclk_sel_1       = 1'b0 ;
//parameter    cfg_geclk90_sel_1     = 1'b0 ;
//parameter    cfg_rstn_sel_1        = 2'b00 ;
//parameter    cfg_setn_sel_1        = 2'b00 ;
parameter    cfg_sclk_inv_1        = 1'b0 ;
parameter    cfg_sclk_gate_sel_1   = 1'b0 ;
parameter    cfg_eclk_gate_sel_1   = 1'b0 ;
parameter    cfg_eclk90_gate_sel_1 = 1'b0 ;
parameter    cfg_sclk_en_1         = 1'b0 ;
parameter    cfg_fclk_en_1         = 1'b0 ;
parameter    cfg_eclk_en_1         = 1'b0 ;
parameter    cfg_eclk90_en_1       = 1'b0 ;
parameter    cfg_rstn_inv_1        = 1'b0 ;
parameter    cfg_oen_rstn_en_1     = 1'b0 ;
parameter    cfg_od_rstn_en_1      = 1'b0 ;
parameter    cfg_id_rstn_en_1      = 1'b0 ;
parameter    cfg_setn_inv_1        = 1'b0 ;
parameter    cfg_oen_setn_en_1     = 1'b0 ;
parameter    cfg_od_setn_en_1      = 1'b0 ;
parameter    cfg_id_setn_en_1      = 1'b0 ;
parameter    cfg_txd0_inv_1        = 1'b0 ;
parameter    cfg_txd1_inv_1        = 1'b0 ;
parameter    cfg_txd2_inv_1        = 1'b0 ;
parameter    cfg_txd3_inv_1        = 1'b0 ;
parameter    cfg_d_en_1            = 1'b0 ;
parameter    cfg_sclk_out_1        = 1'b0 ;
parameter    cfg_clkout_sel_1      = 1'b0 ;
parameter    cfg_od_sel_1          = 2'b00 ;
parameter    cfg_oen_inv_1         = 1'b0 ;
parameter    cfg_oen_sel_1         = 2'b00 ;
parameter    cfg_gear_1            = 1'b0 ;
parameter    cfg_slave_en_1        = 1'b0 ;
parameter    cfg_id_sel_1          = 1'b0 ;
parameter    ns_lv_cfg_1           = 2'b00 ;
parameter    pdr_cfg_1             = 4'b0000 ;
parameter    ndr_cfg_1             = 4'b0000 ;
parameter    rx_dig_en_cfg_1       = 1'b0 ;
parameter    keep_cfg_1            = 2'b00 ;
parameter    in_del_1              = 4'b0000 ;
parameter    out_del_1             = 4'b0000 ;

parameter    ns_lv_fastestn_0      = 1'b0 ;
parameter    cfg_userio_en_0       = 1'b0 ;
//parameter    cfg_clk0_sel_0        = 2'b00 ;
//parameter    cfg_geclk_sel_0       = 1'b0 ;
//parameter    cfg_geclk90_sel_0     = 1'b0 ;
//parameter    cfg_rstn_sel_0        = 2'b00 ;
//parameter    cfg_setn_sel_0        = 2'b00 ;
parameter    cfg_sclk_inv_0        = 1'b0 ;
parameter    cfg_sclk_gate_sel_0   = 1'b0 ;
parameter    cfg_eclk_gate_sel_0   = 1'b0 ;
parameter    cfg_eclk90_gate_sel_0 = 1'b0 ;
parameter    cfg_sclk_en_0         = 1'b0 ;
parameter    cfg_fclk_en_0         = 1'b0 ;
parameter    cfg_eclk_en_0         = 1'b0 ;
parameter    cfg_eclk90_en_0       = 1'b0 ;
parameter    cfg_rstn_inv_0        = 1'b0 ;
parameter    cfg_oen_rstn_en_0     = 1'b0 ;
parameter    cfg_od_rstn_en_0      = 1'b0 ;
parameter    cfg_id_rstn_en_0      = 1'b0 ;
parameter    cfg_setn_inv_0        = 1'b0 ;
parameter    cfg_oen_setn_en_0     = 1'b0 ;
parameter    cfg_od_setn_en_0      = 1'b0 ;
parameter    cfg_id_setn_en_0      = 1'b0 ;
parameter    cfg_txd0_inv_0        = 1'b0 ;
parameter    cfg_txd1_inv_0        = 1'b0 ;
parameter    cfg_txd2_inv_0        = 1'b0 ;
parameter    cfg_txd3_inv_0        = 1'b0 ;
parameter    cfg_d_en_0            = 1'b0 ;
parameter    cfg_sclk_out_0        = 1'b0 ;
parameter    cfg_clkout_sel_0      = 1'b0 ;
parameter    cfg_od_sel_0          = 2'b00 ;
parameter    cfg_oen_inv_0         = 1'b0 ;
parameter    cfg_oen_sel_0         = 2'b00 ;
parameter    cfg_gear_0            = 1'b0 ;
parameter    cfg_slave_en_0        = 1'b0 ;
parameter    cfg_id_sel_0          = 1'b0 ;
parameter    ns_lv_cfg_0           = 2'b00 ;
parameter    pdr_cfg_0             = 4'b0000 ;
parameter    ndr_cfg_0             = 4'b0000 ;
parameter    rx_dig_en_cfg_0       = 1'b0 ;
parameter    keep_cfg_0            = 2'b00 ;
parameter    in_del_0              = 4'b0000 ;
parameter    out_del_0             = 4'b0000 ;

parameter    optional_function       = "";

output		id_1;
output		id_0;
output	[3:0]	id_q_1;
output	[3:0]	id_q_0;
output		io_reg_clk;
input		align_rstn;
input		alignwd;
input		clk_en_1;
input		clk_en_0;
input		geclk90;
input		geclk;
input		geclk180;
input		geclk270;
input	[3:0]	od_d_1;
input	[3:0]	od_d_0;
input		oen_1;
input		oen_0;
input		clk_0;
input		clk_1;
input		rstn_0;
input		rstn_1;
input		setn_0;
input		setn_1;
inout		PAD1;
inout		PAD0;

//---------------------------------------------------------------------------------
// For basic IO function
//---------------------------------------------------------------------------------
	wire clk_n_0;
	wire clk_ng_0;
	wire i_clk_0;
	wire i_rstn_0;
	wire i_setn_0;
	wire i_oen_0;
	wire i_od_0;
	wire i_od_n_0;
	wire i_id_0;
	
	reg id_reg_0;
    reg od_reg_0;
    reg oen_reg_0;

    wire    id_rstn_0;
    wire    id_setn_0;
    wire    od_rstn_0;
    wire    od_setn_0;
    wire    oen_setn_0;
    wire    oen_rstn_0;

    wire    out_en_0;
    wire    out_data_0;

	wire clk_n_1;
	wire clk_ng_1;
	wire i_clk_1;
	wire i_rstn_1;
	wire i_setn_1;
	wire i_oen_1;
	wire i_od_1;
	wire i_od_n_1;
	wire i_id_1;
	
	reg id_reg_1;
    reg od_reg_1;
    reg oen_reg_1;

    wire    id_rstn_1;
    wire    id_setn_1;
    wire    od_rstn_1;
    wire    od_setn_1;
    wire    oen_setn_1;
    wire    oen_rstn_1;

    wire    out_en_1;
    wire    out_data_1;
//---------------------------------------------------------------------------------
//basic setting 0
//---------------------------------------------------------------------------------
	assign clk_n_0    = (cfg_sclk_inv_0 == "true" || cfg_sclk_inv_0 == 1'b1) ? ~clk_0 : clk_0;
	assign clk_ng_0   = (cfg_sclk_gate_sel_0 == "true" || cfg_sclk_gate_sel_0 == 1) ? clk_n_0 : clk_n_0 & clk_en_0 ;
	assign i_clk_0    = (cfg_fclk_en_0 == "true" || cfg_fclk_en_0 == 1) ? clk_ng_0 : 1'b0 ;

	assign i_oen_0    = (cfg_oen_inv_0 == "true"  || cfg_oen_inv_0 ==1'b1) ? ~oen_0 : oen_0;   	
	assign i_od_n_0   = (cfg_d_en_0  == "true" || cfg_d_en_0 == 1'b1) ? od_d_0[0]  : 1'b0;   	
	assign i_od_0     = (cfg_txd0_inv_0  == "true" || cfg_txd0_inv_0 == 1'b1) ? ~i_od_n_0  : i_od_n_0;   	
	assign i_id_0     = (rx_dig_en_cfg_0 == "true" || rx_dig_en_cfg_0 == 1'b1) ? PAD0 : 1'bz;

	assign i_rstn_0   = (cfg_rstn_inv_0 == "true" || cfg_rstn_inv_0 == 1'b1) ? ~rstn_0 : rstn_0;   	
	assign i_setn_0   = (cfg_setn_inv_0 == "true" || cfg_setn_inv_0 == 1'b1) ? ~setn_0 : setn_0;   	

    assign id_rstn_0  = (cfg_id_rstn_en_0 == "true" || cfg_id_rstn_en_0 == 1'b1) ? i_rstn_0 : 1'b1;
    assign id_setn_0  = (cfg_id_setn_en_0 == "true" || cfg_id_setn_en_0 == 1'b1) ? i_setn_0 : 1'b1;

    assign od_rstn_0  = (cfg_od_rstn_en_0 == "true" || cfg_od_rstn_en_0 == 1'b1) ? i_rstn_0 : 1'b1;
    assign od_setn_0  = (cfg_od_setn_en_0 == "true" || cfg_od_setn_en_0 == 1'b1) ? i_setn_0 : 1'b1;

    assign oen_rstn_0  = (cfg_oen_rstn_en_0 == "true" || cfg_oen_rstn_en_0 == 1'b1) ? i_rstn_0 : 1'b1;
    assign oen_setn_0  = (cfg_oen_setn_en_0 == "true" || cfg_oen_setn_en_0 == 1'b1) ? i_setn_0 : 1'b1;

//---------------------------------------------------------------------------------
//id/od/oen reg 0
//---------------------------------------------------------------------------------
    always @ (posedge i_clk_0 or negedge id_rstn_0 or negedge id_setn_0) begin
        if(~id_rstn_0)            id_reg_0 <= 0;
        else if(~id_setn_0)       id_reg_0 <= 1;
        else                      id_reg_0 <= i_id_0;
    end
	
    always @ (posedge i_clk_0 or negedge od_rstn_0 or negedge od_setn_0) begin
        if(~od_rstn_0)        od_reg_0 <= 0;
        else if(~od_setn_0)   od_reg_0 <= 1;
        else                  od_reg_0 <= i_od_0;
    end

    always @ (posedge i_clk_0 or negedge oen_rstn_0 or negedge oen_setn_0) begin
        if(~oen_rstn_0)        oen_reg_0 <= 0;
        else if(~oen_setn_0)   oen_reg_0 <= 1;
        else                   oen_reg_0 <= i_oen_0;
    end
	

//---------------------------------------------------------------------------------
//input, oen, output generation 0
//---------------------------------------------------------------------------------
	assign id_0          = i_id_0 ;
	assign id_q_0[0]     = (cfg_id_sel_0 == "register" || cfg_id_sel_0 == 1'b1) ? id_reg_0 : i_id_0;
	
	assign out_en_0 = (cfg_oen_sel_0 == "register" || cfg_oen_sel_0 == 2'b11) ? oen_reg_0 :
                      (cfg_oen_sel_0 == "bypass"   || cfg_oen_sel_0 == 2'b10) ? i_oen_0   :
                      (cfg_oen_sel_0 == "gnd"      || cfg_oen_sel_0 == 2'b01) ? 1'b0      :
                      (cfg_oen_sel_0 == "vcc"      || cfg_oen_sel_0 == 2'b00) ? 1'b1      : 1'bx;
									
    assign out_data_0 = (cfg_od_sel_0 == "register" || cfg_od_sel_0 == 2'b11) ? od_reg_0 :
                        (cfg_od_sel_0 == "bypass"   || cfg_od_sel_0 == 2'b10) ? i_od_0   :
                        (cfg_od_sel_0 == "gnd"      || cfg_od_sel_0 == 2'b00) ? 1'b0     :
                        (cfg_od_sel_0 == "vcc"      || cfg_od_sel_0 == 2'b01) ? 1'b1     : 1'bx;

    assign PAD0 = ~out_en_0 ? out_data_0 : 1'bz;

//---------------------------------------------------------------------------------
//basic setting 1
//---------------------------------------------------------------------------------
	assign clk_n_1    = (cfg_sclk_inv_1 == "true" || cfg_sclk_inv_1 == 1'b1) ? ~clk_1 : clk_1;
	assign clk_ng_1   = (cfg_sclk_gate_sel_1 == "true" || cfg_sclk_gate_sel_1 == 1) ? clk_n_1 : clk_n_1 & clk_en_1 ;
	assign i_clk_1    = (cfg_fclk_en_1 == "true" || cfg_fclk_en_1 == 1) ? clk_ng_1 : 1'b0 ;

	assign i_oen_1    = (cfg_oen_inv_1 == "true"  || cfg_oen_inv_1 ==1'b1) ? ~oen_1 : oen_1;   	
	assign i_od_n_1   = (cfg_d_en_1  == "true" || cfg_d_en_1 == 1'b1) ? od_d_1[0]  : 1'b0;   	
	assign i_od_1     = (cfg_txd0_inv_1  == "true" || cfg_txd0_inv_1 == 1'b1) ? ~i_od_n_1  : i_od_n_1;   	
	assign i_id_1     = (rx_dig_en_cfg_1 == "true" || rx_dig_en_cfg_1 == 1'b1) ? PAD1 : 1'bz;

	assign i_rstn_1   = (cfg_rstn_inv_1 == "true" || cfg_rstn_inv_1 == 1'b1) ? ~rstn_1 : rstn_1;   	
	assign i_setn_1   = (cfg_setn_inv_1 == "true" || cfg_setn_inv_1 == 1'b1) ? ~setn_1 : setn_1;   	

    assign id_rstn_1  = (cfg_id_rstn_en_1 == "true" || cfg_id_rstn_en_1 == 1'b1) ? i_rstn_1 : 1'b1;
    assign id_setn_1  = (cfg_id_setn_en_1 == "true" || cfg_id_setn_en_1 == 1'b1) ? i_setn_1 : 1'b1;

    assign od_rstn_1  = (cfg_od_rstn_en_1 == "true" || cfg_od_rstn_en_1 == 1'b1) ? i_rstn_1 : 1'b1;
    assign od_setn_1  = (cfg_od_setn_en_1 == "true" || cfg_od_setn_en_1 == 1'b1) ? i_setn_1 : 1'b1;

    assign oen_rstn_1  = (cfg_oen_rstn_en_1 == "true" || cfg_oen_rstn_en_1 == 1'b1) ? i_rstn_1 : 1'b1;
    assign oen_setn_1  = (cfg_oen_setn_en_1 == "true" || cfg_oen_setn_en_1 == 1'b1) ? i_setn_1 : 1'b1;

//---------------------------------------------------------------------------------
//id/od/oen reg 1
//---------------------------------------------------------------------------------
    always @ (posedge i_clk_1 or negedge id_rstn_1 or negedge id_setn_1) begin
        if(~id_rstn_1)            id_reg_1 <= 0;
        else if(~id_setn_1)       id_reg_1 <= 1;
        else                      id_reg_1 <= i_id_1;
    end
	
    always @ (posedge i_clk_1 or negedge od_rstn_1 or negedge od_setn_1) begin
        if(~od_rstn_1)        od_reg_1 <= 0;
        else if(~od_setn_1)   od_reg_1 <= 1;
        else                  od_reg_1 <= i_od_1;
    end

    always @ (posedge i_clk_1 or negedge oen_rstn_1 or negedge oen_setn_1) begin
        if(~oen_rstn_1)        oen_reg_1 <= 0;
        else if(~oen_setn_1)   oen_reg_1 <= 1;
        else                   oen_reg_1 <= i_oen_1;
    end
	

//---------------------------------------------------------------------------------
//input, oen, output generation 1
//---------------------------------------------------------------------------------
	assign id_1          = i_id_1 ;
	assign id_q_1[0]     = (cfg_id_sel_1 == "register" || cfg_id_sel_1 == 1'b1) ? id_reg_1 : i_id_1;
	
	assign out_en_1 = (cfg_oen_sel_1 == "register" || cfg_oen_sel_1 == 2'b11) ? oen_reg_1 :
                      (cfg_oen_sel_1 == "bypass"   || cfg_oen_sel_1 == 2'b10) ? i_oen_1   :
                      (cfg_oen_sel_1 == "gnd"      || cfg_oen_sel_1 == 2'b01) ? 1'b0      :
                      (cfg_oen_sel_1 == "vcc"      || cfg_oen_sel_1 == 2'b00) ? 1'b1      : 1'bx;
									
    assign out_data_1 = (cfg_od_sel_1 == "register" || cfg_od_sel_1 == 2'b11) ? od_reg_1 :
                        (cfg_od_sel_1 == "bypass"   || cfg_od_sel_1 == 2'b10) ? i_od_1   :
                        (cfg_od_sel_1 == "gnd"      || cfg_od_sel_1 == 2'b00) ? 1'b0     :
                        (cfg_od_sel_1 == "vcc"      || cfg_od_sel_1 == 2'b01) ? 1'b1     : 1'bx;

    assign PAD1 = ~out_en_1 ? out_data_1 : 1'bz;
endmodule
//******************************************************************************
//company  :   Capital-Micro
//date     :   20130320
//function :   Software model for pcisg io
//******************************************************************************

module  M7S_IO_PCISG(
	id,
	clk,
	clk_en,
	rstn,
	setn,
	od,
	oen,
	PAD
);
parameter    cfg_nc                = 4'b0000 ;
parameter    ns_lv_fastestn        = 1'b0 ;
parameter    cfg_userio_en         = 1'b0 ;
parameter    ns_lv_cfg             = 2'b00 ;
parameter    pdr_cfg               = 4'b0000 ;
parameter    ndr_cfg               = 4'b0000 ;
parameter    keep_cfg              = 2'b00 ;
parameter    rx_dig_en_cfg         = 1'b0 ;
parameter    in_del                = 4'b0000 ;
parameter    out_del               = 4'b0000 ;
parameter    vpci_en               = 1'b0 ;
parameter    cfg_oen_inv           = 1'b0 ;
parameter    cfg_oen_sel           = 2'b00 ;
parameter    cfg_od_inv            = 1'b0 ;
parameter    cfg_od_sel            = 2'b00 ;
parameter    cfg_id_sel            = 1'b0 ;
//parameter    cfg_rclk0_sel         = 2'b00 ;
//parameter    cfg_rclk1_sel         = 2'b00 ;
//parameter    cfg_rclk2_sel         = 2'b00 ;
//parameter    cfg_rclk3_sel         = 2'b00 ;
//parameter    cfg_rclk4_sel         = 2'b00 ;
//parameter    cfg_rclk5_sel         = 2'b00 ;
//parameter    cfg_fclk_sel          = 2'b00 ;
//parameter    cfg_rstn_sel          = 2'b00 ;
//parameter    cfg_setn_sel          = 2'b00 ;
parameter    cfg_fclk_inv          = 1'b0 ;
parameter    cfg_fclk_gate_sel     = 1'b0 ;
parameter    cfg_fclk_en           = 1'b0 ;
parameter    cfg_rstn_inv          = 1'b0 ;
parameter    cfg_oen_rstn_en       = 1'b0 ;
parameter    cfg_od_rstn_en        = 1'b0 ;
parameter    cfg_id_rstn_en        = 1'b0 ;
parameter    cfg_setn_inv          = 1'b0 ;
parameter    cfg_oen_setn_en       = 1'b0 ;
parameter    cfg_od_setn_en        = 1'b0 ;
parameter    cfg_id_setn_en        = 1'b0 ;

parameter    optional_function       = "";

output		id;
input		clk;
input		clk_en;
input		setn;
input		rstn;
input		od;
input		oen;
inout		PAD;

//---------------------------------------------------------------------------------
// For basic IO function
//---------------------------------------------------------------------------------
	wire clk_n;
	wire clk_ng;
	wire i_clk;
	wire i_rstn;
	wire i_setn;
	wire i_oen;
	wire i_od;
	wire i_id;
	
	reg id_reg;
    reg od_reg;
    reg oen_reg;

    wire    id_rstn;
    wire    id_setn;
    wire    od_rstn;
    wire    od_setn;
    wire    oen_setn;
    wire    oen_rstn;

    wire    out_en;
    wire    out_data;

	
//---------------------------------------------------------------------------------
//basic setting
//---------------------------------------------------------------------------------
	assign clk_n    = (cfg_fclk_inv == "true" || cfg_fclk_inv == 1'b1) ? ~clk : clk;
	assign clk_ng   = (cfg_fclk_gate_sel == "true" || cfg_fclk_gate_sel == 1) ? clk_n : clk_n & clk_en ;
	assign i_clk    = (cfg_fclk_en == "true" || cfg_fclk_en == 1) ? clk_ng : 1'b0 ;

	assign i_oen    = (cfg_oen_inv == "true"  || cfg_oen_inv ==1'b1) ? ~oen : oen;   	
	assign i_od     = (cfg_od_inv  == "true"  || cfg_od_inv ==1'b1)  ? ~od  : od;   	
	assign i_id     = (rx_dig_en_cfg == "true"|| rx_dig_en_cfg == 1'b1) ? PAD : 1'bz;

	assign i_rstn   = (cfg_rstn_inv == "true" || cfg_rstn_inv == 1'b1) ? ~rstn : rstn;   	
	assign i_setn   = (cfg_setn_inv == "true" || cfg_setn_inv == 1'b1) ? ~setn : setn;   	

    assign id_rstn  = (cfg_id_rstn_en == "true" || cfg_id_rstn_en == 1'b1) ? i_rstn : 1'b1;
    assign id_setn  = (cfg_id_setn_en == "true" || cfg_id_setn_en == 1'b1) ? i_setn : 1'b1;

    assign od_rstn  = (cfg_od_rstn_en == "true" || cfg_od_rstn_en == 1'b1) ? i_rstn : 1'b1;
    assign od_setn  = (cfg_od_setn_en == "true" || cfg_od_setn_en == 1'b1) ? i_setn : 1'b1;

    assign oen_rstn  = (cfg_oen_rstn_en == "true" || cfg_oen_rstn_en == 1'b1) ? i_rstn : 1'b1;
    assign oen_setn  = (cfg_oen_setn_en == "true" || cfg_oen_setn_en == 1'b1) ? i_setn : 1'b1;

//---------------------------------------------------------------------------------
//id/od/oen reg
//---------------------------------------------------------------------------------
    always @ (posedge i_clk or negedge id_rstn or negedge id_setn) begin
        if(~id_rstn)            id_reg <= 0;
        else if(~id_setn)       id_reg <= 1;
        else                    id_reg <= i_id;
    end
	
    always @ (posedge i_clk or negedge od_rstn or negedge od_setn) begin
        if(~od_rstn)        od_reg <= 0;
        else if(~od_setn)   od_reg <= 1;
        else                od_reg <= i_od;
    end

    always @ (posedge i_clk or negedge oen_rstn or negedge oen_setn) begin
        if(~oen_rstn)        oen_reg <= 0;
        else if(~oen_setn)   oen_reg <= 1;
        else                 oen_reg <= i_oen;
    end
	

//---------------------------------------------------------------------------------
//input, oen, output generation
//---------------------------------------------------------------------------------
	assign id     = (cfg_id_sel == "register" || cfg_id_sel == 1'b1) ? id_reg : i_id;
	
	assign out_en = (cfg_oen_sel == "register" || cfg_oen_sel == 2'b11) ? oen_reg :
                    (cfg_oen_sel == "bypass"   || cfg_oen_sel == 2'b10) ? i_oen   :
                    (cfg_oen_sel == "gnd"      || cfg_oen_sel == 2'b01) ? 1'b0    :
                    (cfg_oen_sel == "vcc"      || cfg_oen_sel == 2'b00) ? 1'b1    : 1'bx;
									
    assign out_data = (cfg_od_sel == "register" || cfg_od_sel == 2'b11) ? od_reg :
                      (cfg_od_sel == "bypass"   || cfg_od_sel == 2'b10) ? i_od   :
                      (cfg_od_sel == "gnd"      || cfg_od_sel == 2'b00) ? 1'b0   :
                      (cfg_od_sel == "vcc"      || cfg_od_sel == 2'b01) ? 1'b1   : 1'bx;

    assign PAD = ~out_en ? out_data : 1'bz;

endmodule
//******************************************************************************
//company  :   Capital-Micro
//date     :   20130320
//function :   Software model for vref io
//******************************************************************************
module M7S_IO_VREF (
	id_q_1,
	id_q_0,
	NDR_in,
	PDR_in,
	TPD_in,
	TPU_in,
	clk_en_1,
	clk_en_0,
	clkpol_0,
	clkpol_1,
	dqsr90_0,
	dqsr90_1,
	gsclk270_in,
	gsclk180_in,
	gsclk90_in,
	gsclk_in,
	od_d_1,
	od_d_0,
	oen_1,
	oen_0,
	clk_0,
	clk_1,
	rstn_0,
	rstn_1,
	setn_0,
	setn_1,
	PAD1,
	PAD0
);
parameter    cfg_nc                = 1'b0 ;
parameter    cfg_use_cal1_1        = 1'b0 ;
parameter    cfg_use_cal1_0        = 1'b0 ;
parameter    para_ref              = 3'b000 ;
parameter    seri_ref              = 3'b000 ;
parameter    manual_en             = 1'b0 ;
parameter    vref_en               = 1'b0 ;
//parameter    cfg_rclk0_sel         = 2'b00 ;
//parameter    cfg_rclk1_sel         = 2'b00 ;
//parameter    cfg_rclk2_sel         = 2'b00 ;
//parameter    cfg_rclk3_sel         = 2'b00 ;
//parameter    cfg_rclk4_sel         = 2'b00 ;
//parameter    cfg_rclk5_sel         = 2'b00 ;
parameter    vref_sel              = 1'b0 ;

parameter    odt_cfg_1             = 1'b0 ;
parameter    ns_lv_cfg_1           = 2'b00 ;
parameter    pdr_cfg_1             = 5'b00000;
parameter    ndr_cfg_1             = 5'b00000;
parameter    keep_cfg_1            = 2'b00 ;
parameter    term_pu_en_1          = 1'b0 ;
parameter    term_pd_en_1          = 1'b0 ;
parameter    rx_dig_en_cfg_1       = 1'b0 ;
parameter    rx_hstl_sstl_en_cfg_1 = 1'b0 ;
parameter    tpd_cfg_1             = 8'b00000000 ;
parameter    tpu_cfg_1             = 8'b00000000 ;
parameter    cfg_trm_1             = 3'b000 ;
parameter    cfg_trm_sel_1         = 1'b0 ;
parameter    in_del_1              = 4'b0000 ;
parameter    out_del_1             = 4'b0000 ;
parameter    ns_lv_fastestn_1      = 1'b0 ;
parameter    cfg_userio_en_1       = 1'b0 ;
parameter    cfg_use_cal0_1        = 1'b0 ;
//parameter    cfg_fclk_sel_1        = 2'b00 ;
//parameter    cfg_rstn_sel_1        = 2'b00 ;
//parameter    cfg_setn_sel_1        = 2'b00 ;
parameter    cfg_fclk_inv_1        = 1'b0 ;
parameter    cfg_gsclk_inv_1       = 1'b0 ;
parameter    cfg_gsclk90_inv_1     = 1'b0 ;
parameter    cfg_gsclk180_inv_1    = 1'b0 ;
parameter    cfg_gsclk270_inv_1    = 1'b0 ;
parameter    cfg_fclk_gate_sel_1   = 1'b0 ;
parameter    cfg_sclk_gate_sel_1   = 1'b0 ;
parameter    cfg_sclk_en_1         = 1'b0 ;
parameter    cfg_fclk_en_1         = 1'b0 ;
parameter    cfg_rstn_inv_1        = 1'b0 ;
parameter    cfg_oen_rstn_en_1     = 1'b0 ;
parameter    cfg_od_rstn_en_1      = 1'b0 ;
parameter    cfg_id_rstn_en_1      = 1'b0 ;
parameter    cfg_setn_inv_1        = 1'b0 ;
parameter    cfg_oen_setn_en_1     = 1'b0 ;
parameter    cfg_od_setn_en_1      = 1'b0 ;
parameter    cfg_id_setn_en_1      = 1'b0 ;
parameter    cfg_ddr_1             = 1'b0 ;
parameter    cfg_id_sel_1          = 1'b0 ;
parameter    cfg_oen_inv_1         = 1'b0 ;
parameter    cfg_oen_sel_1         = 2'b00 ;
parameter    cfg_dqs_1             = 1'b0 ;
parameter    cfg_txd0_inv_1        = 1'b0 ;
parameter    cfg_txd1_inv_1        = 1'b0 ;
parameter    cfg_d_en_1            = 1'b0 ;
parameter    cfg_clkout_sel_1      = 1'b0 ;
parameter    cfg_sclk_out_1        = 1'b0 ;
parameter    cfg_od_sel_1          = 2'b00 ;

parameter    odt_cfg_0             = 1'b0 ;
parameter    ns_lv_cfg_0           = 2'b00 ;
parameter    pdr_cfg_0             = 5'b00000 ;
parameter    ndr_cfg_0             = 5'b00000 ;
parameter    keep_cfg_0            = 2'b00 ;
parameter    term_pu_en_0          = 1'b0 ;
parameter    term_pd_en_0          = 1'b0 ;
parameter    rx_dig_en_cfg_0       = 1'b0 ;
parameter    rx_hstl_sstl_en_cfg_0 = 1'b0 ;
parameter    tpd_cfg_0             = 8'b00000000 ;
parameter    tpu_cfg_0             = 8'b00000000 ;
parameter    cfg_trm_0             = 3'b000 ;
parameter    cfg_trm_sel_0         = 1'b0 ;
parameter    in_del_0              = 4'b0000 ;
parameter    out_del_0             = 4'b0000 ;
parameter    ns_lv_fastestn_0      = 1'b0 ;
parameter    cfg_userio_en_0       = 1'b0 ;
parameter    cfg_use_cal0_0        = 1'b0 ;
//parameter    cfg_fclk_sel_0        = 2'b00 ;
//parameter    cfg_rstn_sel_0        = 2'b00 ;
//parameter    cfg_setn_sel_0        = 2'b00 ;
parameter    cfg_fclk_inv_0        = 1'b0 ;
parameter    cfg_gsclk_inv_0       = 1'b0 ;
parameter    cfg_gsclk90_inv_0     = 1'b0 ;
parameter    cfg_gsclk180_inv_0    = 1'b0 ;
parameter    cfg_gsclk270_inv_0    = 1'b0 ;
parameter    cfg_fclk_gate_sel_0   = 1'b0 ;
parameter    cfg_sclk_gate_sel_0   = 1'b0 ;
parameter    cfg_sclk_en_0         = 1'b0 ;
parameter    cfg_fclk_en_0         = 1'b0 ;
parameter    cfg_rstn_inv_0        = 1'b0 ;
parameter    cfg_oen_rstn_en_0     = 1'b0 ;
parameter    cfg_od_rstn_en_0      = 1'b0 ;
parameter    cfg_id_rstn_en_0      = 1'b0 ;
parameter    cfg_setn_inv_0        = 1'b0 ;
parameter    cfg_oen_setn_en_0     = 1'b0 ;
parameter    cfg_od_setn_en_0      = 1'b0 ;
parameter    cfg_id_setn_en_0      = 1'b0 ;
parameter    cfg_ddr_0             = 1'b0 ;
parameter    cfg_id_sel_0          = 1'b0 ;
parameter    cfg_oen_inv_0         = 1'b0 ;
parameter    cfg_oen_sel_0         = 2'b00 ;
parameter    cfg_dqs_0             = 1'b0 ;
parameter    cfg_txd0_inv_0        = 1'b0 ;
parameter    cfg_txd1_inv_0        = 1'b0 ;
parameter    cfg_d_en_0            = 1'b0 ;
parameter    cfg_clkout_sel_0      = 1'b0 ;
parameter    cfg_sclk_out_0        = 1'b0 ;
parameter    cfg_od_sel_0          = 2'b00 ;

parameter    optional_function       = "";

output	[1:0]	id_q_1;
output	[1:0]	id_q_0;
input	[4:0]	NDR_in;
input	[4:0]	PDR_in;
input	[7:0]	TPD_in;
input	[7:0]	TPU_in;
input		clk_en_1;
input		clk_en_0;
input		clkpol_0;
input		clkpol_1;
input		dqsr90_0;
input		dqsr90_1;
input		gsclk270_in;
input		gsclk180_in;
input		gsclk90_in;
input		gsclk_in;
input	[1:0]	od_d_1;
input	[1:0]	od_d_0;
input		oen_1;
input		oen_0;
input		clk_0;
input		clk_1;
input		rstn_0;
input		rstn_1;
input		setn_0;
input		setn_1;
inout		PAD1;
inout		PAD0;
//---------------------------------------------------------------------------------
// For basic IO function
//---------------------------------------------------------------------------------
	wire clk_n_0;
	wire clk_ng_0;
	wire i_clk_0;
	wire i_rstn_0;
	wire i_setn_0;
	wire i_oen_0;
	wire i_od_0;
	wire i_od_n_0;
	wire i_id_0;
	
	reg id_reg_0;
    reg od_reg_0;
    reg oen_reg_0;

    wire    id_rstn_0;
    wire    id_setn_0;
    wire    od_rstn_0;
    wire    od_setn_0;
    wire    oen_setn_0;
    wire    oen_rstn_0;

    wire    out_en_0;
    wire    out_data_0;

	wire clk_n_1;
	wire clk_ng_1;
	wire i_clk_1;
	wire i_rstn_1;
	wire i_setn_1;
	wire i_oen_1;
	wire i_od_1;
	wire i_od_n_1;
	wire i_id_1;
	
	reg id_reg_1;
    reg od_reg_1;
    reg oen_reg_1;

    wire    id_rstn_1;
    wire    id_setn_1;
    wire    od_rstn_1;
    wire    od_setn_1;
    wire    oen_setn_1;
    wire    oen_rstn_1;

    wire    out_en_1;
    wire    out_data_1;
//---------------------------------------------------------------------------------
//basic setting 0
//---------------------------------------------------------------------------------
	assign clk_n_0    = (cfg_fclk_inv_0 == "true" || cfg_fclk_inv_0 == 1'b1) ? ~clk_0 : clk_0;
	assign clk_ng_0   = (cfg_fclk_gate_sel_0 == "true" || cfg_fclk_gate_sel_0 == 1) ? clk_n_0 : clk_n_0 & clk_en_0 ;
	assign i_clk_0    = (cfg_fclk_en_0 == "true" || cfg_fclk_en_0 == 1) ? clk_ng_0 : 1'b0 ;

	assign i_oen_0    = (cfg_oen_inv_0 == "true"  || cfg_oen_inv_0 ==1'b1) ? ~oen_0 : oen_0;   	
	assign i_od_n_0   = (cfg_d_en_0  == "true" || cfg_d_en_0 == 1'b1) ? od_d_0[0]  : 1'b0;   	
	assign i_od_0     = (cfg_txd0_inv_0  == "true" || cfg_txd0_inv_0 == 1'b1) ? ~i_od_n_0  : i_od_n_0;   	
	assign i_id_0     = (rx_dig_en_cfg_0 == "true" || rx_dig_en_cfg_0 == 1'b1) ? PAD0 : 1'bz;

	assign i_rstn_0   = (cfg_rstn_inv_0 == "true" || cfg_rstn_inv_0 == 1'b1) ? ~rstn_0 : rstn_0;   	
	assign i_setn_0   = (cfg_setn_inv_0 == "true" || cfg_setn_inv_0 == 1'b1) ? ~setn_0 : setn_0;   	

    assign id_rstn_0  = (cfg_id_rstn_en_0 == "true" || cfg_id_rstn_en_0 == 1'b1) ? i_rstn_0 : 1'b1;
    assign id_setn_0  = (cfg_id_setn_en_0 == "true" || cfg_id_setn_en_0 == 1'b1) ? i_setn_0 : 1'b1;

    assign od_rstn_0  = (cfg_od_rstn_en_0 == "true" || cfg_od_rstn_en_0 == 1'b1) ? i_rstn_0 : 1'b1;
    assign od_setn_0  = (cfg_od_setn_en_0 == "true" || cfg_od_setn_en_0 == 1'b1) ? i_setn_0 : 1'b1;

    assign oen_rstn_0  = (cfg_oen_rstn_en_0 == "true" || cfg_oen_rstn_en_0 == 1'b1) ? i_rstn_0 : 1'b1;
    assign oen_setn_0  = (cfg_oen_setn_en_0 == "true" || cfg_oen_setn_en_0 == 1'b1) ? i_setn_0 : 1'b1;

//---------------------------------------------------------------------------------
//id/od/oen reg 0
//---------------------------------------------------------------------------------
    always @ (posedge i_clk_0 or negedge id_rstn_0 or negedge id_setn_0) begin
        if(~id_rstn_0)            id_reg_0 <= 0;
        else if(~id_setn_0)       id_reg_0 <= 1;
        else                      id_reg_0 <= i_id_0;
    end
	
    always @ (posedge i_clk_0 or negedge od_rstn_0 or negedge od_setn_0) begin
        if(~od_rstn_0)        od_reg_0 <= 0;
        else if(~od_setn_0)   od_reg_0 <= 1;
        else                  od_reg_0 <= i_od_0;
    end

    always @ (posedge i_clk_0 or negedge oen_rstn_0 or negedge oen_setn_0) begin
        if(~oen_rstn_0)        oen_reg_0 <= 0;
        else if(~oen_setn_0)   oen_reg_0 <= 1;
        else                   oen_reg_0 <= i_oen_0;
    end
	

//---------------------------------------------------------------------------------
//input, oen, output generation 0
//---------------------------------------------------------------------------------
	assign id_q_0[0]     = (cfg_id_sel_0 == "register" || cfg_id_sel_0 == 1'b1) ? id_reg_0 : i_id_0;
	
	assign out_en_0 = (cfg_oen_sel_0 == "register" || cfg_oen_sel_0 == 2'b11) ? oen_reg_0 :
                      (cfg_oen_sel_0 == "bypass"   || cfg_oen_sel_0 == 2'b10) ? i_oen_0   :
                      (cfg_oen_sel_0 == "gnd"      || cfg_oen_sel_0 == 2'b01) ? 1'b0      :
                      (cfg_oen_sel_0 == "vcc"      || cfg_oen_sel_0 == 2'b00) ? 1'b1      : 1'bx;
									
    assign out_data_0 = (cfg_od_sel_0 == "register" || cfg_od_sel_0 == 2'b11) ? od_reg_0 :
                        (cfg_od_sel_0 == "bypass"   || cfg_od_sel_0 == 2'b10) ? i_od_0   :
                        (cfg_od_sel_0 == "gnd"      || cfg_od_sel_0 == 2'b00) ? 1'b0     :
                        (cfg_od_sel_0 == "vcc"      || cfg_od_sel_0 == 2'b01) ? 1'b1     : 1'bx;

    assign PAD0 = ~out_en_0 ? out_data_0 : 1'bz;

//---------------------------------------------------------------------------------
//basic setting 1
//---------------------------------------------------------------------------------
	assign clk_n_1    = (cfg_fclk_inv_1 == "true" || cfg_fclk_inv_1 == 1'b1) ? ~clk_1 : clk_1;
	assign clk_ng_1   = (cfg_fclk_gate_sel_1 == "true" || cfg_fclk_gate_sel_1 == 1) ? clk_n_1 : clk_n_1 & clk_en_1 ;
	assign i_clk_1    = (cfg_fclk_en_1 == "true" || cfg_fclk_en_1 == 1) ? clk_ng_1 : 1'b0 ;

	assign i_oen_1    = (cfg_oen_inv_1 == "true"  || cfg_oen_inv_1 ==1'b1) ? ~oen_1 : oen_1;   	
	assign i_od_n_1   = (cfg_d_en_1  == "true" || cfg_d_en_1 == 1'b1) ? od_d_1[0]  : 1'b0;   	
	assign i_od_1     = (cfg_txd0_inv_1  == "true" || cfg_txd0_inv_1 == 1'b1) ? ~i_od_n_1  : i_od_n_1;   	
	assign i_id_1     = (rx_dig_en_cfg_1 == "true" || rx_dig_en_cfg_1 == 1'b1) ? PAD1 : 1'bz;

	assign i_rstn_1   = (cfg_rstn_inv_1 == "true" || cfg_rstn_inv_1 == 1'b1) ? ~rstn_1 : rstn_1;   	
	assign i_setn_1   = (cfg_setn_inv_1 == "true" || cfg_setn_inv_1 == 1'b1) ? ~setn_1 : setn_1;   	

    assign id_rstn_1  = (cfg_id_rstn_en_1 == "true" || cfg_id_rstn_en_1 == 1'b1) ? i_rstn_1 : 1'b1;
    assign id_setn_1  = (cfg_id_setn_en_1 == "true" || cfg_id_setn_en_1 == 1'b1) ? i_setn_1 : 1'b1;

    assign od_rstn_1  = (cfg_od_rstn_en_1 == "true" || cfg_od_rstn_en_1 == 1'b1) ? i_rstn_1 : 1'b1;
    assign od_setn_1  = (cfg_od_setn_en_1 == "true" || cfg_od_setn_en_1 == 1'b1) ? i_setn_1 : 1'b1;

    assign oen_rstn_1  = (cfg_oen_rstn_en_1 == "true" || cfg_oen_rstn_en_1 == 1'b1) ? i_rstn_1 : 1'b1;
    assign oen_setn_1  = (cfg_oen_setn_en_1 == "true" || cfg_oen_setn_en_1 == 1'b1) ? i_setn_1 : 1'b1;

//---------------------------------------------------------------------------------
//id/od/oen reg 1
//---------------------------------------------------------------------------------
    always @ (posedge i_clk_1 or negedge id_rstn_1 or negedge id_setn_1) begin
        if(~id_rstn_1)            id_reg_1 <= 0;
        else if(~id_setn_1)       id_reg_1 <= 1;
        else                      id_reg_1 <= i_id_1;
    end
	
    always @ (posedge i_clk_1 or negedge od_rstn_1 or negedge od_setn_1) begin
        if(~od_rstn_1)        od_reg_1 <= 0;
        else if(~od_setn_1)   od_reg_1 <= 1;
        else                  od_reg_1 <= i_od_1;
    end

    always @ (posedge i_clk_1 or negedge oen_rstn_1 or negedge oen_setn_1) begin
        if(~oen_rstn_1)        oen_reg_1 <= 0;
        else if(~oen_setn_1)   oen_reg_1 <= 1;
        else                   oen_reg_1 <= i_oen_1;
    end
	

//---------------------------------------------------------------------------------
//input, oen, output generation 1
//---------------------------------------------------------------------------------
	assign id_q_1[0]     = (cfg_id_sel_1 == "register" || cfg_id_sel_1 == 1'b1) ? id_reg_1 : i_id_1;
	
	assign out_en_1 = (cfg_oen_sel_1 == "register" || cfg_oen_sel_1 == 2'b11) ? oen_reg_1 :
                      (cfg_oen_sel_1 == "bypass"   || cfg_oen_sel_1 == 2'b10) ? i_oen_1   :
                      (cfg_oen_sel_1 == "gnd"      || cfg_oen_sel_1 == 2'b01) ? 1'b0      :
                      (cfg_oen_sel_1 == "vcc"      || cfg_oen_sel_1 == 2'b00) ? 1'b1      : 1'bx;
									
    assign out_data_1 = (cfg_od_sel_1 == "register" || cfg_od_sel_1 == 2'b11) ? od_reg_1 :
                        (cfg_od_sel_1 == "bypass"   || cfg_od_sel_1 == 2'b10) ? i_od_1   :
                        (cfg_od_sel_1 == "gnd"      || cfg_od_sel_1 == 2'b00) ? 1'b0     :
                        (cfg_od_sel_1 == "vcc"      || cfg_od_sel_1 == 2'b01) ? 1'b1     : 1'bx;

    assign PAD1 = ~out_en_1 ? out_data_1 : 1'bz;

endmodule

module M7S_POR(
     z0
);
output  z0;

assign z0 = 1;

endmodule
