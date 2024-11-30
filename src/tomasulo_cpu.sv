module tomasulo_cpu (
    input clk,
    input rst,

    output [31:0] p_mem_add,
    input [31:0] p_mem_data,

    output [31:0] d_mem_add,
    output d_mem_we,
    input [31:0] d_mem_data_r,
    output [31:0] d_mem_data_w
);   


    /*****Memory Interface*****/
    wire [127:0] mem_data;
    wire abort;
    wire m_rd_en;
    wire [31:0] mem_addr;
    /*****Backend interface*****/
    wire [31:0] queue_op1_data;
    wire [5:0] queue_op1_tag;
    wire queue_op1_data_valid;
    /*Operand 2*/
    wire [31:0] queue_op2_data;
    wire [5:0] queue_op2_tag;
    wire queue_op2_data_valid;
    /*Destination*/
    wire [5:0] queue_rd_tag;
    wire queue_rd_tag_valid;
    /*instruction*/
    wire [2:0] queue_funct3;
    /*ALU signals*/
    wire queue_alu_en;
    wire [2:0] queue_alu_ext;
    /*AGU signals*/
    wire queue_agu_en;
    wire queue_agu_ls;
    wire [31:0] queue_agu_imm;
    /*Mult queue*/
    wire queue_mul_en;
    /*Div queue*/
    wire queue_div_en;
    wire alu_full, agu_full, div_full, mul_full;
    cdb_if cdb();

    tomasulo_front_end_cluster UUT (
        .clk(clk),
        .rst(rst),
        .d_valid(1'b1),
        .mem_data(mem_data),
        .abort(abort),
        .m_rd_en(m_rd_en),
        .mem_addr(mem_addr),
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
        .div_full(div_full),
        .cdb(cdb)
    );

tomasulo_back_end_cluster (
    .clk(clk),
    .rst(rst),
    /*****Backend interface*****/
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
    .queue_mul_en(queue_mul_en),
    /*Div queue*/
    .queue_div_en(queue_div_en),

    .queue_alu_full(alu_full),
    .queue_agu_full(agu_full),
    .queue_mul_full(mul_full),
    .queue_div_full(div_full),
    /*****Backend Return*****/
    .cdb(cdb),
    /*Memoory IF*/
    .mem_addr(d_mem_add),
    .mem_we(d_mem_we),
    .mem_data_w(d_mem_data_w),
    .mem_data_r(d_mem_data_r)
);

endmodule