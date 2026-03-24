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
