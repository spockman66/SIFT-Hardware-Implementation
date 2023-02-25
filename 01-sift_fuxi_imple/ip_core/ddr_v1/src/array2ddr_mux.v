//----------------------------
module common_2i1 (
    i0,i1,o,s
);
parameter WIDTH = 281*2;
input   [WIDTH - 1:0]   i0,i1;
output  [WIDTH - 1:0]   o;
input                   s;
reg     [WIDTH - 1:0]   o;
always @(*) case (s)
    'b1:    o = i1;
`ifdef SIM
    'bz,'bx:o = {WIDTH{1'bx}};
`endif
    default:o = i0;
endcase
endmodule
//----------------------------
module common_1o2 (
    i,o1,o0
);
parameter WIDTH = 281*2;
input   [WIDTH - 1:0]   i;
output  [WIDTH - 1:0]   o0,o1;
assign o0 = i;
assign o1 = i;
endmodule

//----------------------------
module array2ddr_mux(
//axi_port00_arstn , 
//axi_port00_aclk	 ,
//axi_port02_arstn , 
//axi_port02_aclk	 ,
//mc_clk ,
//mc_rstn ,
axi_port00_awid ,	 
axi_port00_awaddr ,
axi_port00_awlen , 
axi_port00_awsize ,
axi_port00_awburst ,
axi_port00_awvalid ,
axi_port00_awready ,
axi_port00_wid ,		 
axi_port00_wdata  ,
axi_port00_wstrb , 
axi_port00_wlast  , 
axi_port00_wvalid ,
axi_port00_wready ,
axi_port00_bid ,	 
axi_port00_bresp , 
axi_port00_bvalid ,
axi_port00_bready ,
axi_port00_arid ,	 
axi_port00_araddr ,
axi_port00_arlen , 
axi_port00_arsize ,
axi_port00_arburst ,
axi_port00_arvalid ,
axi_port00_arready ,
axi_port00_rid ,	 
axi_port00_rdata , 
axi_port00_rresp , 
axi_port00_rlast , 
axi_port00_rvalid ,
axi_port00_rready ,
axi_port02_awid	 ,	
axi_port02_awaddr ,	
axi_port02_awlen ,	
axi_port02_awsize ,	
axi_port02_awburst ,	
axi_port02_awvalid ,	
axi_port02_awready ,	
axi_port02_wid ,		
axi_port02_wdata ,	
axi_port02_wstrb ,	
axi_port02_wlast ,	
axi_port02_wvalid ,	
axi_port02_wready ,	
axi_port02_bid ,		
axi_port02_bresp ,	
axi_port02_bvalid ,	
axi_port02_bready ,	
axi_port02_arid ,		
axi_port02_araddr ,	
axi_port02_arlen ,	
axi_port02_arsize ,	
axi_port02_arburst ,	
axi_port02_arvalid ,	
axi_port02_arready ,	
axi_port02_rid ,		
axi_port02_rdata ,	
axi_port02_rresp ,	
axi_port02_rlast ,	
axi_port02_rvalid ,	
axi_port02_rready ,
sdii_port01_cmd_req	,
sdii_port01_cmd_gnt	,
sdii_port01_cmd_rw ,
sdii_port01_cmd_addr ,
sdii_port01_cmd_len ,
sdii_port01_cmd_partial_wrt	,
sdii_port01_wdata_pop ,
sdii_port01_wdata ,
sdii_port01_wmask ,
sdii_port01_rdata_psh ,
sdii_port01_rdata ,
sdii_port03_cmd_req	,
sdii_port03_cmd_gnt	,
sdii_port03_cmd_rw ,
sdii_port03_cmd_addr ,
sdii_port03_cmd_len ,
sdii_port03_cmd_partial_wrt	,
sdii_port03_wdata_pop ,
sdii_port03_wdata ,
sdii_port03_wmask ,
sdii_port03_rdata_psh ,
sdii_port03_rdata ,	
i_p0 ,
i_p1 ,
o_p0 ,
o_p1 ,
cfg_mc_bus_sel
);



parameter       DDR23AXISLV_PORT00_DATABUS	= 128;
parameter       DDR23AXISLV_PORT01_DATABUS	= 128;
parameter       DDR23AXISLV_PORT02_DATABUS	= 128;
parameter       DDR23AXISLV_PORT03_DATABUS	= 128;
parameter       DDR23AXISLV_PORT04_DATABUS	= 128;

parameter       DDR23AXISLV_PORT00_IDWIDTH	= 16;
parameter       DDR23AXISLV_PORT01_IDWIDTH	= 16;
parameter       DDR23AXISLV_PORT02_IDWIDTH	= 16;
parameter       DDR23AXISLV_PORT03_IDWIDTH	= 16;
parameter       DDR23AXISLV_PORT04_IDWIDTH	= 16;

parameter       DDR23AHBSLV_PORT00_DATABUS	= 128;
parameter       DDR23AHBSLV_PORT01_DATABUS	= 128;
parameter       DDR23AHBSLV_PORT02_DATABUS	= 128;
parameter       DDR23AHBSLV_PORT03_DATABUS	= 128;
parameter       DDR23AHBSLV_PORT04_DATABUS	= 128;

parameter       DDR23AXISLV_PORT00_BYTENUM	= 16;
parameter       DDR23AXISLV_PORT01_BYTENUM	= 16;
parameter       DDR23AXISLV_PORT02_BYTENUM	= 16;
parameter       DDR23AXISLV_PORT03_BYTENUM	= 16;
parameter       DDR23AXISLV_PORT04_BYTENUM	= 16;

parameter       DDR23AXISLV_PORT00_BITNUM	= 4;
parameter       DDR23AXISLV_PORT01_BITNUM	= 4;
parameter       DDR23AXISLV_PORT02_BITNUM	= 4;
parameter       DDR23AXISLV_PORT03_BITNUM	= 4;
parameter       DDR23AXISLV_PORT04_BITNUM	= 4;


parameter       DFI_DATA_WIDTH			= 128;

//clock and reset
//input						mc_clk				;
//input						mc_rstn				;
//input						axi_port00_arstn		;
//input						axi_port00_aclk			;
//input						axi_port02_arstn		;
//input						axi_port02_aclk			;

// Port Interface axi_port00
input	[DDR23AXISLV_PORT00_IDWIDTH-1:0]	axi_port00_arid			;
input	[31:0]					axi_port00_araddr		;
input	[3:0]					axi_port00_arlen		;
input	[2:0]					axi_port00_arsize		;
input	[1:0]					axi_port00_arburst		;
input						axi_port00_arvalid		;
output						axi_port00_arready		;
output	[DDR23AXISLV_PORT00_IDWIDTH-1:0]	axi_port00_rid			;
output	[DDR23AXISLV_PORT00_DATABUS-1:0]	axi_port00_rdata		;
output	[1:0]					axi_port00_rresp		;
output						axi_port00_rlast		;
output						axi_port00_rvalid		;
input						axi_port00_rready		;
input	[DDR23AXISLV_PORT00_IDWIDTH-1:0]	axi_port00_awid			;
input	[31:0]					axi_port00_awaddr		;
input	[3:0]					axi_port00_awlen		;
input	[2:0]					axi_port00_awsize		;
input	[1:0]					axi_port00_awburst		;
input						axi_port00_awvalid		;
output						axi_port00_awready		;
input	[DDR23AXISLV_PORT00_IDWIDTH-1:0]	axi_port00_wid			;
input	[DDR23AXISLV_PORT00_DATABUS-1:0]	axi_port00_wdata		;
input	[(DDR23AXISLV_PORT00_DATABUS/8)-1:0]	axi_port00_wstrb		;
input						axi_port00_wlast		;
input						axi_port00_wvalid		;
output						axi_port00_wready		;
output	[DDR23AXISLV_PORT00_IDWIDTH-1:0]	axi_port00_bid			;
output	[1:0]					axi_port00_bresp		;
output						axi_port00_bvalid		;
input						axi_port00_bready		;

