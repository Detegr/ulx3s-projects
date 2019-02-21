`timescale 1ns / 1ps

module tsdm(
	input rst,
	input [7:0] din,
	input blanking,
	input c0,
	input c1,
	input signed [3:0] prev_dc_bias,
	output signed [3:0] dc_bias,
	output [9:0] dout
);

reg [3:0] popcount_din;
reg [3:0] popcount_res;
reg signed [3:0] symbol_bias;
reg signed [3:0] dc_bias_out_reg;
reg [3:0] i;

reg [9:0] dout_reg;

assign dout = dout_reg;
assign dc_bias = dc_bias_out_reg;

function [3:0] popcount;
	input [7:0] v;
	begin
		popcount = v[7] + v[6] + v[5] + v[4] + v[3] + v[2] + v[1] + v[0];
	end
endfunction

always @(*) begin
	if(rst) begin
		dc_bias_out_reg = 4'b0;
	end else begin
		if(blanking) begin
			case({c1, c0})
				2'b00: dout_reg = 10'b1101010100;
				2'b01: dout_reg = 10'b0010101011;
				2'b10: dout_reg = 10'b0101010100;
				2'b11: dout_reg = 10'b1010101011;
			endcase
			dc_bias_out_reg = 0;
		end else begin
			popcount_din = popcount(din);
			dout_reg[0] = din[0];
			casez({popcount_din, din[0]})
				5'b0000z,5'b0001z,5'b0010z,5'b0011z,5'b01001 : begin
                    dout_reg[1] = dout_reg[0] ^ din[1];
                    dout_reg[2] = dout_reg[1] ^ din[2];
                    dout_reg[3] = dout_reg[2] ^ din[3];
                    dout_reg[4] = dout_reg[3] ^ din[4];
                    dout_reg[5] = dout_reg[4] ^ din[5];
                    dout_reg[6] = dout_reg[5] ^ din[6];
                    dout_reg[7] = dout_reg[6] ^ din[7];
					dout_reg[8] = 1;
				end
				5'b01000,5'b0101z,5'b0110z,5'b0111z,5'b1000z : begin
                    dout_reg[1] = dout_reg[0] == din[1];
                    dout_reg[2] = dout_reg[1] == din[2];
                    dout_reg[3] = dout_reg[2] == din[3];
                    dout_reg[4] = dout_reg[3] == din[4];
                    dout_reg[5] = dout_reg[4] == din[5];
                    dout_reg[6] = dout_reg[5] == din[6];
                    dout_reg[7] = dout_reg[6] == din[7];
					dout_reg[8] = 0;
				end
				default: begin
					dout_reg = 9'bx;
				end
			endcase
			
			popcount_res = popcount(dout_reg[7:0]);
			symbol_bias = (popcount_res - 4);
			if((prev_dc_bias > 0 && symbol_bias > 0) ||
				(prev_dc_bias < 0 && symbol_bias < 0)) begin
				dout_reg[7:0] = ~dout_reg[7:0];
				dout_reg[9] = 1;
				dc_bias_out_reg = ~symbol_bias;
			end else begin
				dout_reg[9] = 0;
				dc_bias_out_reg = symbol_bias;
			end
		end
	end
end

endmodule
