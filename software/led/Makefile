.PHONY: upload clean

led.bin: led.asm
	@z80asm -b -m -oled.bin led.asm

upload: led.bin
	@python ../scripts/serial_loader.py led.bin

clean:
	@python ../scripts/clean.py
