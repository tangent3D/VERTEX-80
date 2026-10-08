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

	wire uart_read_data;
	wire uart_read_register;
	wire uart_write_data;
	wire uart_write_register;

	assign uart_read_data =
	    (z80_address[7:0] == `UART_DATA_PORT && 
	    z80_iorq_n == 0 &&
	    z80_rd_n == 0);

	assign uart_read_register =
	    (z80_address[7:0] == `UART_REG_PORT &&
	    z80_iorq_n == 0 &&
	    z80_rd_n == 0);

	assign uart_write_data =
	    (z80_address[7:0] == `UART_DATA_PORT &&
	    z80_iorq_n == 0 &&
	    z80_wr_n == 0);

	assign uart_write_register =
	    (z80_address[7:0] == `UART_REG_PORT &&
	    z80_iorq_n == 0 &&
	    z80_wr_n == 0);

	uart uart (
	    .i_clk(pin_clk),
	    .i_rx(pin_uart_rx),
	    .o_tx(pin_uart_tx),

	    .i_read_data(uart_read_data),
	    .i_read_register(uart_read_register),
	    .i_write_data(uart_write_data),
	    .i_write_register(uart_write_register)
	);

endmodule
