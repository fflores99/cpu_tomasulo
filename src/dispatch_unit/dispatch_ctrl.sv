module dispatch_ctrl (
    input [31:0] icode,
    output reg queue_alu_en,
    output reg [2:0] queue_alu_ext,
    output reg queue_agu_en,
    output reg queue_agu_ls,
    output reg queue_mul_en,
    output reg queue_div_en,
    
    output reg ctrl_reg_w,
    output reg ctrl_jmp,
    output reg ctrl_jmp_reg,
    output reg [1:0] ctrl_op1_sel,
    output reg ctrl_op2_sel,
    output reg ctrl_branch
);

wire [6:0] opcode = icode[6:0];
wire [2:0] funct3 = icode[14:12];
wire [6:0] funct7 = icode[31:25];

always_comb begin : decoder
    case(opcode)
    7'b0110011: begin
        /*Aritmetic reg to reg operation*/
        queue_agu_en = 1'b0; /*No memory operation*/
        queue_agu_ls = 1'b0; /*No memory operation*/
        ctrl_reg_w = 1'b1; /*Register write back*/
        ctrl_jmp = 1'b0; /*No Jump*/
        ctrl_op1_sel = 2'b01; /*OP1 uses RS1*/
        ctrl_op2_sel = 1'b1; /*OP2 uses RS2*/
        ctrl_branch = 1'b0; /*No branch instruction*/
        ctrl_jmp_reg = 1'b0; /*No JALR*/
        if(funct7 != 7'h01) begin
            /*Integer Operation*/
            queue_alu_en = 1'b1;
            queue_mul_en = 1'b0;
            queue_div_en = 1'b0;
            queue_alu_ext = (funct7 == 7'h20) ? 3'b100 : 3'b000; /*ALU_EXT = 4 if funct7 = 20h, else is normal (0)*/
        end else begin
            if(funct3 < 3'h4) begin
                /*Multiplication*/
                queue_alu_en = 1'b0;
                queue_mul_en = 1'b1;
                queue_div_en = 1'b0;
                queue_alu_ext = 3'b000;
            end else begin
                /*Division*/
                queue_alu_en = 1'b0;
                queue_mul_en = 1'b0;
                queue_div_en = 1'b1;
                queue_alu_ext = 3'b000;
            end
        end   
    end
    7'b0010011: begin
        /*Integer operation with immediate*/
        queue_agu_en = 1'b0; /*No memory operation*/
        queue_agu_ls = 1'b0; /*No memory operation*/
        ctrl_reg_w = 1'b1; /*Register write back*/
        ctrl_jmp = 1'b0; /*No Jump*/
        ctrl_jmp_reg = 1'b0; /*No JALR*/
        ctrl_op1_sel = 2'b01; /*OP1 uses RS1*/
        ctrl_op2_sel = 1'b0; /*OP2 uses IMM*/
        ctrl_branch = 1'b0; /*No branch instruction*/
        queue_alu_en = 1'b1; /*ALU queue enable*/
        queue_mul_en = 1'b0; /*No multiplication*/
        queue_div_en = 1'b0; /*No division*/
        queue_alu_ext = (funct7 == 7'h20) ? 3'b100 : 3'b000; /*ALU_EXT = 4 if funct7 = 20h, else is normal (0)*/
      
    end
    7'b0110111: begin
        /*LUI*/
        queue_agu_en    = 1'b0; /*No memory operation*/
        queue_agu_ls    = 1'b0; /*No memory operation*/
        ctrl_reg_w      = 1'b1; /*Register write back*/
        ctrl_jmp        = 1'b0; /*No Jump*/
        ctrl_jmp_reg = 1'b0; /*No JALR*/
        ctrl_op1_sel    = 2'b00; /*OP1 uses 0*/
        ctrl_op2_sel    = 1'b0; /*OP2 uses IMM*/
        ctrl_branch     = 1'b0; /*No branch instruction*/
        queue_alu_en    = 1'b1; /*ALU queue enable*/
        queue_mul_en    = 1'b0; /*No multiplication*/
        queue_div_en    = 1'b0; /*No division*/
        queue_alu_ext   = 3'b101; /*ALU_EXT = 5 forces an SUM on the ALU*/        
    end
    7'b0010111 : begin
        /*AUIPC*/
        queue_agu_en    = 1'b0; /*No memory operation*/
        queue_agu_ls    = 1'b0; /*No memory operation*/
        ctrl_reg_w      = 1'b1; /*Register write back*/
        ctrl_jmp        = 1'b0; /*No Jump*/
        ctrl_jmp_reg    = 1'b0; /*No JALR*/
        ctrl_op1_sel    = 2'b10; /*OP1 uses PC*/
        ctrl_op2_sel    = 1'b0; /*OP2 uses IMM*/
        ctrl_branch     = 1'b0; /*No branch instruction*/
        queue_alu_en    = 1'b1; /*ALU queue enable*/
        queue_mul_en    = 1'b0; /*No multiplication*/
        queue_div_en    = 1'b0; /*No division*/
        queue_alu_ext   = 3'b101; /*ALU_EXT = 5 forces an SUM on the ALU*/ 
    end
    7'b0000011: begin
        /*Load*/
        queue_agu_en    = 1'b1; /*Memory operation*/
        queue_agu_ls    = 1'b0; /*load operation*/
        ctrl_reg_w      = 1'b1; /*Register write back*/
        ctrl_jmp        = 1'b0; /*No Jump*/
        ctrl_jmp_reg    = 1'b0; /*No JALR*/
        ctrl_op1_sel    = 2'b01; /*OP1 uses RS1*/
        ctrl_op2_sel    = 1'b0; /*OP2 uses IMM, especial buss for imm to agu*/
        ctrl_branch     = 1'b0; /*No branch instruction*/
        queue_alu_en    = 1'b0; /*No ALU operation*/
        queue_mul_en    = 1'b0; /*No multiplication*/
        queue_div_en    = 1'b0; /*No division*/
        queue_alu_ext   = 3'b000; /*ALU_EXT = 0, normal (don't care)*/ 
    end
    7'b0100011: begin
        /*Store*/
        queue_agu_en    = 1'b1; /*Memory operation*/
        queue_agu_ls    = 1'b1; /*store operation*/
        ctrl_reg_w      = 1'b0; /*Register not write back*/
        ctrl_jmp        = 1'b0; /*No Jump*/
        ctrl_jmp_reg    = 1'b0; /*No JALR*/
        ctrl_op1_sel    = 2'b01; /*OP1 uses RS1*/
        ctrl_op2_sel    = 1'b1; /*OP2 uses RS2*/
        ctrl_branch     = 1'b0; /*No branch instruction*/
        queue_alu_en    = 1'b0; /*No ALU operation*/
        queue_mul_en    = 1'b0; /*No multiplication*/
        queue_div_en    = 1'b0; /*No division*/
        queue_alu_ext   = 3'b000; /*ALU_EXT = 0, normal (don't care)*/ 
    end
    7'b1100011: begin
        /*Branch*/
        queue_agu_en    = 1'b0; /*No memory operation*/
        queue_agu_ls    = 1'b0; /*No memory operation*/
        ctrl_reg_w      = 1'b0; /*Register no write back*/
        ctrl_jmp        = 1'b0; /*No Jump*/
        ctrl_jmp_reg    = 1'b0; /*No JALR*/
        ctrl_op1_sel    = 2'b01; /*OP1 uses RS1*/
        ctrl_op2_sel    = 1'b1; /*OP2 uses RS2*/
        ctrl_branch     = 1'b1; /*Branch instruction*/
        queue_alu_en    = 1'b1; /*Branches are solved in ALU*/
        queue_mul_en    = 1'b0; /*No multiplication*/
        queue_div_en    = 1'b0; /*No division*/
        queue_alu_ext   = 3'b011; /*ALU_EXT = 3 (Branch)*/ 
    end
    7'b1101111: begin
        /*JAL*/
        queue_agu_en    = 1'b0; /*No memory operation*/
        queue_agu_ls    = 1'b0; /*No memory operation*/
        ctrl_reg_w      = 1'b1; /*Register write back*/
        ctrl_jmp        = 1'b1; /*Jump*/
        ctrl_jmp_reg    = 1'b0; /*No JALR*/
        ctrl_op1_sel    = 2'b10; /*OP1 uses PC*/
        ctrl_op2_sel    = 1'b1; /*OP2 uses RS2*/
        ctrl_branch     = 1'b0; /*No Branch instruction*/
        queue_alu_en    = 1'b1; /*JAL uses ALU to enqueue PC store*/
        queue_mul_en    = 1'b0; /*No multiplication*/
        queue_div_en    = 1'b0; /*No division*/
        queue_alu_ext   = 3'b001; /*ALU_EXT = 1 (JAL)*/ 
    end
    7'b1100111: begin
        /*JALR*/
        queue_agu_en    = 1'b0; /*No memory operation*/
        queue_agu_ls    = 1'b0; /*No memory operation*/
        ctrl_reg_w      = 1'b1; /*Register write back*/
        ctrl_jmp        = 1'b1; /*Jump*/
        ctrl_jmp_reg    = 1'b1; /*JALR*/
        ctrl_op1_sel    = 2'b01; /*OP1 uses RS1*/
        ctrl_op2_sel    = 1'b0; /*OP2 uses IMM*/
        ctrl_branch     = 1'b0; /*No Branch instruction*/
        queue_alu_en    = 1'b1; /*JALR calculates address in ALU*/
        queue_mul_en    = 1'b0; /*No multiplication*/
        queue_div_en    = 1'b0; /*No division*/
        queue_alu_ext   = 3'b010; /*ALU_EXT = 2 (JALR)*/ 
    end
    default: begin
        /*Invalid OPCODE*/
        queue_agu_en    = 1'b0; /*No memory operation*/
        queue_agu_ls    = 1'b0; /*No memory operation*/
        ctrl_reg_w      = 1'b0; /*Register write back*/
        ctrl_jmp        = 1'b0; /*no Jump*/
        ctrl_jmp_reg    = 1'b0; /*No JALR*/
        ctrl_op1_sel    = 2'b00; /*don't care*/
        ctrl_op2_sel    = 1'b0; /*don't care*/
        ctrl_branch     = 1'b0; /*No Branch instruction*/
        queue_alu_en    = 1'b0; /*No ALU queue*/
        queue_mul_en    = 1'b0; /*No multiplication*/
        queue_div_en    = 1'b0; /*No division*/
        queue_alu_ext   = 3'b000; /*ALU_EXT = 0, don't care*/ 
    end
    endcase
end
endmodule