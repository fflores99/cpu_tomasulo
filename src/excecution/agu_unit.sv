module agu_unit (

    input agu_issue,
    input [31:0] addr,
    input [31:0] data_in,
    input ls,
    input [5:0] tag_in,
    input tag_in_valid,
    output [31:0] data_out,
    output [5:0] tag_out,
    output tag_out_valid,


    /*data memory if*/
    output mem_we,
    output [31:0] mem_addr,
    output [31:0] mem_data_w,
    input [31:0] mem_data_r
);

assign mem_we = ls;
assign mem_addr = addr;
assign mem_data_w = data_in;
assign data_out = mem_data_r;

assign tag_out = tag_in;
assign tag_out_valid = tag_in_valid;

endmodule