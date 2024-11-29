module fifo_param #(
    parameter WIDTH = 32,
    parameter SIZE = 5
) 
(
    input clk,
    input rst,
    input push,
    input pull,
    input [WIDTH-1:0] data_in,
    output [WIDTH-1:0] data_out,
    output empty,
    output full
);

reg [$clog2(WIDTH) - 1:0] write_ptr, read_ptr;

reg [WIDTH-1:0] fifo_data [SIZE];

assign data_out = fifo_data[read_ptr];

always_ff @( posedge clk, posedge rst ) begin : fifo
    if(rst) begin
        integer i;
        write_ptr <= 7'b1000000;
        read_ptr  <= 7'b0000000;
        fifo_full <= 1'b1;
        fifo_empty <= 1'b0;
        for(i = 0; i < SIZE; i += 1) begin
            fifo_data[i] <= {WIDTH{1'b0}};
        end
    end else begin
        if((pull == 1'b1) && (empty == 1'b0)) begin
            read_ptr <= (read_ptr < (SIZE - 1)) ? read_ptr + 1 : 7'b0000000;
            if((read_ptr + 1'b1) == write_ptr)
                empty <= 1'b1;
            else
                empty <= 1'b0;
        end

        if((push == 1'b1) && (full == 1'b0)) begin
            fifo_data[read_ptr] <= data_in;
            write_ptr <= (write_ptr < (SIZE - 1)) ?  write_ptr + 1 : 7'b0000000;
            if((write_ptr + 1'b1) == read_ptr)
                full <= 1'b1;
            else
                full <= 1'b0;
        end
    end
end

endmodule