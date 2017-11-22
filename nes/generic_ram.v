// Simple, platform-agnostic single-ported RAM

module generic_ram(clock, address, wren, write_data, read_data);

parameter integer WIDTH = 8;
parameter integer WORDS = 2048;
localparam ADDR_BITS = $clog2(WORDS-1);

input clock;
input [ADDR_BITS-1:0] address;
input wren;
input [WIDTH-1:0] write_data;
output reg [WIDTH-1:0] read_data;

reg [WIDTH-1:0] mem[0:WORDS-1];

always @(posedge clock) begin
  read_data <= mem[address];
  if (wren) mem[address] <= write_data;
end

endmodule