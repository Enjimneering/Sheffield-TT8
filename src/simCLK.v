module clk_wiz_0 (

    input wire clk_in,
    input wire reset,

    output reg clk_out_25MHz,   
    output reg clk_out_50MHz  
    
);

    localparam DIV_CLK_0 = 4; //  25MHz
    localparam DIV_CLK_1 = 2; //  50MHz
    
    reg[2:0] counter_0;
    reg[2:0] counter_1;
    
    initial begin
        clk_out_25MHz = 0;
        clk_out_50MHz = 0;

        counter_0 = 0;
        counter_1 = 0;
    end

    always @(clk_in) begin
     
        if (reset) begin
            counter_0 <= 0;
            counter_1 <= 0;
            clk_out_25MHz <= 0;
            clk_out_50MHz <= 0;
        end

        else begin

            if (counter_0 == DIV_CLK_0) begin
                counter_0 <= 1;
                clk_out_25MHz <= ~clk_out_25MHz;
            end

            else begin
                counter_0 <= counter_0 + 1;
            end


            if (counter_1 == DIV_CLK_1) begin
                counter_1 <= 1;
                clk_out_50MHz <= ~clk_out_50MHz;
            end
        
            else begin
                counter_1 <= counter_1 + 1;
            end

        end

    end

endmodule

