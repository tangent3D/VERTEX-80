`default_nettype none

module ram (
	input wire i_clk,
	input wire [15:0] i_addr,
	input wire [7:0] i_data,
	input wire i_write,
	output reg [7:0] o_data
);
	reg [7:0] mem [0:16'hA7FF];

	always @(posedge i_clk) begin
		o_data <= mem[i_addr];

		if (i_write) begin
			mem[i_addr] <= i_data;
		end
	end

endmodule

`default_nettype wire
