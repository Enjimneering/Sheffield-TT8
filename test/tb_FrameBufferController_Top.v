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
reg   [13:0]  entity_1                     = 14'b11110000000000 ;
reg   [13:0]  entity_2                     = 14'b11110000000000 ;
reg   [13:0]  entity_3                     = 14'b11110000000000 ;
reg   [13:0]  entity_4                     = 14'b11110000000000 ;
reg   [13:0]  entity_5                     = 14'b11110000000000 ;
reg   [13:0]  entity_6                     = 14'b11110000000000 ;
reg   [13:0]  entity_7                     = 14'b11110000000000 ;
reg   [13:0]  entity_8_Flip                = 14'b11110000000000 ;
reg   [13:0]  entity_9_Flip                = 14'b11110000000000 ;
reg   [9:0]  counter_V                     = 0 ;
reg   [9:0]  counter_H                     = 0 ;

// FrameBufferController_Top Outputs
wire  colour                               ;


initial
begin
    #1
    clk = ~clk;
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
    .entity_7                ( entity_7       [13:0] ),
    .entity_8_Flip           ( entity_8_Flip  [13:0] ),
    .entity_9_Flip           ( entity_9_Flip  [13:0] ),
    .counter_V               ( counter_V      [9:0]  ),
    .counter_H               ( counter_H      [9:0]  ),

    .colour                  ( colour                )
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

    #1
    reset =0;
    count = 0;
    count2=0;
    for(i = 0;i <480; i = i+1)begin
        
        for(a = 0; a < 640; a = a+1)begin
            #1
            entity_1 = count;
            if (colour)begin
                $fwrite(output_file,"X");
            end else begin
                $fwrite(output_file,".");
            end
            counter_H = a;
            
            count = 10'b1111111111&((i/40*16+a/40)+512);
            // if (count == 40)begin
            //     count2 = count2+1;
            //     count = 0;
            // end
        end
        counter_V = i;
        $fwrite(output_file," \n ");
    end
    $fclose(output_file);

    $finish;
end

endmodule
