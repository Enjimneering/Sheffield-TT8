module clk_wiz_0(

    input wire clk_in,
    input wire reset,

    output reg clk_out
    
);

reg[2:0] counter;

     always @(clk_in) begin
     if (reset) begin
        counter <= 0;
        clk_out <= 0;
     end

     else begin


        if (counter == 4) begin
            counter <= 1;
            clk_out =  ~clk_out;
        end
        
        else
            counter <= counter + 1;
        

     end


    end
endmodule




