module debouncer 
(
	input 		noisy,
	input 		clock,
	output reg 	debounced
);

reg [7:0] shiftreg;

initial begin
shiftreg=8'hFF;
debounced=1'b0;
end

always @ (posedge clock) 
begin
	shiftreg[7:0] <= {shiftreg[6:0], noisy};
	if (shiftreg[7:0] == 8'b00000000) 
	begin
		debounced <= 1'b1;
	end 
	else if (shiftreg[7:0] == 8'b11111111) 
	begin
		debounced <= 1'b0;
	end 
	else 
	begin
		debounced <= debounced;
	end
end

endmodule
