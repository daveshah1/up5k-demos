ARACHNE = arachne-pnr
ARACHNE_ARGS = 
ICEPACK = icepack
ICETIME = icetime
ICEPROG = iceprog
SOURCES = $(wildcard *.v)
# ---- iCE40 UP5k Breakout Board ----


up5knes.blif:  $(SOURCES)
	yosys -ql up5knes.log -p 'synth_ice40 -top NES_ice40 -blif up5knes.blif' $^

up5knes_syn.v: up5knes.blif
	yosys -p 'read_blif -wideports up5knes.blif; write_verilog up5knes_syn.v'

up5knes.asc: up5k.pcf up5knes.blif
	$(ARACHNE) -d 5k $(ARACHNE_ARGS) -o up5knes.asc -p up5k.pcf up5knes.blif

up5knes.bin: up5knes.asc
	# $(ICETIME) -d up5k -c 12 -mtr up5knes.rpt up5knes.asc
	$(ICEPACK) up5knes.asc up5knes.bin

rom/game.bin: rom/game.nes
	rom/nes2bin.py $^ $@
	
up5kprog: up5knes.bin rom/game.bin
	$(ICEPROG) up5knes.bin
	$(ICEPROG) -o 1M rom/game.bin

up5kprog_game: rom/game.bin
	$(ICEPROG) -o 1M rom/game.bin



# ---- Clean ----

clean:
	rm -f up5knes.blif up5knes.log up5knes.asc up5knes.rpt up5knes.bin

.PHONY: up5kprog up5kprog_fw  clean

