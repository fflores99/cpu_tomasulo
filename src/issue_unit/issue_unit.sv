module issue_unit (
    input clk,
    input rst,
    /*Integer queue*/
    input int_ready,
    input [31:0] int_result,
    input [5:0] int_tag,
    input int_branch,
    input int_branch_taken,
    input int_jalr,
    input int_write_pc,
    input int_cdb_valid,
    output reg int_done,
    /*mult queue*/
    input mult_ready,
    input [31:0] mult_result,
    input [5:0] mult_tag,
    output reg mult_done,
    /*Div queue*/
    input div_ready,
    input div_busy,
    input [31:0] div_result,
    input [5:0] div_tag,
    output reg div_done,
    /*mem if*/
    input ls_ready,
    input [31:0] load_data,
    input [5:0] load_tag,
    output reg ls_done,
    /*CDB*/
    cdb_if cdb
);

reg lru_bit, lru_tgl;

reg issue_div_temp, issue_mult_temp, issue_int, issue_ld;
wire [6:0] cdb_slot_status;
reg [1:0] mux_sel;
wire issue_mult_pipe, issue_div_pipe;

always_comb begin : issue_logic
    if(int_ready == 1'b1 && ls_ready == 1'b1 && cdb_slot_status[1] == 1'b0)
    begin
        lru_tgl = 1'b1;
        if(lru_bit) begin
            issue_int = 1'b1;
            issue_ld = 1'b0;
            int_done = 1'b1;
            ls_done = 1'b0;
        end else begin
            issue_int = 1'b0;
            issue_ld = 1'b1;
            int_done = 1'b0;
            ls_done = 1'b1;
        end
    end
    else begin
        lru_tgl = 1'b0;
        if(int_ready == 1'b1 && cdb_slot_status[1] == 1'b0) begin
            issue_int = 1'b1;
            issue_ld = 1'b0;
            int_done = 1'b1;
            ls_done = 1'b0;
        end else if(ls_ready && cdb_slot_status[1] == 1'b0) begin
            issue_int = 1'b0;
            issue_ld = 1'b1;
            int_done = 1'b0;
            ls_done = 1'b1;
        end else begin
            issue_int = 1'b0;
            issue_ld = 1'b0;
            int_done = 1'b0;
            ls_done = 1'b0;
        end
    end

    if(mult_ready && cdb_slot_status[4] == 1'b0) begin
        issue_mult_temp = 1'b1;
        mult_done = 1'b1;
    end else begin
        issue_mult_temp = 1'b0;
        mult_done = 1'b0;
    end

    if(div_ready) begin
        if(div_busy) begin
            issue_div_temp = 1'b0;
            div_done = 1'b0;
        end else begin
            issue_div_temp = 1'b1;
            div_done = 1'b1;
        end
    end else begin
            issue_div_temp = 1'b0;
            div_done = 1'b0;
    end 
end 

lru_ctrl LRU (
    .clk(clk),
    .rst(rst),
    .lru_in(lru_tgl),
    .lru_bit(lru_bit)   
);

cdb_slot CDBSLOT (
    .rst(rst),
    .clk(clk),
    .issue_div(issue_div_temp),
    .issue_mult(issue_mult_temp),
    .issue_ls_or_int(issue_int | issue_ld),
    .cdb_status(cdb_slot_status),
    .issue_valid()
);

dummy_pipe  #(
    .DEPTH(3), 
    .WIDTH(1)
) 
MULT_SEL_PIPE
(
    .clk(clk),
    .rst(rst),
    .pipe_in(issue_mult_temp),
    .pipe_out(issue_mult_pipe)
);

dummy_pipe  #(
    .DEPTH(6), 
    .WIDTH(1)
) 
DIV_SEL_PIPE
(
    .clk(clk),
    .rst(rst),
    .pipe_in(issue_div_temp),
    .pipe_out(issue_div_pipe)
);

always_comb begin : cdb_mux_sel
    if(issue_int) begin
        mux_sel = 2'b00;
        cdb.tag = int_tag;
        cdb.data = int_result;
        cdb.branch = int_branch;
        cdb.branch_taken = int_branch_taken;
        cdb.jalr = int_jalr;
        cdb.valid = int_cdb_valid;
        cdb.store_pc = int_write_pc;
    end else if(issue_ld) begin
        mux_sel = 2'b01;
        cdb.tag = load_tag;
        cdb.data = load_data;
        cdb.branch = 1'b0;
        cdb.branch_taken = 1'b0;
        cdb.jalr = 1'b0;
        cdb.valid = 1'b1;
        cdb.store_pc = 1'b0;
    end else if(issue_mult_pipe) begin
        mux_sel = 2'b10;
        cdb.tag = mult_tag;
        cdb.data = mult_result;
        cdb.branch = 1'b0;
        cdb.branch_taken = 1'b0;
        cdb.jalr = 1'b0;
        cdb.valid = 1'b1;
        cdb.store_pc = 1'b0;
    end else if(issue_div_pipe) begin
        mux_sel = 2'b11;
        cdb.tag = div_tag;
        cdb.data = div_result;
        cdb.branch = 1'b0;
        cdb.branch_taken = 1'b0;
        cdb.jalr = 1'b0;
        cdb.valid = 1'b1;
        cdb.store_pc = 1'b0;
    end else begin
        mux_sel = 2'b00; 
        cdb.tag = 6'd0;
        cdb.data = 32'd0;
        cdb.branch = 1'b0;
        cdb.branch_taken = 1'b0;
        cdb.jalr = 1'b0;
        cdb.valid = 1'b0;
        cdb.store_pc = 1'b0;  
    end
end

endmodule