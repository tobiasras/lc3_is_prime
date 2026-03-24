; --- readS ---
; Input : none
; Output: R0 = parsed number (0-99), or -1 for invalid character input
; Note  : This parser currently accepts one-digit (digit + Enter)
;         and two-digit numbers.
; Depends on external routines: isNotNumber, multiply

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