// Port Interface axi_port02
input	[DDR23AXISLV_PORT02_IDWIDTH-1:0]	axi_port02_arid			;
input	[31:0]					axi_port02_araddr		;
input	[3:0]					axi_port02_arlen		;
input	[2:0]					axi_port02_arsize		;
input	[1:0]					axi_port02_arburst		;
input						axi_port02_arvalid		;
output						axi_port02_arready		;
output	[DDR23AXISLV_PORT02_IDWIDTH-1:0]	axi_port02_rid			;
output	[DDR23AXISLV_PORT02_DATABUS-1:0]	axi_port02_rdata		;
output	[1:0]					axi_port02_rresp		;
output						axi_port02_rlast		;
output						axi_port02_rvalid		;
input						axi_port02_rready		;
input	[DDR23AXISLV_PORT02_IDWIDTH-1:0]	axi_port02_awid			;
input	[31:0]					axi_port02_awaddr		;
input	[3:0]					axi_port02_awlen		;
input	[2:0]					axi_port02_awsize		;
input	[1:0]					axi_port02_awburst		;
input						axi_port02_awvalid		;
output						axi_port02_awready		;
input	[DDR23AXISLV_PORT02_IDWIDTH-1:0]	axi_port02_wid			;
input	[DDR23AXISLV_PORT02_DATABUS-1:0]	axi_port02_wdata		;
input	[(DDR23AXISLV_PORT02_DATABUS/8)-1:0]	axi_port02_wstrb		;
input						axi_port02_wlast		;
input						axi_port02_wvalid		;
output						axi_port02_wready		;
output	[DDR23AXISLV_PORT02_IDWIDTH-1:0]	axi_port02_bid			;
output	[1:0]					axi_port02_bresp		;
output						axi_port02_bvalid		;
input						axi_port02_bready		;

// Port Interface sdii_port01
input						sdii_port01_cmd_req		;
output						sdii_port01_cmd_gnt		;
input						sdii_port01_cmd_rw		;
input	[31:0]					sdii_port01_cmd_addr		;
input	[5:0]					sdii_port01_cmd_len		;
input						sdii_port01_cmd_partial_wrt	;
output						sdii_port01_wdata_pop		;
input	[(DFI_DATA_WIDTH-1):0]			sdii_port01_wdata		;
input	[((DFI_DATA_WIDTH/8)-1):0]		sdii_port01_wmask		;
output						sdii_port01_rdata_psh		;
output	[(DFI_DATA_WIDTH-1):0]			sdii_port01_rdata		;

// Port Interface sdii_port03
input						sdii_port03_cmd_req		;
output						sdii_port03_cmd_gnt		;
input						sdii_port03_cmd_rw		;
input	[31:0]					sdii_port03_cmd_addr		;
input	[5:0]					sdii_port03_cmd_len		;
input						sdii_port03_cmd_partial_wrt	;
output						sdii_port03_wdata_pop		;
input	[(DFI_DATA_WIDTH-1):0]			sdii_port03_wdata		;
input	[((DFI_DATA_WIDTH/8)-1):0]		sdii_port03_wmask		;
output						sdii_port03_rdata_psh		;
output	[(DFI_DATA_WIDTH-1):0]			sdii_port03_rdata		;

//
output  [279:0] i_p0 ;
output  [279:0] i_p1 ;
input  [169:0] o_p0 ;
input  [169:0] o_p1 ;

//sel
input cfg_mc_bus_sel;

//wire [279:0] i_p0;

