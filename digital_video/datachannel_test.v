`timescale 1ns / 1ps

module datachannel_test;

reg rst = 1;

initial begin
    $dumpfile("simulation/datachannel.vcd");
    $dumpvars(0, datachannel_test);

    # 40 rst = 0;
    # 1000 $finish;
end

reg clk = 0;
always #20 clk = !clk;

reg [9:0] data = 10'b1111000011;
wire data_out;

datachannel dchnl(
    .clk(clk),
    .rst(rst),
    .data(data),
    .dout(data_out)
);

endmodule
