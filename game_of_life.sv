module game_of_life(
    input logic clk,
    output logic [63:0] grid
    // output logic [5:0] pixel,
    // output logic load_sreg,
    // output logic transmit_pixel
);
    logic [7:0][7:0] mem;
    //create comb logic
    //wire aray to comb logic

    always_comb begin
        //core 8 pixel checking logic
    end

    always_ff@(posedge clk) begin
        //iterate through 64 pixels
    end 



endmodule

