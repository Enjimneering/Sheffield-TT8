`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/20 13:12:27
// Design Name: 
// Module Name: FrameBufferController_Transition
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


module FrameBufferController_Counter
    #(parameter PRECHECKLEN = 8)(
    input clk,  
    input reset,    

    output reg [3:0]buffer_Counter,
    output reg buffer_Reset
    );

    

    


    always @(posedge clk) begin
        if (reset) begin
            buffer_Counter <= 0;
            buffer_Reset <= 0;
        end else if (buffer_Counter >= PRECHECKLEN)begin
            buffer_Counter <= 0;
            buffer_Reset <= 0;
        end else begin
            buffer_Counter <= buffer_Counter + 1;
            buffer_Reset <= 0;
        end

        if (buffer_Counter == PRECHECKLEN-1) begin
            buffer_Reset <= 1;
        end
    end
endmodule
                