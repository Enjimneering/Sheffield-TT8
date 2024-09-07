`include "VGA_Top.v"

/*

Project: TinyTapeStation
Engineer(s) : James Ashie Kotey
Module: VGA Module FPGA Implimentation Test Module

Summary: 

Description =========================================

*/

// `include "simCLK.v" // remove when symthesing 

module Test_top_module (

    input clk,
    input reset,
    input wire  [11:0]  color_data,
    output wire [13:0] LED_out,
    
    output wire       h_sync,
    output wire       v_sync,
    output wire [3:0] red,
    output wire [3:0] green,
    output wire [3:0] blue

);
    
    wire pixel_clk;
    wire system_clk; 
    
   clk_wiz_0 divider
    (
    // Clock out ports
    .clk_out_50MHz(system_clk),     // output clk_out_50MHz
    .clk_out_25MHz(pixel_clk),     // output clk_out_25MHz
    // Status and control signals
    .reset(reset), // input reset
   // Clock in ports
    .clk_in(clk)      // input clk_in
    );


    
    VGA_Top vga(
    
        .pixel_clk(pixel_clk),        
        .reset(reset),  

        .color_data(color_data),     
        .video_enable(video_enable), 
        .rgb_out({red,green,blue}),     
        .h_sync(h_sync),     
        .v_sync(v_sync)       
         
    );
      

    assign LED_out = color_data;


endmodule