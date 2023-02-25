module check_ddr_cfg_done(
	input I_sys_clk,
	input I_sys_rst_n,
	input I_ddr_rdy,
	//
	output  [31:0]O_paddr,
	output  O_pwrite,
	output  O_req,
	output  [31:0]O_pwdata,
	input I_gnt,
	input [31:0]I_prdata,
	//
	output reg O_done,
	output reg O_error,
	input I_intr,
	output reg [2:0]O_error_status,
	output reg O_error_status_en 
);

`define BIT_FSM   4

reg [`BIT_FSM-1:0]  S_machine;
reg [35:0] S_q ;
parameter  reg32_00 = 32'h00000000 ;
parameter  reg32_04 = 32'h00000000 ;
parameter  reg32_3c = 32'h00000800 ;  //bit[1]: enable bist.   
parameter  reg32_D0 = 32'h01000000 ;  //bit[24], start bist..

//
//agdbg -jreg_r 4120924c 
//agdbg -jreg_r 4120924c
//echo ======   if (4120924c[8] = 1 and 4120924c[12] = 0), then BIST PASS.    ====== 

localparam IDLE     = `BIT_FSM'b0000;
localparam REQ_DATA = `BIT_FSM'b0001;
localparam ARBIT    = `BIT_FSM'b0011;
localparam REQ_WR   = `BIT_FSM'b0010;
localparam WR_DONE  = `BIT_FSM'b0110;
localparam REQ_RD   = `BIT_FSM'b0111;
localparam RD_DONE  = `BIT_FSM'b0101;
localparam REQ_DONE = `BIT_FSM'b0100;
localparam REQ_RECC  = `BIT_FSM'b1100;
localparam RECC_DONE = `BIT_FSM'b1110;
localparam REQ_WECC  = `BIT_FSM'b1111;
localparam WECC_DONE = `BIT_FSM'b1101;

reg [2:0]S_rd_ecc_cnt;
reg [15:0]S_wait_cnt;
//wire S_wait_done = ( S_wait_cnt == 0 );

`define EOP_FLAG    3'B001
`define WR_FLAG     3'B010
`define RD_FLAG     3'B100

reg rd_done;
reg [2:0]S_cmd_type ;
reg [31:0]S_cmd_addr,S_cmd_data;
reg [31:0]S_cmd_mask;
reg  S_cmd_write ;
reg  S_cmd_req ;

reg S_desire_result;

assign O_paddr  = S_cmd_addr ;
assign O_pwdata = S_cmd_data ;
assign O_pwrite = S_cmd_write ;
assign O_req    = S_cmd_req;

//localparam
wire S_check_result = ( (|( I_prdata & S_cmd_mask )) == S_desire_result ) ;

always @( posedge I_sys_clk or negedge I_sys_rst_n ) begin
	if( !I_sys_rst_n )S_machine <= IDLE;
	else
		if( I_ddr_rdy ) begin
			case ( S_machine )
				IDLE     : S_machine <= REQ_DATA ;
				REQ_DATA : S_machine <= ( rd_done ) ? ARBIT : S_machine ;
				ARBIT    : S_machine <= ( S_cmd_type ==  `WR_FLAG   ) ? REQ_WR :
				                        ( S_cmd_type ==  `RD_FLAG   ) ? REQ_RD :
				                        ( S_cmd_type ==  `EOP_FLAG  ) ? REQ_DONE : S_machine ;
				REQ_WR   : S_machine <= WR_DONE ;
				REQ_RD   : S_machine <= RD_DONE ;
				WR_DONE  : S_machine <= ( I_gnt ) ? REQ_DATA : S_machine ;
				RD_DONE  : S_machine <= ( I_gnt ) ? ( ( S_check_result ) ? REQ_DATA : REQ_RD )  : S_machine ;
				REQ_DONE : S_machine <= ( O_done ) ? REQ_RECC : S_machine ;
				REQ_RECC : S_machine <= RECC_DONE ;
				RECC_DONE: S_machine <= ( I_gnt ) ? REQ_WECC : S_machine ;
				REQ_WECC : S_machine <= WECC_DONE ;
				WECC_DONE: S_machine <= ( I_gnt ) ? REQ_RECC : S_machine ;
				default  : S_machine <= IDLE;
			endcase
		end
