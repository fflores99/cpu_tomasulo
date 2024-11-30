module cdb_slot (
    input rst,
    input clk,
    input issue_div,
    input issue_mult,
    input issue_ls_or_int,
    output [6:0] cdb_status,
    output issue_valid
);

reg [6:0] slot;

assign cdb_status = slot;

always_ff @( posedge clk, posedge rst ) begin : shift_reg
    integer i;
    if(rst) begin
        slot <= 6'd0;
    end
    else begin
        slot[6] <= issue_div;
        for (i = 0; i < 6; i = i+1) begin
            if(i==3) begin
                slot[i] <= slot[i+1] | issue_mult;
            end else if(i == 0) begin
                slot[i] <= slot[i+1] | issue_ls_or_int;
            end else begin
                slot[i] <= slot[i+1]; 
            end
        end
    end
end

assign issue_valid = slot[0];
endmodule