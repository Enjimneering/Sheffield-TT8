`timescale 1ns / 1ns
`include "VGA_top.v"

module VGA_Testbench;

integer output_file;
integer i;

reg CLK, RESET;
reg [5:0] DATA_IN;
wire H_SYNC, V_SYNC;
wire [5:0] RGB_OUT;

   VGA_Top dut (
    .pixel_clk(CLK),
    .reset(RESET),
    .color_data(DATA_IN),
    .h_sync(H_SYNC),
    .v_sync(V_SYNC),
    .rgb(RGB_OUT)
);

    initial begin 
    $dumpfile("tb.vcd");
    $dumpvars(0 , VGA_Testbench);

    output_file = $fopen("out.txt","w");

    CLK        = 0;
    RESET      = 1;
    DATA_IN    = 'b110000;
    
    $fdisplay(output_file,"%0t ns: %b %b %b %b %b", $time , H_SYNC, V_SYNC, RGB[5:4], RGB[3:2], RGB[1:0]);
    #40 RESET  = 0; // 40ns Clock = 
    $fdisplay(output_file,"%0t ns: %b %b %b %b %b", $time , H_SYNC, V_SYNC, RGB[5:4], RGB[3:2], RGB[1:0]); 


    for ( i = 0; i < 419200 ; i = i + 1 ) begin // 1 Full Frame
        #40 $fdisplay(output_file,"%0t ns: %b %b %b %b %b ", $time, H_SYNC, V_SYNC, RGB[5:4], RGB[3:2], RGB[1:0]);
    end

    $fclose(output_file);

    end

    always begin
       #40  CLK = ~CLK;
    end

   


endmodule


