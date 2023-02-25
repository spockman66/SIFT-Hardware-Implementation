//================================================================================
// Copyright (c) 2014 Capital-micro, Inc.(Beijing)  All rights reserved.
//
// Capital-micro, Inc.(Beijing) Confidential.
//
// No part of this code may be reproduced, distributed, transmitted,
// transcribed, stored in a retrieval system, or translated into any
// human or computer language, in any form or by any means, electronic,
// mechanical, magnetic, manual, or otherwise, without the express
// written permission of Capital-micro, Inc.
//
//================================================================================
// Module Description: 
// This is a SPI M/S IP Core, it is a external device of ARM AHB bus.The ARM core can
// access it through the AHB bus.
// 
//================================================================================
// Revision History :
//     V1.0   2012-12-19  FPGA IP Grp, first created
//     V2.0   2013-03-01  FPGA IP Grp, support spi data width of 8,16,32
//     V3.0   2014-05-05  FPGA IP Grp, support AHB bus interface 
//================================================================================
module 		hme_spi_v3
		(
       		scki,		//serial clock input
       		scko,		//serial clock output
       		scktri,          //serial clock tri-state enable
       		ssn,   		//slave select input
       		misoi,   	//master input/slave output
       		misoo,		//master input/slave output
       		misotri,	//master input/slave output tri-state enable
       		mosii,         	//master output/slave input
       		mosio,		//master output/slave input
       		mositri,	//master output/slave input tri-state enable
       		spssn,		//slave select output
	
	        pclk,       //input pbus clock  
            presetn,    //input pbus reset, low is active 
	        psel,       //pbus slave selection 
	        penable,
            paddr,      //pbus address 
            pwrite,     //pbus write or read 
            pwdata,     //pbus write data 
            prdata,     //pbus read data   
       		      
       		intack,		//interrupt acknowledge
       		intspi		//interrupt output
       		);

parameter SPI_BASEADDR = 32'h4000_4000;
parameter SPI_WIDTH    = 8;
/// system signal 
input          pclk;       
input          presetn;    
//spi interface
input		scki;		//serial clock input
output		scko;		//serial clock output
output		scktri;         //serial clock tri-state enable
input		ssn; 		//slave select input
input		misoi;   	//master input/slave output
output		misoo;		//master input/slave output
output		misotri;	//master input/slave output tri-state enable
input		mosii;       	//master output/slave input
output		mosio;		//master output/slave input
output		mositri;	//master output/slave input tri-state enable
output  [7:0]   spssn;		//slave select output
//AHB bus interface
input  [31:0]  paddr;      
input          psel;  
input          penable;       
input          pwrite;      
input  [31:0]  pwdata;
output [31:0]  prdata;
//Interrupt interface
input		intack;		//interrupt acknowledge
output		intspi;		//interrupt output
//protect_encode_begin
`pragma protect begin_protected
`pragma protect version=4
`pragma protect vendor="Hercules Microelectronics"
`pragma protect email="supports@hercules-micro.com"
`pragma protect data_method="AES128-CBC"
`pragma protect data_encode="Base64"
`pragma protect key_method="RSA"
`pragma protect key_encode="Base64"
`pragma protect data_line_size=96
`pragma protect key_block
S9XVdI/dIjzXjc7T/nr9MvWJSkII03L+rMy5MICLJD9x7ww9+ED2S3FVu5ciwDP/EvQEAosxCjgTP0ymbGx4a4VXtHvAZPAe4jJu8B/x69lRyTcPkHKt74MQTVsrVIC1iqpddTkbhr1F/7x7QzUGMGoC2XKKtL80/ViYFifzRj8=
`pragma protect data_block
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
`pragma protect end_protected
//protect_encode_end

endmodule
//================================================================================
// Copyright (c) 2014 Capital-micro, Inc.(Beijing)  All rights reserved.
//
// Capital-micro, Inc.(Beijing) Confidential.
//
// No part of this code may be reproduced, distributed, transmitted,
// transcribed, stored in a retrieval system, or translated into any
// human or computer language, in any form or by any means, electronic,
// mechanical, magnetic, manual, or otherwise, without the express
// written permission of Capital-micro, Inc.
//
//================================================================================
// Module Description: 
// This function of this module is a bridge of EMIF and SFR
// 
// 
//================================================================================
// Revision History :
//     V1.0   2012-12-05  FPGA IP Grp, first created
//     V2.0   2013-03-01  FPGA IP Grp, support spi data width of 8,16,32
//     V3.0   2014-05-05  FPGA IP Grp, support AHB bus interface 
//================================================================================
module apb2sfr(
	sfrwe,		//write enable
	sfroe,
	sfraddr,	//address bus
	sfrdatai,	//sfr data input
	spcon,		//output of spsta register
	spdat,		//output of spdat register
	spsta,		//output of spsta register
	spssn,		//output of spssn register

	pclk,       //input pbus clock  
    presetn,    //input pbus reset, low is active 
	psel,       //pbus slave selection 
	penable,
    paddr,      //pbus address 
    pwrite,     //pbus write or read 
    pwdata,     //pbus write data 
    prdata      //pbus read data 

    );
