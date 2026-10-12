`default_nettype none

module por (
    input wire i_clk,
    output wire o_reset_n
);

	`ifdef SIMULATION
    reg [3:0] reset_counter = 0;
	`else
    reg [15:0] reset_counter = 0;
	`endif

    always @(posedge i_clk) begin
        if (!(&reset_counter))
            reset_counter <= reset_counter + 1'b1;
    end

    assign o_reset_n = &reset_counter;

endmodule

`default_nettype wire
