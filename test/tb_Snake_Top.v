`timescale 1ns / 1ps


module tb_Snake_Top;

// Snake_Top Parameters



// Snake_Top Inputs
reg   clk                                  = 0 ;
reg   reset                                = 0 ;
reg   [1:0]  States                        = 0 ;
reg   [11:0]  OrienAndPositon              = 0 ;

// Snake_Top Outputs
wire  [95:0]  Dragon                       ;
wire  [2:0]  Tail                          ;


initial
begin
    forever #1  clk=~clk;
end


Snake_Top  u_Snake_Top (
    .clk                     ( clk                     ),
    .reset                   ( reset                   ),
    .States                  ( States           [2:0]  ),
    .OrienAndPositon         ( OrienAndPositon  [11:0] ),

    .Dragon                  ( Dragon           [95:0] ),
    .Tail                    ( Tail             [2:0]  )
);

initial
begin
    #1
    States = 2'b11;
    clk = 0;
    reset = 1;
    #1
    reset = 0;
    #2
    States = 2'b01;
    OrienAndPositon = 12'b110000000001;
    #2
    States = 2'b01;
    OrienAndPositon = 12'b100000011110;
    #2
    States = 2'b00;
    OrienAndPositon = 12'b100000000011;
    #2
    States =2'b11;
    OrienAndPositon = 12'b111111111111;
    #2
    States =2'b01;
    OrienAndPositon = 12'b100000000100;
    #2
    States =2'b10;
    OrienAndPositon = 12'b100000000101;
    #100

    $finish;
end

endmodule
