module rand_num (
    input wire clk,
    input wire reset,
    output reg [7:0] num
);

reg [2:0] counter;

initial begin
    num = 8'b10000000; // Initial state
    counter = 7;       // Set counter to 7 to control shifts
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        num = 8'b10000000;  // Reset to the initial state
        counter = 7;
    end else if (counter > 1) begin
        // Shift and apply feedback for randomness
        num[6:0] <= num[7:1];  // Shift all bits
        num[7] <= num[7] ^ num[5] ^ num[4] ^ num[3];  // Feedback XOR for randomness
        counter <= counter - 1;
    end else if (counter == 1) begin
        counter <= 7;  // Wrap around the counter
    end
end

endmodule
