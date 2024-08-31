// `timescale 1ns / 1ps - please don't include timescales in the 


module Snake_Top(
    input clk,
    input reset,
    input [1:0] States,
    input [11:0] OrienAndPositon,

    output reg [95:0] Dragon, // Every 12 bit represent a body segment, Maximum of 8 segments
    output reg [2:0] Tail //Pointer of Dragon's Tail
    );

    //State
    localparam MOVE = 2'b00;
    localparam HEAL = 2'b01;
    localparam HIT = 2'b10;
    localparam IDLE = 2'b11;


    always @(OrienAndPositon, posedge reset) begin
        if (reset == 0) begin
        case(States) 
            MOVE: begin
                Dragon <= Dragon << 12;
                Dragon[11:0] <= OrienAndPositon;
                //Tail <= Tail;
            end
            HEAL: begin
                Dragon <= Dragon << 12;
                Dragon[11:0] <= OrienAndPositon;
                Tail <= Tail + 1;
            end
            HIT: begin
                Dragon <= Dragon << 12;
                Dragon[11:0] <= OrienAndPositon;
                Tail <= Tail - 1;
            end
            IDLE: begin
                //Dragon <= Dragon;
                //Tail <= Tail;
            end
        endcase
        end else begin
            Dragon = {95{1'b0}};
            Tail = {3{1'b0}};
        end

    end

endmodule

