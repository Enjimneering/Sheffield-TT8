/*

Project: TinyTapeStation
Engineer(s) : 
Module: Dragon Movement Logic
Create Date: 26/08/2024 

Summary: 

Description =========================================

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

module dragon (

    input wire         frame_clk,
    input wire         rst,

    input wire  [7:0]  player_location,
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


    // TODO: ABED - work on all of these functions, Anu has started you off with the select target logic

    function [7:0] SelectTarget;   // Calculate the closest entity to the dragon - return the target location
    
        input [7:0] _playerLocation;
        input [7:0] _sheepLocation;
        input [1:0] _currentState;

        //README

        /* Anu -  I  wrote this logic that uses manhatten distances to calculate which entity is closest to the dragon, 
        if you find a way that is simpler/ will use less logic, feel free to change it - if not, please add the variables 
        to try and make this work. */

        case (_currentState)

        CONTEST_STATE:
        begin  
            /*
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

        */

        end

        RETREAT_STATE:
        begin
            

        end






        endcase
    
    endfunction  


    function [7:0] NextLocation;    // Decide the next tile the dragon's head will move to
        input [7:0] _currentLocation;
        input [7:0] _targetTile;
    reg [3:0] current_x, current_y, target_x, target_y , next_x, next_y;
 

    begin
        // Extract current X and Y coordinates
        current_y = _currentLocation[7:4];
        current_x = _currentLocation[3:0];

        // Extract target X and Y coordinates
        target_y = _targetTile[7:4];
        target_x = _targetTile[3:0];

        // Determine next X coordinate
        if (current_x < target_x)
            next_x = current_x + 1;
        else if (current_x > target_x)
            next_x = current_x - 1;
        else
            next_x = current_x;  // No change in X coordinate

        // Determine next Y coordinate
        if (current_y < target_y)
            next_y = current_y + 1;
        else if (current_y > target_y)
            next_y = current_y - 1;
        else
            next_y = current_y;  // No change in Y coordinate

        // Combine next X and Y coordinates into the next location
        NextLocation = {next_y, next_x};
    end
    
    endfunction


    function [2:0] NextDirection;   // Decide on the location the dragon is facing depening on the locations of the tiles it moved from
        input [7:0] _lastLocation;
        input [7:0] _newLocation;
        
        begin
            
            



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
