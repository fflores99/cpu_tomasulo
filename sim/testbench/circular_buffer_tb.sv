`timescale 1ns/1ps

module circular_buffer_tb();

logic clk, rst, flush, push, pull;
logic [127:0] DATA_READ, DATA_WRITE;
wire [1:0] WR_PTR, RD_PTR;

logic full, empty;

circular_buff #(
.LENGTH(128),
.SIZE(4)
)
UUT 
(
    .clk(clk),
    .rst(rst),
    .flush(flush),
    .push(push),
    .pull(pull),
    .data_write(DATA_WRITE),
    .data_read(DATA_READ),
    .full(full),
    .empty(empty),
    .write_ptr(WR_PTR),
    .read_ptr(RD_PTR)
);

initial begin
	clk = 1'b0;
    push = 1'b0;
    pull = 1'b0;
    flush = 1'b0;
    rst = 1'b0;
    DATA_WRITE = 128'd0;
    reset_seq();
/*    fill_buff();
    delay(2);
    empty_buff();
    delay(2);
    two_writes_one_read();*/
end

always begin
    #5 clk = ~clk;
end

always begin
    single_write();
end

always begin
    single_read();
    delay(3);
end

always begin
    integer i;
    for(i = 0; i < 30; i+=1)
        @(posedge clk);
    flush_tsk();
end

task reset_seq();
    rst = 1'b1;
    @(posedge clk) rst = 1'b0;
endtask

task fill_buff();
    push = 1'b1;
    do begin
        #1;
        DATA_WRITE = $urandom%65536; 
        if(full) begin
            push = 1'b0;
            break;
        end else begin 
            @(posedge clk);
        end  
    end while(1);
endtask

task empty_buff();
    pull = 1'b1;
    do begin
        #1;
        if(empty) begin
            pull = 1'b0;
            break;
        end else begin 
            @(posedge clk);
        end  
    end while(1);
endtask

task two_writes_one_read();
    integer i;   
    do begin
        push = 1'b0;
        pull = 1'b0;    
        for(i = 0; i < 2; i+=1) begin
            DATA_WRITE = $urandom%65536;
            push = 1'b1;
            @(posedge clk);
        end
        #1;
        if(full)
            break;
        push = 1'b0; 
        pull = 1'b1;
        @(posedge clk);
    end while(1);
    pull = 1'b0;
    push = 1'b0; 
endtask

task single_write();
    if(!full) begin
        push = 1'b1;
        DATA_WRITE = $urandom%65536;
        @(posedge clk);
        push = 1'b0;
    end else
        @(posedge clk);
endtask

task single_read();
    if(!empty) begin
        pull = 1'b1;
        @(posedge clk);
        pull = 1'b0;
    end else
        @(posedge clk);
endtask

task delay(integer ticks);
    integer i;
    for(i = 0; i < ticks; i+=1)
        @(posedge clk);
endtask

task flush_tsk();
    flush = 1'b1;
    @(posedge clk);
    flush = 1'b0;
endtask
endmodule