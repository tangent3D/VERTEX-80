`include "io_ports.vh"

module uart #(
	parameter BAUD_DIV = 234
)
(
	// external logic drives it == input wire
	// module writes it in an always block == output reg

	input wire clk,
	input wire rx,
	output reg tx = 1,
	
	input wire read_data,
	input wire read_register,
	input wire write_data,
	input wire write_register,
	
	input wire [7:0] i_data,
	output reg [7:0] o_data
);

	reg rx_meta = 1;
	reg rx_sync = 1;
	reg rx_sync_prev = 1;
	reg rx_busy = 0;
	reg [31:0] rx_baud_counter = 0;
	reg rx_start_valid = 0;
	reg [3:0] rx_frame_counter = 0;
	reg [7:0] rx_shift_reg;
	reg [7:0] rx_data;
	reg rx_data_available = 0;
	
	reg tx_busy = 0;
	reg [31:0] tx_baud_counter = 0;
	reg tx_baud_tick = 0;
	reg [7:0] tx_data_latch;
	reg [3:0] tx_frame_counter;

// Receiver section

	always @(posedge clk) begin
		rx_meta <= rx;
		rx_sync <= rx_meta;
		rx_sync_prev <= rx_sync;
	end

	always @(posedge clk) begin
		if (read_data) begin
			rx_data_available <= 0;
		end
		
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
	         				rx_data_available <= 1;
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

// Transmitter section

	always @(posedge clk) begin
		if (tx_baud_counter == BAUD_DIV - 1) begin
			tx_baud_counter <= 0;
			tx_baud_tick <= 1;
		end else begin
			tx_baud_counter <= tx_baud_counter + 1'b1;
			tx_baud_tick <= 0;
		end

		if (write_data && !tx_busy) begin
			tx_busy <= 1;
			tx_data_latch <= i_data;
			tx_frame_counter <= 0;
			tx_baud_counter <= 0;
			tx_baud_tick <= 0;
			tx <= 0; // Start bit
		end
		
		if (tx_baud_tick && tx_busy) begin			
			if (tx_frame_counter == 8) begin
				tx <= 1; // Stop bit 
			end else if (tx_frame_counter == 9) begin
				tx_busy <= 0; // Hold stop bit for baud_tick
			end else begin
				tx <= tx_data_latch[tx_frame_counter];
			end
			
	 		if (tx_frame_counter < 9) begin
				tx_frame_counter <= tx_frame_counter + 1'b1;
			end
		end
	end
	
endmodule
