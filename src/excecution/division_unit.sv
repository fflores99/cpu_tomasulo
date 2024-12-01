module div_unit (
    input clk,
    input rst,

    input queue_en,
    input [31:0] op1,
    input [31:0] op2,
    input [2:0] funct3,
    input [5:0] tag_in,
    input tag_in_valid,
    output reg [31:0] res,
    output reg [5:0] tag_out,
    output reg tag_out_valid,
    output reg busy
);

reg [2:0] current_state;
reg [5:0] tag_reg;
reg tag_valid;
reg [2:0] funct3_reg;
reg [31:0] op1_reg, op2_reg;

always_comb begin : out_comb
    
    if(current_state == 3'd0 || current_state == 3'd6) busy = 1'b0;
    else busy = 1'b1;

    if(current_state == 3'd6) begin
        tag_out = tag_reg;
        tag_out_valid = tag_valid;
        if(funct3_reg == 3'd6 || funct3_reg == 3'd7)
            res = op1_reg%op2_reg;
        else
            res = op1_reg/op2_reg;
    end else begin
        tag_out = 6'd0;
        tag_out_valid = 1'b0;
        res = 32'd0;
    end
end

always_ff @( posedge clk, posedge rst ) begin : seq
    if(rst) begin
        current_state <= 3'd0;
        funct3_reg <= 3'd0;
        tag_reg <= 6'd0;
        tag_valid <= 1'b0;
        op1_reg <= 32'd0;
        op2_reg <= 32'd0;
    end else begin
        case (current_state)
            3'd0: 
                if(queue_en) begin
                    current_state <= 3'd1;
                    funct3_reg <= funct3;
                    tag_reg <= tag_in;
                    tag_valid <= tag_in_valid;
                    op1_reg <= op1;
                    op2_reg <= op2;
                end else begin
                    current_state <= 3'd0;
                    funct3_reg <= funct3_reg;
                    tag_reg <= tag_reg;
                    tag_valid <= tag_valid;
                    op1_reg <= op1_reg;
                    op2_reg <= op2_reg;
                end
            3'd1: current_state <= 3'd2;
            3'd2: current_state <= 3'd3;
            3'd3: current_state <= 3'd4;
            3'd4: current_state <= 3'd5;
            3'd5: current_state <= 3'd6;
            3'd6: current_state <= 3'd0;
            default: current_state <= 3'd0;
        endcase
    end
end
endmodule