`timescale 1ns / 1ps


module FramBufferController_Top(
    input clk,  
    input reset,    
    input wire [7:0] goat,
    input wire [7:0] heart_1,
    input wire [7:0] heart_2,
    input wire [7:0] heart_3,
    input wire [7:0] heart_4,
    input wire [1:0] dragonHead_Orien,
    input wire [7:0] dragonHead,//[9:8] Orientation (Flip or not depends on orientation), [7:0] Position
    input wire [1:0] dragonBody1_Orien,
    input wire [7:0] dragonBody1,
    input wire [1:0] dragonBody2_Orien,
    input wire [7:0] dragonBody2,
    input wire [1:0] sword_Orien,
    input wire [7:0] sword,
    input wire [1:0] gnome_Orien,
    input wire [7:0] gnome,
    input wire [9:0] counter_V,
    input wire [9:0] counter_H,

    output reg colour // 0-black 1-white
    );

localparam UP = 3'b000;
localparam RIGHT = 3'b001;
localparam DOWN = 3'b010;
localparam LEFT = 3'b011;
localparam WHITE = 3'b100;

localparam BUFFERLEN = 8;
localparam UPSCALE = 5;
localparam TILESIZE = 8;
localparam TILELEN_PIXEL = 40;
localparam SCREENSIZE_H = 16;
localparam SCREENSIZE_V = 12;

// localparam heart_1 = 12;
// localparam heart_2 = 13;
// localparam heart_3 = 14;
// localparam heart_4 = 15;

localparam HEART = 4'b0000;
localparam SWORD = 4'b0001;
localparam GNOME_1 = 4'b0010;
localparam GNOME_2 = 4'b0011;
localparam DRAGON_BODY_1 = 4'b0100;
localparam DRAGON_BODY_2 = 4'b0101;
localparam DRAGON_HEAD = 4'b0110;
localparam GOAT_1 = 4'b0111;
localparam GOAT_2 = 4'b1000;



reg goatStatu = 1'b0;
reg gnomeStatu = 1'b0;

wire [7:0] buffer;
wire [1:0] orien;
wire [3:0] charc;
wire [3:0] line;
wire [3:0] temp;
wire [3:0] goatStatuTemp;
wire [3:0] gnomeStatuTemp;

assign goatStatuTemp = (goatStatu) ? GOAT_2 : GOAT_1;
assign gnomeStatuTemp = (gnomeStatu) ? GNOME_2 : GNOME_1;


//Goat and Gnome statu updating every Frame


function [3:0] detector;
    input [7:0] item_Position;
    input [9:0] ptH_Position;
    input [9:0] ptV_Position;
    begin
    

    if (ptH_Position >= (item_Position % SCREENSIZE_H) * TILELEN_PIXEL && ptH_Position-TILELEN_PIXEL < (item_Position % SCREENSIZE_H) * TILELEN_PIXEL) begin
        if (ptV_Position >= (item_Position / SCREENSIZE_H) * TILELEN_PIXEL && ptV_Position < (item_Position / SCREENSIZE_H) * TILELEN_PIXEL + TILELEN_PIXEL) begin
            detector = (ptV_Position % TILELEN_PIXEL)/UPSCALE;
        end else begin
            detector = 4'b1000;
        end
    end else begin
        detector = 4'b1000;
    end

    end
endfunction


function currentColour;
    input [7:0] buffer_line;
    input [7:0] item_Position;
    input [9:0] ptH_Position;
    begin

    currentColour = buffer[(ptH_Position - (item_Position % 16)*TILELEN_PIXEL)/5];

    end
endfunction



assign line = 4'b1000;
assign charc =  4'hF;
assign orien = 2'b00;

//goat
assign temp = detector(goat, counter_H, counter_V);
assign temp = (charc != 4'hF) ? 4'b1000 : temp;
assign line = (temp[3]) ? line : temp;
assign orien = (temp[3]) ? orien : 2'b00;
assign charc = (temp[3]) ? charc : goatStatuTemp;

//gnome
assign temp = detector(gnome, counter_H, counter_V);
assign temp = (charc != 4'hF) ? 4'b1000 : temp;
assign line = (temp[3]) ? line : temp;
assign orien = (temp[3]) ? orien : gnome_Orien;
assign charc = (temp[3]) ? charc : gnomeStatuTemp;

//dragon head
assign temp = detector(dragonHead, counter_H, counter_V);
assign temp = (charc != 4'hF) ? 4'b1000 : temp;
assign line = (temp[3]) ? line : temp;
assign orien = (temp[3]) ? orien : dragonHead_Orien;
assign charc = (temp[3]) ? charc : DRAGON_HEAD;

//dragon body 1
assign temp = detector(dragonBody1, counter_H, counter_V);
assign temp = (charc != 4'hF) ? 4'b1000 : temp;
assign line = (temp[3]) ? line : temp;
assign orien = (temp[3]) ? orien : dragonBody1_Orien;
assign charc = (temp[3]) ? charc : DRAGON_BODY_1;

//dragon body 2
assign temp = detector(dragonBody2, counter_H, counter_V);
assign temp = (charc != 4'hF) ? 4'b1000 : temp;
assign line = (temp[3]) ? line : temp;
assign orien = (temp[3]) ? orien : dragonBody2_Orien;
assign charc = (temp[3]) ? charc : DRAGON_BODY_2;

//sword
assign temp = detector(sword, counter_H, counter_V);
assign temp = (charc != 4'hF) ? 4'b1000 : temp;
assign line = (temp[3]) ? line : temp;
assign orien = (temp[3]) ? orien : sword_Orien;
assign charc = (temp[3]) ? charc : SWORD;

//heart 1
assign temp = detector(heart_1, counter_H, counter_V);
assign temp = (charc != 4'hF) ? 4'b1000 : temp;
assign line = (temp[3]) ? line : temp;
assign orien = (temp[3]) ? orien : 2'b00;
assign charc = (temp[3]) ? charc : HEART;

//heart 2
assign temp = detector(heart_2, counter_H, counter_V);
assign temp = (charc != 4'hF) ? 4'b1000 : temp;
assign line = (temp[3]) ? line : temp;
assign orien = (temp[3]) ? orien : 2'b00;
assign charc = (temp[3]) ? charc : HEART;

//heart 3
assign temp = detector(heart_3, counter_H, counter_V);
assign temp = (charc != 4'hF) ? 4'b1000 : temp;
assign line = (temp[3]) ? line : temp;
assign orien = (temp[3]) ? orien : 2'b00;
assign charc = (temp[3]) ? charc : HEART;

//heart 4
assign temp = detector(heart_4, counter_H, counter_V);
assign temp = (charc != 4'hF) ? 4'b1000 : temp;
assign line = (temp[3]) ? line : temp;
assign orien = (temp[3]) ? orien : 2'b00;
assign charc = (temp[3]) ? charc : HEART;


AssetROM Rom(
    .clk(clk),
    .reset(reset),
    .direction(orien),
    .charc(charc),
    .index(line),
    .data(buffer)
);


always@(*) begin
    case(charc)
        4'b0000: begin
            if (heart_1<=192) begin
                colour = currentColour(buffer, heart_1, counter_H);
            end else if (heart_2 <= 192) begin
                colour = currentColour(buffer, heart_2, counter_H);
            end else if (heart_3 <= 192) begin
                colour = currentColour(buffer, heart_3, counter_H);
            end else if (heart_4 <= 192) begin
                colour = currentColour(buffer, heart_4, counter_H);
            end
        end

        4'b0001: begin
            colour = currentColour(buffer, sword, counter_H);
        end

        4'b0010: begin
            colour = currentColour(buffer, gnome, counter_H);
        end

        4'b0011: begin
            colour = currentColour(buffer, gnome, counter_H);
        end

        4'b0100: begin
            colour = currentColour(buffer, dragonBody1, counter_H);
        end

        4'b0101: begin
            colour = currentColour(buffer, dragonBody2, counter_H);
        end

        4'b0110: begin
            colour = currentColour(buffer, dragonHead, counter_H);
        end

        4'b0111: begin
            colour = currentColour(buffer, goat, counter_H);
        end

        4'b1000: begin
            colour = currentColour(buffer, goat, counter_H);
        end

        default: begin
            colour = 1;
        end
    endcase
end

    








// assign temp = detector(goat, counter_H, counter_V);
// assign orien = temp[3] ? WHITE : UP;
// assign line = temp[2:0];


endmodule
