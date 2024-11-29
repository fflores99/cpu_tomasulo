module ifq (
    input clk,
    input rst,
    /*Program Memory Interface*/
    input d_valid,
    input [127:0] mem_data,
    output abort,
    output m_rd_en,
    output [31:0] mem_addr,
    /*Dispatch Interface*/
    input jump_branch_valid,
    input [31:0] jump_branch_add,
    input d_rd_en,
    output empty,
    output [31:0] i_code,
    output [31:0] pc_out
);

wire ifq_full;
wire [31:0] NEXT_FETCH, MEM_ADD_PLUS_16;

wire [31:0] NEXT_PC, PC_PLUS_4;

wire [127:0] BUFF_OUT;
/*Memory Fetcher counter*/
reg_param #(
	.LENGTH(32),
	.RESET_VALUE(32'h00400000)
)
PMEM_ADD_REG
(
/*Inputs*/
	/*Control*/
	.clk(clk), /*System Clock*/
	.en(~ifq_full | jump_branch_valid), /*Enable next fetch if ifq not empty or a jump/branch*/
	.rst(rst), /*REset on high*/
	/*Data*/
	.DATA_IN(NEXT_FETCH), /*Data input of LENGTH bits*/
/*Outputs*/
	.DATA_OUT(mem_addr) /*Data output of LENGTH bits*/
);

/*Adder for next fetch*/
adder_param #(
    .WIDTH(32)
)
PMEM_ADDER
(
    .A(32'd16),
    .B(mem_addr),
    .S(MEM_ADD_PLUS_16),
    .carry()
);

/* PMEM_ADDRESS_MUX
 *
 * SEL = 0, NEXT_FETCH = mem_addr + 16
 * SEL = 1, NEXT_FETCH = branch/jump pc
*/
mux_param #(
    .WIDTH(32), 
    .N(2)
)
PMEM_MUX
(
    .X('{jump_branch_add,MEM_ADD_PLUS_16}),
    .SEL(jump_branch_valid),
    .Y(NEXT_FETCH)
);

/*PC Dispatcher counter*/
reg_param #(
	.LENGTH(32),
	.RESET_VALUE(32'h00400000)
)
PC_REG
(
/*Inputs*/
	/*Control*/
	.clk(clk), /*System Clock*/
	.en((d_rd_en & ~empty) | jump_branch_valid), /*Enable next fetch if ifq not empty or a jump/branch*/
	.rst(rst), /*REset on high*/
	/*Data*/
	.DATA_IN(NEXT_PC), /*Data input of LENGTH bits*/
/*Outputs*/
	.DATA_OUT(pc_out) /*Data output of LENGTH bits*/
);
/*Adder for next PC*/
adder_param #(
    .WIDTH(32)
)
PC_ADDER
(
    .A(32'd4),
    .B(pc_out),
    .S(PC_PLUS_4),
    .carry()
);
/* PC_SRC_MUX
 *
 * SEL = 0, NEXT_PC = pc + 4
 * SEL = 1, NEXT_PC = branch/jump pc
*/
mux_param #(
    .WIDTH(32), 
    .N(2)
)
PC_SRC_MUX
(
    .X('{jump_branch_add,PC_PLUS_4}),
    .SEL(jump_branch_valid),
    .Y(NEXT_PC)
);

/*Circular Buffer*/
circular_buff #(
.LENGTH(128),
.SIZE(4)
)
BUFF 
(
    .clk(clk),
    .rst(rst),
    .flush(jump_branch_valid), /*FLUSH when a PC needs to be adjusted*/
    .push(d_valid & ~ifq_full),
    .pull((pc_out[2] & pc_out[3]) & ~empty & d_rd_en),
    .data_write(mem_data),
    .data_read(BUFF_OUT),
    .full(ifq_full),
    .empty(empty),
    .write_ptr(),
    .read_ptr()
);

/*Instruction mux*/
/* ICODE_SELECTOR
*/
mux_param #(
    .WIDTH(32), 
    .N(4)
)
ICODE_MUX
(
    .X('{BUFF_OUT[127:96],BUFF_OUT[95:64],BUFF_OUT[63:32],BUFF_OUT[31:0]}),
    .SEL(pc_out[3:2]),
    .Y(i_code)
);

assign abort = 1'b0;
assign m_rd_en = ~ifq_full;
endmodule