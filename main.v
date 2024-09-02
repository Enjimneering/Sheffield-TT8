

`include "ppu.v"

module Test_top_module (

    input clk,
    input reset,
    input wire [13:0] entity_1,

    output wire       h_sync,
    output wire       v_sync,
    output wire [3:0] red,
    output wire [3:0] green,
    output wire [3:0] blue


);




    PictureProcessingUnit ppu (

        .clk_100MHz(clk),  
        .reset(reset),   

        //ENTITY SLOTS 
        .entity_1(entity_1),  
            
        // OUTPUT
        .h_sync(h_sync),
        .v_sync(v_sync),
        .red(red),
        .green(green),
        .blue(blue)

    );



endmodule