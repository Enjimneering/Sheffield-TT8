`timescale 1ns / 1ps


module AssetROM(
    input clk,
    input reset,
    input wire [1:0] direction,
    input wire [3:0] charc,
    input wire [3:0] index_in,
    
    output reg [7:0] data
    );

localparam UP = 3'b000;
localparam RIGHT = 3'b001;
localparam DOWN = 3'b010;
localparam LEFT = 3'b011;

wire index;

assign index = index_in[2:0];

function [7:0] romData;
    input [3:0] charc_Func;
    input [2:0] index_Func;
    input order;
    reg [2:0] newIndex;
    begin
    
    if (order==1) begin // reading order, if order = 1, means reading from bottom to top
        newIndex = ~index_Func; 
    end else begin
        newIndex = index_Func;
    end

    case(charc_Func)
        4'b0000: begin
            case(newIndex)
            3'b000: romData = 8'b11111111;
            3'b001: romData = 8'b10011001;
            3'b010: romData = 8'b00000000;
            3'b011: romData = 8'b00100000;
            3'b100: romData = 8'b00010000;
            3'b101: romData = 8'b10000001;
            3'b110: romData = 8'b11000011;
            3'b111: romData = 8'b11100111;
            endcase
        end

        4'b0001: begin  //SwordVertical:
            case(newIndex)
            3'b000: romData = 8'b11101111;
            3'b001: romData = 8'b11101111;
            3'b010: romData = 8'b11101111;
            3'b011: romData = 8'b11101111;
            3'b100: romData = 8'b11101111;
            3'b101: romData = 8'b11101111;
            3'b110: romData = 8'b11000111;
            3'b111: romData = 8'b11101111;
            endcase
        end

        4'b0010: begin 
            case(newIndex)
            3'b000: romData = 8'b11111111;
            3'b001: romData = 8'b11000011;
            3'b010: romData = 8'b10110000;
            3'b011: romData = 8'b00000011;
            3'b100: romData = 8'b00110001;
            3'b101: romData = 8'b00000000;
            3'b110: romData = 8'b01000001;
            3'b111: romData = 8'b11111111;
            endcase
        end

        4'b0011: begin 
            case(newIndex)
            3'b000: romData = 8'b11111111;
            3'b001: romData = 8'b10001111;
            3'b010: romData = 8'b10000011;
            3'b011: romData = 8'b11000001;
            3'b100: romData = 8'b10010101;
            3'b101: romData = 8'b10000000;
            3'b110: romData = 8'b10001011;
            3'b111: romData = 8'b11011011;
            endcase
        end

        4'b0100: begin 
            case(newIndex)
            3'b000: romData = 8'b11001111;
            3'b001: romData = 8'b11100011;
            3'b010: romData = 8'b01000010;
            3'b011: romData = 8'b00000000;
            3'b100: romData = 8'b00000000;
            3'b101: romData = 8'b00000000;
            3'b110: romData = 8'b00000101;
            3'b111: romData = 8'b10011111;
            endcase
        end

        4'b0101: begin 
            case(newIndex)
            3'b000: romData = 8'b11111111;
            3'b001: romData = 8'b10000011;
            3'b010: romData = 8'b01000010;
            3'b011: romData = 8'b00000000;
            3'b100: romData = 8'b00000000;
            3'b101: romData = 8'b00000000;
            3'b110: romData = 8'b00000101;
            3'b111: romData = 8'b10011111;
            endcase
        end

        4'b0110: begin 
            case(newIndex)
            3'b000: romData = 8'b10111111;
            3'b001: romData = 8'b11000111;
            3'b010: romData = 8'b00110000;
            3'b011: romData = 8'b00011000;
            3'b100: romData = 8'b00000000;
            3'b101: romData = 8'b10000001;
            3'b110: romData = 8'b11000111;
            3'b111: romData = 8'b11111111;
            endcase
        end

        4'b0111: begin 
            case(newIndex)
            3'b000: romData = 8'b11100011;
            3'b001: romData = 8'b10011101;
            3'b010: romData = 8'b00011110;
            3'b011: romData = 8'b00111110;
            3'b100: romData = 8'b10111110;
            3'b101: romData = 8'b10000001;
            3'b110: romData = 8'b11011011;
            3'b111: romData = 8'b11011011;
            endcase
        end

        4'b1000: begin 
            case(newIndex)
            3'b000: romData = 8'b11111111;
            3'b001: romData = 8'b11100011;
            3'b010: romData = 8'b10011101;
            3'b011: romData = 8'b00011110;
            3'b100: romData = 8'b00111110;
            3'b101: romData = 8'b10111110;
            3'b110: romData = 8'b10000001;
            3'b111: romData = 8'b11011011;
            endcase
        end

        default: begin
            romData = 8'b11111111;
        end
    
    endcase
    end
endfunction

reg [7:0] temp;



always @(*) begin
    if (direction == UP)begin
        data = romData(charc, index, 1'b0);
    end else if (direction == DOWN) begin
        data = romData(charc, index, 1'b1);
    end else if (direction == RIGHT) begin
        temp = romData(charc,3'b000, 1'b1 );
        data[0] = temp[~index];
        temp = romData(charc,3'b001, 1'b1 );
        data[1] = temp[~index];
        temp = romData(charc,3'b010, 1'b1 );
        data[2] = temp[~index];
        temp = romData(charc,3'b011, 1'b1 );
        data[3] = temp[~index];
        temp = romData(charc,3'b100, 1'b1 );
        data[4] = temp[~index];
        temp = romData(charc,3'b101, 1'b1 );
        data[5] = temp[~index];
        temp = romData(charc,3'b110, 1'b1 );
        data[6] = temp[~index];
        temp = romData(charc,3'b111, 1'b1 );
        data[7] = temp[~index];
    end else if (direction == LEFT) begin
        temp = romData(charc,3'b000, 1'b0 );
        data[0] = temp[~index];
        temp = romData(charc,3'b001, 1'b0 );
        data[1] = temp[~index];
        temp = romData(charc,3'b010, 1'b0 );
        data[2] = temp[~index];
        temp = romData(charc,3'b011, 1'b0 );
        data[3] = temp[~index];
        temp = romData(charc,3'b100, 1'b0 );
        data[4] = temp[~index];
        temp = romData(charc,3'b101, 1'b0 );
        data[5] = temp[~index];
        temp = romData(charc,3'b110, 1'b0 );
        data[6] = temp[~index];
        temp = romData(charc,3'b111, 1'b0 );
        data[7] = temp[~index];
    end else begin
        data = romData(4'hf, 3'b000, 1'b0 );
    end
end

endmodule
