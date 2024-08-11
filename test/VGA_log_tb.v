//////////////////////////////////////////////////////////////////////////////
/* 
     Project: TinyTapeStation
    Author(s):      James Ashie Kotey, Abdulatif Balbi
    Create Date:    10/08/2024
    Module Name:    VGA_Testbench
    Summary:        6 control for 640x480 60Hz VGA 6-bit RGB 
    
    Description ==============================================================
    
    The VGA simulator requires a log format of:{time} ns: <HS> <VS> <R> <G> <B>
    <> = bINARY
    {} = decimal

    1 CLK Cyclce = 40ns - 25MHz CLK
*/
//////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ns
`include "VGA_top.v"  // reference  to top module not needed in sim

module VGA_Testbench;

integer output_file;
integer i;

reg CLK, RESET;
reg [5:0] DATA_IN;
wire H_SYNC, V_SYNC;
wire [5:0] RGB_OUT;

    VGA_Top vga (              // TGA TOP module needs these ports
    .pixel_clk(CLK),            // IN
    .reset(RESET),              // IN
    .color_data(DATA_IN),       // IN
    .h_sync(H_SYNC),            // OUT
    .v_sync(V_SYNC),            // OUT
    .rgb(RGB_OUT)               // OUT
);


    initial begin 
    $dumpfile("tb.vcd");
    $dumpvars(0 , VGA_Testbench);

    output_file = $fopen("log.txt","w");  // create log file.

    CLK        = 0;                       // start clk from zero.           
    RESET      = 1;                       // send reset signal.
    DATA_IN    = 'b110000;                // change this to change output color - RR GG BB
    
    $fdisplay(output_file,"%0t ns: %b %b %b %b %b", $time , H_SYNC, V_SYNC, RGB[5:4], RGB[3:2], RGB[1:0]); // print line to log.
    #40 RESET  = 0; // 40ns Clock = 25 MHz
    $fdisplay(output_file,"%0t ns: %b %b %b %b %b", $time , H_SYNC, V_SYNC, RGB[5:4], RGB[3:2], RGB[1:0]); 


    for ( i = 0; i < 419200 ; i = i + 1 ) begin // loop for 1 full frame (800 * 524)
        #40 $fdisplay(output_file,"%0t ns: %b %b %b %b %b ", $time, H_SYNC, V_SYNC, RGB[5:4], RGB[3:2], RGB[1:0]);
    end

    $fclose(output_file);
    $display("Simulation Complete :D");

    end

    always begin // generate 25MHZ clk signal.
       #40  CLK = ~CLK;
    end

   


endmodule


