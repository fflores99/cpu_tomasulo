module tomasulo_back_end_cluster (
    input clk,
    input rst,
    /*****Backend interface*****/
    input [31:0] queue_op1_data,
    input [5:0] queue_op1_tag,
    input queue_op1_data_valid,
    /*Operand 2*/
    input [31:0] queue_op2_data,
    input [5:0] queue_op2_tag,
    input queue_op2_data_valid,
    /*Destination*/
    input [5:0] queue_rd_tag,
    input queue_rd_tag_valid,
    /*instruction*/
    input [2:0] queue_funct3,
    /*ALU signals*/
    input queue_alu_en,
    input [2:0] queue_alu_ext,
    /*AGU signals*/
    input queue_agu_en,
    input queue_agu_ls,
    input [31:0] queue_agu_imm,
    /*Mult queue*/
    input queue_mul_en,
    /*Div queue*/
    input queue_div_en,

    output queue_alu_full,
    output queue_agu_full,
    output queue_mul_full,
    output queue_div_full,
    /*****Backend Return*****/
    cdb_if cdb,

    /*Memoory IF*/
    output [31:0] mem_addr,
    output mem_we,
    output [31:0] mem_data_w,
    input [31:0] mem_data_r
);



/*ISSUE queues*/
/*ALU queue*/
wire alu_done, alu_issue, alu_rd_tag_valid, alu_issue_tag_valid;
wire alu_branch, alu_branch_taken, alu_jalr, alu_write_pc;
wire [31:0] alu_op1, alu_op2, alu_res;
wire [5:0] alu_rd_rtag, alu_issue_tag;
wire [2:0] alu_op_ext, alu_funct3;

alu_reservation_queue ALU_QUEUE
(
    .clk(clk),
    .rst(rst),
    /*****Dispatch Interface*****/
    .queue_en(queue_alu_en),
    /*Operand1*/
    .queue_op1_data_in(queue_op1_data),
    .queue_op1_tag_in(queue_op1_tag),
    .queue_op1_data_valid_in(queue_op1_data_valid),
    /*operand2*/
    .queue_op2_data_in(queue_op2_data),
    .queue_op2_tag_in(queue_op2_tag),
    .queue_op2_data_valid_in(queue_op2_data_valid),
    /*Destination token*/
    .queue_rd_tag_in(queue_rd_tag),
    .queue_rd_tag_valid_in(queue_rd_tag_valid),
    /*instruction*/
    .queue_funct3_in(queue_funct3),
    .queue_alu_ext_in(queue_alu_ext),
    /*back pressure*/
    .queue_full(queue_alu_full),
    /*****CDB*****/
    .cdb(cdb),
    /*****To excecution unit*****/
    .ex_done(alu_done),
    .issue_valid(alu_issue),
    /*Operand1*/
    .queue_op1_data_out(alu_op1),
    /*operand2*/
    .queue_op2_data_out(alu_op2),
    /*Destination token*/
    .queue_rd_tag_out(alu_rd_rtag),
    .queue_rd_tag_valid_out(alu_rd_tag_valid),
    /*instruction*/
    .queue_funct3_out(alu_funct3),
    .queue_alu_ext_out(alu_op_ext)
);

/*ALU excecution unit*/
alu_unit ALU_EX (
    .op1(alu_op1),
    .op2(alu_op2),
    .alu_ext(alu_op_ext),
    .funct3(alu_funct3),
    .tag_in(alu_rd_rtag),
    .tag_in_valid(alu_rd_tag_valid),
    .res(alu_res),
    .tag_out(alu_issue_tag),
    .tag_out_valid(alu_issue_tag_valid),
    .branch(alu_branch),
    .branch_taken(alu_branch_taken),
    .jalr(alu_jalr),
    .store_pc(alu_write_pc)
);

