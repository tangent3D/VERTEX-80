`timescale 1ns/1ps

module uart_sim;

    reg clk = 0;
    reg serial_rx = 1;
    reg [7:0] tx_data = 8'b00000000;
    reg write = 0;

    wire uart_tx;
    wire tx_busy;

    uart uart_inst
    (
    	.clk(clk),
    	.serial_rx(serial_rx),
    	.serial_tx(serial_tx),
    	.tx_data(tx_data),
    	.write(write),
    	.tx_busy(tx_busy)
    );

    always #18.518 clk = ~clk;

    initial begin
    	#100;

    	tx_data = 8'b11110000;
		write = 1;
		wait (tx_busy == 1);
		
		write = 0;
		wait (tx_busy == 0);

        #12345;

    	tx_data = 8'b00001111;
		write = 1;
		wait (tx_busy == 1);
		
		write = 0;
		wait (tx_busy == 0);

        #100;

		
        $finish;
    end

    initial begin
		$dumpfile("build/uart_sim.vcd");
		$dumpvars(0, uart_sim);
    end

endmodule
