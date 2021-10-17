module apple(
		input wire a,
		input wire b,
		input wire clk,
		output reg c
	);

	always @(posedge clk)begin 
		c <= a & b;
	end

endmodule