/*Mult queue*/
wire mul_done, mul_issue, mul_rd_tag_valid, mul_issue_tag_valid;
wire [31:0] mul_op1, mul_op2, mul_res;
wire [5:0] mul_rd_rtag, mul_issue_tag;
wire [2:0] mul_funct3;

mul_div_reservation_queue MUL_QUEUE
(
    .clk(clk),
    .rst(rst),
    /*****Dispatch Interface*****/
    .queue_en(queue_mul_en),
    /*Operand1*/
    .queue_op1_data_in(queue_op1_data),
    .queue_op1_tag_in(queue_op1_tag),
    .queue_op1_data_valid_in(queue_op1_data_valid),
    /*operand2*/
    .queue_op2_data_in(queue_op2_data),
    .queue_op2_tag_in(queue_op2_tag),
    .queue_op2_data_valid_in(queue_op2_data_valid),
    /*Destination token*/
    .queue_rd_tag_in(queue_rd_tag),
    .queue_rd_tag_valid_in(queue_rd_tag_valid),
    /*instruction*/
    .queue_funct3_in(queue_funct3),
    /*back pressure*/
    .queue_full(queue_mul_full),
    /*****CDB*****/
    .cdb(cdb),
    /*****To excecution unit*****/
    .ex_done(mul_done),
    .issue_valid(mul_issue),
    /*Operand1*/
    .queue_op1_data_out(mul_op1),
    /*operand2*/
    .queue_op2_data_out(mul_op2),
    /*Destination token*/
    .queue_rd_tag_out(mul_rd_rtag),
    .queue_rd_tag_valid_out(mul_rd_tag_valid),
    /*instruction*/
    .queue_funct3_out(mul_funct3)
);

/*MUL excecutionn unit*/
mult_unit MULT_UNIT (
    .clk(clk),
    .rst(rst),
    .queue_en(mul_issue),
    .op1(mul_op1),
    .op2(mul_op2),
    .funct3(mul_funct3),
    .tag_in(mul_rd_rtag),
    .tag_in_valid(mul_rd_tag_valid),
    .res(mul_res),
    .tag_out(mul_issue_tag),
    .tag_out_valid(mul_issue_tag_valid)
);

/*DIV queue*/
/*divt queue*/
wire div_done, div_issue, div_rd_tag_valid, div_issue_tag_valid;
wire div_busy;
wire [31:0] div_op1, div_op2, div_res;
wire [5:0] div_rd_rtag, div_issue_tag;
wire [2:0] div_funct3;

mul_div_reservation_queue DIV_QUEUE
(
    .clk(clk),
    .rst(rst),
    /*****Dispatch Interface*****/
    .queue_en(queue_div_en),
    /*Operand1*/
    .queue_op1_data_in(queue_op1_data),
    .queue_op1_tag_in(queue_op1_tag),
    .queue_op1_data_valid_in(queue_op1_data_valid),
    /*operand2*/
    .queue_op2_data_in(queue_op2_data),
    .queue_op2_tag_in(queue_op2_tag),
    .queue_op2_data_valid_in(queue_op2_data_valid),
    /*Destination token*/
    .queue_rd_tag_in(queue_rd_tag),
    .queue_rd_tag_valid_in(queue_rd_tag_valid),
    /*instruction*/
    .queue_funct3_in(queue_funct3),
    /*back pressure*/
    .queue_full(queue_div_full),
    /*****CDB*****/
    .cdb(cdb),
    /*****To excecution unit*****/
    .ex_done(div_done),
    .issue_valid(div_issue),
    /*Operand1*/
    .queue_op1_data_out(div_op1),
    /*operand2*/
    .queue_op2_data_out(div_op2),
    /*Destination token*/
    .queue_rd_tag_out(div_rd_rtag),
    .queue_rd_tag_valid_out(div_rd_tag_valid),
    /*instruction*/
    .queue_funct3_out(div_funct3)
);

