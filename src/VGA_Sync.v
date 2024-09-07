`include "vertical_counter.v"       
`include "horizontal_counter.v"     

/*

Project: TinyTapeStation
Engineer(s) : James Ashie Kotey
Module: VGA Synchronisation Unit

Summary: The VGA sync unit uses the x and y pixel coordinates from the horizontal and vertical
counter to control the vsync and hsync output pulse.

Description =========================================

The sync pulses are enabled when the current pixel is in the retrace or active area.

    SYNC TIMING
    
    (The sync period is also sometimes referred to as the Retrace period)

        Horizontal Timing 

            x_pos:      0             96          144            784           800
                        | HSYNC Pulse | Back Porch | Active Video | Front Porch |
                        |<---96px---->|<---48px--->|<----640px--->|<---16px---->|
            HSync:	  	     LOW 		   HIGH		     HIGH	        HIGH			
    

        Vertical Timing 

            y_pos:  0             2            18            498           524  
                    | HSYNC Pulse | Back Porch | Active Video | Front Porch |
                    |<---2px----->|<---16px--->|<----480px--->|<---16px---->|
            VSync:	  	 LOW 		   HIGH		     HIGH	        HIGH			


        Video Enable Timing
        
        Both the horizontal and vertical counters need to be in the active region
        for the enable signal to go HIGH.

        (18 < y_pos < 498) && (144 < x_pos < 784 )

*/
    

module VGA_Sync(
    
    //CONTROL SIGNALS
    input wire         clk,           //25MHz CLK
    input wire         reset,         //RESET PULSE 

    //OUTPUTS
    output reg         h_sync,        // H_SYNC PULSE
    output reg         v_sync,        // V_SYNC PULSE
    output reg         enable_pixel,  // VIDEO ENABLE
    output reg  [9:0]  pixel_x,       // PIXEL_X - debug
    output reg  [9:0]  pixel_y        // PIXEL_Y - debug

);

    // VGA SPECIFICATION PARAMETERS

    // HORIZONTAL TIMING
    parameter H_RETRACE = 96;
    parameter H_BACK_PORCH = 16;
    parameter H_WIDTH = 640;
    parameter H_FRONT_PORCH = 48;
    parameter H_MAX = H_RETRACE + H_FRONT_PORCH + H_WIDTH + H_BACK_PORCH - 1;       //799

    // VERTICAL TIMING
    parameter V_RETRACE = 2;
    parameter V_BACK_PORCH = 33;
    parameter V_WIDTH = 480;
    parameter V_FRONT_PORCH = 10;
    parameter V_MAX = V_RETRACE + V_BACK_PORCH + V_WIDTH + V_FRONT_PORCH - 1;       // 523

    //Position Counters and buffers

    wire [9:0] h_count_next, v_count_next;

    //Output registers and buffers

    wire  v_sync_next, h_sync_next;
    
    //Video enable signal

    wire enable_v_count;
    
    Horizontal_Counter hc(
        .pixel_clk(clk),
        .reset(reset),
        .enable_v_counter(enable_v_count),
        .h_count_value(h_count_next)
    );

    Vertical_Counter vc(
        .pixel_clk(clk),
        .reset(reset),
        .enable(enable_v_count),
        .v_count_value(v_count_next)
    );
         
    // Set SYNC PULSES LOW  when either counters is in the retrace period.
    
    assign  h_sync_next = (h_count_next < H_RETRACE) ? 0:1;
    assign  v_sync_next = (v_count_next < V_RETRACE) ? 0:1; 
         
    always @(posedge clk) begin 

        // Enable video output when both counters are in the active region.

         enable_pixel <= 
         (
             (h_count_next >= H_RETRACE + H_BACK_PORCH)
          && (h_count_next <= H_MAX - H_FRONT_PORCH )  
          && (v_count_next >= V_RETRACE + V_BACK_PORCH)
          && (v_count_next <= V_MAX - V_FRONT_PORCH) 
         
         ) ? 1:0;  
         
         //Output Assignments

         pixel_x <= h_count_next;
         pixel_y <= v_count_next;     
         h_sync <= h_sync_next;
         v_sync <= v_sync_next;

   end
          
            
     
endmodule


