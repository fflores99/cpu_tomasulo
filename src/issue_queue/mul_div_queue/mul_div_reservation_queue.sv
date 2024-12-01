module mul_div_reservation_queue
(
    input clk,
    input rst,
    /*****Dispatch Interface*****/
    input queue_en,
    /*Operand1*/
    input [31:0] queue_op1_data_in,
    input [5:0] queue_op1_tag_in,
    input queue_op1_data_valid_in,
    /*operand2*/
    input [31:0] queue_op2_data_in,
    input [5:0] queue_op2_tag_in,
    input queue_op2_data_valid_in,
    /*Destination token*/
    input [5:0] queue_rd_tag_in,
    input queue_rd_tag_valid_in,
    /*instruction*/
    input [2:0] queue_funct3_in,
    /*back pressure*/
    output queue_full,
    /*****CDB*****/
    cdb_if cdb,
    /*****To excecution unit*****/
    input ex_done,
    output issue_valid,
    /*Operand1*/
    output [31:0] queue_op1_data_out,
    /*operand2*/
    output [31:0] queue_op2_data_out,
    /*Destination token*/
    output [5:0] queue_rd_tag_out,
    output queue_rd_tag_valid_out,
    /*instruction*/
    output [2:0] queue_funct3_out
);

/***************************************************
* CTRL TO REG SIGNALS                              *
***************************************************/
wire [5:0] op1_tag_arr[4], op2_tag_arr[4];
wire op1_data_valid_arr[4], op2_data_valid_arr[4], ready_arr[4], valid_arr[4];
wire op1_updt_en_arr[4];
wire op1_updt_from_cdb_arr[4];
wire op2_updt_en_arr[4];
wire op2_updt_from_cdb_arr[4];
wire updt_cmn_arr[4];
wire reg_we_arr[4];
wire [1:0] output_selector;

/***************************************************
* REG TO REG SIGNALS                               *
***************************************************/
wire [31:0] queue_op1_data_arr[4];
wire [5:0] queue_op1_tag_arr[4];
wire queue_op1_data_valid_arr[4];
    /*operand2*/
wire [31:0] queue_op2_data_arr[4];
wire [5:0] queue_op2_tag_arr[4];
wire queue_op2_data_valid_arr[4];
    /*Destination token*/
wire [5:0] queue_rd_tag_arr[4];
wire queue_rd_tag_valid_arr[4];
    /*instruction*/
wire [2:0] queue_funct3_arr[4];

wire flush_reg[4];
wire entry_valid[4];

/***************************************************
* REG TO CTRL VALID FLAG                           *
***************************************************/
assign valid_arr[0] = queue_rd_tag_valid_arr[0];
assign valid_arr[1] = queue_rd_tag_valid_arr[1];
assign valid_arr[2] = queue_rd_tag_valid_arr[2];
assign valid_arr[3] = queue_rd_tag_valid_arr[3];

/*Queue barrier to prevent input of data when queue isn't enabled*/
issue_ctrl #(.DEPTH(4)) MD_ISSUE_CTRL (
    .op1_tag(queue_op1_tag_arr), /*op1 tag from each register*/
    .op1_data_valid(queue_op1_data_valid_arr), /*op1 data valid from each register*/
    .op2_tag(queue_op2_tag_arr), /*op2 tag from each register*/
    .op2_data_valid(queue_op2_data_valid_arr), /*op2 data valid from each register*/
    .valid(valid_arr), /*RD valid from each register used to track if instruction in register is a valid instruction*/
    .entry_valid(entry_valid),
    .ready(ready_arr),
    .queue_en(queue_en), /*queue enebale from dispatch*/
    .ex_done(ex_done), /*Excecute done from Excecution Unit*/
    .cdb_tag(cdb.tag), /*Published CDB tag*/
    .cdb_data_valid(cdb.valid), /*Published CDB data valid*/
    .op1_updt_en(op1_updt_en_arr),
    .op1_updt_from_cdb(op1_updt_from_cdb_arr),
    .op2_updt_en(op2_updt_en_arr),
    .op2_updt_from_cdb(op2_updt_from_cdb_arr),
    .updt_cmn(updt_cmn_arr),
    .reg_we(reg_we_arr), /*Enable for registers*/
    .flush(flush_reg),
    .output_selector(output_selector), /*Selector for output mux, also used to track which register is being output*/
    .queue_full(queue_full), /*Queue full indicator*/
    .issue_valid(issue_valid) /*Issue valid bit to indicate excecution unit that data output is valid*/
);

