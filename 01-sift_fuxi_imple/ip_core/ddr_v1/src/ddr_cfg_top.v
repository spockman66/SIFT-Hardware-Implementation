module ddr_cfg_top(
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
	output reg O_done	
);

reg [2:0]S_machine;
reg [11:0]S_addr;
reg [35:0] S_q ;

//localparam IDLE     = 0;
//localparam REQ_DATA = 1;
//localparam ARBIT    = 2;
//localparam REQ_WR   = 3;
//localparam WR_DONE  = 4;
//localparam REQ_RD   = 5;
//localparam RD_DONE  = 6;
//localparam REQ_DONE = 7;

localparam IDLE     = 3'b000;
localparam REQ_DATA = 3'b001;
localparam ARBIT    = 3'b011;
localparam REQ_WR   = 3'b010;
localparam WR_DONE  = 3'b110;
localparam REQ_RD   = 3'b111;
localparam RD_DONE  = 3'b101;
localparam REQ_DONE = 3'b100;

reg [31:0]S_wait_cnt;
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
//reg S_check_result;

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
				REQ_DONE : S_machine <= S_machine ;
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
				default  : S_cmd_write <= 'b0 ; 
			endcase 
		end
end

always @( posedge I_sys_clk or negedge I_sys_rst_n ) begin
	if( !I_sys_rst_n ) S_cmd_req <= 'b0;
	else 
		if( I_ddr_rdy ) begin
			case ( S_machine )
				IDLE     : S_cmd_req <= 'b0 ;
				REQ_DATA : S_cmd_req <= 'b0 ;
				ARBIT    : S_cmd_req <= 'b0 ; 
				REQ_WR   : S_cmd_req <= 'b1 ;
				REQ_RD   : S_cmd_req <= 'b1 ; 
				WR_DONE  : S_cmd_req <= ( I_gnt ) ? 1'b0 : S_cmd_req ;
				RD_DONE  : S_cmd_req <= ( I_gnt ) ? 1'b0 : S_cmd_req ;
				REQ_DONE : S_cmd_req <= 'b0 ; 
				default  : S_cmd_req <= 'b0 ; 
			endcase 
		end
end


always @( posedge I_sys_clk or negedge I_sys_rst_n ) begin
	if( !I_sys_rst_n ) rd_done <= 1'b0 ;
	else 
		case ( S_machine )
			REQ_DATA : rd_done <= 1'b1 ;
			default  : rd_done <= 1'b0 ;
		endcase 
end

