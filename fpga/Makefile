DEVICE = GW1NR-LV9QN88PC6/I5
FAMILY = GW1N-9C
BOARD  = tangnano9k
TOP    = top

RTL := $(wildcard rtl/*.v)

export PYTHONWARNINGS := ignore::UserWarning

.PHONY: all upload flash sim wave clean

all: build/top.fs

build:
	@mkdir -p build

build/top.json: $(RTL) | build
	@yosys -qq -p "read_verilog $(RTL); synth_gowin -top $(TOP) -json build/top.json"

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

sim: $(RTL) sim/uart_sim.v | build
	@iverilog -I rtl -s uart_sim -o build/uart_sim.vvp $(RTL) sim/uart_sim.v
	@vvp build/uart_sim.vvp
	
wave: sim
	@gtkwave build/uart_sim.vcd sim/uart_sim.gtkw >nul 2>&1

clean:
	@rm -rf build/*
