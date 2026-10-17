UART_DATA       EQU 080h
UART_STATUS     EQU 081h
ROM_DISABLE     EQU 038h

RAM_TOP         EQU 0A7FFh
HANDOFF_RAM     EQU RAM_TOP+1-(handoff_end-handoff)

    ORG 0000h

start:
    LD SP,0A800h

    CALL receive_byte
    LD C,A

    CALL receive_byte
    LD B,A

    LD HL,0000h

load_loop:
    LD A,B
    OR C
    JR Z,prepare_handoff

    CALL receive_byte
    LD (HL),A
    INC HL
    DEC BC
    JR load_loop

receive_byte:
    IN A,(UART_STATUS)
    AND 01h
    JR Z,receive_byte

    IN A,(UART_DATA)
    RET

prepare_handoff:
    LD HL,handoff
    LD DE,HANDOFF_RAM
    LD BC,handoff_end-handoff
    LDIR

    JP HANDOFF_RAM

handoff:
    LD A,01h
    OUT (ROM_DISABLE),A
    JP 0000h
handoff_end:

DEFS 4096 - ASMPC, 0xFF