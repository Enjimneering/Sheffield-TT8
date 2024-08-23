`timescale  1ns / 1ps


module tb_VGA_Top;

// VGA_Top Parameters
parameter PERIOD  = 10;


// VGA_Top Inputs
reg   clk                            ;
reg   reset                                = 0 ;
reg   [7:0]  color_data                    = 0 ;

// VGA_Top Outputs
wire  [7:0]  rgb_out                       ;
wire  h_sync                               ;
wire  v_sync                               ;
    wire [9:0]pix_X;
    wire [9:0]pix_Y;





VGA_Top  u_VGA_Top (
    .pixel_clk               ( clk        ),
    .reset                   ( reset             ),
    .color_data              ( color_data  [7:0] ),

    .rgb_out                 ( rgb_out     [7:0] ),
    .h_sync                  ( h_sync            ),
    .v_sync                  ( v_sync            ),
    .pixel_x (pix_X),
    .pixel_y (pix_Y)
);

// integer i;
// integer a;
integer output_file;
integer count_screen_H;
integer count_screen_V;
integer state;


always begin // generate  clk signal.
        #1 clk = ~clk;
end

initial
begin
    
    $dumpfile("VGA_Output_Test.vcd");
    $dumpvars(0 , tb_VGA_Top);
    output_file = $fopen("VGA_Output.txt", "w");
    $fwrite(output_file,"VGA output test \n \n");
    clk = 0; 

    #1
    reset =1;
    #10
    reset = 0; //initialisation
    count_screen_H = 0;



    state = 0;
    while(1)begin
    #2
    if (h_sync && v_sync)begin
        color_data = count_screen_H;
        $fwrite(output_file,"%d ",rgb_out);
        state = 0;
        count_screen_H = count_screen_H+1;
    end
    if (pix_X*pix_Y == 523*798)begin
        $finish;
    end
    if (!h_sync && !state)begin
        count_screen_H = 0;
        $fwrite(output_file," \n ");
        state = 1;
    end
    end


    $fwrite(output_file," \n ");

    $fclose(output_file);
    $finish;
end



endmodule
