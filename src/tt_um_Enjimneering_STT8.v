/*
 * Copyright (c) 2024 James Ashie Kotey
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_Enjimneering_STT8 (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);


  SpriteROM spriteROM(
      .clk(clk),
      .reset(rst_n),
      .read_enable(ui_in[0]),
      .orientation(ui_in[2:1]),
      .sprite_ID(ui_in[5:3]),
      .line_index({uio_in[0] , ui_in[7:6]}),
      .data(uo_out)
  );
  
  // All output pins must be assigned. If not used, assign to 0.
  assign uio_out[7:2]  = 0;
  assign uio_oe        = 'b0000_0011;

  // List all unused inputs to prevent warnings
  wire _unused = &{uio_in ,ena, 1'b0};
    
endmodule

    
