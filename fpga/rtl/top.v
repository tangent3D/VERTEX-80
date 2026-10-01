module top
(
    input  wire clk,
    output wire led
);

uart uart_inst
(
	.clk(clk)
);

    reg [23:0] counter = 24'd0;

    always @(posedge clk) begin
        counter <= counter + 1'b1;
    end

    assign led = ~counter[3];

endmodule
