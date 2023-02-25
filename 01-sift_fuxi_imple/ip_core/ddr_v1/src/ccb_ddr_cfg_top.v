
module cme_ddr_core_top_v1(
    I_mc_rstn, I_mc_pclk,  //200MHz ,
    I_cfg_rstn, I_cfg_pclk,  // low 100MHz ..
    //
    I_mc_uclk, I_pbus_aclk0, I_pbus_aclk1,
    
    O_init_done, O_init_pass,   /* 0: fail ; 1: pass */
    
    //Port0 for AXI Bus
    axi_port00_arid, axi_port00_araddr, axi_port00_arlen, 
    axi_port00_arsize, axi_port00_arburst, axi_port00_arvalid, axi_port00_arready,
    axi_port00_rid, axi_port00_rdata, axi_port00_rresp,
    axi_port00_rlast, axi_port00_rvalid, axi_port00_rready,
    axi_port00_awid, axi_port00_awaddr, axi_port00_awlen,
    axi_port00_awsize, axi_port00_awburst, axi_port00_awvalid, axi_port00_awready,
    axi_port00_wid, axi_port00_wdata, axi_port00_wstrb,
    axi_port00_wlast, axi_port00_wvalid, axi_port00_wready,
    axi_port00_bid, axi_port00_bresp, axi_port00_bvalid, axi_port00_bready,
    
    // Port1 for AXI Bus
    axi_port01_arid, axi_port01_araddr, axi_port01_arlen, 
    axi_port01_arsize, axi_port01_arburst, axi_port01_arvalid, axi_port01_arready,
    axi_port01_rid, axi_port01_rdata, axi_port01_rresp,
    axi_port01_rlast, axi_port01_rvalid, axi_port01_rready,
    axi_port01_awid, axi_port01_awaddr, axi_port01_awlen,
    axi_port01_awsize, axi_port01_awburst, axi_port01_awvalid, axi_port01_awready,
    axi_port01_wid, axi_port01_wdata, axi_port01_wstrb,
    axi_port01_wlast, axi_port01_wvalid, axi_port01_wready,
    axi_port01_bid, axi_port01_bresp, axi_port01_bvalid, axi_port01_bready,
    
    // Port0 for SDII Bus
    sdii_port00_req, sdii_port00_gnt, sdii_port00_rw,
    sdii_port00_addr, sdii_port00_len, sdii_port00_partial_wrt,
    sdii_port00_wdata_pop, sdii_port00_wdata, sdii_port00_wmask,
    sdii_port00_rdata_psh, sdii_port00_rdata,
    
    // Port1 for SDII Bus
    sdii_port01_req, sdii_port01_gnt, sdii_port01_rw,
    sdii_port01_addr, sdii_port01_len, sdii_port01_partial_wrt,
    sdii_port01_wdata_pop, sdii_port01_wdata, sdii_port01_wmask,
    sdii_port01_rdata_psh, sdii_port01_rdata,
	
	O_error_status,O_error_status_en
);

parameter CFG_MC_BUS_SEL = 1'b1 ; // set 4120_8000_bit[0].. 1:sdii, 0: axi.
parameter CFG_IP2IP_SEL  = 1'B1 ; // set 4170_011C_bit[0].. 1=gx/ddr bus inferface connect to array ; 0= gx/ddr bus inferface connect to spine.

//DDR PHY
parameter reg32_100 = 32'h42000000 ;
parameter reg32_104 = 32'h02080c51 ;
parameter reg32_108 = 32'h0186a000 ;
parameter reg32_10c = 32'h55e00a0a ;
parameter reg32_110 = 32'ha0000164 ;
parameter reg32_114 = 32'h00000a24 ; // manual mode : bit9, if bit9 is to 0, reg118 to reg13c will be ignored .
parameter reg32_118 = 32'h04040404 ; // write gate data3/2/1/0_trip (DDR PHY DLL Setting ) for read data.
parameter reg32_11c = 32'h00000004 ; // write gate data7/6/5/4_trip (DDR PHY DLL Setting ) for read data. add by chenDk,
parameter reg32_120 = 32'h2f2f2f2f ; // write gate data3/2/1/0_fine (DDR PHY DLL Setting ) for read data.
parameter reg32_124 = 32'h0000002f ; // write gate data7/6/5/4_fine (DDR PHY DLL Setting ) for read data. add by chenDk,
parameter reg32_128 = 32'hbfbfbfbf ; // write data3/2/1/0_eyep (DQS_p)for read data.
parameter reg32_12c = 32'h000000bf ; // write data7/6/5/4_eyep (DQS_p)for read data. add by chenDk,
parameter reg32_130 = 32'hbfbfbfbf ; // write data3/2/1/0_eyen (DQS_n)for read data.
parameter reg32_134 = 32'h000000bf ; // write data7/6/5/4_eyen (DQS_n)for read data. add by chenDk,
parameter reg32_140 = 32'h86000000 ; //PVT auto-calibration mode enable
parameter reg32_144 = 32'h00008600 ;
parameter reg32_148 = 32'h80000000 ;
parameter reg32_14c = 32'h3f3f3f3f ;
parameter reg32_150 = 32'h0000003f ;
parameter reg32_180 = 32'h00000018 ; //bit[15:0]: MRS2 ; bit[31:16] : MRS3 ; 
parameter reg32_184 = 32'h1d700046 ; //bit[15:0]: MRS1 ; bit[31:16] : MRS0 ; 
parameter reg32_188 = 32'h00000000 ; //bit[15:0]: MRS4 ; bit[31:16] : MRS5 ; 
parameter reg32_18c = 32'h00000000 ; //bit[15:0]: MRS6 ; bit[31:16] : reserved  ;  
parameter reg32_190 = 32'h00100008 ; //MLB train Setting..
parameter reg32_1c0 = 32'h00000001 ;
parameter reg32_1e0 = 32'h01000602 ; //bit[7:0]: tMRD = 4tDDR_CLK, bit[15:8]: tMOD = 4tDDR_CLK,O_init_done bit[31:16]: tZQint = 512tDDR_CLK ;
parameter reg32_1e4 = 32'h0c060044 ; //bit[15:0]: tXPR, bit[23:16] : tPR for pre-charge all banks ; bit[31:24] : tPR for pre-charge single bank ;
parameter reg32_1e8 = 32'hffff000c ; //bit[7:0]: tWR, bit[11:8]: write ODT delay = 0, bit[31:12]: time for cal done to DDR bus RESET in power on procedure ;
parameter reg32_1ec = 32'hfffff105 ; //bit[7:0],bit[11:8] , bit[31:12] = Time for reset to cke ( min =500us) ; 
parameter reg32_1f0 = 32'h060a0406 ; //bit[7:0]: tRRD = 4tDDR_CLK, bit[15:8]: tCCD = 4tDDR_CLK ; bit[23:16]: tRTW , bit[31:24]: tRTP= max( 4tCK,7.5ns ) ;
parameter reg32_1f4 = 32'h80060800 ; //bit[7:0]: tAL, bit[15:8]: tRL , bit[31:23]: tRFC,  
parameter reg32_1f8 = 32'h0c400c30 ; //bit[16:0]: tREFI= 7.8us or 3.9 us , 
parameter reg32_1fc = 32'h00000000 ; //

