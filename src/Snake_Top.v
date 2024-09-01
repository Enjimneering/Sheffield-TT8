// `timescale 1ns / 1ps - please don't include timescales in the 


module Snake_Top(
    input clk,
    input reset,
    input [1:0] States, // MUST be a PULSE
    input [9:0] OrienAndPositon, 

    output reg [79:0] Dragon, // Every 10 bit represent a body segment, Maximum of 8 segments, a queue
    output reg [2:0] Tail //Pointer of Dragon's Tail, equal to the length of dragon
    );

    //State
    localparam MOVE = 2'b00;
    localparam HEAL = 2'b01;
    localparam HIT = 2'b10;
    localparam IDLE = 2'b11;

    //Body describtion length
    localparam ABODY = 10;


    always @(posedge clk) begin
        
        if (reset == 0) begin
        case(States) 
            MOVE: begin 
                Dragon <= Dragon << ABODY; //Pass each body's position to the next segment
                Dragon[ABODY-1:0] <= OrienAndPositon; //New position enqueue
                //Tail <= Tail;
            end
            HEAL: begin
                Dragon <= Dragon << ABODY;
                Dragon[ABODY-1:0] <= OrienAndPositon;
                Tail <= Tail + 1;
            end
            HIT: begin
                Dragon <= Dragon << ABODY;
                Dragon[ABODY-1:0] <= OrienAndPositon;
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

