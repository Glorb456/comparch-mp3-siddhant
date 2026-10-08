module fade #(
    parameter INC_DEC_INTERVAL = 10000,
    parameter INC_DEC_MAX = 200,
    parameter SECTOR_INTERVAL = INC_DEC_INTERVAL * INC_DEC_MAX,
    parameter PWM_INTERVAL = 1200,
    parameter INC_DEC_VAL = PWM_INTERVAL / INC_DEC_MAX
)(
    input logic clk,
    output logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value_R,
    output logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value_G,
    output logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value_B
);

    localparam INC = 2'b00;
    localparam DEC = 2'b01;
    localparam HIGH = 2'b10;
    localparam LOW = 2'b11;

    logic [2:0] curr_sector = 0;
    logic [$clog2(INC_DEC_INTERVAL) - 1:0] count = 0;
    logic [$clog2(SECTOR_INTERVAL) - 1:0] sector_count = 0;
    logic advance_sector = 1'b0;
    logic time_to_inc_dec = 1'b0;

    logic [1:0] cond_R;
    logic [1:0] cond_G;
    logic [1:0] cond_B;

    initial begin
        pwm_value_R <= 0;
        pwm_value_G <= 0;
        pwm_value_B <= 0; 
    end 

    always_ff @(posedge clk) begin
        if (count == INC_DEC_INTERVAL - 1) begin
            count <= 0;
            time_to_inc_dec <= 1'b1;
        end
        else begin
            count <= count + 1;
            time_to_inc_dec <= 1'b0;
        end
    end 

    always_ff @(posedge clk) begin 
        if (advance_sector) begin
            if (curr_sector == 5) begin
                curr_sector <= 0;
            end
            else begin
                curr_sector <= curr_sector + 1;
            end 
        end 
        
    end 

    always_ff @(posedge clk) begin
        if (sector_count == SECTOR_INTERVAL - 1) begin
            sector_count <= 0;
            advance_sector <= 1'b1;
        end
        else begin
            sector_count <= sector_count + 1;
            advance_sector <= 1'b0;
        end
    end 

    always_comb begin
        case (curr_sector)
            3'd0: 
                begin 
                    cond_R = HIGH;
                    cond_G = INC;
                    cond_B = LOW;
                end 
            3'd1:
                begin
                    cond_R = DEC;
                    cond_G = HIGH;
                    cond_B = LOW;
                end 
            3'd2:
                begin 
                    cond_R = LOW;
                    cond_G = HIGH;
                    cond_B = INC;
                end 
            3'd3:
                begin 
                    cond_R = LOW;
                    cond_G = DEC;
                    cond_B = HIGH;
                end 
            3'd4:
                begin 
                    cond_R = INC;
                    cond_G = LOW;
                    cond_B = HIGH;
                end 
            3'd5:
                begin 
                    cond_R = HIGH;
                    cond_G = LOW;
                    cond_B = DEC;
                end 
            default: 
                begin
                    cond_R = HIGH;
                    cond_G = INC;
                    cond_B = LOW;
                end 
        endcase 
    end 

    always_ff @(posedge clk) begin
        if (time_to_inc_dec) begin
            case (cond_R)
                INC: pwm_value_R <= pwm_value_R + INC_DEC_VAL;
                DEC: pwm_value_R <= pwm_value_R - INC_DEC_VAL;
                HIGH: pwm_value_R <=PWM_INTERVAL;
                LOW:pwm_value_R <= 0;
            endcase

            case (cond_G)
                INC: pwm_value_G <= pwm_value_G + INC_DEC_VAL;
                DEC: pwm_value_G <= pwm_value_G - INC_DEC_VAL;
                HIGH: pwm_value_G <= PWM_INTERVAL;
                LOW:pwm_value_G <= 0;
            endcase 

            case (cond_B)
                INC: pwm_value_B <= pwm_value_B + INC_DEC_VAL;
                DEC: pwm_value_B <= pwm_value_B - INC_DEC_VAL;
                HIGH: pwm_value_B <= PWM_INTERVAL;
                LOW: pwm_value_B <= 0;
            endcase 
        end
    end 




endmodule
