`timescale 1ns/10ps
module frontend_tb ();


    reg clk, rst;
    reg d_valid;
    /*****Memory Interface*****/
    wire [127:0] mem_data;
    wire abort;
    wire m_rd_en;
    wire [31:0] mem_addr;
    /*****Backend interface*****/
    wire [31:0] queue_op1_data;
    wire [5:0] queue_op1_tag;
    wire queue_op1_data_valid;
    /*Operand 2*/
    wire [31:0] queue_op2_data;
    wire [5:0] queue_op2_tag;
    wire queue_op2_data_valid;
    /*Destination*/
    wire [5:0] queue_rd_tag;
    wire queue_rd_tag_valid;
    /*instruction*/
    wire [2:0] queue_funct3;
    /*ALU signals*/
    wire queue_alu_en;
    wire [2:0] queue_alu_ext;
    /*AGU signals*/
    wire queue_agu_en;
    wire queue_agu_ls;
    wire [31:0] queue_agu_imm;
    /*Mult queue*/
    wire queue_mul_en;
    /*Div queue*/
    wire queue_div_en;
    cdb_if cdb();

    rom #(
    .SIZE(128)
    ) 
    PMEM 
    (
        .address({16'd0,mem_addr[15:0]}),
        .data(mem_data)
    );

    tomasulo_front_end_cluster UUT (
        .clk(clk),
        .rst(rst),
        .d_valid(d_valid),
        .mem_data(mem_data),
        .abort(abort),
        .m_rd_en(m_rd_en),
        .mem_addr(mem_addr),
        .queue_op1_data(queue_op1_data),
        .queue_op1_tag(queue_op1_tag),
        .queue_op1_data_valid(queue_op1_data_valid),
        /*Operand 2*/
        .queue_op2_data(queue_op2_data),
        .queue_op2_tag(queue_op2_tag),
        .queue_op2_data_valid(queue_op2_data_valid),
        /*Destination*/
        .queue_rd_tag(queue_rd_tag),
        .queue_rd_tag_valid(queue_rd_tag_valid),
        /*instruction*/
        .queue_funct3(queue_funct3),
        /*ALU signals*/
        .queue_alu_en(queue_alu_en),
        .queue_alu_ext(queue_alu_ext),
        /*AGU signals*/
        .queue_agu_en(queue_agu_en),
        .queue_agu_ls(queue_agu_ls),
        .queue_agu_imm(queue_agu_imm),
        /*Mult queue*/
        .queue_mul_en(queue_mul_en),
        /*Div queue*/
        .queue_div_en(queue_div_en),
        .cdb(cdb)
    );

wire [31:0] data_arr[30] = {
    32'd1, 
    32'd2, 
    32'd3, 
    32'd4, 
    32'd3, 
    32'd6, 
    32'd10, 
    32'h24,
    32'd0,
    32'h3c, //mul
    32'd10, //div
    32'h2c,
    32'd0,
    32'h34,
    32'ha,
    32'h3c,
    32'ha,
    32'd0,
    32'd0,
    32'd0,
    32'd0,
    32'd0,
    32'd0,
    32'd0,
    32'd0,
    32'h3054,
    32'd1,
    32'd2,
    32'd3,
    32'd4
};

wire [6:0] token_arr[30] = {
    7'd64,
    7'd65,
    7'd66,
    7'd67,
    7'd68,
    7'd69,
    7'd70,
    7'd73,
    7'd0,
    7'd71,
    7'd72,
    7'd74,
    7'd0,
    7'd75,
    7'd76,
    7'd77,
    7'd78,
    7'd0,
    7'd0,
    7'd0,
    7'd0,
    7'd0,
    7'd0,
    7'd0,
    7'd0,
    7'd79,
    7'd80,
    7'd81,
    7'd82,
    7'd83
};

    initial begin
        clk = 1'b1;
        d_valid = 1'b1;
        cdb.data = 32'd0;
        cdb.tag = 6'd0;
        cdb.valid = 1'b0;
        cdb.branch = 1'b0;
        cdb.branch_taken = 1'b0;
        cdb.store_pc = 1'b0;
        cdb.jalr = 1'b0;
        rst = 1'b1;
        @(posedge clk);
        rst = 1'b0;
    end

    always
    begin
        #5 clk = ~clk;
    end

always begin
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    publish_cbd();
end
integer i;
    task publish_cbd ();
        for (i = 0; i < 30 ; i+=1) begin
            cdb.data = data_arr[i];
            cdb.tag = token_arr[i][5:0];
            cdb.valid = token_arr[i][6];
            if(i == 17 || i == 21)
                cdb.branch = 1'b1;
            else
                cdb.branch = 1'b0;
            if(i == 21)
                cdb.branch_taken = 1'b1;
            else
                cdb.branch_taken = 1'b0;
            if(i == 25)
                cdb.store_pc = 1'b1;
            else
                cdb.store_pc = 1'b0;
            @(posedge clk);
        end
    endtask
endmodule