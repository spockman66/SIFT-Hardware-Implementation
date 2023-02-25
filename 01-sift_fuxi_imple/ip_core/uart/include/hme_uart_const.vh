`ifdef HMEUART_CONST_VH
`else
`define HMEUART_CONST_VH

`define HMEUART_PRODUCT_ID		32'h02011009

`ifdef HMEUART_FIFO_DEPTH_128
	`define HMEUART_FIFO_DEPTH_BIT	7
	`define HMEUART_HWCFG		4'h3
`else
	`ifdef HMEUART_FIFO_DEPTH_64
		`define HMEUART_FIFO_DEPTH_BIT	6
		`define HMEUART_HWCFG		4'h2
	`else
		`ifdef HMEUART_FIFO_DEPTH_32
			`define HMEUART_FIFO_DEPTH_BIT	5
			`define HMEUART_HWCFG		4'h1
		`else
			`define HMEUART_FIFO_DEPTH_BIT	4
			`define HMEUART_HWCFG		4'h0
		`endif
	`endif
`endif

`endif
