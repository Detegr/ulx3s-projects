module top(
    input clk_25mhz,
    input [7:0] btn, // Reset
    output[7:0] led,
    output [3:0] gpdi_dp, // BGR+ Clock+
    output [3:0] gpdi_dn // BGR- Clock-
);

wire rst_wire;
assign rst_wire = ~btn[0];
assign led[7:0] = 8'b0;

wire vsync_wire;
wire[2:0] rgb_wire;
wire[9:0] x;
wire[9:0] y;

reg [7:0] red_input;
reg [7:0] green_input;
reg [7:0] blue_input;

reg [9:0] box_start_x;
reg [9:0] box_start_y;
wire [9:0] box_next_x;
wire [9:0] box_next_y;
wire [9:0] box_prev_x;
wire [9:0] box_prev_y;

assign box_next_x = box_start_x + 1;
assign box_prev_x = box_start_x - 1;
assign box_next_y = box_start_y + 1;
assign box_prev_y = box_start_y - 1;

localparam box_width = 100;
localparam box_height = 100;

reg[7:0] loop;
reg[7:0] loop2;
reg[7:0] loop3;
wire[7:0] next_loop;
wire[7:0] next_loop2;
wire[7:0] next_loop3;
assign next_loop = loop + 1;
assign next_loop2 = loop2 + 2;
assign next_loop3 = loop3 + 1;

reg left, right, up, down;

always @(posedge vsync_wire) begin
    left <= btn[5];
    right <= btn[6];
    up <= btn[3];
    down <= btn[4];

    if(rst_wire) begin
        box_start_x <= 40;
        box_start_y <= 40;
        loop <= 8'd0;
        loop2 <= 8'd80;
        loop3 <= 8'd160;
    end else begin
        loop <= next_loop;
        loop2 <= next_loop2;
        loop3 <= next_loop3;

        if(right)
            box_start_x <= box_next_x;
        else if(left)
            box_start_x <= box_prev_x;
        else if(up)
            box_start_y <= box_prev_y;
        else if(down)
            box_start_y <= box_next_y;
    end
end

always @(*) begin
    if ((x > box_start_x) && (x < (box_start_x + box_width)) &&
        (y > box_start_y) && (y < (box_start_y + box_height))) begin
        red_input = loop;
        green_input = loop2;
        blue_input = loop3;
    end else begin
        red_input = 8'd80;
        green_input = 8'd80;
        blue_input = 8'd80;
    end
end

digital_video gpdi(
    .clk_25mhz(clk_25mhz),
    .rst(rst_wire),
    .red(red_input),
    .green(green_input),
    .blue(blue_input),
    .xout(x),
    .yout(y),
    .vsync_out(vsync_wire),
    .rgbout(rgb_wire)
);

assign gpdi_dp[0] = rgb_wire[2];
assign gpdi_dp[1] = rgb_wire[1];
assign gpdi_dp[2] = rgb_wire[0];
assign gpdi_dp[3] = clk_25mhz;
assign gpdi_dn = ~gpdi_dp;

endmodule
