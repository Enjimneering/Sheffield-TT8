/*
 * Copyright (c) 2024 James Ashie Kotey
 * SPDX-License-Identifier: Apache-2.0
 */

//`default_nettype none

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

    wire FRAME_BUF_COL_OUT;

    FrameBuffer_Top frameBuffer (
    .clk(clk),  
    .reset(rst_n),    
    .entity_2({4'hf, 2'b00 , ui_in}),  //Simultaneously supports up to 9 objects in the scene.
    .entity_1({4'hf, 2'b00 , ui_in}),  //entity input form: ([13:10] entity ID, [9:8] Orientation, [7:0] Location(tile)).
    .entity_3({4'hf, 2'b00 , ui_in}),  //Set the entity ID to 4'hf for unused channels.
    .entity_4({4'hf, 2'b00 , ui_in}),
    .entity_5({4'hf, 2'b00 , ui_in}),
    .entity_6({4'hf, 2'b00 , ui_in}),
    .entity_7({4'hf, 2'b00 , ui_in}),
    .entity_8_Flip({4'hf, 2'b00 , ui_in}),
    .entity_9_Flip({4'hf, 2'b00 , ui_in}),
    .counter_V(10'b0),
    .counter_H(10'b0),
    .colour(uo_out[0])
    );


/*
   VGA_Top vga(

    .pixel_clk(clk),    // CLK
    .reset(rst_n),        // RESET
    .color_data(FRAME_BUF_COL_OUT),   // COLOR DATA - FROM GRAPHICS CONTROLLER
    .rgb_out(uio_out),      // PIXEL COLOR OUTPUT
    .h_sync(uo_out[0]),       // HSYNC OUT
    .v_sync(uo_out[1])      // VSYNC OUT

);
*/
  // All output pins must be assigned. If not used, assign to 0.
  //assign uio_out[7:0]  = 0;
  assign uio_oe         = 'b0000_0011;
  assign uo_out  [7:1]  = 0;
  assign uio_out        = 0;
  // List all unused inputs to prevent warnings
  wire _unused = &{ena, 1'b0};
    
endmodule

    
