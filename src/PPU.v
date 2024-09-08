`include "FrameBufferController_Top.v"
`include "VGA_Top.v"
`include "FBC_Input_Sync.v"
`include "BUF.v"


/*
  
  Project: TinyTapeStation
  
  Engineer(s) : Bowen Shi , James Ashie Kotey 
  Module: Picture Processing Unit (PPU)
  Create Date: 26/08/2024

  Summary: 

  

  Description =========================================


  (Game State Variables)

    Player:
      Number of Hearts
      Player Location
      Player Look Direction
      Player Attack?
      Player Attack Direction
      Player Taking Damage

    Dragon:
      Dragon Head Location 
      Dragon Head Orientation
      Dragon Length

    Sheep:
      Sheep Location

    Animation:
      Even Frame?

   Module Inputs
   
    entity :
      ([13:10] entity ID, [9:8] Orientation, [7:0] Location(tile)).
      
 

  =====================================================
*/


 module PictureProcessingUnit (
    
    input system_clk,  
    input pixel_clk,
    input reset,    
    
    input wire [13:0] entity_1,  
    input wire [13:0] entity_2,  
    input wire [13:0] entity_3,  
    input wire [13:0] entity_4,
    input wire [13:0] entity_5,
    input wire [13:0] entity_6,
    input wire [17:0] entity_7,
    input wire [13:0] entity_8_Flip,
    input wire [13:0] entity_9_Flip,

    //Video Sync Outputs

    output wire [9:0] x_pos,
    output wire [9:0] y_pos,
    output wire       video_enable,


    // VGA Outputs

    output wire       h_sync,
    output wire       v_sync,
    output wire [2:0] red,
    output wire [2:0] green,
    output wire [1:0] blue

);
    
    reg   [13:0]   next_entity_1       = 14'b11110000000000 ;
    reg   [13:0]   next_entity_2       = 14'b11110000000000 ;
    reg   [13:0]   next_entity_3       = 14'b11110000000000 ;
    reg   [13:0]   next_entity_4       = 14'b11110000000000 ;
    reg   [13:0]   next_entity_5       = 14'b11110000000000 ;
    reg   [13:0]   next_entity_6       = 14'b11110000000000 ;
    reg   [17:0]   next_entity_7       = 18'b111100000000000000 ;
    reg   [13:0]   next_entity_8_Flip  = 14'b11110000000000 ;
    reg   [13:0]   next_entity_9_Flip  = 14'b11110000000000 ;


    reg   [7:0]    color_data;
    wire           output_color;
    
    reg   [9:0]    X_PIXEL;
    reg   [9:0]    Y_PIXEL;


    BUFG pixel_CLK_buf(
      .I(pixel_clk),
      .O(pixel_clk_buf)
    );


    FrameBufferController_Top  fbc (

        .clk                     ( pixel_clk_buf      ),
        .reset                   ( reset    ),
        .entity_1                ( next_entity_1 ),
        .entity_2                ( next_entity_2 ),
        .entity_3                ( next_entity_3 ),
        .entity_4                ( next_entity_4 ),
        .entity_5                ( next_entity_5 ),
        .entity_6                ( next_entity_6 ),
        .entity_7_Array          ( next_entity_7 ),
        .entity_8_Flip           ( next_entity_8_Flip ),
        .entity_9_Flip           ( next_entity_9_Flip ),
        .counter_V               ( Y_PIXEL),
        .counter_H               ( X_PIXEL),
        .colour                  ( output_color )
    );


    Frame_Buffer_Sync fb_sync (
        
        .pixel_clk(pixel_clk_buf),
        .reset(reset),
        .video_enable(video_enable),
        .screen_pixel_x(x_pos),
        .screen_pixel_y(y_pos)
        
    );


    VGA_Top vga(
        .pixel_clk(pixel_clk_buf),        
        .reset(reset),         
        .color_data( color_data),     
        .video_enable(video_enable), 
        .rgb_out({red,green,blue}),     
        .h_sync(h_sync),     
        .v_sync(v_sync)        
    );
      

always @(pixel_clk_buf) begin // is negedge clk, clk or * better?
  
    if (reset) begin
      
      next_entity_1        <= 14'b11110000000000 ;
      next_entity_2        <= 14'b11110000000000 ;
      next_entity_3        <= 14'b11110000000000 ;
      next_entity_4        <= 14'b11110000000000 ;
      next_entity_5        <= 14'b11110000000000 ;
      next_entity_6        <= 14'b11110000000000 ;
      next_entity_7        <= 14'b11110000000000;
      next_entity_8_Flip   <= 14'b11110000000000 ;
      next_entity_9_Flip   <= 14'b11110000000000 ;
      color_data           <= 8'b0 ;
      
     end

     else begin

      next_entity_1        <= entity_1 ;
      next_entity_2        <= entity_2 ;
      next_entity_3        <= entity_3 ;
      next_entity_4        <= entity_4 ;
      next_entity_5        <= entity_5 ;
      next_entity_6        <= entity_6 ;
      next_entity_7        <= entity_7 ;
      next_entity_8_Flip   <= entity_8_Flip ;
      next_entity_9_Flip   <= entity_9_Flip ;
      
      X_PIXEL = x_pos;
      Y_PIXEL = y_pos;

      color_data = 8'b0000_0000;
      color_data[0] = output_color;
      
     end

end



   



endmodule

    
