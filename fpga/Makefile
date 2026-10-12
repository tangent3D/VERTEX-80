DEVICE = GW1NR-LV9QN88PC6/I5
FAMILY = GW1N-9C
BOARD  = tangnano9k
TOP    = top

RTL := $(wildcard rtl/*.v)

TV80_RTL := \
    third-party/tv80/rtl/core/tv80_alu.v \
    third-party/tv80/rtl/core/tv80_reg.v \
    third-party/tv80/rtl/core/tv80_mcode.v \
    third-party/tv80/rtl/core/tv80_core.v \
    third-party/tv80/rtl/core/tv80n.v

SOURCES := $(RTL) $(TV80_RTL)

export PYTHONWARNINGS := ignore::UserWarning

.PHONY: all upload flash sim wave clean

all: build/top.fs

build:
	@mkdir -p build

build/top.json: $(SOURCES) | build
	@yosys -qq -p "read_verilog -Irtl $(SOURCES); synth_gowin -top $(TOP) -json build/top.json"

build/top_pnr.json: build/top.json constraints/tangnano9k.cst
	@nextpnr-himbaechel -q \
		--json build/top.json \
		--write build/top_pnr.json \
		--report build/report.json \
		--device $(DEVICE) \
		--freq 27 \
		--vopt family=$(FAMILY) \
		--vopt cst=constraints/tangnano9k.cst

build/top.fs: build/top_pnr.json
	@gowin_pack -d $(FAMILY) -o build/top.fs build/top_pnr.json

upload: build/top.fs
	@openFPGALoader -b $(BOARD) build/top.fs

flash: build/top.fs
	@openFPGALoader -b $(BOARD) -f build/top.fs

SIM ?= top

sim: $(SOURCES) sim/$(SIM)_sim.v | build
	@iverilog -DSIMULATION -I rtl -s $(SIM)_sim -o build/$(SIM)_sim.vvp $(SOURCES) sim/$(SIM)_sim.v
	@vvp build/$(SIM)_sim.vvp

wave: sim
	@gtkwave build/$(SIM)_sim.vcd sim/$(SIM)_sim.gtkw >nul 2>&1

clean:
	@rm -rf build/*
