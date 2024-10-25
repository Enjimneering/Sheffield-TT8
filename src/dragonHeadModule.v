/*
 * Copyright (c) 2024 Tiny Tapeout LTD
 * SPDX-License-Identifier: Apache-2.0
 * Author: Uri Shaked
 */


`define COLOR_WHITE 3'd7
`timescale 1ms/1ms

// top module

//TT Pinout (standard for TT projects - can't change this)

module DragonHead ( 
    input clk,
    input reset,
    input [7:0] player_pos,
  
    input vsync,

    output reg [1:0] dragon_direction,
    output reg [7:0] dragon_pos,
    output reg [5:0] movement_counter// Counter for delaying dragon's movement otherwise sticks to player
);

   
reg [3:0] dragon_x;
reg [3:0] dragon_y;


reg [3:0] dx; //difference
reg [3:0] dy;
reg [3:0] sx; //figuring out direction in axis
reg [3:0] sy;
// reg [5:0] movement_counter = 0;  // Counter for delaying dragon's movement otherwise sticks to player



// Movement logic , uses bresenhams line algorithm
always @(posedge vsync or posedge reset) begin
  if (~reset)begin
    if (movement_counter < 6'd10) begin
        movement_counter <= movement_counter + 1;
    end else begin
        movement_counter <= 0;

        // Store the current position before updating , used later
        dragon_x <= dragon_pos[7:4];
        dragon_y <= dragon_pos[3:0];

        // Calculate the differences between dragon and player
        dx <= player_pos[7:4] - dragon_x;
        dy <= player_pos[3:0] - dragon_y ;
        sx <= (dragon_x < player_pos[7:4]) ? 1 : -1; // Direction in axis
        sy <= (dragon_y < player_pos[3:0]) ? 1 : -1; 

        // Move the dragon towards the player if it's not adjacent
        if (dx >= 1 || dy >= 1) begin
        // Update dragon position only if it actually moves , keeps flickering
            if (dx >= dy) begin //prioritize movement
                dragon_x <= dragon_x + sx;
                dragon_y <= dragon_y;
            end else begin
                dragon_x <= dragon_x;
                dragon_y <= dragon_y + sy;
            end

            if (dragon_x > dragon_pos[7:4])
              dragon_direction <= 2'b01;   // Move right
            else if (dragon_x < dragon_pos[7:4])
              dragon_direction <= 2'b11;   // Move left
            else if (dragon_y > dragon_pos[3:0])
              dragon_direction <= 2'b10;   // Move down
            else if (dragon_y < dragon_pos[3:0])
              dragon_direction <= 2'b00;   // Move up

            // Update the next location
            dragon_pos <= {dragon_x, dragon_y};

        end else begin
            // stop moving when the dragon is adjacent to the player 
            dragon_x <= dragon_x; 
            dragon_y <= dragon_y; 
        end
    end
  end else begin
    dragon_x <= 0;
    dragon_y <= 0;
    movement_counter <= 0;
    dragon_pos <= 0;
    dx <= 0; //difference
    dy <= 0;
    sx <= 0; //figuring out direction in axis
    sy <= 0;
  end
end



endmodule
