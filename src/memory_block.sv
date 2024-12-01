/* ASYNC read
 * SYNC write
*/
module memory_block #(
    parameter SIZE = 1024
)
(
    input clk,
    input [$clog2(SIZE) - 1:0] ADD,
    input we,
    input [31:0] DW,
    output [31:0] DR

);

reg [31:0] DATA_MEM [(SIZE/4) - 1:0];
/*Async READ*/
assign DR = DATA_MEM[ADD[$clog2(SIZE) - 1:2]];
/*Sync Write*/
always_ff @( posedge clk ) begin : mem_block

    if(we) begin
		DATA_MEM[ADD[$clog2(SIZE) - 1:2]] <= DW;
	end
end

endmodule