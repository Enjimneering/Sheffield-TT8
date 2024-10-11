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

    wire pixel_value;
    vga_sync_generator vga_sync_gen (
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

    .colour                  ( pixel_value              ),
    .buffer_O                (unused)
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
endmodule

module vga_sync_generator (
    input clk,
    input reset,
    output reg hsync,
    output reg vsync,
    output wire display_on,
    output wire [9:0] screen_hpos,
    output wire [9:0] screen_vpos
);
    reg [9:0] hpos;
    reg [9:0] vpos;
  // declarations for TV-simulator sync parameters
  // horizontal constants
  parameter H_DISPLAY = 640;  // horizontal display width
  parameter H_BACK = 48;  // horizontal left border (back porch)
  parameter H_FRONT = 16;  // horizontal right border (front porch)
  parameter H_SYNC = 96;  // horizontal sync width
  // vertical constants
  parameter V_DISPLAY = 480;  // vertical display height
  parameter V_TOP = 33;  // vertical top border
  parameter V_BOTTOM = 10;  // vertical bottom border
  parameter V_SYNC = 2;  // vertical sync # lines
  // derived constants
  parameter H_SYNC_START = H_DISPLAY + H_FRONT;
  parameter H_SYNC_END = H_DISPLAY + H_FRONT + H_SYNC - 1;
  parameter H_MAX = H_DISPLAY + H_BACK + H_FRONT + H_SYNC - 1;
  parameter V_SYNC_START = V_DISPLAY + V_BOTTOM;
  parameter V_SYNC_END = V_DISPLAY + V_BOTTOM + V_SYNC - 1;
  parameter V_MAX = V_DISPLAY + V_TOP + V_BOTTOM + V_SYNC - 1;

  wire hmaxxed = (hpos == H_MAX) || reset;  // set when hpos is maximum
  wire vmaxxed = (vpos == V_MAX) || reset;  // set when vpos is maximum
  assign screen_hpos = (hpos < H_DISPLAY)? hpos : 0; 
  assign screen_vpos = (vpos < V_DISPLAY)? vpos : 0;

  // horizontal position counter
  always @(posedge clk) begin
    hsync <= (hpos >= H_SYNC_START && hpos <= H_SYNC_END);
    if (hmaxxed) begin
      hpos <= 0;
    end else begin
      hpos <= hpos + 1;
    end
  end


  // vertical position counter
  always @(posedge clk) begin
    vsync <= (vpos >= V_SYNC_START && vpos <= V_SYNC_END);
    if (hmaxxed)
      if (vmaxxed) begin
      vpos <= 0;
      end else begin
        vpos <= vpos + 1;
      end
  end

  // always @(posedge clk)begin
  //   if (!hsync) begin
  //     screen_hpos <= screen_hpos +1;
  //   end else begin
  //     screen_hpos <= 0;
  //   end
  // end
  // always @(posedge clk)begin
  //   if (hmaxxed) begin
  //     if (!vsync) begin
  //       screen_vpos <= screen_vpos +1;
  //     end else begin
  //       screen_vpos <= 0;
  //     end
  //   end
  // end

  // display_on is set when beam is in "safe" visible frame
  assign display_on = (hpos < H_DISPLAY) && (vpos < V_DISPLAY);

endmodule
    
