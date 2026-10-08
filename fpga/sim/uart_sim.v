`timescale 1ns/1ps

module uart_sim;

	// testbench drives it == reg
	// uart drives it == wire

	reg clk = 0;
	reg rx = 1;
	wire tx;
	
	reg read_data = 0;
	reg read_status = 0;
	reg write_data = 0;
	reg write_control = 0;
	
	reg [7:0] i_data = 8'h00;
	wire [7:0] o_data;

    uart uart_sim
    (
	    .clk(clk),
	    .rx(rx),
	    .tx(tx),
	    .read_data(read_data),
	    .read_status(read_status),
	    .write_data(write_data),
	    .write_control(write_control),
	    .i_data(i_data),
	    .o_data(o_data)
    );

    always #18.518 clk = ~clk;

    integer i;
	reg [7:0] test_byte = 8'hAA;

    initial begin
		//
    	// Test the transmitter
    	//
    	
    	i_data = 8'b10101010;
    	
		write_data = 1;
		@(posedge clk);
		@(negedge clk);
		write_data = 0;
		
		wait (uart_sim.tx_busy == 1);
		wait (uart_sim.tx_busy == 0);

		//
		// Test the receiver
		//
		
	    rx = 1;
	
	    repeat (2) @(posedge clk);
	
	    @(negedge clk);
	    rx = 0;
	    repeat (234) @(posedge clk);
	
	    for (i = 0; i < 8; i = i + 1) begin
	        @(negedge clk);
	        rx = test_byte[i];
	        repeat (234) @(posedge clk);
	    end
	
	    @(negedge clk);
	    rx = 1;
	    repeat (234) @(posedge clk);
	
	    wait (uart_sim.rx_data_available == 1);

   		read_data = 1;
		@(posedge clk);
		@(negedge clk);
		read_data = 0;

		#100;
		
        $finish;
    end

    initial begin
		$dumpfile("build/uart_sim.vcd");
		$dumpvars(0, uart_sim);
    end

endmodule
