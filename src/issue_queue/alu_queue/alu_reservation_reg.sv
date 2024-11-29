module alu_reservation_reg
(
    input clk,
    input rst,
    /*control signals*/
    input we,
    input updt_cmn_block,
    input updt_op1,
    input updt_op1_from_cdb,
    input updt_op2,
    input updt_op2_from_cdb,
    /*****From upper register*****/
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
    input [2:0] queue_alu_ext_in,
    /*CDB data*/
    input cdb_data_valid,
    input [31:0] cdb_data,
    /*****To next register*****/
    /*Operand1*/
    output [31:0] queue_op1_data_out,
    output [5:0] queue_op1_tag_out,
    output queue_op1_data_valid_out,
    /*operand2*/
    output [31:0] queue_op2_data_out,
    output [5:0] queue_op2_tag_out,
    output queue_op2_data_valid_out,
    /*Destination token*/
    output [5:0] queue_rd_tag_out,
    output queue_rd_tag_valid_out,
    /*instruction*/
    output [2:0] queue_funct3_out,
    output [2:0] queue_alu_ext_out,
    /*Register Ready flag*/
    output ready
);

wire [31:0] op1_data_to_reg;
wire op1_data_valid_to_reg;

wire [31:0] op2_data_to_reg;
wire op2_data_valid_to_reg;

/* if operand 1 is uptated from cdb, selects CDB data, if not, selects prev op1 data*/
assign op1_data_to_reg = (updt_op1_from_cdb) ? cdb_data : queue_op1_data_in;
/* updates data valid of operand 1 if it is being updated by cdb, if not, uses previous data valid*/
assign op1_data_valid_to_reg = (updt_op1_from_cdb) ? cdb_data_valid : queue_op1_data_valid_in;

/* if operand 2 is uptated from cdb, selects CDB data, if not, selects prev op2 data*/
assign op2_data_to_reg = (updt_op2_from_cdb) ? cdb_data : queue_bus_in.op2_data;
/* updates data valid of operand 1 if it is being updated by cdb, if not, uses previous data valid*/
assign op2_data_valid_to_reg = (updt_op2_from_cdb) ? cdb_data_valid : queue_bus_in.op2_data_valid;

/*Operand 1 Register (op1 data + data valid)*/
reg_param #(
	.LENGTH(33),
	.RESET_VALUE(33'd0)
)
OP1_REG
(
	.clk(clk),
	.en(we & updt_op1),
	.rst(rst),
	.DATA_IN({op1_data_to_reg,
            op1_data_valid_to_reg}),
	.DATA_OUT({queue_op1_data_out,
            queue_op1_data_valid_out})
);

/*Operand 2 Register (op2 data + data valid)*/
reg_param #(
	.LENGTH(33),
	.RESET_VALUE(33'd0)
)
OP2_REG
(
	.clk(clk),
	.en(we & updt_op1),
	.rst(rst),
	.DATA_IN({op2_data_to_reg,
            op2_data_valid_to_reg}),
	.DATA_OUT({queue_op2_data_out,
            queue_op2_data_valid_out})
);

/*Common register*/
reg_param #(
	.LENGTH(25),
	.RESET_VALUE(25'd0)
)
CMN_REG
(
	.clk(clk),
	.en(we & updt_cmn_block),
	.rst(rst),
	.DATA_IN({queue_op1_tag_in, //6
            queue_op2_tag_in, //6
            queue_rd_tag_in, //6
            queue_rd_tag_valid_in, //1
            queue_funct3_in, //3
            queue_alu_ext_in}), //3 total = 25
	.DATA_OUT({queue_op1_tag_out,
            queue_op2_tag_out,
            queue_rd_tag_out,
            queue_rd_tag_valid_out,
            queue_funct3_out,
            queue_alu_ext_out})
);

/*Ready register*/
reg_param #(
	.LENGTH(1),
	.RESET_VALUE(1'd0)
)
READY_REG
(
	.clk(clk),
	.en(we),
	.rst(rst),
	.DATA_IN(((op1_data_valid_to_reg & updt_op1) | op1_data_valid_out) & ((op2_data_valid_to_reg & updt_op2)  | op2_data_valid_out)),
	.DATA_OUT(ready)
);

endmodule