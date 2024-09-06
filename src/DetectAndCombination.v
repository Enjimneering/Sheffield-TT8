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



module DetectionCombinationUnit(
    
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
                general_Entity[17:4] <= entity_9_Flip;   //position is XXYY!!!!!
                if (counter_H > 600)begin
                    local_Counter_H <= 0;
                    local_Counter_V <= counter_V + 1;
                end else begin
                    local_Counter_H <= counter_H + 40;
                    local_Counter_V <= counter_V;
                end
                $display("X = %b",  local_Counter_H);
                $display("Y = %b", local_Counter_V);
                flip_Or_Array_Flag <= 2'b01;
                end
            4'd1:begin
                general_Entity[17:4] <= entity_8_Flip;  
                flip_Or_Array_Flag <= 2'b01;
            end   
            4'd2:begin
                general_Entity <= entity_7_Array;
                flip_Or_Array_Flag <= 2'b10;
            end
            4'd3:begin 
                general_Entity[17:4] <= entity_6;
                flip_Or_Array_Flag <= 2'b00;
            end
            4'd4:begin 
                general_Entity[17:4] <= entity_5;
                flip_Or_Array_Flag <= 2'b00;
            end
            4'd5:begin 
                general_Entity[17:4] <= entity_4;
                flip_Or_Array_Flag <= 2'b00;
            end
            4'd6:begin 
                general_Entity[17:4] <= entity_3;
                flip_Or_Array_Flag <= 2'b00;
            end
            4'd7:begin 
                general_Entity[17:4] <= entity_2;
                flip_Or_Array_Flag <= 2'b00;
            end
            4'd8: begin
                general_Entity[17:4] <= entity_1;
                flip_Or_Array_Flag <= 2'b00;
            end
            
            default: begin
                general_Entity <= 18'b111100000000000000;
                flip_Or_Array_Flag <= 2'b00;
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
    reg inRange_Left_H, inRange_Right_H;
    reg inRange_Top_V, inRange_Bottom_V;
    reg [6:0] inRange;
    reg [5:0] temp_Entity_1;
    reg [5:0] temp_Entity_2;
    reg [1:0] flip_Or_Array_Flag_1;
    reg [1:0] flip_Or_Array_Flag_2;
    reg [1:0] flip_Or_Array_Flag_3;

    always @(posedge clk) begin
        if (!reset) begin
            entity_Position_Pixel_H <= general_Entity[11:8] * TILE_LEN_PIXEL;
            entity_Position_Pixel_V <= general_Entity[7:4] * TILE_LEN_PIXEL;
            temp_Entity_1 <= general_Entity[17:12];
            flip_Or_Array_Flag_1 <= flip_Or_Array_Flag;
        
        // $display("Position_X = %b",  entity_Position_Pixel_H);
        // $display("Position_Y = %b",  entity_Position_Pixel_V);
        $display("entity = %b",  general_Entity);
        end else begin
            flip_Or_Array_Flag_1 <= 2'b11;
            entity_Position_Pixel_H <= 0;
            entity_Position_Pixel_V <= 0;
            temp_Entity_1 <= 6'b111111;
        end
    end

    always @(posedge clk) begin
        if (!reset) begin
            if (flip_Or_Array_Flag_1 != 2'b10) begin
                inRange_Left_H <= local_Counter_H  >= entity_Position_Pixel_H;
                
                inRange_Right_H <= local_Counter_H  < (entity_Position_Pixel_H + TILE_LEN_PIXEL);
                
                temp_Entity_2 <= temp_Entity_1;
                flip_Or_Array_Flag_2 <= flip_Or_Array_Flag_1;
                flip_Or_Array_Flag_3 <= flip_Or_Array_Flag_2;

                inRange_Top_V <= local_Counter_V >= entity_Position_Pixel_V;
                inRange_Bottom_V <= local_Counter_V < (entity_Position_Pixel_V + TILE_LEN_PIXEL);
                
                inRange <= {inRange_Top_V && inRange_Bottom_V && inRange_Left_H && inRange_Right_H, temp_Entity_2};
            end else begin
                inRange_Left_H <= ($signed(local_Counter_H)  >= ($signed({1'b0,entity_Position_Pixel_H})-((entity_7_Array[13:12] == 2'b01)? (entity_7_Array[7:0] * TILE_LEN_PIXEL) :0)));
                
                inRange_Right_H <= local_Counter_H  < ({1'b0,entity_Position_Pixel_H} + ((entity_7_Array[13:12] == 2'b11)? (entity_7_Array[7:0] * TILE_LEN_PIXEL) : TILE_LEN_PIXEL));
                
                temp_Entity_2 <= temp_Entity_1;
                flip_Or_Array_Flag_2 <= flip_Or_Array_Flag_1;
                flip_Or_Array_Flag_3 <= flip_Or_Array_Flag_2;

                inRange_Top_V <= ($signed(local_Counter_V)  >= ($signed({1'b0,entity_Position_Pixel_V})-((entity_7_Array[13:12] == 2'b10)? (entity_7_Array[7:0] * TILE_LEN_PIXEL) :0)));
                inRange_Bottom_V <= local_Counter_V  < ({1'b0,entity_Position_Pixel_V} + ((entity_7_Array[13:12] == 2'b00)? (entity_7_Array[7:0] * TILE_LEN_PIXEL) : TILE_LEN_PIXEL));
                
                inRange <= {inRange_Top_V && inRange_Bottom_V && inRange_Left_H && inRange_Right_H, temp_Entity_2};
            end
        end else begin
            flip_Or_Array_Flag_2 <= 2'b11;
            flip_Or_Array_Flag_3 <= 2'b11;
            inRange_Left_H <= 0;
            inRange_Right_H <= 0;
            inRange_Top_V <= 0;
            inRange_Bottom_V <= 0;
            inRange <= 7'b1111111;
            temp_Entity_2 <= 6'b111111;
        
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
            $display("Display = %b",  inRange[4] && inRange[5:0] != 4'b1111 );
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

        // always @(posedge clk) begin
    //     case(entity_Counter)
    //         4'd0: out_entity <= detector;
    //         4'd1: out_entity <= (detector != 9'b111111111)? detector : out_entity;
    //         4'd2: out_entity <= (detector != 9'b111111111)? detector : out_entity;
    //         4'd3: out_entity <= (detector != 9'b111111111)? detector : out_entity;
    //         4'd4: out_entity <= (detector != 9'b111111111)? detector : out_entity;
    //         4'd5: out_entity <= (detector != 9'b111111111)? detector : out_entity;
    //         4'd6: out_entity <= (detector != 9'b111111111)? detector : out_entity;
    //         4'd7: out_entity <= (detector != 9'b111111111)? detector : out_entity;
    //         4'd8: out_entity <= (detector != 9'b111111111)? detector : out_entity;
    //         // 4'd9: 
    //         default: priority_Out = priority_Out;
    //     endcase
        
    // end
    // always @(posedge reset) begin
    //     if (reset) begin
    //     general_Entity = 0;
    //     entity_Counter = 0;
    //     inRange_Left_H = 0;
    //     inRange_Right_H = 0;
    //     inRange_Top_V = 0;
    //     inRange_Bottom_V= 0;
    //     entity_Position_Pixel_H =0;
    //     entity_Position_Pixel_V =0;
    //     detector = 0;
    //     relative_Position = 0;
    //     priority_Out=0;
    //     end
    // end

    // always@(*) begin
    // $display("Inside module: a = %b",  inRange);
    // end

    // reg inRange_Left_H_Array, inRange_Right_H_Array;
    // reg inRange_Top_V_Array, inRange_Bottom_V_Array;
    // reg inRange_H, inRange_V, inRange;
    // always @(posedge clk) begin
    //     inRange_Right_H_Array <= $signed(counter_H) >= $signed({1'b0,entity_Position_Pixel_H} - ((entity_OrienAndPosition[9:8] == 2'b01) ? (entity_Len_Array * TILE_LEN_PIXEL) : 0))
    // end



    // function [9:0] entity_Position_Pixel_H; //Calculate the entity horizontal position in pixels
    //     input [7:0] entity_Position;
    //     begin
    //         //entity_Position_Pixel_H = (entity_Position % SCREEN_SIZE_H) * TILE_LEN_PIXEL;
    //         entity_Position_Pixel_H = entity_Position[3:0] * TILE_LEN_PIXEL;
    //     end

    // endfunction

    // function [9:0] entity_Position_Pixel_V; //Calculate the entity vertical position in pixels
    //     input [7:0] entity_Position;
    //     begin
    //     // entity_Position_Pixel_V = (entity_Position / SCREEN_SIZE_H) * TILE_LEN_PIXEL;
    //     entity_Position_Pixel_V = entity_Position[7:4] * TILE_LEN_PIXEL;
    //     end
    // endfunction

    // function inRange; //If the entity is within the loading area (40 Pixel or 1 tile length)
    //     input [7:0] entity_Position;
    //     input [9:0] ptH_Position;
    //     input [9:0] ptV_Position;
    //     begin
        
    //     inRange = ptH_Position >= entity_Position_Pixel_H(entity_Position) 
    //     && ptH_Position < (entity_Position_Pixel_H(entity_Position) + TILE_LEN_PIXEL) 
    //     && ptV_Position >= entity_Position_Pixel_V(entity_Position) 
    //     && ptV_Position < entity_Position_Pixel_V(entity_Position) + TILE_LEN_PIXEL;

    //     end
        
    // endfunction

//     function inRange_Array; //If the entity is within the loading area (40 Pixel or 1 tile length)
//         input [9:0] entity_OrienAndPosition;
//         input [3:0] entity_Len_Array;
//         input [10:0] ptH_Position;
//         input [10:0] ptV_Position;
//         begin
        
//         inRange_Array = $signed(ptH_Position) >= $signed({1'b0,entity_Position_Pixel_H(entity_OrienAndPosition)} - ((entity_OrienAndPosition[9:8] == 2'b01) ? (entity_Len_Array * TILE_LEN_PIXEL) : 0))
//         && ptH_Position < ({1'b0,entity_Position_Pixel_H(entity_OrienAndPosition)}  + ((entity_OrienAndPosition[9:8] == 2'b11) ? ((entity_Len_Array + 1) * TILE_LEN_PIXEL) : TILE_LEN_PIXEL)) 
//         && $signed(ptV_Position) >= $signed({1'b0,entity_Position_Pixel_V(entity_OrienAndPosition)}  - ((entity_OrienAndPosition[9:8] == 2'b10) ? (entity_Len_Array * TILE_LEN_PIXEL) : 0))
//         && ptV_Position < ({1'b0,entity_Position_Pixel_V(entity_OrienAndPosition)}  + ((entity_OrienAndPosition[9:8] == 2'b00) ? ((entity_Len_Array + 1) * TILE_LEN_PIXEL) : TILE_LEN_PIXEL));
        
//         end
        
//     endfunction


//     function [8:0] detector; //If the position of the pointer needs to be displayed, return the row label; otherwise, return 4'hF (an invalid identifier).
//         input [13:0] entity;
//         input [9:0] ptH_Position;
//         input [9:0] ptV_Position;
//         begin
        
//         if (inRange(entity[7:0], ptH_Position, ptV_Position)==1 && entity[13:10] != 4'b1111) begin
//                 detector = {((ptV_Position % TILE_LEN_PIXEL)/UPSCALE_FACTOR), entity[13:10],entity[9:8]};
//             end else begin
//                 detector = 9'b111111111; // 'h1FF
//             end
//         end


//     endfunction

//     function [8:0] detector_Flip; //If the position of the pointer needs to be displayed, return the row label; otherwise, return 4'hF (an invalid identifier).
//         input [13:0] entity;
//         input [9:0] ptH_Position;
//         input [9:0] ptV_Position;
//         begin
        
//         if (inRange(entity[7:0], ptH_Position, ptV_Position)==1 && entity[13:10] != 4'b1111) begin
//                 detector_Flip = {~(3'b111&((ptV_Position % TILE_LEN_PIXEL)/UPSCALE_FACTOR)), entity[13:10],entity[9:8]};
//             end else begin
//                 detector_Flip = 9'b111111111; // 'h1FF
//             end
//         end


//     endfunction

//     function [8:0] detector_Array; //If the position of the pointer needs to be displayed, return the row label; otherwise, return 4'hF (an invalid identifier).
//         input [17:0] entity_Array;
//         input [9:0] ptH_Position;
//         input [9:0] ptV_Position;
//         begin
        
//         if (inRange_Array(entity_Array[13:4], entity_Array[3:0],{1'b0,ptH_Position}, {1'b0,ptV_Position})==1 && entity_Array[17:14] != 4'b1111) begin
//                 detector_Array = {(3'b111&((ptV_Position % TILE_LEN_PIXEL)/UPSCALE_FACTOR)), entity_Array[17:14],entity_Array[13:12]};
//             end else begin
//                 detector_Array = 9'b111111111; // 'h1FF
//             end
//         end


//     endfunction

// // always @(*) begin
// // $display("Inside module: Range = %b \n", inRange(entity_1[7:0], counter_H, counter_V)==1 && entity_1[13:10] != 4'b1111);
// // $display("Inside module: 1 = %b \n",  detector(entity_1, counter_H, counter_V));
// // $display("Inside module: 2 = %b \n",  detector(entity_2, counter_H, counter_V));
// // $display("Inside module: 3 = %b \n",  detector(entity_3, counter_H, counter_V));
// // $display("Inside module: 4 = %b \n",  detector(entity_4, counter_H, counter_V));
// // $display("Inside module: 5 = %b \n",  detector(entity_5, counter_H, counter_V));
// // $display("Inside module: 6 = %b \n",  detector(entity_6, counter_H, counter_V));
// // $display("Inside module: 7 = %b \n",  detector(entity_7_Array, counter_H, counter_V));
// // $display("Inside module: 8 = %b \n",  detector(entity_8, counter_H, counter_V));
// // $display("Inside module: 9 = %b \n",  detector(entity_9, counter_H, counter_V));

// // end

// //BigAnd and_5_entity( detector(entity_1, counter_H, counter_V) , detector(entity_2, counter_H, counter_V) , detector(entity_3, counter_H, counter_V) , detector(entity_4, counter_H, counter_V) , detector(entity_5, counter_H, counter_V) , detector(entity_6, counter_H, counter_V) , detector(entity_7_Array, counter_H, counter_V) , detector(entity_8, counter_H, counter_V) , detector(entity_9, counter_H, counter_V), out_entity);
// // wire [9:0] FlipEntity_8 = detector(entity_8_Flip, counter_H, counter_V);
// // wire [9:0] FlipEntity_9 = detector(entity_9_Flip, counter_H, counter_V);


// // always@(*) begin
// //     $display("Inside module: a = %b",  entity_Position_Pixel_H(entity_1[7:0]));
// // end

// reg [8:0] priority_Out;
// wire [8:0] priority_1 = detector(entity_1, counter_H, counter_V);
// wire [8:0] priority_2 = detector(entity_2, counter_H, counter_V);
// wire [8:0] priority_3 = detector(entity_3, counter_H, counter_V);
// wire [8:0] priority_4 = detector(entity_4, counter_H, counter_V);
// wire [8:0] priority_5 = detector(entity_5, counter_H, counter_V);
// wire [8:0] priority_6 = detector(entity_6, counter_H, counter_V);
// wire [8:0] priority_7 = detector_Array(entity_7_Array, counter_H, counter_V);
// wire [8:0] priority_8 = detector_Flip(entity_8_Flip, counter_H, counter_V);
// wire [8:0] priority_9 = detector_Flip(entity_9_Flip, counter_H, counter_V);

// always @(posedge clk) begin
//     if (priority_1 != 9'b111111111) begin
//         priority_Out = priority_1;
//     end else if (priority_2 != 9'b111111111) begin
//         priority_Out = priority_2;
//     end else if (priority_3 != 9'b111111111) begin
//         priority_Out = priority_3;
//     end else if (priority_4 != 9'b111111111) begin
//         priority_Out = priority_4;
//     end else if (priority_5 != 9'b111111111) begin
//         priority_Out = priority_5;
//     end else if (priority_6 != 9'b111111111) begin
//         priority_Out = priority_6;
//     end else if (priority_7 != 9'b111111111) begin
//         priority_Out = priority_7;
//     end else if (priority_8 != 9'b111111111) begin
//         priority_Out = priority_8;
//     end else if (priority_9 != 9'b111111111) begin
//         priority_Out = priority_9;
//     end else begin
//         priority_Out = 9'b11111111;
//     end
// end

// assign out_entity = priority_Out;

// assign out_entity = detector(entity_1, counter_H, counter_V) 
//     & detector(entity_2, counter_H, counter_V) 
//     & detector(entity_3, counter_H, counter_V) 
//     & detector(entity_4, counter_H, counter_V) 
//     & detector(entity_5, counter_H, counter_V) 
//     & detector(entity_6, counter_H, counter_V) 
//     & detector_Array(entity_7_Array, counter_H, counter_V)
//     & detector_Flip(entity_8_Flip, counter_H, counter_V)
//     & detector_Flip(entity_9_Flip, counter_H, counter_V);


// always@(*) begin
//     out_entity = detector(entity_1, counter_H, counter_V) & detector(entity_2, counter_H, counter_V) & detector(entity_3, counter_H, counter_V) & detector(entity_4, counter_H, counter_V) & detector(entity_5, counter_H, counter_V) & detector(entity_6, counter_H, counter_V) & detector(entity_7_Array, counter_H, counter_V) & detector(entity_8, counter_H, counter_V) & detector(entity_9, counter_H, counter_V);
// end


