`include "fade.sv"
`include "ws2812b.sv"
`include "game_of_life.sv"
`include "controller.sv"

module top #(
    parameter PWM_INTERVAL = 126
)(
    input logic clk,
    input logic SW,
    input logic BOOT,
    output logic _48b
);


    logic [7:0] red_data;
    logic [7:0] green_data;
    logic [7:0] blue_data;

    logic [5:0] pixel;
    logic [4:0] frame;

    logic [23:0] shift_reg = 24'd0;
    logic load_sreg;
    logic transmit_pixel;
    logic shift;
    logic ws2812b_out;
    logic [63:0] grid;

    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value_R;
    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value_G;
    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value_B;
    logic [6:0] brightness_r;
    logic [6:0] brightness_g;
    logic [6:0] brightness_b;


    //wiring modules
    fade #(
        .PWM_INTERVAL (PWM_INTERVAL)
    ) u_F (
    //not actually a pwm value, reused from earlier project
        .clk (clk),
        .pwm_value_R (brightness_r),
        .pwm_value_G (brightness_g),
        .pwm_value_B (brightness_b)
    );

        ws2812b u_w (
        .clk            (clk), 
        .serial_in      (shift_reg[23]), 
        .transmit       (transmit_pixel), 
        .ws2812b_out    (ws2812b_out), 
        .shift          (shift)
    );

    controller u_c (
        .clk            (clk), 
        .load_sreg      (load_sreg), 
        .transmit_pixel (transmit_pixel), 
        .pixel          (pixel),
        .frame          (frame)
    );

    game_of_life u_l (
        .clk (clk),
        .grid (grid)
    );

    //assign color based on pixel value and fade timing
    always_comb begin
        if (grid[pixel]) begin
            red_data = {1'b0, brightness_r};
            green_data = {1'b0, brightness_g};
            blue_data = {1'b0, brightness_b};
        end 
        else begin
            red_data = 8'd0;
            green_data = 8'd0;
            blue_data = 8'd0;
        end 
    end 

    //serialization shift logic from example
    always_ff @(posedge clk) begin
        if (load_sreg) begin
            unique case ({ SW, BOOT })
                2'b00:
                    shift_reg <= { green_data, 16'd0 };
                2'b01:
                    shift_reg <= { 8'd0, red_data, 8'd0 };
                2'b10:
                    shift_reg <= { 16'd0, blue_data };
                2'b11:
                    shift_reg <= { green_data, red_data, blue_data };
            endcase
        end
        else if (shift) begin
            shift_reg <= { shift_reg[22:0], 1'b0 };
        end
    end

    assign _48b = ws2812b_out;


endmodule 