`timescale 1ns / 1ps
module datachannel(
    input clk,
    input rst,
    input [9:0] data,
    output dout
);

reg[3:0] i;
reg[3:0] i_next;
reg dout_reg;

assign dout = data[i];

always @(dout_reg, i) begin
	i_next = i + 1;
	if(i_next == 10) begin
		i_next = 0;
	end
end

always @(posedge clk) begin
	if(rst) begin
		i <= 4'd9;
	end else begin
		i <= i_next;
	end
end

endmodule
