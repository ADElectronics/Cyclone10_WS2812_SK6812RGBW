module RAM_2P
#(
	parameter ADDR_WIDTH = 32, // Сколько бит содержит адресация 
	parameter DATA_WIDTH = 32 	// Сколько бит содержат данные
)
(
	input [DATA_WIDTH-1:0] data_a, data_b,
	input [ADDR_POINTER_WIDTH:0] addr_a, addr_b,
	input we_a, we_b, 
	input clock,
	output reg [DATA_WIDTH-1:0] rd_a, rd_b
);

localparam integer ADDR_POINTER_WIDTH = $clog2(ADDR_WIDTH);

reg [DATA_WIDTH-1:0] ram[ADDR_WIDTH-1:0];

always @ (posedge clock)
begin
	if (we_a) 
	begin
		ram[addr_a] <= data_a;
		rd_a <= data_a;
	end
	else 
	begin
		rd_a <= ram[addr_a];
	end
end

always @ (posedge clock)
begin
	if (we_b)
	begin
		ram[addr_b] <= data_b;
		rd_b <= data_b;
	end
	else
	begin
		rd_b <= ram[addr_b];
	end
end
	
endmodule
