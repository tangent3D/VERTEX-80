`default_nettype none
`include "io_ports.vh"

module top (
    input wire pin_clk,
    input wire pin_uart_rx,
    output wire pin_uart_tx
);
// -----------------------------------------------------------------------------
// PLL
// -----------------------------------------------------------------------------
	wire pll_clk;
	wire pll_locked;

	`ifdef SIMULATION

    assign pll_clk = pin_clk;
    assign pll_locked = 1'b1;

	`else

    pll pll (
        .clock_in(pin_clk),
        .clock_out(pll_clk),
        .locked(pll_locked)
    );
	`endif

// -----------------------------------------------------------------------------
// Power-on reset
// -----------------------------------------------------------------------------
	wire por_reset_n;
	wire reset_n;

	por por (
		.i_clk(pin_clk),
		.o_reset_n(por_reset_n)
	);

	assign reset_n = por_reset_n && pll_locked;
	
// -----------------------------------------------------------------------------
// CPU
// -----------------------------------------------------------------------------
	wire cpu_mreq_n;
	wire cpu_iorq_n;
	wire cpu_rd_n;
	wire cpu_wr_n;
	wire [15:0] cpu_addr;
	wire [7:0] cpu_data_in;
	wire [7:0] cpu_data_out;

	tv80n cpu (
	// Outputs
	    //.m1_n(),
	    .mreq_n(cpu_mreq_n),
	    .iorq_n(cpu_iorq_n),
	    .rd_n(cpu_rd_n),
	    .wr_n(cpu_wr_n),
	    //.rfsh_n(),
	    //.halt_n(),
	    //.busak_n(),
	    .A(cpu_addr),
	    .dout(cpu_data_out),

	// Inputs
	    .reset_n(reset_n),
	    .clk(pll_clk),
	    .wait_n(1'b1),
	    .int_n(1'b1),
	    .nmi_n(1'b1),
	    .busrq_n(1'b1),
	    .di(cpu_data_in)

	);

// -----------------------------------------------------------------------------
// UART
// -----------------------------------------------------------------------------
	wire uart_read_data;
	wire uart_read_register;
	wire uart_write_data;
	wire uart_write_register;
	wire [7:0] uart_data_out;

	uart uart (
	    .i_clk(pll_clk),
	    .i_rx(pin_uart_rx),
	    .o_tx(pin_uart_tx),

	    .i_read_data(uart_read_data),
	    .i_read_register(uart_read_register),
	    .i_write_data(uart_write_data),
	    .i_write_register(uart_write_register),

	    .i_data(cpu_data_out),
	    .o_data(uart_data_out)
	);
	
	assign uart_read_data =
	    (cpu_addr[7:0] == `UART_DATA_PORT && 
	    cpu_iorq_n == 0 &&
	    cpu_rd_n == 0);

	assign uart_read_register =
	    (cpu_addr[7:0] == `UART_REG_PORT &&
	    cpu_iorq_n == 0 &&
	    cpu_rd_n == 0);

	assign uart_write_data =
	    (cpu_addr[7:0] == `UART_DATA_PORT &&
	    cpu_iorq_n == 0 &&
	    cpu_wr_n == 0);

	assign uart_write_register =
	    (cpu_addr[7:0] == `UART_REG_PORT &&
	    cpu_iorq_n == 0 &&
	    cpu_wr_n == 0);
	
// -----------------------------------------------------------------------------
// ROM
// -----------------------------------------------------------------------------
	wire rom_select = !rom_disable && (cpu_addr <= 16'h0FFF);
	wire [7:0] rom_data_out;
	reg rom_disable = 1'b0;

	rom rom (
		.i_clk(pll_clk),
	    .i_addr(cpu_addr),
	    .o_data(rom_data_out)
	);

	always @(posedge pll_clk) begin
	    if (!reset_n)
	        rom_disable <= 1'b0;
	    else if (!cpu_iorq_n && !cpu_wr_n && cpu_addr[7:0] == `ROM_DISABLE)
	        rom_disable <= 1'b1;
	end

// -----------------------------------------------------------------------------
// RAM
// -----------------------------------------------------------------------------
	wire ram_select = cpu_addr <= 16'hA7FF;
	wire ram_write;
	wire [7:0] ram_data_out;

	ram ram (
		.i_clk(pll_clk),
		.i_addr(cpu_addr),
		.i_data(cpu_data_out),
		.i_write(ram_write),
		.o_data(ram_data_out)
	);

	assign ram_write = 
		ram_select &&
		!cpu_mreq_n &&
		!cpu_wr_n;

// -----------------------------------------------------------------------------
// CPU data bus multiplexing
// -----------------------------------------------------------------------------
	assign cpu_data_in =
	    !cpu_mreq_n && rom_select ? rom_data_out :
	    !cpu_mreq_n && ram_select ? ram_data_out :
	    !cpu_iorq_n && (uart_read_data || uart_read_register) ? uart_data_out :
	    8'hFF;
	
endmodule

`default_nettype wire
