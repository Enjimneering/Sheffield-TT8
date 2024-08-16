/*

Project: TinyTapeStation
Engineer(s) : James Ashie Kotey
Module: VGA Vertical Pixel Counter

Summary: 

Description =========================================

*/

module Vertical_Counter(
    input               pixel_clk,
    input               reset,
    input               enable,
    output reg [9:0]    v_count_value

);

    parameter V_MAX = 524;

    always @(posedge pixel_clk) begin

        if (reset) begin // RESET PULSE
            v_count_value <= 0;
        end 
    
        else begin  // CLK PULSE

            if (v_count_value >= V_MAX) begin // Next cycle is end of the frame (bottom right)
                v_count_value <= 0;
            end
            
            else begin // increment when enable is set.
                if (enable == 1) begin
                    v_count_value <= v_count_value + 1;
                end
            end

        end 

    
    end
        

endmodule