; shitty LED scroller test

init:
	LD		A,1
	
loop:
	OUT		(40h),A
	RLA
	PUSH 	AF
	CALL	delay
	POP 	AF
	JP		loop

delay:
	LD		BC,65535
delay_loop:
    DEC 	BC
    LD 		A,C
    OR 		B
    JP 		NZ, delay_loop
    RET
	
