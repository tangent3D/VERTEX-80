`default_nettype none

module rom (
	input wire i_clk,
	input wire [15:0] i_addr,
	output reg [7:0] o_data
);
	reg [7:0] rom [0:16'h0FFF];
	
	initial begin
	    $readmemh("rom/rom.hex", rom);
	end

	always @(posedge i_clk)
	    o_data <= rom[i_addr[11:0]];
	
endmodule

`default_nettype wire
