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
	iverilog -o simulation/datachannel datachannel.v datachannel_test.v
	vvp simulation/datachannel
	iverilog -o simulation/video_sync video_sync.v video_sync_test.v
	vvp simulation/video_sync

.PHONY: all clean simulation
