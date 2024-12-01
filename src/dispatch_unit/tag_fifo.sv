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
    output fifo_full,
    output fifo_empty
);

reg [5:0] write_ptr, read_ptr;

reg [5:0] fifo_data [SIZE];
assign tag_out = fifo_data[read_ptr];

always_ff @( posedge clk, posedge rst ) begin : fifo
    if(rst) begin
        integer i;
        write_ptr <= 6'b111111;
        read_ptr  <= 6'b000000;
        for(i = 0; i < SIZE; i += 1) begin
            fifo_data[i] <= i[6:0];
        end
    end else begin
        if((tag_pull == 1'b1) && (fifo_empty == 1'b0)) begin
            //read_ptr <= (read_ptr < (SIZE - 1)) ? read_ptr + 1 : 6'b0000000;
            read_ptr <= read_ptr + 1;
            /*if((read_ptr + 1'b1) == write_ptr)
                fifo_empty <= 1'b1;
            else
                fifo_empty <= 1'b0;
                */
        end

        if((tag_push == 1'b1) && (fifo_full == 1'b0)) begin
            //fifo_data[read_ptr] <= tag_in;
            //write_ptr <= (write_ptr < (SIZE - 1)) ?  write_ptr + 1 : 6'b0000000;
            write_ptr <= write_ptr + 1;
/*
            if((write_ptr + 1'b1) == read_ptr)
                fifo_full <= 1'b1;
            else
                fifo_full <= 1'b0;
                */
        end
    end
end

assign fifo_full = ((write_ptr + 1'b1) == read_ptr);
assign fifo_empty = (write_ptr == read_ptr);
endmodule