`timescale 1ns / 1ps

`include "DetectionCombinationUnit.v"
`include "SpriteROM.v"

module FrameBufferController_Top(
    input clk,  
    input reset,    
    input wire [13:0] entity_1,  //entity input form: ([13:10] entity ID, [9:8] Orientation, [7:0] Location(tile)).
    input wire [13:0] entity_2,  //Simultaneously supports up to 9 objects in the scene.
    input wire [13:0] entity_3,  //Set the entity ID to 4'hf for unused channels.
    input wire [13:0] entity_4,
    input wire [13:0] entity_5,
    input wire [13:0] entity_6,
    input wire [17:0] entity_7_Array,
    input wire [13:0] entity_8_Flip,
    input wire [13:0] entity_9_Flip,
    input wire [9:0] counter_V,
    input wire [9:0] counter_H,

    output reg colour, // 0-black 1-white

    output reg [8:0] buffer_O // 0-black 1-white
    );

    localparam [3:0] BUFFERLEN = 8;
    localparam [2:0] UPSCALE = 5;
    localparam [3:0] TILESIZE = 8;
    localparam [5:0] TILE_LEN_PIXEL = 40;
    localparam [4:0] SCREENSIZE_H = 16;
    localparam [3:0] SCREENSIZE_V = 12;


    wire [7:0] buffer;
    wire [8:0] out_entity;



DetectionCombinationUnit det (
    .clk(clk),
    .reset(reset),
    .entity_1(entity_1),
    .entity_2(entity_2),
    .entity_3(entity_3),
    .entity_4(entity_4),
    .entity_5(entity_5),
    .entity_6(entity_6),
    .entity_7_Array(entity_7_Array),
    .entity_8_Flip(entity_8_Flip),
    .entity_9_Flip(entity_9_Flip),
    .counter_V(counter_V),
    .counter_H(counter_H),
    

    .out_entity(out_entity)
);


// assign out_entity = detector(entity_1, counter_H, counter_V) & detector(entity_2, counter_H, counter_V) & detector(entity_3, counter_H, counter_V) & detector(entity_4, counter_H, counter_V) & detector(entity_5, counter_H, counter_V) & detector(entity_6, counter_H, counter_V) & detector(entity_7_Array_Heart, counter_H, counter_V) & detector(entity_8, counter_H, counter_V) & detector(entity_9, counter_H, counter_V);

SpriteROM Rom(
    .clk(clk),
    .reset(reset),
    .orientation(out_entity[1:0]),
    .sprite_ID(out_entity[5:2]),
    .line_index(out_entity[8:6]),

    .data(buffer)
);

// always@(*) begin
//     $display("buffer = %b", buffer);
// end
//reg [3:0] tile_Counter_H;

reg [5:0] buf_Index_L;
reg [2:0] buf_Index_S;

always@(posedge clk) begin
    
    if (!reset) begin
        //buf_Index_L <= counter_H % {4'b0000,TILE_LEN_PIXEL};
        
        if (buf_Index_L==(TILE_LEN_PIXEL -1) || counter_H == 0)begin
            buf_Index_L <= 0;
        end else begin
            buf_Index_L <= buf_Index_L + 1;
        end
        buf_Index_S <= (buf_Index_L)/UPSCALE;
        if(out_entity[5:2] != 4'b1111) begin
            colour <= buffer[buf_Index_S]; // 1 - White 0 - black
        end else begin
            colour <= 1;
        end
    end else begin
        colour <= 1'b1;
        buf_Index_L <= 6'b111111;
        buf_Index_S <= 3'b111;
    end
end


always@(posedge clk) begin 
    
    if (!reset)begin
    buffer_O <= buffer; 
    //colour <= buffer[4];//(out_entity[5:2] != 4'b1111)?(buffer[(counter_H % TILE_LEN_PIXEL)/UPSCALE]) : (1'b1); // 1 - White 0 - black
    end else begin
        buffer_O <= 0;
    end
    //$display("!!!!!!!!!!!!!!!!!!!!!Inside module: a = %b",  out_entity);
end
// always@(*) begin
//     $display("counter_H= %b" , buffer);
// end



endmodule
