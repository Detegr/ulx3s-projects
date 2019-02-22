OUTFILE := digital_video.bit
all: bitstream

clean:
	rm -rf top.json ulx3s_out.config $(OUTFILE) simulation/

bitstream: ulx3s_out.config
	ecppack --idcode 0x21111043 ulx3s_out.config $(OUTFILE)

ulx3s_out.config: top.json
	nextpnr-ecp5 --25k --json top.json --lpf ulx3s_v20.lpf --textcfg ulx3s_out.config

top.json: top.ys top.v
	yosys top.ys 

prog: ulx3s.bit
	ujproj $(OUTFILE)

simulation:
	-mkdir -p simulation
	iverilog -o simulation/datachannel ../digital_video/datachannel.v ../digital_video/datachannel_test.v
	vvp simulation/datachannel
	iverilog -o simulation/video_sync ../digital_video/video_sync.v ../digital_video/video_sync_test.v
	vvp simulation/video_sync
	iverilog -o simulation/test test.v top.v clk25_250_test.v ../digital_video/digital_video.v ../digital_video/video_sync.v ../digital_video/tsdm.v ../digital_video/previous_value.v ../digital_video/datachannel.v ../digital_video/coloroutput.v
	vvp simulation/test

.PHONY: all clean simulation
