/*

Project: TinyTapeStation
Engineer(s) : Bowen Shi
Module: Frame Builder DCU 
Create Date: 2024/08/17 20:47:46

Summary: 

Description =========================================

The Entity Detector-Combination Unit can display up to 9 entities on screen at once.

Entity structure:

    [13:10]  Entity ID
    [9:8]  Orientation
    [7:0]  Tile Location

    Unused entities (off-screen) have an ID of 4'hf

Screen Coordinates:

    In line with the coordinate system adopted by VGA Scanlines, the horizontal increases from right to left and  
    the vertical coordinate increases from top to bottom.

    (0,0)----------------> x  
      | 
      |
      |
      v 
      y         
*/

`timescale 1ns / 1ps



module DetectionCombinationUnit (
    
    input clk,
    input reset,
    input [13:0]  entity_1,  
    input [13:0]  entity_2,  
    input [13:0]  entity_3,  
    input [13:0]  entity_4,
    input [13:0]  entity_5,
    input [13:0]  entity_6,
    input [17:0]  entity_7_Array, //[17:4] General entity. [3:0] length of array, array direction is opposite with orientation.
    input [13:0]  entity_8_Flip,
    input [13:0]  entity_9_Flip,
    input [9:0]   counter_V,
    input [9:0]   counter_H,

    output reg [8:0]  out_entity,

    output reg[9:0] test_buffer
    
    //output reg  [8:0]  entity_output_reg
    );

    //Screen Size Paramaters
    localparam BUFFER_LEN = 8;
    localparam UPSCALE_FACTOR = 5;
    localparam TILE_SIZE = 8;
    localparam TILE_LEN_PIXEL = TILE_SIZE * UPSCALE_FACTOR;
    localparam SCREEN_SIZE_H = 16;
    localparam SCREEN_SIZE_V = 12;



    //Entity Set
    reg [3:0] entity_Counter;
    reg [17:0] general_Entity;
    reg [9:0] local_Counter_H;
    reg [9:0] local_Counter_V;
    reg tile_Pulse;
    reg [1:0] flip_Or_Array_Flag; //[1:0] 2'b10:Array; 2'b01:Flip; 2'b00: Default, 2'b11: Disable(internal).
    always@(posedge clk)begin
        if (!reset) begin
        case (entity_Counter)
            4'd0: begin 
                general_Entity <= {entity_9_Flip,4'b0000};   //position is XXYY!!!!!
                if (counter_H > 600)begin
                    local_Counter_H <= 0;
                    local_Counter_V <= counter_V + 1;
                end else begin
                    local_Counter_H <= counter_H + 40;
                    local_Counter_V <= counter_V;
                end
               // $display("X = %b",  local_Counter_H);
                //$display("Y = %b", local_Counter_V);
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
                general_Entity <= 18'b111100000000000000;
                flip_Or_Array_Flag <= 2'b11;
            end
        endcase
           
            if (entity_Counter != 8 && entity_Counter != 4'd15)begin
                entity_Counter <= entity_Counter + 1;
                tile_Pulse <= 0;
            end else if (counter_H % 40 == 0)begin
                entity_Counter <=0;
                tile_Pulse <= 1;
            end else begin
                entity_Counter <= 4'd15;
                tile_Pulse <= 0;
            end

        end else begin
            flip_Or_Array_Flag <= 2'b11;
            entity_Counter <= 0;
            general_Entity <=18'b111100000000000000;
            local_Counter_H <= 0;
            local_Counter_V <= 0;
            tile_Pulse <= 0;
        end
        
    end


    // always @(posedge clk)begin
    //     entity_Counter <= counter_H %8;
    // end

    reg [9:0] entity_Position_Pixel_H;
    reg [9:0] entity_Position_Pixel_V;
    reg [9:0] entity_Position_Pixel_H_1;
    reg [9:0] entity_Position_Pixel_V_1;
    reg inRange_Left_H, inRange_Right_H;
    reg inRange_Top_V, inRange_Bottom_V;
    reg [6:0] inRange;
    reg [9:0] temp_Entity_1;
    reg [9:0] temp_Entity_1_5;
    reg [9:0] temp_Entity_2;
    reg [1:0] flip_Or_Array_Flag_1;
    reg [1:0] flip_Or_Array_Flag_1_5;
    reg [1:0] flip_Or_Array_Flag_2;
    reg [1:0] flip_Or_Array_Flag_3;
    reg [10:0] array_Len;


    always @(posedge clk) begin
        if (!reset) begin
            entity_Position_Pixel_H <= general_Entity[11:8] * TILE_LEN_PIXEL;
            entity_Position_Pixel_V <= general_Entity[7:4] * TILE_LEN_PIXEL;
            temp_Entity_1 <= {general_Entity[17:12], general_Entity[3:0]};
            flip_Or_Array_Flag_1 <= flip_Or_Array_Flag;
        
        // $display("Position_X = %b",  entity_Position_Pixel_H);
        // $display("Position_Y = %b",  entity_Position_Pixel_V);
       // $display("entity = %b",  general_Entity);
        end else begin
            flip_Or_Array_Flag_1 <= 2'b11;
            entity_Position_Pixel_H <= 0;
            entity_Position_Pixel_V <= 0;
            temp_Entity_1 <= 10'b1111110000;
        end
    end

    always @(posedge clk) begin
        if (!reset) begin
            if (flip_Or_Array_Flag_1 != 2'b10) begin
                inRange_Left_H <= local_Counter_H  >= entity_Position_Pixel_H;
                inRange_Right_H <= local_Counter_H  < (entity_Position_Pixel_H + TILE_LEN_PIXEL);
 

                inRange_Top_V <= local_Counter_V >= entity_Position_Pixel_V;
                inRange_Bottom_V <= local_Counter_V < (entity_Position_Pixel_V + TILE_LEN_PIXEL);
                //inRange <= {inRange_Top_V && inRange_Bottom_V && inRange_Left_H && inRange_Right_H, temp_Entity_2};
            end else begin
                // signed_Array_Len <= $signed({1'b0, 10'b1111111111&(entity_7_Array[3:0] * TILE_LEN_PIXEL)});
                inRange_Left_H <= ($signed({1'b0,local_Counter_H})  >= ($signed({1'b0,entity_Position_Pixel_H}) - ((temp_Entity_1[5:4] == 2'b01) ? ($signed({1'b0, 10'b1111111111&(temp_Entity_1[3:0] * TILE_LEN_PIXEL)})) : 0)));
                inRange_Right_H <= {1'b0,local_Counter_H}  < ({1'b0,entity_Position_Pixel_H} + ((temp_Entity_1[5:4] == 2'b11)? ((temp_Entity_1[3:0] + 1) * TILE_LEN_PIXEL) : TILE_LEN_PIXEL));
    
                inRange_Top_V <= ($signed({1'b0,local_Counter_V})  >= ($signed({1'b0,entity_Position_Pixel_V}) - ((temp_Entity_1[5:4] == 2'b10) ? ($signed({1'b0, 10'b1111111111&(temp_Entity_1[3:0] * TILE_LEN_PIXEL)})) : 0)));
                inRange_Bottom_V <= {1'b0,local_Counter_V}  < ({1'b0,entity_Position_Pixel_V} + ((temp_Entity_1[5:4] == 2'b00)? ((temp_Entity_1[3:0] + 1) * TILE_LEN_PIXEL) : TILE_LEN_PIXEL));
            end


            //delay
            temp_Entity_2 <= temp_Entity_1;
            flip_Or_Array_Flag_2 <= flip_Or_Array_Flag_1;
            flip_Or_Array_Flag_3 <= flip_Or_Array_Flag_2;

            inRange <= {inRange_Top_V && inRange_Bottom_V && inRange_Left_H && inRange_Right_H, temp_Entity_2[9:4]};
        end else begin
            flip_Or_Array_Flag_2 <= 2'b11;
            flip_Or_Array_Flag_3 <= 2'b11;
            entity_Position_Pixel_H_1 <= 0;
            entity_Position_Pixel_V_1 <= 0;
            inRange_Left_H <= 0;
            inRange_Right_H <= 0;
            inRange_Top_V <= 0;
            inRange_Bottom_V <= 0;
            inRange <= 7'b1111111;
            temp_Entity_2 <= 10'b1111110000;
        
        end
    end

    reg [8:0] detector;
    reg [5:0] relative_Position;
    reg [5:0] temp_Entity_4;
    reg [1:0] flip_Or_Array_Flag_4;
    //reg effe_Flag;
    always @(posedge clk) begin
        if (!reset) begin
        if (inRange[6] && (inRange[5:2] != 4'b1111)) begin
           // $display("Display = %b",  inRange[4] && inRange[5:0] != 4'b1111 );
            relative_Position <= local_Counter_V % TILE_LEN_PIXEL;
            temp_Entity_4 <= inRange[5:0];
            flip_Or_Array_Flag_4 <= flip_Or_Array_Flag_3;
        
            //effe_Flag <= 1;
        end else begin
            //effe_Flag <= 0;
            flip_Or_Array_Flag_4 <= 2'b11;
            relative_Position <= 6'b111111;
            temp_Entity_4 <=  6'b111111;
        end

        if (flip_Or_Array_Flag_4 != 2'b11)begin
            if (flip_Or_Array_Flag_4 == 2'b01) begin
                detector <= {~(3'b111&(relative_Position/UPSCALE_FACTOR)),temp_Entity_4};
            end else begin
                detector <= {(3'b111&(relative_Position/UPSCALE_FACTOR)),temp_Entity_4};
            end
        end else begin
            detector <= 9'b111111111;
        end

        end else begin
            //effe_Flag <= 0;
            flip_Or_Array_Flag_4 <= 2'b11;
            detector <= 9'b111111111;
            relative_Position <= 0;
            temp_Entity_4 <= 6'b111111;
        end
    end
    
    reg [8:0] holder;
    reg [8:0] delay;
    always @(posedge clk)begin
        if (!reset) begin
            if(!tile_Pulse) begin
                if (detector != 9'b111111111) begin
                    holder <= detector; 
                end else begin
                    holder <= holder;
                end
            end else begin

                holder <= 9'b111111111;
            end
        end else begin
            holder <= 9'b111111111;
            delay <= 9'b111111111;
        end

    end

    always @(posedge clk) begin
        if (!reset) begin
            if (tile_Pulse)begin
                out_entity <= holder;
            end else begin
                out_entity <= out_entity;
            end
        end else begin
            out_entity = 9'b111111111;
        end
    end

    always@(posedge clk) begin
        test_buffer[2:0] = entity_Counter;
    
    end
    endmodule