//==================== parameter declare===================================//
parameter SPI_BASEADDR = 32'h4000_4000;//0x80 alligned
//=========================================================================//
//protect_encode_begin
`pragma protect begin_protected
`pragma protect version=4
`pragma protect vendor="Hercules Microelectronics"
`pragma protect email="supports@hercules-micro.com"
`pragma protect data_method="AES128-CBC"
`pragma protect data_encode="Base64"
`pragma protect key_method="RSA"
`pragma protect key_encode="Base64"
`pragma protect data_line_size=96
`pragma protect key_block
JlFa8sU/P5ahWqx/V7fnHJW/lGEMw+rf1YUN3FR798g11BlqyS+IQRZ8auBQ02cy330Zn8MbKz8O7W0X5khfN644RejLQ28dWYZuWi8EF0hGRzWnpaH8qJWETwNz/2OmwVKWIyEW9YFHOFOMvjZ6+esSeuLFK6Zpr+zGWX1rsc8=
`pragma protect data_block
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
`pragma protect end_protected
//protect_encode_end
endmodule 
//================================================================================
// Copyright (c) 2014 Capital-micro, Inc.(Beijing)  All rights reserved.
//
// Capital-micro, Inc.(Beijing) Confidential.
//
// No part of this code may be reproduced, distributed, transmitted,
// transcribed, stored in a retrieval system, or translated into any
// human or computer language, in any form or by any means, electronic,
// mechanical, magnetic, manual, or otherwise, without the express
// written permission of Capital-micro, Inc.
//
//================================================================================
// Module Description: 
// The function of this module is to control the spi receieve an send by
// set the registers such spcon,spsta,spssn,spdat.
// 
// 
//================================================================================
// Revision History :
//     V1.0   2012-12-05  FPGA IP Grp, first created
//     V2.0   2013-03-01  FPGA IP Grp, support spi data width of 8,16,32
//     V3.0   2013-03-01  FPGA IP Grp, no change for update new version
//================================================================================

`timescale 1 ns / 1 ps // timescale for following modules

module ext_spi_core (
  clk,                                       // Global clock, pulse for all synchronous circuits
  rstn,                                       // Global reset
  sfrwe,                                     // Special Function Registers write enable
  sfroe,                                     // Special Function Registers read enable
  sfraddr,                                   // Special Function Registers address bus
  sfrdatai,                                  // Special Function Registers input data bus
  spcon,                                     // Serial Peripheral Control Register output
  spsta,                                     // Serial Peripheral Status Register output
  spdat,                                     // Serial Peripheral Data Register output
  spssn,                                     // Serial Peripheral Slave Select Register output
  sfrdatao,                                  // Special Function Registers bus output
  spen,                                      // Serial Peripheral Enable
  mstr,                                      // Serial Peripheral Master
  cpol,                                      // Clock Polarity
  cpha,                                      // Clock Phase
  rstcfg,                                    // Reset mstr and spen bit
  scki,                                      // Serial Clock Input
  scko,                                      // Serial Clock Output
  scktri,                                    // Enable of tri-state bufer
  ssn_ff,                                       // Slave Select
  misoi,                                     // Data master input slave output (input)
  misoo,                                     // Data master input slave output (output)
  misotri,                                   // Data master input slave output (enabele tri-state buffer)
  mosii,                                     // Master output slave input (input)
  mosio,                                     // Master output slave input (output)
  mositri,                                   // Master output slave input (enabele tri-state buffer)
  intack,                                    // SPI Interrupt Acknowledge
  intspi,                                    // SPI Interrupt Request
  scki_fall_ff,                              // scki_fall_ff signal connected with SPI_SYNCH
  scki_rise_ff                               // scki_rise_ff signal connected with SPI_SYNCH

  );
//protect_encode_begin
`pragma protect begin_protected
`pragma protect version=4
`pragma protect vendor="Hercules Microelectronics"
`pragma protect email="supports@hercules-micro.com"
`pragma protect data_method="AES128-CBC"
`pragma protect data_encode="Base64"
`pragma protect key_method="RSA"
`pragma protect key_encode="Base64"
`pragma protect data_line_size=96
`pragma protect key_block
pNJZaXTsGir8VmDEsJcEy8KBJE3f2vpkBWhmjGITCreLHSayAmzJ2MBtocxnuFUqGRSgDM1iehj7wyQ2u/Q3G4gxq72+lk866NWSrihUb3wEqKN5YYdbyr+22YeMCb4Lo47oozbq2+ucs1PSoiFXuktdTb0QIxyeJyvakyF+Pa0=
`pragma protect data_block
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
A+4TyPVEU8ozcgIiN/L8Fw==
`pragma protect end_protected
//protect_encode_end
endmodule

//================================================================================
// Copyright (c) 2014 Capital-micro, Inc.(Beijing)  All rights reserved.
//
// Capital-micro, Inc.(Beijing) Confidential.
//
// No part of this code may be reproduced, distributed, transmitted,
// transcribed, stored in a retrieval system, or translated into any
// human or computer language, in any form or by any means, electronic,
// mechanical, magnetic, manual, or otherwise, without the express
// written permission of Capital-micro, Inc.
//
//================================================================================
// Module Description: 
// the SFR interface of spi
// 
// 
//================================================================================
// Revision History :
//     V1.0   2012-12-12  FPGA IP Grp, first created
//     V2.0   2013-03-01  FPGA IP Grp, support spi data width of 8,16,32
//     V3.0   2013-03-01  FPGA IP Grp, no change for update new version
//================================================================================

`timescale 1 ns / 1 ps // timescale for following modules

