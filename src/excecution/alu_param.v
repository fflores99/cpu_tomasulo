/****************************************
 * Company: ITESO
 ****************************************
 * Engineer: Francisco Flores
 * Date: Feb 2024
 ****************************************
 * Description: This module perform Logic
 * and arithmetic operations bases on the
 * selection of a Op signal. Operations
 * are:
 * OP   | Operation  |
 *______|____________|
 * 0000 | A + B	   |
 * 0001 | A - B	   |
 * 0010 |-1 X A 	   |
 * 0011 | A X B	   |
 * 0100 | A & B	   |
 * 0101 | A | B	   |
 * 0110 | ~A	      |
 * 0111 | A ^ B	   |
 * 1000 | A << B[3:0]|
 * 1001 | A >> B[3:0	|
 * -    | 0     	   |
 *___________________|
 ****************************************/

module alu_param #(parameter LENGTH = 8) (
	/*Inputs*/
	input signed [LENGTH - 1:0] A,
	input signed [LENGTH - 1:0] B,
	/*Operation selector*/
	input [3:0] Op,
	/*Flags*/
	output reg c, /*carry*/
	output z, /*zero*/
	output reg n, /*negative*/
	output reg o, /*negative*/
	/*Output*/
	output reg signed [LENGTH - 1:0] Y
);

localparam ADD_O    = 4'b0000;
localparam SUB_O    = 4'b0001;
localparam NEG_O    = 4'b0010;
localparam MUL_O    = 4'b0011;
localparam AND_O    = 4'b0100;
localparam OR_O     = 4'b0101;
localparam INV_O    = 4'b0110;
localparam XOR_O    = 4'b0111;
localparam LSHIFT_O = 4'b1000;
localparam RSHIFT_O = 4'b1001;
localparam SLT_O	= 4'b1010;

localparam signed UP_LIMIT = {1'b0,{(LENGTH - 1){1'b1}}};
localparam signed LOW_LIMIT = {1'b1,{(LENGTH - 1){1'b0}}};

reg  [LENGTH - 1:0] sum;
wire [LENGTH - 1:0] a_us;
wire [LENGTH - 1:0] b_us , b_us_c2;

wire signed [2*LENGTH - 1:0] mul_r;
assign mul_r = A*B;

assign a_us = A;
assign b_us = B;
assign b_us_c2 = ~b_us + 1;
assign z = (Y == {LENGTH{1'b0}})? 1'b1 : 1'b0;
//assign n = (Y < 0) ? 1'b1 : 1'b0;

always @(*)
begin
	case(Op)
		ADD_O: begin
			{c,sum} = (a_us + b_us);
			Y = sum[LENGTH - 1:0];
			//c = (A[LENGTH - 1] & A[LENGTH - 1]) | Y[LENGTH - 1];
			n = Y[LENGTH - 1];
			o = 1'b0;
		end
		SUB_O: begin
			{c,sum} = (a_us + b_us_c2);
			Y = sum[LENGTH - 1:0];
			//c = (A[LENGTH - 1] & A[LENGTH - 1]) | Y[LENGTH - 1];
			n = Y[LENGTH - 1];
			o = 1'b0;
		end
		NEG_O: begin
			Y = ~A + 1;
			c = 1'b0;
			n = ~A[LENGTH - 1];
			o = 1'b0;
			sum = {LENGTH{1'b0}};
		end
		MUL_O: begin
			Y = mul_r[LENGTH - 1:0];
			//Y = sum[LENGTH - 1:0];
			c = 1'b0;
			n = Y[LENGTH-1];
			o = (mul_r > UP_LIMIT || mul_r < LOW_LIMIT) ? 1'b1: 1'b0;
			sum = {LENGTH{1'b0}};
		end
		AND_O: begin
			Y = A&B;
			c = 1'b0;
			n = 1'b0;
			o = 1'b0;
			sum = {LENGTH{1'b0}};
		end
		OR_O: begin
			Y = A|B;
			c = 1'b0;
			n = 1'b0;
			o = 1'b0;
			sum = {LENGTH{1'b0}};
		end
		INV_O: begin
			Y = ~A;
			c = 1'b0;
			n = 1'b0;
			o = 1'b0;
			sum = {LENGTH{1'b0}};
		end
		XOR_O: begin
			Y = A^B;
			c = 1'b0;
			n = 1'b0;
			o = 1'b0;
			sum = {LENGTH{1'b0}};
		end
		LSHIFT_O: begin
			Y = A << B[4:0];
			c = 1'b0;
			n = 1'b0;
			o = 1'b0;
			sum = {LENGTH{1'b0}};
		end
		RSHIFT_O: begin
			Y = A >> B[4:0];
			c = 1'b0;
			n = 1'b0;
			o = 1'b0;
			sum = {LENGTH{1'b0}};
		end
		SLT_O: begin
			Y[LENGTH - 1:1] = {(LENGTH - 1){1'b0}};
			Y[0] = (A < B) ? 1'b1 : 1'b0;
			c = 1'b0;
			n = 1'b0;
			o = 1'b0;
			sum = {LENGTH{1'b0}};
		end
		default: begin
			Y = {LENGTH{1'b0}};
			c = 1'b0;
			n = 1'b0;
			o = 1'b0;
			sum = {LENGTH {1'b0}};
		end
	endcase
end

endmodule