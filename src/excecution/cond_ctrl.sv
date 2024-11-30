module cond_ctrl (
    input [2:0] funct3,
    input z,
    input n,
    output reg cond_write
);

always_comb
begin
    case (funct3)
        3'b000: cond_write = z;
        3'b001: cond_write = ~z;
        3'b100, 3'b110: cond_write = n;
        3'b101, 3'b111: cond_write = z | ~n;
        default: cond_write = 1'b0;
    endcase
end
endmodule