//*******************************************************************--

module ext_spi_ms (
  clk,
  rstn,
  sfrwe,
  sfroe,
  sfraddr,
  sfrdatai,
  spcon,
  spsta,
  spdat,
  spssn,
  sfrdatao,
  spen,
  mstr,
  cpol,
  cpha,
  rstcfg,
  scki,
  scko,
  scktri,
  ssn,
  misoi,
  misoo,
  misotri,
  mosii,
  mosio,
  mositri,
  intack,
  intspi
  );
//protect_encode_begin
`pragma protect begin_protected
`pragma protect version=4
`pragma protect vendor="Hercules Microelectronics"
`pragma protect email="supports@hercules-micro.com"
`pragma protect data_method="AES128-CBC"
`pragma protect data_encode="Base64"
`pragma protect key_method="RSA"
`pragma protect key_encode="Base64"
`pragma protect data_line_size=96
`pragma protect key_block
mI20eJKky+dd72l05G5XSeRzwA/XQ4oc7VkcfFYR2u15L5HJDNEnnWPSe+90HTm4JDKwSbV7dLFqeuO5ElNtgf+ZvqYNLo7RQ3GEChE8kq4yehPgjDPPoj30mfanTaar4G9k+cyx8Cri+lEZ/E3c2Uy0HnKq+loNjXI55GZId2o=
`pragma protect data_block
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
`pragma protect end_protected
//protect_encode_end
endmodule



//================================================================================
// Copyright (c) 2014 Capital-micro, Inc.(Beijing)  All rights reserved.
//
// Capital-micro, Inc.(Beijing) Confidential.
//
// No part of this code may be reproduced, distributed, transmitted,
// transcribed, stored in a retrieval system, or translated into any
// human or computer language, in any form or by any means, electronic,
// mechanical, magnetic, manual, or otherwise, without the express
// written permission of Capital-micro, Inc.
//
//================================================================================
// Module Description: 
// This functiong of this module is detect the rise and fall of the clock
// 
// 
//================================================================================
// Revision History :
//     V1.0   2012-12-12  FPGA IP Grp, first created
//     V2.0   2013-03-01  FPGA IP Grp, support spi data width of 8,16,32
//     V3.0   2013-03-01  FPGA IP Grp, no change for update new version
//================================================================================