end

always @( posedge I_sys_clk or negedge I_sys_rst_n ) begin
	if( !I_sys_rst_n ) S_cmd_write <= 'b0;
	else
		if( I_ddr_rdy ) begin 
			case ( S_machine )
				IDLE     : S_cmd_write <= 'b0 ;
				REQ_DATA : S_cmd_write <= 'b0 ;
				ARBIT    : S_cmd_write <= 'b0 ;
				REQ_WR   : S_cmd_write <= 'b1 ;
				REQ_RD   : S_cmd_write <= 'b0 ;
				WR_DONE  : S_cmd_write <= ( I_gnt ) ? 1'b0 : S_cmd_write ;
				RD_DONE  : S_cmd_write <= 'b0 ;
				REQ_DONE : S_cmd_write <= 'b0 ;
				REQ_RECC : S_cmd_write <= 'b0 ;
				REQ_WECC : S_cmd_write <= 'b1 ;
				default  : S_cmd_write <= S_cmd_write ;
			endcase
	end
end

always @( posedge I_sys_clk or negedge I_sys_rst_n ) begin 
	if( !I_sys_rst_n ) S_cmd_req <= 1'b0;
	else
		if( I_ddr_rdy ) begin
			case ( S_machine )
				IDLE     : S_cmd_req <= 1'b0 ; 
				REQ_DATA : S_cmd_req <= 1'b0 ; 
				ARBIT    : S_cmd_req <= 1'b0 ; 
				REQ_WR   : S_cmd_req <= 1'b1 ; 
				REQ_RD   : S_cmd_req <= 1'b1 ; 
				WR_DONE  : S_cmd_req <= ( I_gnt ) ? 1'b0 : S_cmd_req ; 
				RD_DONE  : S_cmd_req <= ( I_gnt ) ? 1'b0 : S_cmd_req ; 
				REQ_DONE : S_cmd_req <= 1'b0 ;
				REQ_RECC : S_cmd_req <= 1'b1 ;
				REQ_WECC : S_cmd_req <= 1'b1 ; 
				RECC_DONE: S_cmd_req <= ( I_gnt ) ? 1'b0 : S_cmd_req ; 
				WECC_DONE: S_cmd_req <= ( I_gnt ) ? 1'b0 : S_cmd_req ; 
				default  : S_cmd_req <= 1'b0 ; 
			endcase
		end
end

always @( posedge I_sys_clk or negedge I_sys_rst_n ) begin 
	if( !I_sys_rst_n ) rd_done <= 1'b0 ; 
	else
		case ( S_machine )
			REQ_DATA : rd_done <= 1'b1 ; 
			default : rd_done <= 1'b0 ; 
		endcase
end

