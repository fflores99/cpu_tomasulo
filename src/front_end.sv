module tomasulo_front_end_cluster (
    input clk,
    input rst,
    /*****Memory Interface*****/
    input d_valid,
    input [127:0] mem_data,
    output abort,
    output m_rd_en,
    output [31:0] mem_addr,
    /*****Backend interface*****/
    output [31:0] queue_op1_data,
    output [5:0] queue_op1_tag,
    output queue_op1_data_valid,
    /*Operand 2*/
    output [31:0] queue_op2_data,
    output [5:0] queue_op2_tag,
    output queue_op2_data_valid,
    /*Destination*/
    output [5:0] queue_rd_tag,
    output queue_rd_tag_valid,
    /*instruction*/
    output [2:0] queue_funct3,
    /*ALU signals*/
    output queue_alu_en,
    output [2:0] queue_alu_ext,
    /*AGU signals*/
    output queue_agu_en,
    output queue_agu_ls,
    output [31:0] queue_agu_imm,
    /*Mult queue*/
    output queue_mul_en,
    /*Div queue*/
    output queue_div_en,
    input alu_full,
    input mul_full,
    input agu_full,
    input div_full,
    /*****Backend Return*****/
    cdb_if cdb
);

/*Dispatch IF*/
wire jump_branch_valid;
wire [31:0] jump_branch_add;
wire d_rd_en;
wire empty;
wire [31:0] i_code;
wire [31:0] pc_out;

ifq IFQ (
    .clk(clk),
    .rst(rst),
    /*Program Memory Interface*/
    .d_valid(d_valid),
    .mem_data(mem_data),
    .abort(abort),
    .m_rd_en(m_rd_en),
    .mem_addr(mem_addr),
    /*Dispatch Interface*/
    .jump_branch_valid(jump_branch_valid),
    .jump_branch_add(jump_branch_add),
    .d_rd_en(d_rd_en),
    .empty(empty),
    .i_code(i_code),
    .pc_out(pc_out)
);

dispatch_unit DPCH_UNIT (
    .clk(clk),
    .rst(rst),
    /*IFQ interface signals*/
    .ifq_pc(pc_out),
    .ifq_icode(i_code),
    .ifq_empty(empty),
    .dpch_jmp_br_addr(jump_branch_add),
    .dpch_rd(d_rd_en),
    .dpch_jmp(jump_branch_valid),
    /*CDB interface*/
    .cdb(cdb),
    /***Queue iunterface***/
    /*Operand 1*/
    .queue_op1_data(queue_op1_data),
    .queue_op1_tag(queue_op1_tag),
    .queue_op1_data_valid(queue_op1_data_valid),
    /*Operand 2*/
    .queue_op2_data(queue_op2_data),
    .queue_op2_tag(queue_op2_tag),
    .queue_op2_data_valid(queue_op2_data_valid),
    /*Destination*/
    .queue_rd_tag(queue_rd_tag),
    .queue_rd_tag_valid(queue_rd_tag_valid),
    /*instruction*/
    .queue_funct3(queue_funct3),
    /*ALU signals*/
    .queue_alu_en(queue_alu_en),
    .queue_alu_ext(queue_alu_ext),
    /*AGU signals*/
    .queue_agu_en(queue_agu_en),
    .queue_agu_ls(queue_agu_ls),
    .queue_agu_imm(queue_agu_imm),
    /*Mult queue*/
    .queue_mul_en(queue_mul_en),
    /*Div queue*/
    .queue_div_en(queue_div_en),
    .alu_full(alu_full),
    .mul_full(mul_full),
    .agu_full(agu_full),
    .div_full(div_full)
);

endmodule