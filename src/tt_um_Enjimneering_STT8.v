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
    wire [13:0] entityInput = {uio_in[3:0] , ui_in[1:0], uio_in};
    wire [13:0] entityInput2 = {ui_in[3:0] , uio_in[1:0], uio_in};
    wire [9:0]  counterInputH = {ui_in, uio_in[7:6]};
    wire [9:0]  counterInputV = {uio_in, ui_in[4:3]};


    FrameBuffer_Top frameBuffer (
    .clk(clk),  
    .reset(rst_n),   
     
    .entity_2(entityInput),  //Simultaneously supports up to 9 objects in the scene.
    .entity_1(entityInput2),  // entity input form: ([13:10] entity ID, [9:8] Orientation, [7:0] Location(tile)).
    .entity_3(entityInput),  //Set the entity ID to 4'hf for unused channels.
    .entity_4(entityInput),
    .entity_5(entityInput2),
    .entity_6(entityInput),
    .entity_7(entityInput2),
    .entity_8_Flip(entityInput2),
    .entity_9_Flip(entityInput),
    .counter_V(counterInputV),
    .counter_H(counterInputH),
    .colour(uo_out[0])
    );



   VGA_Top vga(

    .pixel_clk(clk),    // CLK
    .reset(rst_n),        // RESET
    .color_data(FRAME_BUF_COL_OUT),   // COLOR DATA - FROM GRAPHICS CONTROLLER
    .rgb_out(uio_out),      // PIXEL COLOR OUTPUT
    .h_sync(uo_out[0]),       // HSYNC OUT
    .v_sync(uo_out[1])      // VSYNC OUT

);



  // All output pins must be assigned. If not used, assign to 0.
  //assign uio_out[7:0]  = 0;
  assign uio_oe         = 'b0000_0011;
  assign uo_out  [7:1]  = 0;
  assign uio_out        = 0;
  // List all unused inputs to prevent warnings
  wire _unused = &{ena, 1'b0};
    
endmodule

    