always @( posedge I_sys_clk or negedge I_sys_rst_n ) begin
	if( !I_sys_rst_n ) S_cmd_type <= `EOP_FLAG;
	else
		case ( S_machine )
			REQ_DATA : S_cmd_type <= S_q[34:32] ;
			default : S_cmd_type <= S_cmd_type ;
		endcase
end

always @( posedge I_sys_clk or negedge I_sys_rst_n ) begin
	if( !I_sys_rst_n ) S_cmd_addr <= 'B0;
	else 
		case ( S_machine )
			REQ_DATA : S_cmd_addr <= S_q[31:0] ;			
			default : S_cmd_addr <= S_cmd_addr ;
		endcase
end

always @( posedge I_sys_clk or negedge I_sys_rst_n ) begin
	if( !I_sys_rst_n ) S_cmd_data <= 'B0 ;
	else
		case ( S_machine )
			ARBIT   : S_cmd_data <= S_q[31:0]  ;
			REQ_WECC: S_cmd_data <= { S_q[31:27],O_error_status, S_q[23:0] }  ;
			default : S_cmd_data <= S_cmd_data ;
		endcase
end

always @( posedge I_sys_clk or negedge I_sys_rst_n ) begin
	if( !I_sys_rst_n ) S_cmd_mask <= 'B0 ;
	else 
		case ( S_machine )
			ARBIT  : S_cmd_mask <= S_q[31:0]  ;
			default: S_cmd_mask <= S_cmd_mask ;
		endcase
end

always @( posedge I_sys_clk or negedge I_sys_rst_n ) begin
	if( !I_sys_rst_n ) S_desire_result <= 'B0 ;
	else
		case ( S_machine )
			ARBIT   : S_desire_result <= S_q[35]  ;
			default: S_desire_result <= S_desire_result ;
		endcase
end

`define SUM_STEP_WIDTH   5 
reg [`SUM_STEP_WIDTH-1:0]S_data_cnt ;
always @( posedge I_sys_clk or negedge I_sys_rst_n ) begin
	if( !I_sys_rst_n ) S_data_cnt <= { `SUM_STEP_WIDTH {1'B0} } ;
	else
		case ( S_machine )
			REQ_DATA : S_data_cnt <= S_data_cnt + 1 ;
			default : S_data_cnt <= S_data_cnt ;
		endcase
		end

always @( posedge I_sys_clk ) begin
	case ( S_data_cnt )
		//DDR23 controller
		// r_ddr_mode = bit[1:0], 00: DDR3, 01: DDR2, 11: LPDDR2.
		// r_bl4 = bit[2], 0: BL8, 1: BL4.
		// r_refresh_en=bit[4],
		// r_refresh_dis = bit[5].
		// r_pd_enable= bit[6].
		// r_col_addr_width = bit[9:8]
		//       00 : DRAM Column address 10bits.
		//       01 : DRAM Column address 11bits.
		//       10 : DRAM Column address 12bits.
		//       11 : DRAM Column address 9bits.
		// r_4bank = bit[10], 0: DRAM 8 Banks, 1: DRAM 4 banks.
		// r_ecc_enable = bit[11],
		// r_rstctl_rst2cke = bit[31:12] 
		`SUM_STEP_WIDTH'd0 : S_q <= { 1'B0, `WR_FLAG ,32'H41209000 };  //enable ddr23 controller.
		`SUM_STEP_WIDTH'd1 : S_q <= { 4'H0, { reg32_00[31:1] , 1'b1 } }; //Enable DDR23Ctrl=bit[0],
		`SUM_STEP_WIDTH'd2 : S_q <= { 1'B0, `RD_FLAG ,32'H4120906c };  //read only register,
		`SUM_STEP_WIDTH'd3 : S_q <= { 4'H8, 32'H40000000 };//waiting for MRS Command is DONE ...
		`SUM_STEP_WIDTH'd4 : S_q <= { 1'B0, `RD_FLAG ,32'H4120906c };  //read only register,
		`SUM_STEP_WIDTH'd5 : S_q <= { 4'H8, 32'H80000000 };//waiting for DFI_INIT_COMPLETE signal from PHY is DONE,
		`SUM_STEP_WIDTH'd6 : S_q <= { 1'B0, `WR_FLAG ,32'H4120903C };  //enable bist
		`SUM_STEP_WIDTH'd7 : S_q <= { 4'H0, { reg32_3c[31:2] , 1'b1, reg32_3c[0] } }; //Enable bist = bit[1],
		`SUM_STEP_WIDTH'd8 : S_q <= { 1'B0, `WR_FLAG ,32'H412090D0 };  //start bist
		`SUM_STEP_WIDTH'd9 : S_q <= { 4'H0, 32'H01000000 }; // start bist = bit[24],
		`SUM_STEP_WIDTH'd10 : S_q <= { 1'B0, `RD_FLAG ,32'H4120924c };  //read only register,
		`SUM_STEP_WIDTH'd11 : S_q <= { 4'H8, 32'H80000000 };// BIST FINISH = BIT[31]; BIST OK = bit[8], 1: OK, 0: Fail,
		`SUM_STEP_WIDTH'd12 : S_q <= { 1'B0, `RD_FLAG ,32'H4120924c };  //read only register,
//		`SUM_STEP_WIDTH'd13 : S_q <= { 4'H8, 32'H00000100 }; // BIST OK = bit[8], 1: OK, 0: Fail,
		`SUM_STEP_WIDTH'd13 : S_q <= { 4'H0, 32'H00000000 }; // BIST OK = bit[8], 1: OK, 0: Fail,
		`SUM_STEP_WIDTH'd14 : S_q <= { 1'B0, `WR_FLAG ,32'H412090D0 };  //start bist
		`SUM_STEP_WIDTH'd15 : S_q <= { 4'H0, 32'H00000000 }; // start bist = bit[24],
		`SUM_STEP_WIDTH'd16 : S_q <= { 1'B0, `WR_FLAG ,32'H4120903C };  //enable bist 
		`SUM_STEP_WIDTH'd17 : S_q <= { 4'H0, { reg32_3c[31:27] ,3'b111,reg32_3c[23:2], 1'b0, reg32_3c[0] } }; //Enable bist = bit[1], 0: normal ; 
		`SUM_STEP_WIDTH'd18 : S_q <= { 1'B0, `EOP_FLAG,32'H4120903C }; //End Config.
		`SUM_STEP_WIDTH'd19 : S_q <= { 4'H0, { reg32_3c[31:27],3'B000, reg32_3c[23:0] } };//
	endcase
end


always @( posedge I_sys_clk or negedge I_sys_rst_n ) begin
	if( !I_sys_rst_n ) O_done <= 1'b0 ;
	else
		case ( S_machine )
		    IDLE     : O_done <= 1'b0 ;
			REQ_DONE : O_done <= ( S_wait_cnt[15] ) ? 1'b1 : O_done ;
			default : O_done <= O_done ;
		endcase	
end

reg S_error;
always @( posedge I_sys_clk or negedge I_sys_rst_n ) begin
	if( !I_sys_rst_n ) S_error <= 1'b0 ;
	else
		case ( S_machine )
			RD_DONE : S_error <= ( I_gnt ) ? I_prdata[8] : S_error ;
		endcase
end

always @( posedge I_sys_clk or negedge I_sys_rst_n ) begin
	if( !I_sys_rst_n ) O_error <= 1'b0 ;
	else  O_error <= S_error ;
end

always @( posedge I_sys_clk or negedge I_sys_rst_n ) begin
	if( !I_sys_rst_n ) S_wait_cnt <= 'b0 ;
	else
		case ( S_machine )
			REQ_DONE : S_wait_cnt <= S_wait_cnt + 1'b1 ;
			default : S_wait_cnt <= 'b0 ;
		endcase	
end

//always @( posedge I_sys_clk or negedge I_sys_rst_n ) begin
//	if( !I_sys_rst_n ) S_rd_ecc_cnt <= 'b0 ;
//	else
//		case ( S_machine )
//			REQ_DONE : S_rd_ecc_cnt <= S_rd_ecc_cnt + 1'b1 ;
//			default : S_rd_ecc_cnt <= 'b0 ;
//		endcase	
//end



//O_ecc_status,
//O_ecc_status_en 
always @( posedge I_sys_clk or negedge I_sys_rst_n ) begin
	if( !I_sys_rst_n ) O_error_status <= 'b0 ;
	else
		case ( S_machine )
			RECC_DONE: O_error_status <= ( I_gnt ) ? I_prdata[26:24] : O_error_status ;
			default : O_error_status <= O_error_status ;
		endcase	
end

always @( posedge I_sys_clk or negedge I_sys_rst_n ) begin
	if( !I_sys_rst_n ) O_error_status_en <= 'b0 ;
	else
		case ( S_machine )
			RECC_DONE : O_error_status_en <= ( I_gnt & reg32_04[11] ) ;
			default   : O_error_status_en <= 'b0 ;
		endcase	
end

	
endmodule
