`timescale 1ns/1ns
`include "anu_player.v"

module player_tb;
    // Inputs
    reg clk = 0;
    reg reset = 0;
    reg A, B, select, start;
    reg up, down, left, right;

    // Outputs
    wire [13:0] player;
    wire [1:0] player_health;
    wire [13:0] sword;

    // Instantiate the player module
    player uut (
        .clk(clk),
        .reset(reset),
        .A(A),
        .B(B),
        .select(select),
        .start(start),
        .up(up),
        .down(down),
        .left(left),
        .right(right),
        .player(player),
        .player_health(player_health),
        .sword(sword)
    );

    // Clock generation
    always #20 clk = ~clk; // 25MHz clock

    // Testbench logic
    initial begin
        // Initialize inputs
        clk = 0;
        reset = 1;
        A = 0;
        B = 0;
        select = 0;
        start = 0;
        up = 0;
        down = 0;
        left = 0;
        right = 0;

        // Dump waveforms for GTKWave
        $dumpfile("player_tb.vcd");
        $dumpvars(0, player_tb);

        // Wait for reset
        #40;
        reset = 0;

        // Test 1: Move up
        up = 1; #40; up = 0;
        #40; // Wait for state to update
        
        // Test 2: Move down
        down = 1; #40; down = 0;
        #40; // Wait for state to update
        
        // Test 3: Move left
        left = 1; #40; left = 0;
        #40; // Wait for state to update
        
        // Test 4: Move right
        right = 1; #40; right = 0;
        #40; // Wait for state to update
        
        // Test 5: Attack while facing up
        up = 1; #40; up = 0; 
        A = 1; #40; A = 0;
        #40; // Wait for state to update

        // Test 6: Attack while facing down
        down = 1; #40; down = 0; 
        B = 1; #40; B = 0;
        #40; // Wait for state to update
        
        // Test 7: Move left, then attack
        left = 1; #40; left = 0; 
        A = 1; #40; A = 0;
        #40; // Wait for state to update

        // Test 8: reset the game
        reset = 1; #40; reset = 0;
        #40; // Wait for reset to complete
        
        // Stop simulation
        $stop;   
    end

    // Monitor changes
    initial begin
        $monitor("Time=%0t | Player=%b | Sword=%b | Player Health=%b | Up=%b Down=%b Left=%b Right=%b A=%b B=%b",
        $time, player, sword, player_health, up, down, left, right, A, B);
    end
endmodule

