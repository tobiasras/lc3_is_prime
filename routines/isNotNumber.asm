
.ORIG x3000
    LD R6, STACK_TOP
    GETC                    ; ASCII in R0
    OUT                     ; echo character
    ADD R2, R0, #0         ; R2 = ASCII for validator
    JSR isNotNumber        ; R0=0 valid digit, 1 invalid digit

    LD R3, ASCII_ZERO      ; convert flag to ASCII '0'/'1'
    ADD R0, R0, R3
    OUT

    AND R0, R0, #0
    ADD R0, R0, #13
    OUT
    HALT

; --- SUBROUTINE: isNotNumber ---
; Input : R2 = ASCII character to validate
; Output: R0 = 0 if character is digit ('0'..'9'), else 1
;         R1 = digit value 0..9 when valid

isNotNumber
    ADD R6, R6, #-1           
    STR R7, R6, #0

    AND R1, R1, #0
    LD R1, NEGATIVE_ASCII_ZERO ; R1 = -'0'
    ADD R0, R2, R1             ; R0 = ASCII - '0'
    AND R1, R1, #0
    ADD R1, R1, R0              ; store converted digit candidate in R1
    BRn EXIT_NOT_NUMBER         ; < 0 means below '0'

    ADD R0, R0, #-9             ; test upper bound against 9
    BRp EXIT_NOT_NUMBER         ; > 9 means above '9'
    AND R0, R0, #0              ; valid digit => return 0 (false: not "not number")
    BR EXIT

EXIT_NOT_NUMBER:
    AND R0, R0, #0
    ADD R0, R0, #1             ; invalid digit => return 1

EXIT:
    LDR R7, R6, #0             
    ADD R6, R6, #1             
    RET

; Local data used by isNotNumber
NEGATIVE_ASCII_ZERO .FILL #-48

; Local data used by standalone harness
STACK_TOP   .FILL xFDFF
ASCII_ZERO  .FILL x0030

.END
