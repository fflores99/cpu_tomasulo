module lru_ctrl (
    input clk,
    input rst,
    input lru_in,
    output reg lru_bit    
);
    
always_ff @( posedge clk, posedge rst ) begin : blockName
    if(rst)
        lru_bit <= 1'b1;
    else
        if(lru_in)
            lru_bit <= ~lru_bit;
        else
            lru_bit <= ~lru_bit;
end
endmodule