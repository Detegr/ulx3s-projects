module digital_video(
    input clk_25mhz,
    input rst,
    input [7:0] red,
    input [7:0] green,
    input [7:0] blue,
    output [9:0] xout,
    output [9:0] yout,
    output [2:0] rgbout
);

assign xout = x;
assign yout = y;

wire blanking_wire;
wire dataclk_wire;
wire gnd = 0;
wire hsync_wire;
wire locked_wire;
wire vsync_wire;

// 250MHz data clock
clk25_250 clk25_250(
    .clk_25mhz(clk_25mhz),
    .clko(dataclk_wire),
    .locked(locked_wire)
);

video_sync sync(
	.clk(dataclk_wire),
	.rst(rst),
	.blanking(blanking_wire),
	.h_sync(hsync_wire),
	.v_sync(vsync_wire),
    .x(x),
    .y(y)
);

coloroutput redout(
    .clk(dataclk_wire),
    .pixelclk(clk_25mhz),
    .rst(rst),
    .color_input(red_input),
    .blanking(blanking_wire),
    .c0(gnd),
    .c1(gnd),
    .dout(rgbout[0])
);

coloroutput greenout(
    .clk(dataclk_wire),
    .pixelclk(clk_25mhz),
    .rst(rst),
    .color_input(green),
    .blanking(blanking_wire),
    .c0(gnd),
    .c1(gnd),
    .dout(rgbout[1])
);

coloroutput blueout(
    .clk(dataclk_wire),
    .pixelclk(clk_25mhz),
    .rst(rst),
    .color_input(blue),
    .blanking(blanking_wire),
    .c0(hsync_wire),
    .c1(vsync_wire),
    .dout(rgbout[2])
);

endmodule