always @( posedge I_sys_clk or negedge I_sys_rst_n ) begin
	if( !I_sys_rst_n ) S_cmd_type <= `EOP_FLAG;
	else 
		case ( S_machine )
			REQ_DATA : S_cmd_type <= S_q[34:32] ;
			default  : S_cmd_type <= S_cmd_type ;
		endcase 
end

always @( posedge I_sys_clk or negedge I_sys_rst_n ) begin
	if( !I_sys_rst_n ) S_cmd_addr <= 'B0;
	else 
		case ( S_machine )
			REQ_DATA : S_cmd_addr <= S_q[31:0]  ;
			default  : S_cmd_addr <= S_cmd_addr ;
		endcase 
end

always @( posedge I_sys_clk or negedge I_sys_rst_n ) begin
	if( !I_sys_rst_n ) S_cmd_data <= 'B0 ;
	else 
		case ( S_machine )
			ARBIT   : S_cmd_data <= S_q[31:0]  ;
			default : S_cmd_data <= S_cmd_data ;
		endcase 
end

always @( posedge I_sys_clk or negedge I_sys_rst_n ) begin
	if( !I_sys_rst_n ) S_cmd_mask <= 'B0 ;
	else 
		case ( S_machine )
			ARBIT   : S_cmd_mask <= S_q[31:0]  ;
			default : S_cmd_mask <= S_cmd_mask ;
		endcase 
end

always @( posedge I_sys_clk or negedge I_sys_rst_n ) begin
	if( !I_sys_rst_n ) S_desire_result <= 'B0 ;
	else 
		case ( S_machine )
			ARBIT   : S_desire_result <= S_q[35]  ;
			default : S_desire_result <= S_desire_result ;
		endcase 
end

`define SUM_STEP_WIDTH   8
reg [`SUM_STEP_WIDTH-1:0]S_data_cnt ;
always @( posedge I_sys_clk or negedge I_sys_rst_n ) begin
	if( !I_sys_rst_n ) S_data_cnt <= { `SUM_STEP_WIDTH {1'B0} } ;
	else 
		case ( S_machine )
			REQ_DATA : S_data_cnt <= S_data_cnt + 1 ;
			default  : S_data_cnt <= S_data_cnt ;
		endcase
end



always @( posedge I_sys_clk ) begin
	case ( S_data_cnt )
		`SUM_STEP_WIDTH'd0 : S_q <= { 1'B0, `WR_FLAG ,32'H41209050 }; //system pll option register..
		`SUM_STEP_WIDTH'd1 : S_q <= { 4'H0, 32'H60000000 };
		
		/* DDR PHY setting, reserved  */
		`SUM_STEP_WIDTH'd2 : S_q <= { 1'B0, `WR_FLAG ,32'H41209100 }; //
		`SUM_STEP_WIDTH'd3 : S_q <= { 4'H0, 32'H42000000 };
		/*
			DDR PHY setting 
			bit0: DDR3 mode setting. ( 0: DDR2 mode ; 1: DDR3 mode or loopback bist mode ).
			bit1: DDR PHY Write data delay,
			bit2: DDR AUX Power saving mode,
			bit3: reserved and shall be 0.
			bit7-4 : DDR PHY Read Valid timing.
			bit8: DDR IO command address signal Power saving to tri-state output commands signals when csn is deasserted( 0: normal ; 1: tri-state ).
			bit9: DDR PHY Read Data FIFO reset, this control is only used for diagmosis purpose( 0: normal; 1: For Diagnosis mode ).
			bit10: DDR PHY Read Valid timing manual mode,( 0: aotomatic mode; 1: manual mode ).
			bit13-11 : DDR IO ODT Register setting
			     ( for DDR3 [A9,A6,A2] means: 000: ODT disable; 001: 120 OHm; 010: 60 OHm; 011 : 40 OHm ; other: reserved )
				 ( for DDR2 [A9,A6,A2] means: 000: ODT disable; 001: 150 OHm; 010: 75 OHm; 011 : 50 OHm ; other: reserved )
			bit15-14 : reserved for future use, shall be logic-0.
			bit18-16 : DDR PHY read ODT Setting, Read ODT control signal enable delay after DFI read command.
			     000: Delay 2T MC_CLK ; 001: Delay 3T MC_CLK ; 010: Delay 4T MC_CLK ; ... ; 110: Delay 8T MC_CLK ; 111:  Delay 2T MC_CLK ;
			bit19 : DDR PHY read ODT Always On, Read ODT always turned On(0: Not always On ; 1: Always On ).
			bit20 : DDR PHY Delay Calibration Enable, Delay calibration function enable,( 0: disable ; 1: enable ).
			bit21 : DDR PHY Quick simulation mode ( 0: normal mode, 1: quick simulation mode ; For real silicon, this bit shall be 0 ).
			bit23-22 : reserved, shall be logic 0,
			bit24 : reserved, shall be logic 0,
			bit25 : DDR Controller Training Mode, Choose train procedure from controller or PHY( 0 : PHY training Mode, 1: Controller training mode ),
			bit27-26 : reserved, shall be logic 0,
			bit28 : DDR2 mode select, ( 0: DDR3, 1: DDR2 ),
			bit31-29 : reserved, shall be logic 0,
		*/
		`SUM_STEP_WIDTH'd4 : S_q <= { 1'B0, `WR_FLAG ,32'H41209104 }; 
		`SUM_STEP_WIDTH'd5 : S_q <= { 4'H0, 32'H02080c51 };
		/* 
			DDR PHY PLL Setting,
			reg_phy_pll[31:0]
			bit7-0  :  M[7:0],       00000111
			bit12-8 :  N[4:0],          00111
			bit18-13:  P[5:0],         000000
			bit20-19:  LKSEL[1:0],         00
			bit25-21:  SIP[4:0],        00110
			bit30-26:  SIC[4:0],        01100
			bit31   :  FSE                  0
		*/
		`SUM_STEP_WIDTH'd6 : S_q <= { 1'B0, `WR_FLAG ,32'H4120910c }; //pll
		`SUM_STEP_WIDTH'd7 : S_q <= { 4'H0, 32'H55e00a0a };
		/* 
		    DLL PHY DLL Setting,
			reg_phy_dll[31:0]
			bit28-0 : reserved, shall be logic-0,
			bit29   :  0 : Slower or equal to DDR-800 Mbps ; 1 : fater than DDR-800Mbps,
			bit31-30: reserved, shall be logic-0,
		*/
		`SUM_STEP_WIDTH'd8 : S_q <= { 1'B0, `WR_FLAG ,32'H41209110 }; //dll
		`SUM_STEP_WIDTH'd9 : S_q <= { 4'H0, 32'Ha0000164 };
		
		/*
		    DDR PHY Setting, page 44 in DDR PHY SPEC .
			bit0 : reg_phy_pll_bypass, enabled, following clock shll be applied from SOC extern PIN, 
			    mc_clk ( memory controller clock )
				pll_bypass_phy_clk2x ( 2 times of DDR_CK bus differential clock speed, 4times of mc_clk speed )
				 NOTE1 : if PLL bypass mode is enable, the PLL bypass setting shall also be set( reg_phy_pll[14] BP setting )
				 NOTE2 : Could tie to logic-0 is not used by user.
			bit1 : PLL Test Mode, if pll test mode is enabled, PLL data rate clock divided by 32 will be output to DDR_BANK[0] for observation,
			        0: normal mode; 1: pll test mode ;
			bit7-2 : reg_phy_databusy_cnt_intg[5:0], DDR PHY DLL update setting, 000000: recommended value .
			bit8 : DLL Bypass mode Bypass dll for low speed function test purpose, 
			      Note1: could tie to logic-0 if not used,
				  Note2: During bypass dll mode there are 2 limitations
				        a) maximum data rate 80MHz;
						b) Read DQS/DQ wave shall be central alignment instead of edge alignment because dll is by-pass.
			bit9 : reg-training_manual_mode, 
			        0 :  traing manual mode is disable, using DFI train mode;
					1 :  traing manual mode is enabled.
			bit15-10 : reserved for future, shall be logic-0,
			bit31-16 : reg_phy_data_byte[N-1:0]_pwr_dn, Data Module power down, Each data module can be power down independently
			        0 :  normal;   1: Data module  power down ;			  
		*/
		`SUM_STEP_WIDTH'd10 : S_q <= { 1'B0, `WR_FLAG ,32'H41209114 };
		`SUM_STEP_WIDTH'd11 : S_q <= { 4'H0, 32'H00000824 };
		
		/*
		    DDR PHY setting, page 46 in DDR PHY SPEC .
		    bit0 : reg_cal_disable, Auto-calibration disable
			        0 : Enable auto-calibration ( recommended ) ; 1 : disable auto-calibration ;
			bit1 : reg_cal_manual_mode, Calibrion Manual mode enable, when manual mode is enabled, the IO buffer will use reg_cal_default_pu and reg_cal_default_pd setting value instead of auto-calibrated values.
			        0 : Disable manual mode ; 1: enable manual mode ;
			bit2 : reg_cal_manual_pwrdn, Auto-calibration Circuit Power Down , Power down auto-calibraton circuit, the power down control could be enabled if auto-calibraion is disable,
			        0 : Power On auto-calibraton circuit ( recommended )
					1 : Power Down auto-calibration circuit,
			bit3 : reg_lb_bist_start, Loop Back BIST Mode Start Command Bit, 
			        0: inactive ; 1: start to do loop back BIST test ,
			bit4 : reg_lb_bist_internal, Loop back BIST mode setting ,
			        0 : Extern loop back ; 1 : Internal loop back ;
			bit7-5 : PHY RDDV Selection 
			        000 : train value +3 ; 001 : train value +1 ; 010 : train value +2 ; 011 : train value +3 ; ... 
			bit15-8 : reg_lb_bist_eye_rdqs[7:0], Loop back mode DLL setting,
			          User shall set this DLL value to adjust read data eye margin during loop back BIST mode, the value shall be set as 1/2T DDR_CK delay to let DQS sample at the center of DQ data eye during loopback mode.
			bit19-16 : reg_cal0_offset_pu, Calibration 0 offset Value PU[3:0] .
			             the offset value adjustment for auto-calibated value apply to I0 buffer .
						 reg_cal0_offset_pu[3]
						   0 : Means minus offset value .
						   1 : Means add offset value .
						 reg_cal0_offset_pu[2:0]: offset value .
						 0000b : Default .
						 Note : There will be K sets of calibration offset/default/ro values for different kind of DQ configuration .
						   DQ16,32 : K=1( only one set )
						   DQ64 : K=2
						   DQ128: K=4
			bit23-20 : reg_cal0_offset_pd, Calibration 0 offset value PD[3:0] .
			             the offset value adjustment for auto-calibrated value apply to IO buffer .
						 reg_cal0_offset_pd[3]
						    0 : Means minus offset value .
							1 : Means add offset value .
						 reg_cal0_offset_pd[2:0]: offset value
						   0000b: default
						 Note : There will be K sets of calibration offset/default/ro values for different kind of DQ configuration .
						   DQ16,32 : K=1( only one set )
						   DQ64 : K=2
						   DQ128: K=4
			bit27-24 : reg_cal0_default_pu, Calibration: 0 Value PU[3:0] for manual mode,
			             PU values for IO when calibration manual mode enabled.
						   0101b : Recommend for manual mode.
						   Don't care : For auto-calibration mode .
						  Note : There will be K sets of calibration offset/default/ro values for different kind of DQ configuration .
						   DQ16,32 : K=1( only one set )
						   DQ64 : K=2
						   DQ128: K=4
			bit31-28 : reg_cal0_default_pd, Calibration: 0 Value PD[3:0] for manual mode,
			             PU values for IO when calibration manual mode enabled.
						   0101b : Recommend for manual mode.
						   Don't care : For auto-calibration mode .
						  Note : There will be K sets of calibration offset/default/ro values for different kind of DQ configuration .
						   DQ16,32 : K=1( only one set )
						   DQ64 : K=2
						   DQ128: K=4
		*/
		`SUM_STEP_WIDTH'd12 : S_q <= { 1'B0, `WR_FLAG ,32'H41209140 };
		`SUM_STEP_WIDTH'd13 : S_q <= { 4'H0, 32'H86000000 };
		/*
		   DDR PHY setting, page 48 in DDR PHY SPEC .
		   bit3-0  : reg_cal1_offset_pu, Calibration 1 offset Value PU[3:0] .
			             the offset value adjustment for auto-calibated value apply to I0 buffer .
						 reg_cal0_offset_pu[3]
						   0 : Means minus offset value .
						   1 : Means add offset value .
						 reg_cal0_offset_pu[2:0]: offset value .
						 0000b : Default .
						 Note : There will be K sets of calibration offset/default/ro values for different kind of DQ configuration .
						   DQ16,32 : K=1( only one set )
						   DQ64 : K=2
						   DQ128: K=4
		   bit7-4  : reg_cal1_offset_pd, Calibration 1 offset value PD[3:0] .
			             the offset value adjustment for auto-calibrated value apply to IO buffer .
						 reg_cal0_offset_pd[3]
						    0 : Means minus offset value .
							1 : Means add offset value .
						 reg_cal0_offset_pd[2:0]: offset value
						   0000b: default
						 Note : There will be K sets of calibration offset/default/ro values for different kind of DQ configuration .
						   DQ16,32 : K=1( only one set )
						   DQ64 : K=2
						   DQ128: K=4
		   bit11-8 : reg_cal1_default_pu, Calibration: 1 Value PU[3:0] for manual mode,
			             PU values for IO when calibration manual mode enabled.
						   0101b : Recommend for manual mode.
						   Don't care : For auto-calibration mode .
						  Note : There will be K sets of calibration offset/default/ro values for different kind of DQ configuration .
						   DQ16,32 : K=1( only one set )
						   DQ64 : K=2
						   DQ128: K=4
		   bit15-12: reg_cal1_default_pd, Calibration: 1 Value PD[3:0] for manual mode,
			             PU values for IO when calibration manual mode enabled.
						   0101b : Recommend for manual mode.
						   Don't care : For auto-calibration mode .
						  Note : There will be K sets of calibration offset/default/ro values for different kind of DQ configuration .
						   DQ16,32 : K=1( only one set )
						   DQ64 : K=2
						   DQ128: K=4
		   bit16   : reg_wrdata1t_case, Write Data delay 1T.
		   bit17   : reg_lowspeed_case, Read Data and Read Data Valid early 1T.
		   bit19-18: reserved for future use , input shall be logic-0 .
		   bit20   : reg_init_start_after_cmplt, Auto initial start after every mc_clk_rst_n, 
		   bit21   : reg_lb_bist_DDR23phy, Write Data enable early 1T for DDR23PHY Loop Back BIST.
		   bit27-22: reserved for future use , input shall be logic-0 .
		   bit31-28: reg_lb_bist_chk_result, Loopback Result Select
		              if set if to N, loopback result of datamodule N will be reported
					     reg_ro_lb_rdata_gld = reg_ro_lbN_rdata_gld ;
						 reg_ro_lb_rdata_err = reg_ro_lbN_rdata_err ;
						 reg_ro_lb_cmp_timer = reg_ro_lbN_cmp_timer ;
					  0000b : default .						 
		*/
		`SUM_STEP_WIDTH'd14 : S_q <= { 1'B0, `WR_FLAG ,32'H41209144 };
		`SUM_STEP_WIDTH'd15 : S_q <= { 4'H0, 32'H00008600 };
		/*
		   DDR PHY setting, Page 50 in DDR PHY SPEC .
		   bit3-0  : 
		   bit7-4  : reserved for future used, input shall be logic-0 .
		   bit11-8 :
		   bit15-12: reserved for future used, input shall be logic-0 .
		   bit19-16: reg_lb_bist[N-1]_errinjec, 
		   bit23-20: reserved for future used, input shall be logic-0 .
		   bit31-24: reg_ad_dll_deye_wdqsn, DDR PHY CA Phase Adjustment .
		              this setting will be applied to ca module for ca operation .
					  Definition:
					    1) Delay setting 0 to FF(hex) means 0T, (1/256)x(1/2)T to (255/256)x(1/2)T DDR _CK cycle delay.
						2) Recommend setting is "80(hex)" (which is 1/4T DDR_CK clock cycle ).
		*/
		`SUM_STEP_WIDTH'd16 : S_q <= { 1'B0, `WR_FLAG ,32'H41209148 };
		`SUM_STEP_WIDTH'd17 : S_q <= { 4'H0, 32'H80000000 };
		/*
		   DDR PHY Setting , Page 51 in DDR PHY SPEC .
		   bit7-0  : reg_db_[0]_dll_deye_wdqsn[7:0], DDR PHY write DQS to DQ phase adjustment, The write DQS to DQ phase delay adjustment.
		             This setting will be applied to all data modules for write operation.
					 Definition:
					    1) Delay setting 0 to FF(hex) means 0T, (1/256)x(1/2)T to (255/256)x(1/2)T DDR _CK cycle delay.
						2) Recommend setting is "80(hex)" (which is 1/4T DDR_CK clock cycle ).  
		   bit15-8 : reg_db_[1]_dll_deye_wdqsn[7:0], DDR PHY write DQS to DQ phase adjustment, The write DQS to DQ phase delay adjustment.
		             This setting will be applied to all data modules for write operation.
					 Definition:
					    1) Delay setting 0 to FF(hex) means 0T, (1/256)x(1/2)T to (255/256)x(1/2)T DDR _CK cycle delay.
						2) Recommend setting is "80(hex)" (which is 1/4T DDR_CK clock cycle ). 
		   bit23-16: reg_db_[2]_dll_deye_wdqsn[7:0], DDR PHY write DQS to DQ phase adjustment, The write DQS to DQ phase delay adjustment.
		             This setting will be applied to all data modules for write operation.
					 Definition:
					    1) Delay setting 0 to FF(hex) means 0T, (1/256)x(1/2)T to (255/256)x(1/2)T DDR _CK cycle delay.
						2) Recommend setting is "80(hex)" (which is 1/4T DDR_CK clock cycle ). 
		   bit31-24: reg_db_[3]_dll_deye_wdqsn[7:0], DDR PHY write DQS to DQ phase adjustment, The write DQS to DQ phase delay adjustment.
		             This setting will be applied to all data modules for write operation.
					 Definition:
					    1) Delay setting 0 to FF(hex) means 0T, (1/256)x(1/2)T to (255/256)x(1/2)T DDR _CK cycle delay.
						2) Recommend setting is "80(hex)" (which is 1/4T DDR_CK clock cycle ). 
		*/
		`SUM_STEP_WIDTH'd18 : S_q <= { 1'B0, `WR_FLAG ,32'H4120914c };
		`SUM_STEP_WIDTH'd19 : S_q <= { 4'H0, 32'H80808080 };
		/*
		   DDR PHY Setting , Page 51 in DDR PHY SPEC .
		   bit7-0  : reg_db_[4]_dll_deye_wdqsn[7:0], DDR PHY write DQS to DQ phase adjustment, The write DQS to DQ phase delay adjustment.
		             This setting will be applied to all data modules for write operation.
					 Definition:
					    1) Delay setting 0 to FF(hex) means 0T, (1/256)x(1/2)T to (255/256)x(1/2)T DDR _CK cycle delay.
						2) Recommend setting is "80(hex)" (which is 1/4T DDR_CK clock cycle ).  
		   bit15-8 : reg_db_[5]_dll_deye_wdqsn[7:0], DDR PHY write DQS to DQ phase adjustment, The write DQS to DQ phase delay adjustment.
		             This setting will be applied to all data modules for write operation.
					 Definition:
					    1) Delay setting 0 to FF(hex) means 0T, (1/256)x(1/2)T to (255/256)x(1/2)T DDR _CK cycle delay.
						2) Recommend setting is "80(hex)" (which is 1/4T DDR_CK clock cycle ). 
		   bit23-16: reg_db_[6]_dll_deye_wdqsn[7:0], DDR PHY write DQS to DQ phase adjustment, The write DQS to DQ phase delay adjustment.
		             This setting will be applied to all data modules for write operation.
					 Definition:
					    1) Delay setting 0 to FF(hex) means 0T, (1/256)x(1/2)T to (255/256)x(1/2)T DDR _CK cycle delay.
						2) Recommend setting is "80(hex)" (which is 1/4T DDR_CK clock cycle ). 
		   bit31-24: reg_db_[7]_dll_deye_wdqsn[7:0], DDR PHY write DQS to DQ phase adjustment, The write DQS to DQ phase delay adjustment.
		             This setting will be applied to all data modules for write operation.
					 Definition:
					    1) Delay setting 0 to FF(hex) means 0T, (1/256)x(1/2)T to (255/256)x(1/2)T DDR _CK cycle delay.
						2) Recommend setting is "80(hex)" (which is 1/4T DDR_CK clock cycle ). 
		*/
		`SUM_STEP_WIDTH'd20 : S_q <= { 1'B0, `WR_FLAG ,32'H41209150 };
		`SUM_STEP_WIDTH'd21 : S_q <= { 4'H0, 32'H80808080 };
		
		/*
			
		   MLB Training Setting.
		   bit0 : MLB training start ,for MLB Training Mode User shall set this bit to 1 then clear to 0 to create a trigger event to start GUC MLB training after all related setting are set properly.
		   bit1 : MLB gate training disable, 
		          0 :  recommended ; 1 : to disable GUC MLB training mode gate training.
		   bit2 : MLB read data eye training enable or disable
		          0 : enable ; 1 : disable .
		   bit3 : MLB gate training fast mode.
		          0 : normal ; 1: fast mode, ( only for simulation ).   
		   bit16-5 :  reserved for future use , input shall be logic-0.
		   bit17 : MLB gate training resullt minus offset value,  Minus or Add reg_train_delay_offset value to GUC MLB gate training result
		          0 : Add offset value ;  1: Minus offset value .
		   bit18 : MLB read data eye training result minus offset value , Minus or Add reg_mlb_train_deye_delay_offset value to GUC MLB gate training result.
		          0 : Add offset value ;  1: Minus offset value .
		   bit19 : MLB write data eye training result minus offset value, Minus or Add reg_mlg_train_wdsq_delay_offset value to GUC MLB gate training reslut.
		          0 : Add offset value ;  1: Minus offset value .
		   bit20 : Choose data training mode to do gate/read data eye training.
		          0 : Use MPR training mode ( recommended )
				  1 : Use data training mode
		   bit21 : Choose dqs training mode to do gate training
		          0 : Use MPR/data training mode do gate training ( recommended )
				  1 : Use dqs training mode do gate training.
		   other : reseved for future use, input shall be logic-0.		    
			
		*/
		`SUM_STEP_WIDTH'd22 : S_q <= { 1'B0, `WR_FLAG ,32'H41209190 };
		`SUM_STEP_WIDTH'd23 : S_q <= { 4'H0, 32'H00100008 };
		
		/*
		   MLB Training Status. Page 64 in DDR PHY SPEC .
		   reg_ro_mlb_train_db[N-1:0]_deye_result[7:0], 
		   C0h ~ C4h : MLB read data eye training reslut. the offset adjustment will be include 
		               1) [N-1] means setting for data module [N-1].
					   2) reg_ro_mlb_train_db*_deye_reslut[7:0]: fine-tune phase delay setting .
		*/
		`SUM_STEP_WIDTH'd24 : S_q <= { 1'B0, `WR_FLAG ,32'H412091c0 };
		`SUM_STEP_WIDTH'd25 : S_q <= { 4'H0, 32'H00000001 };
		
		/*
		    MLB initialize Setting, Page 52 in DDR PHY SPEC .
			bit15-0  : MLB initialize MRS2 setting ;
			bit31-16 : MLB initialize MRS3 setting ;
		*/
		`SUM_STEP_WIDTH'd26 : S_q <= { 1'B0, `WR_FLAG ,32'H41209180 };
		`SUM_STEP_WIDTH'd27 : S_q <= { 4'H0, 32'H00000018 };
		/*
		    MLB initialize Setting, Page 52 in DDR PHY SPEC .
			bit15-0  : MLB initialize MRS1 setting ;
			bit31-16 : MLB initialize MRS0 setting ;
		*/
		`SUM_STEP_WIDTH'd28 : S_q <= { 1'B0, `WR_FLAG ,32'H41209184 };
		`SUM_STEP_WIDTH'd29 : S_q <= { 4'H0, 32'H1d700046 };
		/*
		    MLB initialize Setting, Page 52 in DDR PHY SPEC .
			bit15-0  : MLB initialize MRS4 setting ;
			bit31-16 : MLB initialize MRS5 setting ;
		*/
		`SUM_STEP_WIDTH'd30 : S_q <= { 1'B0, `WR_FLAG ,32'H41209188 };
		`SUM_STEP_WIDTH'd31 : S_q <= { 4'H0, 32'H00000000 };
		/*
		    MLB initialize Setting, Page 52 and 53 in DDR PHY SPEC .
			bit15-0  : MLB initialize MRS6 setting ;
		*/
		`SUM_STEP_WIDTH'd32 : S_q <= { 1'B0, `WR_FLAG ,32'H4120918c };
		`SUM_STEP_WIDTH'd33 : S_q <= { 4'H0, 32'H00000000 };
		
		/*
		   DDR Timing Setting.  Page 55 in DDR PHY SPEC .
		   bit7-0   : tMRD ,
		   bit15-8  : tMOD ,
		   bit31-16 : tZQint ,
		*/
		`SUM_STEP_WIDTH'd34 : S_q <= { 1'B0, `WR_FLAG ,32'H412091e0 };
		`SUM_STEP_WIDTH'd35 : S_q <= { 4'H0, 32'H01000602 };
		
		/*
		   DDR Timing Setting.  Page 56 in DDR PHY SPEC .
		   bit15-0  : tXPR ,
		   bit23-16 : tRP for pre-charge all banks ,
		   bit31-24 : tRP for pre-charge single bank ,		   
		*/
		`SUM_STEP_WIDTH'd36 : S_q <= { 1'B0, `WR_FLAG ,32'H412091e4 };
		`SUM_STEP_WIDTH'd37 : S_q <= { 4'H0, 32'H0c060044 };
		/*
		   DDR Timing Setting, Page 56 in DDR PHY SPEC .
		   bit7-0   : tWR
		   bit11-8  : Write ODT delay
		   bit31-12 : Time for cal_done to DRR bus RESET in power on procedure.
		*/
		`SUM_STEP_WIDTH'd38 : S_q <= { 1'B0, `WR_FLAG ,32'H412091e8 };
		`SUM_STEP_WIDTH'd39 : S_q <= { 4'H0, 32'Hffff000c };
		/*
		   page56 in DDR PHY SPEC .
		   bit7-0  : reg_mlb_r_dfi_t_phy_wrlat , Time for DFI write command to write data enable. INT( t_phy_wrlat/2 ).
		   bit11-8 : reg_mlb_r_dfi_t_phy_wrdata, Time for DFI write data enable to write data , INT ( t_phy_wrdata/2 ).
		   bit31-12: reg_mlb_r_rstctlrst2cke, Time from RESET to CKE during power on procedure .
		*/
		`SUM_STEP_WIDTH'd40 : S_q <= { 1'B0, `WR_FLAG ,32'H412091ec };
		`SUM_STEP_WIDTH'd41 : S_q <= { 4'H0, 32'Hfffff105 };
		/*
		   DDR Timing Setting, Page 57 in DDR PHY SPEC .
		   bit7-0  : tRRD
		   bit15-8 : tCCD
		   bit23-16: tRTW
		   bit31-24: tRTP
		*/
		`SUM_STEP_WIDTH'd42 : S_q <= { 1'B0, `WR_FLAG ,32'H412091f0 };
		`SUM_STEP_WIDTH'd43 : S_q <= { 4'H0, 32'H060a0406 };
		/*
		   DDR Setting , Page 57 in DDR PHY SPEC .
		   bit7-0  : AL
		   bit15-8 : reg_mlb_r_dfi_t_rddata_en, Time for DFI read command to read data enable, INT( t_rddata_en/2 ).
		   bit23-16: reserved for future use, Input shall be logic-0.
		   bit31-24: reg_mlb_r_rfc, tRFC, DDR Timing Setting .
		*/
		`SUM_STEP_WIDTH'd44 : S_q <= { 1'B0, `WR_FLAG ,32'H412091f4 };
		`SUM_STEP_WIDTH'd45 : S_q <= { 4'H0, 32'H80060800 };
		/*
		   Page 58 in DDR PHY SPEC .
		   bit16-0 : reg_mlb_r_refresh_limit, Time for auto-refresh interval.
		   bit19-17: reserved for future use, input shall be logic-0 .
		   bit23-20: reg_mlb_r_wodt_timer, Time for write ODT period .
		   bit31-24: reg_mlb_r_t_rcd  , tRCD . DDR Timing Setting .
		*/
		`SUM_STEP_WIDTH'd46 : S_q <= { 1'B0, `WR_FLAG ,32'H412091f8 };
		`SUM_STEP_WIDTH'd47 : S_q <= { 4'H0, 32'H0c400c30 };
		/*
		   bit7-0  : reg_mlb_r_t_wrmpr, tWR_MPR for DDR4 . 
		   bit11-8 : reg_pad_drvp, OCD Pull up driving strength selection .  DDRPHY IO setting . Page 58
		              DDR3 :
					     0000 : 120 Ohm
						 0001 : 60 Ohm
						 0010 : 40 Ohm
						 0011 : 34 Ohm
					  DDR2 :
					     0000 : 150 Ohm
						 0001 : 75 Ohm
						 0010 : 50 Ohm
						 0011 : 37.5 Ohm
		   bit15-12: reg_pad_drvp, OCD Pull down driving strength selection
		              DDR3 :
					     0000 : 120 Ohm
						 0001 : 60 Ohm
						 0010 : 40 Ohm
						 0011 : 34 Ohm
					  DDR2 :
					     0000 : 150 Ohm
						 0001 : 75 Ohm
						 0010 : 50 Ohm
						 0011 : 37.5 Ohm
		  bit31-16: reserved for future use, input shall be logic-0 .						 
		*/
		`SUM_STEP_WIDTH'd48 : S_q <= { 1'B0, `WR_FLAG ,32'H412091fc };
		`SUM_STEP_WIDTH'd49 : S_q <= { 4'H0, 32'H00000000 };
		
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
		
		`SUM_STEP_WIDTH'd72 : S_q <= { 1'B0, `WR_FLAG ,32'H41209004 };
		`SUM_STEP_WIDTH'd73 : S_q <= { 4'H0, 32'H00258000 }; //DDR3, BL8, COL_ADDR_WIDTH = 10bit, ECC DISABLE, tPD = 20'H00258,
//		`SUM_STEP_WIDTH'd73 : S_q <= { 4'H0, 32'H00258800 }; //DDR3, BL8, COL_ADDR_WIDTH = 10bit, ECC ENABLE, tPD = 20'H00258, means 600us;
		`SUM_STEP_WIDTH'd74 : S_q <= { 1'B0, `WR_FLAG ,32'H41209008 };
		`SUM_STEP_WIDTH'd75 : S_q <= { 4'H0, 32'H08080c30 }; //r_refresh_limit = 17'H00C30,r_wodt_timer = 4'H4,r_zqcs_enable=1'b0,r_t_zqcs=8'H20,r_banklsb = 0,means CSN-RA,BA,CA, 
		
		// r_dfi_t_rddata_en = bit[3:0], timer for DFI read command to read data enable.
		// r_dfi_t_phy_wlat  = bit[7:4], timer for DFI write command to write data enable.
		// r_dfi_t_phy_wrdata=bit[11:8], timer for DFI write data enable to write data.
		// r_rstctl_en2rst   =bit[31:12], timer for ddr23controller enable to DDR bus RESET in Power ON procedure.
		`SUM_STEP_WIDTH'd76 : S_q <= { 1'B0, `WR_FLAG ,32'H4120900c };
		`SUM_STEP_WIDTH'd77 : S_q <= { 4'H0, 32'Hfffff124 }; //
		`SUM_STEP_WIDTH'd78 : S_q <= { 1'B0, `WR_FLAG ,32'H41209010 };
		`SUM_STEP_WIDTH'd79 : S_q <= { 4'H0, 32'H02030305 };//tRTW=BIT[7:0],tWTR=BIT[15:8],tRRD=BIT[23:16],tCCD=BIT[31:24].
		`SUM_STEP_WIDTH'd80 : S_q <= { 1'B0, `WR_FLAG ,32'H41209014 };
		`SUM_STEP_WIDTH'd81 : S_q <= { 4'H0, 32'h03064010 };//tFAW=BIT[7:0],tRFC=BIT[15:8],tWR=BIT[23:24],tRTP=BIT[31:24],
		`SUM_STEP_WIDTH'd82 : S_q <= { 1'B0, `WR_FLAG ,32'H41209018 };
		`SUM_STEP_WIDTH'd83 : S_q <= { 4'H0, 32'H06060e06 };//tRCD=BIT[7:0],tRAS=BIT[15:8],tRP for pre-charge signle bank = BIT[23:16],tRP for pre-charge all bank = BIT[31:24]
		`SUM_STEP_WIDTH'd84 : S_q <= { 1'B0, `WR_FLAG ,32'H4120901c };
		`SUM_STEP_WIDTH'd85 : S_q <= { 4'H0, 32'H40040006 };//CL=BIT[7:0],AL=[11:8],CWL=[23:16],Write ODT delay=BIT[27:24],r_rc2rde_odd=bit[29],r_wc2wde_odd=bit[30],r_wde2wd_odd=bit[31].
		`SUM_STEP_WIDTH'd86 : S_q <= { 1'B0, `WR_FLAG ,32'H41209020 };
		`SUM_STEP_WIDTH'd87 : S_q <= { 4'H0, 32'H01000044 }; //tXPR=BIT[15:0],tOIT=BIT[31:16].
		`SUM_STEP_WIDTH'd88 : S_q <= { 1'B0, `WR_FLAG ,32'H41209024 };
		`SUM_STEP_WIDTH'd89 : S_q <= { 4'H0, 32'H00030602 }; //tMRD=BIT[7:0],tMOD=BIT[15:8],tZQCS_limit=bit[31:16].
		`SUM_STEP_WIDTH'd90 : S_q <= { 1'B0, `WR_FLAG ,32'H41209028 };
		`SUM_STEP_WIDTH'd91 : S_q <= { 4'H0, 32'H00000018 }; //MR2=BIT[15:0],MR3=BIT[31:16].
		`SUM_STEP_WIDTH'd92 : S_q <= { 1'B0, `WR_FLAG ,32'H4120902c };
		`SUM_STEP_WIDTH'd93 : S_q <= { 4'H0, 32'H1d700046 };//MR1=BIT[15:0],MR0=BIT[31:16]
		`SUM_STEP_WIDTH'd94 : S_q <= { 1'B0, `WR_FLAG ,32'H41209030 };
		`SUM_STEP_WIDTH'd95 : S_q <= { 4'H0, 32'H01000404 };//tCKSRE=BIT[7:0],tCKSRX=BIT[15:8],tXSDLL=BIT[31:16],
		`SUM_STEP_WIDTH'd96 : S_q <= { 1'B0, `WR_FLAG ,32'H41209034 };
		`SUM_STEP_WIDTH'd97 : S_q <= { 4'H0, 32'H020a0344 };//tXS=BIT[7:0],tXP=BIT[15:8],tXPDLL=BIT[23:16],tCKE=BIT[31:24].
		`SUM_STEP_WIDTH'd98 : S_q <= { 1'B0, `WR_FLAG ,32'H41209038 };
		`SUM_STEP_WIDTH'd99 : S_q <= { 4'H0, 32'H00060c08 };//tRDPDEN=BIT[7:0],tWRPDEN=BIT[15:8],t_pd_timer_limit=BIT[31:16].
		
		
		// r_enable_training=bit[0], r_enable_bist=bit[1],r_enable_cpuif/r_enable_ecc_back_group_data = bit[2], bit3,reserved.
		// r_mc_init_upd_enable = bit[4],
		// r_phy_init_upd_mode = bit[6:5],
		// r_topbound = bit[9:7],
		// r_row_addr_width = bit[12:10], 000: 16Bits ; 001: 15Bits ; 010: 14Bits ;011: 13Bits ;100: 12Bits ;
		// r_cs_addr_width = bit[14:13],  00: single rank, 01: two ranks, 10: three ranks, 11: four ranks..
		// r_intr_enable = bit[23:16],   
		//         bit0: enalbe_top-bound error report interrupt, 
		//         bit1: enable ecc correctable err report interrupt,
		//         bit2: enable ecc fatal error report interrupt,
		//         other: reserved.
		// r_intr_status = bit[31:24], interrupt status ( write 1 clear ).
		`SUM_STEP_WIDTH'd100 : S_q <= { 1'B0, `WR_FLAG ,32'H4120903C }; //default all 0.
		`SUM_STEP_WIDTH'd101 : S_q <= { 4'H0, 32'H0000800 }; //row addr width = 14Bits.
		
		
		`SUM_STEP_WIDTH'd102 : S_q <= { 1'B0, `WR_FLAG ,32'H41209058 }; //read only, reserved..
		`SUM_STEP_WIDTH'd103 : S_q <= { 4'H0, 32'H00000000 };
		`SUM_STEP_WIDTH'd104 : S_q <= { 1'B0, `WR_FLAG ,32'H41209064 };
		`SUM_STEP_WIDTH'd105 : S_q <= { 4'H0, 32'Hf0000000 }; //Port8 priority weighting=BIT[3:0], ... , Port15 priority weighting = BIT[31:28]
		`SUM_STEP_WIDTH'd106 : S_q <= { 1'B0, `WR_FLAG ,32'H41209068 };
		`SUM_STEP_WIDTH'd107 : S_q <= { 4'H0, 32'H00002000 }; //Port0 high priority group = BIT[16], ... , Port15 high priority group = BIT[31].
		`SUM_STEP_WIDTH'd108 : S_q <= { 1'B0, `WR_FLAG ,32'h41209050 };
		`SUM_STEP_WIDTH'd109 : S_q <= { 4'H0, 32'h30000001 };//user defined registets reserved for system pll = BIT[31:0],
		`SUM_STEP_WIDTH'd110 : S_q <= { 1'B0, `RD_FLAG ,32'h41209000 };  //wait,nop
		`SUM_STEP_WIDTH'd111 : S_q <= { 4'H0, 32'H00000000 };//NEED MODIFY...
		`SUM_STEP_WIDTH'd112 : S_q <= { 1'B0, `WR_FLAG ,32'H41209000 };  //enable ddr23 controller.
		`SUM_STEP_WIDTH'd113 : S_q <= { 4'H0, 32'H00000001 }; //Enable DDR23Ctrl=bit[0],
		`SUM_STEP_WIDTH'd114 : S_q <= { 1'B0, `RD_FLAG ,32'H4120906c };  //read only register, 
		`SUM_STEP_WIDTH'd115 : S_q <= { 4'H8, 32'H40000000 };//waiting for MRS Command is DONE ...
		`SUM_STEP_WIDTH'd116 : S_q <= { 1'B0, `RD_FLAG ,32'H4120906c };  //wait,nop
		`SUM_STEP_WIDTH'd117 : S_q <= { 4'H8, 32'H80000000 };//waiting for DFI_INIT_COMPLETE signal from PHY is DONE,
		//DDR23 phy
		
		/*
		   Training manuall mode and recommended to connect to user-defined register for third party controller .
		   REG_18h and REG_1Ch are applied to reg_db[N-1]_dll_gate_trip[7:0], 
		   REG_20h and REG_24h are applied to reg_db[N-1]_dll_gate_fine[7:0],		   
		   bit7:0  : reg_db*_dll_gate_trip[7:0], Training Manual Mode Gate Training Delay_value, 
		             This is DDR PHY DLL setting value for read leveling gate delay. the DLL gate delay setting 
					      includes a 1/2T DDR bus clock cycle(DDR_CK) delay setting and a fine-tune phase delay_setting .
				     Definiton :
					    1) [N-1] Means setting for data module [N-1] .
					    2) reg_db*_dll_gata_trip[7:0] : 1/2T DDR _CK cycle delay.
						3) reg_db*_dll_data_fine[7:0] : fine-tune phase delay.
					 Users Could set full cycle delay value from 0 to F(hex) means 0T to 15x(1/2)T DDR_CK cycle delay.
					 Fine-tune phase delay setting 0 to FF(hex) means 0T, (1/256)x(1/2)T to (255/256)x(1/2)T DDR_CK cycle delay.
		*/
		`SUM_STEP_WIDTH'd50 : S_q <= { 1'B0, `WR_FLAG ,32'H41209118 }; //write gate data3/2/1/0_trip.
		`SUM_STEP_WIDTH'd51 : S_q <= { 4'H0, 32'H04040404 };
		`SUM_STEP_WIDTH'd52 : S_q <= { 1'B0, `WR_FLAG ,32'H4120911c }; //write gate data7/6/5/4_trip.
		`SUM_STEP_WIDTH'd53 : S_q <= { 4'H0, 32'H00000004 };
		
		`SUM_STEP_WIDTH'd54 : S_q <= { 1'B0, `WR_FLAG ,32'H41209120 }; //write gate data3/2/1/0_fine.
		`SUM_STEP_WIDTH'd55 : S_q <= { 4'H0, 32'H20202020 };		
		`SUM_STEP_WIDTH'd56 : S_q <= { 1'B0, `WR_FLAG ,32'H41209124 }; //write gate data7/6/5/4_fine.
		`SUM_STEP_WIDTH'd57 : S_q <= { 4'H0, 32'H00000020 };
		/*
		   Training manual mode and recommended to connect to user-defined register for third part controller.
		   REG_28h and REG_2Ch are applied to reg_db[N-1]_dll_deye_rdqs[7:0],
		   Training Manual Mode Data Eye Training Delay Value for DDR_DQS
		      Both position differential ddr_dqs and negative differential ddr_dqs_n are used to sample read data. Therefore, two DLL setting,
			  one for ddr_dqs and one for ddr_dqs_n, are required for data eye training delay,
			  Definitioin :
			      1) [N-1] Means setting for data module [N-1].
				  2) reg_db*_dll_deye_rdqs[7:0]: fine tune phase delay.
				  3) Recommended setting is "80(hex)", which is 1/4T DDR_CK clock cycle.
			  Fine-tune phase delay setting 0 to FF(hex) means 0T, (1/256)x(1/2)T to (255/256)x(1/2)T DDR_CK cycle delay. 
		*/
		`SUM_STEP_WIDTH'd58 : S_q <= { 1'B0, `WR_FLAG ,32'H41209128 };  //write data3/2/1/0_eyep.
		`SUM_STEP_WIDTH'd59 : S_q <= { 4'H0, 32'Hbfbfbfbf };
		`SUM_STEP_WIDTH'd60 : S_q <= { 1'B0, `WR_FLAG ,32'H4120912c };  //write data7/6/5/4_eyep.
		`SUM_STEP_WIDTH'd61 : S_q <= { 4'H0, 32'H000000bf };
		
		/*
		   Training manual mode and recommended to connect to user-defined register for third part controller.
		   REG_30h and REG_34h are applied to reg_db[N-1]_dll_deye_rdqsn[7:0],
		   Training Manual Mode Data Eye Training Delay Value for DDR_DQS
		      Both position differential ddr_dqs and negative differential ddr_dqs_n are used to sample read data. Therefore, two DLL setting,
			  one for ddr_dqs and one for ddr_dqs_n, are required for data eye training delay,
			  Definitioin :
			      1) [N-1] Means setting for data module [N-1].
				  2) reg_db*_dll_deye_rdqs[7:0]: fine tune phase delay.
				  3) Recommended setting is "80(hex)", which is 1/4T DDR_CK clock cycle.
			  Fine-tune phase delay setting 0 to FF(hex) means 0T, (1/256)x(1/2)T to (255/256)x(1/2)T DDR_CK cycle delay. 
		*/
		
		`SUM_STEP_WIDTH'd62 : S_q <= { 1'B0, `WR_FLAG ,32'H41209130 };  //write data3/2/1/0_eyen.
		`SUM_STEP_WIDTH'd63 : S_q <= { 4'H0, 32'Hbfbfbfbf };
		`SUM_STEP_WIDTH'd64 : S_q <= { 1'B0, `WR_FLAG ,32'H41209134 };  //write data7/6/5/4_eyen.
		`SUM_STEP_WIDTH'd65 : S_q <= { 4'H0, 32'H000000bf };
		
		/*
		   please refrence to page 51 in DDR PHY SPEC .
		   for 
		*/
		`SUM_STEP_WIDTH'd66 : S_q <= { 1'B0, `WR_FLAG ,32'H4120914c }; //write data3/2/1/0_eyen.
		`SUM_STEP_WIDTH'd67 : S_q <= { 4'H0, 32'H3f3f3f3f };
		`SUM_STEP_WIDTH'd68 : S_q <= { 1'B0, `WR_FLAG ,32'H41209150 }; //write data7/6/5/4_eyen.
		`SUM_STEP_WIDTH'd69 : S_q <= { 4'H0, 32'H0000003f };
		/*
		*/
		`SUM_STEP_WIDTH'd70 : S_q <= { 1'B0, `WR_FLAG ,32'H41209114 }; //manual mode bit[9]
		`SUM_STEP_WIDTH'd71 : S_q <= { 4'H0, 32'H00000a24 };
		
//		/*
//		   
//		*/
//		`SUM_STEP_WIDTH'd118 : S_q <= { 1'B0, `WR_FLAG ,32'H41209104 }; //DDR PHY setting
//		`SUM_STEP_WIDTH'd119 : S_q <= { 4'H0, 32'H02080e51 };
//		`SUM_STEP_WIDTH'd120 : S_q <= { 1'B0, `WR_FLAG ,32'H41209104 };
//		`SUM_STEP_WIDTH'd121 : S_q <= { 4'H0, 32'H02080c51 };
		//
		`SUM_STEP_WIDTH'd118 : S_q <= { 1'B0, `RD_FLAG ,32'H4120906c };
		`SUM_STEP_WIDTH'd119 : S_q <= { 4'H8, 32'H40000000 };//auto_MRS done status, 1: done.
		`SUM_STEP_WIDTH'd120 : S_q <= { 1'B0, `RD_FLAG ,32'H4120906c };
		`SUM_STEP_WIDTH'd121 : S_q <= { 4'H8, 32'H80000000 };//Dram_dfi_init_complete status, 1: done.
		`SUM_STEP_WIDTH'd122 : S_q <= { 1'B0, `EOP_FLAG,32'H00000000 }; //End Config.
		`SUM_STEP_WIDTH'd123 : S_q <= { 4'H0, 32'H00000000 };//
	endcase
end


//always @( posedge I_sys_clk ) begin
//	case ( S_data_cnt )
//		`SUM_STEP_WIDTH'd0 : S_q <= { 1'B0, `WR_FLAG ,32'H41209050 }; //system pll option register..
//		`SUM_STEP_WIDTH'd1 : S_q <= { 4'H0, 32'H60000000 };
//		
//		/* DDR PHY setting, reserved  */
//		`SUM_STEP_WIDTH'd2 : S_q <= { 1'B0, `WR_FLAG ,32'H41209100 }; //
//		`SUM_STEP_WIDTH'd3 : S_q <= { 4'H0, 32'H42000000 };
//		/*
//			DDR PHY setting 
//			bit0: DDR3 mode setting. ( 0: DDR2 mode ; 1: DDR3 mode or loopback bist mode ).
//			bit1: DDR PHY Write data delay,
//			bit2: DDR AUX Power saving mode,
//			bit3: reserved and shall be 0.
//			bit7-4 : DDR PHY Read Valid timing.
//			bit8: DDR IO command address signal Power saving to tri-state output commands signals when csn is deasserted( 0: normal ; 1: tri-state ).
//			bit9: DDR PHY Read Data FIFO reset, this control is only used for diagmosis purpose( 0: normal; 1: For Diagnosis mode ).
//			bit10: DDR PHY Read Valid timing manual mode,( 0: aotomatic mode; 1: manual mode ).
//			bit13-11 : DDR IO ODT Register setting
//			     ( for DDR3 [A9,A6,A2] means: 000: ODT disable; 001: 120 OHm; 010: 60 OHm; 011 : 40 OHm ; other: reserved )
//				 ( for DDR2 [A9,A6,A2] means: 000: ODT disable; 001: 150 OHm; 010: 75 OHm; 011 : 50 OHm ; other: reserved )
//			bit15-14 : reserved for future use, shall be logic-0.
//			bit18-16 : DDR PHY read ODT Setting, Read ODT control signal enable delay after DFI read command.
//			     000: Delay 2T MC_CLK ; 001: Delay 3T MC_CLK ; 010: Delay 4T MC_CLK ; ... ; 110: Delay 8T MC_CLK ; 111:  Delay 2T MC_CLK ;
//			bit19 : DDR PHY read ODT Always On, Read ODT always turned On(0: Not always On ; 1: Always On ).
//			bit20 : DDR PHY Delay Calibration Enable, Delay calibration function enable,( 0: disable ; 1: enable ).
//			bit21 : DDR PHY Quick simulation mode ( 0: normal mode, 1: quick simulation mode ; For real silicon, this bit shall be 0 ).
//			bit23-22 : reserved, shall be logic 0,
//			bit24 : reserved, shall be logic 0,
//			bit25 : DDR Controller Training Mode, Choose train procedure from controller or PHY( 0 : PHY training Mode, 1: Controller training mode ),
//			bit27-26 : reserved, shall be logic 0,
//			bit28 : DDR2 mode select, ( 0: DDR3, 1: DDR2 ),
//			bit31-29 : reserved, shall be logic 0,
//		*/
//		`SUM_STEP_WIDTH'd4 : S_q <= { 1'B0, `WR_FLAG ,32'H41209104 }; 
//		`SUM_STEP_WIDTH'd5 : S_q <= { 4'H0, 32'H02080c51 };
//		/* 
//			DDR PHY PLL Setting,
//			reg_phy_pll[31:0]
//			bit7-0  :  M[7:0],       00000111
//			bit12-8 :  N[4:0],          00111
//			bit18-13:  P[5:0],         000000
//			bit20-19:  LKSEL[1:0],         00
//			bit25-21:  SIP[4:0],        00110
//			bit30-26:  SIC[4:0],        01100
//			bit31   :  FSE                  0
//		*/
//		`SUM_STEP_WIDTH'd6 : S_q <= { 1'B0, `WR_FLAG ,32'H4120910c }; //pll
//		`SUM_STEP_WIDTH'd7 : S_q <= { 4'H0, 32'H55e00a0a };
//		/* 
//		    DLL PHY DLL Setting,
//			reg_phy_dll[31:0]
//			bit28-0 : reserved, shall be logic-0,
//			bit29   :  0 : Slower or equal to DDR-800 Mbps ; 1 : fater than DDR-800Mbps,
//			bit31-30: reserved, shall be logic-0,
//		*/
//		`SUM_STEP_WIDTH'd8 : S_q <= { 1'B0, `WR_FLAG ,32'H41209110 }; //dll
//		`SUM_STEP_WIDTH'd9 : S_q <= { 4'H0, 32'Ha0000164 };
//		
//		/*
//		    DDR PHY Setting, page 44 in DDR PHY SPEC .
//			bit0 : reg_phy_pll_bypass, enabled, following clock shll be applied from SOC extern PIN, 
//			    mc_clk ( memory controller clock )
//				pll_bypass_phy_clk2x ( 2 times of DDR_CK bus differential clock speed, 4times of mc_clk speed )
//				 NOTE1 : if PLL bypass mode is enable, the PLL bypass setting shall also be set( reg_phy_pll[14] BP setting )
//				 NOTE2 : Could tie to logic-0 is not used by user.
//			bit1 : PLL Test Mode, if pll test mode is enabled, PLL data rate clock divided by 32 will be output to DDR_BANK[0] for observation,
//			        0: normal mode; 1: pll test mode ;
//			bit7-2 : reg_phy_databusy_cnt_intg[5:0], DDR PHY DLL update setting, 000000: recommended value .
//			bit8 : DLL Bypass mode Bypass dll for low speed function test purpose, 
//			      Note1: could tie to logic-0 if not used,
//				  Note2: During bypass dll mode there are 2 limitations
//				        a) maximum data rate 80MHz;
//						b) Read DQS/DQ wave shall be central alignment instead of edge alignment because dll is by-pass.
//			bit9 : reg-training_manual_mode, 
//			        0 :  traing manual mode is disable, using DFI train mode;
//					1 :  traing manual mode is enabled.
//			bit15-10 : reserved for future, shall be logic-0,
//			bit31-16 : reg_phy_data_byte[N-1:0]_pwr_dn, Data Module power down, Each data module can be power down independently
//			        0 :  normal;   1: Data module  power down ;			  
//		*/
//		`SUM_STEP_WIDTH'd10 : S_q <= { 1'B0, `WR_FLAG ,32'H41209114 };
//		`SUM_STEP_WIDTH'd11 : S_q <= { 4'H0, 32'H00000824 };
//		
//		/*
//		    DDR PHY setting, page 46 in DDR PHY SPEC .
//		    bit0 : reg_cal_disable, Auto-calibration disable
//			        0 : Enable auto-calibration ( recommended ) ; 1 : disable auto-calibration ;
//			bit1 : reg_cal_manual_mode, Calibrion Manual mode enable, when manual mode is enabled, the IO buffer will use reg_cal_default_pu and reg_cal_default_pd setting value instead of auto-calibrated values.
//			        0 : Disable manual mode ; 1: enable manual mode ;
//			bit2 : reg_cal_manual_pwrdn, Auto-calibration Circuit Power Down , Power down auto-calibraton circuit, the power down control could be enabled if auto-calibraion is disable,
//			        0 : Power On auto-calibraton circuit ( recommended )
//					1 : Power Down auto-calibration circuit,
//			bit3 : reg_lb_bist_start, Loop Back BIST Mode Start Command Bit, 
//			        0: inactive ; 1: start to do loop back BIST test ,
//			bit4 : reg_lb_bist_internal, Loop back BIST mode setting ,
//			        0 : Extern loop back ; 1 : Internal loop back ;
//			bit7-5 : PHY RDDV Selection 
//			        000 : train value +3 ; 001 : train value +1 ; 010 : train value +2 ; 011 : train value +3 ; ... 
//			bit15-8 : reg_lb_bist_eye_rdqs[7:0], Loop back mode DLL setting,
//			          User shall set this DLL value to adjust read data eye margin during loop back BIST mode, the value shall be set as 1/2T DDR_CK delay to let DQS sample at the center of DQ data eye during loopback mode.
//			bit19-16 : reg_cal0_offset_pu, Calibration 0 offset Value PU[3:0] .
//			             the offset value adjustment for auto-calibated value apply to I0 buffer .
//						 reg_cal0_offset_pu[3]
//						   0 : Means minus offset value .
//						   1 : Means add offset value .
//						 reg_cal0_offset_pu[2:0]: offset value .
//						 0000b : Default .
//						 Note : There will be K sets of calibration offset/default/ro values for different kind of DQ configuration .
//						   DQ16,32 : K=1( only one set )
//						   DQ64 : K=2
//						   DQ128: K=4
//			bit23-20 : reg_cal0_offset_pd, Calibration 0 offset value PD[3:0] .
//			             the offset value adjustment for auto-calibrated value apply to IO buffer .
//						 reg_cal0_offset_pd[3]
//						    0 : Means minus offset value .
//							1 : Means add offset value .
//						 reg_cal0_offset_pd[2:0]: offset value
//						   0000b: default
//						 Note : There will be K sets of calibration offset/default/ro values for different kind of DQ configuration .
//						   DQ16,32 : K=1( only one set )
//						   DQ64 : K=2
//						   DQ128: K=4
//			bit27-24 : reg_cal0_default_pu, Calibration: 0 Value PU[3:0] for manual mode,
//			             PU values for IO when calibration manual mode enabled.
//						   0101b : Recommend for manual mode.
//						   Don't care : For auto-calibration mode .
//						  Note : There will be K sets of calibration offset/default/ro values for different kind of DQ configuration .
//						   DQ16,32 : K=1( only one set )
//						   DQ64 : K=2
//						   DQ128: K=4
//			bit31-28 : reg_cal0_default_pd, Calibration: 0 Value PD[3:0] for manual mode,
//			             PU values for IO when calibration manual mode enabled.
//						   0101b : Recommend for manual mode.
//						   Don't care : For auto-calibration mode .
//						  Note : There will be K sets of calibration offset/default/ro values for different kind of DQ configuration .
//						   DQ16,32 : K=1( only one set )
//						   DQ64 : K=2
//						   DQ128: K=4
//		*/
//		`SUM_STEP_WIDTH'd12 : S_q <= { 1'B0, `WR_FLAG ,32'H41209140 };
//		`SUM_STEP_WIDTH'd13 : S_q <= { 4'H0, 32'H86000000 };
//		/*
//		   DDR PHY setting, page 48 in DDR PHY SPEC .
//		   bit3-0  : reg_cal1_offset_pu, Calibration 1 offset Value PU[3:0] .
//			             the offset value adjustment for auto-calibated value apply to I0 buffer .
//						 reg_cal0_offset_pu[3]
//						   0 : Means minus offset value .
//						   1 : Means add offset value .
//						 reg_cal0_offset_pu[2:0]: offset value .
//						 0000b : Default .
//						 Note : There will be K sets of calibration offset/default/ro values for different kind of DQ configuration .
//						   DQ16,32 : K=1( only one set )
//						   DQ64 : K=2
//						   DQ128: K=4
//		   bit7-4  : reg_cal1_offset_pd, Calibration 1 offset value PD[3:0] .
//			             the offset value adjustment for auto-calibrated value apply to IO buffer .
//						 reg_cal0_offset_pd[3]
//						    0 : Means minus offset value .
//							1 : Means add offset value .
//						 reg_cal0_offset_pd[2:0]: offset value
//						   0000b: default
//						 Note : There will be K sets of calibration offset/default/ro values for different kind of DQ configuration .
//						   DQ16,32 : K=1( only one set )
//						   DQ64 : K=2
//						   DQ128: K=4
//		   bit11-8 : reg_cal1_default_pu, Calibration: 1 Value PU[3:0] for manual mode,
//			             PU values for IO when calibration manual mode enabled.
//						   0101b : Recommend for manual mode.
//						   Don't care : For auto-calibration mode .
//						  Note : There will be K sets of calibration offset/default/ro values for different kind of DQ configuration .
//						   DQ16,32 : K=1( only one set )
//						   DQ64 : K=2
//						   DQ128: K=4
//		   bit15-12: reg_cal1_default_pd, Calibration: 1 Value PD[3:0] for manual mode,
//			             PU values for IO when calibration manual mode enabled.
//						   0101b : Recommend for manual mode.
//						   Don't care : For auto-calibration mode .
//						  Note : There will be K sets of calibration offset/default/ro values for different kind of DQ configuration .
//						   DQ16,32 : K=1( only one set )
//						   DQ64 : K=2
//						   DQ128: K=4
//		   bit16   : reg_wrdata1t_case, Write Data delay 1T.
//		   bit17   : reg_lowspeed_case, Read Data and Read Data Valid early 1T.
//		   bit19-18: reserved for future use , input shall be logic-0 .
//		   bit20   : reg_init_start_after_cmplt, Auto initial start after every mc_clk_rst_n, 
//		   bit21   : reg_lb_bist_DDR23phy, Write Data enable early 1T for DDR23PHY Loop Back BIST.
//		   bit27-22: reserved for future use , input shall be logic-0 .
//		   bit31-28: reg_lb_bist_chk_result, Loopback Result Select
//		              if set if to N, loopback result of datamodule N will be reported
//					     reg_ro_lb_rdata_gld = reg_ro_lbN_rdata_gld ;
//						 reg_ro_lb_rdata_err = reg_ro_lbN_rdata_err ;
//						 reg_ro_lb_cmp_timer = reg_ro_lbN_cmp_timer ;
//					  0000b : default .						 
//		*/
//		`SUM_STEP_WIDTH'd14 : S_q <= { 1'B0, `WR_FLAG ,32'H41209144 };
//		`SUM_STEP_WIDTH'd15 : S_q <= { 4'H0, 32'H00008600 };
//		/*
//		   DDR PHY setting, Page 50 in DDR PHY SPEC .
//		   bit3-0  : 
//		   bit7-4  : reserved for future used, input shall be logic-0 .
//		   bit11-8 :
//		   bit15-12: reserved for future used, input shall be logic-0 .
//		   bit19-16: reg_lb_bist[N-1]_errinjec, 
//		   bit23-20: reserved for future used, input shall be logic-0 .
//		   bit31-24: reg_ad_dll_deye_wdqsn, DDR PHY CA Phase Adjustment .
//		              this setting will be applied to ca module for ca operation .
//					  Definition:
//					    1) Delay setting 0 to FF(hex) means 0T, (1/256)x(1/2)T to (255/256)x(1/2)T DDR _CK cycle delay.
//						2) Recommend setting is "80(hex)" (which is 1/4T DDR_CK clock cycle ).
//		*/
//		`SUM_STEP_WIDTH'd16 : S_q <= { 1'B0, `WR_FLAG ,32'H41209148 };
//		`SUM_STEP_WIDTH'd17 : S_q <= { 4'H0, 32'H80000000 };
//		/*
//		   DDR PHY Setting , Page 51 in DDR PHY SPEC .
//		   bit7-0  : reg_db_[0]_dll_deye_wdqsn[7:0], DDR PHY write DQS to DQ phase adjustment, The write DQS to DQ phase delay adjustment.
//		             This setting will be applied to all data modules for write operation.
//					 Definition:
//					    1) Delay setting 0 to FF(hex) means 0T, (1/256)x(1/2)T to (255/256)x(1/2)T DDR _CK cycle delay.
//						2) Recommend setting is "80(hex)" (which is 1/4T DDR_CK clock cycle ).  
//		   bit15-8 : reg_db_[1]_dll_deye_wdqsn[7:0], DDR PHY write DQS to DQ phase adjustment, The write DQS to DQ phase delay adjustment.
//		             This setting will be applied to all data modules for write operation.
//					 Definition:
//					    1) Delay setting 0 to FF(hex) means 0T, (1/256)x(1/2)T to (255/256)x(1/2)T DDR _CK cycle delay.
//						2) Recommend setting is "80(hex)" (which is 1/4T DDR_CK clock cycle ). 
//		   bit23-16: reg_db_[2]_dll_deye_wdqsn[7:0], DDR PHY write DQS to DQ phase adjustment, The write DQS to DQ phase delay adjustment.
//		             This setting will be applied to all data modules for write operation.
//					 Definition:
//					    1) Delay setting 0 to FF(hex) means 0T, (1/256)x(1/2)T to (255/256)x(1/2)T DDR _CK cycle delay.
//						2) Recommend setting is "80(hex)" (which is 1/4T DDR_CK clock cycle ). 
//		   bit31-24: reg_db_[3]_dll_deye_wdqsn[7:0], DDR PHY write DQS to DQ phase adjustment, The write DQS to DQ phase delay adjustment.
//		             This setting will be applied to all data modules for write operation.
//					 Definition:
//					    1) Delay setting 0 to FF(hex) means 0T, (1/256)x(1/2)T to (255/256)x(1/2)T DDR _CK cycle delay.
//						2) Recommend setting is "80(hex)" (which is 1/4T DDR_CK clock cycle ). 
//		*/
//		`SUM_STEP_WIDTH'd18 : S_q <= { 1'B0, `WR_FLAG ,32'H4120914c };
//		`SUM_STEP_WIDTH'd19 : S_q <= { 4'H0, 32'H80808080 };
//		/*
//		   DDR PHY Setting , Page 51 in DDR PHY SPEC .
//		   bit7-0  : reg_db_[4]_dll_deye_wdqsn[7:0], DDR PHY write DQS to DQ phase adjustment, The write DQS to DQ phase delay adjustment.
//		             This setting will be applied to all data modules for write operation.
//					 Definition:
//					    1) Delay setting 0 to FF(hex) means 0T, (1/256)x(1/2)T to (255/256)x(1/2)T DDR _CK cycle delay.
//						2) Recommend setting is "80(hex)" (which is 1/4T DDR_CK clock cycle ).  
//		   bit15-8 : reg_db_[5]_dll_deye_wdqsn[7:0], DDR PHY write DQS to DQ phase adjustment, The write DQS to DQ phase delay adjustment.
//		             This setting will be applied to all data modules for write operation.
//					 Definition:
//					    1) Delay setting 0 to FF(hex) means 0T, (1/256)x(1/2)T to (255/256)x(1/2)T DDR _CK cycle delay.
//						2) Recommend setting is "80(hex)" (which is 1/4T DDR_CK clock cycle ). 
//		   bit23-16: reg_db_[6]_dll_deye_wdqsn[7:0], DDR PHY write DQS to DQ phase adjustment, The write DQS to DQ phase delay adjustment.
//		             This setting will be applied to all data modules for write operation.
//					 Definition:
//					    1) Delay setting 0 to FF(hex) means 0T, (1/256)x(1/2)T to (255/256)x(1/2)T DDR _CK cycle delay.
//						2) Recommend setting is "80(hex)" (which is 1/4T DDR_CK clock cycle ). 
//		   bit31-24: reg_db_[7]_dll_deye_wdqsn[7:0], DDR PHY write DQS to DQ phase adjustment, The write DQS to DQ phase delay adjustment.
//		             This setting will be applied to all data modules for write operation.
//					 Definition:
//					    1) Delay setting 0 to FF(hex) means 0T, (1/256)x(1/2)T to (255/256)x(1/2)T DDR _CK cycle delay.
//						2) Recommend setting is "80(hex)" (which is 1/4T DDR_CK clock cycle ). 
//		*/
//		`SUM_STEP_WIDTH'd20 : S_q <= { 1'B0, `WR_FLAG ,32'H41209150 };
//		`SUM_STEP_WIDTH'd21 : S_q <= { 4'H0, 32'H80808080 };
//		
//		/*
//			
//		   MLB Training Setting.
//		   bit0 : MLB training start ,for MLB Training Mode User shall set this bit to 1 then clear to 0 to create a trigger event to start GUC MLB training after all related setting are set properly.
//		   bit1 : MLB gate training disable, 
//		          0 :  recommended ; 1 : to disable GUC MLB training mode gate training.
//		   bit2 : MLB read data eye training enable or disable
//		          0 : enable ; 1 : disable .
//		   bit3 : MLB gate training fast mode.
//		          0 : normal ; 1: fast mode, ( only for simulation ).   
//		   bit16-5 :  reserved for future use , input shall be logic-0.
//		   bit17 : MLB gate training resullt minus offset value,  Minus or Add reg_train_delay_offset value to GUC MLB gate training result
//		          0 : Add offset value ;  1: Minus offset value .
//		   bit18 : MLB read data eye training result minus offset value , Minus or Add reg_mlb_train_deye_delay_offset value to GUC MLB gate training result.
//		          0 : Add offset value ;  1: Minus offset value .
//		   bit19 : MLB write data eye training result minus offset value, Minus or Add reg_mlg_train_wdsq_delay_offset value to GUC MLB gate training reslut.
//		          0 : Add offset value ;  1: Minus offset value .
//		   bit20 : Choose data training mode to do gate/read data eye training.
//		          0 : Use MPR training mode ( recommended )
//				  1 : Use data training mode
//		   bit21 : Choose dqs training mode to do gate training
//		          0 : Use MPR/data training mode do gate training ( recommended )
//				  1 : Use dqs training mode do gate training.
//		   other : reseved for future use, input shall be logic-0.		    
//			
//		*/
//		`SUM_STEP_WIDTH'd22 : S_q <= { 1'B0, `WR_FLAG ,32'H41209190 };
//		`SUM_STEP_WIDTH'd23 : S_q <= { 4'H0, 32'H00100008 };
//		
//		/*
//		   MLB Training Status. Page 64 in DDR PHY SPEC .
//		   reg_ro_mlb_train_db[N-1:0]_deye_result[7:0], 
//		   C0h ~ C4h : MLB read data eye training reslut. the offset adjustment will be include 
//		               1) [N-1] means setting for data module [N-1].
//					   2) reg_ro_mlb_train_db*_deye_reslut[7:0]: fine-tune phase delay setting .
//		*/
//		`SUM_STEP_WIDTH'd24 : S_q <= { 1'B0, `WR_FLAG ,32'H412091c0 };
//		`SUM_STEP_WIDTH'd25 : S_q <= { 4'H0, 32'H00000001 };
//		
//		/*
//		    MLB initialize Setting, Page 52 in DDR PHY SPEC .
//			bit15-0  : MLB initialize MRS2 setting ;
//			bit31-16 : MLB initialize MRS3 setting ;
//		*/
//		`SUM_STEP_WIDTH'd26 : S_q <= { 1'B0, `WR_FLAG ,32'H41209180 };
//		`SUM_STEP_WIDTH'd27 : S_q <= { 4'H0, 32'H00000018 };
//		/*
//		    MLB initialize Setting, Page 52 in DDR PHY SPEC .
//			bit15-0  : MLB initialize MRS1 setting ;
//			bit31-16 : MLB initialize MRS0 setting ;
//		*/
//		`SUM_STEP_WIDTH'd28 : S_q <= { 1'B0, `WR_FLAG ,32'H41209184 };
//		`SUM_STEP_WIDTH'd29 : S_q <= { 4'H0, 32'H1d700046 };
//		/*
//		    MLB initialize Setting, Page 52 in DDR PHY SPEC .
//			bit15-0  : MLB initialize MRS4 setting ;
//			bit31-16 : MLB initialize MRS5 setting ;
//		*/
//		`SUM_STEP_WIDTH'd30 : S_q <= { 1'B0, `WR_FLAG ,32'H41209188 };
//		`SUM_STEP_WIDTH'd31 : S_q <= { 4'H0, 32'H00000000 };
//		/*
//		    MLB initialize Setting, Page 52 and 53 in DDR PHY SPEC .
//			bit15-0  : MLB initialize MRS6 setting ;
//		*/
//		`SUM_STEP_WIDTH'd32 : S_q <= { 1'B0, `WR_FLAG ,32'H4120918c };
//		`SUM_STEP_WIDTH'd33 : S_q <= { 4'H0, 32'H00000000 };
//		
//		/*
//		   DDR Timing Setting.  Page 55 in DDR PHY SPEC .
//		   bit7-0   : tMRD ,
//		   bit15-8  : tMOD ,
//		   bit31-16 : tZQint ,
//		*/
//		`SUM_STEP_WIDTH'd34 : S_q <= { 1'B0, `WR_FLAG ,32'H412091e0 };
//		`SUM_STEP_WIDTH'd35 : S_q <= { 4'H0, 32'H01000602 };
//		
//		/*
//		   DDR Timing Setting.  Page 56 in DDR PHY SPEC .
//		   bit15-0  : tXPR ,
//		   bit23-16 : tRP for pre-charge all banks ,
//		   bit31-24 : tRP for pre-charge single bank ,		   
//		*/
//		`SUM_STEP_WIDTH'd36 : S_q <= { 1'B0, `WR_FLAG ,32'H412091e4 };
//		`SUM_STEP_WIDTH'd37 : S_q <= { 4'H0, 32'H0c060044 };
//		/*
//		   DDR Timing Setting, Page 56 in DDR PHY SPEC .
//		   bit7-0   : tWR
//		   bit11-8  : Write ODT delay
//		   bit31-12 : Time for cal_done to DRR bus RESET in power on procedure.
//		*/
//		`SUM_STEP_WIDTH'd38 : S_q <= { 1'B0, `WR_FLAG ,32'H412091e8 };
//		`SUM_STEP_WIDTH'd39 : S_q <= { 4'H0, 32'Hffff000c };
//		/*
//		   page56 in DDR PHY SPEC .
//		   bit7-0  : reg_mlb_r_dfi_t_phy_wrlat , Time for DFI write command to write data enable. INT( t_phy_wrlat/2 ).
//		   bit11-8 : reg_mlb_r_dfi_t_phy_wrdata, Time for DFI write data enable to write data , INT ( t_phy_wrdata/2 ).
//		   bit31-12: reg_mlb_r_rstctlrst2cke, Time from RESET to CKE during power on procedure .
//		*/
//		`SUM_STEP_WIDTH'd40 : S_q <= { 1'B0, `WR_FLAG ,32'H412091ec };
//		`SUM_STEP_WIDTH'd41 : S_q <= { 4'H0, 32'Hfffff105 };
//		/*
//		   DDR Timing Setting, Page 57 in DDR PHY SPEC .
//		   bit7-0  : tRRD
//		   bit15-8 : tCCD
//		   bit23-16: tRTW
//		   bit31-24: tRTP
//		*/
//		`SUM_STEP_WIDTH'd42 : S_q <= { 1'B0, `WR_FLAG ,32'H412091f0 };
//		`SUM_STEP_WIDTH'd43 : S_q <= { 4'H0, 32'H060a0406 };
//		/*
//		   DDR Setting , Page 57 in DDR PHY SPEC .
//		   bit7-0  : AL
//		   bit15-8 : reg_mlb_r_dfi_t_rddata_en, Time for DFI read command to read data enable, INT( t_rddata_en/2 ).
//		   bit23-16: reserved for future use, Input shall be logic-0.
//		   bit31-24: reg_mlb_r_rfc, tRFC, DDR Timing Setting .
//		*/
//		`SUM_STEP_WIDTH'd44 : S_q <= { 1'B0, `WR_FLAG ,32'H412091f4 };
//		`SUM_STEP_WIDTH'd45 : S_q <= { 4'H0, 32'H80060800 };
//		/*
//		   Page 58 in DDR PHY SPEC .
//		   bit16-0 : reg_mlb_r_refresh_limit, Time for auto-refresh interval.
//		   bit19-17: reserved for future use, input shall be logic-0 .
//		   bit23-20: reg_mlb_r_wodt_timer, Time for write ODT period .
//		   bit31-24: reg_mlb_r_t_rcd  , tRCD . DDR Timing Setting .
//		*/
//		`SUM_STEP_WIDTH'd46 : S_q <= { 1'B0, `WR_FLAG ,32'H412091f8 };
//		`SUM_STEP_WIDTH'd47 : S_q <= { 4'H0, 32'H0c400c30 };
//		/*
//		   bit7-0  : reg_mlb_r_t_wrmpr, tWR_MPR for DDR4 . 
//		   bit11-8 : reg_pad_drvp, OCD Pull up driving strength selection .  DDRPHY IO setting . Page 58
//		              DDR3 :
//					     0000 : 120 Ohm
//						 0001 : 60 Ohm
//						 0010 : 40 Ohm
//						 0011 : 34 Ohm
//					  DDR2 :
//					     0000 : 150 Ohm
//						 0001 : 75 Ohm
//						 0010 : 50 Ohm
//						 0011 : 37.5 Ohm
//		   bit15-12: reg_pad_drvp, OCD Pull down driving strength selection
//		              DDR3 :
//					     0000 : 120 Ohm
//						 0001 : 60 Ohm
//						 0010 : 40 Ohm
//						 0011 : 34 Ohm
//					  DDR2 :
//					     0000 : 150 Ohm
//						 0001 : 75 Ohm
//						 0010 : 50 Ohm
//						 0011 : 37.5 Ohm
//		  bit31-16: reserved for future use, input shall be logic-0 .						 
//		*/
//		`SUM_STEP_WIDTH'd48 : S_q <= { 1'B0, `WR_FLAG ,32'H412091fc };
//		`SUM_STEP_WIDTH'd49 : S_q <= { 4'H0, 32'H00000000 };
//		
//		//DDR23 controller
//		// r_ddr_mode = bit[1:0], 00: DDR3, 01: DDR2, 11: LPDDR2.
//		// r_bl4 = bit[2], 0: BL8, 1: BL4.
//		// r_refresh_en=bit[4], 
//		// r_refresh_dis = bit[5].
//		// r_pd_enable= bit[6].
//		// r_col_addr_width = bit[9:8]
//		//       00 : DRAM Column address 10bits.
//		//       01 : DRAM Column address 11bits.
//		//       10 : DRAM Column address 12bits.
//		//       11 : DRAM Column address 9bits.
//		// r_4bank = bit[10], 0: DRAM 8 Banks, 1: DRAM 4 banks.
//		// r_ecc_enable = bit[11],
//		// r_rstctl_rst2cke = bit[31:12]
//		
//		`SUM_STEP_WIDTH'd50 : S_q <= { 1'B0, `WR_FLAG ,32'H41209004 };
//		`SUM_STEP_WIDTH'd51 : S_q <= { 4'H0, 32'H00258000 }; //DDR3, BL8, COL_ADDR_WIDTH = 10bit, ECC DISABLE, tPD = 20'H00258,
////		`SUM_STEP_WIDTH'd51 : S_q <= { 4'H0, 32'H00258800 }; //DDR3, BL8, COL_ADDR_WIDTH = 10bit, ECC ENABLE, tPD = 20'H00258, means 600us;
//		`SUM_STEP_WIDTH'd52 : S_q <= { 1'B0, `WR_FLAG ,32'H41209008 };
//		`SUM_STEP_WIDTH'd53 : S_q <= { 4'H0, 32'H08080c30 }; //r_refresh_limit = 17'H00C30,r_wodt_timer = 4'H4,r_zqcs_enable=1'b0,r_t_zqcs=8'H20,r_banklsb = 0,means CSN-RA,BA,CA, 
//		
//		// r_dfi_t_rddata_en = bit[3:0], timer for DFI read command to read data enable.
//		// r_dfi_t_phy_wlat  = bit[7:4], timer for DFI write command to write data enable.
//		// r_dfi_t_phy_wrdata=bit[11:8], timer for DFI write data enable to write data.
//		// r_rstctl_en2rst   =bit[31:12], timer for ddr23controller enable to DDR bus RESET in Power ON procedure.
//		`SUM_STEP_WIDTH'd54 : S_q <= { 1'B0, `WR_FLAG ,32'H4120900c };
//		`SUM_STEP_WIDTH'd55 : S_q <= { 4'H0, 32'Hfffff124 }; //
//		`SUM_STEP_WIDTH'd56 : S_q <= { 1'B0, `WR_FLAG ,32'H41209010 };
//		`SUM_STEP_WIDTH'd57 : S_q <= { 4'H0, 32'H02030305 };//tRTW=BIT[7:0],tWTR=BIT[15:8],tRRD=BIT[23:16],tCCD=BIT[31:24].
//		`SUM_STEP_WIDTH'd58 : S_q <= { 1'B0, `WR_FLAG ,32'H41209014 };
//		`SUM_STEP_WIDTH'd59 : S_q <= { 4'H0, 32'h03064010 };//tFAW=BIT[7:0],tRFC=BIT[15:8],tWR=BIT[23:24],tRTP=BIT[31:24],
//		`SUM_STEP_WIDTH'd60 : S_q <= { 1'B0, `WR_FLAG ,32'H41209018 };
//		`SUM_STEP_WIDTH'd61 : S_q <= { 4'H0, 32'H06060e06 };//tRCD=BIT[7:0],tRAS=BIT[15:8],tRP for pre-charge signle bank = BIT[23:16],tRP for pre-charge all bank = BIT[31:24]
//		`SUM_STEP_WIDTH'd62 : S_q <= { 1'B0, `WR_FLAG ,32'H4120901c };
//		`SUM_STEP_WIDTH'd63 : S_q <= { 4'H0, 32'H40040006 };//CL=BIT[7:0],AL=[11:8],CWL=[23:16],Write ODT delay=BIT[27:24],r_rc2rde_odd=bit[29],r_wc2wde_odd=bit[30],r_wde2wd_odd=bit[31].
//		`SUM_STEP_WIDTH'd64 : S_q <= { 1'B0, `WR_FLAG ,32'H41209020 };
//		`SUM_STEP_WIDTH'd65 : S_q <= { 4'H0, 32'H01000044 }; //tXPR=BIT[15:0],tOIT=BIT[31:16].
//		`SUM_STEP_WIDTH'd66 : S_q <= { 1'B0, `WR_FLAG ,32'H41209024 };
//		`SUM_STEP_WIDTH'd67 : S_q <= { 4'H0, 32'H00030602 }; //tMRD=BIT[7:0],tMOD=BIT[15:8],tZQCS_limit=bit[31:16].
//		`SUM_STEP_WIDTH'd68 : S_q <= { 1'B0, `WR_FLAG ,32'H41209028 };
//		`SUM_STEP_WIDTH'd69 : S_q <= { 4'H0, 32'H00000018 }; //MR2=BIT[15:0],MR3=BIT[31:16].
//		`SUM_STEP_WIDTH'd70 : S_q <= { 1'B0, `WR_FLAG ,32'H4120902c };
//		`SUM_STEP_WIDTH'd71 : S_q <= { 4'H0, 32'H1d700046 };//MR1=BIT[15:0],MR0=BIT[31:16]
//		`SUM_STEP_WIDTH'd72 : S_q <= { 1'B0, `WR_FLAG ,32'H41209030 };
//		`SUM_STEP_WIDTH'd73 : S_q <= { 4'H0, 32'H01000404 };//tCKSRE=BIT[7:0],tCKSRX=BIT[15:8],tXSDLL=BIT[31:16],
//		`SUM_STEP_WIDTH'd74 : S_q <= { 1'B0, `WR_FLAG ,32'H41209034 };
//		`SUM_STEP_WIDTH'd75 : S_q <= { 4'H0, 32'H020a0344 };//tXS=BIT[7:0],tXP=BIT[15:8],tXPDLL=BIT[23:16],tCKE=BIT[31:24].
//		`SUM_STEP_WIDTH'd76 : S_q <= { 1'B0, `WR_FLAG ,32'H41209038 };
//		`SUM_STEP_WIDTH'd77 : S_q <= { 4'H0, 32'H00060c08 };//tRDPDEN=BIT[7:0],tWRPDEN=BIT[15:8],t_pd_timer_limit=BIT[31:16].
//		
//		
//		// r_enable_training=bit[0], r_enable_bist=bit[1],r_enable_cpuif/r_enable_ecc_back_group_data = bit[2], bit3,reserved.
//		// r_mc_init_upd_enable = bit[4],
//		// r_phy_init_upd_mode = bit[6:5],
//		// r_topbound = bit[9:7],
//		// r_row_addr_width = bit[12:10], 000: 16Bits ; 001: 15Bits ; 010: 14Bits ;011: 13Bits ;100: 12Bits ;
//		// r_cs_addr_width = bit[14:13],  00: single rank, 01: two ranks, 10: three ranks, 11: four ranks..
//		// r_intr_enable = bit[23:16],   
//		//         bit0: enalbe_top-bound error report interrupt, 
//		//         bit1: enable ecc correctable err report interrupt,
//		//         bit2: enable ecc fatal error report interrupt,
//		//         other: reserved.
//		// r_intr_status = bit[31:24], interrupt status ( write 1 clear ).
//		`SUM_STEP_WIDTH'd78 : S_q <= { 1'B0, `WR_FLAG ,32'H4120903C }; //default all 0.
//		`SUM_STEP_WIDTH'd79 : S_q <= { 4'H0, 32'H0000800 }; //row addr width = 14Bits.
//		
//		
//		`SUM_STEP_WIDTH'd80 : S_q <= { 1'B0, `WR_FLAG ,32'H41209058 }; //read only, reserved..
//		`SUM_STEP_WIDTH'd81 : S_q <= { 4'H0, 32'H00000000 };
//		`SUM_STEP_WIDTH'd82 : S_q <= { 1'B0, `WR_FLAG ,32'H41209064 };
//		`SUM_STEP_WIDTH'd83 : S_q <= { 4'H0, 32'Hf0000000 }; //Port8 priority weighting=BIT[3:0], ... , Port15 priority weighting = BIT[31:28]
//		`SUM_STEP_WIDTH'd84 : S_q <= { 1'B0, `WR_FLAG ,32'H41209068 };
//		`SUM_STEP_WIDTH'd85 : S_q <= { 4'H0, 32'H00002000 }; //Port0 high priority group = BIT[16], ... , Port15 high priority group = BIT[31].
//		`SUM_STEP_WIDTH'd86 : S_q <= { 1'B0, `WR_FLAG ,32'h41209050 };
//		`SUM_STEP_WIDTH'd87 : S_q <= { 4'H0, 32'h30000001 };//user defined registets reserved for system pll = BIT[31:0],
//		`SUM_STEP_WIDTH'd88 : S_q <= { 1'B0, `RD_FLAG ,32'h41209000 };  //wait,nop
//		`SUM_STEP_WIDTH'd89 : S_q <= { 4'H0, 32'H00000000 };//NEED MODIFY...
//		`SUM_STEP_WIDTH'd90 : S_q <= { 1'B0, `WR_FLAG ,32'H41209000 };  //enable ddr23 controller.
//		`SUM_STEP_WIDTH'd91 : S_q <= { 4'H0, 32'H00000001 }; //Enable DDR23Ctrl=bit[0],
//		`SUM_STEP_WIDTH'd92 : S_q <= { 1'B0, `RD_FLAG ,32'H4120906c };  //read only register, 
//		`SUM_STEP_WIDTH'd93 : S_q <= { 4'H8, 32'H40000000 };//waiting for MRS Command is DONE ...
//		`SUM_STEP_WIDTH'd94 : S_q <= { 1'B0, `RD_FLAG ,32'H4120906c };  //wait,nop
//		`SUM_STEP_WIDTH'd95 : S_q <= { 4'H8, 32'H80000000 };//waiting for DFI_INIT_COMPLETE signal from PHY is DONE,
//		//DDR23 phy
//		
//		/*
//		   Training manuall mode and recommended to connect to user-defined register for third party controller .
//		   REG_18h and REG_1Ch are applied to reg_db[N-1]_dll_gate_trip[7:0], 
//		   REG_20h and REG_24h are applied to reg_db[N-1]_dll_gate_fine[7:0],		   
//		   bit7:0  : reg_db*_dll_gate_trip[7:0], Training Manual Mode Gate Training Delay_value, 
//		             This is DDR PHY DLL setting value for read leveling gate delay. the DLL gate delay setting 
//					      includes a 1/2T DDR bus clock cycle(DDR_CK) delay setting and a fine-tune phase delay_setting .
//				     Definiton :
//					    1) [N-1] Means setting for data module [N-1] .
//					    2) reg_db*_dll_gata_trip[7:0] : 1/2T DDR _CK cycle delay.
//						3) reg_db*_dll_data_fine[7:0] : fine-tune phase delay.
//					 Users Could set full cycle delay value from 0 to F(hex) means 0T to 15x(1/2)T DDR_CK cycle delay.
//					 Fine-tune phase delay setting 0 to FF(hex) means 0T, (1/256)x(1/2)T to (255/256)x(1/2)T DDR_CK cycle delay.
//		*/
//		`SUM_STEP_WIDTH'd96 : S_q <= { 1'B0, `WR_FLAG ,32'H41209118 }; //write gate data3/2/1/0_trip.
//		`SUM_STEP_WIDTH'd97 : S_q <= { 4'H0, 32'H04040404 };
//		`SUM_STEP_WIDTH'd98 : S_q <= { 1'B0, `WR_FLAG ,32'H4120911c }; //write gate data7/6/5/4_trip.
//		`SUM_STEP_WIDTH'd99 : S_q <= { 4'H0, 32'H00000004 };
//		
//		`SUM_STEP_WIDTH'd100 : S_q <= { 1'B0, `WR_FLAG ,32'H41209120 }; //write gate data3/2/1/0_fine.
//		`SUM_STEP_WIDTH'd101 : S_q <= { 4'H0, 32'H20202020 };		
//		`SUM_STEP_WIDTH'd102 : S_q <= { 1'B0, `WR_FLAG ,32'H41209124 }; //write gate data7/6/5/4_fine.
//		`SUM_STEP_WIDTH'd103 : S_q <= { 4'H0, 32'H00000020 };
//		/*
//		   Training manual mode and recommended to connect to user-defined register for third part controller.
//		   REG_28h and REG_2Ch are applied to reg_db[N-1]_dll_deye_rdqs[7:0],
//		   Training Manual Mode Data Eye Training Delay Value for DDR_DQS
//		      Both position differential ddr_dqs and negative differential ddr_dqs_n are used to sample read data. Therefore, two DLL setting,
//			  one for ddr_dqs and one for ddr_dqs_n, are required for data eye training delay,
//			  Definitioin :
//			      1) [N-1] Means setting for data module [N-1].
//				  2) reg_db*_dll_deye_rdqs[7:0]: fine tune phase delay.
//				  3) Recommended setting is "80(hex)", which is 1/4T DDR_CK clock cycle.
//			  Fine-tune phase delay setting 0 to FF(hex) means 0T, (1/256)x(1/2)T to (255/256)x(1/2)T DDR_CK cycle delay. 
//		*/
//		`SUM_STEP_WIDTH'd104 : S_q <= { 1'B0, `WR_FLAG ,32'H41209128 };  //write data3/2/1/0_eyep.
//		`SUM_STEP_WIDTH'd105 : S_q <= { 4'H0, 32'Hbfbfbfbf };
//		`SUM_STEP_WIDTH'd106 : S_q <= { 1'B0, `WR_FLAG ,32'H4120912c };  //write data7/6/5/4_eyep.
//		`SUM_STEP_WIDTH'd107 : S_q <= { 4'H0, 32'H000000bf };
//		
//		/*
//		   Training manual mode and recommended to connect to user-defined register for third part controller.
//		   REG_30h and REG_34h are applied to reg_db[N-1]_dll_deye_rdqsn[7:0],
//		   Training Manual Mode Data Eye Training Delay Value for DDR_DQS
//		      Both position differential ddr_dqs and negative differential ddr_dqs_n are used to sample read data. Therefore, two DLL setting,
//			  one for ddr_dqs and one for ddr_dqs_n, are required for data eye training delay,
//			  Definitioin :
//			      1) [N-1] Means setting for data module [N-1].
//				  2) reg_db*_dll_deye_rdqs[7:0]: fine tune phase delay.
//				  3) Recommended setting is "80(hex)", which is 1/4T DDR_CK clock cycle.
//			  Fine-tune phase delay setting 0 to FF(hex) means 0T, (1/256)x(1/2)T to (255/256)x(1/2)T DDR_CK cycle delay. 
//		*/
//		`SUM_STEP_WIDTH'd108 : S_q <= { 1'B0, `WR_FLAG ,32'H41209130 };  //write data3/2/1/0_eyen.
//		`SUM_STEP_WIDTH'd109 : S_q <= { 4'H0, 32'Hbfbfbfbf };
//		`SUM_STEP_WIDTH'd110 : S_q <= { 1'B0, `WR_FLAG ,32'H41209134 };  //write data7/6/5/4_eyen.
//		`SUM_STEP_WIDTH'd111 : S_q <= { 4'H0, 32'H000000bf };
//		
//		/*
//		   please refrence to page 51 in DDR PHY SPEC .
//		   for 
//		*/
//		`SUM_STEP_WIDTH'd112 : S_q <= { 1'B0, `WR_FLAG ,32'H4120914c }; //write data3/2/1/0_eyen.
//		`SUM_STEP_WIDTH'd113 : S_q <= { 4'H0, 32'H3f3f3f3f };
//		`SUM_STEP_WIDTH'd114 : S_q <= { 1'B0, `WR_FLAG ,32'H41209150 }; //write data7/6/5/4_eyen.
//		`SUM_STEP_WIDTH'd115 : S_q <= { 4'H0, 32'H0000003f };
//		/*
//		*/
//		`SUM_STEP_WIDTH'd116 : S_q <= { 1'B0, `WR_FLAG ,32'H41209114 }; //manual mode bit[9]
//		`SUM_STEP_WIDTH'd117 : S_q <= { 4'H0, 32'H00000a24 };
//		
//		/*
//		   
//		*/
//		`SUM_STEP_WIDTH'd118 : S_q <= { 1'B0, `WR_FLAG ,32'H41209104 }; //DDR PHY setting
//		`SUM_STEP_WIDTH'd119 : S_q <= { 4'H0, 32'H02080e51 };
//		`SUM_STEP_WIDTH'd120 : S_q <= { 1'B0, `WR_FLAG ,32'H41209104 };
//		`SUM_STEP_WIDTH'd121 : S_q <= { 4'H0, 32'H02080c51 };
//		//
//		`SUM_STEP_WIDTH'd122 : S_q <= { 1'B0, `RD_FLAG ,32'H4120906c };
//		`SUM_STEP_WIDTH'd123 : S_q <= { 4'H8, 32'H40000000 };//auto_MRS done status, 1: done.
//		`SUM_STEP_WIDTH'd124 : S_q <= { 1'B0, `RD_FLAG ,32'H4120906c };
//		`SUM_STEP_WIDTH'd125 : S_q <= { 4'H8, 32'H80000000 };//Dram_dfi_init_complete status, 1: done.
//		`SUM_STEP_WIDTH'd126 : S_q <= { 1'B0, `EOP_FLAG,32'H00000000 }; //End Config.
//		`SUM_STEP_WIDTH'd127 : S_q <= { 4'H0, 32'H00000000 };//
//	endcase
//end

//always @( posedge I_sys_clk ) begin
//	case ( S_data_cnt )
//		`SUM_STEP_WIDTH'd0 : S_q <= { 1'B0, `WR_FLAG ,32'H41209050 }; //system pll option register..
//		`SUM_STEP_WIDTH'd1 : S_q <= { 4'H0, 32'H60000000 };
//		`SUM_STEP_WIDTH'd2 : S_q <= { 1'B0, `WR_FLAG ,32'H41209100 }; //
//		`SUM_STEP_WIDTH'd3 : S_q <= { 4'H0, 32'H42000000 };
//		`SUM_STEP_WIDTH'd4 : S_q <= { 1'B0, `WR_FLAG ,32'H41209104 }; //pll
//		`SUM_STEP_WIDTH'd5 : S_q <= { 4'H0, 32'H02080c51 };
//		`SUM_STEP_WIDTH'd6 : S_q <= { 1'B0, `WR_FLAG ,32'H4120910c }; //dll
//		`SUM_STEP_WIDTH'd7 : S_q <= { 4'H0, 32'H55e00a0a };
//		`SUM_STEP_WIDTH'd8 : S_q <= { 1'B0, `WR_FLAG ,32'H41209110 };
//		`SUM_STEP_WIDTH'd9 : S_q <= { 4'H0, 32'Ha0000164 };
//		`SUM_STEP_WIDTH'd10 : S_q <= { 1'B0, `WR_FLAG ,32'H41209114 };
//		`SUM_STEP_WIDTH'd11 : S_q <= { 4'H0, 32'H00000824 };
//		`SUM_STEP_WIDTH'd12 : S_q <= { 1'B0, `WR_FLAG ,32'H41209140 };
//		`SUM_STEP_WIDTH'd13 : S_q <= { 4'H0, 32'H86000000 };
//		`SUM_STEP_WIDTH'd14 : S_q <= { 1'B0, `WR_FLAG ,32'H41209144 };
//		`SUM_STEP_WIDTH'd15 : S_q <= { 4'H0, 32'H00008600 };
//		`SUM_STEP_WIDTH'd16 : S_q <= { 1'B0, `WR_FLAG ,32'H41209148 };
//		`SUM_STEP_WIDTH'd17 : S_q <= { 4'H0, 32'H80000000 };
//		`SUM_STEP_WIDTH'd18 : S_q <= { 1'B0, `WR_FLAG ,32'H4120914c };
//		`SUM_STEP_WIDTH'd19 : S_q <= { 4'H0, 32'H80808080 };
//		`SUM_STEP_WIDTH'd20 : S_q <= { 1'B0, `WR_FLAG ,32'H41209150 };
//		`SUM_STEP_WIDTH'd21 : S_q <= { 4'H0, 32'H80808080 };
//		`SUM_STEP_WIDTH'd22 : S_q <= { 1'B0, `WR_FLAG ,32'H41209190 };
//		`SUM_STEP_WIDTH'd23 : S_q <= { 4'H0, 32'H00100008 };
//		`SUM_STEP_WIDTH'd24 : S_q <= { 1'B0, `WR_FLAG ,32'H412091c0 };
//		`SUM_STEP_WIDTH'd25 : S_q <= { 4'H0, 32'H00000001 };
//		`SUM_STEP_WIDTH'd26 : S_q <= { 1'B0, `WR_FLAG ,32'H41209180 };
//		`SUM_STEP_WIDTH'd27 : S_q <= { 4'H0, 32'H00000018 };
//		`SUM_STEP_WIDTH'd28 : S_q <= { 1'B0, `WR_FLAG ,32'H41209184 };
//		`SUM_STEP_WIDTH'd29 : S_q <= { 4'H0, 32'H1d700046 };
//		`SUM_STEP_WIDTH'd30 : S_q <= { 1'B0, `WR_FLAG ,32'H41209188 };
//		`SUM_STEP_WIDTH'd31 : S_q <= { 4'H0, 32'H00000000 };
//		`SUM_STEP_WIDTH'd32 : S_q <= { 1'B0, `WR_FLAG ,32'H4120918c };
//		`SUM_STEP_WIDTH'd33 : S_q <= { 4'H0, 32'H00000000 };
//		`SUM_STEP_WIDTH'd34 : S_q <= { 1'B0, `WR_FLAG ,32'H412091e0 };
//		`SUM_STEP_WIDTH'd35 : S_q <= { 4'H0, 32'H01000602 };
//		`SUM_STEP_WIDTH'd36 : S_q <= { 1'B0, `WR_FLAG ,32'H412091e4 };
//		`SUM_STEP_WIDTH'd37 : S_q <= { 4'H0, 32'H0c060044 };
//		`SUM_STEP_WIDTH'd38 : S_q <= { 1'B0, `WR_FLAG ,32'H412091e8 };
//		`SUM_STEP_WIDTH'd39 : S_q <= { 4'H0, 32'Hffff000c };
//		`SUM_STEP_WIDTH'd40 : S_q <= { 1'B0, `WR_FLAG ,32'H412091ec };
//		`SUM_STEP_WIDTH'd41 : S_q <= { 4'H0, 32'Hfffff105 };
//		`SUM_STEP_WIDTH'd42 : S_q <= { 1'B0, `WR_FLAG ,32'H412091f0 };
//		`SUM_STEP_WIDTH'd43 : S_q <= { 4'H0, 32'H060a0406 };
//		`SUM_STEP_WIDTH'd44 : S_q <= { 1'B0, `WR_FLAG ,32'H412091f4 };
//		`SUM_STEP_WIDTH'd45 : S_q <= { 4'H0, 32'H80060800 };
//		`SUM_STEP_WIDTH'd46 : S_q <= { 1'B0, `WR_FLAG ,32'H412091f8 };
//		`SUM_STEP_WIDTH'd47 : S_q <= { 4'H0, 32'H0c400c30 };
//		`SUM_STEP_WIDTH'd48 : S_q <= { 1'B0, `WR_FLAG ,32'H412091fc };
//		`SUM_STEP_WIDTH'd49 : S_q <= { 4'H0, 32'H00000000 };
//		
//		//DDR23 controller
//		`SUM_STEP_WIDTH'd50 : S_q <= { 1'B0, `WR_FLAG ,32'H41209004 };
//		//`SUM_STEP_WIDTH'd51 : S_q <= { 4'H0, 32'H00258000 }; //DDR3, BL8, COL_ADDR_WIDTH = 10bit, ECC DISABLE, tPD = 20'H00258,
//		`SUM_STEP_WIDTH'd51 : S_q <= { 4'H0, 32'H00258000 }; //DDR3, BL8, COL_ADDR_WIDTH = 10bit, ECC ENABLE, tPD = 20'H00258, means 600us;
//		`SUM_STEP_WIDTH'd52 : S_q <= { 1'B0, `WR_FLAG ,32'H41209008 };
//		`SUM_STEP_WIDTH'd53 : S_q <= { 4'H0, 32'H08080c30 }; //r_refresh_limit = 17'H00C30,r_wodt_timer = 4'H4,r_zqcs_enable=1'b0,r_t_zqcs=8'H20,r_banklsb = 0,means CSN-RA,BA,CA, 
//		`SUM_STEP_WIDTH'd54 : S_q <= { 1'B0, `WR_FLAG ,32'H4120900c };
//		`SUM_STEP_WIDTH'd55 : S_q <= { 4'H0, 32'Hfffff124 }; //
//		`SUM_STEP_WIDTH'd56 : S_q <= { 1'B0, `WR_FLAG ,32'H41209010 };
//		`SUM_STEP_WIDTH'd57 : S_q <= { 4'H0, 32'H02030305 };//tRTW=BIT[7:0],tWTR=BIT[15:8],tRRD=BIT[23:16],tCCD=BIT[31:24].
//		`SUM_STEP_WIDTH'd58 : S_q <= { 1'B0, `WR_FLAG ,32'H41209014 };
//		`SUM_STEP_WIDTH'd59 : S_q <= { 4'H0, 32'h03064010 };//tFAW=BIT[7:0],tRFC=BIT[15:8],tWR=BIT[23:24],tRTP=BIT[31:24],
//		`SUM_STEP_WIDTH'd60 : S_q <= { 1'B0, `WR_FLAG ,32'H41209018 };
//		`SUM_STEP_WIDTH'd61 : S_q <= { 4'H0, 32'H06060e06 };//tRCD=BIT[7:0],tRAS=BIT[15:8],tRP for pre-charge signle bank = BIT[23:16],tRP for pre-charge all bank = BIT[31:24]
//		`SUM_STEP_WIDTH'd62 : S_q <= { 1'B0, `WR_FLAG ,32'H4120901c };
//		`SUM_STEP_WIDTH'd63 : S_q <= { 4'H0, 32'H40040006 };//CL=BIT[7:0],AL=[11:8],CWL=[23:16],Write ODT delay=BIT[27:24],r_rc2rde_odd=bit[29],r_wc2wde_odd=bit[30],r_wde2wd_odd=bit[31].
//		`SUM_STEP_WIDTH'd64 : S_q <= { 1'B0, `WR_FLAG ,32'H41209020 };
//		`SUM_STEP_WIDTH'd65 : S_q <= { 4'H0, 32'H01000044 }; //tXPR=BIT[15:0],tOIT=BIT[31:16].
//		`SUM_STEP_WIDTH'd66 : S_q <= { 1'B0, `WR_FLAG ,32'H41209024 };
//		`SUM_STEP_WIDTH'd67 : S_q <= { 4'H0, 32'H00030602 }; //tMRD=BIT[7:0],tMOD=BIT[15:8],tZQCS_limit=bit[31:16].
//		`SUM_STEP_WIDTH'd68 : S_q <= { 1'B0, `WR_FLAG ,32'H41209028 };
//		`SUM_STEP_WIDTH'd69 : S_q <= { 4'H0, 32'H00000018 }; //MR2=BIT[15:0],MR3=BIT[31:16].
//		`SUM_STEP_WIDTH'd70 : S_q <= { 1'B0, `WR_FLAG ,32'H4120902c };
//		`SUM_STEP_WIDTH'd71 : S_q <= { 4'H0, 32'H1d700046 };//MR1=BIT[15:0],MR0=BIT[31:16]
//		`SUM_STEP_WIDTH'd72 : S_q <= { 1'B0, `WR_FLAG ,32'H41209030 };
//		`SUM_STEP_WIDTH'd73 : S_q <= { 4'H0, 32'H01000404 };//tCKSRE=BIT[7:0],tCKSRX=BIT[15:8],tXSDLL=BIT[31:16],
//		`SUM_STEP_WIDTH'd74 : S_q <= { 1'B0, `WR_FLAG ,32'H41209034 };
//		`SUM_STEP_WIDTH'd75 : S_q <= { 4'H0, 32'H020a0344 };//tXS=BIT[7:0],tXP=BIT[15:8],tXPDLL=BIT[23:16],tCKE=BIT[31:24].
//		`SUM_STEP_WIDTH'd76 : S_q <= { 1'B0, `WR_FLAG ,32'H41209038 };
//		`SUM_STEP_WIDTH'd77 : S_q <= { 4'H0, 32'H00060c08 };//tRDPDEN=BIT[7:0],tWRPDEN=BIT[15:8],t_pd_timer_limit=BIT[31:16].
//		
////		
////		// r_enable_training=bit[1], r_enable_bist=bit[1],r_enable_cpuif/r_enable_ecc_back_group_data = bit[3], bit4,reserved.
////		// r_mc_init_upd_enable = bit[4],
////		// r_phy_init_upd_mode = bit[6:5],
////		// r_topbound = bit[9:7],
////		// r_row_addr_width = bit[12:10], 000: 16Bits ; 001: 15Bits ; 010: 14Bits ;011: 13Bits ;100: 12Bits ;
////		// r_cs_addr_width = bit[14:13],  00: single rank, 01: two ranks, 10: three ranks, 11: four ranks..
////		// r_intr_enable = bit[23:16],   
////		//         bit0: enalbe_top-bound error report interrupt, 
////		//         bit1: enable ecc correctable err report interrupt,
////		//         bit2: enable ecc fatal error report interrupt,
////		//         other: reserved.
////		// r_intr_status = bit[31:24], interrupt status ( write 1 clear ).
////		`SUM_STEP_WIDTH'd78 : S_q <= { 1'B0, `WR_FLAG ,32'H4120903C }; //default all 0.
////		`SUM_STEP_WIDTH'd79 : S_q <= { 4'H0, 32'H00060c08 }; //r_enable_train = bit[4:0], tRDPDEN=BIT[7:0],tWRPDEN=BIT[15:8],t_pd_timer_limit=BIT[31:16].
////		
////		
//		`SUM_STEP_WIDTH'd78 : S_q <= { 1'B0, `WR_FLAG ,32'H41209058 }; //read only, reserved..
//		`SUM_STEP_WIDTH'd79 : S_q <= { 4'H0, 32'H00000000 };
//		`SUM_STEP_WIDTH'd80 : S_q <= { 1'B0, `WR_FLAG ,32'H41209064 };
//		`SUM_STEP_WIDTH'd81 : S_q <= { 4'H0, 32'Hf0000000 }; //Port8 priority weighting=BIT[3:0], ... , Port15 priority weighting = BIT[31:28]
//		`SUM_STEP_WIDTH'd82 : S_q <= { 1'B0, `WR_FLAG ,32'H41209068 };
//		`SUM_STEP_WIDTH'd83 : S_q <= { 4'H0, 32'H00002000 }; //Port0 high priority group = BIT[16], ... , Port15 high priority group = BIT[31].
//		`SUM_STEP_WIDTH'd84 : S_q <= { 1'B0, `WR_FLAG ,32'h41209050 };
//		`SUM_STEP_WIDTH'd85 : S_q <= { 4'H0, 32'h30000001 };//user defined registets reserved for system pll = BIT[31:0],
//		`SUM_STEP_WIDTH'd86 : S_q <= { 1'B0, `RD_FLAG ,32'h41209000 };  //wait,nop
//		`SUM_STEP_WIDTH'd87 : S_q <= { 4'H0, 32'H00000000 };//NEED MODIFY...
//		`SUM_STEP_WIDTH'd88 : S_q <= { 1'B0, `WR_FLAG ,32'H41209000 };  //enable ddr23 controller.
//		`SUM_STEP_WIDTH'd89 : S_q <= { 4'H0, 32'H00000001 }; //Enable DDR23Ctrl=bit[0],
//		`SUM_STEP_WIDTH'd90 : S_q <= { 1'B0, `RD_FLAG ,32'H4120906c };  //read only register, 
//		`SUM_STEP_WIDTH'd91 : S_q <= { 4'H8, 32'H40000000 };//waiting for MRS Command is DONE ...
//		`SUM_STEP_WIDTH'd92 : S_q <= { 1'B0, `RD_FLAG ,32'H4120906c };  //wait,nop
//		`SUM_STEP_WIDTH'd93 : S_q <= { 4'H8, 32'H80000000 };//waiting for DFI_INIT_COMPLETE signal from PHY is DONE,
//		//DDR23 phy
//		`SUM_STEP_WIDTH'd94 : S_q <= { 1'B0, `WR_FLAG ,32'H41209118 };
//		`SUM_STEP_WIDTH'd95 : S_q <= { 4'H0, 32'H04040404 };
//		`SUM_STEP_WIDTH'd96 : S_q <= { 1'B0, `WR_FLAG ,32'H41209120 };
//		`SUM_STEP_WIDTH'd97 : S_q <= { 4'H0, 32'H2f2f2f2f };
//		`SUM_STEP_WIDTH'd98 : S_q <= { 1'B0, `WR_FLAG ,32'H41209128 };
//		`SUM_STEP_WIDTH'd99 : S_q <= { 4'H0, 32'Hbfbfbfbf };
//		`SUM_STEP_WIDTH'd100 : S_q <= { 1'B0, `WR_FLAG ,32'H41209130 };
//		`SUM_STEP_WIDTH'd101 : S_q <= { 4'H0, 32'Hbfbfbfbf };
//		`SUM_STEP_WIDTH'd102 : S_q <= { 1'B0, `WR_FLAG ,32'H4120914c };
//		`SUM_STEP_WIDTH'd103 : S_q <= { 4'H0, 32'H3f3f3f3f };
//		`SUM_STEP_WIDTH'd104 : S_q <= { 1'B0, `WR_FLAG ,32'H41209114 };
//		`SUM_STEP_WIDTH'd105 : S_q <= { 4'H0, 32'H00000a24 };
//		`SUM_STEP_WIDTH'd106 : S_q <= { 1'B0, `WR_FLAG ,32'H41209104 }; //phy pll..
//		`SUM_STEP_WIDTH'd107 : S_q <= { 4'H0, 32'H02080e51 };
//		`SUM_STEP_WIDTH'd108 : S_q <= { 1'B0, `WR_FLAG ,32'H41209104 };
//		`SUM_STEP_WIDTH'd109 : S_q <= { 4'H0, 32'H02080c51 };
//		`SUM_STEP_WIDTH'd110 : S_q <= { 1'B0, `RD_FLAG ,32'H41209104 };
//		`SUM_STEP_WIDTH'd111 : S_q <= { 4'H8, 32'H02080c51 };
//		
//		`SUM_STEP_WIDTH'd112 : S_q <= { 1'B0, `RD_FLAG ,32'H4120906c };
//		`SUM_STEP_WIDTH'd113 : S_q <= { 4'H8, 32'H40000000 };//NEED MODIFY...
//		`SUM_STEP_WIDTH'd114 : S_q <= { 1'B0, `RD_FLAG ,32'H4120906c };
//		`SUM_STEP_WIDTH'd115 : S_q <= { 4'H8, 32'H80000000 };//NEED MODIFY...
//		`SUM_STEP_WIDTH'd116 : S_q <= { 1'B0, `EOP_FLAG,32'H00000000 };
//		`SUM_STEP_WIDTH'd117 : S_q <= { 4'H0, 32'H00000000 };//NEED MODIFY...
//	endcase
//end

		
always @( posedge I_sys_clk or negedge I_sys_rst_n ) begin
	if( !I_sys_rst_n ) O_done <= 1'b0 ;
	else 
		case ( S_machine )
			REQ_DONE : O_done <= ( S_wait_cnt[15] ) ? 1'b1 : O_done ;
			default  : O_done <= 1'b0 ;
		endcase	
end

always @( posedge I_sys_clk or negedge I_sys_rst_n ) begin
	if( !I_sys_rst_n ) S_wait_cnt <= 'b0 ;
	else 
		case ( S_machine )
			REQ_DONE : S_wait_cnt <= S_wait_cnt + 1'b1 ;
			default  : S_wait_cnt <= 'b0 ;
		endcase	
end



//emb_ddr_cfg emb_ddr_cfg_inst(
//	.a   ( S_addr      ), 
//	.ce  ( 1'b1        ), 
//	.clk ( I_sys_clk   ), 
//	.d   (             ), 
//	.q   ( S_qA         ), 
//	.rstn( I_sys_rst_n ), 
//	.we  ( 1'b0        )
//	);



endmodule
