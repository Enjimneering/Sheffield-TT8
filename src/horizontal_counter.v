
module Horizontal_Counter(
    input pixel_clk,
    input reset,
    output reg [9:0] h_count_value,
    output reg enable_v_counter
);
    
    parameter H_MAX = 799;
    
    always @(posedge pixel_clk or reset) begin
    if (reset) begin // RESET PULSE
        h_count_value <= 0;
    end 
    
    else begin// Normal CLK cycle

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