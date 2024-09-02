/*

Project: TinyTapeStation
Engineer(s) : Bowen Shi
Module: Frame Builder DCU 
Create Date: 2024/08/17 20:47:46

Summary: 

Description =========================================

The Entity Detector-Combination Unit can display up to 9 entities on screen at once.

Entity structure:

    [13:10]  Entity ID
    [9:8]  Orientation
    [7:0]  Tile Location

    Unused entities (off-screen) have an ID of 4'hf

Screen Coordinates:

    In line with the coordinate system adopted by VGA Scanlines, the horizontal increases from right to left and  
    the vertical coordinate increases from top to bottom.

    (0,0)----------------> x  
      | 
      |
      |
      v 
      y         
*/

module DetectionCombinationUnit(
    
    input clk,
    input reset,
    
    input wire  [13:0]  entity_1,  
    // input wire  [13:0]  entity_2,  
    // input wire  [13:0]  entity_3,  
    // input wire  [13:0]  entity_4,
    // input wire  [13:0]  entity_5,
    // input wire  [13:0]  entity_6,
    // input wire  [17:0]  entity_7_Array, //[17:4] General entity. [3:0] length of array, array direction is opposite with orientation.
    // input wire  [13:0]  entity_8_Flip,
    // //input wire  [13:0]  entity_9_Flip,
    input wire  [9:0]   counter_V,
    input wire  [9:0]   counter_H,

    output wire [8:0]  out_entity
    
    //output reg  [8:0]  entity_output_reg
    );

    //Screen Size Paramaters

    localparam BUFFER_LEN = 8;
    localparam UPSCALE_FACTOR = 5;
    localparam TILE_SIZE = 8;
    localparam TILE_LEN_PIXEL = TILE_SIZE * UPSCALE_FACTOR;
    localparam SCREEN_SIZE_H = 16;
    localparam SCREEN_SIZE_V = 12;


    function [9:0] entity_Position_Pixel_H; //Calculate the entity horizontal position in pixels
        input [8:0] entity_Position;
        begin
            //entity_Position_Pixel_H = (entity_Position % SCREEN_SIZE_H) * TILE_LEN_PIXEL;
            entity_Position_Pixel_H = entity_Position[3:0] * TILE_LEN_PIXEL;
        end

    endfunction

    function [9:0] entity_Position_Pixel_V; //Calculate the entity vertical position in pixels
        input [8:0] entity_Position;
        begin
        // entity_Position_Pixel_V = (entity_Position / SCREEN_SIZE_H) * TILE_LEN_PIXEL;
        entity_Position_Pixel_V = entity_Position[7:4] * TILE_LEN_PIXEL;
        end
    endfunction

    function inRange; //If the entity is within the loading area (40 Pixel or 1 tile length)
        input [7:0] entity_Position;
        input [9:0] ptH_Position;
        input [9:0] ptV_Position;
        begin
        
        inRange = ptH_Position >= entity_Position_Pixel_H(entity_Position) 
        && ptH_Position < (entity_Position_Pixel_H(entity_Position) + TILE_LEN_PIXEL) 
        && ptV_Position >= entity_Position_Pixel_V(entity_Position) 
        && ptV_Position < entity_Position_Pixel_V(entity_Position) + TILE_LEN_PIXEL;

        end
        
    endfunction

    function inRange_Array; //If the entity is within the loading area (40 Pixel or 1 tile length)
        input [9:0] entity_OrienAndPosition;
        input [3:0] entity_Len_Array;
        input [10:0] ptH_Position;
        input [10:0] ptV_Position;
        begin
        
        inRange_Array = $signed(ptH_Position) >= $signed({1'b0,entity_Position_Pixel_H(entity_OrienAndPosition)} - ((entity_OrienAndPosition[9:8] == 2'b01) ? (entity_Len_Array * TILE_LEN_PIXEL) : 0))
        && ptH_Position < ({1'b0,entity_Position_Pixel_H(entity_OrienAndPosition)}  + ((entity_OrienAndPosition[9:8] == 2'b11) ? ((entity_Len_Array + 1) * TILE_LEN_PIXEL) : TILE_LEN_PIXEL)) 
        && $signed(ptV_Position) >= $signed({1'b0,entity_Position_Pixel_V(entity_OrienAndPosition)}  - ((entity_OrienAndPosition[9:8] == 2'b10) ? (entity_Len_Array * TILE_LEN_PIXEL) : 0))
        && ptV_Position < ({1'b0,entity_Position_Pixel_V(entity_OrienAndPosition)}  + ((entity_OrienAndPosition[9:8] == 2'b00) ? ((entity_Len_Array + 1) * TILE_LEN_PIXEL) : TILE_LEN_PIXEL));
        
        end
        
    endfunction

    function [8:0] detector; //If the position of the pointer needs to be displayed, return the row label; otherwise, return 4'hF (an invalid identifier).
        input [13:0] entity;
        input [9:0] ptH_Position;
        input [9:0] ptV_Position;
        begin
        
        if (inRange({entity[3:0],entity[7:4]}, ptH_Position, ptV_Position)==1 && entity[13:10] != 4'b1111) begin
                detector = {((ptV_Position % TILE_LEN_PIXEL)/UPSCALE_FACTOR), entity[13:10],entity[9:8]};
            end else begin
                detector = 9'b111111111; // 'h1FF
            end
        end


    endfunction

    function [8:0] detector_Flip; //If the position of the pointer needs to be displayed, return the row label; otherwise, return 4'hF (an invalid identifier).
        input [13:0] entity;
        input [9:0] ptH_Position;
        input [9:0] ptV_Position;
        begin
        
        if (inRange({entity[3:0],entity[7:4]}, ptH_Position, ptV_Position)==1 && entity[13:10] != 4'b1111) begin
                detector_Flip = {~(3'b111&((ptV_Position % TILE_LEN_PIXEL)/UPSCALE_FACTOR)), entity[13:10],entity[9:8]};
            end else begin
                detector_Flip = 9'b111111111; // 'h1FF
            end
        end


    endfunction

    function [8:0] detector_Array; //If the position of the pointer needs to be displayed, return the row label; otherwise, return 4'hF (an invalid identifier).
        input [17:0] entity_Array;
        input [9:0] ptH_Position;
        input [9:0] ptV_Position;
        begin
        
        if (inRange_Array(entity_Array[13:4], entity_Array[3:0],{1'b0,ptH_Position}, {1'b0,ptV_Position})==1 && entity_Array[17:14] != 4'b1111) begin
                detector_Array = {(3'b111&((ptV_Position % TILE_LEN_PIXEL)/UPSCALE_FACTOR)), entity_Array[17:14],entity_Array[13:12]};
            end else begin
                detector_Array = 9'b111111111; // 'h1FF
            end
        end


    endfunction

// always @(*) begin
// $display("Inside module: Range = %b \n", inRange(entity_1[7:0], counter_H, counter_V)==1 && entity_1[13:10] != 4'b1111);
// $display("Inside module: 1 = %b \n",  detector(entity_1, counter_H, counter_V));
// $display("Inside module: 2 = %b \n",  detector(entity_2, counter_H, counter_V));
// $display("Inside module: 3 = %b \n",  detector(entity_3, counter_H, counter_V));
// $display("Inside module: 4 = %b \n",  detector(entity_4, counter_H, counter_V));
// $display("Inside module: 5 = %b \n",  detector(entity_5, counter_H, counter_V));
// $display("Inside module: 6 = %b \n",  detector(entity_6, counter_H, counter_V));
// $display("Inside module: 7 = %b \n",  detector(entity_7, counter_H, counter_V));
// $display("Inside module: 8 = %b \n",  detector(entity_8, counter_H, counter_V));
// $display("Inside module: 9 = %b \n",  detector(entity_9, counter_H, counter_V));

// end

//BigAnd and_5_entity( detector(entity_1, counter_H, counter_V) , detector(entity_2, counter_H, counter_V) , detector(entity_3, counter_H, counter_V) , detector(entity_4, counter_H, counter_V) , detector(entity_5, counter_H, counter_V) , detector(entity_6, counter_H, counter_V) , detector(entity_7, counter_H, counter_V) , detector(entity_8, counter_H, counter_V) , detector(entity_9, counter_H, counter_V), out_entity);
// wire [9:0] FlipEntity_8 = detector(entity_8_Flip, counter_H, counter_V);
// wire [9:0] FlipEntity_9 = detector(entity_9_Flip, counter_H, counter_V);


// always@(*) begin
//     $display("Inside module: a = %b",  entity_Position_Pixel_H(entity_1[7:0]));
// end

reg [8:0] priority_Out;
wire [8:0] priority_1 = detector(entity_1, counter_H, counter_V);
// // wire [8:0] priority_2 = detector(entity_2, counter_H, counter_V);
// // wire [8:0] priority_3 = detector(entity_3, counter_H, counter_V);
// wire [8:0] priority_4 = detector(entity_4, counter_H, counter_V);
// wire [8:0] priority_5 = detector(entity_5, counter_H, counter_V);
// wire [8:0] priority_6 = detector(entity_6, counter_H, counter_V);
// wire [8:0] priority_7 = detector_Array(entity_7_Array, counter_H, counter_V);
// wire [8:0] priority_8 = detector_Flip(entity_8_Flip, counter_H, counter_V);
// // wire [8:0] priority_9 = detector_Flip(entity_9_Flip, counter_H, counter_V);

always @(posedge clk) begin
    if (priority_1 != 9'b111111111) begin
        priority_Out = priority_1;
    // // end else if (priority_2 != 9'b111111111) begin
    // //     priority_Out = priority_2;
    // // end else if (priority_3 != 9'b111111111) begin
    // //     priority_Out = priority_3;
    // end else if (priority_4 != 9'b111111111) begin
    //     priority_Out = priority_4;
    // end else if (priority_5 != 9'b111111111) begin
    //     priority_Out = priority_5;
    // end else if (priority_6 != 9'b111111111) begin
    //     priority_Out = priority_6;
    // end else if (priority_7 != 9'b111111111) begin
    //     priority_Out = priority_7;
    // end else if (priority_8 != 9'b111111111) begin
    //     priority_Out = priority_8;
    // // end else if (priority_9 != 9'b111111111) begin
    // //     priority_Out = priority_9;
    end else begin
        priority_Out = 9'b11111111;
    end
end

assign out_entity = priority_Out;


// assign out_entity = detector(entity_1, counter_H, counter_V) 
//     & detector(entity_2, counter_H, counter_V) 
//     & detector(entity_3, counter_H, counter_V) 
//     & detector(entity_4, counter_H, counter_V) 
//     & detector(entity_5, counter_H, counter_V) 
//     & detector(entity_6, counter_H, counter_V) 
//     & detector(entity_7, counter_H, counter_V)
//     & detector_Flip(entity_8_Flip, counter_H, counter_V)
//     & detector_Flip(entity_9_Flip, counter_H, counter_V);


// always@(*) begin
//     out_entity = detector(entity_1, counter_H, counter_V) & detector(entity_2, counter_H, counter_V) & detector(entity_3, counter_H, counter_V) & detector(entity_4, counter_H, counter_V) & detector(entity_5, counter_H, counter_V) & detector(entity_6, counter_H, counter_V) & detector(entity_7, counter_H, counter_V) & detector(entity_8, counter_H, counter_V) & detector(entity_9, counter_H, counter_V);
// end


endmodule