common_2i1 #(280) u_p0_i_1o2(
            .i0 ({axi_port00_araddr[31],axi_port00_araddr[30],axi_port00_araddr[29],axi_port00_araddr[28],axi_port00_araddr[27],axi_port00_araddr[26],axi_port00_araddr[25],axi_port00_araddr[24],axi_port00_araddr[23],axi_port00_araddr[22],axi_port00_araddr[21],axi_port00_araddr[20],axi_port00_araddr[19],axi_port00_araddr[18],axi_port00_araddr[17],axi_port00_araddr[16],axi_port00_araddr[15],axi_port00_araddr[14],axi_port00_araddr[13],axi_port00_araddr[12],axi_port00_araddr[11],axi_port00_araddr[10],axi_port00_araddr[9],axi_port00_araddr[8],axi_port00_araddr[7],axi_port00_araddr[6],axi_port00_araddr[5],axi_port00_araddr[4],axi_port00_araddr[3],axi_port00_araddr[2],axi_port00_araddr[1],axi_port00_araddr[0],axi_port00_arburst[1],axi_port00_arburst[0],axi_port00_arid[15],axi_port00_arid[14],axi_port00_arid[13],axi_port00_arid[12],axi_port00_arid[11],axi_port00_arid[10],axi_port00_arid[9],axi_port00_arid[8],axi_port00_arid[7],axi_port00_arid[6],axi_port00_arid[5],axi_port00_arid[4],axi_port00_arid[3],axi_port00_arid[2],axi_port00_arid[1],axi_port00_arid[0],axi_port00_arlen[3],axi_port00_arlen[2],axi_port00_arlen[1],axi_port00_arlen[0],axi_port00_arsize[2],axi_port00_arsize[1],axi_port00_arsize[0],axi_port00_arvalid,axi_port00_awaddr[31],axi_port00_awaddr[30],axi_port00_awaddr[29],axi_port00_awaddr[28],axi_port00_awaddr[27],axi_port00_awaddr[26],axi_port00_awaddr[25],axi_port00_awaddr[24],axi_port00_awaddr[23],axi_port00_awaddr[22],axi_port00_awaddr[21],axi_port00_awaddr[20],axi_port00_awaddr[19],axi_port00_awaddr[18],axi_port00_awaddr[17],axi_port00_awaddr[16],axi_port00_awaddr[15],axi_port00_awaddr[14],axi_port00_awaddr[13],axi_port00_awaddr[12],axi_port00_awaddr[11],axi_port00_awaddr[10],axi_port00_awaddr[9],axi_port00_awaddr[8],axi_port00_awaddr[7],axi_port00_awaddr[6],axi_port00_awaddr[5],axi_port00_awaddr[4],axi_port00_awaddr[3],axi_port00_awaddr[2],axi_port00_awaddr[1],axi_port00_awaddr[0],axi_port00_awburst[1],axi_port00_awburst[0],axi_port00_awid[15],axi_port00_awid[14],axi_port00_awid[13],axi_port00_awid[12],axi_port00_awid[11],axi_port00_awid[10],axi_port00_awid[9],axi_port00_awid[8],axi_port00_awid[7],axi_port00_awid[6],axi_port00_awid[5],axi_port00_awid[4],axi_port00_awid[3],axi_port00_awid[2],axi_port00_awid[1],axi_port00_awid[0],axi_port00_awlen[3],axi_port00_awlen[2],axi_port00_awlen[1],axi_port00_awlen[0],axi_port00_awsize[2],axi_port00_awsize[1],axi_port00_awsize[0],axi_port00_awvalid,axi_port00_bready,axi_port00_rready,axi_port00_wdata[127],axi_port00_wdata[126],axi_port00_wdata[125],axi_port00_wdata[124],axi_port00_wdata[123],axi_port00_wdata[122],axi_port00_wdata[121],axi_port00_wdata[120],axi_port00_wdata[119],axi_port00_wdata[118],axi_port00_wdata[117],axi_port00_wdata[116],axi_port00_wdata[115],axi_port00_wdata[114],axi_port00_wdata[113],axi_port00_wdata[112],axi_port00_wdata[111],axi_port00_wdata[110],axi_port00_wdata[109],axi_port00_wdata[108],axi_port00_wdata[107],axi_port00_wdata[106],axi_port00_wdata[105],axi_port00_wdata[104],axi_port00_wdata[103],axi_port00_wdata[102],axi_port00_wdata[101],axi_port00_wdata[100],axi_port00_wdata[99],axi_port00_wdata[98],axi_port00_wdata[97],axi_port00_wdata[96],axi_port00_wdata[95],axi_port00_wdata[94],axi_port00_wdata[93],axi_port00_wdata[92],axi_port00_wdata[91],axi_port00_wdata[90],axi_port00_wdata[89],axi_port00_wdata[88],axi_port00_wdata[87],axi_port00_wdata[86],axi_port00_wdata[85],axi_port00_wdata[84],axi_port00_wdata[83],axi_port00_wdata[82],axi_port00_wdata[81],axi_port00_wdata[80],axi_port00_wdata[79],axi_port00_wdata[78],axi_port00_wdata[77],axi_port00_wdata[76],axi_port00_wdata[75],axi_port00_wdata[74],axi_port00_wdata[73],axi_port00_wdata[72],axi_port00_wdata[71],axi_port00_wdata[70],axi_port00_wdata[69],axi_port00_wdata[68],axi_port00_wdata[67],axi_port00_wdata[66],axi_port00_wdata[65],axi_port00_wdata[64],axi_port00_wdata[63],axi_port00_wdata[62],axi_port00_wdata[61],axi_port00_wdata[60],axi_port00_wdata[59],axi_port00_wdata[58],axi_port00_wdata[57],axi_port00_wdata[56],axi_port00_wdata[55],axi_port00_wdata[54],axi_port00_wdata[53],axi_port00_wdata[52],axi_port00_wdata[51],axi_port00_wdata[50],axi_port00_wdata[49],axi_port00_wdata[48],axi_port00_wdata[47],axi_port00_wdata[46],axi_port00_wdata[45],axi_port00_wdata[44],axi_port00_wdata[43],axi_port00_wdata[42],axi_port00_wdata[41],axi_port00_wdata[40],axi_port00_wdata[39],axi_port00_wdata[38],axi_port00_wdata[37],axi_port00_wdata[36],axi_port00_wdata[35],axi_port00_wdata[34],axi_port00_wdata[33],axi_port00_wdata[32],axi_port00_wdata[31],axi_port00_wdata[30],axi_port00_wdata[29],axi_port00_wdata[28],axi_port00_wdata[27],axi_port00_wdata[26],axi_port00_wdata[25],axi_port00_wdata[24],axi_port00_wdata[23],axi_port00_wdata[22],axi_port00_wdata[21],axi_port00_wdata[20],axi_port00_wdata[19],axi_port00_wdata[18],axi_port00_wdata[17],axi_port00_wdata[16],axi_port00_wdata[15],axi_port00_wdata[14],axi_port00_wdata[13],axi_port00_wdata[12],axi_port00_wdata[11],axi_port00_wdata[10],axi_port00_wdata[9],axi_port00_wdata[8],axi_port00_wdata[7],axi_port00_wdata[6],axi_port00_wdata[5],axi_port00_wdata[4],axi_port00_wdata[3],axi_port00_wdata[2],axi_port00_wdata[1],axi_port00_wdata[0],axi_port00_wid[15],axi_port00_wid[14],axi_port00_wid[13],axi_port00_wid[12],axi_port00_wid[11],axi_port00_wid[10],axi_port00_wid[9],axi_port00_wid[8],axi_port00_wid[7],axi_port00_wid[6],axi_port00_wid[5],axi_port00_wid[4],axi_port00_wid[3],axi_port00_wid[2],axi_port00_wid[1],axi_port00_wid[0],axi_port00_wlast,axi_port00_wstrb[15],axi_port00_wstrb[14],axi_port00_wstrb[13],axi_port00_wstrb[12],axi_port00_wstrb[11],axi_port00_wstrb[10],axi_port00_wstrb[9],axi_port00_wstrb[8],axi_port00_wstrb[7],axi_port00_wstrb[6],axi_port00_wstrb[5],axi_port00_wstrb[4],axi_port00_wstrb[3],axi_port00_wstrb[2],axi_port00_wstrb[1],axi_port00_wstrb[0],axi_port00_wvalid})
            ,.i1({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,sdii_port01_cmd_addr[31],sdii_port01_cmd_addr[30],sdii_port01_cmd_addr[29],sdii_port01_cmd_addr[28],sdii_port01_cmd_addr[27],sdii_port01_cmd_addr[26],sdii_port01_cmd_addr[25],sdii_port01_cmd_addr[24],sdii_port01_cmd_addr[23],sdii_port01_cmd_addr[22],sdii_port01_cmd_addr[21],sdii_port01_cmd_addr[20],sdii_port01_cmd_addr[19],sdii_port01_cmd_addr[18],sdii_port01_cmd_addr[17],sdii_port01_cmd_addr[16],sdii_port01_cmd_addr[15],sdii_port01_cmd_addr[14],sdii_port01_cmd_addr[13],sdii_port01_cmd_addr[12],sdii_port01_cmd_addr[11],sdii_port01_cmd_addr[10],sdii_port01_cmd_addr[9],sdii_port01_cmd_addr[8],sdii_port01_cmd_addr[7],sdii_port01_cmd_addr[6],sdii_port01_cmd_addr[5],sdii_port01_cmd_addr[4],sdii_port01_cmd_addr[3],sdii_port01_cmd_addr[2],sdii_port01_cmd_addr[1],sdii_port01_cmd_addr[0],sdii_port01_cmd_len[5],sdii_port01_cmd_len[4],sdii_port01_cmd_len[3],sdii_port01_cmd_len[2],sdii_port01_cmd_len[1],sdii_port01_cmd_len[0],sdii_port01_cmd_partial_wrt,sdii_port01_cmd_req,sdii_port01_cmd_rw,sdii_port01_wdata[127],sdii_port01_wdata[126],sdii_port01_wdata[125],sdii_port01_wdata[124],sdii_port01_wdata[123],sdii_port01_wdata[122],sdii_port01_wdata[121],sdii_port01_wdata[120],sdii_port01_wdata[119],sdii_port01_wdata[118],sdii_port01_wdata[117],sdii_port01_wdata[116],sdii_port01_wdata[115],sdii_port01_wdata[114],sdii_port01_wdata[113],sdii_port01_wdata[112],sdii_port01_wdata[111],sdii_port01_wdata[110],sdii_port01_wdata[109],sdii_port01_wdata[108],sdii_port01_wdata[107],sdii_port01_wdata[106],sdii_port01_wdata[105],sdii_port01_wdata[104],sdii_port01_wdata[103],sdii_port01_wdata[102],sdii_port01_wdata[101],sdii_port01_wdata[100],sdii_port01_wdata[99],sdii_port01_wdata[98],sdii_port01_wdata[97],sdii_port01_wdata[96],sdii_port01_wdata[95],sdii_port01_wdata[94],sdii_port01_wdata[93],sdii_port01_wdata[92],sdii_port01_wdata[91],sdii_port01_wdata[90],sdii_port01_wdata[89],sdii_port01_wdata[88],sdii_port01_wdata[87],sdii_port01_wdata[86],sdii_port01_wdata[85],sdii_port01_wdata[84],sdii_port01_wdata[83],sdii_port01_wdata[82],sdii_port01_wdata[81],sdii_port01_wdata[80],sdii_port01_wdata[79],sdii_port01_wdata[78],sdii_port01_wdata[77],sdii_port01_wdata[76],sdii_port01_wdata[75],sdii_port01_wdata[74],sdii_port01_wdata[73],sdii_port01_wdata[72],sdii_port01_wdata[71],sdii_port01_wdata[70],sdii_port01_wdata[69],sdii_port01_wdata[68],sdii_port01_wdata[67],sdii_port01_wdata[66],sdii_port01_wdata[65],sdii_port01_wdata[64],sdii_port01_wdata[63],sdii_port01_wdata[62],sdii_port01_wdata[61],sdii_port01_wdata[60],sdii_port01_wdata[59],sdii_port01_wdata[58],sdii_port01_wdata[57],sdii_port01_wdata[56],sdii_port01_wdata[55],sdii_port01_wdata[54],sdii_port01_wdata[53],sdii_port01_wdata[52],sdii_port01_wdata[51],sdii_port01_wdata[50],sdii_port01_wdata[49],sdii_port01_wdata[48],sdii_port01_wdata[47],sdii_port01_wdata[46],sdii_port01_wdata[45],sdii_port01_wdata[44],sdii_port01_wdata[43],sdii_port01_wdata[42],sdii_port01_wdata[41],sdii_port01_wdata[40],sdii_port01_wdata[39],sdii_port01_wdata[38],sdii_port01_wdata[37],sdii_port01_wdata[36],sdii_port01_wdata[35],sdii_port01_wdata[34],sdii_port01_wdata[33],sdii_port01_wdata[32],sdii_port01_wdata[31],sdii_port01_wdata[30],sdii_port01_wdata[29],sdii_port01_wdata[28],sdii_port01_wdata[27],sdii_port01_wdata[26],sdii_port01_wdata[25],sdii_port01_wdata[24],sdii_port01_wdata[23],sdii_port01_wdata[22],sdii_port01_wdata[21],sdii_port01_wdata[20],sdii_port01_wdata[19],sdii_port01_wdata[18],sdii_port01_wdata[17],sdii_port01_wdata[16],sdii_port01_wdata[15],sdii_port01_wdata[14],sdii_port01_wdata[13],sdii_port01_wdata[12],sdii_port01_wdata[11],sdii_port01_wdata[10],sdii_port01_wdata[9],sdii_port01_wdata[8],sdii_port01_wdata[7],sdii_port01_wdata[6],sdii_port01_wdata[5],sdii_port01_wdata[4],sdii_port01_wdata[3],sdii_port01_wdata[2],sdii_port01_wdata[1],sdii_port01_wdata[0],sdii_port01_wmask[15],sdii_port01_wmask[14],sdii_port01_wmask[13],sdii_port01_wmask[12],sdii_port01_wmask[11],sdii_port01_wmask[10],sdii_port01_wmask[9],sdii_port01_wmask[8],sdii_port01_wmask[7],sdii_port01_wmask[6],sdii_port01_wmask[5],sdii_port01_wmask[4],sdii_port01_wmask[3],sdii_port01_wmask[2],sdii_port01_wmask[1],sdii_port01_wmask[0]})
            ,.s (cfg_mc_bus_sel)
            ,.o (i_p0[279:0])
        );
 //	wire [279:0] i_p1;

 common_2i1 #(280) u_p1_i_1o2(
            .i0 ({axi_port02_araddr[31],axi_port02_araddr[30],axi_port02_araddr[29],axi_port02_araddr[28],axi_port02_araddr[27],axi_port02_araddr[26],axi_port02_araddr[25],axi_port02_araddr[24],axi_port02_araddr[23],axi_port02_araddr[22],axi_port02_araddr[21],axi_port02_araddr[20],axi_port02_araddr[19],axi_port02_araddr[18],axi_port02_araddr[17],axi_port02_araddr[16],axi_port02_araddr[15],axi_port02_araddr[14],axi_port02_araddr[13],axi_port02_araddr[12],axi_port02_araddr[11],axi_port02_araddr[10],axi_port02_araddr[9],axi_port02_araddr[8],axi_port02_araddr[7],axi_port02_araddr[6],axi_port02_araddr[5],axi_port02_araddr[4],axi_port02_araddr[3],axi_port02_araddr[2],axi_port02_araddr[1],axi_port02_araddr[0],axi_port02_arburst[1],axi_port02_arburst[0],axi_port02_arid[15],axi_port02_arid[14],axi_port02_arid[13],axi_port02_arid[12],axi_port02_arid[11],axi_port02_arid[10],axi_port02_arid[9],axi_port02_arid[8],axi_port02_arid[7],axi_port02_arid[6],axi_port02_arid[5],axi_port02_arid[4],axi_port02_arid[3],axi_port02_arid[2],axi_port02_arid[1],axi_port02_arid[0],axi_port02_arlen[3],axi_port02_arlen[2],axi_port02_arlen[1],axi_port02_arlen[0],axi_port02_arsize[2],axi_port02_arsize[1],axi_port02_arsize[0],axi_port02_arvalid,axi_port02_awaddr[31],axi_port02_awaddr[30],axi_port02_awaddr[29],axi_port02_awaddr[28],axi_port02_awaddr[27],axi_port02_awaddr[26],axi_port02_awaddr[25],axi_port02_awaddr[24],axi_port02_awaddr[23],axi_port02_awaddr[22],axi_port02_awaddr[21],axi_port02_awaddr[20],axi_port02_awaddr[19],axi_port02_awaddr[18],axi_port02_awaddr[17],axi_port02_awaddr[16],axi_port02_awaddr[15],axi_port02_awaddr[14],axi_port02_awaddr[13],axi_port02_awaddr[12],axi_port02_awaddr[11],axi_port02_awaddr[10],axi_port02_awaddr[9],axi_port02_awaddr[8],axi_port02_awaddr[7],axi_port02_awaddr[6],axi_port02_awaddr[5],axi_port02_awaddr[4],axi_port02_awaddr[3],axi_port02_awaddr[2],axi_port02_awaddr[1],axi_port02_awaddr[0],axi_port02_awburst[1],axi_port02_awburst[0],axi_port02_awid[15],axi_port02_awid[14],axi_port02_awid[13],axi_port02_awid[12],axi_port02_awid[11],axi_port02_awid[10],axi_port02_awid[9],axi_port02_awid[8],axi_port02_awid[7],axi_port02_awid[6],axi_port02_awid[5],axi_port02_awid[4],axi_port02_awid[3],axi_port02_awid[2],axi_port02_awid[1],axi_port02_awid[0],axi_port02_awlen[3],axi_port02_awlen[2],axi_port02_awlen[1],axi_port02_awlen[0],axi_port02_awsize[2],axi_port02_awsize[1],axi_port02_awsize[0],axi_port02_awvalid,axi_port02_bready,axi_port02_rready,axi_port02_wdata[127],axi_port02_wdata[126],axi_port02_wdata[125],axi_port02_wdata[124],axi_port02_wdata[123],axi_port02_wdata[122],axi_port02_wdata[121],axi_port02_wdata[120],axi_port02_wdata[119],axi_port02_wdata[118],axi_port02_wdata[117],axi_port02_wdata[116],axi_port02_wdata[115],axi_port02_wdata[114],axi_port02_wdata[113],axi_port02_wdata[112],axi_port02_wdata[111],axi_port02_wdata[110],axi_port02_wdata[109],axi_port02_wdata[108],axi_port02_wdata[107],axi_port02_wdata[106],axi_port02_wdata[105],axi_port02_wdata[104],axi_port02_wdata[103],axi_port02_wdata[102],axi_port02_wdata[101],axi_port02_wdata[100],axi_port02_wdata[99],axi_port02_wdata[98],axi_port02_wdata[97],axi_port02_wdata[96],axi_port02_wdata[95],axi_port02_wdata[94],axi_port02_wdata[93],axi_port02_wdata[92],axi_port02_wdata[91],axi_port02_wdata[90],axi_port02_wdata[89],axi_port02_wdata[88],axi_port02_wdata[87],axi_port02_wdata[86],axi_port02_wdata[85],axi_port02_wdata[84],axi_port02_wdata[83],axi_port02_wdata[82],axi_port02_wdata[81],axi_port02_wdata[80],axi_port02_wdata[79],axi_port02_wdata[78],axi_port02_wdata[77],axi_port02_wdata[76],axi_port02_wdata[75],axi_port02_wdata[74],axi_port02_wdata[73],axi_port02_wdata[72],axi_port02_wdata[71],axi_port02_wdata[70],axi_port02_wdata[69],axi_port02_wdata[68],axi_port02_wdata[67],axi_port02_wdata[66],axi_port02_wdata[65],axi_port02_wdata[64],axi_port02_wdata[63],axi_port02_wdata[62],axi_port02_wdata[61],axi_port02_wdata[60],axi_port02_wdata[59],axi_port02_wdata[58],axi_port02_wdata[57],axi_port02_wdata[56],axi_port02_wdata[55],axi_port02_wdata[54],axi_port02_wdata[53],axi_port02_wdata[52],axi_port02_wdata[51],axi_port02_wdata[50],axi_port02_wdata[49],axi_port02_wdata[48],axi_port02_wdata[47],axi_port02_wdata[46],axi_port02_wdata[45],axi_port02_wdata[44],axi_port02_wdata[43],axi_port02_wdata[42],axi_port02_wdata[41],axi_port02_wdata[40],axi_port02_wdata[39],axi_port02_wdata[38],axi_port02_wdata[37],axi_port02_wdata[36],axi_port02_wdata[35],axi_port02_wdata[34],axi_port02_wdata[33],axi_port02_wdata[32],axi_port02_wdata[31],axi_port02_wdata[30],axi_port02_wdata[29],axi_port02_wdata[28],axi_port02_wdata[27],axi_port02_wdata[26],axi_port02_wdata[25],axi_port02_wdata[24],axi_port02_wdata[23],axi_port02_wdata[22],axi_port02_wdata[21],axi_port02_wdata[20],axi_port02_wdata[19],axi_port02_wdata[18],axi_port02_wdata[17],axi_port02_wdata[16],axi_port02_wdata[15],axi_port02_wdata[14],axi_port02_wdata[13],axi_port02_wdata[12],axi_port02_wdata[11],axi_port02_wdata[10],axi_port02_wdata[9],axi_port02_wdata[8],axi_port02_wdata[7],axi_port02_wdata[6],axi_port02_wdata[5],axi_port02_wdata[4],axi_port02_wdata[3],axi_port02_wdata[2],axi_port02_wdata[1],axi_port02_wdata[0],axi_port02_wid[15],axi_port02_wid[14],axi_port02_wid[13],axi_port02_wid[12],axi_port02_wid[11],axi_port02_wid[10],axi_port02_wid[9],axi_port02_wid[8],axi_port02_wid[7],axi_port02_wid[6],axi_port02_wid[5],axi_port02_wid[4],axi_port02_wid[3],axi_port02_wid[2],axi_port02_wid[1],axi_port02_wid[0],axi_port02_wlast,axi_port02_wstrb[15],axi_port02_wstrb[14],axi_port02_wstrb[13],axi_port02_wstrb[12],axi_port02_wstrb[11],axi_port02_wstrb[10],axi_port02_wstrb[9],axi_port02_wstrb[8],axi_port02_wstrb[7],axi_port02_wstrb[6],axi_port02_wstrb[5],axi_port02_wstrb[4],axi_port02_wstrb[3],axi_port02_wstrb[2],axi_port02_wstrb[1],axi_port02_wstrb[0],axi_port02_wvalid})
            ,.i1({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,sdii_port03_cmd_addr[31],sdii_port03_cmd_addr[30],sdii_port03_cmd_addr[29],sdii_port03_cmd_addr[28],sdii_port03_cmd_addr[27],sdii_port03_cmd_addr[26],sdii_port03_cmd_addr[25],sdii_port03_cmd_addr[24],sdii_port03_cmd_addr[23],sdii_port03_cmd_addr[22],sdii_port03_cmd_addr[21],sdii_port03_cmd_addr[20],sdii_port03_cmd_addr[19],sdii_port03_cmd_addr[18],sdii_port03_cmd_addr[17],sdii_port03_cmd_addr[16],sdii_port03_cmd_addr[15],sdii_port03_cmd_addr[14],sdii_port03_cmd_addr[13],sdii_port03_cmd_addr[12],sdii_port03_cmd_addr[11],sdii_port03_cmd_addr[10],sdii_port03_cmd_addr[9],sdii_port03_cmd_addr[8],sdii_port03_cmd_addr[7],sdii_port03_cmd_addr[6],sdii_port03_cmd_addr[5],sdii_port03_cmd_addr[4],sdii_port03_cmd_addr[3],sdii_port03_cmd_addr[2],sdii_port03_cmd_addr[1],sdii_port03_cmd_addr[0],sdii_port03_cmd_len[5],sdii_port03_cmd_len[4],sdii_port03_cmd_len[3],sdii_port03_cmd_len[2],sdii_port03_cmd_len[1],sdii_port03_cmd_len[0],sdii_port03_cmd_partial_wrt,sdii_port03_cmd_req,sdii_port03_cmd_rw,sdii_port03_wdata[127],sdii_port03_wdata[126],sdii_port03_wdata[125],sdii_port03_wdata[124],sdii_port03_wdata[123],sdii_port03_wdata[122],sdii_port03_wdata[121],sdii_port03_wdata[120],sdii_port03_wdata[119],sdii_port03_wdata[118],sdii_port03_wdata[117],sdii_port03_wdata[116],sdii_port03_wdata[115],sdii_port03_wdata[114],sdii_port03_wdata[113],sdii_port03_wdata[112],sdii_port03_wdata[111],sdii_port03_wdata[110],sdii_port03_wdata[109],sdii_port03_wdata[108],sdii_port03_wdata[107],sdii_port03_wdata[106],sdii_port03_wdata[105],sdii_port03_wdata[104],sdii_port03_wdata[103],sdii_port03_wdata[102],sdii_port03_wdata[101],sdii_port03_wdata[100],sdii_port03_wdata[99],sdii_port03_wdata[98],sdii_port03_wdata[97],sdii_port03_wdata[96],sdii_port03_wdata[95],sdii_port03_wdata[94],sdii_port03_wdata[93],sdii_port03_wdata[92],sdii_port03_wdata[91],sdii_port03_wdata[90],sdii_port03_wdata[89],sdii_port03_wdata[88],sdii_port03_wdata[87],sdii_port03_wdata[86],sdii_port03_wdata[85],sdii_port03_wdata[84],sdii_port03_wdata[83],sdii_port03_wdata[82],sdii_port03_wdata[81],sdii_port03_wdata[80],sdii_port03_wdata[79],sdii_port03_wdata[78],sdii_port03_wdata[77],sdii_port03_wdata[76],sdii_port03_wdata[75],sdii_port03_wdata[74],sdii_port03_wdata[73],sdii_port03_wdata[72],sdii_port03_wdata[71],sdii_port03_wdata[70],sdii_port03_wdata[69],sdii_port03_wdata[68],sdii_port03_wdata[67],sdii_port03_wdata[66],sdii_port03_wdata[65],sdii_port03_wdata[64],sdii_port03_wdata[63],sdii_port03_wdata[62],sdii_port03_wdata[61],sdii_port03_wdata[60],sdii_port03_wdata[59],sdii_port03_wdata[58],sdii_port03_wdata[57],sdii_port03_wdata[56],sdii_port03_wdata[55],sdii_port03_wdata[54],sdii_port03_wdata[53],sdii_port03_wdata[52],sdii_port03_wdata[51],sdii_port03_wdata[50],sdii_port03_wdata[49],sdii_port03_wdata[48],sdii_port03_wdata[47],sdii_port03_wdata[46],sdii_port03_wdata[45],sdii_port03_wdata[44],sdii_port03_wdata[43],sdii_port03_wdata[42],sdii_port03_wdata[41],sdii_port03_wdata[40],sdii_port03_wdata[39],sdii_port03_wdata[38],sdii_port03_wdata[37],sdii_port03_wdata[36],sdii_port03_wdata[35],sdii_port03_wdata[34],sdii_port03_wdata[33],sdii_port03_wdata[32],sdii_port03_wdata[31],sdii_port03_wdata[30],sdii_port03_wdata[29],sdii_port03_wdata[28],sdii_port03_wdata[27],sdii_port03_wdata[26],sdii_port03_wdata[25],sdii_port03_wdata[24],sdii_port03_wdata[23],sdii_port03_wdata[22],sdii_port03_wdata[21],sdii_port03_wdata[20],sdii_port03_wdata[19],sdii_port03_wdata[18],sdii_port03_wdata[17],sdii_port03_wdata[16],sdii_port03_wdata[15],sdii_port03_wdata[14],sdii_port03_wdata[13],sdii_port03_wdata[12],sdii_port03_wdata[11],sdii_port03_wdata[10],sdii_port03_wdata[9],sdii_port03_wdata[8],sdii_port03_wdata[7],sdii_port03_wdata[6],sdii_port03_wdata[5],sdii_port03_wdata[4],sdii_port03_wdata[3],sdii_port03_wdata[2],sdii_port03_wdata[1],sdii_port03_wdata[0],sdii_port03_wmask[15],sdii_port03_wmask[14],sdii_port03_wmask[13],sdii_port03_wmask[12],sdii_port03_wmask[11],sdii_port03_wmask[10],sdii_port03_wmask[9],sdii_port03_wmask[8],sdii_port03_wmask[7],sdii_port03_wmask[6],sdii_port03_wmask[5],sdii_port03_wmask[4],sdii_port03_wmask[3],sdii_port03_wmask[2],sdii_port03_wmask[1],sdii_port03_wmask[0]})
            ,.s (cfg_mc_bus_sel)
            ,.o (i_p1[279:0])
        );
        //	wire [169:0] o_p0;
	wire NC_u_p0_o_2i1_0;	wire NC_u_p0_o_2i1_1;	wire NC_u_p0_o_2i1_2;	wire NC_u_p0_o_2i1_3;	wire NC_u_p0_o_2i1_4;	wire NC_u_p0_o_2i1_5;	wire NC_u_p0_o_2i1_6;	wire NC_u_p0_o_2i1_7;	wire NC_u_p0_o_2i1_8;	wire NC_u_p0_o_2i1_9;	wire NC_u_p0_o_2i1_10;	wire NC_u_p0_o_2i1_11;	wire NC_u_p0_o_2i1_12;	wire NC_u_p0_o_2i1_13;	wire NC_u_p0_o_2i1_14;	wire NC_u_p0_o_2i1_15;	wire NC_u_p0_o_2i1_16;	wire NC_u_p0_o_2i1_17;	wire NC_u_p0_o_2i1_18;	wire NC_u_p0_o_2i1_19;	wire NC_u_p0_o_2i1_20;	wire NC_u_p0_o_2i1_21;	wire NC_u_p0_o_2i1_22;	wire NC_u_p0_o_2i1_23;	wire NC_u_p0_o_2i1_24;	wire NC_u_p0_o_2i1_25;	wire NC_u_p0_o_2i1_26;	wire NC_u_p0_o_2i1_27;	wire NC_u_p0_o_2i1_28;	wire NC_u_p0_o_2i1_29;	wire NC_u_p0_o_2i1_30;	wire NC_u_p0_o_2i1_31;	wire NC_u_p0_o_2i1_32;	wire NC_u_p0_o_2i1_33;	wire NC_u_p0_o_2i1_34;	wire NC_u_p0_o_2i1_35;	wire NC_u_p0_o_2i1_36;	wire NC_u_p0_o_2i1_37;	wire NC_u_p0_o_2i1_38;
        common_1o2 #(170) u_p0_o_2i1(
            .o0 ({axi_port00_arready,axi_port00_awready,axi_port00_bid[15],axi_port00_bid[14],axi_port00_bid[13],axi_port00_bid[12],axi_port00_bid[11],axi_port00_bid[10],axi_port00_bid[9],axi_port00_bid[8],axi_port00_bid[7],axi_port00_bid[6],axi_port00_bid[5],axi_port00_bid[4],axi_port00_bid[3],axi_port00_bid[2],axi_port00_bid[1],axi_port00_bid[0],axi_port00_bresp[1],axi_port00_bresp[0],axi_port00_bvalid,axi_port00_rdata[127],axi_port00_rdata[126],axi_port00_rdata[125],axi_port00_rdata[124],axi_port00_rdata[123],axi_port00_rdata[122],axi_port00_rdata[121],axi_port00_rdata[120],axi_port00_rdata[119],axi_port00_rdata[118],axi_port00_rdata[117],axi_port00_rdata[116],axi_port00_rdata[115],axi_port00_rdata[114],axi_port00_rdata[113],axi_port00_rdata[112],axi_port00_rdata[111],axi_port00_rdata[110],axi_port00_rdata[109],axi_port00_rdata[108],axi_port00_rdata[107],axi_port00_rdata[106],axi_port00_rdata[105],axi_port00_rdata[104],axi_port00_rdata[103],axi_port00_rdata[102],axi_port00_rdata[101],axi_port00_rdata[100],axi_port00_rdata[99],axi_port00_rdata[98],axi_port00_rdata[97],axi_port00_rdata[96],axi_port00_rdata[95],axi_port00_rdata[94],axi_port00_rdata[93],axi_port00_rdata[92],axi_port00_rdata[91],axi_port00_rdata[90],axi_port00_rdata[89],axi_port00_rdata[88],axi_port00_rdata[87],axi_port00_rdata[86],axi_port00_rdata[85],axi_port00_rdata[84],axi_port00_rdata[83],axi_port00_rdata[82],axi_port00_rdata[81],axi_port00_rdata[80],axi_port00_rdata[79],axi_port00_rdata[78],axi_port00_rdata[77],axi_port00_rdata[76],axi_port00_rdata[75],axi_port00_rdata[74],axi_port00_rdata[73],axi_port00_rdata[72],axi_port00_rdata[71],axi_port00_rdata[70],axi_port00_rdata[69],axi_port00_rdata[68],axi_port00_rdata[67],axi_port00_rdata[66],axi_port00_rdata[65],axi_port00_rdata[64],axi_port00_rdata[63],axi_port00_rdata[62],axi_port00_rdata[61],axi_port00_rdata[60],axi_port00_rdata[59],axi_port00_rdata[58],axi_port00_rdata[57],axi_port00_rdata[56],axi_port00_rdata[55],axi_port00_rdata[54],axi_port00_rdata[53],axi_port00_rdata[52],axi_port00_rdata[51],axi_port00_rdata[50],axi_port00_rdata[49],axi_port00_rdata[48],axi_port00_rdata[47],axi_port00_rdata[46],axi_port00_rdata[45],axi_port00_rdata[44],axi_port00_rdata[43],axi_port00_rdata[42],axi_port00_rdata[41],axi_port00_rdata[40],axi_port00_rdata[39],axi_port00_rdata[38],axi_port00_rdata[37],axi_port00_rdata[36],axi_port00_rdata[35],axi_port00_rdata[34],axi_port00_rdata[33],axi_port00_rdata[32],axi_port00_rdata[31],axi_port00_rdata[30],axi_port00_rdata[29],axi_port00_rdata[28],axi_port00_rdata[27],axi_port00_rdata[26],axi_port00_rdata[25],axi_port00_rdata[24],axi_port00_rdata[23],axi_port00_rdata[22],axi_port00_rdata[21],axi_port00_rdata[20],axi_port00_rdata[19],axi_port00_rdata[18],axi_port00_rdata[17],axi_port00_rdata[16],axi_port00_rdata[15],axi_port00_rdata[14],axi_port00_rdata[13],axi_port00_rdata[12],axi_port00_rdata[11],axi_port00_rdata[10],axi_port00_rdata[9],axi_port00_rdata[8],axi_port00_rdata[7],axi_port00_rdata[6],axi_port00_rdata[5],axi_port00_rdata[4],axi_port00_rdata[3],axi_port00_rdata[2],axi_port00_rdata[1],axi_port00_rdata[0],axi_port00_rid[15],axi_port00_rid[14],axi_port00_rid[13],axi_port00_rid[12],axi_port00_rid[11],axi_port00_rid[10],axi_port00_rid[9],axi_port00_rid[8],axi_port00_rid[7],axi_port00_rid[6],axi_port00_rid[5],axi_port00_rid[4],axi_port00_rid[3],axi_port00_rid[2],axi_port00_rid[1],axi_port00_rid[0],axi_port00_rlast,axi_port00_rresp[1],axi_port00_rresp[0],axi_port00_rvalid,axi_port00_wready})
            ,.o1({NC_u_p0_o_2i1_0,NC_u_p0_o_2i1_1,NC_u_p0_o_2i1_2,NC_u_p0_o_2i1_3,NC_u_p0_o_2i1_4,NC_u_p0_o_2i1_5,NC_u_p0_o_2i1_6,NC_u_p0_o_2i1_7,NC_u_p0_o_2i1_8,NC_u_p0_o_2i1_9,NC_u_p0_o_2i1_10,NC_u_p0_o_2i1_11,NC_u_p0_o_2i1_12,NC_u_p0_o_2i1_13,NC_u_p0_o_2i1_14,NC_u_p0_o_2i1_15,NC_u_p0_o_2i1_16,NC_u_p0_o_2i1_17,NC_u_p0_o_2i1_18,NC_u_p0_o_2i1_19,NC_u_p0_o_2i1_20,NC_u_p0_o_2i1_21,NC_u_p0_o_2i1_22,NC_u_p0_o_2i1_23,NC_u_p0_o_2i1_24,NC_u_p0_o_2i1_25,NC_u_p0_o_2i1_26,NC_u_p0_o_2i1_27,NC_u_p0_o_2i1_28,NC_u_p0_o_2i1_29,NC_u_p0_o_2i1_30,NC_u_p0_o_2i1_31,NC_u_p0_o_2i1_32,NC_u_p0_o_2i1_33,NC_u_p0_o_2i1_34,NC_u_p0_o_2i1_35,NC_u_p0_o_2i1_36,NC_u_p0_o_2i1_37,NC_u_p0_o_2i1_38,sdii_port01_cmd_gnt,sdii_port01_rdata[127],sdii_port01_rdata[126],sdii_port01_rdata[125],sdii_port01_rdata[124],sdii_port01_rdata[123],sdii_port01_rdata[122],sdii_port01_rdata[121],sdii_port01_rdata[120],sdii_port01_rdata[119],sdii_port01_rdata[118],sdii_port01_rdata[117],sdii_port01_rdata[116],sdii_port01_rdata[115],sdii_port01_rdata[114],sdii_port01_rdata[113],sdii_port01_rdata[112],sdii_port01_rdata[111],sdii_port01_rdata[110],sdii_port01_rdata[109],sdii_port01_rdata[108],sdii_port01_rdata[107],sdii_port01_rdata[106],sdii_port01_rdata[105],sdii_port01_rdata[104],sdii_port01_rdata[103],sdii_port01_rdata[102],sdii_port01_rdata[101],sdii_port01_rdata[100],sdii_port01_rdata[99],sdii_port01_rdata[98],sdii_port01_rdata[97],sdii_port01_rdata[96],sdii_port01_rdata[95],sdii_port01_rdata[94],sdii_port01_rdata[93],sdii_port01_rdata[92],sdii_port01_rdata[91],sdii_port01_rdata[90],sdii_port01_rdata[89],sdii_port01_rdata[88],sdii_port01_rdata[87],sdii_port01_rdata[86],sdii_port01_rdata[85],sdii_port01_rdata[84],sdii_port01_rdata[83],sdii_port01_rdata[82],sdii_port01_rdata[81],sdii_port01_rdata[80],sdii_port01_rdata[79],sdii_port01_rdata[78],sdii_port01_rdata[77],sdii_port01_rdata[76],sdii_port01_rdata[75],sdii_port01_rdata[74],sdii_port01_rdata[73],sdii_port01_rdata[72],sdii_port01_rdata[71],sdii_port01_rdata[70],sdii_port01_rdata[69],sdii_port01_rdata[68],sdii_port01_rdata[67],sdii_port01_rdata[66],sdii_port01_rdata[65],sdii_port01_rdata[64],sdii_port01_rdata[63],sdii_port01_rdata[62],sdii_port01_rdata[61],sdii_port01_rdata[60],sdii_port01_rdata[59],sdii_port01_rdata[58],sdii_port01_rdata[57],sdii_port01_rdata[56],sdii_port01_rdata[55],sdii_port01_rdata[54],sdii_port01_rdata[53],sdii_port01_rdata[52],sdii_port01_rdata[51],sdii_port01_rdata[50],sdii_port01_rdata[49],sdii_port01_rdata[48],sdii_port01_rdata[47],sdii_port01_rdata[46],sdii_port01_rdata[45],sdii_port01_rdata[44],sdii_port01_rdata[43],sdii_port01_rdata[42],sdii_port01_rdata[41],sdii_port01_rdata[40],sdii_port01_rdata[39],sdii_port01_rdata[38],sdii_port01_rdata[37],sdii_port01_rdata[36],sdii_port01_rdata[35],sdii_port01_rdata[34],sdii_port01_rdata[33],sdii_port01_rdata[32],sdii_port01_rdata[31],sdii_port01_rdata[30],sdii_port01_rdata[29],sdii_port01_rdata[28],sdii_port01_rdata[27],sdii_port01_rdata[26],sdii_port01_rdata[25],sdii_port01_rdata[24],sdii_port01_rdata[23],sdii_port01_rdata[22],sdii_port01_rdata[21],sdii_port01_rdata[20],sdii_port01_rdata[19],sdii_port01_rdata[18],sdii_port01_rdata[17],sdii_port01_rdata[16],sdii_port01_rdata[15],sdii_port01_rdata[14],sdii_port01_rdata[13],sdii_port01_rdata[12],sdii_port01_rdata[11],sdii_port01_rdata[10],sdii_port01_rdata[9],sdii_port01_rdata[8],sdii_port01_rdata[7],sdii_port01_rdata[6],sdii_port01_rdata[5],sdii_port01_rdata[4],sdii_port01_rdata[3],sdii_port01_rdata[2],sdii_port01_rdata[1],sdii_port01_rdata[0],sdii_port01_rdata_psh,sdii_port01_wdata_pop})
            ,.i (o_p0[169:0])
        );
        //	wire [169:0] o_p1;
	wire NC_u_p1_o_2i1_0;	wire NC_u_p1_o_2i1_1;	wire NC_u_p1_o_2i1_2;	wire NC_u_p1_o_2i1_3;	wire NC_u_p1_o_2i1_4;	wire NC_u_p1_o_2i1_5;	wire NC_u_p1_o_2i1_6;	wire NC_u_p1_o_2i1_7;	wire NC_u_p1_o_2i1_8;	wire NC_u_p1_o_2i1_9;	wire NC_u_p1_o_2i1_10;	wire NC_u_p1_o_2i1_11;	wire NC_u_p1_o_2i1_12;	wire NC_u_p1_o_2i1_13;	wire NC_u_p1_o_2i1_14;	wire NC_u_p1_o_2i1_15;	wire NC_u_p1_o_2i1_16;	wire NC_u_p1_o_2i1_17;	wire NC_u_p1_o_2i1_18;	wire NC_u_p1_o_2i1_19;	wire NC_u_p1_o_2i1_20;	wire NC_u_p1_o_2i1_21;	wire NC_u_p1_o_2i1_22;	wire NC_u_p1_o_2i1_23;	wire NC_u_p1_o_2i1_24;	wire NC_u_p1_o_2i1_25;	wire NC_u_p1_o_2i1_26;	wire NC_u_p1_o_2i1_27;	wire NC_u_p1_o_2i1_28;	wire NC_u_p1_o_2i1_29;	wire NC_u_p1_o_2i1_30;	wire NC_u_p1_o_2i1_31;	wire NC_u_p1_o_2i1_32;	wire NC_u_p1_o_2i1_33;	wire NC_u_p1_o_2i1_34;	wire NC_u_p1_o_2i1_35;	wire NC_u_p1_o_2i1_36;	wire NC_u_p1_o_2i1_37;	wire NC_u_p1_o_2i1_38;
        common_1o2 #(170) u_p1_o_2i1(
            .o0 ({axi_port02_arready,axi_port02_awready,axi_port02_bid[15],axi_port02_bid[14],axi_port02_bid[13],axi_port02_bid[12],axi_port02_bid[11],axi_port02_bid[10],axi_port02_bid[9],axi_port02_bid[8],axi_port02_bid[7],axi_port02_bid[6],axi_port02_bid[5],axi_port02_bid[4],axi_port02_bid[3],axi_port02_bid[2],axi_port02_bid[1],axi_port02_bid[0],axi_port02_bresp[1],axi_port02_bresp[0],axi_port02_bvalid,axi_port02_rdata[127],axi_port02_rdata[126],axi_port02_rdata[125],axi_port02_rdata[124],axi_port02_rdata[123],axi_port02_rdata[122],axi_port02_rdata[121],axi_port02_rdata[120],axi_port02_rdata[119],axi_port02_rdata[118],axi_port02_rdata[117],axi_port02_rdata[116],axi_port02_rdata[115],axi_port02_rdata[114],axi_port02_rdata[113],axi_port02_rdata[112],axi_port02_rdata[111],axi_port02_rdata[110],axi_port02_rdata[109],axi_port02_rdata[108],axi_port02_rdata[107],axi_port02_rdata[106],axi_port02_rdata[105],axi_port02_rdata[104],axi_port02_rdata[103],axi_port02_rdata[102],axi_port02_rdata[101],axi_port02_rdata[100],axi_port02_rdata[99],axi_port02_rdata[98],axi_port02_rdata[97],axi_port02_rdata[96],axi_port02_rdata[95],axi_port02_rdata[94],axi_port02_rdata[93],axi_port02_rdata[92],axi_port02_rdata[91],axi_port02_rdata[90],axi_port02_rdata[89],axi_port02_rdata[88],axi_port02_rdata[87],axi_port02_rdata[86],axi_port02_rdata[85],axi_port02_rdata[84],axi_port02_rdata[83],axi_port02_rdata[82],axi_port02_rdata[81],axi_port02_rdata[80],axi_port02_rdata[79],axi_port02_rdata[78],axi_port02_rdata[77],axi_port02_rdata[76],axi_port02_rdata[75],axi_port02_rdata[74],axi_port02_rdata[73],axi_port02_rdata[72],axi_port02_rdata[71],axi_port02_rdata[70],axi_port02_rdata[69],axi_port02_rdata[68],axi_port02_rdata[67],axi_port02_rdata[66],axi_port02_rdata[65],axi_port02_rdata[64],axi_port02_rdata[63],axi_port02_rdata[62],axi_port02_rdata[61],axi_port02_rdata[60],axi_port02_rdata[59],axi_port02_rdata[58],axi_port02_rdata[57],axi_port02_rdata[56],axi_port02_rdata[55],axi_port02_rdata[54],axi_port02_rdata[53],axi_port02_rdata[52],axi_port02_rdata[51],axi_port02_rdata[50],axi_port02_rdata[49],axi_port02_rdata[48],axi_port02_rdata[47],axi_port02_rdata[46],axi_port02_rdata[45],axi_port02_rdata[44],axi_port02_rdata[43],axi_port02_rdata[42],axi_port02_rdata[41],axi_port02_rdata[40],axi_port02_rdata[39],axi_port02_rdata[38],axi_port02_rdata[37],axi_port02_rdata[36],axi_port02_rdata[35],axi_port02_rdata[34],axi_port02_rdata[33],axi_port02_rdata[32],axi_port02_rdata[31],axi_port02_rdata[30],axi_port02_rdata[29],axi_port02_rdata[28],axi_port02_rdata[27],axi_port02_rdata[26],axi_port02_rdata[25],axi_port02_rdata[24],axi_port02_rdata[23],axi_port02_rdata[22],axi_port02_rdata[21],axi_port02_rdata[20],axi_port02_rdata[19],axi_port02_rdata[18],axi_port02_rdata[17],axi_port02_rdata[16],axi_port02_rdata[15],axi_port02_rdata[14],axi_port02_rdata[13],axi_port02_rdata[12],axi_port02_rdata[11],axi_port02_rdata[10],axi_port02_rdata[9],axi_port02_rdata[8],axi_port02_rdata[7],axi_port02_rdata[6],axi_port02_rdata[5],axi_port02_rdata[4],axi_port02_rdata[3],axi_port02_rdata[2],axi_port02_rdata[1],axi_port02_rdata[0],axi_port02_rid[15],axi_port02_rid[14],axi_port02_rid[13],axi_port02_rid[12],axi_port02_rid[11],axi_port02_rid[10],axi_port02_rid[9],axi_port02_rid[8],axi_port02_rid[7],axi_port02_rid[6],axi_port02_rid[5],axi_port02_rid[4],axi_port02_rid[3],axi_port02_rid[2],axi_port02_rid[1],axi_port02_rid[0],axi_port02_rlast,axi_port02_rresp[1],axi_port02_rresp[0],axi_port02_rvalid,axi_port02_wready})
            ,.o1({NC_u_p1_o_2i1_0,NC_u_p1_o_2i1_1,NC_u_p1_o_2i1_2,NC_u_p1_o_2i1_3,NC_u_p1_o_2i1_4,NC_u_p1_o_2i1_5,NC_u_p1_o_2i1_6,NC_u_p1_o_2i1_7,NC_u_p1_o_2i1_8,NC_u_p1_o_2i1_9,NC_u_p1_o_2i1_10,NC_u_p1_o_2i1_11,NC_u_p1_o_2i1_12,NC_u_p1_o_2i1_13,NC_u_p1_o_2i1_14,NC_u_p1_o_2i1_15,NC_u_p1_o_2i1_16,NC_u_p1_o_2i1_17,NC_u_p1_o_2i1_18,NC_u_p1_o_2i1_19,NC_u_p1_o_2i1_20,NC_u_p1_o_2i1_21,NC_u_p1_o_2i1_22,NC_u_p1_o_2i1_23,NC_u_p1_o_2i1_24,NC_u_p1_o_2i1_25,NC_u_p1_o_2i1_26,NC_u_p1_o_2i1_27,NC_u_p1_o_2i1_28,NC_u_p1_o_2i1_29,NC_u_p1_o_2i1_30,NC_u_p1_o_2i1_31,NC_u_p1_o_2i1_32,NC_u_p1_o_2i1_33,NC_u_p1_o_2i1_34,NC_u_p1_o_2i1_35,NC_u_p1_o_2i1_36,NC_u_p1_o_2i1_37,NC_u_p1_o_2i1_38,sdii_port03_cmd_gnt,sdii_port03_rdata[127],sdii_port03_rdata[126],sdii_port03_rdata[125],sdii_port03_rdata[124],sdii_port03_rdata[123],sdii_port03_rdata[122],sdii_port03_rdata[121],sdii_port03_rdata[120],sdii_port03_rdata[119],sdii_port03_rdata[118],sdii_port03_rdata[117],sdii_port03_rdata[116],sdii_port03_rdata[115],sdii_port03_rdata[114],sdii_port03_rdata[113],sdii_port03_rdata[112],sdii_port03_rdata[111],sdii_port03_rdata[110],sdii_port03_rdata[109],sdii_port03_rdata[108],sdii_port03_rdata[107],sdii_port03_rdata[106],sdii_port03_rdata[105],sdii_port03_rdata[104],sdii_port03_rdata[103],sdii_port03_rdata[102],sdii_port03_rdata[101],sdii_port03_rdata[100],sdii_port03_rdata[99],sdii_port03_rdata[98],sdii_port03_rdata[97],sdii_port03_rdata[96],sdii_port03_rdata[95],sdii_port03_rdata[94],sdii_port03_rdata[93],sdii_port03_rdata[92],sdii_port03_rdata[91],sdii_port03_rdata[90],sdii_port03_rdata[89],sdii_port03_rdata[88],sdii_port03_rdata[87],sdii_port03_rdata[86],sdii_port03_rdata[85],sdii_port03_rdata[84],sdii_port03_rdata[83],sdii_port03_rdata[82],sdii_port03_rdata[81],sdii_port03_rdata[80],sdii_port03_rdata[79],sdii_port03_rdata[78],sdii_port03_rdata[77],sdii_port03_rdata[76],sdii_port03_rdata[75],sdii_port03_rdata[74],sdii_port03_rdata[73],sdii_port03_rdata[72],sdii_port03_rdata[71],sdii_port03_rdata[70],sdii_port03_rdata[69],sdii_port03_rdata[68],sdii_port03_rdata[67],sdii_port03_rdata[66],sdii_port03_rdata[65],sdii_port03_rdata[64],sdii_port03_rdata[63],sdii_port03_rdata[62],sdii_port03_rdata[61],sdii_port03_rdata[60],sdii_port03_rdata[59],sdii_port03_rdata[58],sdii_port03_rdata[57],sdii_port03_rdata[56],sdii_port03_rdata[55],sdii_port03_rdata[54],sdii_port03_rdata[53],sdii_port03_rdata[52],sdii_port03_rdata[51],sdii_port03_rdata[50],sdii_port03_rdata[49],sdii_port03_rdata[48],sdii_port03_rdata[47],sdii_port03_rdata[46],sdii_port03_rdata[45],sdii_port03_rdata[44],sdii_port03_rdata[43],sdii_port03_rdata[42],sdii_port03_rdata[41],sdii_port03_rdata[40],sdii_port03_rdata[39],sdii_port03_rdata[38],sdii_port03_rdata[37],sdii_port03_rdata[36],sdii_port03_rdata[35],sdii_port03_rdata[34],sdii_port03_rdata[33],sdii_port03_rdata[32],sdii_port03_rdata[31],sdii_port03_rdata[30],sdii_port03_rdata[29],sdii_port03_rdata[28],sdii_port03_rdata[27],sdii_port03_rdata[26],sdii_port03_rdata[25],sdii_port03_rdata[24],sdii_port03_rdata[23],sdii_port03_rdata[22],sdii_port03_rdata[21],sdii_port03_rdata[20],sdii_port03_rdata[19],sdii_port03_rdata[18],sdii_port03_rdata[17],sdii_port03_rdata[16],sdii_port03_rdata[15],sdii_port03_rdata[14],sdii_port03_rdata[13],sdii_port03_rdata[12],sdii_port03_rdata[11],sdii_port03_rdata[10],sdii_port03_rdata[9],sdii_port03_rdata[8],sdii_port03_rdata[7],sdii_port03_rdata[6],sdii_port03_rdata[5],sdii_port03_rdata[4],sdii_port03_rdata[3],sdii_port03_rdata[2],sdii_port03_rdata[1],sdii_port03_rdata[0],sdii_port03_rdata_psh,sdii_port03_wdata_pop})
            ,.i (o_p1[169:0])
        );

endmodule


