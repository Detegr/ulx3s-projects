`timescale 1ns / 1ps

module tsdm(
    input clk,
	input rst,
	input [7:0] din,
	input blanking,
	input c0,
	input c1,
	output reg [9:0] dout
);

reg signed [3:0] dc_bias;
wire signed [3:0] symbol_bias;
reg [9:0] dout_reg;

function [3:0] popcount;
	input [7:0] v;
	begin
		popcount = v[7] + v[6] + v[5] + v[4] + v[3] + v[2] + v[1] + v[0];
	end
endfunction

always @(*) begin
    dout_reg[0] = din[0];
    casez({popcount(din), din[0]})
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
            dout_reg = 10'bx;
        end
    endcase
end

assign symbol_bias = (popcount(dout_reg[7:0]) - 4);

always @(posedge clk) begin
	if(rst) begin
		dc_bias <= 4'b0;
        dout <= 10'bx;
	end else begin
        if(blanking) begin
			case({c1, c0})
				2'b00: dout <= 10'b1101010100;
				2'b01: dout <= 10'b0010101011;
				2'b10: dout <= 10'b0101010100;
				2'b11: dout <= 10'b1010101011;
			endcase
            dc_bias <= 0;
        end else begin
            if((dc_bias > 0 && symbol_bias > 0) ||
                (dc_bias < 0 && symbol_bias < 0)) begin
                dout[7:0] <= ~dout_reg[7:0];
                dout[9] <= 1;
                dc_bias <= ~symbol_bias;
            end else begin
                dout[7:0] <= dout_reg[7:0];
                dout[9] <= 0;
                dc_bias <= symbol_bias;
            end
            dout[8] <= dout_reg[8];
        end
	end
end

endmodule