//DDR CORE 
parameter reg32_00 = 32'h00000001 ; // control parameters ,
parameter reg32_04 = 32'h00258000 ; // control parameters , bit11: ecc_enable, bit10:bank num( 0:8banks, 1:4banks)bit9-8: col width(00:10bits,01:11bits,10:12bits,11:9bits).
parameter reg32_08 = 32'h08080c30 ;
parameter reg32_0c = 32'hfffff124 ; // timer parameters
parameter reg32_10 = 32'h02030305 ; // timer parameters
parameter reg32_14 = 32'h03064010 ; // timer parameters
parameter reg32_18 = 32'h06060e06 ; // timer parameters
parameter reg32_1c = 32'h40040006 ; // timer parameters
parameter reg32_20 = 32'h01000044 ; // timer parameters
parameter reg32_24 = 32'h00030602 ; // timer parameters
parameter reg32_28 = 32'h00000018 ; // MRS2, MRS3
parameter reg32_2c = 32'h1d700046 ; // MRS1, MRS0
parameter reg32_30 = 32'h01000404 ; // timer parameters
parameter reg32_34 = 32'h020a0344 ; // timer parameters
parameter reg32_38 = 32'h00060c08 ; // timer parameters
parameter reg32_3c = 32'h00000800 ; // control parameters, row width: 14bit ; add by chenDk,
parameter reg32_50 = 32'h30000001 ;
parameter reg32_54 = 32'h00000000 ;
parameter reg32_58 = 32'h00000000 ;
parameter reg32_64 = 32'hf0000000 ;
parameter reg32_68 = 32'h00002000 ;

// 
parameter DDR23AXISLV_PORT00_DATABUS = 128;
parameter DDR23AXISLV_PORT01_DATABUS = 128;
parameter DDR23AXISLV_PORT02_DATABUS = 128;
parameter DDR23AXISLV_PORT03_DATABUS = 128;
parameter DDR23AXISLV_PORT04_DATABUS = 128;

parameter DDR23AXISLV_PORT00_IDWIDTH = 16;
parameter DDR23AXISLV_PORT01_IDWIDTH = 16;
parameter DDR23AXISLV_PORT02_IDWIDTH = 16;
parameter DDR23AXISLV_PORT03_IDWIDTH = 16;
parameter DDR23AXISLV_PORT04_IDWIDTH = 16;

parameter DDR23AHBSLV_PORT00_DATABUS = 128;
parameter DDR23AHBSLV_PORT01_DATABUS = 128;
parameter DDR23AHBSLV_PORT02_DATABUS = 128;
parameter DDR23AHBSLV_PORT03_DATABUS = 128;
parameter DDR23AHBSLV_PORT04_DATABUS = 128;

parameter DDR23AXISLV_PORT00_BYTENUM = 16;
parameter DDR23AXISLV_PORT01_BYTENUM = 16;
parameter DDR23AXISLV_PORT02_BYTENUM = 16;
parameter DDR23AXISLV_PORT03_BYTENUM = 16;
parameter DDR23AXISLV_PORT04_BYTENUM = 16;

parameter DDR23AXISLV_PORT00_BITNUM = 4;
parameter DDR23AXISLV_PORT01_BITNUM = 4;
parameter DDR23AXISLV_PORT02_BITNUM = 4;
parameter DDR23AXISLV_PORT03_BITNUM = 4;
parameter DDR23AXISLV_PORT04_BITNUM = 4;


parameter DFI_DATA_WIDTH = 128;

// module ports begin
input I_mc_rstn;  // mc_rstn for DDR IP.
input I_mc_pclk;  // mc_clk for DDR IP. 

input I_cfg_rstn;  // cfg pbus rstn for DDR IP ,
input I_cfg_pclk;  // cfg pbus clk for DDR IP , low 100MHz ..

input I_mc_uclk ;   // SDII BUS SYNC CLK FOR USER RTL MODULE..
input I_pbus_aclk0; // AXI IN PORT0 ASYN CLK FOR RTL MODULE.
input I_pbus_aclk1; // AXI IN PORT1 ASYN CLK FOR RTL MODULE.

output  O_init_done ;
output  O_init_pass ;  /* 0: fail ; 1: pass */

// Port Interface axi_port00	
input  [DDR23AXISLV_PORT00_IDWIDTH-1:0] axi_port00_arid	;
input  [31:0] axi_port00_araddr ;
input  [3:0]  axi_port00_arlen  ;
input  [2:0]  axi_port00_arsize ;
input  [1:0]  axi_port00_arburst;
input  axi_port00_arvalid ;
output axi_port00_arready ;
output [DDR23AXISLV_PORT00_IDWIDTH-1:0] axi_port00_rid  ;
output [DDR23AXISLV_PORT00_DATABUS-1:0] axi_port00_rdata;
output [1:0] axi_port00_rresp ;
output axi_port00_rlast  ;
output axi_port00_rvalid ;
input  axi_port00_rready ;
input  [DDR23AXISLV_PORT00_IDWIDTH-1:0] axi_port00_awid ;
input  [31:0] axi_port00_awaddr ;
input  [3:0]  axi_port00_awlen  ;
input  [2:0]  axi_port00_awsize ;
input  [1:0]  axi_port00_awburst;
input  axi_port00_awvalid ;
output axi_port00_awready ;
input  [DDR23AXISLV_PORT00_IDWIDTH-1:0] axi_port00_wid ;
input  [DDR23AXISLV_PORT00_DATABUS-1:0] axi_port00_wdata ;
input  [(DDR23AXISLV_PORT00_DATABUS/8)-1:0] axi_port00_wstrb ;
input  axi_port00_wlast ;
input  axi_port00_wvalid ;
output axi_port00_wready ;
output [DDR23AXISLV_PORT00_IDWIDTH-1:0] axi_port00_bid ;
output [1:0] axi_port00_bresp ;
output axi_port00_bvalid ;
input  axi_port00_bready ;

// Port Interface axi_port01
input  [DDR23AXISLV_PORT02_IDWIDTH-1:0] axi_port01_arid ;
input  [31:0] axi_port01_araddr ;
input  [3:0]  axi_port01_arlen ;
input  [2:0]  axi_port01_arsize ;
input  [1:0]  axi_port01_arburst;
input  axi_port01_arvalid ;
output axi_port01_arready ;
output [DDR23AXISLV_PORT02_IDWIDTH-1:0] axi_port01_rid ;
output [DDR23AXISLV_PORT02_DATABUS-1:0] axi_port01_rdata ;
output [1:0] axi_port01_rresp ;
output axi_port01_rlast ;
output axi_port01_rvalid ;
input  axi_port01_rready ;
input  [DDR23AXISLV_PORT02_IDWIDTH-1:0] axi_port01_awid			;
input  [31:0] axi_port01_awaddr ;
input  [3:0]  axi_port01_awlen ;
input  [2:0]  axi_port01_awsize ;
input  [1:0]  axi_port01_awburst;
input  axi_port01_awvalid ;
output axi_port01_awready ;
input  [DDR23AXISLV_PORT02_IDWIDTH-1:0] axi_port01_wid ;
input  [DDR23AXISLV_PORT02_DATABUS-1:0] axi_port01_wdata ;
input  [(DDR23AXISLV_PORT02_DATABUS/8)-1:0] axi_port01_wstrb ;
input  axi_port01_wlast ;
input  axi_port01_wvalid ;
output axi_port01_wready ;
output [DDR23AXISLV_PORT02_IDWIDTH-1:0] axi_port01_bid ;
output [1:0] axi_port01_bresp ;
output axi_port01_bvalid ;
input  axi_port01_bready ;

// Port Interface sdii_port03
input  sdii_port00_req ;
output sdii_port00_gnt ;
input  sdii_port00_rw  ;
input  [31:0] sdii_port00_addr ;
input  [5:0]  sdii_port00_len  ;
input  sdii_port00_partial_wrt ;
output sdii_port00_wdata_pop ;
input  [(DFI_DATA_WIDTH-1):0]     sdii_port00_wdata ;
input  [((DFI_DATA_WIDTH/8)-1):0] sdii_port00_wmask ;
output sdii_port00_rdata_psh ;
output [(DFI_DATA_WIDTH-1):0] sdii_port00_rdata ;

