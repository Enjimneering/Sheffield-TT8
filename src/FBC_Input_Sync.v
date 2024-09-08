/*

Project: TinyTapeStation
Engineer(s) : James Ashie Kotey
Module: Frame Buffer Synchronisation Unit
Date Created : 24/08/2024

Summary:  This module takes the display timing information from the VGA Sync unit and uses it 
to enable the Frame buffer controler that selects the appropriaet colour output.

Description =========================================

    This sync unit keeps track of the  640 x 480 active area of the screen, 
    incrementing every time the video enable singnal is high.
    
*/

module Frame_Buffer_Sync (

    input wire         pixel_clk,
    input wire         reset,
    input wire         video_enable,      // VIDEO ENABLE

    output reg  [9:0]  screen_pixel_x,    // Active Area X Coordinate
    output reg  [9:0]  screen_pixel_y     // Active Area Y Coordinate

    );  

    initial begin
        screen_pixel_x = 0;
        screen_pixel_y = 0;

    end


    always @(posedge pixel_clk ) begin
        
        if (reset) begin

            screen_pixel_x <= 0;
            screen_pixel_y <= 0;

        end

        else begin

            if (video_enable) begin
                
                if (screen_pixel_x < 639 ) begin

                    screen_pixel_x <= screen_pixel_x + 1; // increment x

                end

                if (screen_pixel_x == 639) begin // reset x
                    
                        screen_pixel_x <= 0;

                        if (screen_pixel_y < 478) begin  // increment y

                            screen_pixel_y <= screen_pixel_y + 1;
                        end

                        if (screen_pixel_x == 479) begin //reset y

                            screen_pixel_y <= 0;
                        end

                end

            end

        end

    end





endmodule