`timescale 1ns/1ns
`include "anu_rand_num.v"

module rand_numtb;

    // Inputs
    reg clk;
    reg reset;

    // Outputs
    wire [7:0] num;

    // Instantiate the Unit Under Test (UUT)
    rand_num uut (
        .clk(clk), 
        .reset(reset), 
        .num(num)
    );

    // Clock generation (25 MHz = 40 ns period)
    always begin
        #20 clk = ~clk; // Toggle every 20ns, making 40ns period (25 MHz)
    end

    initial begin

        $dumpfile("rand_numtb.vcd");
        $dumpvars(0, rand_numtb);
        
        // Initialize Inputs
        clk = 0;
        reset = 0;

        // Apply reset
        reset = 1;
        #40;  // Keep reset active for 40 ns
        reset = 0;

        // Monitor outputs
        $monitor("Time: %0t | Reset: %b | Num: %b", $time, reset, num);

        // Simulation runs for 500 ns
        #1000;
        $finish;
    end

endmodule
