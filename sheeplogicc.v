
module sheepLogic (
    input clk,
    input reset,
    input wire read_enable, // When high, generate random position for the sheep
    input wire [7:0] dragon_pos, // using as seed value to ensure no overlap
    input wire [7:0] player_pos, // using as seed value to ensure no overlap
    output reg [7:0] sheep_pos, // 8-bit position (4 bits for X, 4 bits for Y)
    output reg [3:0] sheep_visible
);

wire [7:0] random_value; // 8-bit random value: first 4 bits -> X, last 4 bits -> Y

// Instantiate the random number generator with seeded initial value
rand_num rng (
    .clk(clk),
    .reset(reset),
    .seed((player_pos ^ dragon_pos) + 1), // Seed with XOR of player and dragon positions +1
    .rdm_num(random_value)               // Random value generated by the RNG
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        // Reset condition: sheep is not visible and position off-screen
        sheep_visible <= 0;
        sheep_pos <= 8'b0; // Initialize to 0 during reset
    end else if (read_enable) begin
        // Generate a valid position
        sheep_visible <= 1; // Sheep becomes visible
        sheep_pos <= {random_value[7:4], random_value[3:0]}; // Assign 4-bit X and Y positions
    end
end

endmodule

module rand_num (
    input wire clk,
    input wire reset,
    input wire [7:0] seed, // Seed input for initializing randomness
    output reg [7:0] rdm_num
);

reg [2:0] counter;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        rdm_num <= seed;  // Initialize with seed during reset
        counter <= 7;     // Reset counter
    end else if (counter > 0) begin
        // Shift and apply feedback for randomness
        rdm_num[6:0] <= rdm_num[7:1];  // Shift all bits
        rdm_num[7] <= rdm_num[7] ^ rdm_num[5] ^ rdm_num[4] ^ rdm_num[3]; // Feedback XOR for randomness

        // Ensure random values fall within valid screen range (4-bit X and Y coordinates)
        rdm_num <= {rdm_num[7:4] % 16, rdm_num[3:0] % 16}; // Modulo operation to limit values

        counter <= counter - 1;        // Decrement counter
    end else begin
        counter <= 7;  // Reset counter for next random number
    end
end

endmodule




