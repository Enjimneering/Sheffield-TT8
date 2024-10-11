
/*
 * Copyright (c) 2024 Tiny Tapeout LTD
 * SPDX-License-Identifier: Apache-2.0
 * Author: Uri Shaked
 */


`define COLOR_WHITE 3'd7
module tt_um_vga_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
    wire hsync;
    wire vsync;
    reg [1:0] R;
    reg [1:0] G;
    reg [1:0] B;
    wire video_active;
    wire [9:0] pix_x;
    wire [9:0] pix_y;

    wire pixel_value;
    vga_sync_generator vga_sync_gen (
        .clk(clk),
        .reset(~rst_n),
        .hsync(hsync),
        .vsync(vsync),
        .display_on(video_active),
        .screen_hpos(pix_x),
        .screen_vpos(pix_y)
    );
    assign uo_out  = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

    assign uio_out = 0;
    assign uio_oe  = 0;
    wire _unused_ok = &{ena, uio_in};

    wire [7:0] unused;

    wire [7:0] inPos;
    assign inPos = ui_in;

    FrameBufferController_Top FBC(
    .clk_in                  ( clk                   ),
    .reset                   ( ~rst_n                 ),
    .entity_1                ( {4'b0000,2'b01,inPos} ),
    // .entity_1                ( 14'b11111100100000 ),
    .entity_2                ( 14'b10001100010000 ),
    .entity_3                ( 14'b11111100010001 ),
    .entity_4                ( 14'b11111100010010 ),
    .entity_5                ( 14'b01111100000000 ),
    .entity_6                ( 14'b11111100000000 ),
    .entity_7_Array                (18'b111111000000000000 ),
    .entity_8_Flip           ( 14'b11111100000000 ),
    .entity_9_Flip           ( 14'b11111100000000 ),
    .counter_V               ( pix_y      [9:0]  ),
    .counter_H               ( pix_x      [9:0]  ),

    .colour                  ( pixel_value              ),
    .buffer_O                (unused)
    );

    always @(posedge clk) begin
    if (~rst_n) begin
      R <= 0;
      G <= 0;
      B <= 0;
    end else begin

      if (video_active) begin
        R <= pixel_value ? 2'b11 : 0;
        G <= pixel_value ? 2'b11 : 0;
        B <= pixel_value ? 2'b11 : 0;
      end else begin
        R <= 0;
        G <= 0;
        B <= 0;
      end
    end
  end
endmodule



module FrameBufferController_Top(
    input clk_in,  
    input reset,    
    input wire [13:0] entity_1,  //entity input form: ([13:10] entity ID, [9:8] Orientation, [7:0] Location(tile)).
    input wire [13:0] entity_2,  //Simultaneously supports up to 9 objects in the scene.
    input wire [13:0] entity_3,  //Set the entity ID to 4'hf for unused channels.
    input wire [13:0] entity_4,
    input wire [13:0] entity_5,
    input wire [13:0] entity_6,
    input wire [17:0] entity_7_Array,
    input wire [13:0] entity_8_Flip,
    input wire [13:0] entity_9_Flip,
    input wire [9:0] counter_V,
    input wire [9:0] counter_H,

    output reg [7:0] buffer_O,
    output reg colour // 0-black 1-white
    );

// localparam [3:0] BUFFERLEN = 8;
// localparam [2:0] UPSCALE_FACTOR = 5;
// localparam [3:0] TILE_SIZE = 8;
// localparam [5:0] TILE_LEN_PIXEL = TILE_SIZE * UPSCALE_FACTOR;
// localparam [4:0] SCREENSIZE_H = 16;
// localparam [3:0] SCREENSIZE_V = 12;

wire clk = clk_in;
// Clock
// clk_wiz_0 inst(
//     .clk_in1(clk_in),
//     .reset(reset),

//     .clk_out1(clk),
//     .locked(locked)
// );

reg [3:0] entity_Counter;
reg [17:0] general_Entity;
reg [3:0] local_Counter_H;
reg [3:0] local_Counter_V;
reg [1:0] flip_Or_Array_Flag; //[1:0] 2'b10:Array; 2'b01:Flip; 2'b00: Default, 2'b11: Disable(internal).
reg [3:0] Counter_H_Tile;
reg [3:0] Counter_V_Tile;

reg [9:0] preH;
reg [9:0] preV;

reg [2:0] colCounter;
reg [2:0] rowCounter;

reg [2:0] upscale_Counter_H;
reg [2:0] upscale_Counter_V;


always@(posedge clk)begin //合并横纵两方向运算
    if(!reset)begin
            preV <= counter_V;
            if (preV != counter_V)begin
                
                if(upscale_Counter_V != 4) begin
                    upscale_Counter_V <= upscale_Counter_V + 1;
                end else begin
                    upscale_Counter_V <= 0;
                    colCounter <= colCounter + 1;
                end
                if (counter_V >= 40)begin
                    if(colCounter == 3'b111 && upscale_Counter_V == 4 && Counter_V_Tile != 4'd11)begin
                        Counter_V_Tile <= Counter_V_Tile + 1;
                    end else if(colCounter == 3'b111 && upscale_Counter_V == 4 && Counter_V_Tile == 4'd11) begin
                        Counter_V_Tile <= 0;
                    end else begin
                        Counter_V_Tile <= Counter_V_Tile;
                    end
                end else begin
                    Counter_V_Tile <= 0;
                end
            end else begin
                Counter_V_Tile <= Counter_V_Tile;
                upscale_Counter_V <= upscale_Counter_V;
                colCounter <= colCounter;
            end

            preH <= counter_H;
            if (preH != counter_H )begin
                if(upscale_Counter_H != 4)begin
                    upscale_Counter_H <= upscale_Counter_H + 1;
                end else begin
                    upscale_Counter_H <= 0;
                    rowCounter <= rowCounter + 1;
                end
                
                if (counter_H >= 40) begin
                    if(rowCounter == 3'b111 && upscale_Counter_H == 4)begin
                        Counter_H_Tile <= Counter_H_Tile + 1;
                    end else begin
                        Counter_H_Tile <= Counter_H_Tile;
                    end
                end else begin
                    Counter_H_Tile <= 0;
                end
            end else begin
                Counter_H_Tile <= Counter_H_Tile;
                upscale_Counter_H <= upscale_Counter_H;
                rowCounter <= rowCounter;
            end

    end else begin
        preH <= 0;
        rowCounter <= 0; 
        upscale_Counter_H <= 0;
        Counter_H_Tile <= 4'b0000;

        preV <= 0;
        colCounter <= 0;
        upscale_Counter_V <= 0;
        Counter_V_Tile <= 4'b0000;
    end
end

// reg [9:0] pre_Counter_H;
// wire [7:0] next_Counter_HV = ({Counter_V_Tile, Counter_H_Tile}) + 8'b00000001;
wire [3:0] test1 = (Counter_H_Tile + 1);
wire [3:0] test2 = (local_Counter_H);
wire test12 = test1 != test2;

always@(posedge clk)begin
    if (!reset) begin
    case (entity_Counter)
        4'd0: begin 
            general_Entity <= {entity_9_Flip,4'b0000};   //position is XXYY!!!!!
            flip_Or_Array_Flag <= 2'b01;
            end
        4'd1:begin
            general_Entity <= {entity_8_Flip,4'b0000}; 
            flip_Or_Array_Flag <= 2'b01;
        end   
        4'd2:begin
            general_Entity <= entity_7_Array;
            flip_Or_Array_Flag <= 2'b10;
        end
        4'd3:begin 
            general_Entity <= {entity_6,4'b0000};
            flip_Or_Array_Flag <= 2'b00;
        end
        4'd4:begin 
            general_Entity <= {entity_5,4'b0000};
            flip_Or_Array_Flag <= 2'b00;
        end
        4'd5:begin 
            general_Entity <= {entity_4,4'b0000};
            flip_Or_Array_Flag <= 2'b00;
        end
        4'd6:begin 
            general_Entity <= {entity_3,4'b0000};
            flip_Or_Array_Flag <= 2'b00;
        end
        4'd7:begin 
            general_Entity <= {entity_2,4'b0000};
            flip_Or_Array_Flag <= 2'b00;
        end
        4'd8: begin
            general_Entity <= {entity_1,4'b0000};
            flip_Or_Array_Flag <= 2'b00;
        end
        
        default: begin
            general_Entity <= 18'b111111000000000000;
            flip_Or_Array_Flag <= 2'b11;
        end
    endcase
        local_Counter_H <= Counter_H_Tile + 1;
        if(colCounter == 3'b111 && upscale_Counter_H == 4 && Counter_H_Tile == 15 && rowCounter == 7 && upscale_Counter_H ==4)begin
            if(Counter_V_Tile != 4'b1011)begin 
                local_Counter_V <= Counter_V_Tile + 1;
            end else begin
                local_Counter_V <= 0;
            end
        end else begin
            local_Counter_V <= Counter_V_Tile;
        end
        if (entity_Counter != 8 && entity_Counter != 4'd15)begin
            entity_Counter <= entity_Counter + 1;
        end else if (test12)begin
            entity_Counter <=0;
        end else begin
            entity_Counter <= 4'd15;
        end
        buffer_O[3:0] <= general_Entity[3:0];
    end else begin
        flip_Or_Array_Flag <= 2'b11;
        entity_Counter <= 4'b0000;
        general_Entity <=18'b111111000000000000;
        local_Counter_H <= 0;
        local_Counter_V <= 0;
    end
    
end
//wire [3:0] testV = local_Counter_H == Counter_H_Tile;

wire inRange;
wire array_ori = general_Entity[13] !=  general_Entity[12];
assign inRange = ((((local_Counter_H - general_Entity[11:8])) <= ((~array_ori)? general_Entity[3:0] : 0)) && (((local_Counter_V - general_Entity[7:4])) <= ((array_ori)?general_Entity[3:0] : 0)));

reg [8:0] detector;
reg [8:0] out_entity;


//reg effe_Flag;
always @(posedge clk) begin
    if (!reset) begin

        if (!(rowCounter == 7 && upscale_Counter_H == 3))begin
            out_entity <= out_entity;
            
            if ((inRange && (general_Entity[17:14] != 4'b1111)) && (flip_Or_Array_Flag != 2'b11)) begin

                if (flip_Or_Array_Flag == 2'b01) begin
                    detector <= {~(colCounter),general_Entity[17:12]};
                end else begin
                    detector <= {(colCounter),general_Entity[17:12]};
                end
            end else begin

                detector <= detector;
            end
        end else begin
            out_entity <= detector;
            detector <= 9'b111111111;
        end

    end else begin
        detector <= 9'b111111111;
        out_entity <= 9'b111111111;
    end
end

wire [7:0] buffer;

SpriteROM Rom(
    .clk(clk),
    .reset(reset),
    .orientation(out_entity[1:0]),
    .sprite_ID(out_entity[5:2]),
    .line_index(out_entity[8:6]),

    .data(buffer)
);

always@(posedge clk)begin
    if(!reset)begin
    colour <= buffer[rowCounter];
    buffer_O <= buffer;
    end else begin
    colour <= 1'b1;
    buffer_O <= 0;
    end
end

endmodule


module SpriteROM(
    
    input            clk,
    input            reset,
    // input wire       read_enable,
    input [1:0] orientation,
    input [3:0] sprite_ID,
    input [2:0] line_index,
    
    output reg [7:0] data
);

    localparam UP     = 2'b00;
    localparam RIGHT  = 2'b01;
    localparam DOWN   = 2'b10;
    localparam LEFT   = 2'b11;

    // assign read_enable = 1'b1;

reg [7:0]romData[71:0];
initial begin
    romData[0] = 8'b11000111;
    romData[1] = 8'b10000011;
    romData[2] = 8'b10000001;
    romData[3] = 8'b11000000;
    romData[4] = 8'b11001000;
    romData[5] = 8'b10010001;
    romData[6] = 8'b10000011;
    romData[7] = 8'b11000111;

    romData[8]  = 8'b11101111;
    romData[9]  = 8'b11101111;
    romData[10] = 8'b11101111;
    romData[11] = 8'b11101111;
    romData[12] = 8'b11101111;
    romData[13] = 8'b11101111;
    romData[14] = 8'b11000111;
    romData[15] = 8'b11101111;

    romData[16] = 8'b11111111;
    romData[17] = 8'b11000011;
    romData[18] = 8'b10110000;
    romData[19] = 8'b00000011;
    romData[20] = 8'b00110001;
    romData[21] = 8'b00000000;
    romData[22] = 8'b01000001;
    romData[23] = 8'b11111111;

    romData[24] = 8'b11111011;
    romData[25] = 8'b11100011;
    romData[26] = 8'b11001000;
    romData[27] = 8'b11000011;
    romData[28] = 8'b10001001;
    romData[29] = 8'b10000000;
    romData[30] = 8'b10010001;
    romData[31] = 8'b11111111;

    romData[32] = 8'b11000011;
    romData[33] = 8'b11100001;
    romData[34] = 8'b10000011;
    romData[35] = 8'b10000001;
    romData[36] = 8'b00000001;
    romData[37] = 8'b01000000;
    romData[38] = 8'b11100001;
    romData[39] = 8'b11000001;

    romData[40] = 8'b11000011;
    romData[41] = 8'b11100001;
    romData[42] = 8'b11000011;
    romData[43] = 8'b10000001;
    romData[44] = 8'b10000000;
    romData[45] = 8'b10000000;
    romData[46] = 8'b10000001;
    romData[47] = 8'b11000001;

    romData[48] = 8'b11000111;
    romData[49] = 8'b11000011;
    romData[50] = 8'b11000011;
    romData[51] = 8'b10010001;
    romData[52] = 8'b10110001;
    romData[53] = 8'b10100001;
    romData[54] = 8'b01000011;
    romData[55] = 8'b11000111;

    romData[56] = 8'b11001111;
    romData[57] = 8'b10000011;
    romData[58] = 8'b10011000;
    romData[59] = 8'b01111011;
    romData[60] = 8'b01111011;
    romData[61] = 8'b01111000;
    romData[62] = 8'b10111011;
    romData[63] = 8'b11000111;

    romData[64] = 8'b11100111;
    romData[65] = 8'b11000001;
    romData[66] = 8'b11001100;
    romData[67] = 8'b10111101;
    romData[68] = 8'b10111101;
    romData[69] = 8'b10111100;
    romData[70] = 8'b11011101;
    romData[71] = 8'b11100011;
    
end

    always @(posedge clk) begin // impliment the 4 orientations
        
        if(!reset) begin
            if (sprite_ID != 4'b1111)begin

                if (orientation == UP) begin                              // Normal Operation
                    data[0] <= romData[{sprite_ID,line_index}][7];
                    data[1] <= romData[{sprite_ID,line_index}][6];
                    data[2] <= romData[{sprite_ID,line_index}][5];
                    data[3] <= romData[{sprite_ID,line_index}][4];
                    data[4] <= romData[{sprite_ID,line_index}][3];
                    data[5] <= romData[{sprite_ID,line_index}][2];
                    data[6] <= romData[{sprite_ID,line_index}][1];
                    data[7] <= romData[{sprite_ID,line_index}][0];
                    // data <= romData(sprite_ID,line_index, 1'b0 );
                end 

                else if (orientation == RIGHT) begin                        // (Rotate 90 degrees clockwise around the center point)   
                    data[0] <= romData[{sprite_ID,3'b111}][~line_index];               
                    data[1] <= romData[{sprite_ID,3'b110}][~line_index];
                    data[2] <= romData[{sprite_ID,3'b101}][~line_index];
                    data[3] <= romData[{sprite_ID,3'b100}][~line_index];
                    data[4] <= romData[{sprite_ID,3'b011}][~line_index];
                    data[5] <= romData[{sprite_ID,3'b010}][~line_index];
                    data[6] <= romData[{sprite_ID,3'b001}][~line_index];
                    data[7] <= romData[{sprite_ID,3'b000}][~line_index];
                end

                else if(orientation == DOWN) begin                           // Top row to bottom row (Reflection on the line y = 0)
                    data <= romData[{sprite_ID,~line_index}];
                end

                else if (orientation == LEFT) begin                         //  (Rotate 90 degrees clockwise around the center point and reflect on the line x = 0)
                    data[0] <= romData[{sprite_ID,3'b000}][~line_index];               
                    data[1] <= romData[{sprite_ID,3'b001}][~line_index];
                    data[2] <= romData[{sprite_ID,3'b010}][~line_index];
                    data[3] <= romData[{sprite_ID,3'b011}][~line_index];
                    data[4] <= romData[{sprite_ID,3'b100}][~line_index];
                    data[5] <= romData[{sprite_ID,3'b101}][~line_index];
                    data[6] <= romData[{sprite_ID,3'b110}][~line_index];
                    data[7] <= romData[{sprite_ID,3'b111}][~line_index];

                end else begin
                    data <= 8'b11111111;
                end

            end else begin
                data <= 8'b11111111;
            end

        end else begin
            data <= 8'b11111111;
        end

    end

endmodule

module vga_sync_generator (
    input clk,
    input reset,
    output reg hsync,
    output reg vsync,
    output wire display_on,
    output wire [9:0] screen_hpos,
    output wire [9:0] screen_vpos
);
    reg [9:0] hpos;
    reg [9:0] vpos;
  // declarations for TV-simulator sync parameters
  // horizontal constants
  parameter H_DISPLAY = 640;  // horizontal display width
  parameter H_BACK = 48;  // horizontal left border (back porch)
  parameter H_FRONT = 16;  // horizontal right border (front porch)
  parameter H_SYNC = 96;  // horizontal sync width
  // vertical constants
  parameter V_DISPLAY = 480;  // vertical display height
  parameter V_TOP = 33;  // vertical top border
  parameter V_BOTTOM = 10;  // vertical bottom border
  parameter V_SYNC = 2;  // vertical sync # lines
  // derived constants
  parameter H_SYNC_START = H_DISPLAY + H_FRONT;
  parameter H_SYNC_END = H_DISPLAY + H_FRONT + H_SYNC - 1;
  parameter H_MAX = H_DISPLAY + H_BACK + H_FRONT + H_SYNC - 1;
  parameter V_SYNC_START = V_DISPLAY + V_BOTTOM;
  parameter V_SYNC_END = V_DISPLAY + V_BOTTOM + V_SYNC - 1;
  parameter V_MAX = V_DISPLAY + V_TOP + V_BOTTOM + V_SYNC - 1;

  wire hmaxxed = (hpos == H_MAX) || reset;  // set when hpos is maximum
  wire vmaxxed = (vpos == V_MAX) || reset;  // set when vpos is maximum
  assign screen_hpos = (hpos < H_DISPLAY)? hpos : 0; 
  assign screen_vpos = (vpos < V_DISPLAY)? vpos : 0;

  // horizontal position counter
  always @(posedge clk) begin
    hsync <= (hpos >= H_SYNC_START && hpos <= H_SYNC_END);
    if (hmaxxed) begin
      hpos <= 0;
    end else begin
      hpos <= hpos + 1;
    end
  end


  // vertical position counter
  always @(posedge clk) begin
    vsync <= (vpos >= V_SYNC_START && vpos <= V_SYNC_END);
    if (hmaxxed)
      if (vmaxxed) begin
      vpos <= 0;
      end else begin
        vpos <= vpos + 1;
      end
  end

  // always @(posedge clk)begin
  //   if (!hsync) begin
  //     screen_hpos <= screen_hpos +1;
  //   end else begin
  //     screen_hpos <= 0;
  //   end
  // end
  // always @(posedge clk)begin
  //   if (hmaxxed) begin
  //     if (!vsync) begin
  //       screen_vpos <= screen_vpos +1;
  //     end else begin
  //       screen_vpos <= 0;
  //     end
  //   end
  // end

  // display_on is set when beam is in "safe" visible frame
  assign display_on = (hpos < H_DISPLAY) && (vpos < V_DISPLAY);

endmodule

// --------------------------------------------------------

