`timescale 1ns / 1ps

module tsdm(
	input rst,
	input [7:0] din,
	input blanking,
	input c0,
	input c1,
	output reg [9:0] dout
);

reg signed [3:0] dc_bias;
reg signed [3:0] symbol_bias;

function [3:0] popcount;
	input [7:0] v;
	begin
		popcount = v[7] + v[6] + v[5] + v[4] + v[3] + v[2] + v[1] + v[0];
	end
endfunction

always @(*) begin
	if(rst) begin
		dout = 10'bx;
		dc_bias = 4'b0;
		symbol_bias = 0;
	end else begin
		if(blanking) begin
			case({c1, c0})
				2'b00: dout = 10'b1101010100;
				2'b01: dout = 10'b0010101011;
				2'b10: dout = 10'b0101010100;
				2'b11: dout = 10'b1010101011;
			endcase
			dc_bias = 0;
			symbol_bias = 0;
		end else begin
			dout[0] = din[0];
			casez({popcount(din), din[0]})
				5'b0000z,5'b0001z,5'b0010z,5'b0011z,5'b01001 : begin
					dout[1] = dout[0] ^ din[1];
					dout[2] = dout[1] ^ din[2];
					dout[3] = dout[2] ^ din[3];
					dout[4] = dout[3] ^ din[4];
					dout[5] = dout[4] ^ din[5];
					dout[6] = dout[5] ^ din[6];
					dout[7] = dout[6] ^ din[7];
					dout[8] = 1;
				end
				5'b01000,5'b0101z,5'b0110z,5'b0111z,5'b1000z : begin
					dout[1] = dout[0] == din[1];
					dout[2] = dout[1] == din[2];
					dout[3] = dout[2] == din[3];
					dout[4] = dout[3] == din[4];
					dout[5] = dout[4] == din[5];
					dout[6] = dout[5] == din[6];
					dout[7] = dout[6] == din[7];
					dout[8] = 0;
				end
				default: begin
					dout = 9'bx;
				end
			endcase
			
			symbol_bias = (popcount(dout[7:0]) - 4);
			if((prev_dc_bias > 0 && symbol_bias > 0) ||
				(prev_dc_bias < 0 && symbol_bias < 0)) begin
				dout[7:0] = ~dout[7:0];
				dout[9] = 1;
				dc_bias = ~symbol_bias;
			end else begin
				dout[9] = 0;
				dc_bias = symbol_bias;
			end
		end
	end
end

endmodule
