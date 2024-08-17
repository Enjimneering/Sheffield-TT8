`timescale 1ns / 1ps


module FrameBufferController_Top(
    input clk,  
    input reset,    
    input wire [13:0] item_1,  //Item input form: ([13:10] Item ID, [9:8] Orientation, [7:0] Location(tile)).
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

    output reg colour // 0-black 1-white
    );


localparam BUFFERLEN = 8;
localparam UPSCALE = 5;
localparam TILESIZE = 8;
localparam TILE_LEN_PIXEL = 40;
localparam SCREENSIZE_H = 16;
localparam SCREENSIZE_V = 12;


wire [7:0] buffer;






function [6:0] item_Position_Pixel_H; //Calculate the item horizontal position in pixel
    input [7:0] item_Position;
    begin
    
    item_Position_Pixel_H = (item_Position % SCREENSIZE_H) * TILE_LEN_PIXEL;

    end
endfunction

// function [4:0] item_Position_Pixel_V; //Calculate the item vertical position in pixel
//     input [7:0] item_Position;
//     begin

//     item_Position_Pixel_V = (item_Position / SCREENSIZE_H) * TILE_LEN_PIXEL;

//     end
// endfunction

// function inRange; //If the item within the loading area(40 Pixel or 1 tile length)
//     input [7:0] item_Position;
//     input [9:0] ptH_Position;
//     input [9:0] ptV_Position;
//     begin
    
//     inRange = ptH_Position >= item_Position_Pixel_H(item_Position) && ptH_Position < item_Position_Pixel_H(item_Position) + TILE_LEN_PIXEL && ptV_Position <= item_Position_Pixel_V(item_Position) && ptV_Position > item_Position_Pixel_V(item_Position) - TILE_LEN_PIXEL;
//     // 
//     //   
//     //                      
//     //                     |-----------> The horizontal coordinate increases in this direction.
//     //                     | Screen
//     //                     |
//     //                     v 
//     //     The vertical coordinate increases in this direction.
//     //                     

//     end
    
// endfunction


// function [8:0] detector; //If the position of the pointer needs to be displayed, return the row label; otherwise, return 4'hF (an invalid identifier).
//     input [13:0] item;
//     input [9:0] ptH_Position;
//     input [9:0] ptV_Position;
//     begin
    
//     if (inRange(item[7:0], ptH_Position, ptV_Position)) begin
//             detector = {{3{1'b0}}|((ptV_Position % TILE_LEN_PIXEL)/UPSCALE), item[13:10],item[9:8]};
//         end else begin
//             detector = 9'b111111111;
//         end
//     end

// endfunction


function currentColour; //Select the value that needs to be displayed from the buffer
    input [7:0] buffer_line;
    input [13:0] item;
    input [9:0] ptH_Position;
    begin
    
    if(item[5:2] != 4'b1111) begin
        currentColour = buffer_line[(ptH_Position - item_Position_Pixel_H(item[7:0]))/5]; // 1 - White 0 - black
    end else begin
        currentColour = 1;
    end
    

    end
endfunction

wire [8:0] out_Item;



DetectAndCombination det(
    .clk(clk),
    .reset(reset),
    .item_1(item_1),
    .item_2(item_2),
    .item_3(item_3),
    .item_4(item_4),
    .item_5(item_5),
    .item_6(item_6),
    .item_7(item_7),
    .item_8(item_8),
    .item_9(item_9),
    .counter_V(counter_V),
    .counter_H(counter_H),
    

    .out_Item(out_Item)
);


// assign out_Item = detector(item_1, counter_H, counter_V) & detector(item_2, counter_H, counter_V) & detector(item_3, counter_H, counter_V) & detector(item_4, counter_H, counter_V) & detector(item_5, counter_H, counter_V) & detector(item_6, counter_H, counter_V) & detector(item_7, counter_H, counter_V) & detector(item_8, counter_H, counter_V) & detector(item_9, counter_H, counter_V);

AssetROM Rom(
    .clk(clk),
    .reset(reset),
    .direction(out_Item[1:0]),
    .charc(out_Item[5:2]),
    .index(out_Item[8:6]),

    .data(buffer)
);

always@(*) begin
    $display("Inside module: buffer = %b", out_Item);

end

always@(*) begin
    colour = currentColour(buffer, out_Item, counter_H);
end




endmodule
