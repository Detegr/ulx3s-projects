`timescale 1ns / 1ps
module coloroutput(
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

tsdm tsdm(
    .clk(pixelclk),
    .rst(rst),
    .din(color_input),
    .dout(color_output),
    .blanking(blanking),
    .c0(c0),
    .c1(c1)
);

datachannel datachannel(
    .clk(clk),
    .rst(rst),
    .data(color_output),
    .dout(dout)
);

endmodule
