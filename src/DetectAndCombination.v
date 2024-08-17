`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/17 20:47:46
// Design Name: 
// Module Name: DetectAndCombination
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module DetectAndCombination(
    input clk,
    input reset,
    input wire [13:0] item_1,  //Item input form: ([13:10] Item ID [9:8] Orientation,[7:0] Location(tile)).
    input wire [13:0] item_2,  //Simultaneously supports up to 9 objects in the scene.
    input wire [13:0] item_3,  //Set the item ID to 4'hf for unused channels.
    input wire [13:0] item_4,
    input wire [13:0] item_5,
    input wire [13:0] item_6,
    input wire [13:0] item_7,
    input wire [13:0] item_8,
    input wire [13:0] item_9,
    input wire [9:0] counter_V,
    input wire [9:0] counter_H,

    output wire [8:0]out_Item
    //output reg [8:0]out_Item
    );


localparam BUFFERLEN = 8;
localparam UPSCALE = 5;
localparam TILESIZE = 8;
localparam TILE_LEN_PIXEL = 40;
localparam SCREENSIZE_H = 16;
localparam SCREENSIZE_V = 12;


function [6:0] item_Position_Pixel_H; //Calculate the item horizontal position in pixel
    input [7:0] item_Position;
    begin
    
    item_Position_Pixel_H = (item_Position % SCREENSIZE_H) * TILE_LEN_PIXEL;

    end
endfunction

function [4:0] item_Position_Pixel_V; //Calculate the item vertical position in pixel
    input [7:0] item_Position;
    begin

    item_Position_Pixel_V = (item_Position / SCREENSIZE_H) * TILE_LEN_PIXEL;

    end
endfunction

function inRange; //If the item within the loading area(40 Pixel or 1 tile length)
    input [7:0] item_Position;
    input [9:0] ptH_Position;
    input [9:0] ptV_Position;
    begin
    
    inRange = ptH_Position >= item_Position_Pixel_H(item_Position) && ptH_Position < (item_Position_Pixel_H(item_Position) + TILE_LEN_PIXEL) && ptV_Position >= item_Position_Pixel_V(item_Position) && ptV_Position < item_Position_Pixel_V(item_Position) + TILE_LEN_PIXEL;
    // 
    //   
    //                      
    //                     |-----------> The horizontal coordinate increases in this direction.
    //                     | Screen
    //                     |
    //                     v 
    //     The vertical coordinate increases in this direction.
    //                     

    end
    
endfunction


function [8:0] detector; //If the position of the pointer needs to be displayed, return the row label; otherwise, return 4'hF (an invalid identifier).
    input [13:0] item;
    input [9:0] ptH_Position;
    input [9:0] ptV_Position;
    begin
    
    if (inRange(item[7:0], ptH_Position, ptV_Position)==1 && item[13:10] != 4'b1111) begin
            detector = {((ptV_Position % TILE_LEN_PIXEL)/UPSCALE), item[13:10],item[9:8]};
        end else begin
            detector = 9'b111111111;
        end
    end

endfunction

// always @(*) begin
// $display("Inside module: Range = %b \n", inRange(item_1[7:0], counter_H, counter_V)==1 && item_1[13:10] != 4'b1111);
// $display("Inside module: 1 = %b \n",  detector(item_1, counter_H, counter_V));
// $display("Inside module: 2 = %b \n",  detector(item_2, counter_H, counter_V));
// $display("Inside module: 3 = %b \n",  detector(item_3, counter_H, counter_V));
// $display("Inside module: 4 = %b \n",  detector(item_4, counter_H, counter_V));
// $display("Inside module: 5 = %b \n",  detector(item_5, counter_H, counter_V));
// $display("Inside module: 6 = %b \n",  detector(item_6, counter_H, counter_V));
// $display("Inside module: 7 = %b \n",  detector(item_7, counter_H, counter_V));
// $display("Inside module: 8 = %b \n",  detector(item_8, counter_H, counter_V));
// $display("Inside module: 9 = %b \n",  detector(item_9, counter_H, counter_V));

// end

//BigAnd and_5_item( detector(item_1, counter_H, counter_V) , detector(item_2, counter_H, counter_V) , detector(item_3, counter_H, counter_V) , detector(item_4, counter_H, counter_V) , detector(item_5, counter_H, counter_V) , detector(item_6, counter_H, counter_V) , detector(item_7, counter_H, counter_V) , detector(item_8, counter_H, counter_V) , detector(item_9, counter_H, counter_V), out_Item);
assign out_Item = detector(item_1, counter_H, counter_V) & detector(item_2, counter_H, counter_V) & detector(item_3, counter_H, counter_V) & detector(item_4, counter_H, counter_V) & detector(item_5, counter_H, counter_V) & detector(item_6, counter_H, counter_V) & detector(item_7, counter_H, counter_V) & detector(item_8, counter_H, counter_V) & detector(item_9, counter_H, counter_V);

// always@(*) begin
//     out_Item = detector(item_1, counter_H, counter_V) & detector(item_2, counter_H, counter_V) & detector(item_3, counter_H, counter_V) & detector(item_4, counter_H, counter_V) & detector(item_5, counter_H, counter_V) & detector(item_6, counter_H, counter_V) & detector(item_7, counter_H, counter_V) & detector(item_8, counter_H, counter_V) & detector(item_9, counter_H, counter_V);
// end
// always@(posedge clk, out_Item) begin
//     $display("Inside module: a = %b",  out_Item);
    
// end
endmodule