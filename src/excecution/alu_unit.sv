module alu_unit (
    input [31:0] op1,
    input [31:0] op2,
    input [2:0] alu_ext,
    input [2:0] funct3,
    input [5:0] tag_in,
    input tag_in_valid,
    output [31:0] res,
    output [5:0] tag_out,
    output tag_out_valid,
    output reg branch,
    output reg branch_taken,
    output reg jalr,
    output reg store_pc
);

/*ALU OPERATIONS*/
localparam ADD_O    = 4'b0000;
localparam SUB_O    = 4'b0001;
localparam NEG_O    = 4'b0010;
localparam AND_O    = 4'b0100;
localparam OR_O     = 4'b0101;
localparam INV_O    = 4'b0110;
localparam XOR_O    = 4'b0111;
localparam LSHIFT_O = 4'b1000;
localparam RSHIFT_O = 4'b1001;
localparam SLT_O	= 4'b1010;

wire z,n,cond_taken;

reg [3:0] alu_op_from_funct3, alu_op;

assign tag_out = tag_in;
assign tag_out_valid = tag_in_valid;

/*ALU operation decoder*/
always_comb begin : alu_op_dec
    case (funct3)
        3'd0: alu_op_from_funct3 = (alu_ext != 3'd4) ? ADD_O : SUB_O;
        3'd1: alu_op_from_funct3 = LSHIFT_O;
        3'd2: alu_op_from_funct3 = SLT_O;
        3'd3: alu_op_from_funct3 = SLT_O;
        3'd4: alu_op_from_funct3 = XOR_O;
        3'd5: alu_op_from_funct3 = RSHIFT_O;
        3'd6: alu_op_from_funct3 = OR_O;
        3'd7: alu_op_from_funct3 = AND_O;
        default: alu_op_from_funct3 = ADD_O;
    endcase
end
/*ALU control decoder*/
always_comb begin : alu_ctrl
    case (alu_ext)
        3'd0: alu_op = alu_op_from_funct3;
        3'd1: alu_op = ADD_O;
        3'd2: alu_op = ADD_O;
        3'd3: alu_op = SUB_O;
        3'd4: alu_op = alu_op_from_funct3;
        3'd5: alu_op = ADD_O;
        default: alu_op = ADD_O;
    endcase    
end

/*Branch taken comparator*/
cond_ctrl (
    .funct3(funct3),
    .z(z),
    .n(n),
    .cond_write(cond_taken)
);

always_comb begin : alu_ext_dec
    case (alu_ext)
        3'd0: begin
            branch = 1'b0;
            branch_taken = 1'b0;
            jalr = 1'b0;
            store_pc = 1'b0;
        end
        3'd1: begin
            branch = 1'b0;
            branch_taken = 1'b0;
            jalr = 1'b0;
            store_pc = 1'b1;
        end
        3'd2: begin
            branch = 1'b0;
            branch_taken = 1'b0;
            jalr = 1'b1;
            store_pc = 1'b1;
        end
        3'd3: begin
            branch = 1'b1;
            branch_taken = cond_taken;
            jalr = 1'b0;
            store_pc = 1'b0;
        end
        3'd4: begin
            branch = 1'b0;
            branch_taken = 1'b0;
            jalr = 1'b0;
            store_pc = 1'b0;
        end
        3'd5: begin
            branch = 1'b0;
            branch_taken = 1'b0;
            jalr = 1'b0;
            store_pc = 1'b0;
        end
        default:  begin
            branch = 1'b0;
            branch_taken = 1'b0;
            jalr = 1'b0;
            store_pc = 1'b0;
        end
    endcase    
end

alu_param #(
    .LENGTH(32)
) ALU (
	/*Inputs*/
	.A(op1),
	.B(op2),
	/*Operation selector*/
	.Op(alu_op),
	/*Flags*/
	.c(), /*carry*/
	.z(z), /*zero*/
	.n(n), /*negative*/
	.o(), /*overflow*/
	/*Output*/
	.Y(res)
);
endmodule