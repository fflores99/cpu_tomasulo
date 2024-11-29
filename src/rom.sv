module rom #(parameter SIZE = 64) (
    input [31:0] address,
    output [127:0] data
);

reg [31:0] mem_data [SIZE/4];

initial
  begin
    $readmemh("C:/Users/frfdm/Documents/MDI/Repositories/cpu_tomasulo/assembly/bin/frontend_test.txt", mem_data);
  end

assign data[31:0] = mem_data[{address[31:4],2'b00}];
assign data[63:32] = mem_data[{address[31:4],2'b01}];
assign data[95:64] = mem_data[{address[31:4],2'b10}];
assign data[127:96] = mem_data[{address[31:4],2'b11}];

endmodule