`timescale 1ns/10ps

module cpu_tb ();
    
    reg clk, rst;

    wire [31:0] pmem_addr;
    wire [127:0] pmem_data;
    wire [31:0] dmem_addr, dmem_data_r, dmem_data_w;
    wire dmem_we;

    rom #(
    .SIZE(128)
    ) 
    ROM
    (
        .address({16'd0,pmem_addr[15:0]}),
        .data(pmem_data)
    );

    memory_block #(
        .SIZE(256)
    )
    RAM
    (
        .clk(clk),
        .ADD(dmem_addr[7:0]),
        .we(dmem_we),
        .DW(dmem_data_w),
        .DR(dmem_data_r)
    );

    tomasulo_cpu CPU (
    .clk(clk),
    .rst(rst),

    .p_mem_add(pmem_addr),
    .p_mem_data(pmem_data),

    .d_mem_add(dmem_addr),
    .d_mem_we(dmem_we),
    .d_mem_data_r(dmem_data_r),
    .d_mem_data_w(dmem_data_w)
); 

initial
begin
    rst = 1'b1;
    clk = 1'b1;
    @(posedge clk);
    rst = 1'b0;
end

always
begin
    #5 clk = ~clk;
end
endmodule