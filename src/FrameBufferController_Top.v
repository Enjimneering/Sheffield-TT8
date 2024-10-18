module FrameBufferController_Top(
    input clk_in,  
    input reset,    
    input wire [13:0] entity_1,  //entity input form: ([13:10] entity ID, [9:8] Orientation, [7:0] Location(tile)).
    input wire [13:0] entity_2,  //Simultaneously supports up to 9 objects in the scene.
    input wire [13:0] entity_3,  //Set the entity ID to 4'hf for unused channels.
    input wire [13:0] entity_4,
    input wire [13:0] entity_5,
    input wire [13:0] entity_6,
    input wire [17:0] entity_7_Array, //Array function disable
    input wire [13:0] entity_8_Flip,
    input wire [13:0] entity_9_Flip,
    input wire [9:0] counter_V,
    input wire [9:0] counter_H,

    output reg colour // 0-black 1-white
    );

localparam [2:0] UPSCALE_FACTOR = 5;
localparam [3:0] TILE_SIZE = 8;
localparam [9:0] TILE_LEN_PIXEL = 40;
localparam [3:0] SCREENSIZE_H_BDRY = 15;
localparam [3:0] SCREENSIZE_V_BDRY= 11;

wire clk = clk_in;
// wire locked;
// Clock
// clk_wiz_0 inst(
//     .clk_in1(clk_in),
//     .reset(reset),

//     .clk_out1(clk),
//     .locked(locked)
// );

reg [3:0] entity_Counter; //Point to the entity list
reg [17:0] general_Entity; //Entity reg
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


always@(posedge clk)begin //Break the pixel counter into h/v tile counter and tile row/col counter 
    if(!reset)begin
            // preV <= counter_V;
            // if (preV != counter_V)begin
                
            //     if(upscale_Counter_V != (UPSCALE_FACTOR-1)) begin
            //         upscale_Counter_V <= upscale_Counter_V + 1;
            //     end else begin
            //         upscale_Counter_V <= 0;
            //         colCounter <= colCounter + 1;
            //     end
                
            //     if (counter_V >= TILE_LEN_PIXEL)begin
            //         if(colCounter == 3'b111 && upscale_Counter_V == (UPSCALE_FACTOR-1) && Counter_V_Tile != SCREENSIZE_V_BDRY)begin
            //             Counter_V_Tile <= Counter_V_Tile + 1;
            //         end else if(colCounter == 3'b111 && upscale_Counter_V == (UPSCALE_FACTOR-1) && Counter_V_Tile == SCREENSIZE_V_BDRY) begin
            //             Counter_V_Tile <= 0;
            //         end else begin
            //             Counter_V_Tile <= Counter_V_Tile;
            //         end
            //     end else begin
            //         Counter_V_Tile <= 0;
            //     end

            // end else begin
            //     Counter_V_Tile <= Counter_V_Tile;
            //     upscale_Counter_V <= upscale_Counter_V;
            //     colCounter <= colCounter;
            // end

            // preH <= counter_H;
            // if (preH != counter_H )begin

            //     if(upscale_Counter_H != (UPSCALE_FACTOR-1))begin
            //         upscale_Counter_H <= upscale_Counter_H + 1;
            //     end else begin
            //         upscale_Counter_H <= 0;
            //         rowCounter <= rowCounter + 1;
            //     end
                
            //     if (counter_H >= TILE_LEN_PIXEL) begin
            //         if(rowCounter == 3'b111 && upscale_Counter_H == (UPSCALE_FACTOR-1))begin
            //             Counter_H_Tile <= Counter_H_Tile + 1;
            //         end else begin
            //             Counter_H_Tile <= Counter_H_Tile;
            //         end
            //     end else begin
            //         Counter_H_Tile <= 0;
            //     end

            // end else begin
            //     Counter_H_Tile <= Counter_H_Tile;
            //     upscale_Counter_H <= upscale_Counter_H;
            //     rowCounter <= rowCounter;
            // end
            rowCounter <= rowCounter + 1;
            upscale_Counter_H <= upscale_Counter_H +1;
            Counter_H_Tile <= Counter_H_Tile + 1;
            colCounter <= colCounter + 1;
            upscale_Counter_V <= upscale_Counter_V + 1;
            Counter_V_Tile <= Counter_V_Tile + 1;

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

wire [3:0] next_HPos = (Counter_H_Tile + 1);
wire [3:0] curDet_Hpos = (local_Counter_H);
wire hpos_update = next_HPos != curDet_Hpos;

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

        // local_Counter_H <= Counter_H_Tile + 1;
        // if(colCounter == 3'b111 && upscale_Counter_H == (UPSCALE_FACTOR-1) && Counter_H_Tile == 15 && rowCounter == 7 && upscale_Counter_H == (UPSCALE_FACTOR-1))begin
        //     if(Counter_V_Tile != SCREENSIZE_V_BDRY)begin 
        //         local_Counter_V <= Counter_V_Tile + 1;
        //     end else begin
        //         local_Counter_V <= 0;
        //     end
        // end else begin
        //     local_Counter_V <= Counter_V_Tile;
        // end

        // if (entity_Counter != 8 && entity_Counter != 4'd15)begin
        //     entity_Counter <= entity_Counter + 1;
        // end else if (hpos_update)begin
        //     entity_Counter <=0;
        // end else begin
        //     entity_Counter <= 4'd15;
        // end

    end else begin
        flip_Or_Array_Flag <= 2'b11;
        entity_Counter <= 4'b0000;
        general_Entity <=18'b111111000000000000;
        local_Counter_H <= 0;
        local_Counter_V <= 0;
    end
    
end

wire inRange;
assign inRange = ((((local_Counter_H - general_Entity[11:8])) == 0) && (((local_Counter_V - general_Entity[7:4])) == 0));

reg [8:0] detector;
reg [8:0] out_entity;

always @(posedge clk) begin
    if (!reset) begin

        // if (!(rowCounter == 7 && upscale_Counter_H == (UPSCALE_FACTOR-2)))begin //Update the entity index one cycle in advance (ROM lookup requires one cycle)
        //     out_entity <= out_entity;
            
        //     if ((inRange && (general_Entity[17:14] != 4'b1111)) && (flip_Or_Array_Flag != 2'b11)) begin

        //         if (flip_Or_Array_Flag == 2'b01) begin
        //             detector <= {~(colCounter),general_Entity[17:12]};
        //         end else begin
        //             detector <= {(colCounter),general_Entity[17:12]};
        //         end

        //     end else begin
        //         detector <= detector;
        //     end
        // end else begin
        //     out_entity <= detector; //Update Entity index
        //     detector <= 9'b111111111;
        // end
        detector <= inRange;
        out_entity <= general_Entity;
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
    end else begin
    colour <= 1'b1;
    end
end

endmodule
