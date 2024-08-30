/*

Project: TinyTapeStation
Engineer(s) : Bowen Shi
Module: Frame Buffer Controler Top Module
Create Date: 17/08/2024 

Summary: The frame buffer controller takes in the sprite orientation and location from the game control logic and 
outputs it to VGA unit to be displayed on screen pixel by pixel at the appropriate time according to the VGA timing 
standard.


Description =========================================

Entity Input structure:

    [13:10]  Entity ID
    [9:8]  Orientation
    [7:0]  Tile Location

    Unused entities (off-screen) have an ID of 4'hf

Entity Priority:



*/

// please do not add timescales to the individual hardware models- only testbenches.

module FrameBufferController_Top(
    input clk,  
    input reset,    
    input wire [13:0] entity_1,  //entity input form: ([13:10] entity ID, [9:8] Orientation, [7:0] Location(tile)).
    input wire [13:0] entity_2,  //Simultaneously supports up to 9 objects in the scene.
    input wire [13:0] entity_3,  //Set the entity ID to 4'hf for unused channels.
    input wire [13:0] entity_4,
    input wire [13:0] entity_5,
    input wire [13:0] entity_6,
    input wire [13:0] entity_7,
    input wire [13:0] entity_8_Flip,
    input wire [13:0] entity_9_Flip,
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


    function [9:0] entity_Position_Pixel_H; //Calculate the entity horizontal position in pixels
        input [7:0] entity_Position;
        begin
        
        entity_Position_Pixel_H = (entity_Position % SCREENSIZE_H) * TILE_LEN_PIXEL;

        end
    endfunction



    function currentColour; //Select the value that needs to be displayed from the buffer
        input [7:0] buffer_line;
        input [13:0] entity;
        input [9:0] ptH_Position;
        begin
        
        if(entity[5:2] != 4'b1111) begin
            currentColour = buffer_line[(ptH_Position % TILE_LEN_PIXEL)/UPSCALE]; // 1 - White 0 - black
        end else begin
            currentColour = 1;
        end
        

        end
    endfunction

    wire [8:0] out_entity;



    DetectionCombinationUnit det(
        .clk(clk),
        .reset(reset),
        .entity_1(entity_1),
        .entity_2(entity_2),
        .entity_3(entity_3),
        .entity_4(entity_4),
        .entity_5(entity_5),
        .entity_6(entity_6),
        .entity_7(entity_7),
        .entity_8_Flip(entity_8_Flip),
        .entity_9_Flip(entity_9_Flip),
        .counter_V(counter_V),
        .counter_H(counter_H),
        

        .out_entity(out_entity)
    );



    SpriteROM Rom(
        .clk(clk),
        .reset(reset),
        .orientation(out_entity[1:0]),
        .sprite_ID(out_entity[5:2]),
        .line_index(out_entity[8:6]),

        .data(buffer)
    );


    always@(*) begin
        colour = currentColour(buffer, out_entity, counter_H);
    end

    // debug lines

    /* assign out_entity = detector(entity_1, counter_H, counter_V) 
        & detector(entity_2, counter_H, counter_V) 
        & detector(entity_3, counter_H, counter_V) 
        & detector(entity_4, counter_H, counter_V) 
        & detector(entity_5, counter_H, counter_V) 
        & detector(entity_6, counter_H, counter_V) 
        & detector(entity_7, counter_H, counter_V) 
        & detector(entity_8, counter_H, counter_V) 
        & detector(entity_9, counter_H, counter_V);

    */

    /* always@(*) begin
        $display("buffer = %b", buffer);
    end */ 


endmodule
