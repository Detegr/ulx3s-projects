OUTFILE := digital_video.bit
all: bitstream

clean:
	rm -rf top.json ulx3s_out.config $(OUTFILE)

bitstream: ulx3s_out.config
	ecppack --idcode 0x21111043 ulx3s_out.config $(OUTFILE)

ulx3s_out.config: top.json
	nextpnr-ecp5 --25k --json top.json --lpf ulx3s_v20_segpdi.lpf --textcfg ulx3s_out.config --force

top.json: top.ys top.v
	yosys top.ys 

prog: ulx3s.bit
	ujproj $(OUTFILE)

.PHONY: all
.PHONY: clean
