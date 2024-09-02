
/*

Project: TinyTapeStation
Engineer : Bowen Shi, 
Refactors by James Ashie Kotey
Module: Sprite ROM
Create Date: 2024/08/17 20:47:46

Summary: The SpriteROM stores the 9 game sprites and is able to output them line by line in several differernt or

Description =========================================

Sprite List:

    0: Heart
    1: Sword
    2: Gnome_Idle_1
    3: Gnome_Idle_2
    4: Dragon_Wing_Up
    5: Dragon_Wing_Down
    6: Dragon_Head
    7: Sheep_Idle_1
    8: Sheep_Idle_2

Orientation Selection:

    The ROM Can be read from in four differernt ways in order to output the imagine in a differenet orientations.

    UP    = 0  - No change
    RIGHT = 1  - Reflection on y = x
    DOWN  = 2  - Reflection on y = 0
    LEFT  = 3  - Reflection on y = -x
    

Sprite Storage:

    The sprite is stored using an active low binary bitmap.
    0 = Pixel_ON
    1 = Pixel_OFF

*/

//Modules with a timescale cannot be synthesized


module SpriteROM(
    
    input            clk,
    input            reset,
    input wire       read_enable,
    input wire [1:0] orientation,
    input wire [3:0] sprite_ID,
    input wire [2:0] line_index,
    
    output reg [7:0] data
);

    localparam UP     = 2'b00;
    localparam RIGHT  = 2'b01;
    localparam DOWN   = 2'b10;
    localparam LEFT   = 2'b11;


    function [7:0] romData;
        
        input [3:0]  _spriteID;
        input [2:0]  _lineIndex;
        input        _invertLineIndex;
        reg [2:0]    _newIndex;
        
        begin
        
        // Start from the bottom line if the _invertLineIndex is 1 
        // Start from the top line if order is 0

        if (_invertLineIndex == 1 ) begin 
            _newIndex = ~_lineIndex; 
        end else begin
            _newIndex = _lineIndex;
        end

        case(_spriteID)     
            4'b0000: begin
                case(_newIndex)       //Heart
                3'b000: romData = 8'b11000111;
                3'b001: romData = 8'b10000011;
                3'b010: romData = 8'b10000001;
                3'b011: romData = 8'b11000000;
                3'b100: romData = 8'b11001000;
                3'b101: romData = 8'b10010001;
                3'b110: romData = 8'b10000011;
                3'b111: romData = 8'b11000111;
                endcase
            end

            // 4'b0001: begin            //Sword
            //     case(_newIndex)
            //     3'b000: romData = 8'b11101111;
            //     3'b001: romData = 8'b11101111;
            //     3'b010: romData = 8'b11101111;
            //     3'b011: romData = 8'b11101111;
            //     3'b100: romData = 8'b11101111;
            //     3'b101: romData = 8'b11101111;
            //     3'b110: romData = 8'b11000111;
            //     3'b111: romData = 8'b11101111;
            //     endcase
            // end

            // 4'b0010: begin      //Gnome_Idle_1
            //     case(_newIndex)
            //     3'b000: romData = 8'b11111111;
            //     3'b001: romData = 8'b11000011;
            //     3'b010: romData = 8'b10110000;
            //     3'b011: romData = 8'b00000011;
            //     3'b100: romData = 8'b00110001;
            //     3'b101: romData = 8'b00000000;
            //     3'b110: romData = 8'b01000001;
            //     3'b111: romData = 8'b11111111;
            //     endcase
            // end

            // 4'b0011: begin     //Gnome_Idle_2
            //     case(_newIndex)
            //     3'b000: romData = 8'b11111011;
            //     3'b001: romData = 8'b11100011;
            //     3'b010: romData = 8'b11001000;
            //     3'b011: romData = 8'b11000011;
            //     3'b100: romData = 8'b10001001;
            //     3'b101: romData = 8'b10000000;
            //     3'b110: romData = 8'b10010001;
            //     3'b111: romData = 8'b11111111;
            //     endcase
            // end

            // 4'b0100: begin    //Dragon_Wing_Up
            //     case(_newIndex)
            //     3'b000: romData = 8'b11000011;
            //     3'b001: romData = 8'b11100001;
            //     3'b010: romData = 8'b10000011;
            //     3'b011: romData = 8'b10000001;
            //     3'b100: romData = 8'b00000001;
            //     3'b101: romData = 8'b01000000;
            //     3'b110: romData = 8'b11100001;
            //     3'b111: romData = 8'b11000001;
            //     endcase
            // end

            // 4'b0101: begin  //Dragon_Wing_Down
            //     case(_newIndex)
            //     3'b000: romData = 8'b11000011;
            //     3'b001: romData = 8'b11100001;
            //     3'b010: romData = 8'b11000011;
            //     3'b011: romData = 8'b10000001;
            //     3'b100: romData = 8'b10000000;
            //     3'b101: romData = 8'b10000000;
            //     3'b110: romData = 8'b10000001;
            //     3'b111: romData = 8'b11000001;
            //     endcase
            // end

            // 4'b0110: begin      // Dragon_Head
            //     case(_newIndex)
            //     3'b000: romData = 8'b11000111;
            //     3'b001: romData = 8'b11000011;
            //     3'b010: romData = 8'b11000011;
            //     3'b011: romData = 8'b10010001;
            //     3'b100: romData = 8'b10110001;
            //     3'b101: romData = 8'b10100001;
            //     3'b110: romData = 8'b01000011;
            //     3'b111: romData = 8'b11000111;
            //     endcase
            // end

            // 4'b0111: begin     // Sheep_Idle_1
            //     case(_newIndex)
            //     3'b000: romData = 8'b11001111;
            //     3'b001: romData = 8'b10000011;
            //     3'b010: romData = 8'b10011000;
            //     3'b011: romData = 8'b01111011;
            //     3'b100: romData = 8'b01111011;
            //     3'b101: romData = 8'b01111000;
            //     3'b110: romData = 8'b10111011;
            //     3'b111: romData = 8'b11000111;
            //     endcase
            // end

            // 4'b1000: begin     // Sheep_Idle_2
            //     case(_newIndex)
            //     3'b000: romData = 8'b11100111;
            //     3'b001: romData = 8'b11000001;
            //     3'b010: romData = 8'b11001100;
            //     3'b011: romData = 8'b10111101;
            //     3'b100: romData = 8'b10111101;
            //     3'b101: romData = 8'b10111100;
            //     3'b110: romData = 8'b11011101;
            //     3'b111: romData = 8'b11100011;
            //     endcase
            // end

            default: begin
                romData = 8'b11111111;  //empty space - unused tile
            end
        
        endcase
        end
    
    endfunction

    reg [7:0] temp;

    always @(posedge clk) begin // impliment the 4 orientations
        
        if(read_enable) begin
    
            if (orientation == UP) begin                                // Normal Operation
                case(line_index)
                    3'b000: temp = romData(sprite_ID,3'b000, 1'b0 );
                    3'b001: temp = romData(sprite_ID,3'b001, 1'b0 );
                    3'b010: temp = romData(sprite_ID,3'b010, 1'b0 );
                    3'b011: temp = romData(sprite_ID,3'b011, 1'b0 );
                    3'b100: temp = romData(sprite_ID,3'b100, 1'b0 );
                    3'b101: temp = romData(sprite_ID,3'b101, 1'b0 );
                    3'b110: temp = romData(sprite_ID,3'b110, 1'b0 );
                    3'b111: temp = romData(sprite_ID,3'b111, 1'b0 );
                endcase
                data[0] <= temp[7];
                data[1] <= temp[6];
                data[2] <= temp[5];
                data[3] <= temp[4];
                data[4] <= temp[3];
                data[5] <= temp[2];
                data[6] <= temp[1];
                data[7] <= temp[0];
            end 

           else if (orientation == RIGHT) begin                        // (Rotate 90 degrees clockwise around the center point)
                temp = romData(sprite_ID, 3'b000, 1'b1 );   
                data[0] <= temp[~line_index];                
                temp = romData(sprite_ID, 3'b001, 1'b1 );
                data[1] <= temp[~line_index];
                temp = romData(sprite_ID, 3'b010, 1'b1 );
                data[2] <= temp[~line_index];
                temp = romData(sprite_ID, 3'b011, 1'b1 );
                data[3] <= temp[~line_index];
                temp = romData(sprite_ID, 3'b100, 1'b1 );
                data[4] <= temp[~line_index];
                temp = romData(sprite_ID, 3'b101, 1'b1 );
                data[5] <= temp[~line_index];
                temp = romData(sprite_ID, 3'b110, 1'b1 );
                data[6] <= temp[~line_index];
                temp = romData(sprite_ID, 3'b111, 1'b1 );
                data[7] <= temp[~line_index];
            end

            else if(orientation == DOWN) begin                           // Top row to bottom row (Reflection on the line y = 0)
                case(line_index)
                    3'b000: temp = romData(sprite_ID,3'b000, 1'b1 );
                    3'b001: temp = romData(sprite_ID,3'b001, 1'b1 );
                    3'b010: temp = romData(sprite_ID,3'b010, 1'b1 );
                    3'b011: temp = romData(sprite_ID,3'b011, 1'b1 );
                    3'b100: temp = romData(sprite_ID,3'b100, 1'b1 );
                    3'b101: temp = romData(sprite_ID,3'b101, 1'b1 );
                    3'b110: temp = romData(sprite_ID,3'b110, 1'b1 );
                    3'b111: temp = romData(sprite_ID,3'b111, 1'b1 );
                endcase
                data <= temp;
            end

  
            else if (orientation == LEFT) begin                         //  (Rotate 90 degrees clockwise around the center point and reflect on the line x = 0)
                temp = romData(sprite_ID, 3'b000, 1'b0 );      
                data[0] <= temp[~line_index];
                temp = romData(sprite_ID, 3'b001, 1'b0 );
                data[1] <= temp[~line_index];
                temp = romData(sprite_ID, 3'b010, 1'b0 );
                data[2] <= temp[~line_index];
                temp = romData(sprite_ID, 3'b011, 1'b0 );
                data[3] <= temp[~line_index];
                temp = romData(sprite_ID, 3'b100, 1'b0 );
                data[4] <= temp[~line_index];
                temp = romData(sprite_ID, 3'b101, 1'b0 );
                data[5] <= temp[~line_index];
                temp = romData(sprite_ID, 3'b110, 1'b0 );
                data[6] <= temp[~line_index];
                temp = romData(sprite_ID, 3'b111, 1'b0 );
                data[7] <= temp[~line_index];
            end 
        
            else begin
                data <= romData(4'hf, 3'b000, 1'b0 );
            end

        end

    end

endmodule