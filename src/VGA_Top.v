/*

Project: TinyTapeStation
Engineer(s) : James Ashie Kotey
Module: VGA Top Unit

Summary: The VGA sync unit uses the x and y pixel coordinates from the horizontal and vertical
counter to control the vsync and hsync output pulse.

Description =========================================


*/
    

//`include "VGA_Sync.v" - Removed for TT Build

module VGA_Top(

    input wire         pixel_clk,    // CLK
    input wire         reset,        // RESET
    input wire  [7:0]  color_data,   // COLOR DATA - FROM GRAPHICS CONTROLLER
    output reg  [7:0]  rgb_out,      // PIXEL COLOR OUTPUT
    output reg         h_sync,       // HSYNC OUT
    output reg         v_sync        // VSYNC OUT

);

    //Internal signals 

    wire video_enable;
    wire h_sync_in, v_sync_in;

    VGA_Sync sync(
        .clk(pixel_clk),
        .reset(reset),  
        .enable_pixel(video_enable),
        .h_sync(h_sync_in),
        .v_sync(v_sync_in)
    );

    //Color Logic
    always @(posedge pixel_clk ) begin
        
        if (video_enable) 
            rgb_out = color_data;
        else begin
            rgb_out = 0;
        end

        h_sync <= h_sync_in;
        v_sync <= v_sync_in;

    end

endmodule


