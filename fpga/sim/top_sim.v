`timescale 1ns/1ps
`default_nettype none

module top_sim;

    reg pin_clk = 0;
    reg pin_uart_rx = 1'b1;
    wire pin_uart_tx;
    wire [5:0] pin_led;

    always #18.5185 pin_clk = ~pin_clk;

    top dut (
        .pin_clk(pin_clk),
        .pin_uart_rx(pin_uart_rx),
        .pin_uart_tx(pin_uart_tx),
        .pin_led(pin_led)
    );

    task send_uart_byte;
        input [7:0] data;
        integer i;
        begin
            pin_uart_rx = 0;
            #(8680);
    
            for (i = 0; i < 8; i = i + 1) begin
                pin_uart_rx = data[i];
                #(8680);
            end
    
            pin_uart_rx = 1;
            #(8680);
        end
    endtask

    initial begin
        $dumpfile("build/top_sim.vcd");
        $dumpvars(0, top_sim);

        #1000;

        send_uart_byte(8'h01);
        send_uart_byte(8'h00);
        send_uart_byte(8'h76);

        #10000;
        
        $finish;
    end

endmodule
`default_nettype wire
