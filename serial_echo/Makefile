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
	ghdl -r --workdir=work $(patsubst run-%,%, $@) $(ARGS)

import: work $(wildcard *.vhd)
	ghdl -i --workdir=work $(filter %.vhd, $?)
