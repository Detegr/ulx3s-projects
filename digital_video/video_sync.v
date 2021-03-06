`timescale 1ns / 1ps

module video_sync(
	input clk,
	input rst,
	output reg blanking,
	output reg h_sync,
	output reg v_sync,
    output [9:0] x,
    output [9:0] y,
    output reg pixel_clk
);

function between;
	input [9:0]x, start_px, end_px;
	begin
		between = (x >= start_px) && (x <= end_px);
	end
endfunction

localparam h_total_px = h_front_porch_px + h_video_px + h_sync_px + h_back_porch_px;
localparam v_total_px = v_front_porch_px + v_video_px + v_sync_px + v_back_porch_px;

localparam h_video_px = 640;
localparam v_video_px = 480;

//localparam h_video_px = 800;
//localparam v_video_px = 600;

localparam h_front_porch_px = 16;
localparam h_back_porch_px = 48;
localparam h_sync_px = 96;

//localparam h_front_porch_px = 40;
//localparam h_back_porch_px = 88;
//localparam h_sync_px = 128;

localparam h_porch_start_px = h_video_px - 1;
localparam h_sync_start_px = h_porch_start_px + h_front_porch_px;
localparam h_sync_end_px = h_sync_start_px + h_sync_px;

localparam v_front_porch_px = 10;
localparam v_back_porch_px = 33;
localparam v_sync_px = 2;

//localparam v_front_porch_px = 1;
//localparam v_back_porch_px = 23;
//localparam v_sync_px = 4;

localparam v_porch_start_px = v_video_px - 1;
localparam v_sync_start_px = v_porch_start_px + v_front_porch_px;
localparam v_sync_end_px = v_sync_start_px + v_sync_px;

reg[9:0] h_pixel;
reg[9:0] h_next_pixel;

assign x = h_pixel;

reg[9:0] v_pixel;
reg[9:0] v_next_pixel;

assign y = v_pixel;

wire[2:0] vga_input;
wire in_h_blank;
wire in_v_blank;
wire h_sync_wire;
wire v_sync_wire;

assign h_sync_wire = between(h_next_pixel, h_sync_start_px, h_sync_end_px);
assign v_sync_wire = between(v_next_pixel, v_sync_start_px, v_sync_end_px);

reg[3:0] pixel_clk_counter;
reg[3:0] pixel_clk_next;

always @(*) begin
	h_next_pixel = ((h_pixel + 1) == h_total_px) ? 0 : h_pixel + 1;
    if((h_pixel + 1) == h_total_px)
        v_next_pixel = ((v_pixel + 1) == v_total_px) ? 0 : v_pixel + 1;
    else
        v_next_pixel = v_pixel;
	pixel_clk_next = (pixel_clk_counter + 1) == 10 ? 0 : pixel_clk_counter + 1;
end

always @(posedge clk) begin
	if(rst) begin
        h_pixel <= h_total_px - 1;
        v_pixel <= v_total_px - 1;
        h_sync <= 0;
        v_sync <= 0;
		pixel_clk_counter <= 4'd9;
		pixel_clk <= 0;
	end else begin
		pixel_clk_counter <= pixel_clk_next;
		pixel_clk <= pixel_clk_next < 5;

        if(pixel_clk_next == 0) begin
            h_pixel <= h_next_pixel;
            v_pixel <= v_next_pixel;
            h_sync <= h_sync_wire;
            v_sync <= v_sync_wire;
            blanking <= (h_next_pixel > h_porch_start_px) || (v_next_pixel > v_porch_start_px);
        end
    end
end

endmodule
