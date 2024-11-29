module one_hot_param #(parameter WIDTH = 8) (
    input [$clog2(WIDTH) - 1:0] SEL,
    output reg [WIDTH - 1:0] ONE_HOT
);

integer i;
always_comb begin : one_hot_decoder
    for(i = 0; i < WIDTH; i = i + 1) begin
        if(i == SEL)
            ONE_HOT[i] = 1'b1;
        else
            ONE_HOT[i] = 1'b0;
    end
end
endmodule