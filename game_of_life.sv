module game_of_life #(
    //steps every half second (12Mhz / 2)
    parameter STEP_SPEED = 6000000,
    parameter INIT_FILE = "initial_states/lwss.txt"
)(
    input logic clk,
    output logic [63:0] grid
);
    logic [7:0] curr_grid [0:7];
    logic [7:0] nxt_grid [0:7];
    logic [7:0] curr_select;
    logic [3:0] select_count;
    logic curr_cell;
    logic [$clog2(STEP_SPEED) - 1:0] count = 0;

    logic [5:0] cell_idx;
    logic [2:0] row;
    logic [2:0] col;

    logic [2:0] rowm1;
    logic [2:0] colm1;
    logic [2:0] rowp1;
    logic [2:0] colp1;



    //power of 2 so hopefully no bad hardware
    //precomputing neighboring indices
    assign row = cell_idx / 8;
    assign col = cell_idx % 8;
    assign rowm1 = cell_idx / 8 - 1;
    assign colm1 = cell_idx % 8 - 1;
    assign rowp1 = cell_idx / 8 + 1;
    assign colp1 = cell_idx % 8 + 1;
    assign curr_cell = curr_grid[row][col];
    assign grid = {curr_grid[7], curr_grid[6], curr_grid[5], curr_grid[4],
                curr_grid[3], curr_grid[2], curr_grid[1], curr_grid[0]};

    //computing amount of alive neighboring cells
    assign curr_select = {curr_grid[rowm1][colm1], 
    curr_grid[rowm1][col],curr_grid[rowm1][colp1], 
    curr_grid[row][colm1],curr_grid[row][colp1],
    curr_grid[rowp1][colm1],curr_grid[rowp1][col],
    curr_grid[rowp1][colp1]};
    assign select_count = $countones(curr_select);


    //read initial state file
    initial if (INIT_FILE) begin
        $readmemh(INIT_FILE, curr_grid);
    end


    //incriment and wrap clock
    always_ff @(posedge clk) begin
        if (count == STEP_SPEED - 1)
            count <= 0;
        else 
            count <= count + 1;
    end 

    //copy nxt_grid into curr_grid, preparing next generation
    always_ff@(posedge clk) begin
        if (count == STEP_SPEED - 2) begin
            for (int i = 0; i < 8; i++) begin
                curr_grid[i] <= nxt_grid[i];
            end 
        end 
    end

    //computing the next state for each of 64 cells
    always_ff@(posedge clk) begin
        if (count > 99 && count < 164)
            cell_idx <= count;
    end

    //core logic of game of life
    //computes state of cell in next gen based on surrounding alive cells
    always_ff@(posedge clk) begin
        if (curr_cell) begin
            if (select_count == 2 || select_count == 3) begin
                nxt_grid[row][col] <= 1'b1;
            end 
            else begin
                nxt_grid[row][col] <= 1'b0;
            end 
        end 
        else begin
            if (select_count == 3) begin
                nxt_grid[row][col] <= 1'b1;
            end 
            else begin
                nxt_grid[row][col] <= 1'b0;
            end 
        end 

    end 
endmodule

