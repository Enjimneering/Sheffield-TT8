/* 
    Project: TinyTapeStation
    Author(s):      James Ashie Kotey,
    Create Date:    18/08/2024
    Module Name:    Sprite ROM Testbench
    
    Summary: Read each tile from The ROM in each of the four orientations.
    
    Description ==============================================================
    
*/


`timescale 1ns / 1ns
`include "SpriteROM.v" 

module ROM_Testbench;

    integer    output_file;
    integer    id;
    integer    orienation;
    integer    line_index;
    integer    pixel;

    reg        CLK;
    reg        RESET;
    reg        ENABLE;
    reg  [1:0] ORIENTATION;
    reg  [3:0] SPRITE_ID;
    reg  [2:0] LINE_INDEX;
    wire [7:0] DATA_OUT;



    SpriteROM ROM (
        .clk(CLK),
        .reset(RESET),
        .read_enable(ENABLE),
        .orientation(ORIENTATION),
        .sprite_ID(SPRITE_ID),
        .line_index(LINE_INDEX),
        .data(DATA_OUT)
    );


    initial begin 
        
        $dumpfile("ROM_Test.vcd");
        $dumpvars(0 , ROM_Testbench);

        output_file = $fopen("ROM_OUTPUT.txt", "w"); 
        RESET  = 0; 
        
        $fwrite(output_file,"ROM OUTPUT TEST \n \n");

        // Display view
        for ( id = 0; id < 9 ; id = id + 1 ) begin
            
            $fwrite(output_file,"ID: %0d \n", id );
            
            for ( orienation = 0; orienation < 4 ; orienation = orienation + 1 ) begin
                
                $fwrite(output_file,"\t" );
             
                case (orienation)
                    3'b000:   $fwrite(output_file, "UP \n");
                    3'b001:   $fwrite(output_file, "RIGHT \n");
                    3'b010:   $fwrite(output_file, "DOWN \n");
                    3'b011:   $fwrite(output_file, "LEFT \n" );
                endcase

                    for (line_index = 0; line_index < 8 ; line_index = line_index + 1) begin      
                        
                        #20 ENABLE = 1;
                        ORIENTATION = orienation;
                        SPRITE_ID = id;
                        LINE_INDEX = line_index;
                        #20;

                        $fwrite(output_file,"\t");

                         for (pixel = 7; pixel > -1 ; pixel = pixel - 1) begin   // read from MSB to LSB 

                            if (DATA_OUT[pixel] == 0 )
                                $fwrite(output_file," X ");
                            else
                                $fwrite(output_file," . ");

                        end

                        $fwrite(output_file,"    ");  //Show the Bitmap

                        for (pixel = 7; pixel > -1 ; pixel = pixel - 1) begin   // read from MSB to LSB 

                            if (DATA_OUT[pixel] == 0 )
                                $fwrite(output_file,"0");
                            else
                                $fwrite(output_file,"1");

                        end
                        
                        $fwrite(output_file,"\n");
                        
                    end 
    
            end

        end
        
                $fwrite(output_file,"\n");
                
              

        $fclose(output_file);

        $display("Testbench Completed Sucsessfully! :D");
        $finish();

    end

    always begin // generate 50MHZ clk signal.
       #20  CLK = ~CLK;
    end

endmodule