`default_nettype none

module rom (
	input wire i_read,
	input wire [15:0]i_addr,
	output reg [7:0] o_data
);
	reg [7:0] rom [0:4095];
	
	initial begin
	    $readmemh("rom/rom.hex", rom);
	end

	always @(*) begin
		o_data = 8'h00;

		if (i_read) begin
			o_data = rom[i_addr[11:0]];
		end
	end
endmodule

`default_nettype wire