/*Reservation register 0, it interfaces directly with dispatch unit*/
mul_div_reservation_reg RES_REG0
(
    .clk(clk),
    .rst(rst),
    .flush(flush_reg[0]),
    .we(reg_we_arr[0]),
    .updt_cmn_block(updt_cmn_arr[0]),
    .updt_op1(op1_updt_en_arr[0]),
    .updt_op1_from_cdb(op1_updt_from_cdb_arr[0]),
    .updt_op2(op2_updt_en_arr[0]),
    .updt_op2_from_cdb(op2_updt_from_cdb_arr[0]),
    .reg_valid_in(queue_en),
    .queue_op1_data_in(queue_op1_data_in),
    .queue_op1_tag_in(queue_op1_tag_in),
    .queue_op1_data_valid_in(queue_op1_data_valid_in),
    .queue_op2_data_in(queue_op2_data_in),
    .queue_op2_tag_in(queue_op2_tag_in),
    .queue_op2_data_valid_in(queue_op2_data_valid_in),
    .queue_rd_tag_in(queue_rd_tag_in),
    .queue_rd_tag_valid_in(queue_rd_tag_valid_in),
    .queue_funct3_in(queue_funct3_in),
    .cdb_data_valid(cdb.valid),
    .cdb_data(cdb.data),
    .reg_valid_out(entry_valid[0]),
    .queue_op1_data_out(queue_op1_data_arr[0]),
    .queue_op1_tag_out(queue_op1_tag_arr[0]),
    .queue_op1_data_valid_out(queue_op1_data_valid_arr[0]),
    .queue_op2_data_out(queue_op2_data_arr[0]),
    .queue_op2_tag_out(queue_op2_tag_arr[0]),
    .queue_op2_data_valid_out(queue_op2_data_valid_arr[0]),
    .queue_rd_tag_out(queue_rd_tag_arr[0]),
    .queue_rd_tag_valid_out(queue_rd_tag_valid_arr[0]),
    .queue_funct3_out(queue_funct3_arr[0]),
    .ready(ready_arr[0])
);

genvar i;
generate
    for (i = 1; i < 4; i += 1) begin : reg_station
    mul_div_reservation_reg RES_REG
    (
        .clk(clk),
        .rst(rst),
        .flush(flush_reg[i]),
        .we(reg_we_arr[i]),
        .updt_cmn_block(updt_cmn_arr[i]),
        .updt_op1(op1_updt_en_arr[i]),
        .updt_op1_from_cdb(op1_updt_from_cdb_arr[i]),
        .updt_op2(op2_updt_en_arr[i]),
        .updt_op2_from_cdb(op2_updt_from_cdb_arr[i]),
        .reg_valid_in(entry_valid[i-1]),
        .queue_op1_data_in(queue_op1_data_arr[i-1]),
        .queue_op1_tag_in(queue_op1_tag_arr[i-1]),
        .queue_op1_data_valid_in(queue_op1_data_valid_arr[i-1]),
        .queue_op2_data_in(queue_op2_data_arr[i-1]),
        .queue_op2_tag_in(queue_op2_tag_arr[i-1]),
        .queue_op2_data_valid_in(queue_op2_data_valid_arr[i-1]),
        .queue_rd_tag_in(queue_rd_tag_arr[i-1]),
        .queue_rd_tag_valid_in(queue_rd_tag_valid_arr[i-1]),
        .queue_funct3_in(queue_funct3_arr[i-1]),
        .cdb_data_valid(cdb.valid),
        .cdb_data(cdb.data),
        .reg_valid_out(entry_valid[i]),
        .queue_op1_data_out(queue_op1_data_arr[i]),
        .queue_op1_tag_out(queue_op1_tag_arr[i]),
        .queue_op1_data_valid_out(queue_op1_data_valid_arr[i]),
        .queue_op2_data_out(queue_op2_data_arr[i]),
        .queue_op2_tag_out(queue_op2_tag_arr[i]),
        .queue_op2_data_valid_out(queue_op2_data_valid_arr[i]),
        .queue_rd_tag_out(queue_rd_tag_arr[i]),
        .queue_rd_tag_valid_out(queue_rd_tag_valid_arr[i]),
        .queue_funct3_out(queue_funct3_arr[i]),
        .ready(ready_arr[i])
    );
    end
endgenerate

/* OP1 (32) + OP2 (32) + funct3 (3) + rd_tag (6) + rd_valid (1)*/
mux_param #(
    .WIDTH(74),
    .N(4)
)
MUL_CDB_MUX
(
    .X('{{queue_op1_data_arr[3],queue_op2_data_arr[3],queue_funct3_arr[3],queue_rd_tag_arr[3],queue_rd_tag_valid_arr[3]},
    {queue_op1_data_arr[2],queue_op2_data_arr[2],queue_funct3_arr[2],queue_rd_tag_arr[2],queue_rd_tag_valid_arr[2]},
    {queue_op1_data_arr[1],queue_op2_data_arr[1],queue_funct3_arr[1],queue_rd_tag_arr[1],queue_rd_tag_valid_arr[1]},
    {queue_op1_data_arr[0],queue_op2_data_arr[0],queue_funct3_arr[0],queue_rd_tag_arr[0],queue_rd_tag_valid_arr[0]}}),
    .SEL(output_selector),
    .Y({queue_op1_data_out,queue_op2_data_out,queue_funct3_out,queue_rd_tag_out,queue_rd_tag_valid_out})
);

endmodule