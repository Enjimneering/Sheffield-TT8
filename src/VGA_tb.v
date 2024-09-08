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

    VGA Simulator Link - https://madlittlemods.github.io/vga-simulator/
*/


`timescale 1ns/1ns
`include "VGA_Top.v"  
`include "simCLK.v"

module VGA_Testbench;

    integer output_file;
    integer i;

    reg CLK, RESET;
    reg [11:0] DATA_IN;         
    wire H_SYNC, V_SYNC;
    wire [11:0] RGB_OUT;

    
    clk_wiz_0 clock_divider
    (

        .clk_in(CLK), 
        .reset(RESET),
        .clk_out_0(pixelCLK),
        .clk_out_1()

    );
    

    VGA_Top vga (              
        .pixel_clk(pixelCLK),           
        .reset(RESET),             
        .color_data(DATA_IN),  
        .h_sync(H_SYNC),           
        .v_sync(V_SYNC),     
        .rgb_out(RGB_OUT)            
    );

    
    // Change bus using these output ports

    //  12-BIT - RRRR GGGG BBBB
 
    wire [3:0] RED   =  RGB_OUT[11:8];
    wire [3:0] GREEN =  RGB_OUT[7:4];
    wire [3:0] BLUE  =  RGB_OUT[3:0];
    

    initial begin 

    $dumpfile("vga.vcd");
    $dumpvars(0 , VGA_Testbench);

    output_file = $fopen("VGA_test.txt","w");  // create log file.

    CLK        = 0;                       // start clk from zero.           
    RESET      = 1;                       // send reset signal.
    DATA_IN    = 'b0000_0000_0000;        // change this to change output color - RRR GGG BB

    
    
    $fdisplay(output_file,"%0t ns: %b %b %b %b %b", $time , H_SYNC, V_SYNC, RED, GREEN, BLUE); // print line to log.
   
    #20 RESET  = 0; // 40ns Clock = 25 MHz

    $fdisplay(output_file,"%0t ns: %b %b %b %b %b", $time , H_SYNC, V_SYNC, RED, GREEN, BLUE); 

    for ( i = 0; i < 419218 ; i = i + 1 ) begin // loop for 1 full frame (800 * 524)
        
        if (i >  419220 /2)                     // poland
        DATA_IN = 12'b1111_0000_0000;
        else
        DATA_IN = 12'b1111_1111_1111;

        #40 $display("%0t ns: %b %b %b %b %b", $time , H_SYNC, V_SYNC, RED, GREEN, BLUE); 
        $fdisplay(output_file, "%0t ns: %b %b %b %b %b", $time , H_SYNC, V_SYNC, RED, GREEN, BLUE); 
    end

    $fclose(output_file);

    $display("Simulation Complete :D");
    $finish();
    end

    always begin // generate 100MHZ clk signal.
       #5  CLK = ~CLK;
    end


endmodule


