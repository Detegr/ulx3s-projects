module top(
    input clk_25mhz,
    input [7:0] btn, // Reset
    output[7:0] led,
    output [3:0] gpdi_dp, // BGR+ Clock+
    output [3:0] gpdi_dn // BGR- Clock-
);

assign rst = ~btn[0];

assign led[7:0] = 8'b0;

wire[9:0] x;
wire[9:0] y;

reg [7:0] red_input;
reg [7:0] green_input;
reg [7:0] blue_input;

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

always @(*) begin
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

digital_video gpdi(
    .clk_25mhz(clk_25mhz),
    .rst(rst),
    .red(red_input),
    .green(green_input),
    .blue(blue_input),
    .xout(x),
    .yout(y),
    .rgbout(rgb)
);

assign rgb = {gpdi_dp[2], gpdi_dp[1], gpdi_dp[0]};
assign gpdi_dp[3] = clk_25mhz;
assign gpdi_dn[3] = ~clk_25mhz;
assign gpdi_dn = ~gpdi_dp;

endmodule
