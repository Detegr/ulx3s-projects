`timescale 1ns / 1ps

module test;

reg rst = 1;

initial begin
    $dumpfile("simulation/test.vcd");
    $dumpvars(0, test);

    # 40 rst = 0;
    # 48000000 $finish;
end

reg clk = 1;
always #10 clk = !clk;

wire blanking_wire;
wire vsync_wire;
wire [9:0] x;
wire [9:0] y;
wire[2:0] rgb_wire;

digital_video gpdi(
    .clk_25mhz(clk),
    .rst(rst),
    .red(8'd80),
    .green(8'd80),
    .blue(8'd80),
    .xout(x),
    .yout(y),
    .vsync_out(vsync_wire),
    .rgbout(rgb_wire)
);

endmodule
