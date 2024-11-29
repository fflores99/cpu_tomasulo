module register_file (
	input clk,
	input rst,
	input we,
/*Inputs*/
	input [4:0] RS1,
	input [4:0] RS2,
	input [4:0] RD,
	
	input[31:0] DATA_IN,
/*Outputs*/
	output [31:0] RS1_DATA,
	output [31:0] RS2_DATA
);

wire [31:0] REG_OUT_ARRAY [31:0];
wire [31:0] WRITE_SELECT;

one_hot_param #(.WIDTH(32)) REG_WS (
	.SEL(RD),
	.ONE_HOT(WRITE_SELECT)
);
/*Register 0*/
reg_param #(.LENGTH(32), .RESET_VALUE(32'd0)) REG_ZERO (
	.clk(clk), /*System Clock*/
	.en(WRITE_SELECT[0] & 1'b0), /*Enable on High*/
	.rst(1'b1), /*REset on high*/
   .DATA_IN(DATA_IN), /*Data input of LENGTH bits*/
   .DATA_OUT(REG_OUT_ARRAY[0]) /*Data output of LENGTH bits*/
);
genvar i;
generate
	for(i=1;i<32;i=i+1)
	begin: reg_array
		reg_param #(.LENGTH(32), .RESET_VALUE(32'd0)) REG_X (
			.clk(clk), /*System Clock*/
			.en(WRITE_SELECT[i] & we), /*Enable on High*/
			.rst(rst), /*REset on high*/
			.DATA_IN(DATA_IN), /*Data input of LENGTH bits*/
			.DATA_OUT(REG_OUT_ARRAY[i]) /*Data output of LENGTH bits*/
		); 
	end
endgenerate
/*RS1 MUX*/
mux_param #(.WIDTH(32), .N(32)) RS1_MUX (
	.X(REG_OUT_ARRAY),
	.SEL(RS1),
	.Y(RS1_DATA)
);

/*RS2 MUX*/
mux_param #(.WIDTH(32), .N(32)) RS2_MUX (
	.X(REG_OUT_ARRAY),
	.SEL(RS2),
	.Y(RS2_DATA)
);
endmodule

