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

//entity for player is 2, sword is 1
// orientiant 00 = up, 01 = right, 10 = down, 11=left


// Define Behaviour States 
module player (
    input wire frame_clk,
    input wire rst,
    input wire A, B, select, start, up, down, left, right,

    output reg [13:0] player,
    output reg [13:0] player_health,
    output reg [13:0] sword
    /* we might need this if we're doing collision logic in each entity module
    input wire  [7:0]  sheep_location, 
    input wire  [7:0]  dragon_head_location,
    input wire  [2:0]  dragon_head_direction,
    */
);
    // State register
    reg [1:0] current_state;
    reg [1:0] next_state;

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

    // Decide what the current state should be    
    always @(posedge frame_clk) begin
        if (rst) begin   // reset logic
            current_state <= IDLE_STATE;
            player <= 14'b0010_01_1000_0010; // Example stating location entityId_orientation_XXXX_YYYY
            player_health <= 2'b11; // Max health = 3 hearts
            sword <= 14'b1111_01_0000_0000; //Anywhere out of grid entityId_orientation_XXXX_YYYY
            sword_visible <= 1'b0;
        end else if (!game_over) current_state = next_state;
    
        case (current_state)
            IDLE_STATE: begin
                if (up ^ down ^ left ^ right) begin
                    if (A || B)
                        next_state = ATTACK_STATE;
                    else 
                        next_state = MOVE_STATE;
                end else if (player_health == 0)
                    next_state = DEAD;
                else
                    next_state = IDLE_STATE;
            end

            MOVE_STATE: begin
                if (up && player [3:0] != 0010) begin //also checking that the player isn't at the border
                    player [3:0] <= player [3:0] - 4'b0001; //location change in tiles
                end else if (down && player [3:0] != 1010) begin
                    player [3:0] <= player [3:0] + 4'b0001; 
                end else if (left && player [7:4] != 0001) begin
                    player [7:4] <= player [7:4] - 4'b0001; 
                    player [9:8] <= 2'b11; //orientation
                end else if (right && player [7:4] != 1110) begin
                    player [7:4] <= player [7:4] - 4'b0001;
                    player [9:0] <= 2'b01; 
                end else begin
                    next_state = IDLE_STATE;
                end
            end

            ATTACK_STATE: begin   
                //logic for the sword to appear in front of the player in the same direction
                sword_visible <= 1'b1;
                sword [13:10] <= 4'b0001;
                if (up && player [3:0] != 0010) begin // ensuring sword doesn't end up outside the border
                    sword [7:0] <= player [7:0] - 8'b0000_0001;
                    sword [9:8] <= 2'b00;
                end else if (down && player [3:0] != 1010) begin
                    sword [7:0] <= player [7:0] + 8'b0000_0001;
                    sword [9:8] <= 2'b10;
                end else if (left && player [7:4] != 0001) begin
                    sword [7:0] <= player [7:0] - 8'b0001_0000;
                    sword [9:8] <= 2'b11;
                end else if (right && player [7:4] != 1110) begin
                    sword [7:0] <= player [7:0] + 8'b0001_0000;
                    sword [9:8] <= 2'b01;
                end
                next_state = IDLE_STATE;
            end

            DEAD: game_over <= 1'b1;

            default: next_state = IDLE_STATE; // Default case if something unexpected happens
        endcase
    end
endmodule



