`timescale 1ns / 1ps
module parallel_to_serial(
    input clk,
    input pixelclk,
    input rst,
    input [7:0] color_input,
    input blanking,
    input c0,
    input c1,
    output dout
);

wire [9:0] color_output;
wire signed [3:0] dc_bias_wire;
wire signed [3:0] dc_bias_feedback;

previous_value dc_bias_buf(
	.clk(pixelclk),
	.current_value(dc_bias_wire),
	.previous_value(dc_bias_feedback)
);

tsdm tsdm(
	.rst(rst),
	.din(color_input),
	.dout(color_output),
	.blanking(blanking),
	.c0(c0),
	.c1(c1),
	.prev_dc_bias(dc_bias_feedback),
	.dc_bias(dc_bias_wire)
);

datachannel datachannel(
	.clk(clk),
	.rst(rst),
	.data(color_output),
	.dout(dout)
);

endmodule
