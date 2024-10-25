`timescale 1ns / 1ps


module Snake_Top(
    input clk,
    input reset,
    input vsync,
    input [1:0] States, // MUST be a PULSE
    input [9:0] OrienAndPositon, 
    input [5:0] movement_counter,

    output reg [9:0] Dragon_1, // Every 10 bit represent a body segment, Maximum of 8 segments, a queue
    output reg [9:0] Dragon_2,
    output reg [9:0] Dragon_3,
    output reg [9:0] Dragon_4,
    output reg [9:0] Dragon_5,
    output reg [9:0] Dragon_6,
    output reg [9:0] Dragon_7,

    output reg [6:0] Display_en
    );

localparam MOVE = 2'b00;
localparam HEAL = 2'b01;
localparam HIT = 2'b10;
localparam IDLE = 2'b11;

always @(posedge vsync or posedge reset)begin
    if (~reset)begin
        if(movement_counter < 6'b10)begin
            Dragon_1 <= OrienAndPositon;
            Dragon_2 <= Dragon_1;
            Dragon_3 <= Dragon_2;
            Dragon_4 <= Dragon_3;
            Dragon_5 <= Dragon_4;
            Dragon_6 <= Dragon_5;
            Dragon_7 <= Dragon_6;
        end
    end else begin
        Dragon_1 <= 0;
        Dragon_2 <= 0;
        Dragon_3 <= 0;
        Dragon_4 <= 0;
        Dragon_5 <= 0;
        Dragon_6 <= 0;
        Dragon_7 <= 0;
    end
end

always @(posedge clk)begin
    if(~reset)begin
        case(States) 
            MOVE: begin
                Display_en <= Display_en;
            end
            HEAL: begin
                Display_en <= (Display_en << 1) | 1'b1;
            end
            HIT: begin
                Display_en <= Display_en >> 1;
            end
            IDLE: begin
                Display_en <= Display_en;
            end
        endcase
    end else begin
        Display_en <= 0;
    end
end



























// //State
// localparam MOVE = 2'b00;
// localparam HEAL = 2'b01;
// localparam HIT = 2'b10;
// localparam IDLE = 2'b11;

// //Body describtion length
// localparam MAX = 7;

// reg [2:0] Head;
// reg [2:0] Tail;
// reg [9:0] Dragon [8:0];

// always @(posedge clk ) begin
//     if (reset == 0) begin

//         case(States) 
//             MOVE: begin
//                 Head <= Head + 1;
//                 Tail <= Tail + 1;
//                 Dragon[Head][9:0] <= OrienAndPositon;
//                 Display_en[Head] <= 0;
//                 Display_en[Tail] <= 1;
//             end
//             HEAL: begin
//                 if(Tail == Head + 1 && States == HEAL)begin
//                     Head <= Head + 1;
//                     Tail <= Tail + 1;
//                     Display_en[Head] <= 0;
//                     Display_en[Tail] <= 1;
//                 end else begin
//                     Head <= Head + 1;
//                     Display_en[Head] <= 0;
//                 end
//                 Dragon[Head][9:0] <= OrienAndPositon;
//             end
//             HIT: begin
//                 if (Tail != Head)begin
//                     Tail <= Tail + 1;
//                     Display_en[Tail] <= 1;
//                 end
//             end
//             IDLE: begin
//                 Head <= Head;
//                 Tail <= Tail;
//             end
//         endcase

//     end else begin
//         Dragon[0] <= 0;
//         Dragon[1] <= 0;
//         Dragon[2] <= 0;
//         Dragon[3] <= 0;
//         Dragon[4] <= 0;
//         Dragon[5] <= 0;
//         Dragon[6] <= 0;
//         Dragon[7] <= 0;
//         Tail <= 3'b000;
//         Head <= 3'b000;
//         Display_en <= 8'b11111111;
//     end
// end

// assign Dragon_Wire[9:0] = Dragon[0][9:0];
// assign Dragon_Wire[19:10] = Dragon[1][9:0];
// assign Dragon_Wire[29:20] = Dragon[2][9:0];
// assign Dragon_Wire[39:30] = Dragon[3][9:0];
// assign Dragon_Wire[49:40] = Dragon[4][9:0];
// assign Dragon_Wire[59:50] = Dragon[5][9:0];
// assign Dragon_Wire[69:60] = Dragon[6][9:0];




endmodule

