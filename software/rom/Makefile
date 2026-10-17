.PHONY: clean

rom.hex: rom.bin
	@python ../scripts/bin2hex.py rom.bin rom.hex

rom.bin: rom.asm
	@z80asm -b -m -orom.bin rom.asm

clean:
	@python ../scripts/clean.py