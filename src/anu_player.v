/*
Project: TinyTapeStation
Engineer(s) : Anubhav Avinash, Abdulatif Babli
Module: Player Logic
Create Date: 26/08/2024 

Summary: Player logic controller for movement and attacking.

Description =========================================

Sword Logic 
    The sword location is initialized outside of the 16x12 active area 
    so it doesn't affect the collision logic.
    When the player is in the attack state, the sword appears in front of the player.

Inputs:
    Controller Input:
        A, B    - Attack
        UP      - Move UP
        RIGHT   - Move RIGHT
        DOWN    - Move DOWN
        LEFT    - Move LEFT

        START, SELECT - UNUSED

    Previous Game State (Not used in this module but available for future use):
        Dragon Head Location
        Dragon Head Direction

Outputs:
    Next State Information:
        New player location
    
    Location Format: 0000_0000  (X, Y) - tiles

    (0000,0000)------> X+
        |
        |
        |
        V

        Y+
*/

// Entity ID for player is 2, sword is 1
// Orientation: 00 = up, 01 = right, 10 = down, 11 = left

// Define Behavior States 
module player (
    input wire clk,
    input wire reset,
    input wire A, B, select, start, up, down, left, right,

    output reg [13:0] player,         // Player's current visibility, orientation and position
    output reg [1:0] player_health,   // Player's health (3 states: 11, 10, 01, 00)
    output reg [13:0] sword          // Sword's current visibility, orientation and position
);
    // State register
    reg [1:0] current_state;
    reg [1:0] next_state;

    // State definitions
    localparam MOVE_STATE   = 2'b00;  // Move when there is input from the controller
    localparam ATTACK_STATE = 2'b01;  // Sword appears where the player is facing
    localparam IDLE_STATE   = 2'b10;  // Wait for input and stay idle
    localparam DEAD         = 2'b11;  // End game - player dies

    // Gameplay Flags
    reg dragon_hurt;     // Flag indicating dragon was hit (not used in this module)
    reg player_hurt;     // Flag indicating player was hit (not used in this module)
    reg dragon_dead;     // Flag indicating dragon is dead (not used in this module)
    reg player_dead;     // Flag indicating player is dead (not used in this module)
    reg sword_visible;   // Sword visibility flag
    reg game_over;       // Game over flag

    // State transition logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin   // Reset logic
            current_state <= IDLE_STATE;
            player <= 14'b0010_01_0111_0101;  // Initial player state: entityId_orientation_XXXX_YYYY
            player_health <= 2'b11;           // Max health = 3 hearts
            sword <= 14'b1111_01_0000_0000;   // Initial sword state: entityId_orientation_XXXX_YYYY (out of grid)
            sword_visible <= 1'b0;
            game_over <= 1'b0;
        end else if (!game_over) begin
            current_state <= next_state;      // Update state if game is not over
        end
    end

    // State machine for player actions
    always @( clk ) begin
        case (current_state)
            IDLE_STATE: begin
                sword <= 14'b1111_01_0000_0000;  // Hide sword outside the grid
                sword_visible <= 1'b0;
                if (player_health == 0) begin
                    next_state = DEAD;  // Transition to DEAD state if health is 0
                end else if (up ^ down ^ left ^ right) begin
                    if (A || B)
                        next_state = ATTACK_STATE;  // Attack if A or B is pressed
                    else
                        next_state = MOVE_STATE;  // Move if directional button is pressed
                end else begin
                    next_state = IDLE_STATE;  // Stay idle if no input
                end
            end

            MOVE_STATE: begin
                // Move player based on direction inputs and update orientation
                if (up && player[3:0] > 4'b0001) begin  // Check boundary for up movement
                    player[7:0] <= player [7:0] - 8'b0000_0001;  // Move up
                end else if (down && player[3:0] < 4'b1011) begin  // Check boundary for down movement
                    player[7:0] <= player [7:0] + 8'b0000_0001;  // Move down
                end else if (left && player[7:4] > 4'b0000) begin  // Check boundary for left movement
                    player[7:0] <= player [7:0] - 8'b0001_0000;  // Move left
                    player[9:8] <= 2'b11;  // Update orientation to left
                end else if (right && player[7:4] < 4'b1111) begin  // Check boundary for right movement
                    player[7:0] <= player [7:0] + 8'b0001_0000;  // Move right
                    player[9:8] <= 2'b01;  // Update orientation to right
                end
                next_state = IDLE_STATE;  // Return to IDLE after moving
            end

            ATTACK_STATE: begin   
                sword_visible <= 1'b1;  // Make sword visible
                sword[13:10] <= 4'b0001;  // Sword entity ID

                if (up && player[3:0] > 4'b0010) begin
                    sword [7:0] <= player [7:0] - 8'b0000_0001;
                    sword [9:8] <= 2'b00;
                end else if (down && player[3:0] < 4'b1010) begin
                    sword [7:0] <= player [7:0] + 8'b0000_0001;
                    sword [9:8] <= 2'b10;
                end else if (left && player[7:4] > 4'b0001) begin
                    sword [7:0] <= player [7:0] - 8'b0001_0000;
                    sword [9:8] <= 2'b11;
                end else if (right && player[7:4] < 4'b1110) begin
                    sword [7:0] <= player [7:0] + 8'b0001_0000;
                    sword [9:8] <= 2'b01;
                end
                next_state = IDLE_STATE;  // Return to IDLE after attacking
            end

            DEAD: begin
                game_over <= 1'b1;  // Set game over flag
            end

            default: begin
                next_state = IDLE_STATE;  // Default case, stay in IDLE state
            end
        endcase
    end
endmodule
    