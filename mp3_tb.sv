`timescale 10ns/10ns
`include "game_of_life.sv"

module game_of_life_tb;

    parameter STEP_SPEED = 200;
    parameter INIT_FILE  = "initial_states/lwss.txt";

    logic clk = 0;
    logic [63:0] grid;
    logic [63:0] save_grid;

    game_of_life # (
        .STEP_SPEED(STEP_SPEED),
        .INIT_FILE(INIT_FILE)
    ) u0 (
        .clk            (clk), 
        .grid           (grid)
    );

    initial begin
        $dumpfile("mp3_tb.vcd");
        $dumpvars(0, u0.grid);
        @(posedge clk);
        save_grid = grid;
        for (int k = 0; k < 32; k++)begin
            for (int i = 0; i < 8; i++)begin
                for (int j = 7; j >-1; j--) begin
                    $write("%s", (grid[i*8 + j] ==1) ? "# " : ". ");
                end
            $display;
            end
            $display;
            repeat (STEP_SPEED) @(posedge clk);
        end 
        $finish;
    end

    always begin
        #4
        clk = ~clk;
    end

endmodule
