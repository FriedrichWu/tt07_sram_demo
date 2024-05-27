/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_kmakise_sram_demo (
`ifdef USE_POWER_PINS
	inout VPWR,
	inout VGND,
`endif 
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
//======================================//  
//========Interal_Signals===============//
//rst_n use as chip_select
//here spare will not use
//1 uio_in use as r/w# selet;
//io pins limited, support only 2 bis a time, but NOT all situation
reg  [3:0] wmask;
wire       spare_wen;
wire [8:0] real_in;
wire [8:0] real_out;

assign uio_oe = 8'b0;//all input for bi-direct IOs
assign uio_out = 8'b0;//all bi-direct IOs force to 0
assign spare_wen = 0;//always deactive
//get the 9th bit
assign real_in = {1'b0, ui_in[7:0]};
//drop the 9th bit
assign uo_out = real_out[7:0];
//decoder for wmask
always@(*) begin
  case (uio_in[2:1])
	//sigle 2 bits
	'b00: begin
		wmask = 'b0001;
	end
	'b01: begin
		wmask = 'b0010;
	end
	//first 4 bits
	'b10: begin
		wmask = 'b1100;
	end 
	//all on
	'b11: begin
		wmask = 'b1111;
	end
	default: wmask = 'b1111;
  endcase
end
//=====================================//
sky130_sram_1rw_tiny sram0 (
`ifdef USE_POWER_PINS
    .vccd1      (VPWR       ),
    .vssd1      (VGND       ),
`endif		
	.clk0       (clk        ),
	.csb0       (~rst_n     ),
	.web0       (uio_in[0]  ),
	.wmask0     (wmask      ),
	.spare_wen0 (spare_wen  ),
	.addr0      (uio_in[7:3]),
	.din0       (real_in    ),
	.dout0      (real_out   )
);
endmodule
