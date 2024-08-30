/*
Project: TinyTapeStation
Engineer(s) : Anubhav Avinash, Abdulatif Babli
Module: Player Logic
Create Date: 26/08/2024 

Summary: Player logic controller for movement and attacking.

Description =========================================

Sword Logic 
    Sword location is initialised outside of the 16x12 active area 
    so it doesn't affect the collision logic.
    When the player is in the attack state the sword location in front of the player

Inputs 
    Controller Input:
       
        A       - Attack
        B       - Attack
        UP      - Move UP
        RIGHT   - Move RIGHT
        DOWN    - Move DOWN
        LEFT    - Move LEFT

        START, SELECT - UNUSED

    Previous Game State
        Dragon Head Location
        Dragon Head Direction

Outputs

    Next State Information
    	New player location
    
    Location Format: 0000_0000  (X,Y) - tiles

    (0000,0000)------> X+
        |
        |
        |
        V

        Y+
*/

// Define Behaviour States 
module player (
    input wire frame_clk,
    input wire rst,
    input wire A, B, select, start, up, down, left, right,

    output reg [7:0] player_location,
    output reg [7:0] sword_location 

    /* we might need this if we're doing collision logic in each entity module
    input wire  [7:0]  sheep_location, 
   	input wire  [7:0]  dragon_head_location,
    input wire  [2:0]  dragon_head_direction,
	*/
);
    // State register
    reg [1:0] current_state;
    reg [1:0] next_state;

    // Player Attributes
    reg [1:0] player_health; // 00 = dead, no hearts; 01 = 1 heart; 10 = 2 hearts; 11 = 3 hearts
    reg [1:0] player_direction; // Also corresponds to sword direction(00 = up, 01 = down, 10 = left, 11 = right)

    // State definitions
    localparam MOVE_STATE = 2'b00;  // Move when there is an input from the controller
    localparam ATTACK_STATE = 2'b01;  // Sword appears where the player is facing
    localparam IDLE_STATE = 2'b10;  // Wait for an input and be in an idle animation maybe
    localparam DEAD = 2'b11;  // end game - player wins

    // Gamplay Flags
	reg dragon_hurt; // 1 less body part or dead
	reg player_hurt; // 1 less player heart and move two tiles into the direction it got hit or dead
	reg dragon_dead; // VICTORY ACHIEVED 
	reg player_dead; // YOU DIED
    reg sword_visible;
	reg game_over;

    always @(posedge frame_clk) begin
        if (rst) begin   // reset logic
            current_state <= IDLE_STATE;
            player_location <= 8'b0100_0100; // Example stating location
            player_health <= 2'b11; // Max health = 3 hearts
            sword_location <= 8'b0000_0000; //Anywhere out of grid
            sword_visible <= 1'b0;
        end 

        else if (!game_over) current_state = next_state;
    end

    // Decide what the current state should be    
    always @(posedge frame_clk) begin

        case (current_state)
            IDLE_STATE: begin
                if (up || down || left || right)
                    next_state = MOVE_STATE;
                else if (A)
                    next_state = ATTACK_STATE;
                else if (player_health == 0)
                    next_state = DEAD;
                else
                    next_state = IDLE_STATE;
            end

            MOVE_STATE: begin
        		if (up) begin
                    player_location <= player_location - 8'b0000_1000;
                    player_direction <= 2'b00;
                end else if (down) begin
                    player_location <= player_location + 8'b0000_1000;
                    player_direction <= 2'b01;
                end else if (left) begin
                    player_location <= player_location - 8'b1000_0000;
                    player_direction <= 2'b10;
                end else if (right) begin
                    player_location <= player_location + 8'b1000_0000;
                    player_direction <= 2'b11;
                end else begin
                    next_state = IDLE_STATE;
                end
            end

            ATTACK_STATE: begin   
                if (A) begin
                    //logic for the sword to appear in front of the player in the same direction
                    sword_visible <= 1'b1;
                    case(player_direction) //display logic to rotate the entity should be used
                        2'b00: sword_location <= player_location - 8'b0000_1000;
                        2'b01: sword_location <= player_location + 8'b0000_1000;
                        2'b01: sword_location <= player_location - 8'b1000_0000;
                        2'b11: sword_location <= player_location + 8'b1000_0000;
                        default: sword_location = 8'b0000_0000;
                    endcase
                end else
                    next_state = IDLE_STATE;
            end

            DEAD: game_over <= 1'b1;

            default: next_state = IDLE_STATE; // Default case if something unexpected happens
        endcase
    end
endmodule



