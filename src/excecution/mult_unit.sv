module mult_unit (
    input clk,
    input rst,

    input queue_en,
    input [31:0] op1,
    input [31:0] op2,
    input [2:0] funct3,
    input [5:0] tag_in,
    input tag_in_valid,
    output [31:0] res,
    output [5:0] tag_out,
    output tag_out_valid
);

assign branch = 1'b0;
assign branch_taken = 1'b0;
assign jalr = 1'b0; 
assign store_pc = 1'b0;


wire [64:0] mult_res;
wire [31:0] P[3];
wire [5:0] tag_out_reg[3];
wire tag_out_valid_reg[3];


assign tag_out_reg[0] = (queue_en) ? tag_in : 6'd0;
assign tag_out_valid_reg[0] = (queue_en) ? tag_in_valid : 1'b0;

assign mult_res = op1 * op2;

assign P[0] = (queue_en) ? ((funct3 == 3'd0) ? mult_res[31:0] : mult_res[63:32]) : 32'd0;

reg_param #(
	.LENGTH(39),
	.RESET_VALUE(39'h00000000)
)
P1
(
	.clk(clk),
	.en(1'b1),
	.rst(rst), 
	.DATA_IN({P[0],tag_out_reg[0],tag_out_valid_reg[0]}),
	.DATA_OUT ({P[1],tag_out_reg[1],tag_out_valid_reg[1]})
);

reg_param #(
	.LENGTH(39),
	.RESET_VALUE(39'h00000000)
)
P2
(
	.clk(clk),
	.en(1'b1),
	.rst(rst), 
	.DATA_IN({P[1],tag_out_reg[1],tag_out_valid_reg[1]}),
	.DATA_OUT ({P[2],tag_out_reg[2],tag_out_valid_reg[2]})
);

reg_param #(
	.LENGTH(39),
	.RESET_VALUE(39'h00000000)
)
P3
(
	.clk(clk),
	.en(1'b1),
	.rst(rst), 
	.DATA_IN({P[2],tag_out_reg[2],tag_out_valid_reg[2]}),
	.DATA_OUT ({res,tag_out,tag_out_valid})
);

endmodule