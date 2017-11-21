/*
The virtual NES cartridge
At the moment this stores the entire cartridge
in SPRAM, in the future it could stream data from
SQI flash, which is more than fast enough
*/

module cart_mem(
  input clock,
  input reset,
  output cart_ready,
  
  //address into a given section - 0 is the start of CHR and PRG,
  //region is selected using the select lines for maximum flexibility
  //in partitioning
  input [20:0] address,
  
  input prg_sel, chr_sel,
  input ram_sel, //for cart SRAM (NYI)
  
  input rden, wren,
  
  input  [7:0] write_data,
  output [7:0] read_data,
  
  //Flash load interface
  output flash_csn,
  output flash_sck,
  output flash_mosi,
  input flash_miso,
);

reg load_done;
initial load_done = 1'b0;

wire cart_ready = load_done;

wire spram_en = prg_sel | chr_sel;

wire [16:0] decoded_address;
assign decoded_address = chr_sel ? {1'b1, address[15:0]} : {1'b0, address[15:0]};

reg [14:0] load_addr;
wire [14:0] spram_address = load_done ? decoded_address[16:2] : load_addr;

wire load_wren;
wire spram_wren = load_done ? (spram_en && wren) : load_wren;
wire [3:0] spram_mask = load_done ? (4'b0001 << decoded_address[1:0]) : 4'b1111;
wire [3:0] spram_maskwren = spram_wren ? spram_mask : 4'b0000;

wire [31:0] load_write_data;
wire [31:0] spram_write_data = load_done ? {write_data, write_data, write_data, write_data} : load_write_data;

wire [31:0] spram_read_data;

assign read_data = spram_read_data;

`ifdef no_spram_prim
  reg [31:0] spram_mem[0:32767];
  reg [31:0] spram_dout_pre;
  always @(posedge clock)
  begin
    spram_dout_pre <= spram_mem[spram_address];
    if(spram_maskwren[0]) spram_mem[spram_address] <= spram_write_data[7:0];
    if(spram_maskwren[1]) spram_mem[spram_address] <= spram_write_data[15:8];
    if(spram_maskwren[2]) spram_mem[spram_address] <= spram_write_data[23:16];
    if(spram_maskwren[3]) spram_mem[spram_address] <= spram_write_data[31:24];
  end;
  assign spram_read_data <= spram_dout_pre;
`else
  up_spram spram_i (
    .clk(clock),
    .wen(spram_maskwren),
    .addr(spram_address),
    .wdata(spram_write_data),
    .rdata(spram_read_data)
  );
`endif


wire flashmem_valid = !load_done;
wire flashmem_ready;
assign load_wren =  flashmem_ready;
wire flashmem_rstn = !reset;
wire [23:0] flashmem_addr = 24'h100000 | {load_addr, 2'b00};

always @(posedge reset or posedge clock) 
begin
  if (reset == 1'b1) begin
    load_done <= 1'b0;
    load_addr <= 14'h0000;
  end else begin
    if (flashmem_ready == 1'b1) begin
      if (load_addr == 15'h7FFF) begin
        load_done <= 1'b1;
      end else begin
        load_addr <= load_addr + 1'b1;
      end;
    end
  end
end

icosoc_flashmem flash_i (
	.clk(clock),
  .resetn(flashmem_rstn),
  .valid(flashmem_valid),
  .ready(flashmem_ready),
  .addr(flashmem_addr),
  .rdata(load_write_data),

	.spi_cs(flash_csn),
	.spi_sclk(flash_sck),
	.spi_mosi(flash_mosi),
	.spi_miso(flash_miso)
);

endmodule