`timescale 1ns / 1ps

module previous_value(
	 input clk,
    input signed [3:0] current_value,
    output signed [3:0] previous_value
);

reg signed [3:0] input_value_1;
reg signed [3:0] input_value_2;
reg selection = 0;

assign previous_value = selection ? input_value_1 : input_value_2;

always @(*) begin
	if(selection) begin
		input_value_2 <= current_value;
	end else begin
		input_value_1 <= current_value;
	end
end

always @(posedge clk) begin
	if(selection) begin
		selection <= 0;
	end else begin
		selection <= 1;
	end
end

endmodule