// Port Interface sdii_port01
input  sdii_port01_req ;
output sdii_port01_gnt ;
input  sdii_port01_rw  ;
input  [31:0] sdii_port01_addr ;
input  [5:0]  sdii_port01_len  ;
input  sdii_port01_partial_wrt ;
output sdii_port01_wdata_pop ;
input  [(DFI_DATA_WIDTH-1):0]     sdii_port01_wdata ;
input  [((DFI_DATA_WIDTH/8)-1):0] sdii_port01_wmask ;
output sdii_port01_rdata_psh ;
output [(DFI_DATA_WIDTH-1):0] sdii_port01_rdata ;

output [2:0]O_error_status;
output O_error_status_en ;

// module ports end
//`define SIM_INTER_WIRE               1
//`define SIM_DFI_BUS                  1
//`define SIM_SDRAM_EN                 1
//`define SIM_MASTER_CFG_DDR_CORE_EN   1
//`define SIM_MASTER_CFG_DDR_PHY_EN    1
//`define SIMULATION_DDRC_EN           1

`ifdef SIM_MASTER_CFG_DDR_CORE_EN
	`define SIM_MASTER_CFG_EN  1
`elsif  SIM_MASTER_CFG_DDR_PHY_EN
	`define SIM_MASTER_CFG_EN  1
`else
`endif


// notes:
// ip_clk & usr_clk should be in same freq, 
// mc_clk is the DDR clk freq
// DDRC async usr mode: mc_clk faster than usr/ip_clk
// DDRC sync usr mode: ip_clk rules as the mc_clk
// notes:
// also cfg_u/pclk is the same freq and diff latency for sync issues
// fabric user should use uclk
wire mc_clk_src;	 // for hardware IP PHY , 1:2 to DDR/DDRPHY clock, IP core clock, like 400MHz
wire usr_clk;      // for Fabric usr logic
wire ip_bus_clk;   // for hardware IP bridge logic
wire usrbus_clk;	 // for usr master logic
wire cfg_uclk;     // cfg clock for usr in Fabric, low speed < 100MHz
wire cfg_pclk;     // cfg clock on IP side
wire pll_lck;
wire ctl_ahb_cfg_hclk ;

//pll_v1 u_pll(
//    .clkin0  ( i_clk_ref   ),
//    .clkout0 ( mc_clk_src  ), // 1:2 to DDR/DDRPHY clock, IP core clock, like 400MHz
//    //.clkout1 (usr_clk	), // usr in Fabric clock and the same freq but different latency to mc_clk, like SDII 400MHz
//    .clkout2 ( ip_bus_clk  ), // connect to IP bus bridge, diffrent latency
//		.clkout3 ( usrbus_clk  ),
//    .clkout4 ( cfg_uclk    ),	// cfg clock for usr in Fabric
//    .clkout5 ( cfg_pclk    ),	// cfg clock on IP side
//    .locked  ( pll_lck	   )
//);

assign mc_clk_src = I_mc_pclk ;
assign usr_clk    = mc_clk_src ;
assign ip_bus_clk = I_pbus_aclk0 ; //I_axi_port_aclk_ug ;
assign usrbus_clk = ip_bus_clk ; // 
assign cfg_pclk = I_cfg_pclk;
assign cfg_uclk = cfg_pclk;
assign ctl_ahb_cfg_hclk = cfg_pclk ;


// --asic internal connections begin
wire w_x0connection;
wire w_x1connection;
wire mc_clk ;
wire mc_rstn ;

wire         mcfg_rstn;
wire [15:0]  cbi_pbus_addr;
wire         cbi_pbus_req;
wire [31:0]  cbi_pbus_wdata;
wire         cbi_pbus_write;
wire [31:0]  ctl_ahb_cfg_haddr_i;
wire [2:0]   ctl_ahb_cfg_hburst_i;
wire         ctl_ahb_cfg_hready_i;
wire         ctl_ahb_cfg_hsel_i;
wire [2:0]   ctl_ahb_cfg_hsize_i;
wire [1:0]  ctl_ahb_cfg_htrans_i;
wire [31:0] ctl_ahb_cfg_hwdata_i;
wire            ctl_ahb_cfg_hwrite_i;
wire [31:0] hreg_haddr;
wire [1:0]  hreg_htrans;
wire [31:0] hreg_hwdata;
wire            hreg_hwrite;
//wire		o;
//wire		pbus_gnt;
//wire	[31:0]	pbus_rdata;
wire [15:0] pcsps_pbus_addr;
wire           pcsps_pbus_req;
wire [31:0] pcsps_pbus_wdata;
wire           pcsps_pbus_write;
wire [31:0] phy_ahb_haddr_i;
wire [2:0]  phy_ahb_hburst_i;
wire 	   phy_ahb_hready_i;
wire 	   phy_ahb_hsel_i;
wire [2:0]  phy_ahb_hsize_i;
wire [1:0]  phy_ahb_htrans_i;
wire [31:0] phy_ahb_hwdata_i;
wire 	   phy_ahb_hwrite_i;
wire 	   cbi_pbus_gnt;
wire [31:0] cbi_pbus_rdata;
//wire		cfg_fp2ip_sel;
//wire		clk_p;
wire [31:0]	ctl_ahb_cfg_hrdata_o;
wire 	ctl_ahb_cfg_hready_o;
wire [0:0]	ctl_ahb_cfg_hresp_o;
//wire		fp_cs_clk;
wire      fp_cs_rstn;
wire [31:0]	hreg_hrdata;
wire     hreg_hready_out;
//wire	[1:0]	i;
wire      psps_pbus_gnt;
wire [31:0] pcsps_pbus_rdata;
wire [31:0] phy_ahb_hrdata_o;
wire     hy_ahb_hready_o;
wire [0:0]	 phy_ahb_hresp_o;
//wire		s;
wire usr_pbus_rstn;

