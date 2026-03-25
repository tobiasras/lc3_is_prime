; Standalone demo harness for readS
.ORIG x3000
    LD R6, STACK_TOP
    JSR readS
    HALT

; --- readS ---
; Input : none
; Output: R0 = parsed number (0-99), or -1 for invalid character input
; Note  : This parser currently accepts one-digit (digit + Enter)
;         and two-digit numbers.
; Includes its own dependencies (isNotNumber, multiply) for standalone running

readS
    ADD R6, R6, #-1
    STR R7, R6, #0

    LEA R0, ask_for_a_number   ; prompt string
    PUTS                       ; print prompt string

    AND R5, R5, #0             ; init register for final parsed number

    ; FIRST DIGIT
    GETC                       ; read first key as ASCII into R0
    AND R2, R2, #0
    ADD R2, R2, R0             ; preserve raw ASCII
    JSR isNotNumber            ; validates R2 and returns numeric digit in R1
    ADD R0, R0, #0
    BRp NOT_A_NUMBER           ; if R0==1 then non-digit -> invalid input
    ADD R4, R1, #0             ; store first numeric digit for single-digit case
    ADD R0, R0, R2
    OUT                        ; echo typed first character back to console
    AND R0, R0, #0
    ADD R0, R0, #10            ; decimal place multiplier for tens place
    JSR multiply
    ADD R5, R5, R0             ; add tens contribution to accumulator

    ; SECOND DIGIT
    GETC                       ; read second key (digit or Enter)
    AND R2, R2, #0
    ADD R2, R2, R0             ; keep raw second key
    ADD R0, R2, #-10           ; check for LF Enter (ASCII 10)
    BRz SINGLE_DIGIT_RETURN    ; if Enter, number is just first digit
    JSR isNotNumber            ; otherwise second key must be a digit
    ADD R0, R0, #0             ; update CC from validator
    BRp NOT_A_NUMBER           ; reject if not a digit
    ADD R0, R0, R2
    OUT                        ; echo second digit

    ADD R5, R5, R1             ; add ones place to accumulator
    BR RETURN

SINGLE_DIGIT_RETURN:
    AND R5, R5, #0             ; clear accumulator (was firstDigit*10)
    ADD R5, R5, R4             ; replace with only first digit value
    BR RETURN

RETURN:
    ; print newline for cleaner console output
    AND R0, R0, #0
    ADD R0, R0, #13            ; carriage return
    OUT

    AND R0, R0, #0
    ADD R0, R0, R5             ; move final parsed number to return register

    LDR R7, R6, #0
    ADD R6, R6, #1
    RET

NOT_A_NUMBER:
    AND R0, R0, #0
    ADD R0, R0, R2             ; print bad character
    OUT
    LEA R0, bad_input          ; print validation failure message
    PUTS

    AND R5, R5, #0
    ADD R5, R5, #-1            ; return -1 to indicate failure

    BR RETURN

; Local data used by readS
ask_for_a_number .STRINGZ "Input a number.\n"
bad_input        .STRINGZ " <-- Bad input! (TYPE A NUMBER)\n"


; Local data used by standalone harness + dependencies
STACK_TOP        .FILL xFDFF
NEGATIVE_ASCII_ZERO .FILL #-48

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

; --- multiply ---
; Input : R0 = multiplicand, R1 = multiplier
; Output: R0 = multiplicand * multiplier
multiply
    ADD R6, R6, #-1            
    STR R7, R6, #0
    ADD R2, R0, #0             ; keep multiplicand in R2
    AND R0, R0, #0             ; clear result accumulator

    ADD R1, R1, #0             ; if multiplier <= 0, product is 0
    BRnz MUL_DONE

LOOP_START
    ADD R0, R0, R2             ; accumulate multiplicand
    ADD R1, R1, #-1            ; decrement remaining iterations
    BRp LOOP_START             ; repeat while multiplier still positive

MUL_DONE

    LDR R7, R6, #0             
    ADD R6, R6, #1             
    RET

.END
