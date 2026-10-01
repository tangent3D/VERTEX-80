`timescale 1ns/1ps

module uart_sim;

    reg clk = 0;
    reg serial_rx = 1;
    reg [7:0] data_in = 8'b00000000;
    reg write = 0;

    wire uart_tx;
    wire busy;

    uart uart_inst
    (
    	.clk(clk),
    	.serial_rx(serial_rx),
    	.serial_tx(serial_tx),
    	.data_in(data_in),
    	.write(write),
    	.busy(busy)
    );

    always #18.518 clk = ~clk;

    initial begin
    	#100;

    	data_in = 8'b11110000;
		write = 1;
		wait (busy == 1);
		
		write = 0;
		wait (busy == 0);

        #12345;

    	data_in = 8'b00001111;
		write = 1;
		wait (busy == 1);
		
		write = 0;
		wait (busy == 0);

        #100;

		
        $finish;
    end

    initial begin
		$dumpfile("build/uart_sim.vcd");
		$dumpvars(0, uart_sim);
    end

endmodule
