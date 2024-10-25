`timescale 1ns / 1ps


module tb_Snake_Top;

// Snake_Top Parameters



// Snake_Top Inputs
// Snake_Top Inputs
reg   clk                                  = 0 ;
reg   reset                                = 1 ;
reg   vsync                                = 0 ;
reg   [1:0]  States                        = 0 ;
reg   [9:0]  OrienAndPositon               = 0 ;
reg   [5:0]  movement_counter              = 0 ;

// Snake_Top Outputs
wire  [9:0]  Dragon_1                      ;
wire  [9:0]  Dragon_2                      ;
wire  [9:0]  Dragon_3                      ;
wire  [9:0]  Dragon_4                      ;
wire  [9:0]  Dragon_5                      ;
wire  [9:0]  Dragon_6                      ;
wire  [9:0]  Dragon_7                      ;
wire  [6:0]  Display_en                    ;

integer counter;

initial
begin
    forever #1  clk=~clk;
end

initial
begin
    forever #10  vsync=~vsync;
end

always@(posedge vsync)begin
    if(movement_counter <6'd20)begin
        movement_counter <= movement_counter+1;
    end else begin
        movement_counter <= 0;
    end
end

initial
begin
    #(1*2) reset  =  0;
end

Snake_Top  u_Snake_Top (
    .clk                     ( clk                     ),
    .reset                   ( reset                   ),
    .vsync                   ( vsync                   ),
    .States                  ( States            [1:0] ),
    .OrienAndPositon         ( OrienAndPositon   [9:0] ),
    .movement_counter        ( movement_counter  [5:0] ),

    .Dragon_1                ( Dragon_1          [9:0] ),
    .Dragon_2                ( Dragon_2          [9:0] ),
    .Dragon_3                ( Dragon_3          [9:0] ),
    .Dragon_4                ( Dragon_4          [9:0] ),
    .Dragon_5                ( Dragon_5          [9:0] ),
    .Dragon_6                ( Dragon_6          [9:0] ),
    .Dragon_7                ( Dragon_7          [9:0] ),
    .Display_en              ( Display_en        [6:0] )
);

initial
begin
    #450
    States = 2'b00;
    #1020
    States = 2'b01;
    #2
    States = 2'b00;
    #300
    States = 2'b01;
    #2
    States = 2'b00;
    #900
    States = 2'b01;
    #2
    States = 2'b00;
    #800
    States = 2'b01;
    #2
    States = 2'b00;
    #230
    States = 2'b01;
    #2
    States = 2'b00;
    #1000
    States = 2'b10;
    #2
    States = 2'b00;
    #400
    States = 2'b10;
    #2
    States = 2'b00;
    #400
    States = 2'b10;
    #2
    States = 2'b00;
    #400
    States = 2'b00;
    #400
    States = 2'b00;
    #400
    States = 2'b10;
    #2
    States = 2'b00;
    #400
    States = 2'b01;
    #2
    States = 2'b00;
    #400


    $finish;
end

initial
begin
    #400
    OrienAndPositon = 12'b110000000001;
    #400
    OrienAndPositon = 12'b100000011110;
    #400
    OrienAndPositon = 12'b100000000011;
    #400
    OrienAndPositon = 12'b111111111111;
    #400
    OrienAndPositon = 12'b100000000100;
    #400
    OrienAndPositon = 12'b100000000101;
end

endmodule
