; Standalone demo harness for resultS
; can be testet by typing 0, or 1


.ORIG x3000
    LD R6, STACK_TOP
    GETC
    OUT
    ; Convert '0'..'9' => 0..9 (resultS treats 0 as false, non-zero as true)
    LD R1, NEGATIVE_ASCII_ZERO
    ADD R0, R0, R1
    JSR resultS

    AND R0, R0, #0
    ADD R0, R0, #13
    OUT
    HALT

; --- SUBROUTINE: resultS ---
; Input : R0 = prime flag (0 = not prime, non-zero = prime)
; Output: none (prints result message to console)

resultS
    ADD R6, R6, #-1            ; push return address
    STR R7, R6, #0

    ADD R0, R0, #0             ; set CC from prime flag
    BRz RESULT_NOT_PRIME       ; 0 => not prime message

    LEA R0, prime_message      ; load address of prime message
    PUTS                       ; print "prime"
    BR RESULT_RETURN

RESULT_NOT_PRIME
    LEA R0, not_prime_message  ; load address of not-prime message
    PUTS                       ; print "not prime"

RESULT_RETURN
    LDR R7, R6, #0             ; restore return address
    ADD R6, R6, #1             ; pop stack
    RET

; Local data used by resultS
prime_message     .STRINGZ "The number is a prime\n\n"
not_prime_message .STRINGZ "The number is not a prime\n\n"

; Local data used by standalone harness
STACK_TOP           .FILL xFDFF
NEGATIVE_ASCII_ZERO .FILL #-48

.END
