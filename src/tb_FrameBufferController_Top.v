`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/21 15:25:00
// Design Name: 
// Module Name: tb_FrameBufferController_Top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale  1ns / 1ps

module tb_FrameBufferController_Top;

// FrameBufferController_Top Parameters
parameter PERIOD  = 10;


// FrameBufferController_Top Inputs
reg   clk                                  = 0 ;
reg   reset                                = 0 ;
reg   [13:0]  entity_1                     = 14'b00000001000001 ;
reg   [13:0]  entity_2                     = 14'b10000000110000 ;
reg   [13:0]  entity_3                     = 14'b00010011000100 ;
reg   [13:0]  entity_4                     = 14'b11110000000000 ;
reg   [13:0]  entity_5                     = 14'b11110000000000 ;
reg   [13:0]  entity_6                     = 14'b11110000010000 ;
reg   [17:0]  entity_7_Array               = 18'b111110000000000011 ;
reg   [13:0]  entity_8_Flip                = 14'b11110000000000 ;
reg   [13:0]  entity_9_Flip                = 14'b11110000000000 ;
reg   [9:0]  counter_V                     = 0 ;
reg   [9:0]  counter_H                     = 0 ;

// FrameBufferController_Top Outputs
wire colour                               ;
wire [8:0] buffer_O;


initial
begin
    
    forever #1  clk=~clk;
end

FrameBufferController_Top  u_FrameBufferController_Top (
    .clk                     ( clk                   ),
    .reset                   ( reset                 ),
    .entity_1                ( entity_1       [13:0] ),
    .entity_2                ( entity_2       [13:0] ),
    .entity_3                ( entity_3       [13:0] ),
    .entity_4                ( entity_4       [13:0] ),
    .entity_5                ( entity_5       [13:0] ),
    .entity_6                ( entity_6       [13:0] ),
    .entity_7_Array                ( entity_7_Array       [17:0] ),
    .entity_8_Flip           ( entity_8_Flip  [13:0] ),
    .entity_9_Flip           ( entity_9_Flip  [13:0] ),
    .counter_V               ( counter_V      [9:0]  ),
    .counter_H               ( counter_H      [9:0]  ),

    .colour                  ( colour              ),
    .buffer_O                (buffer_O [8:0])
);
integer i;
integer a;
integer    output_file;
integer count;
integer count2;

initial
begin
    $dumpfile("Full_tb.vcd");
    $dumpvars(0 , tb_FrameBufferController_Top);

    output_file = $fopen("Full_OUTPUT.txt", "w"); 

    
    $fwrite(output_file,"ROM OUTPUT TEST \n \n");

    
    clk = 0;
    reset =0;
    count = 0;
    count2=0;
    counter_V = 0;
    counter_H = 0;

    #1
    reset = 1;
    #1
    reset =0;
    #1
    
    for (count2 = 0;count2<480; count2 = count2 +1)begin
        
        #2 counter_V = count2;
        for (count = 0;count<640; count = count +1)begin
            
            // entity_3 = count;
            
            #2 counter_H = count;
            
            
            
            if (colour)begin
                $fwrite(output_file,"X");
            end else begin
                $fwrite(output_file,".");
            end
            
            
            // count = 10'b1111111111&((i/40*16+a/40)+512);
            // if (count == 40)begin
            //     count2 = count2+1;
            //     count = 0;
            // end
            
        end
        
        $fwrite(output_file," \n ");
    end
    #2
    $fclose(output_file);

    $finish;
end



endmodule
