`timescale 1ns/1ps
`default_nettype none

module top_sim;

    reg pin_clk = 0;
    reg pin_uart_rx = 1'b1;
    wire pin_uart_tx;

    always #18.5185 pin_clk = ~pin_clk;

    top dut (
        .pin_clk(pin_clk),
        .pin_uart_rx(pin_uart_rx),
        .pin_uart_tx(pin_uart_tx)
    );

    initial begin
        $dumpfile("build/top_sim.vcd");
        $dumpvars(0, top_sim);

        #100000;
        $finish;
    end

endmodule
`default_nettype wire
