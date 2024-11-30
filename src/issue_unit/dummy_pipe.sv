module dummy_pipe #(parameter DEPTH = 6, parameter WIDTH = 1) (
    input clk,
    input rst,
    input [WIDTH - 1:0] pipe_in,
    output [WIDTH - 1:0] pipe_out
);

reg [WIDTH - 1:0] pipe [DEPTH];

always_ff @( posedge clk, posedge rst ) begin : pipeline
    integer i;
    if(rst) begin
        pipe[DEPTH-1] <= {WIDTH{1'b0}};
    end
    else begin
        pipe[DEPTH - 1] <= pipe_in;
        for (i = 0; i < DEPTH - 1; i = i+1) begin
                pipe[i] <= pipe[i+1]; 
        end
    end
end

assign pipe_out = pipe[0];

endmodule