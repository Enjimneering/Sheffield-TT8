/*

Project: TinyTapeStation
Engineer(s) : James Ashie Kotey
Module: VGA Horizontal Pixel Counter

Summary: Moduluo 800 counter that with active high reset. Used to count the horizontal position of the current pixel in the VGA Sync Unit.

Description =========================================

*/

module Horizontal_Counter(
    input               pixel_clk,
    input               reset,
    output reg          enable_v_counter,
    output reg [9:0]    h_count_value
);
    
    parameter H_MAX = 799;

    initial begin
        h_count_value = 0;
        enable_v_counter = 0;
    end

    // CAN only use a single event as a condition in an always block- otherwise, it won't synthesize.
    always @(posedge pixel_clk) begin
    
        if (reset) begin // RESET PULSE
            h_count_value <= 0;
        end 
        
        else begin  //CLK PULSE

            if ( h_count_value >= H_MAX) begin // Next Cycle is end of scanline
                h_count_value <= 0;
                enable_v_counter <= 1;
            end
            
            else begin // normal operation
                enable_v_counter <= 0;
                h_count_value <= h_count_value + 1;
            end

        end 

    end
        

endmodule