wire [19:0]  dram_dfi_addr_p1;
wire [19:0]  dram_dfi_addr_p0;
wire [2:0]   dram_dfi_bank_p1;
wire [2:0]   dram_dfi_bank_p0;
wire         dram_dfi_cas_n_p1;
wire         dram_dfi_cas_n_p0;
wire [0:0]   dram_dfi_cke_p1;
wire [0:0]   dram_dfi_cke_p0;
wire [0:0]   dram_dfi_cs_n_duplicate_p1;
wire [0:0]   dram_dfi_cs_n_duplicate_p0;
wire [0:0]   dram_dfi_cs_n_p1;
wire [0:0]   dram_dfi_cs_n_p0;
wire         dram_dfi_ctrlupd_req;
wire         dram_dfi_dram_clk_disable;
wire [0:0]	  dram_dfi_ecc_rddata_en_p1;
wire [0:0]	  dram_dfi_ecc_rddata_en_p0;
wire [0:0]	  dram_dfi_ecc_wrdata_en_p1;
wire [0:0]	  dram_dfi_ecc_wrdata_en_p0;
wire [15:0]  dram_dfi_ecc_wrdata_p1;
wire [15:0]  dram_dfi_ecc_wrdata_p0;
wire [1:0]   dram_dfi_ecc_wrmask_p1;
wire [1:0]   dram_dfi_ecc_wrmask_p0;
wire         dram_dfi_init_start;
wire         dram_dfi_ras_n_p1;
wire         dram_dfi_ras_n_p0;
wire [3:0]   dram_dfi_rddata_en_p1;
wire [3:0]   dram_dfi_rddata_en_p0;
wire [31:0]  dram_dfi_rdlvl_delay;
wire [31:0]  dram_dfi_rdlvl_delayn;
wire [0:0]	  dram_dfi_rdlvl_edge;
wire [0:0]	  dram_dfi_rdlvl_en;
wire [63:0]	dram_dfi_rdlvl_gate_delay;
wire [0:0]   dram_dfi_rdlvl_gate_en;
wire [0:0]   dram_dfi_rdlvl_load;
wire   dram_dfi_reset_n_p1;
wire   dram_dfi_reset_n_p0;
wire   ram_dfi_we_n_p1;
wire   dram_dfi_we_n_p0;
wire [0:0]	dram_dfi_wodt_p1;
wire [0:0]	dram_dfi_wodt_p0;
wire [3:0]	dram_dfi_wrdata_en_p1;
wire [3:0]	dram_dfi_wrdata_en_p0;
wire [63:0]	dram_dfi_wrdata_p1;
wire [63:0]	dram_dfi_wrdata_p0;
wire [31:0]	dram_dfi_wrlvl_delay;
wire [0:0]	  dram_dfi_wrlvl_en;
wire [0:0]	  dram_dfi_wrlvl_load;
wire [0:0]	  dram_dfi_wrlvl_strobe;
wire [7:0]	  dram_dfi_wrmask_p1;
wire [7:0]	  dram_dfi_wrmask_p0;
wire 	gating_mc_clk;
wire  intr;
wire [2047:0]	r_ddr23phy_reg;
wire [31:0]	r_system_pll_reg;
wire [31:0] ahb_cfg_haddr_i;
wire [2:0]	 ahb_cfg_hburst_i;
wire 	     ahb_cfg_hready_i;
wire 	     ahb_cfg_hsel_i;
wire [2:0]	 ahb_cfg_hsize_i;
wire [1:0]	 ahb_cfg_htrans_i;
wire [31:0] ahb_cfg_hwdata_i;
wire 	     ahb_cfg_hwrite_i;
wire 	axi_port02_aclk;
wire 	axi_port02_arstn;
wire 	axi_port00_aclk;
wire 	axi_port00_arstn;
//wire			bus_ctl_sel;
wire     dram_dfi_ctrlupd_ack;
wire [15:0]	dram_dfi_ecc_rddata_w1;
wire [15:0]	dram_dfi_ecc_rddata_w0;
wire   dram_dfi_init_complete;
wire [3:0]	  dram_dfi_rddata_valid_w1;
wire [3:0]	  dram_dfi_rddata_valid_w0;
wire [63:0]	dram_dfi_rddata_w1;
wire [63:0]	dram_dfi_rddata_w0;
wire [1:0]	  dram_dfi_rdlvl_gate_mode;
wire [1:0]	  dram_dfi_rdlvl_mode;
wire [31:0]	dram_dfi_rdlvl_resp;
wire [1:0]	  dram_dfi_wrlvl_mode;
wire [3:0]	  dram_dfi_wrlvl_resp;
wire    [2047:0]	ro_ddr23phy_reg;

wire       inner_pbus_req ;
wire 	   NC_s0; // useless, just for RTL syntex
//


// --asic internal connections end



// -- user master's signal begin
wire S_intr ;
wire         pbus_req;
wire         pbus_gnt;
wire         pbus_write;
wire [15:0] pbus_addr;
wire [31:0] pbus_wdata;
wire [31:0] pbus_rdata;

wire [279:0] S_port0_data_to_ip ;
wire [279:0] S_port1_data_to_ip ;
wire [169:0] S_port0_data_to_usr ;
wire [169:0] S_port1_data_to_usr ;
// -- user master's signal end