`timescale 1 ns / 1 ps // timescale for following modules

module ext_spi_synch (
  clk,                                       // Global clock, pulse for all synchronous circuits
  rstn,                                       // Global reset
  scki_rise_ff,                              // Rising edge FF SCK Input
  ssn,
  scki_fall_ff,                              // Falling edge FF SCK output
  ssn_ff);
//protect_encode_begin
`pragma protect begin_protected
`pragma protect version=4
`pragma protect vendor="Hercules Microelectronics"
`pragma protect email="supports@hercules-micro.com"
`pragma protect data_method="AES128-CBC"
`pragma protect data_encode="Base64"
`pragma protect key_method="RSA"
`pragma protect key_encode="Base64"
`pragma protect data_line_size=96
`pragma protect key_block
lMhq12o7uxQiv2GyW8wM0r7Lt+U7xnTq+wbhOyp0mf6dfsT3nCERVQzXSsRtdhEg/Yzj+oocbHzrftxMHrBbtJhaAXWfXzjdZcNR0UXwAJLBmKJRddBFioXkeUmoegM/qxtHvJwIrPGWRZNHbUCDqkfOdkTdFmpjUt5dCV0G4cw=
`pragma protect data_block
+J9h+KovGBMCYQa/Mj5O9xjz+UuIqxmlbJWdCnZVI8bOuI+bu2COC2uQneClmFrSfGzy37m7FDXZqYcKQBll/lwzjWn/uYPllbV21aZrYYsRQyM52jRwAGr0nS7v42s5
NFIFIWirQT8TesVUagXMLSlGkm2jl1Q6pCl0GLZ737axBzdFzllxcqbmhbxnGFAWwxPs0vP/Spzm42TEkzO/S2SNvujCRsLrRe9Ukc5bPJSQ+CVbO7td/V3yoy2C2oPb
fFZvWvTwj9EGLivw4dgO2NRe05/mcEQ7guA0DKJyetTsFiWnY7J7YFuTjBrKo47Iyogm0Sa9h4GMq195YwJtiPUnNw+b3AxLetu/yzf5rSt8gbn3dKSd9J1VTXCGyAJm
LmKRiI2lIu7X97POMWrj624U8t+W3TTI+GbBqYd7mvsJquy82ygXq9gXckrxf4Y7TtMqEmKVEAaevi1mhfv33hzX4D/ju8CpqiRRR8XvLFPKiCbRJr2HgYyrX3ljAm2I
vPGVOysHEugAepzQptKrC2Tnw29GDmZcozuLu5lWZzYAdFy9IoTqHyhob33/c+7EqRMIrXNI3wLeMA4k56YL+yOSFt3CRkfJW38JFFmRrvvKiCbRJr2HgYyrX3ljAm2I
o7H/i8DTrkQgBIBkWW6fxo7tCnzIEe05sTkJMS0S+QmO7Qp8yBHtObE5CTEtEvkJju0KfMgR7TmxOQkxLRL5CY7tCnzIEe05sTkJMS0S+QmGw+7NJ6EiGDCgIoQ2SDHf
j7WoFy6tbRuDSxIbySiAwI+1qBcurW0bg0sSG8kogMCPtagXLq1tG4NLEhvJKIDAgtDp525Oa86001Wt1T5l4wUSIRdohQ5rcWbmDu3uCDoTw2Qo1sAL4WYywHtsqM0d
yHCHXE+xRv4a7S6K+Zsw04+1qBcurW0bg0sSG8kogMCPtagXLq1tG4NLEhvJKIDAj7WoFy6tbRuDSxIbySiAwH9VrLchklBh3ro8CqjhU/LT/YVKB1mXcKxzcjV4pTCh
TXF2PMdgadsTcIikvJfpEFl8IDi4A8lTnjB/TWqBUQYZJrOYqmDbAM0FtTtbBIHKv7+FHwESlzh/y8BCJAFeKtEasFMEAtj+5VzUCbKDtivO5Gnlv2+7GGjKYDnf4R8C
UEG1RwMV5+S1iW9pr2jBp2dOfGb3XZ0UaiGO03vxe0+Q8aouHRYGyU0XzI6+LMn1yafyJJkXMaZPmVtIk9N/nPuVf912jN23EwGYec6Lvoo1SudFKntiWWoedIO81BHN
j7WoFy6tbRuDSxIbySiAwI+1qBcurW0bg0sSG8kogMCPtagXLq1tG4NLEhvJKIDAHj7F3Rz6xogmkhI/T6QCNL0//U6T9Nw2rjbGVR/fErQ6xMXsP9P3BfvtIcodFwM+
irJNudd7RiIBA6MsT6ODEI+1qBcurW0bg0sSG8kogMCPtagXLq1tG4NLEhvJKIDAj7WoFy6tbRuDSxIbySiAwMrO4GDJ93CwTtOA6hALNHvIlTyzoMf8mRTNBgvwaPnq
lhmoAqHUuwnR5B24EauwCgC4BMk/iiY5MgxOTTfFPfAl+RD9aRNEWc2QMgvxdlsQ48hr8ozfVQghg3mwLurRIkNcEwlkhBqKetjFvrcuIFvhSwTSRRPx5eBQxSU/TRAM
Qi39JKT0YjBHItzn5iFDCruBj2KRdUPZf7UduU4F1aC3GKgB9WLawaM07UJHqPWHjDmpdCZHj6AE5X9D6hcMZeZUQe8imqxlkQ5PYO4Xv4A=
`pragma protect end_protected
//protect_encode_end
endmodule 



