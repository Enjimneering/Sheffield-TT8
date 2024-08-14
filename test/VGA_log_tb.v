/* 
    Project: TinyTapeStation
    Author(s):      James Ashie Kotey, Abdulatif Balbi
    Create Date:    10/08/2024
    Module Name:    VGA_Testbench
    Summary:        6 control for 640x480 60Hz VGA n-bit RGB 
    
    Description ==============================================================
    
    The VGA simulator requires a log format of:{time} ns: <HS> <VS> <R> <G> <B>
    <> = bINARY
    {} = decimal

    This testbench provides a simple framework for generating VGA patterns outputs to be tested.
    currently, the input accomodates 6-bit rgb This can be modified/ increased easily. 

    1 CLK Cyclce = 40ns - 25MHz CLK
*/


`timescale 1ns / 1ns
`include "VGA_Top.v"  // reference  to top module not needed in sim

module VGA_Testbench;

    integer output_file;
    integer i;

    reg CLK, RESET;
    reg [15:0] DATA_IN;         
    wire H_SYNC, V_SYNC;
    wire [15:0] RGB_OUT;

    VGA_Top vga (               
    .pixel_clk(CLK),            // IN
    .reset(RESET),              // IN
    .color_data(DATA_IN),       // IN
    .h_sync(H_SYNC),            // OUT
    .v_sync(V_SYNC),            // OUT
    .rgb(RGB_OUT)               // OUT
    );

    // Change bus using these output ports

    //  8-BIT - RRR GGG BB
    wire [2:0] RED = RGB_OUT[7:5];
    wire [2:0] GREEN = RGB_OUT[4:2];
    wire [1:0] BLUE = RGB_OUT[1:0];
    

    initial begin 
    $dumpfile("tb.vcd");
    $dumpvars(0 , VGA_Testbench);

    output_file = $fopen("log.txt","w");  // create log file.

    CLK        = 0;                       // start clk from zero.           
    RESET      = 1;                       // send reset signal.
    DATA_IN    = 'b0000_0000;                // change this to change output color - RRR GGG BB

    
    
    $fdisplay(output_file,"%0t ns: %b %b %b %b %b", $time , H_SYNC, V_SYNC, RED, GREEN, BLUE); // print line to log.
   
    #40 RESET  = 0; // 40ns Clock = 25 MHz
    $fdisplay(output_file,"%0t ns: %b %b %b %b %b", $time , H_SYNC, V_SYNC, RED, GREEN, BLUE); 

    for ( i = 0; i < 419218 ; i = i + 1 ) begin // loop for 1 full frame (800 * 524)
        
        if (i >  419220 /2)
        DATA_IN = 'b1110_0000;
        else
        DATA_IN = 'b1111_1111;
        

        #40 $fdisplay(output_file,"%0t ns: %b %b %b %b %b ", $time, H_SYNC, V_SYNC, RED, GREEN, BLUE);
        #40 $fdisplay(output_file, "%0t ns: %b %b %b %b %b", $time, H_SYNC, V_SYNC, RED, GREEN, BLUE);
    end

    $fclose(output_file);

    $display("Simulation Complete :D");
    $finish();
    end

    always begin // generate 25MHZ clk signal.
       #40  CLK = ~CLK;
    end


endmodule


