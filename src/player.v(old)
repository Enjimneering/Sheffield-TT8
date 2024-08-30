// notes 
/*
reset: Resets the FSM to the IDLE state.
dir: A 2-bit signal representing the directional input.
00 = down.
01 = Left.
10 = Right.
11 = Up.
attack: A signal indicating that the attack button is pressed.
Outputs:

state: A 2-bit signal representing the current state of the game.
00 = Idle.
01 = Moving.
10 = Attacking.
State Encoding:

IDLE is encoded as 2'b00.
MOVING is encoded as 2'b01.
ATTACKING is encoded as 2'b10.
FSM Behavior:

In the IDLE state, the FSM transitions to MOVING if any direction is pressed or to ATTACKING if the attack button is pressed.
In the MOVING state, the FSM transitions back to IDLE if no direction is pressed or to ATTACKING if the attack button is pressed.
In the ATTACKING state, the FSM automatically returns to IDLE after the attack.

*/


module player (
    input wire clk,          // Clock signal
    input wire reset,        // Reset signal
    input wire [1:0] dir,    // Direction input: 00 = down, 01 = Left, 10 = Right, 11 = Up
    input wire attack,       // Attack input
    output reg [1:0] state   // State output: 00 = Idle, 01 = Moving, 10 = Attacking
);

    // State encoding
    localparam IDLE     = 2'b00;
    localparam MOVING   = 2'b01;
    localparam ATTACKING = 2'b10;

    reg [1:0] next_state;  // Next state variable

    // Sequential logic: State transition
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // Combinational logic: Next state logic
    always @(*) begin
        case (state)
            IDLE: begin
                if (dir != 2'b00) begin
                    next_state = MOVING; // Move if a direction is pressed
                end else if (attack) begin
                    next_state = ATTACKING; // Attack if the attack button is pressed
                end else begin
                    next_state = IDLE;
                end
            end

            MOVING: begin
                if (dir == 2'b00) begin
                    next_state = IDLE; // Return to idle if no direction is pressed
                end else if (attack) begin
                    next_state = ATTACKING; // Attack while moving
                end else begin
                    next_state = MOVING; // Continue moving
                end
            end

            ATTACKING: begin
                next_state = IDLE; // Return to idle after attacking
            end

            default: begin
                next_state = IDLE; // Default state
            end
        endcase
    end

endmodule