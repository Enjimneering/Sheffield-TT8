module Game_Logic_Top(

    input clk,
    input logic_enable,
    input reset,
    
    input [7:0] button_state,

    input  disable_player, 
    input  disable_dragon, 

    output enable_player,
    output enable_dragon,
    
    inout    [7:0]  sword_position,
    inout    [7:0]  player_position,
    inout    [7:0]  dragon_head_position,
    inout    [3:0]  dragon_length,
    input    [48:0] Dragon_Body_Locations,   //7 body segments maximum 
    //shouldn't it be 55:0? 8 bits per body segment
    inout    [1:0]  dragon_state,
    inout    [7:0]  sheep_position
    //dragon's orientation/direction needed to move the player when it gets hit
);

    reg [2:0] player_health;
    reg       player_hurt;
    reg       dragon_shrink;
    reg       dragon_grow;
    reg       game_over;


    // Game Logic Processor Scheduling

    // PLAYER INPUT (PLAYER ENABLE)                                            

    // Player Move? / Player Attack?                                           


    //----------------------------------------- CLK 1

    
    // Player Module                                                                

    // MOVE -> Player Collision Check with boundary or dragon
    /*
    if (!game_over) begin   
        if (player_health == 0)
            game_over <= 1;
        if (player_position == dragon_head_position) begin
            player_hurt <= 1;
            player_health <= player_health - 1;
        end
        */

        // ATTACK -> sword collision check with dragon 
        
        /*
        if (sword_position == dragon_head_position) begin
            dragon_hurt <= 1;
            if (dragon_length == 0)
                game_over <= 1;
            else 
                dragon_length <= dragon_length - 1;
        end
    end
    */


    //----------------------------------------- CLK 2



    // PLAYER DISABLE -> DRAGON ENABLE

    // DRAGON MOVE -> dragon collision with player, dragon collision with sheep



    //----------------------------------------- CLK 3






    // DRAGON GROW / DRAGON SHRINK  - change behaviour state
    
    // DRAGON DISABLE

    // SHEEP SPAWN/SPAWN



    // ---------------------------------------- CLK 4




endmodule