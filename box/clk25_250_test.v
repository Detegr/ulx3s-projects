module clk25_250(
    input clk_25mhz, 
    output locked,
    output clko
);
reg clk = 1;
always #1 clk = !clk;
assign locked = 0;
assign clko = clk;
endmodule
