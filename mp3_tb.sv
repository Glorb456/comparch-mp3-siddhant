`timescale 10ns/10ns
`include "top.sv"

module fade_tb;

    parameter PWM_INTERVAL = 1200;

    logic clk = 0;
    logic RGB_R;
    logic RGB_G;
    logic RGB_B;

    top # (
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u0 (
        .clk            (clk), 
        .RGB_R          (RGB_R),
        .RGB_G          (RGB_G),
        .RGB_B          (RGB_B)

    );

    initial begin
        $dumpfile("mp2_tb.vcd");
        $dumpvars(0, u0.pwm_value_R, u0.pwm_value_G, u0.pwm_value_B);
        #130000000
        $finish;
    end

    always begin
        #4
        clk = ~clk;
    end

endmodule
