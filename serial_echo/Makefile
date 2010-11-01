TARGETS:=$(patsubst %.vhd,%,$(wildcard *.vhd))

all: work
	@echo Available targets: $(TARGETS)

clean:
	rm -rf work

work:
	mkdir work

make-%: work/work-obj93.cf
	ghdl -m --workdir=work $(patsubst make-%,%,$@)

run-%: make-%
	ghdl -r --workdir=work $(patsubst run-%,%, $@) $(ARGS) 2>&1 | perl -n -e'/.*.vhd:[0-9]*:[0-9]*:@([0-9a-z]*):.*: (.*)/ && printf "%15s %s\n",$$1,$$2'

import: work $(wildcard *.vhd)
	ghdl -i --workdir=work $(filter %.vhd, $?)

# Xilinx
%.bin: %.bit
	promgen -w -p bin -u 0 $<
