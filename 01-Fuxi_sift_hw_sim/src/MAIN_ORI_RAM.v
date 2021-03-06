//
// This is a file generated by EMB wizard.
// Please do not edit this file!
// Generated time: 06/13/2022 19:32:55
// Version: Fuxi fx2020a win64
// Wizard name: EMB 1.0b
//
// ============================================================
// File Name: MAIN_ORI_RAM.v
// IP core : emb
// Device name: P1P060N0V324C7
// ============================================================

module MAIN_ORI_RAM (clk, ce, we, rstn, a, d, q);
input clk;
input ce;
input we;
input rstn;
input [9:0]a;
input [5:0]d;
output [5:0]q;

wire vcc_net;
wire gnd_net;
wire net_26;
wire net_27;
wire nc6145;
wire nc6146;
wire nc6147;
wire nc6148;
wire nc6149;
wire nc6150;
wire nc6151;
wire nc6152;
wire nc6153;
wire nc6154;
wire nc6155;
wire nc6156;
wire nc6157;
wire nc6158;
wire nc6159;
wire nc6160;
wire nc6161;
wire nc6162;
wire nc6163;
wire nc6164;
wire nc6165;
wire nc6166;
wire nc6167;
wire nc6168;
wire nc6169;
wire nc6170;
wire nc6171;
wire nc6172;
wire nc6173;
wire nc6174;
wire nc6175;
wire nc6176;
wire nc6177;
wire nc6178;
wire nc6179;
wire nc6180;
wire nc6181;
wire nc6182;
wire nc6183;
wire nc6184;
wire nc6185;
wire nc6186;
wire nc6187;
wire nc6188;
wire nc6189;
wire nc6190;
wire nc6191;
wire nc6192;
wire nc6193;
wire nc6194;

assign vcc_net = 1;
assign gnd_net = 0;
EMB9K #(
		.clka_inv (1'b0),
		.clkb_inv (1'b0),
		.emb5k_1_init_file (""),
		.emb5k_2_init_file (""),
		.extension_mode ("power"),
		.init_file ("none"),
		.outreg_a (1'b0),
		.outreg_b (1'b0),
		.rammode ("sp"),
		.use_parity (1'b0),
		.width_a (9),
		.width_b (9),
		.writemode_a ("no_change"),
		.writemode_b ("write_first"),
		.byte_write_enable (1'b0)
	)
	emb_0(
		.doa({nc6145, nc6146, nc6147, nc6148, nc6149, nc6150, nc6151, nc6152, nc6153, nc6154, nc6155, nc6156, nc6157, nc6158, nc6159, nc6160, nc6161, nc6162, nc6163, nc6164, nc6165, nc6166, nc6167, nc6168, net_27, net_26, q[5], q[4], q[3], q[2], q[1], q[0]}),
		.dob(),
		.dopa(),
		.dopb(),
		.addra({gnd_net, gnd_net, gnd_net, a[9], a[8], a[7], a[6], a[5], a[4], a[3], a[2], a[1], a[0]}),
		.addrb(),
		.clka(clk),
		.clkb(),
		.dia({nc6169, nc6170, nc6171, nc6172, nc6173, nc6174, nc6175, nc6176, nc6177, nc6178, nc6179, nc6180, nc6181, nc6182, nc6183, nc6184, nc6185, nc6186, nc6187, nc6188, nc6189, nc6190, nc6191, nc6192, nc6193, nc6194, d[5], d[4], d[3], d[2], d[1], d[0]}),
		.dib(),
		.dipa(),
		.dipb(),
		.cea(ce),
		.ceb(gnd_net),
		.regcea(vcc_net),
		.regceb(),
		.regsra(rstn),
		.regsrb(),
		.wea({we, we}),
		.web()
	);
endmodule


// ============================================================
//                  emb Setting
//
// Warning: This part is read by Fuxi, please don't modify it.
// ============================================================
// Device          : P1P060N0V324C7
// Module          : MAIN_ORI_RAM
// IP core         : emb
// IP Version      : 1

// AddrUsedA       : 10
// ByteWriteEn     : false
// DataUsedA       : 6
// DataUsedB       : 6
// EmbResource     : AUTO
// EmbType         : sp
// ErrorInjectMode : None
// InitFile        : 
// RegoutA         : false
// RegoutB         : false
// RegoutEnA       : false
// RegoutEnB       : false
// Simulation Files: 
// SplitEmb        : false
// SplitInfo       : 6,1024;block_0:8,512,0,0,0 1 2 3 4 5 -1 -1;block_1:8,512,0,512,0 1 2 3 4 5 -1 -1
// Synthesis Files : 
// UseEccEn        : false
// WriteModeA      : No Change
// WriteModeB      : Write First
