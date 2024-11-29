module reg_stat_table (
    input clk,
    input rst,
    /*Tag clearing*/
    input [5:0] cdb_tag,
    input cdb_valid,
    output [4:0] rf_rd,
    output rf_we,
    /*Tag reading*/
    input [4:0] rs1,
    output [5:0] rs1_tag,
    output rs1_tag_valid,
    input [4:0] rs2,
    output [5:0] rs2_tag,
    output rs2_tag_valid,
    /*Tag writing*/
    input [4:0] rd,
    input [5:0] rd_tag,
    input tag_write_en
);

/*Tag Registers*/
reg [6:0] REGISTER_STATUS [32];

reg [4:0] looked_up_rd; /*rd index of a looked-up tag*/
reg looked_up_rd_valid;

/*Register file Rd*/
assign rf_rd = looked_up_rd;
assign rf_we = looked_up_rd_valid; /*If tag was not found, rf is not updated*/
/*RS1 token*/
assign rs1_tag = REGISTER_STATUS[rs1][5:0];
assign rs1_tag_valid = REGISTER_STATUS[rs1][6];
/*RS2 token*/
assign rs2_tag = REGISTER_STATUS[rs2][5:0];
assign rs2_tag_valid = REGISTER_STATUS[rs2][6];

/* Combinational logic to find the rd index from tag (Asynchronous reading)
 * If a tag is nnot found, rd will be equal to 0, and writting to
 * register 0 has no effect.
 */
always_comb begin : look_up_rd
    integer i;
    looked_up_rd = 5'b00000; /*default of rd = 0*/
    looked_up_rd_valid = 1'b0;
    for(i = 0; i < 32; i+=1)  begin
        if(REGISTER_STATUS[i] == {1'b1,cdb_tag}) begin
            looked_up_rd = i;
            looked_up_rd_valid = REGISTER_STATUS[i][6];
        end
    end 
end

/*Sequential logc to write and clears tags (Synchronous writting)*/
always_ff @( posedge clk, posedge rst ) begin : sequential
    if(rst) begin
        /*Reset event*/
        integer i;
        for(i = 0; i < 32; i+=1)
            REGISTER_STATUS[i] <= 7'b0000000; /*Reset register to 0*/
    end else begin
        /*Writting and clearing same token adds priority to writting*/
        if(tag_write_en) begin
            REGISTER_STATUS[rd] <= {1'b1,rd_tag}; /*Writes valid bit + tag*/
        end
        /*Clears tag if cdb_valid and tag_write_en is different to 1 and rd is different to rd*/
        if(cdb_valid == 1'b1) begin
            if(!((tag_write_en) && (rd == looked_up_rd)))
                REGISTER_STATUS[looked_up_rd] <= 7'b0000000; /*Clears valid bit + tag*/     
        end      
    end
end
endmodule
