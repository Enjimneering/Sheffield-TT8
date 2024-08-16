module Vertical_Counter(
    input pixel_clk,
    input reset,
    input enable,
    
    output reg [9:0] v_count_value

);

    parameter V_MAX = 524;

    always @(posedge pixel_clk or reset) begin
    if (reset) begin // RESET PULSE
        v_count_value <= 0;
    end 
    
    else begin// Normal CLK cycle

        if ( v_count_value >= V_MAX) begin // Next Cycle is end of scanline
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