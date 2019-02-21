`timescale 1ns / 1ps

module previous_value(
    input clk,
    input signed [3:0] current_value,
    output signed [3:0] previous_value
);

reg signed [3:0] input_value_1;
reg signed [3:0] input_value_2;
reg selection;

always @(posedge clk) begin
	if(selection) begin
		selection <= 0;
        input_value_2 <= current_value;
        previous_value <= input_value_1;
	end else begin
		selection <= 1;
        input_value_1 <= current_value;
        previous_value <= input_value_2;
	end
end

endmodule
