module uart
(
	input wire clk,
	input wire serial_rx,
	output reg serial_tx = 1,
	input wire [7:0] data_in,
	input wire write,
	output reg busy = 0
);
	reg [7:0] baud_counter = 0;
	reg baud_tick = 0;
	reg [7:0] data_latch;
	reg [3:0] frame_counter;

	always @(posedge clk) begin
		// ~115200 baud tick
		if (baud_counter == 233) begin
			baud_counter <= 0;
			baud_tick <= 1;
		end else begin
			baud_counter <= baud_counter + 1'b1;
			baud_tick <= 0;
		end

		if (write && !busy) begin
			busy <= 1; // Begin transmitting frame
			data_latch <= data_in;
			frame_counter <= 0;
			baud_counter <= 0;
			baud_tick <= 0;
			serial_tx <= 0; // Start bit
		end
		
		if (baud_tick && busy) begin			
			if (frame_counter == 8) begin
				serial_tx <= 1; // Stop bit 
			end else if (frame_counter == 9) begin
				busy <= 0; // Hold stop bit for baud_tick
			end else begin
				serial_tx <= data_latch[frame_counter];
			end
			
	 		if (frame_counter < 9) begin
				frame_counter <= frame_counter + 1'b1;
			end
		end
	end
endmodule
