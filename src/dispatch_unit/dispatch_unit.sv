module dispatch_unit (
    input clk,
    input rst,
    /*IFQ interface signals*/
    input [31:0] ifq_pc,
    input [31:0] ifq_icode,
    input ifq_empty,
    output [31:0] dpch_jmp_br_addr,
    output dpch_rd,
    output dpch_jmp,
    /*CDB interface*/
    cdb_if cdb,
    /***Queue iunterface***/
    /*Operand 1*/
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
    input div_full
);

/***************************************************
* GENERAL SIGNALS                                  *
***************************************************/
/*JUMP ADDRESS CALCULATOR*/
wire alu_en, agu_en, mul_en, div_en;
wire [31:0] jac_imm; /*Immediate value decoded from isntruction and formated in a 32-bit signed integer*/
/*RSx SELECTOR*/
wire [31:0] rs1_reg_data;
wire rs1_cdb_fw;
wire [31:0] rs2_reg_data;
wire rs2_cdb_fw;
/*TOKEN MANAGER*/
wire [4:0] rf_rd;
wire rf_we;
wire [5:0] rs1_tag;
wire rs1_tag_valid;
wire [5:0] rs2_tag;
wire rs2_tag_valid;
/*STALL LOGIC*/
wire nstall;
wire staller_br_addr_reg_en;
/*DISPATCH CONTROL*/
wire [1:0] ctrl_op1_sel;
wire ctrl_op2_sel;
wire ctrl_branch;
wire ctrl_jmp_reg;
wire ctrl_jmp;
wire ctrl_reg_w;
wire [4:0] icode_rs1;
wire [4:0] icode_rs2;
wire [4:0] icode_rd;
wire [2:0] icode_funct3;
/*PC QUEUE TO STORE*/
wire [31:0] rf_rd_data;
wire [31:0] pc_queue_out;
/***************************************************
* JUMP ADDRESS CALCULATOR                          *
***************************************************/
wire [31:0] pc_plus_imm; /*ifq + immediate*/
wire [31:0] br_addr_reg_out; /*branch addres register output*/
wire [31:0] jmp_or_branch_addr; /*jump or branch mux output*/
/* IMMEDIATE GENERATOR
 * IMM_GEN: Decodes the isntruction format and
 * generates a signed 32-bit signed integer from 
 * immediate field. If instruction format does not 
 * contain the IMM fields, it outputs 32'd0 
 */
imm_gen IMM_GEN (
    .inst(ifq_icode),
    .imm(jac_imm)
);
/* JUMP ADDRESS ADDER
 * JMP_ADDR_ADDER: Adds the immediate value to PC to
 * avoid waiting for integer queue to calculate the
 * jump and branch address.
 * This calculation is ignored in JALR instruction.  
 */
adder_param #(
    .WIDTH(32)
) 
JMP_ADDR_ADDER
(
    .A(ifq_pc),
    .B(jac_imm),
    .S(pc_plus_imm),
    .carry()
);
/* BRANCH ADDRESS REGISTER
 * BR_ADDR_REG: When excecuting a branch, the branch address
 * is stored in a register while the branche is being solved,
 * this is because dispatch unit will request a fetch of the
 * next instruction before stalling for branch.
 */
reg_param #(
	.LENGTH(32),
	.RESET_VALUE(32'h00400000)
)
BR_ADDR_REG
(
	.clk(clk),
	.en(staller_br_addr_reg_en),
	.rst(rst),
	.DATA_IN(pc_plus_imm),
	.DATA_OUT(br_addr_reg_out)
);
/* JUMP OR BRANCH MULTIPLEXER
 * JMP_BR_MUX: Selects between the registered address (branch
 * address after branch is solved) or the pc_plus_imm (jump 
 * address) to send it to the IFQ.
 *
 * SEL = 0, jmp_or_branch_addr = br_addr_reg_out (branch)
 * SEL = 1, jmp_or_branch_addr = pc_plus_imm (jump)
 */
