module imm_gen (
    input [31:0] inst,
    output reg signed [31:0] imm
);

localparam R_TYPE = 3'd0;
localparam I_TYPE = 3'd1;
localparam S_TYPE = 3'd2;
localparam B_TYPE = 3'd3;
localparam U_TYPE = 3'd4;
localparam J_TYPE = 3'd5;

reg [2:0] i_format;

always_comb
begin: format_decoder
    case(inst[6:0])
        7'h33: i_format = R_TYPE;
        7'h13: i_format = I_TYPE;
        7'h03: i_format = I_TYPE;
        7'h23: i_format = S_TYPE;
        7'h63: i_format = B_TYPE;
        7'h6F: i_format = J_TYPE;
        7'h67: i_format = I_TYPE;
        7'h37: i_format = U_TYPE;
        7'h17: i_format = U_TYPE;
        default i_format = R_TYPE;
    endcase
end

always_comb
begin
    case(i_format)
        R_TYPE: imm = 32'd0;
        I_TYPE: imm = {{20{inst[31]}},inst[31:20]};
        S_TYPE: imm = {{20{inst[31]}},inst[31:25],inst[11:7]};
        B_TYPE: imm = {{19{inst[31]}},inst[31],inst[7],inst[30:25],inst[11:8], 1'b0};
        U_TYPE: imm = (inst[6:0] == 7'h37) ? {inst[31:12], {12{1'b0}}} : {inst[31:12], {12{1'b0}}};
        J_TYPE: imm = {{11{inst[31]}},inst[31],inst[19:12],inst[20],inst[30:21],1'b0};
        default: imm = 32'd0;
    endcase
end

endmodule