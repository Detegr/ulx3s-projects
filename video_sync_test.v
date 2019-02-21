`timescale 1ns / 1ps

module video_sync_test;

reg rst = 1;

initial begin
    $dumpfile("simulation/video_sync_test.vcd");
    $dumpvars(0, video_sync_test);

    # 40 rst = 0;
    # 48000000 $finish;
end

reg clk = 0;
always #4 clk = !clk;

wire blanking_wire;
wire hsync_wire;
wire vsync_wire;
wire [9:0] x_wire;
wire [9:0] y_wire;

video_sync sync(
    .clk(clk),
    .rst(rst),
    .blanking(blanking_wire),
    .h_sync(hsync_wire),
    .v_sync(vsync_wire),
    .x(x_wire),
    .y(y_wire)
);

endmodule
