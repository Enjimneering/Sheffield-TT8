module dragon (
    input wire clk,
    input wire rst,
    input wire player_near,
    input wire sheep_near,
    input wire ate_sheep,
    output reg [1:0] state,
    output reg [1:0] next_state
);

    // State encoding
    localparam MOVE_TO_PLAYER = 2'b00;
    localparam MOVE_TO_SHEEP = 2'b01;
    localparam GROW = 2'b10;

    // State register
    reg [1:0] current_state;

    // FSM state transitions
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= MOVE_TO_PLAYER; // or MOVE_TO_APPLE based on initial preference
        end else begin
            current_state <= next_state;
        end
    end

    // Next state logic
    always @(*) begin
        case (current_state)
            MOVE_TO_PLAYER: begin
                if (ate_apple) begin
                    next_state = GROW;
                end else if (apple_near) begin
                    next_state = MOVE_TO_SHEEP;
                end else begin
                    next_state = MOVE_TO_PLAYER;
                end
            end

            MOVE_TO_SHEEP: begin
                if (ate_apple) begin
                    next_state = GROW;
                end else if (player_near) begin
                    next_state = MOVE_TO_SHEEP;
                end else begin
                    next_state = MOVE_TO_SHEEP;
                end
            end

            GROW: begin
                // Assume growth completes quickly and transition to the next target
                next_state = player_near ? MOVE_TO_PLAYER : apple_near ? MOVE_TO_APPLE : MOVE_TO_PLAYER;
            end

            default: next_state = MOVE_TO_PLAYER; // Default case if something unexpected happens
        endcase
    end

    // Output assignments based on state (not used in this basic example)
    always @(*) begin
        case (current_state)
            MOVE_TO_PLAYER: /* add Output for the dragon to move towards player */;
            MOVE_TO_APPLE: /* add Output for the dragon to move towards sheep */;
            GROW: /* dragon size increase */;
            default: /* Default output which will be output*/;
        endcase
    end

endmodule
