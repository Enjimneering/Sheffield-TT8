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
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
    wire hsync;
    wire vsync;
    reg [1:0] R;
    reg [1:0] G;
    reg [1:0] B;
    wire video_active;
    wire [9:0] pix_x;
    wire [9:0] pix_y;

    wire entityInput = {ui_in ,ui_in[0:5]};
    wire entityInput2 = {ui_in[0:5] ,ui_in};
    wire entityInput3 = {ui_in, ui_in, ui_in[0:1]};

    wire pixel_value;
    VGA_Top vga_sync_gen (
        .clk(clk),
        .reset(~rst_n),
        .hsync(hsync),
        .vsync(vsync),
        .display_on(video_active),
        .screen_hpos(pix_x),
        .screen_vpos(pix_y)
    );
    assign uo_out  = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

    assign uio_out = 0;
    assign uio_oe  = 0;
    wire _unused_ok = &{ena, uio_in};

    wire [7:0] unused;

    wire [7:0] inPos;
    assign inPos = ui_in;

    FrameBufferController_Top FBC(
    .clk_in                  ( clk                   ),
    .reset                   ( ~rst_n                 ),
    .entity_2(entityInput),  //Simultaneously supports up to 9 objects in the scene.
    .entity_1(entityInput2),  // entity input form: ([13:10] entity ID, [9:8] Orientation, [7:0] Location(tile)).
    .entity_3(entityInput),  //Set the entity ID to 4'hf for unused channels.
    .entity_4(entityInput),
    .entity_5(entityInput2),
    .entity_6(entityInput),
    .entity_7_Array(entityInput3),
    .entity_8_Flip(entityInput2),
    .entity_9_Flip(entityInput),
    .counter_V               ( pix_y      [9:0]  ),
    .counter_H               ( pix_x      [9:0]  ),

    .colour                  ( pixel_value              )
    );



    always @(posedge clk) begin
    if (~rst_n) begin
      R <= 0;
      G <= 0;
      B <= 0;
    end else begin

      if (video_active) begin
        R <= pixel_value ? 2'b11 : 0;
        G <= pixel_value ? 2'b11 : 0;
        B <= pixel_value ? 2'b11 : 0;
      end else begin
        R <= 0;
        G <= 0;
        B <= 0;
      end
    end
  end

  // All output pins must be assigned. If not used, assign to 0.
  //assign uio_out[7:0]  = 0;
endmodule

    
