module uart #(
	parameter BAUD_DIV = 234
)
(
	input wire clk,
	input wire serial_rx,
	output reg serial_tx = 1,
	input wire [7:0] data_in,
	input wire write,
	output reg busy = 0
);
	reg [31:0] baud_counter = 0;
	reg baud_tick = 0;
	reg [7:0] data_latch;
	reg [3:0] frame_counter;

	reg rx_meta = 1;
	reg rx_sync = 1;
	reg rx_sync_prev = 1;
	reg rx_busy = 0;
	reg [31:0] rx_baud_counter = 0;
	reg rx_start_valid = 0;
	reg [3:0] rx_frame_counter = 0;
	reg [7:0] rx_shift_reg;
	reg [7:0] rx_data;
	reg rx_data_ready = 0;

	// sync async rx input to FPGA clock
	always @(posedge clk) begin
		rx_meta <= serial_rx;
		rx_sync <= rx_meta;
		rx_sync_prev <= rx_sync;
	end

	always @(posedge clk) begin
	    if (!rx_busy) begin
			if (rx_sync == 0 && rx_sync_prev == 1) begin
				rx_busy <= 1;
				rx_baud_counter <= 0;
				rx_start_valid <= 0;
			end	
	    end else begin
	        if (!rx_start_valid) begin
	            if (rx_baud_counter == (BAUD_DIV / 2) - 1) begin
	                if (rx_sync == 1) begin
	                    rx_busy <= 0;
	                end else begin
	                    rx_start_valid <= 1;
	                    rx_baud_counter <= 0;
	                    rx_frame_counter <= 0;
	                end
	            end else begin
	                rx_baud_counter <= rx_baud_counter + 1'b1;
	            end
	        end else begin
	            if (rx_baud_counter == BAUD_DIV - 1) begin
	            	if (rx_frame_counter < 8) begin
	            		rx_shift_reg <= {rx_sync, rx_shift_reg[7:1]};
      	            	rx_frame_counter <= rx_frame_counter + 1'b1;
	            	end else if (rx_frame_counter == 8) begin
	         			if (rx_sync == 1) begin
	         	         	rx_data <= rx_shift_reg;
	         				rx_data_ready <= 1;
	         				rx_busy <= 0;
	         			end else begin
							rx_busy <= 0;
	         			end
	         		end
	            	rx_baud_counter <= 0;
	            end else begin
	            	rx_baud_counter <= rx_baud_counter + 1'b1;
	            end
	        end
	    end
	end

	always @(posedge clk) begin
		if (baud_counter == BAUD_DIV - 1) begin
			baud_counter <= 0;
			baud_tick <= 1;
		end else begin
			baud_counter <= baud_counter + 1'b1;
			baud_tick <= 0;
		end

		if (write && !busy) begin
			busy <= 1;
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
