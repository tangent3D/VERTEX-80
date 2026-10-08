`include "io_ports.vh"

module top (
    input wire pin_clk,
    input wire pin_uart_rx,
    output wire pin_uart_tx
);

	wire [15:0] z80_address;
	wire z80_iorq_n;
	wire z80_rd_n;
	wire z80_wr_n;	

	wire read_data;
	wire read_status;
	wire write_data;
	wire write_control;

	assign read_data =
	    (z80_address[7:0] == `UART_DATA_PORT && 
	    z80_iorq_n == 0 &&
	    z80_rd_n == 0);

	assign read_status =
	    (z80_address[7:0] == `UART_STATUS_PORT &&
	    z80_iorq_n == 0 &&
	    z80_rd_n == 0);

	assign write_data =
	    (z80_address[7:0] == `UART_DATA_PORT &&
	    z80_iorq_n == 0 &&
	    z80_wr_n == 0);

	assign write_control =
	    (z80_address[7:0] == `UART_STATUS_PORT &&
	    z80_iorq_n == 0 &&
	    z80_wr_n == 0);

	uart uart (
	    .clk(pin_clk),
	    .rx(pin_uart_rx),
	    .tx(pin_uart_tx),

	    .read_data(read_data),
	    .read_status(read_status),
	    .write_data(write_data),
	    .write_control(write_control)
	);

endmodule
