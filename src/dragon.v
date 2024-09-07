/*

Project: TinyTapeStation
Engineer(s) : Abdulatif Babli, James Ashie Kotey, Anubhav Avinash
Module: Dragon Movement Logic
Create Date: 26/08/2024 

Summary: 

Description =========================================
//TODO ABED: The variable names don't match up can you fix this pls.


Inputs 

    Previous Game State
        Dragon Head Location
        Dragon Head Direction
        Length

    Current Game State
        Player Location
        Sheep Location
        Target Tile
        
Outputs

    Next State Information
            New Dragon Head Location
            New Dragon Head Direction
            New Length


*/

// Define Behaviour States 

module dragon_head (

    input wire         frame_clk,
    input wire         rst,

    input wire  [7:0]  player_location,`
    input wire  [7:0]  sheep_location,


    input wire  [7:0]  dragon_head_location,
    input wire  [2:0]  dragon_head_direction,
    input wire  [3:0]  dragon_body_length,


    output reg  [7:0]  next_dragon_head_location,
    output reg  [2:0]  next_dragon_head_direction,
    output reg  [3:0]  next_dragon_body_length,
    output reg  [1:0]  behaviour_state

);

    // State register
    reg [1:0] current_state;
    reg reset_state;

    // State definitions

    localparam CONTEST_STATE = 2'b00;  // target the closest entity (player/sheep)
    localparam RETREAT_STATE = 2'b01;  // move far away from the player, target corner tile.
    localparam SCATTER_STATE = 2'b10;  // target a random tile in the play area
    localparam DEAD          = 2'b11;  // end game - player wins


    // Direction definitions

    localparam UP     = 2'b00; 
    localparam RIGHT  = 2'b01; 
    localparam DOWN   = 2'b10; 
    localparam LEFT   = 2'b11;  

    // Gamplay Flags

    reg dragon_contest;
    reg dragon_hurt;
    reg dragon_win;
    reg sheep_respawn;

    reg target_tile;
    reg state_complete; //Signal to move to next state?
    reg game_over;         

    always @(posedge frame_clk or posedge rst) begin
        if (rst) begin
            timer <= 8'b0;
        end else if (timeout) begin
            timer <= 8'b0;
        end else begin
            timer <= timer + 1;
        end
    end    
    

    function [7:0] SelectTarget;   // Calculate the closest entity to the dragon - return the target location
    
        input [7:0] _playerLocation;
        input [7:0] _sheepLocation;
        input [1:0] _currentState;
    
        begin
        
            case (_currentState)

            CONTEST_STATE:
            begin  
                if (_contest_state) begin

                    // Extract Y and X coordinates

                    dragon_head_y = dragon_head_location[7:4]; // Extract the first 4 bits for Y coordinate
                    dragon_head_x = dragon_head_location[3:0]; // Extract the last 4 bits for X coordinate

                    sheep_y = _sheepLocation[7:4]; 
                    sheep_x = _sheepLocation[3:0]; 

                    player_y = _playerLocation[7:4];
                    player_x = _playerLocation[3:0];

                    // Calculate Manhattan distance between the dragon and the sheep (Should be a function)

                    if (dragon_head_x > sheep_x)
                        distance_dragon_sheep_x = dragon_head_x - sheep_x;
                    else
                        distance_dragon_sheep_x = sheep_x - dragon_head_x;

                    if (dragon_head_y > sheep_y)
                        distance_dragon_sheep_y = dragon_head_y - sheep_y;
                    else
                        distance_dragon_sheep_y = sheep_y - dragon_head_y;

                    distance_dragon_sheep = distance_dragon_sheep_x + distance_dragon_sheep_y;

                    // Calculate Manhattan distance between the dragon and the player

                    if (dragon_head_x > player_x)
                        distance_dragon_player_x = dragon_head_x - player_x;
                    else
                        distance_dragon_player_x = player_x - dragon_head_x;

                    if (dragon_head_y > player_y)
                        distance_dragon_player_y = dragon_head_y - player_y;
                    else
                        distance_dragon_player_y = player_y - dragon_head_y;

                    distance_dragon_player = distance_dragon_player_x + distance_dragon_player_y;

                    
                    // return appropriate location 

                    if ( distance_dragon_player < distance_dragon_sheep ) begin

                        SelectTarget = _player_location;
                    end

                    else begin

                        SelectTarget = _sheep_location;
                    end

                    
                end

                    else begin   // If not in contest state

                        //target randon Tile
                        SelectTarget = _sheep_location;

                    end

            end

            RETREAT_STATE:  //TODO- ABED
        begin
            if (dragon_hurt) begin 
                reg [3:0] player_x, player_y;
                reg [7:0] top_left, top_right, bottom_left, bottom_right;
             //   reg [7:0] distance_to_top_left, distance_to_top_right, distance_to_bottom_left, distance_to_bottom_right;


                // Define the corner locations assuming that tyhe grid starts from bottom left making it (0,0) 
                top_left     = 8'b1111_0000;  
                top_right    = 8'b1111_1111; 
                bottom_left  = 8'b0000_0000; 
                bottom_right = 8'b0000_1111;   


                // Generate a random number between 0 and 3 to choose a corner
                random_corner = timer[1:0]; 

                // Select a corner based on the random number
                case (random_corner)
                2'b00: SelectTarget = top_left;
                2'b01: SelectTarget = top_right;
                2'b10: SelectTarget = bottom_left;
                2'b11: SelectTarget = bottom_right;
        endcase
    end
        end

                
        SCATTER_STATE:
        begin
            if (dragon_win) begin  // Check if the dragon beats the player to the sheep
                reg [7:0] random_target;

                // Generate a random target location on the grid
                random_target[7:4] = timer[7:4];  // Random X coordinate
                random_target[3:0] = timer[3:0];   // Random Y coordinate

                SelectTarget = random_target;  // Set the random target as the next location
            end
        end

    endfunction  



    function [7:0] NextLocation;    // Decide the next tile the dragon's head will move to
        
        input [7:0] _currentLocation;
        input [7:0] _targetTile;

        reg signed [3:0] dx, dy;       // Differences between target and current positions
        reg  [3:0] next_x, next_y;
        reg  [3:0] current_x, current_y;
        reg  [3:0] sx, sy;       // Steps in the X and Y directions
   
        begin
            // Extract current X and Y coordinates
            current_x = _currentLocation[7:4];
            current_y = _currentLocation[3:0];

            // Extract target X and Y coordinates
            target_x = _targetTile[7:4];
            target_y = _targetTile[3:0];

        // Calculate the differences between target and current positions
        dx = (target_x > current_x) ? (target_x - current_x) : (current_x - target_x);
        dy = (target_y > current_y) ? (target_y - current_y) : (current_y - target_y);
        sx = (current_x < target_x) ? 1 : -1;
        sy = (current_y < target_y) ? 1 : -1;

        // Movement based on which axis is closer (larger difference)
        if (dx >= dy) begin
            // Move in the X direction
            next_x = current_x + sx;
            next_y = current_y;  // No change in Y
        end else begin
            // Move in the Y direction
            next_x = current_x;  // No change in X
            next_y = current_y + sy;
        end

        // Combine next X and Y coordinates into the next location
            NextLocation = {next_x, next_y};
    end
endfunction


    always @(posedge frame_clk) begin
        
        if (rst)     // reset logic
            behaviour_state <= SCATTER_STATE;
        else 
            behaviour_state <= current_state;
    end




    // Decide what the next state should be

    always @(posedge frame_clk) begin

    case (current_state)

            CONTEST_STATE: 
            begin
                // Update location and direction
                
                target_tile = SelectTarget( CONTEST_STATE , player_location , sheep_location);

                next_dragon_head_location <= NextLocation(dragon_head_location, target_tile);
                next_dragon_head_direction <= NextDirection(dragon_head_location, next_dragon_head_location);

                // if the dragon either eats sheep or kills the player

                if (next_dragon_head_location == target_tile ) begin
                    
                    if (dragon_win) begin
                         current_state <= SCATTER_STATE;

                    end

                    else if (dragon_hurt) begin
                        current_state <= RETREAT_STATE;
                    end
                end


                else  begin
                    
                    current_state <= CONTEST_STATE;
                end

            end


            RETREAT_STATE: 
            begin

                // Update location and direction
                target_tile = SelectTarget( RETREAT_STATE , player_location , sheep_location);

                next_dragon_head_location <= NextLocation(dragon_head_location, target_tile);
                next_dragon_head_direction <= NextDirection(dragon_head_location, next_dragon_head_location);


                if (next_dragon_head_location == target_tile ) begin
                    
                        current_state <= CONTEST_STATE;

                end 

            end

            SCATTER_STATE:
            begin
                // Update location and direction
                target_tile = SelectTarget( RETREAT_STATE , player_location , sheep_location);

                next_dragon_head_location <= NextLocation (     // Which is clearer? - Format A
                    dragon_head_location, 
                    target_tile
                );

                next_dragon_head_direction <= NextDirection(dragon_head_location, next_dragon_head_location); // - Format  B


                 if (next_dragon_head_location == target_tile ) begin
                    
                        current_state <= CONTEST_STATE;

                end 

            end


            


        endcase

    end



endmodule