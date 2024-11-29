interface cdb_if();
    logic [5:0] tag;
    logic valid;
    logic [31:0] data;
    logic branch;
    logic branch_taken;
    logic jalr;
    logic store_pc;
endinterface //cdb_if