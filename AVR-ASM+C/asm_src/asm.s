;
; asm.asm
;
; Created: 9/11/2021 7:37:34 AM
; Author : Aman Kumar Singh
;

.GLOBAL toggle

toggle:
 IN R18,0x05
 COM R18
 OUT 0x05,R18
 RET
