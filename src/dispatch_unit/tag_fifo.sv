module tag_fifo #(parameter SIZE = 64) (
    input clk,
    input rst,
    /*CDB IF*/
    input [5:0] tag_in,
    input tag_push,
    /*Register Status Table IF*/
    output [5:0] tag_out,
    input tag_pull,
    /*FIFO indicators*/
    output reg fifo_full,
    output reg fifo_empty
);

reg [6:0] write_ptr, read_ptr;

reg [5:0] fifo_data [SIZE];
assign tag_out = fifo_data[read_ptr];

always_ff @( posedge clk, posedge rst ) begin : fifo
    if(rst) begin
        integer i;
        write_ptr <= 7'b1000000;
        read_ptr  <= 7'b0000000;
        fifo_full <= 1'b1;
        fifo_empty <= 1'b0;
        for(i = 0; i < SIZE; i += 1) begin
            fifo_data[i] <= i[6:0];
        end
    end else begin
        if((tag_pull == 1'b1) && (fifo_empty == 1'b0)) begin
            read_ptr <= (read_ptr < (SIZE - 1)) ? read_ptr + 1 : 7'b0000000;
            if((read_ptr + 1'b1) == write_ptr)
                fifo_empty <= 1'b1;
            else
                fifo_empty <= 1'b0;
        end

        if((tag_push == 1'b1) && (fifo_full == 1'b0)) begin
            fifo_data[read_ptr] <= tag_in;
            write_ptr <= (write_ptr < (SIZE - 1)) ?  write_ptr + 1 : 7'b0000000;
            if((write_ptr + 1'b1) == read_ptr)
                fifo_full <= 1'b1;
            else
                fifo_full <= 1'b0;
        end
    end
end

endmodule