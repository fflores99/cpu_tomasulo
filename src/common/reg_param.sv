/****************************************
 * Company: ITESO
 ****************************************
 * Engineer: Francisco Flores
 * Date: Feb 2024
 ****************************************
 * Description: This is a PIPO register
 * with reset on high and enable on high.
 * It's data width is parametrized.
 ****************************************/
module reg_param #(
	parameter LENGTH = 32,
	parameter RESET_VALUE = 32'd0
)
(
/*Inputs*/
	/*Control*/
	input clk, /*System Clock*/
	input en, /*Enable on High*/
	input rst, /*REset on high*/
	/*Data*/
	input [LENGTH - 1:0] DATA_IN, /*Data input of LENGTH bits*/
/*Outputs*/
	output reg [LENGTH - 1:0] DATA_OUT /*Data output of LENGTH bits*/
);

always @(posedge clk, posedge rst)
begin
	if (rst)
	/*Reset event*/
		DATA_OUT <= RESET_VALUE;
	else
		if (en)
			DATA_OUT <= DATA_IN;
		else
			DATA_OUT <= DATA_OUT;
end
endmodule