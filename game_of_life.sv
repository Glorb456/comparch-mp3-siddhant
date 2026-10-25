module game_of_life #(
    parameter STEP_SPEED = 6000000,
    parameter INIT_FILE = ""
)(
    input logic clk,
    output logic [63:0] grid
    // output logic [5:0] pixel,
    // output logic load_sreg,
    // output logic transmit_pixel
);
    logic [7:0] curr_grid [0:7];
    logic [7:0] nxt_grid [0:7];
    logic [7:0] curr_select;
    logic [3:0] select_count;
    logic time_to_send;
    logic curr_cell;
    logic [$clog2(STEP_SPEED) - 1:0] count;

    logic [5:0] cell_idx;
    logic [2:0] row;
    logic [2:0] col;

    logic [2:0] rowm1;
    logic [2:0] colm1;
    logic [2:0] rowp1;
    logic [2:0] colp1;



    //power of 2 so hopefully no bad hardware
    assign row = cell_idx / 8;
    assign col = cell_dx % 8;
    assign rowm1 = cell_idx / 8 - 1;
    assign colm1 = cell_idx % 8 - 1;
    assign rowp1 = cell_idx / 8 + 1;
    assign rowm1 = cell_idx % 8 + 1;
    assign curr_cell = curr_grid[row][col];

    assign curr_select = {curr_grid[rowm1][colm1], 
    curr_grid[rowm1][col],curr_grid[rowm1][colp1], 
    curr_grid[row][colm1],curr_grid[row][colp1],
    curr_grid[rowp1][colm1],curr_grid[rowp1][col],
    curr_grid[rowp1][colp1]};
    //loadmemh

    initial if (INIT_FILE) begin
        $readmemh(INIT_FILE, curr_grid);
    end

    always_ff @(posedge clk) begin
        read_data <= mem[read_address];
    end

    always_ff @(posedge clk) begin
        if (count == STEP_SPEED)
            count <=0;
        else 
            count = count + 1;
    end 

    always_ff@(posedge clk) begin
        if (count == 0) begin
            time_to_send == 1'b0
        end 

        else if (count == 1) begin
            time_to_send <= 1'b1
        end 

        else if (count == 3) begin
            curr_grid <= nxt_grid;
        end 
    end

    always_comb begin 
    end 



    always_ff@(posedge clk) begin 
        //work out wrapped neighbor row/col
        select_count <= $countones(curr_select);


    end 



    always_comb begin
        if (curr_cell) begin
            if (select_count == 2 || select_count == 3) begin
                //set index of next array to 1
            end 
            else begin
                //set index of next array to 0
            end 
        end 
        else begin
            if (select_count == 3) begin
                //set index of next array to 1
            end 
            else begin
                //set index of next array to 0
            end 
        end 

    end 

    always_comb begin
        if (time_to_send)begin
            grid = {curr_grid[7], curr_grid[6], curr_grid[5], curr_grid[4],
                        curr_grid[3], curr_grid[2], curr_grid[1], curr_grid[0]};
            time_to_send <= 0;
        end 
    end 

endmodule

