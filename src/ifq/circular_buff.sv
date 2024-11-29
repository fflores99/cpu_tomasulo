module circular_buff #(parameter LENGTH = 128, SIZE = 4)
(
    input clk,
    input rst,
    input flush,

    input push,
    input pull,

    input [LENGTH - 1:0] data_write,

    output [LENGTH - 1:0] data_read,
    output reg full,
    output reg empty,
    output reg [$clog2(SIZE) - 1:0] write_ptr, 
    output reg [$clog2(SIZE) - 1:0] read_ptr 
);

reg [LENGTH - 1:0] BUFF_DAT [SIZE];

assign data_read = BUFF_DAT[read_ptr];

always_ff @( posedge clk, posedge rst ) begin : sequential
    if(rst) begin
        /*Asynchronous reset*/
	    integer i;
        read_ptr <= {$clog2(SIZE){1'b0}}; /*Read pointer reset (-1)*/
        write_ptr <= {$clog2(SIZE){1'b0}}; /*Wriite pointer reset (0)*/
        empty <= 1'b1;
        full <= 1'b0;
        for(i=0;i<(SIZE);i=i+1)
		    BUFF_DAT[i] <= {LENGTH{1'b0}}; /*Data reset*/
    end else begin
        if(flush) begin
            /*Synchronous reset (FLUSH)*/
	        integer i;
            read_ptr <= {$clog2(SIZE){1'b0}}; /*Read pointer reset (-1)*/
            write_ptr <= {$clog2(SIZE){1'b0}}; /*Wriite pointer reset (0)*/
            empty <= 1'b1;
            full <= 1'b0;
            for(i=0;i<(SIZE);i=i+1)
                BUFF_DAT[i] <= {LENGTH{1'b0}}; /*Data reset*/
        end else begin
            if(pull) begin
                if(!empty) begin
                    read_ptr <= read_ptr + 1'b1;
                    full <= 1'b0;
                    if((read_ptr + 1'b1) == write_ptr)
                        empty <= 1'b1;
                    else
                        empty <= 1'b0;
                end
            end
            
            if(push) begin
                if(!full) begin
                    BUFF_DAT[write_ptr] <= data_write;
                    write_ptr <= write_ptr + 1'b1;
                    empty <= 1'b0;
                    if((write_ptr + 1'b1) == read_ptr)
                        full <= 1'b1;
                    else
                        full <= 1'b0;
                end
            end
        end
    end

end

endmodule