`timescale 1ns/1ps
module ifq_tb();
logic clk, rst, d_valid, abort, m_rd_en,jump_branch_valid,d_rd_en,empty;
logic [127:0] mem_data;
logic [31:0] mem_addr, jump_branch_add, i_code, pc_out;

ifq UUT (
    .clk(clk),
    .rst(rst),
    /*Program Memory Interface*/
    .d_valid(d_valid),
    .mem_data(mem_data),
    .abort(abort),
    .m_rd_en(m_rd_en),
    .mem_addr(mem_addr),
    /*Dispatch Interface*/
    .jump_branch_valid(jump_branch_valid),
    .jump_branch_add(jump_branch_add),
    .d_rd_en(d_rd_en),
    .empty(empty),
    .i_code(i_code),
    .pc_out(pc_out)
);

initial begin
    clk = 1'b0;
    rst = 1'b0;
    d_valid = 1'b0;
    jump_branch_valid = 1'b0;
    d_rd_en = 1'b0;
    mem_data = 128'd0;
    jump_branch_add = 32'd0;
    reset_seq();
end

always begin
    #5 clk = ~clk;
end

always begin
    single_write();
end

always begin
    single_read();
end

always begin
    integer i;
    for(i = 0; i < 42; i+=1)
        @(posedge clk);
    jump_sim();
end

task jump_sim();
    jump_branch_valid = 1'b1;
    jump_branch_add = 32'h0040001C;
    @(posedge clk);
    jump_branch_valid = 1'b0;
    jump_branch_add = 32'h00000000;
endtask;

task single_write();
    d_valid = 1'b1;
    if(m_rd_en) begin
        mem_data = (($urandom%32) << 96) | (($urandom%32) << 64) | (($urandom%32) << 32) | ($urandom%32);
    end
    @(posedge clk);
endtask

task single_read();
    if(!empty) begin
        d_rd_en = 1'b1;
    end else begin
        d_rd_en = 1'b0;
    end
    @(posedge clk);
endtask

task reset_seq();
    rst = 1'b1;
    @(posedge clk) rst = 1'b0;
endtask

endmodule