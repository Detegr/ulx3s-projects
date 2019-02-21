module top(
    input clk_25mhz,
    input [7:0] btn, // Reset
    output[7:0] led,
    output [3:0] gpdi_dp, gpdi_dn // BGR-Clock +/-
);

assign rst = ~btn[0];

assign led[7:0] = 8'b0;

wire dataclk_wire;
wire clkmul_fb_wire;
wire dataclk_fb_wire;

wire blanking_wire;
wire hsync_wire;
wire vsync_wire;

wire gnd = 0;
wire locked_wire;

wire[9:0] x;
wire[9:0] y;

clk25_250 clk25_250(
    .clk_25mhz(clk_25mhz),
    .clko(dataclk_wire),
    .locked(locked_wire)
);

reg [7:0] red_input;
reg [7:0] green_input;
reg [7:0] blue_input;

video_sync sync(
	.clk(dataclk_wire),
	.rst(rst),
	.blanking(blanking_wire),
	.h_sync(hsync_wire),
	.v_sync(vsync_wire),
    .x(x),
    .y(y)
);

reg [9:0] box_start_x = 100;
reg [9:0] box_start_y = 100;
localparam box_width = 100;
localparam box_height = 100;

always @(posedge vsync_wire) begin
    if (btn[6]) begin
        box_start_x <= box_start_x + 1;
    end else if (btn[5]) begin
        box_start_x <= box_start_x - 1;
    end else if (btn[3]) begin
        box_start_y <= box_start_y - 1;
    end else if (btn[4]) begin
        box_start_y <= box_start_y + 1;
    end
end

always @(x,y) begin
    if ((x > box_start_x) && (x < (box_start_x + box_width)) &&
        (y > box_start_y) && (y < (box_start_y + box_height))) begin
        red_input <= 8'd255;
        green_input <= 8'd127;
        blue_input <= 8'd0;
    end else begin
        red_input <= 8'd80;
        green_input <= 8'd80;
        blue_input <= 8'd80;
    end
end

parallel_to_serial red(
    .clk(dataclk_wire),
    .pixelclk(clk_25mhz),
	 .rst(rst),
	 .color_input(red_input),
	 .blanking(blanking_wire),
	 .c0(gnd),
	 .c1(gnd),
	 .dout(gpdi_dp[2])
);

parallel_to_serial green(
    .clk(dataclk_wire),
    .pixelclk(clk_25mhz),
	 .rst(rst),
	 .color_input(green_input),
	 .blanking(blanking_wire),
	 .c0(gnd),
	 .c1(gnd),
	 .dout(gpdi_dp[1])
);

parallel_to_serial blue(
    .clk(dataclk_wire),
    .pixelclk(clk_25mhz),
	 .rst(rst),
	 .color_input(blue_input),
	 .blanking(blanking_wire),
	 .c0(hsync_wire),
	 .c1(vsync_wire),
	 .dout(gpdi_dp[0])
);

assign gpdi_dp[3] = clk_25mhz;
assign gpdi_dn[3] = ~clk_25mhz;
assign gpdi_dn = ~gpdi_dp;

endmodule