mux_param #(
    .WIDTH(32), 
    .N(2)
)
JMP_BR_MUX
(
    .X('{pc_plus_imm,br_addr_reg_out}),
    .SEL(ctrl_jmp),
    .Y(jmp_or_branch_addr)
);
/* JUMP OR CDB
 * JMP_CDB_MUX: Selects between the dispatch calculation
 * of jump/branch address (jmp_or_branch_addr) or the ALU
 * calculated branch (cdb_data) for JALR
 *
 * SEL = 0, dpch_jmp_br_addr = jmp_or_branch_addr (locally calculated)
 * SEL = 1, dpch_jmp_br_addr = cdb_data (ALU calculated)
 */
mux_param #(
    .WIDTH(32), 
    .N(2)
)
JMP_CDB_MUX
(
    .X('{cdb.data,jmp_or_branch_addr}),
    .SEL(cdb.jalr),
    .Y(dpch_jmp_br_addr)
);
/***************************************************
* RSx SELECTOR                                     *
***************************************************/
wire [31:0] rf_rs1_data_out;
wire [31:0] rf_rs2_data_out;
wire rs1_tag_cmp_out;
wire rs2_tag_cmp_out;
/* REGISTER FILE
 * REG_FILE: Contains the 32 physical registers of the RISV-V architecture.
 */
register_file REG_FILE (
	.clk(clk),
	.rst(rst),
	.we(rf_we),
	.RS1(icode_rs1),
	.RS2(icode_rs2),
	.RD(rf_rd),
	.DATA_IN(rf_rd_data),
	.RS1_DATA(rf_rs1_data_out),
	.RS2_DATA(rf_rs2_data_out)
);
/*CDB DATA FORWARD TAG COMPARATORS*/
assign rs1_tag_cmp_out = (cdb.tag == rs1_tag) ? 1'b1 : 1'b0;
assign rs2_tag_cmp_out = (cdb.tag == rs2_tag) ? 1'b1 : 1'b0;
/* CDB DATA FORWARD SIGNALS
 * Register data will be forwarded to queues if cdb is writting
 * on the requested register at the same cycle of the request,
 * this will evaluater if requested tag matched the tag cdb
 * is writting, the cdb is valid and the register tag is also
 * valid.
 */
assign rs1_cdb_fw = rs1_tag_cmp_out & rs1_tag_valid & cdb.valid;
assign rs2_cdb_fw = rs2_tag_cmp_out & rs2_tag_valid & cdb.valid;
/* REGISTER DATA SELECTOR
 * Selects between register file data or cdb forwarded data (data that
 * is being written in the Register File)
 */
assign rs1_reg_data = (rs1_cdb_fw == 1'b1) ? rf_rd_data : rf_rs1_data_out;
assign rs2_reg_data = (rs2_cdb_fw == 1'b1) ? rf_rd_data : rf_rs2_data_out;
/***************************************************
* TOKEN MANAGER (REGISTER RENAMING)                *
***************************************************/
wire rd_is_not_zero;
wire rd_tag_valid;
wire [5:0] rd_tag_fifo_out;
/*Flag to evaluate if rd is not zero and prevent a tag reading*/
assign rd_is_not_zero = (icode_rd == 5'd0) ? 1'b0: 1'b1;
/* Tag token rquieres a tag valid. If instruction does not writes back
 * in RF, rd_tag then is not valid
 */
assign rd_tag_valid = ctrl_reg_w & nstall & rd_is_not_zero;
/* TAG FIFO
 * Acquires a TAG for the destination register, renaming
 * it with the tag. 
 */
tag_fifo #(.SIZE(64)) FIFO (
    .clk(clk),
    .rst(rst),
    /*CDB IF*/
    .tag_in(cdb.tag),
    .tag_push(cdb.valid),
    /*Register Status Table IF*/
    .tag_out(rd_tag_fifo_out),
    .tag_pull(ctrl_reg_w & nstall & rd_is_not_zero),
    /*FIFO indicators*/
    .fifo_full(),
    .fifo_empty()
);
/* REGISTER STATUS TABLE
 * REG_STAT_TBL: Stores the status of the register renaming. Sets
 * a bit if the value of the register is traveling through the queues
 * and a tag is sent instead.
*/
reg_stat_table REG_ST_TBL(
    .clk(clk),
    .rst(rst),
    /*Tag clearing*/
    .cdb_tag(cdb.tag),
    .cdb_valid(cdb.valid),
    .rf_rd(rf_rd),
    .rf_we(rf_we),
    /*Tag reading*/
    .rs1(icode_rs1),
    .rs1_tag(rs1_tag),
    .rs1_tag_valid(rs1_tag_valid),
    .rs2(icode_rs2),
    .rs2_tag(rs2_tag),
    .rs2_tag_valid(rs2_tag_valid),
    /*Tag writing*/
    .rd(icode_rd),
    .rd_tag(rd_tag_fifo_out),
    .tag_write_en(ctrl_reg_w & nstall & rd_is_not_zero)
);
/*Direct assign to ports*/
assign queue_rd_tag = rd_tag_fifo_out;
assign queue_rd_tag_valid = rd_tag_valid;
assign queue_op1_tag = rs1_tag;
assign queue_op2_tag = rs2_tag;
/***************************************************
* STALL LOGIC                                      *
***************************************************/
/* STALL FSM
 * STALLER: Evaluates the conditions of the dispatch logic
 * and generates the stall signal to wait for a jalr, branch or
 * a queue fetch.
 */
dispatch_staller STALLER (
    .clk(clk),
    .rst(rst),
    /*FSM inputs*/
    .branch(ctrl_branch),
    .jalr(ctrl_jmp_reg),
    .branch_solved(cdb.branch),
    .jalr_solved(cdb.jalr),
    .ifq_empty(ifq_empty),

    .alu_full(alu_full),
    .mul_full(mul_full),
    .agu_full(agu_full),
    .div_full(div_full),

    .alu_dispatch(queue_alu_en),
    .mul_dispatch(queue_mul_en),
    .agu_dispatch(queue_agu_en),
    .div_dispatch(queue_div_en),

    .nstall(nstall),
    .branch_add_reg_en(staller_br_addr_reg_en)
);
/*Direct assignment to Read request to IFQ*/
assign dpch_rd = nstall;
/***************************************************
* CONTROL UNIT                                     *
***************************************************/
/*ICODE DECODER*/
assign icode_funct3 = ifq_icode[14:12];
assign icode_rs1    = ifq_icode[19:15];
assign icode_rs2    = ifq_icode[24:20];
assign icode_rd     = ifq_icode[11:7];
/*CONTROL DECODER
 * DPCH_CTRL: Decodes the ICODE of the instruction and generates
 * the control signal for the datapath of the dispatch unit
*/
dispatch_ctrl DPCH_CTRL (
    .icode(ifq_icode),
    .queue_alu_en(alu_en),
    .queue_alu_ext(queue_alu_ext),
    .queue_agu_en(agu_en),
    .queue_agu_ls(queue_agu_ls),
    .queue_mul_en(mul_en),
    .queue_div_en(div_en),
    .ctrl_reg_w(ctrl_reg_w),
    .ctrl_jmp(ctrl_jmp),
    .ctrl_jmp_reg(ctrl_jmp_reg),
    .ctrl_op1_sel(ctrl_op1_sel),
    .ctrl_op2_sel(ctrl_op2_sel),
    .ctrl_branch(ctrl_branch)
);
/*Direct assignments*/
assign queue_funct3 = icode_funct3;
assign queue_agu_imm = jac_imm;
/***************************************************
* JUMP BRANCH VALID                                *
***************************************************/
/* Dispatch Unit will request a jump to IFQ if cdb solves a branch,
 * cdb solves a jalr or ctrl detects a jal
 */
assign dpch_jmp = cdb.branch_taken | cdb.jalr | ctrl_jmp;
/***************************************************
* QUEUE OPx SELECTOR                               *
***************************************************/
/* OPERAND 1 MUX
 * QUEUE_OP1_MUX: Selects between the choices for operand 1
 *
 * SEL = 0, queue_op1_data = 0
 * SEL = 1, queue_op1_data = rs1_reg_data
 * SEL = 2, queue_op1_data = ifq_pc
 * SEL = 3, queue_op1_data = 0
 */
mux_param #(
    .WIDTH(32), 
    .N(4)
)
QUEUE_OP1_MUX
(
    .X('{32'd0,ifq_pc,rs1_reg_data,32'd0}),
    .SEL(ctrl_op1_sel),
    .Y(queue_op1_data)
);
/* OPERAND 2 MUX
 * QUEUE_OP2_MUX: Selects between the choices for operand 2
 *
 * SEL = 0, queue_op2_data = immediate
 * SEL = 1, queue_op2_data = rs2_reg_data
 */
mux_param #(
    .WIDTH(32), 
    .N(2)
)
QUEUE_OP2_MUX
(
    .X('{rs2_reg_data,jac_imm}),
    .SEL(ctrl_op2_sel),
    .Y(queue_op2_data)
);
/*OPERAND 1 VALID. If value is forced to 0 or PC, data is valid, else, depends on register status*/
assign queue_op1_data_valid = (ctrl_op1_sel != 2'b01) ? 1'b1 : ~rs1_tag_valid | rs1_cdb_fw;
/*OPERAND 2 VALID. If value is forced to immediate, data is valid, else, depends on register status*/
assign queue_op2_data_valid = (ctrl_op2_sel != 1'b1) ? 1'b1 : ~rs2_tag_valid | rs2_cdb_fw;
/***************************************************
* PC QUEUE STORAGE                                 *
***************************************************/
wire [31:0] pc_plus_four;
/* PC PLUS 4
 * PC_ADD_FOUR: Adds a constant of 4 to PC. JAL and JALR stores
 * PC+4 on registers.  
 */
adder_param #(
    .WIDTH(32)
) 
PC_ADD_FOUR
(
    .A(ifq_pc),
    .B(32'd4),
    .S(pc_plus_four),
    .carry()
);
/* PC FIFO
 * PC_QUEUE: used to store PC to be writen after JAL/JALR instructions.
 *
*/
fifo_param #(
    .WIDTH(32),
    .SIZE(5)
) 
PC_QUEUE
(
    .clk(clk),
    .rst(rst),
    .push(ctrl_jmp),
    .pull(cdb.store_pc),
    .data_in(pc_plus_four),
    .data_out(pc_queue_out),
    .empty(),
    .full()
);
/*REGISTER FILE RD DATA SELECTOR
 * Selects between CDB data or pc+4 in queue to be stored in
 * register file.
 */
assign rf_rd_data = (cdb.store_pc == 1'b1) ? pc_queue_out : cdb.data;

assign queue_alu_en = alu_en & nstall;
assign queue_agu_en = agu_en & nstall;
assign queue_mul_en = mul_en & nstall;
assign queue_div_en = div_en & nstall;
endmodule