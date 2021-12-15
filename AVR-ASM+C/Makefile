SRC=./src/main
SRC_ASM =./asm_src/asm
CXX=avr-gcc

MCU=atmega328p #m32
CPU_SPEED=16000000UL
CFLAGS= -mmcu=$(MCU) -DF_CPU=$(CPU_SPEED) -Os -Wall -Wl,--gc-sections -ffunction-sections -fdata-sections


avrdudeMCU=m328p #m32
programmer=arduino #usbasp
conf=-C ./avrdude.conf 
speed=115200
flags= -v
port=/dev/ttyUSB0


build: $(SRC).hex

$(SRC).elf: $(SRC).c $(SRC_ASM).s
	$(CXX) $(CFLAGS) $^ -o $@
	avr-size -C $(SRC).elf
	
$(SRC).hex: $(SRC).elf
	avr-objcopy -O ihex $< $@



upload: $(SRC).hex
	avrdude $(flags) -p $(avrdudeMCU) -c $(programmer) -P$(port) -b $(speed) -Uflash:w:$(SRC).hex $(conf)

clean:
	rm -f $(SRC).elf $(SRC).hex
	@echo "Cleaned"
