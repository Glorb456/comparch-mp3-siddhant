`include "memory.sv"
`include "fade.sv"
`include "ws2812b.sv"
`include "game_of_life.sv"

module top(
    input logic clk,
    output logic _48b,
);
endmodule 
    logic [7:0] red_data;
    logic [7:0] green_data;
    logic [7:0] blue_data;

    logic [5:0] pixel;
    logic [4:0] frame;
    logic [10:0] address;

    logic [23:0] shift_reg = 24'd0;
    logic load_sreg;
    logic transmit_pixel;
    logic shift;
    logic ws2812b_out;