DDR_CRG_CORE #(
		.cfg_gx_soft_prst      ( 0                   ),  //reg_4120_8000[30], GX soft reset to reset the configuration and hardware hot reset, default 0.
		.cfg_mc_bus_sel        ( CFG_MC_BUS_SEL	     )   //reg_4120_8000[0]   //axi // modify by user or wizard
) u_ddrc_crg(   
		//input..
		.axi_port00_aclk_ug    ( I_pbus_aclk0          ), // connect this when using ASYNC AXI bridge
		.axi_port00_aclk_us    ( w_x0connection      ), // to let Router handle the mux
		.axi_port02_aclk_ug    ( I_pbus_aclk1          ), // connect this when using ASYNC AXI bridge
		.axi_port02_aclk_us    ( w_x1connection      ), // to let Router handle the mux
		.bypasspll_mc_clk_x4_ug( I_mc_pclk           ), // PLL test/bypass clock, optional
		.fp_cs_clk             ( cfg_pclk            ), // also connect when user want to cfg IP by usr master in Fabric
		.gating_mc_clk         ( gating_mc_clk       ),
		.mc_clk_ug             ( I_mc_pclk           ), // ONLY connect this when using SYNC AXI bridge
		
		.p_rc                  (  1'B1 /*|  I_mc_rstn */  ), 	// user's overall botton reset, and will clean cfg
`ifdef SIMULATION_DDRC_EN
		.pbus_rst_n            ( 1 /*| I_mc_rstn*/         ), // implicitly driven by cfg center, set to 1.
`endif
		.pclk_ddr              ( cfg_pclk            ),// connect when user want to cfg IP by usr master in Fabric
		.r_system_pll_reg      ( r_system_pll_reg    ),
	
		//output ..
		.axi_port00_aclk     ( axi_port00_aclk     ),  //output
		.axi_port00_arstn    ( axi_port00_arstn    ),  //output
		.axi_port02_aclk     ( axi_port02_aclk     ),  //output
		.axi_port02_arstn    ( axi_port02_arstn    ),  //output
		.bypasspll_mc_clk_x4 ( bypasspll_mc_clk_x4 ),  //output
		.fp_cs_rstn          ( fp_cs_rstn          ),  //output..
		.mc_clk              ( mc_clk              ),  //output
		.mc_clk_us           ( ), //output , implicitly to syn/async clk mux
		.mc_rstn             ( mc_rstn             ),  //output
		.mcfg_rstn           ( mcfg_rstn           ),  //output
		.prstn_gx            ( prstn_gx            ),  //output
		.rst_p_n             ( rst_p_n             ),  //output 
		.usr_pbus_rstn       ( usr_pbus_rstn       ),  //output.  only reset the local pbug. 
		.x0_async_clk        ( w_x0connection      ),  // output when using ASYNC AXI bridge also connect this	
		.x1_async_clk        ( w_x1connection      )   // output when using ASYNC AXI bridge also connect this
		                                        // when using SYNC bridge, connect the *us as mc_clk_ug
	// if user want to sw_rst one of the module, pls ref to the register r_system_pll_reg
);


//4170_011C[0], 0: JTAG OR CCB ; 1: FP.
ctrl_wrapper #(
	.bus_ctl_sel     ( CFG_MC_BUS_SEL )  // 4120_8000[0], DDRC user bus selection: 0: AXI ; 1: SDII  
	,.ddr_ctl_iso_en ( 1'b1      )  // 4120_8000[6], 0: all ddrc’s outputs are isolated ; 1: normal working mode
	,.ddr_ctl_pd     ( 1'b0      )  // 4120_8000[5], reserved, default 0.
	,.reg32_50       ( reg32_50  )
	,.reg32_100      ( reg32_100 )
	,.reg32_104      ( reg32_104 )
	,.reg32_108      ( reg32_108 )
	,.reg32_10c      ( reg32_10c )
	,.reg32_110      ( reg32_110 )
	,.reg32_140      ( reg32_140 )
	,.reg32_144      ( reg32_144 )
	,.reg32_148      ( reg32_148 )
	,.reg32_14c      ( reg32_14c )
	,.reg32_150      ( reg32_150 )
	,.reg32_190      ( reg32_190 )
	,.reg32_1c0      ( reg32_1c0 )
	,.reg32_180      ( reg32_180 )
	,.reg32_184      ( reg32_184 )
	,.reg32_188      ( reg32_188 )
	,.reg32_18c      ( reg32_18c )
	,.reg32_1e0      ( reg32_1e0 )
	,.reg32_1e4      ( reg32_1e4 )
	,.reg32_1e8      ( reg32_1e8 )
	,.reg32_1ec      ( reg32_1ec )
	,.reg32_1f0      ( reg32_1f0 )
	,.reg32_1f4      ( reg32_1f4 )
	,.reg32_1f8      ( reg32_1f8 )
	,.reg32_1fc      ( reg32_1fc )
	,.reg32_04       ( reg32_04  )
	,.reg32_08       ( reg32_08  )
	,.reg32_0c       ( reg32_0c  )
	,.reg32_10       ( reg32_10  )
	,.reg32_14       ( reg32_14  )
	,.reg32_18       ( reg32_18  )
	,.reg32_1c       ( reg32_1c  )
	,.reg32_20       ( reg32_20  )
	,.reg32_24       ( reg32_24  )
	,.reg32_28       ( reg32_28  )
	,.reg32_2c       ( reg32_2c  )
	,.reg32_30       ( reg32_30  )
	,.reg32_34       ( reg32_34  )
	,.reg32_38       ( reg32_38  )
	,.reg32_3c       ( reg32_3c  ) //add by chendk
	,.reg32_54       ( reg32_54  ) //add by Johnson for DDR x16 mode
	,.reg32_58       ( reg32_58  )
	,.reg32_64       ( reg32_64  )
	,.reg32_68       ( reg32_68  )
	,.reg32_00       ( reg32_00  )
	,.reg32_118      ( reg32_118 )
	,.reg32_11c      ( reg32_11c ) //add by chendk
	,.reg32_120      ( reg32_120 )
	,.reg32_124      ( reg32_124 ) //add by chendk
	,.reg32_128      ( reg32_128 )
	,.reg32_12c      ( reg32_12c ) //add by chendk
	,.reg32_130      ( reg32_130 )
	,.reg32_134      ( reg32_134 ) //add by chendk
	,.reg32_114      ( reg32_114 )
			//those just be too many, will be covered by a simple cfg file 
			//parameter reg32_00 = 32'h00000000;
			//parameter reg32_04 = 32'h00000000;
			//parameter reg32_08 = 32'h00000000;
) u_ddrc(
	//input..
	.ro_ddr23phy_reg         ( ro_ddr23phy_reg          )
`ifdef SIM_MASTER_CFG_DDR_CORE_EN
	,.ahb_cfg_haddr_i				 ( ctl_ahb_cfg_haddr_i			)
	,.ahb_cfg_hburst_i			     ( ctl_ahb_cfg_hburst_i			)
	,.ahb_cfg_hclk				     ( ctl_ahb_cfg_hclk			  	) // where are you from ?  Oh, it comes from FP..
	,.ahb_cfg_hready_i			     ( ctl_ahb_cfg_hready_i			)
	,.ahb_cfg_hresetn				 ( mcfg_rstn				    ) // fp->through crg->here
	,.ahb_cfg_hsel_i				 ( ctl_ahb_cfg_hsel_i		  	)
	,.ahb_cfg_hsize_i				 ( ctl_ahb_cfg_hsize_i			)
	,.ahb_cfg_htrans_i			     ( ctl_ahb_cfg_htrans_i			)
	,.ahb_cfg_hwdata_i			     ( ctl_ahb_cfg_hwdata_i			)
	,.ahb_cfg_hwrite_i			     ( ctl_ahb_cfg_hwrite_i			)
`endif
	,.axi_port00_aclk				( axi_port00_aclk				) 
	,.axi_port00_arstn			    ( axi_port00_arstn				)
	,.axi_port02_aclk				( axi_port02_aclk				) 
	,.axi_port02_arstn				( axi_port02_arstn				)
`ifdef SIM_DFI_BUS
	,.dram_dfi_ctrlupd_ack			( dram_dfi_ctrlupd_ack			)
	,.dram_dfi_ecc_rddata_w0		( dram_dfi_ecc_rddata_w0		)
	,.dram_dfi_ecc_rddata_w1		( dram_dfi_ecc_rddata_w1		)
	,.dram_dfi_init_complete		( dram_dfi_init_complete		)		
	,.dram_dfi_rddata_valid_w0      ( dram_dfi_rddata_valid_w0		) 	
	,.dram_dfi_rddata_valid_w1	    ( dram_dfi_rddata_valid_w1		)
	,.dram_dfi_rddata_w0			( dram_dfi_rddata_w0			)
	,.dram_dfi_rddata_w1			( dram_dfi_rddata_w1			)
	,.dram_dfi_rdlvl_gate_mode		( dram_dfi_rdlvl_gate_mode		) 		
	,.dram_dfi_rdlvl_mode			( dram_dfi_rdlvl_mode			) 	
	,.dram_dfi_rdlvl_resp			( dram_dfi_rdlvl_resp			) 	
	,.dram_dfi_wrlvl_mode			( dram_dfi_wrlvl_mode			)
	,.dram_dfi_wrlvl_resp			( dram_dfi_wrlvl_resp			) 
`endif
	,.i_p0                    ( S_port0_data_to_ip /* I_port_0  */              )	// refer to mux2usr 
	,.i_p1                    ( S_port1_data_to_ip /* I_port_1  */               )  // by another RTL module of IC
	,.mc_clk				          ( mc_clk				        ) 
	,.mc_rstn				          ( mc_rstn				        )
	
	//output..
	,.r_ddr23phy_reg				( r_ddr23phy_reg				)
`ifdef SIM_MASTER_CFG_DDR_CORE_EN
	,.ahb_cfg_hrdata_o				( ctl_ahb_cfg_hrdata_o			) 
	,.ahb_cfg_hready_o				( ctl_ahb_cfg_hready_o			) 
	,.ahb_cfg_hresp_o				( ctl_ahb_cfg_hresp_o			)
`endif

`ifdef SIM_DFI_BUS
	,.dram_dfi_addr_p0				( dram_dfi_addr_p0				)
	,.dram_dfi_addr_p1				( dram_dfi_addr_p1				) 
	,.dram_dfi_bank_p0				( dram_dfi_bank_p0				) 
	,.dram_dfi_bank_p1				( dram_dfi_bank_p1				)
	,.dram_dfi_cas_n_p0				( dram_dfi_cas_n_p0				)	 
	,.dram_dfi_cas_n_p1				( dram_dfi_cas_n_p1				)
	,.dram_dfi_cke_p0				( dram_dfi_cke_p0				)
	,.dram_dfi_cke_p1				( dram_dfi_cke_p1				)
	,.dram_dfi_cs_n_duplicate_p0	( dram_dfi_cs_n_duplicate_p0	)
	,.dram_dfi_cs_n_duplicate_p1	( dram_dfi_cs_n_duplicate_p1	)
	,.dram_dfi_cs_n_p0				( dram_dfi_cs_n_p0				)
	,.dram_dfi_cs_n_p1				( dram_dfi_cs_n_p1				)
	,.dram_dfi_ctrlupd_req			( dram_dfi_ctrlupd_req			)
	,.dram_dfi_dram_clk_disable		( dram_dfi_dram_clk_disable		)
	,.dram_dfi_ecc_rddata_en_p0		( dram_dfi_ecc_rddata_en_p0		)
	,.dram_dfi_ecc_rddata_en_p1		( dram_dfi_ecc_rddata_en_p1		)
	,.dram_dfi_ecc_wrdata_en_p0		( dram_dfi_ecc_wrdata_en_p0		)
	,.dram_dfi_ecc_wrdata_en_p1		( dram_dfi_ecc_wrdata_en_p1		)
	,.dram_dfi_ecc_wrdata_p0		( dram_dfi_ecc_wrdata_p0		)
	,.dram_dfi_ecc_wrdata_p1		( dram_dfi_ecc_wrdata_p1		)
	,.dram_dfi_ecc_wrmask_p0		( dram_dfi_ecc_wrmask_p0		)
	,.dram_dfi_ecc_wrmask_p1		( dram_dfi_ecc_wrmask_p1		)
	,.dram_dfi_init_start			( dram_dfi_init_start			)
	,.dram_dfi_ras_n_p0				( dram_dfi_ras_n_p0				)
	,.dram_dfi_ras_n_p1				( dram_dfi_ras_n_p1				)
	,.dram_dfi_rddata_en_p0			( dram_dfi_rddata_en_p0			) 
	,.dram_dfi_rddata_en_p1			( dram_dfi_rddata_en_p1			)
	,.dram_dfi_rdlvl_delay			( dram_dfi_rdlvl_delay			)
	,.dram_dfi_rdlvl_delayn			( dram_dfi_rdlvl_delayn			)
	,.dram_dfi_rdlvl_edge			( dram_dfi_rdlvl_edge			)
	,.dram_dfi_rdlvl_en				( dram_dfi_rdlvl_en				)
	,.dram_dfi_rdlvl_gate_delay		( dram_dfi_rdlvl_gate_delay		) 		
	,.dram_dfi_rdlvl_gate_en		( dram_dfi_rdlvl_gate_en		)
	,.dram_dfi_rdlvl_load			( dram_dfi_rdlvl_load			)
 	,.dram_dfi_reset_n_p0			( dram_dfi_reset_n_p0			)
	,.dram_dfi_reset_n_p1			( dram_dfi_reset_n_p1			) 	
	,.dram_dfi_we_n_p0				( dram_dfi_we_n_p0				)	
	,.dram_dfi_we_n_p1				( dram_dfi_we_n_p1				)
	,.dram_dfi_wodt_p0				( dram_dfi_wodt_p0				) 
	,.dram_dfi_wodt_p1				( dram_dfi_wodt_p1				)
	,.dram_dfi_wrdata_en_p0		( dram_dfi_wrdata_en_p0			)
	,.dram_dfi_wrdata_en_p1		( dram_dfi_wrdata_en_p1			) 	
	,.dram_dfi_wrdata_p0			( dram_dfi_wrdata_p0			) 	
	,.dram_dfi_wrdata_p1			( dram_dfi_wrdata_p1			)
	,.dram_dfi_wrlvl_delay		( dram_dfi_wrlvl_delay			)
	,.dram_dfi_wrlvl_en				( dram_dfi_wrlvl_en				) 
	,.dram_dfi_wrlvl_load			( dram_dfi_wrlvl_load			)
	,.dram_dfi_wrlvl_strobe			( dram_dfi_wrlvl_strobe			)
	,.dram_dfi_wrmask_p0			( dram_dfi_wrmask_p0			)	
	,.dram_dfi_wrmask_p1			( dram_dfi_wrmask_p1			)
`endif
	,.gating_mc_clk				    ( gating_mc_clk				    )
	,.intr                          ( intr                          )
	// user data interface
	,.o_p0   						( S_port0_data_to_usr /* O_port_0 */ ) // these signals will be seperated  
	,.o_p1   						( S_port1_data_to_usr /* O_port_1 */  ) // to meaningful name
	,.r_system_pll_reg				( r_system_pll_reg				) 
);

phy_wrapper #(
     .phy_test_iddq  ( 1'b0 )   // 4120_8000[2] , DDR PHY IDDQ test control,
    ,.dfi_sphy_sel   ( 1'b0 )   // 4120_8000[1] , DDR DFI selection: 0: DDRC user bus ; 1: DDR DFI bus from PHY(DDRC bypassed) ;
    ,.ddr_phy_iso_en ( 1'b1 )   // 4120_8000[4] , reserved , default 0.
    ,.ddr_phy_pd     ( 1'b1 )   // 4120_8000[3] , reserved , default 0.
    //others are about iodc_* for GPIO settings
) u_ddr23phy (
`ifndef SIM_INTER_WIRE
	//input..
	.r_ddr23phy_reg				( r_ddr23phy_reg			)
	
`ifdef SIM_MASTER_CFG_DDR_PHY_EN
	,.ahb_haddr_i			    ( phy_ahb_haddr_i			)
	,.ahb_hburst_i				( phy_ahb_hburst_i			)
	,.ahb_hclk				    ( phy_ahb_hclk				) //where are you from ? 
	,.ahb_hready_i				( phy_ahb_hready_i			)
	,.ahb_hresetn				( phy_ahb_hresetn			) //where are you from ? 
	,.ahb_hsel_i				( phy_ahb_hsel_i			)
	,.ahb_hsize_i				( phy_ahb_hsize_i			)
	,.ahb_htrans_i				( phy_ahb_htrans_i			)
	,.ahb_hwdata_i				( phy_ahb_hwdata_i			)
	,.ahb_hwrite_i				( phy_ahb_hwrite_i			)
`endif

	,.bypasspll_mc_clk_x4		( bypasspll_mc_clk_x4		)
`ifdef SIM_DFI_BUS
	,.dram_dfi_addr_p0			( dram_dfi_addr_p0			)
	,.dram_dfi_addr_p1			( dram_dfi_addr_p1			)
	,.dram_dfi_bank_p0			( dram_dfi_bank_p0			)
	,.dram_dfi_bank_p1			( dram_dfi_bank_p1			)
	,.dram_dfi_cas_n_p0			( dram_dfi_cas_n_p0			)
	,.dram_dfi_cas_n_p1			( dram_dfi_cas_n_p1			)
	,.dram_dfi_cke_p0			  ( dram_dfi_cke_p0		  	)
	,.dram_dfi_cke_p1			  ( dram_dfi_cke_p1			  )
	,.dram_dfi_cs_n_duplicate_p0( dram_dfi_cs_n_duplicate_p0 )
	,.dram_dfi_cs_n_duplicate_p1( dram_dfi_cs_n_duplicate_p1 )
	,.dram_dfi_cs_n_p0			( dram_dfi_cs_n_p0			)
	,.dram_dfi_cs_n_p1			( dram_dfi_cs_n_p1			)
	,.dram_dfi_ctrlupd_req		( dram_dfi_ctrlupd_req		)
	,.dram_dfi_dram_clk_disable	( dram_dfi_dram_clk_disable	)
	,.dram_dfi_ecc_rddata_en_p0	( dram_dfi_ecc_rddata_en_p0	)
	,.dram_dfi_ecc_rddata_en_p1	( dram_dfi_ecc_rddata_en_p1	)
	,.dram_dfi_ecc_wrdata_en_p0	( dram_dfi_ecc_wrdata_en_p0	)
	,.dram_dfi_ecc_wrdata_en_p1	( dram_dfi_ecc_wrdata_en_p1	)
	,.dram_dfi_ecc_wrdata_p0	( dram_dfi_ecc_wrdata_p0	)
	,.dram_dfi_ecc_wrdata_p1	( dram_dfi_ecc_wrdata_p1	)
	,.dram_dfi_ecc_wrmask_p0	( dram_dfi_ecc_wrmask_p0	)
	,.dram_dfi_ecc_wrmask_p1	( dram_dfi_ecc_wrmask_p1	)
	,.dram_dfi_init_start		( dram_dfi_init_start		)
	,.dram_dfi_ras_n_p0			( dram_dfi_ras_n_p0			)
	,.dram_dfi_ras_n_p1			( dram_dfi_ras_n_p1			)
	,.dram_dfi_rddata_en_p0		( dram_dfi_rddata_en_p0		)
	,.dram_dfi_rddata_en_p1		( dram_dfi_rddata_en_p1		)
	,.dram_dfi_rdlvl_delay		( dram_dfi_rdlvl_delay		)
	,.dram_dfi_rdlvl_delayn		( dram_dfi_rdlvl_delayn		)
	,.dram_dfi_rdlvl_edge		( dram_dfi_rdlvl_edge		)
	,.dram_dfi_rdlvl_en			( dram_dfi_rdlvl_en			)
	,.dram_dfi_rdlvl_gate_delay	( dram_dfi_rdlvl_gate_delay	)
	,.dram_dfi_rdlvl_gate_en	( dram_dfi_rdlvl_gate_en	)
	,.dram_dfi_rdlvl_load		( dram_dfi_rdlvl_load		)
	,.dram_dfi_reset_n_p0		( dram_dfi_reset_n_p0		)
	,.dram_dfi_reset_n_p1		( dram_dfi_reset_n_p1		)
	,.dram_dfi_we_n_p0			( dram_dfi_we_n_p0			)
	,.dram_dfi_we_n_p1			( dram_dfi_we_n_p1			)
	,.dram_dfi_wodt_p0			( dram_dfi_wodt_p0			)
	,.dram_dfi_wodt_p1			( dram_dfi_wodt_p1			)
	,.dram_dfi_wrdata_en_p0		( dram_dfi_wrdata_en_p0		)
	,.dram_dfi_wrdata_en_p1		( dram_dfi_wrdata_en_p1		)
	,.dram_dfi_wrdata_p0		( dram_dfi_wrdata_p0		)
	,.dram_dfi_wrdata_p1		( dram_dfi_wrdata_p1		)
	,.dram_dfi_wrlvl_delay		( dram_dfi_wrlvl_delay		)
	,.dram_dfi_wrlvl_en			( dram_dfi_wrlvl_en			)
	,.dram_dfi_wrlvl_load		( dram_dfi_wrlvl_load		)
	,.dram_dfi_wrlvl_strobe		( dram_dfi_wrlvl_strobe		)
	,.dram_dfi_wrmask_p0		( dram_dfi_wrmask_p0		)
	,.dram_dfi_wrmask_p1		( dram_dfi_wrmask_p1		)
`endif
	,.mc_clk				      ( mc_clk				        )
	,.mc_clk_rst_n				( mc_rstn				      	)
	
	//output...
	,.ro_ddr23phy_reg			( ro_ddr23phy_reg			  )
`ifdef SIM_MASTER_CFG_DDR_PHY_EN
	,.ahb_hrdata_o				( phy_ahb_hrdata_o			)
	,.ahb_hready_o				( phy_ahb_hready_o			)
	,.ahb_hresp_o			  	( phy_ahb_hresp_o			  )
`endif

`ifdef SIM_DFI_BUS
	,.dram_dfi_ctrlupd_ack		  ( dram_dfi_ctrlupd_ack		  )
	,.dram_dfi_ecc_rddata_w0	  ( dram_dfi_ecc_rddata_w0	  )
	,.dram_dfi_ecc_rddata_w1	  ( dram_dfi_ecc_rddata_w1	  )	
	,.dram_dfi_init_complete	  ( dram_dfi_init_complete	  )
	,.dram_dfi_rddata_valid_w0	( dram_dfi_rddata_valid_w0	)
	,.dram_dfi_rddata_valid_w1	( dram_dfi_rddata_valid_w1	)
	,.dram_dfi_rddata_w0		    ( dram_dfi_rddata_w0		    )
	,.dram_dfi_rddata_w1	    	( dram_dfi_rddata_w1	    	)
	,.dram_dfi_rdlvl_gate_mode	( dram_dfi_rdlvl_gate_mode	)
	,.dram_dfi_rdlvl_mode		    ( dram_dfi_rdlvl_mode		    )
	,.dram_dfi_rdlvl_resp		    ( dram_dfi_rdlvl_resp		    )
	,.dram_dfi_wrlvl_mode		    ( dram_dfi_wrlvl_mode	    	)
	,.dram_dfi_wrlvl_resp		    ( dram_dfi_wrlvl_resp	    	)
`endif
	//-- link sdram 
`endif
);

assign O_init_done = 1'b1;
assign O_init_pass = 1'b1;

/*
check_ddr_cfg_done #(
		.reg32_00    ( reg32_00     )
		,.reg32_04   ( reg32_04     )
		,.reg32_3c   ( reg32_3c     )
	)
	cfg_inst(
		.I_sys_clk   ( cfg_pclk     ),
		.I_sys_rst_n ( I_cfg_rstn   ),
		.I_ddr_rdy   ( 1            ),
		//
		.O_paddr     ( pbus_addr    ),
		.O_pwrite    ( pbus_write   ),
		.O_req       ( pbus_req     ),
		.O_pwdata    ( pbus_wdata   ),
		.I_gnt       ( pbus_gnt     ),
		.I_prdata    ( pbus_rdata   ),
		//
		.O_done      ( O_init_done  ),
		.O_error     ( O_init_pass  ),
		.I_intr           ( intr              ),
		.O_error_status   ( O_error_status    ),
		.O_error_status_en( O_error_status_en )
);


// instance the bridge from user to IP to take over the CCB CFG
bus_top  #(
	.cfg_fp2ip_sel	        (  CFG_IP2IP_SEL        )  //4170_011C[0] , 1=gx/ddr bus inferface connect to array ; 0= gx/ddr bus inferface connect to spine.
) u_cfg_bus(
// input ..
	.i						( { pbus_req, NC_s0 }   )
//	,.cbi_pbus_gnt          ( )
//	,.cbi_pbus_rdata        ( )
	,.clk_p		            ( cfg_pclk           	)
`ifdef SIM_MASTER_CFG_DDR_CORE_EN
	,.ctl_ahb_cfg_hrdata_o  ( ctl_ahb_cfg_hrdata_o  )
	,.ctl_ahb_cfg_hready_o  ( ctl_ahb_cfg_hready_o  )
	,.ctl_ahb_cfg_hresp_o   ( ctl_ahb_cfg_hresp_o   )
`endif	
	,.fp_cs_clk             ( cfg_pclk          	)
	,.fp_cs_rstn            ( fp_cs_rstn     	    )
//	,.hreg_hrdata         ( )
//	,.hreg_hready_out     ( )
	,.pbus_addr				      ( { 16'h0, pbus_addr }  )
`ifdef SIM_MASTER_CFG_EN
	,.pbus_req				      ( inner_pbus_req 		    ) //has be tied to port o.
`endif
	,.pbus_wdata			      ( pbus_wdata           	)
	,.pbus_write			      ( pbus_write           	)
	,.pclk_ddr              ( cfg_pclk             	)
//	,.pcsps_pbus_gnt        ( )
//	,.pcsps_pbus_rdata      ( )
`ifdef SIM_MASTER_CFG_DDR_PHY_EN
	,.phy_ahb_hrdata_o      ( phy_ahb_hrdata_o      )
	,.phy_ahb_hready_o      ( phy_ahb_hready_o      )
	,.phy_ahb_hresp_o       ( phy_ahb_hresp_o       )
`endif

`ifdef SIM_MASTER_CFG_EN
	,.s                     ( 1 ) // have been set to 1 by inner..
`endif
	,.usr_pbus_rstn         ( usr_pbus_rstn      	)
	
	// output..
//	,.cbi_pbus_addr         ( )
//	,.cbi_pbus_req          ( )
//	,.cbi_pbus_wdata        ( )
//	,.cbi_pbus_write        ( )	
`ifdef SIM_MASTER_CFG_DDR_CORE_EN	
	,.ctl_ahb_cfg_haddr_i   ( ctl_ahb_cfg_haddr_i    )
	,.ctl_ahb_cfg_hburst_i  ( ctl_ahb_cfg_hburst_i   )
	,.ctl_ahb_cfg_hready_i  ( ctl_ahb_cfg_hready_i   )
	,.ctl_ahb_cfg_hsel_i    ( ctl_ahb_cfg_hsel_i     )
	,.ctl_ahb_cfg_hsize_i   ( ctl_ahb_cfg_hsize_i    )
	,.ctl_ahb_cfg_htrans_i  ( ctl_ahb_cfg_htrans_i   )
	,.ctl_ahb_cfg_hwdata_i  ( ctl_ahb_cfg_hwdata_i   )
	,.ctl_ahb_cfg_hwrite_i  ( ctl_ahb_cfg_hwrite_i   )
`endif
//	,.hreg_haddr            ( )
//	,.hreg_htrans           ( )
//	,.hreg_hwdata           ( )
//	,.hreg_hwrite           ( )
`ifdef SIM_MASTER_CFG_EN
	,.o                     ( inner_pbus_req         )
`endif
	,.pbus_gnt			    ( pbus_gnt          	 )	//to master config
	,.pbus_rdata			( pbus_rdata          	 )  //to master config
//	,.pcsps_pbus_addr       ( )
//	,.pcsps_pbus_req        ( )
//	,.pcsps_pbus_wdata      ( )
//	,.pcsps_pbus_write      ( )
`ifdef SIM_MASTER_CFG_DDR_PHY_EN
	,.phy_ahb_haddr_i       ( phy_ahb_haddr_i        )
	,.phy_ahb_hburst_i      ( phy_ahb_hburst_i       )
	,.phy_ahb_hready_i      ( phy_ahb_hready_i       )
	,.phy_ahb_hsel_i        ( phy_ahb_hsel_i         )
	,.phy_ahb_hsize_i       ( phy_ahb_hsize_i        )
	,.phy_ahb_htrans_i      ( phy_ahb_htrans_i       )
	,.phy_ahb_hwdata_i      ( phy_ahb_hwdata_i       )
	,.phy_ahb_hwrite_i      ( phy_ahb_hwrite_i       )	
`endif
);
*/


array2ddr_mux mux_inst(
		.axi_port00_awid      ( axi_port00_awid    )
		,.axi_port00_awaddr   ( axi_port00_awaddr  )
		,.axi_port00_awlen    ( axi_port00_awlen   )  
		,.axi_port00_awsize   ( axi_port00_awsize  ) 
		,.axi_port00_awburst  ( axi_port00_awburst )
		,.axi_port00_awvalid  ( axi_port00_awvalid )
		,.axi_port00_awready  ( axi_port00_awready )
		,.axi_port00_wid      ( axi_port00_wid     )    
		,.axi_port00_wdata    ( axi_port00_wdata   )  
		,.axi_port00_wstrb    ( axi_port00_wstrb   )  
		,.axi_port00_wlast    ( axi_port00_wlast   )  
		,.axi_port00_wvalid   ( axi_port00_wvalid  ) 
		,.axi_port00_wready   ( axi_port00_wready  ) 
		,.axi_port00_bid      ( axi_port00_bid     )    
		,.axi_port00_bresp    ( axi_port00_bresp   )  
		,.axi_port00_bvalid   ( axi_port00_bvalid  ) 
		,.axi_port00_bready   ( axi_port00_bready  ) 
		,.axi_port00_arid     ( axi_port00_arid    )   
		,.axi_port00_araddr   ( axi_port00_araddr  ) 
		,.axi_port00_arlen    ( axi_port00_arlen   )  
		,.axi_port00_arsize   ( axi_port00_arsize  ) 
		,.axi_port00_arburst  ( axi_port00_arburst )
		,.axi_port00_arvalid  ( axi_port00_arvalid )
		,.axi_port00_arready  ( axi_port00_arready )
		,.axi_port00_rid      ( axi_port00_rid     )
		,.axi_port00_rdata    ( axi_port00_rdata   )
		,.axi_port00_rresp    ( axi_port00_rresp   )
		,.axi_port00_rlast    ( axi_port00_rlast   )
		,.axi_port00_rvalid   ( axi_port00_rvalid  )
		,.axi_port00_rready   ( axi_port00_rready  )
		,.axi_port02_awid     ( axi_port01_awid    ) 
		,.axi_port02_awaddr   ( axi_port01_awaddr  )
		,.axi_port02_awlen    ( axi_port01_awlen   )
		,.axi_port02_awsize   ( axi_port01_awsize  )
		,.axi_port02_awburst  ( axi_port01_awburst )
		,.axi_port02_awvalid  ( axi_port01_awvalid )
		,.axi_port02_awready  ( axi_port01_awready )
		,.axi_port02_wid      ( axi_port01_wid     )
		,.axi_port02_wdata    ( axi_port01_wdata   )
		,.axi_port02_wstrb    ( axi_port01_wstrb   )
		,.axi_port02_wlast    ( axi_port01_wlast   )
		,.axi_port02_wvalid   ( axi_port01_wvalid  )
		,.axi_port02_wready   ( axi_port01_wready  )
		,.axi_port02_bid      ( axi_port01_bid     )
		,.axi_port02_bresp    ( axi_port01_bresp   )
		,.axi_port02_bvalid   ( axi_port01_bvalid  )
		,.axi_port02_bready   ( axi_port01_bready  )
		,.axi_port02_arid     ( axi_port01_arid    )
		,.axi_port02_araddr   ( axi_port01_araddr  )
		,.axi_port02_arlen    ( axi_port01_arlen   )
		,.axi_port02_arsize   ( axi_port01_arsize  )
		,.axi_port02_arburst  ( axi_port01_arburst )		
		,.axi_port02_arvalid  ( axi_port01_arvalid )
		,.axi_port02_arready  ( axi_port01_arready )
		,.axi_port02_rid      ( axi_port01_rid     )
		,.axi_port02_rdata    ( axi_port01_rdata   )
		,.axi_port02_rresp    ( axi_port01_rresp   )
		,.axi_port02_rlast    ( axi_port01_rlast   )
		,.axi_port02_rvalid   ( axi_port01_rvalid  )
		,.axi_port02_rready   ( axi_port01_rready  )
		,.sdii_port01_cmd_req        ( sdii_port00_req        )
		,.sdii_port01_cmd_gnt        ( sdii_port00_gnt        )
		,.sdii_port01_cmd_rw         ( sdii_port00_rw         )
		,.sdii_port01_cmd_addr       ( sdii_port00_addr       )
		,.sdii_port01_cmd_len        ( sdii_port00_len        )
		,.sdii_port01_cmd_partial_wrt( sdii_port00_partial_wrt)
		,.sdii_port01_wdata_pop      ( sdii_port00_wdata_pop  )
		,.sdii_port01_wdata          ( sdii_port00_wdata      )
		,.sdii_port01_wmask          ( sdii_port00_wmask      )
		,.sdii_port01_rdata_psh      ( sdii_port00_rdata_psh  )
		,.sdii_port01_rdata          ( sdii_port00_rdata      )
		,.sdii_port03_cmd_req	     ( sdii_port01_req	      )
		,.sdii_port03_cmd_gnt	     ( sdii_port01_gnt	      )
		,.sdii_port03_cmd_rw         ( sdii_port01_rw         )
		,.sdii_port03_cmd_addr       ( sdii_port01_addr       )
		,.sdii_port03_cmd_len        ( sdii_port01_len        )
		,.sdii_port03_cmd_partial_wrt( sdii_port01_partial_wrt)
		,.sdii_port03_wdata_pop      ( sdii_port01_wdata_pop  )
		,.sdii_port03_wdata          ( sdii_port01_wdata      )
		,.sdii_port03_wmask          ( sdii_port01_wmask      )
		,.sdii_port03_rdata_psh      ( sdii_port01_rdata_psh  )
		,.sdii_port03_rdata          ( sdii_port01_rdata      )
		,.i_p0 ( S_port0_data_to_ip  )
		,.i_p1 ( S_port1_data_to_ip  )
		,.o_p0 ( S_port0_data_to_usr )
		,.o_p1 ( S_port1_data_to_usr )
		,.cfg_mc_bus_sel  ( CFG_MC_BUS_SEL )	
	);


endmodule
