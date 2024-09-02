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

module tb_PictureProcessingUnit;

    // PPU input

    reg           CLK            = 0 ;
    reg           CLK_25MHZ      =  0;
    reg           RESET          = 0 ;

    reg   [13:0]  entity_1       = 14'b11110000000000 ; // hearts
    reg   [13:0]  entity_2       = 14'b11110000000000 ; // sword
    reg   [13:0]  entity_3       = 14'b11110000000000 ; // player
    reg   [13:0]  entity_4       = 14'b11110000000000 ; // dragon head
    reg   [13:0]  entity_5       = 14'b11110000000000 ; // dragon body
    reg   [13:0]  entity_6       = 14'b11110000000000 ;  
    reg   [13:0]  entity_7       = 14'b11110000000000 ;
    reg   [13:0]  entity_8_Flip  = 14'b11110000000000 ;
    reg   [13:0]  entity_9_Flip  = 14'b11110000000000 ;
    

    // VGA OUPUT 
    wire   [9:0]  X_PIXEL;
    wire   [9:0]  Y_PIXEL;
    wire          H_SYNC;
    wire          V_SYNC;
    wire          VIDEO_ENABLE;
    wire   [3:0]  RED;
    wire   [3:0]  GREEN;
    wire   [3:0]  BLUE;


    PictureProcessingUnit ppu (
        // INPUTS
        
        // SYSTEM 
        .clk_100MHz(CLK),  
        .reset(RESET),   

        //ENTITY SLOTS 
        .entity_1(entity_1),  
        .video_enable(VIDEO_ENABLE),
        
        .x_pos(X_PIXEL),
        .y_pos(Y_PIXEL),

        // OUTPUT
        .h_sync(H_SYNC),
        .v_sync(V_SYNC),
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
        output_file = $fopen("newpu.txt", "w"); 
       // $fwrite(output_file,"FBC OUTPUT TEST \n \n");
        
        temp_entity  = 0;
        temp_id      = 0;
        CLK          = 0;


    //    $fdisplay(output_file,"%0t ns: %b %b %b %b %b", $time , H_SYNC, V_SYNC, RED, GREEN, BLUE);   // print line to log;
        
        RESET        = 1;
        #40 RESET    = 0;

       // $fdisplay(output_file,"%0t ns: %b %b %b %b %b", $time , H_SYNC, V_SYNC, RED, GREEN, BLUE);
        
        // loop through a full screen - using the sync unit.

        entity_1 = 14'b0000_00_0000_0000;
        
       for(counter = 0; counter < TOTAL_SCREEN_AREA ; counter = counter + 1 ) begin
    


    //   #40   $fdisplay(output_file,"%0t ns: %b %b %b %b %b", $time , H_SYNC, V_SYNC, RED, GREEN, BLUE);

            end
     
        
                $fclose(output_file);
                $finish;     

    end
        
                

    always begin
        #5 CLK = ~CLK; // 100 MHz CLK
    end   

    
    always begin
        #20 CLK_25MHZ = ~CLK_25MHZ; // 100 MHz CLK
    end   


endmodule