div_unit DIV_UNIT (
    .clk(clk),
    .rst(rst),

    .queue_en(div_issue),
    .op1(div_op1),
    .op2(div_op2),
    .funct3(div_funct3),
    .tag_in(div_rd_rtag),
    .tag_in_valid(div_rd_tag_valid),
    .res(div_res),
    .tag_out(div_issue_tag),
    .tag_out_valid(div_issue_tag_valid),
    .busy(div_busy)
);

/*Memory Unit QUEUE*/
wire agu_done, agu_issue, agu_rd_tag_valid, agu_issue_tag_valid, agu_ls;
wire [31:0] agu_adress, agu_mem_data, agu_res;
wire [5:0] agu_rd_rtag, agu_issue_tag;
wire [2:0] agu_funct3;
agu_reservation_queue AGU_QUEUE
(
    .clk(clk),
    .rst(rst),
    /*****Dispatch Interface*****/
    .queue_en(queue_agu_en),
    /*Operand1*/
    .queue_op1_data_in(queue_op1_data),
    .queue_op1_tag_in(queue_op1_tag),
    .queue_op1_data_valid_in(queue_op1_data_valid),
    /*operand2*/
    .queue_op2_data_in(queue_op2_data),
    .queue_op2_tag_in(queue_op2_tag),
    .queue_op2_data_valid_in(queue_op2_data_valid),
    /*Destination token*/
    .queue_rd_tag_in(queue_rd_tag),
    .queue_rd_tag_valid_in(queue_rd_tag_valid),
    /*instruction*/
    .queue_funct3_in(queue_funct3),
    .queue_agu_ls_in(queue_agu_ls),
    .queue_agu_imm_in(queue_agu_imm),

    /*back pressure*/
    .queue_full(queue_agu_full),
    /*****CDB*****/
    .cdb(cdb),
    /*****To excecution unit*****/
    .ex_done(agu_done),
    .issue_valid(agu_issue),
    /*Operand1*/
    .ex_address(agu_adress),
    /*operand2*/
    .ex_data(agu_mem_data),
    /*Destination token*/
    .queue_rd_tag_out(agu_rd_rtag),
    .queue_rd_tag_valid_out(agu_rd_tag_valid),
    /*instruction*/
    .queue_funct3_out(agu_funct3),
    .queue_agu_ls_out(agu_ls)
);

/*Mem unit*/
agu_unit AGU (

    .agu_issue(agu_issue),
    .addr(agu_adress),
    .data_in(agu_mem_data),
    .ls(agu_ls),
    .tag_in(agu_rd_rtag),
    .tag_in_valid(agu_rd_tag_valid),
    .data_out(agu_res),
    .tag_out(agu_issue_tag),
    .tag_out_valid(agu_issue_tag_valid),

    .mem_we(mem_we),
    .mem_addr(mem_addr),
    .mem_data_w(mem_data_w),
    .mem_data_r(mem_data_r)
);

/*ISSUE UNIT*/
issue_unit ISSUE (
    .clk(clk),
    .rst(rst),
    /*Integer queue*/
    .int_ready(alu_issue),
    .int_result(alu_res),
    .int_tag(alu_issue_tag),
    .int_branch(alu_branch),
    .int_branch_taken(alu_branch_taken),
    .int_jalr(alu_jalr),
    .int_write_pc(alu_write_pc),
    .int_cdb_valid(alu_issue_tag_valid),
    .int_done(alu_done),
    /*mult queue*/
    .mult_ready(mul_issue),
    .mult_result(mul_res),
    .mult_tag(mul_issue_tag),
    .mult_done(mul_done),
    /*Div queue*/
    .div_ready(div_issue),
    .div_busy(div_busy),
    .div_result(div_res),
    .div_tag(div_issue_tag),
    .div_done(div_done),
    /*mem if*/
    .ls_ready(agu_issue_tag_valid),
    .load_data(agu_res),
    .load_tag(agu_issue_tag),
    .ls_done(agu_done),
    /*CDB*/
    .cdb(cdb)
);

endmodule