
module FrameBuffer_Top (
    
    input clk,  
    input reset,    
    
    input wire [13:0] entity_1,  //entity input form: ([13:10] entity ID, [9:8] Orientation, [7:0] Location(tile)).
    // input wire [13:0] entity_2,  //Simultaneously supports up to 9 objects in the scene.
    // input wire [13:0] entity_3,  //Set the entity ID to 4'hf for unused channels.
    input wire [13:0] entity_4,
    input wire [13:0] entity_5,
    input wire [13:0] entity_6,
    input wire [17:0] entity_7_Array,
    input wire [13:0] entity_8_Flip,
    //input wire [13:0] entity_9_Flip,
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


// function [9:0] entity_Position_Pixel_H; //Calculate the entity horizontal position in pixel
//     input [7:0] entity_Position;
//     begin
    
//     entity_Position_Pixel_H = (entity_Position % SCREENSIZE_H) * TILE_LEN_PIXEL;

//     end
// endfunction

// function [4:0] entity_Position_Pixel_V; //Calculate the entity vertical position in pixel
//     input [7:0] entity_Position;
//     begin

//     entity_Position_Pixel_V = (entity_Position / SCREENSIZE_H) * TILE_LEN_PIXEL;

//     end
// endfunction

// function inRange; //If the entity within the loading area(40 Pixel or 1 tile length)
//     input [7:0] entity_Position;
//     input [9:0] ptH_Position;
//     input [9:0] ptV_Position;
//     begin
    
//     inRange = ptH_Position >= entity_Position_Pixel_H(entity_Position) && ptH_Position < entity_Position_Pixel_H(entity_Position) + TILE_LEN_PIXEL && ptV_Position <= entity_Position_Pixel_V(entity_Position) && ptV_Position > entity_Position_Pixel_V(entity_Position) - TILE_LEN_PIXEL;
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
//     input [13:0] entity;
//     input [9:0] ptH_Position;
//     input [9:0] ptV_Position;
//     begin
    
//     if (inRange(entity[7:0], ptH_Position, ptV_Position)) begin
//             detector = {{3{1'b0}}|((ptV_Position % TILE_LEN_PIXEL)/UPSCALE), entity[13:10],entity[9:8]};
//         end else begin
//             detector = 9'b111111111;
//         end
//     end

// endfunction


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
    // .entity_2(entity_2),
    // .entity_3(entity_3),
    .entity_4(entity_4),
    .entity_5(entity_5),
    .entity_6(entity_6),
    .entity_7_Array(entity_7_Array),
    .entity_8_Flip(entity_8_Flip),
    // .entity_9_Flip(entity_9_Flip),
    .counter_V(counter_V),
    .counter_H(counter_H),
    

    .out_entity(out_entity)
);


// assign out_entity = detector(entity_1, counter_H, counter_V) & detector(entity_2, counter_H, counter_V) & detector(entity_3, counter_H, counter_V) & detector(entity_4, counter_H, counter_V) & detector(entity_5, counter_H, counter_V) & detector(entity_6, counter_H, counter_V) & detector(entity_7, counter_H, counter_V) & detector(entity_8, counter_H, counter_V) & detector(entity_9, counter_H, counter_V);

SpriteROM Rom(
    .clk(clk),
    .reset(reset),

    .orientation(out_entity[1:0]),
    .sprite_ID(out_entity[5:2]),
    .line_index(out_entity[8:6]),
    .read_enable(1),
    .data(buffer)
);

// always@(*) begin
//     $display("buffer = %b", buffer);
// end

always@(posedge clk) begin
    colour <= currentColour(buffer, out_entity, counter_H);
end




endmodule