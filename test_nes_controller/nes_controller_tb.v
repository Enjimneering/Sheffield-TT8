`timescale 1ns / 1ps

module nes_controller_tb;

    // Inputs
    reg clk;
    reg reset;
    reg data;
    reg clk_timing;

    // Outputs
    wire latch;
    wire nes_clk;
    wire A, B, select, start, up, down, left, right;

    // Instantiate the Unit Under Test (UUT)
    nes_controller uut (
        .clk(clk), 
        .reset(reset), 
        .data(data), 
        .latch(latch), 
        .nes_clk(nes_clk), 
        .A(A), 
        .B(B), 
        .select(select), 
        .start(start), 
        .up(up), 
        .down(down), 
        .left(left), 
        .right(right)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 50MHz clock
    end

    // Function to display button states
    task display_button_states;
        input [31:0] cycle;
        begin
            $display("--------------------");
            $display("Time=%0t ns, Cycle %0d:", $time, cycle);
            if (A) $display("A pressed");
            if (B) $display("B pressed");
            if (select) $display("Select pressed");
            if (start) $display("Start pressed");
            if (up) $display("Up pressed");
            if (down) $display("Down pressed");
            if (left) $display("Left pressed");
            if (right) $display("Right pressed");
            if (!A && !B && !select && !start && !up && !down && !left && !right)
                $display("No buttons pressed");
            $display("--------------------");
        end
    endtask

    // Test scenario
    initial begin
        // Initialize Inputs
        reset = 1;
        data = 0;

        // Wait for global reset
        #100;
        reset = 0;

        // Simulate button states
               data = 1; // A 
        #18000 data = 1; // B 
        #12000 data = 1; // Select 
        #12000 data = 0; // Start 
        #12000 data = 1; // Up 
        #12000 data = 1; // Down 
        #12000 data = 1; // Left 
        #12000 data = 1; // Right 
        #12000 display_button_states(1);

        // Cycle 2
               data = 1; // A 
        #18000 data = 1; // B 
        #12000 data = 1; // Select 
        #12000 data = 1; // Start 
        #12000 data = 1; // Up 
        #12000 data = 1; // Down 
        #12000 data = 1; // Left 
        #12000 data = 1; // Right 
        #12000 display_button_states(2);

        // Cycle 3
               data = 1; // A 
        #18000 data = 1; // B 
        #12000 data = 1; // Select 
        #12000 data = 1; // Start 
        #12000 data = 1; // Up 
        #12000 data = 1; // Down 
        #12000 data = 1; // Left 
        #12000 data = 1; // Right 
        #12000 display_button_states(3);

        // Run for a while longer
        #50000;

        // End simulation
        $finish;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, nes_controller_tb);
    end

endmodule