`timescale 1ns/1ps

module uart_sim;

	// testbench drives it == reg
	// uart drives it == wire

	reg i_clk = 0;
	reg i_rx = 1;
	wire o_tx;
	
	reg i_read_data = 0;
	reg i_read_register = 0;
	reg i_write_data = 0;
	reg i_write_register = 0;
	
	reg [7:0] i_data = 8'h00;
	wire [7:0] o_data;

    uart uart_sim
    (
	    .i_clk(i_clk),
	    .i_rx(i_rx),
	    .o_tx(o_tx),
	    .i_read_data(i_read_data),
	    .i_read_register(i_read_register),
	    .i_write_data(i_write_data),
	    .i_write_register(i_write_register),
	    .i_data(i_data),
	    .o_data(o_data)
    );

    always #18.518 i_clk = ~i_clk;

    integer i;
	reg [7:0] test_byte = 8'hAA;

    initial begin
		//
    	// Test the transmitter
    	//
    	
    	i_data = 8'b10101010;
    	
		i_write_data = 1;
		@(posedge i_clk);
		@(negedge i_clk);
		i_write_data = 0;
		
		wait (uart_sim.tx_busy == 1);
		wait (uart_sim.tx_busy == 0);

		//
		// Test the receiver
		//
		
	    i_rx = 1;
	
	    repeat (2) @(posedge i_clk);
	
	    @(negedge i_clk);
	    i_rx = 0;
	    repeat (234) @(posedge i_clk);
	
	    for (i = 0; i < 8; i = i + 1) begin
	        @(negedge i_clk);
	        i_rx = test_byte[i];
	        repeat (234) @(posedge i_clk);
	    end
	
	    @(negedge i_clk);
	    i_rx = 1;
	    repeat (234) @(posedge i_clk);
	
	    wait (uart_sim.rx_data_available == 1);

		i_read_register = 1;

		#1000

		i_read_register = 0;

		#1000

   		i_read_data = 1;

		#1000

		i_read_data = 0;

		#1000

		i_read_register = 1;

		#1000

		i_read_register = 0;

		#10000
		
        $finish;
    end

    initial begin
		$dumpfile("build/uart_sim.vcd");
		$dumpvars(0, uart_sim);
    end

endmodule
