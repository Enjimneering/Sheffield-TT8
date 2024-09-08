`include "VGA_Top.v"
`include "PPU.v"


//`include "simCLK.v"
/*

Project: TinyTapeStation
Engineer(s) : James Ashie Kotey
Module: VGA Module FPGA Implimentation Test Module

Summary: 

Description =========================================

*/


module Test_top_module (

    input wire         clk,
    input wire         reset,
    input wire  [13:0] entity_in,
    output wire [13:0] LED_out,
    
    output wire        h_sync,
    output wire        v_sync,
    output wire [3:0]  red,
    output wire [3:0]  green,
    output wire [3:0]  blue

);
    
    wire pixel_clk;
    wire system_clk; 
    
    wire clk_root;
    
    
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

   PictureProcessingUnit ppu (

    .system_clk(system_clk),  
    .pixel_clk(pixel_clk),
    .reset(reset),    
    
    .entity_1(entity_in),  
    .entity_2(14'b1111_00_00000000),  
    .entity_3(14'b1111_00_00000000),  
    .entity_4(14'b1111_00_00000000),
    .entity_5(14'b1111_00_00000000),
    .entity_6(14'b1111_00_00000000),
    .entity_7(17'b000_1111_00_00000000),
    .entity_8_Flip(14'b1111_00_00000000),
    .entity_9_Flip(14'b1111_00_00000000),

    // VGA Outputs

    .h_sync(h_sync),
    .v_sync(v_sync),
    .red(red),
    .green(green),
    .blue(blue)

);
    
    /*
    
    VGA_Top vga(
    
        .pixel_clk(pixel_clk),        
        .reset(reset),  

        .color_data(color_data),     
        .video_enable(video_enable), 
        .rgb_out({red,green,blue}),     
        .h_sync(h_sync),     
        .v_sync(v_sync)       
         
    );
    
    */

    assign LED_out = entity_in;


endmodule