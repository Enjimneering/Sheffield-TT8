// iverilog -o dragon_tb.vvp dragon_tb.v

`timescale 1ns/1ns
`include "DragonHead.v"

module dragon_tb;

    // Testbench signals

    integer output_file; // used later to print 

    reg         frame_clk = 0;

    reg         rst = 0;

    reg [7:0]   player_location = 0;
    reg [7:0]   sheep_location = 0;
    
    reg [7:0]   dragon_head_location = 0;
    reg [1:0]   dragon_head_direction = 0;
    reg [3:0]   dragon_body_length = 0;
    
    wire [7:0]  next_dragon_head_location ;
    wire [1:0]  next_dragon_head_direction ;
    wire [3:0]  next_dragon_body_length ;
    wire [1:0]  behaviour_state ;

    // Instantiate the dragon module
    DragonHead uut (
        .frame_clk(frame_clk),
        .rst(rst),
        .player_location(player_location),
        .sheep_location(sheep_location),
        .dragon_head_location(dragon_head_location),
        .dragon_head_direction(dragon_head_direction),
        .dragon_body_length(dragon_body_length),
        .next_dragon_head_location(next_dragon_head_location),
        .next_dragon_head_direction(next_dragon_head_direction),
        .next_dragon_body_length(next_dragon_body_length),
        .behaviour_state(behaviour_state)
    );

    // Clock generation
    always #5 frame_clk = ~frame_clk;

    // Testbench logic
    initial begin
        // Dump waveforms for GTKWave
        $dumpfile("dragon_tb.vcd");
        $dumpvars(0, dragon_tb);

        output_file = $fopen("dragonStateOutput.txt", "w");  

        // Initialize signals
        rst = 1;
        player_location = 8'b0000_1000; // Player at (x=0, y=8)
        sheep_location = 8'b1111_0000; // Sheep at (x=15, y=0)
        dragon_head_location = 8'b0001_0000; // Dragon at (x=1, y=0)
        dragon_head_direction = 3'b000; // Direction: UP
        dragon_body_length = 4'd3; // Length: 3

        // wait for reset
        #10;
        rst = 0;
        #10;
        
        // Test Case 1: Contest state
        player_location = 8'b0001_0000; // Player at (x=1, y=0)
        sheep_location = 8'b1111_0000; // Sheep at (x=15, y=0)
        dragon_head_location = 8'b0001_0000; // Dragon at (x=1, y=0)
        #40;

        // Test Case 2: Retreat state
        uut.dragon_hurt = 1;
        player_location = 8'b0000_0000; // Player at (x=0, y=0)
        sheep_location = 8'b1111_1111;; // Sheep at (x=16, y=16)
        dragon_head_location = 8'b0010_0000; // Dragon at (x=2, y=0)
        #40;

        // Test Case 3: Scatter state
        uut.dragon_win = 1;
        player_location = 8'b0000_0000;
        sheep_location = 8'b0000_0000;
        dragon_head_location = 8'b0000_0000;
        #40;

        // Test Case 4: Dead state
        uut.dragon_hurt = 1;
        uut.game_over = 1;
        player_location = 8'b0000_0000;
        sheep_location = 8'b1111_1111;
        dragon_head_location = 8'b0000_0000;
        #40;

        // Stop simulation
        $stop;
        $fclose(output_file);
    end

    // Monitor changes
    initial begin
        $monitor("Time=%0t | Player Location=%b | Sheep Location=%b | Dragon Head Location=%b | Dragon Head Direction=%b | Behaviour State=%b",
        $time, player_location, sheep_location, dragon_head_location, dragon_head_direction, behaviour_state);
    end

    initial begin
    $monitor("Time=%0t | Behaviour State=%b | Dragon Hurt=%b | Dragon Win=%b | Game Over=%b",
    $time, behaviour_state, uut.dragon_hurt, uut.dragon_win, uut.game_over);
end


    always begin
        #40 $fdisplay(output_file, "Time=%0t | Player Location=%b | Sheep Location=%b | Dragon Head Location=%b | Dragon Head Direction=%b | Behaviour State=%b |  Dragon Hurt=%b | Dragon Win=%b | Game Over=%b |",
        $time, player_location, sheep_location, dragon_head_location, dragon_head_direction, behaviour_state, uut.dragon_hurt, uut.dragon_win, uut.game_over);
    end


endmodule
