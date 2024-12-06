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
    input clk

    
);

   
reg dragon_pos;

reg [1:0] dragon_direction;
reg [3:0] dragon_sprite;
reg [3:0] player_y;
reg [3:0] dragon_y;


reg [3:0] next_x;
reg [3:0] next_y;
reg [3:0] dx; //difference
reg [3:0] dy;
reg [3:0] sx; //figuring out direction in axis
reg [3:0] sy;
reg [5:0] movement_counter = 0;  // Counter for delaying dragon's movement otherwise sticks to player

reg [3:0] dragon_head_x;
reg [3:0] dragon_head_y;
reg [3:0] player_pos;
reg [3:0] sheep_pos;

reg [1:0] current_state;

localparam CHASE  = 1'b1; 
localparam ESCAPE = 1'b0; 
localparam PLAYER = 1'b1;
localparam SHEEP  = 1'b0;

reg [7:0] player_pos;
reg [7:0] sheep_pos;
reg [1:0] next_state;

reg [7:0] target_pos;

input Collision;




input RNG;

    initial begin
        target_pos = player_pos;
        current_state = CHASE;
    end

    always @(posedge frame_end) begin
        current_state <= next_state;      // Update state

    end


always @(posedge clk) begin
    if (~reset)begin
    pre_vsync <= vsync;
    if(pre_vsync != vsync && pre_vsync == 0)begin
      
    if (movement_counter < 6'd10) begin
        movement_counter <= movement_counter + 1;
    end else begin
        movement_counter <= 0;


//2'b00 collison with sheep
//2'b01 collision with sword
//2'b10 collision with palyer

    if (Collision == 2'b00) begin 
        current_state <= CHASE; // Contest behavior in DragonHead
    end
    else if (Collision == 2'b01 || Collision == 2'b10) begin 
        current_state <= ESCAPE; // Scatter behavior in DragonHead
    end

//fsm 
 case (current_state)
        CHASE: begin

            target_pos <= (RNG[0] == 1) ? player_pos : sheep_pos;

            // Check if the target has been reached
            if (dragon_pos == target_pos) begin
               next_state <= CHASE; // Change state when the target is reached
            
            end

        end

ESCAPE: begin
    reg [4:0] dist_top_left;
    reg [4:0] dist_top_right;
    reg [4:0] dist_bottom_left;
    reg [4:0] dist_bottom_right;
    reg [1:0] closest_corner;
    // Determine the closest corner based on pre-calculated distances
        dist_top_left     = dragon_x + dragon_y;                     // Top-left corner (0, 0)
        dist_top_right    = (4'b1111 - dragon_x) + dragon_y;           // Top-right corner (15, 0)
        dist_bottom_left  = dragon_x + (4'b1011 - dragon_y);           // Bottom-left corner (0, 11)
        dist_bottom_right = (4'b1111 - dragon_x) + (4'b1011 - dragon_y); // Bottom-right corner (15, 11)
     // Determine which corner is closest
        if (dist_top_left < dist_top_right && dist_top_left < dist_bottom_left && dist_top_left < dist_bottom_right)
            closest_corner = 2'b00; // Top Left
        else if (dist_top_right < dist_top_left && dist_top_right < dist_bottom_left && dist_top_right < dist_bottom_right)
            closest_corner = 2'b01; // Top Right
        else if (dist_bottom_left < dist_top_left && dist_bottom_left < dist_top_right && dist_bottom_left < dist_bottom_right)
            closest_corner = 2'b10; // Bottom Left
        else
            closest_corner = 2'b11; // Bottom Right

if (closest_corner == 2'b00) //top left
        case (RNG[1:0])
            2'b00: target_pos <= 8'b1111_0000; //top right
            2'b01: target_pos <= 8'b0000_1011; // bottom left
            2'b10: target_pos <= 8'b1111_1011; // bottom right
            2'b11: target_pos <= 8'b1111_1011; // bottom right
        endcase
if (closest_corner == 2'b01) // top right
        case (RNG[1:0])
            2'b00: target_pos <= 8'b0000_0000; //top left
            2'b01: target_pos <= 8'b0000_1011; // bottom left
            2'b10: target_pos <= 8'b0000_1011; // bottom left
            2'b11: target_pos <= 8'b1111_1011; // bottom right
        endcase
if (closest_corner == 2'b10) // bottom left
        case (RNG[1:0])
            2'b00: target_pos <= 8'b0000_0000; //top left
            2'b01: target_pos <= 8'b1111_0000; // top right
            2'b10: target_pos <= 8'b1111_0000; // top right
            2'b11: target_pos <= 8'b1111_1011; // bottom right
        endcase
if (closest_corner == 2'b11) // bottom right
        case (RNG[1:0])
            2'b00: target_pos <= 8'b0000_0000; //top left
            2'b10: target_pos <= 8'b0000_0000; //top left
            2'b01: target_pos <= 8'b0000_1011; // bottom left
            2'b11: target_pos <= 8'b1111_1011; // top right
        endcase




    // Transition when the target is reached
    if (dragon_pos == target_pos) begin
        next_state <= CONTEST_STATE;
    end else begin
        next_state <= ESCAPE;
    end
end

 endcase

// Movement logic , uses bresenhams line algorithm
  

     // Store the current position before updating , used later
        dragon_x <= dragon_pos[7:4];
        dragon_y <= dragon_pos[3:0];

        // Calculate the differences between dragon and player
        dx <= target_pos[7:4] - dragon_x;
        dy <= target_pos[3:0] - dragon_y ;
        sx <= (dragon_x < target_pos[7:4]) ? 1 : -1; // Direction in axis
        sy <= (dragon_y < target_pos[3:0]) ? 1 : -1; 

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
