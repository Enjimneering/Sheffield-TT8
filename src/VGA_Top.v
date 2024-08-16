`include "VGA_Sync.v"

module VGA_Top(

//INPUTS ============================================ // 

input wire pixel_clk,
input wire reset,
input wire [15:0] color_data,

//From Timing Circuit
input wire h_sync_in,
input wire v_sync_in,

// OUTPUTS ======================================== // 

output reg [15:0] rgb,
output reg h_sync,
output reg v_sync 

);

input video_enable;

VGA_Sync sync(
.clk(pixel_clk),
.reset(reset),  
.enable_pixel(video_enable),
.h_sync(h_sync_in),
.v_sync(v_sync_in)
);

//Pass-through Logic
always @(posedge pixel_clk ) begin
    
if (video_enable) 
    rgb = color_data;
else begin
    rgb = 0;
end

h_sync <= h_sync_in;
v_sync <= v_sync_in;

end

endmodule


