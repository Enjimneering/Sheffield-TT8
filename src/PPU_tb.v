/* 
    Project: TinyTapeStation
    Author(s):      James Ashie Kotey
    Create Date:    25/08/2024
    Module Name:    Picture Proccessing Unit (PPU) Output Test
    
   
    
    Description ==============================================================
    
    This Testbench outputs a VGA log file to be used in the VGA Simulator.
    VGA Simulator: https://madlittlemods.github.io/vga-simulator/

*/


`timescale 1ns / 1ns
`include "PPU.v"
`include "simCLK.v"


module tb_PictureProcessingUnit;

    // PPU input

    reg           CLK            = 0 ;
    reg           RESET          = 0 ;

    reg   [13:0]  entity_1       = 14'b11110000000000 ;   // hearts
    reg   [13:0]  entity_2       = 14'b11110000000000 ;   // sword
    reg   [13:0]  entity_3       = 14'b11110000000000 ;   // player
    reg   [13:0]  entity_4       = 14'b11110000000000 ;   // dragon head
    reg   [13:0]  entity_5       = 14'b11110000000000 ; 
    reg   [13:0]  entity_6       = 14'b11110000000000 ;  
    reg   [13:0]  entity_7       = 17'b11110000000000000 ; // hearts
    reg   [13:0]  entity_8_Flip  = 14'b11110000000000 ;
    reg   [13:0]  entity_9_Flip  = 14'b11110000000000 ;
    

    // VGA OUPUT 
    wire   [9:0]  X_PIXEL;
    wire   [9:0]  Y_PIXEL;
    wire          H_SYNC;
    wire          V_SYNC;
    wire          VIDEO_ENABLE;
    wire   [2:0]  RED;
    wire   [2:0]  GREEN;
    wire   [1:0]  BLUE;

   
    clk_wiz_0 divider
    (
        // Clock out ports
        .clk_out_50MHz(system_clk),     // output clk_out_50MHz
        .clk_out_25MHz(pixel_clk),     // output clk_out_25MHz
        // Status and control signals
        .reset(reset), // input reset
         // Clock in ports
        .clk_in(CLK)      // input clk_in
    );


    PictureProcessingUnit ppu (

        // SYSTEM 
        .system_clk(system_clk),  
        .pixel_clk(pixel_clk),
        .reset(RESET),   

        //ENTITY SLOTS 
        .entity_1(entity_1),  
        .entity_2(entity_2),  
        .entity_3(entity_3),  
        .entity_4(entity_4),
        .entity_5(entity_5),
        .entity_6(entity_6),
        .entity_7(entity_7),
        .entity_8_Flip(entity_8_Flip),
        .entity_9_Flip(entity_9_Flip),
        
        // OUTPUT
        .x_pos(X_PIXEL),
        .y_pos(Y_PIXEL),
        .h_sync(H_SYNC),
        .v_sync(V_SYNC),
        
        .video_enable(VIDEO_ENABLE),
        .red(RED),
        .green(GREEN),
        .blue(BLUE)

    );

    // TEST BENCH variables

    integer counter;
    integer output_file;
    integer temp_entity;
    integer temp_id;
    integer count2;
    integer inc;
    integer TOTAL_SCREEN_AREA = 420000;


    initial begin
        // $dumpfile("FBC_tb.vcd");
        $dumpvars();
        output_file = $fopen("PPU_Log.txt", "w"); 
       // $fwrite(output_file,"FBC OUTPUT TEST \n \n");
        
        temp_entity  = 0;
        temp_id      = 0;
        CLK          = 0;


        $fdisplay(output_file,"%0t ns: %b %b %b %b %b", $time , H_SYNC, V_SYNC, RED, GREEN, BLUE);   // print line to log;
        
        RESET        = 1;
        #40 RESET    = 0;

        $fdisplay(output_file,"%0t ns: %b %b %b %b %b", $time , H_SYNC, V_SYNC, RED, GREEN, BLUE);
        
        // loop through a full screen - using the sync unit.
     
       for(counter = 0; counter < TOTAL_SCREEN_AREA ; counter = counter + 1 ) begin
       
      
                        if (VIDEO_ENABLE) begin

                                entity_1 = 14'b0000_00_00000101;

                        end
                        else begin
                        
                                entity_1 = 14'b1111_00_00000000;
                        end

                        // OUTPUT
                        #40;
                        
                        $fdisplay(output_file,"%0t ns: %b %b %b %b %b", $time , H_SYNC, V_SYNC, RED, GREEN, BLUE);
                        $display("%0t ns: %b %b %b %b %b", $time , H_SYNC, V_SYNC, RED, GREEN, BLUE);

            end
     
        
                $fclose(output_file);
                $finish;     

    end
        
                

    always begin
        #5 CLK = ~CLK; // 100 MHz system CLK
    end   


endmodule
