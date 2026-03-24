; --- SUBROUTINE: isPrime ---
; Input : R0 = number
; Output: R0 = 1 if prime, 0 otherwise

isPrime
    ADD R6, R6, #-1            ; push return address
    STR R7, R6, #0

    ; n < 2 is not prime
    ADD R1, R0, #-2
    BRn IS_NOT_PRIME
    ; 2 is prime
    BRz IS_PRIME

    ; check if divisible by any d where 2 <= d < n
    AND R2, R2, #0
    ADD R2, R2, #2

PRIME_OUTER_LOOP
    ; if d - n == 0, no divisor found => prime
    NOT R3, R0
    ADD R3, R3, #1
    ADD R3, R2, R3
    BRz IS_PRIME

    ; remainder = n
    ADD R4, R0, #0

PRIME_REMAINDER_LOOP
    NOT R3, R2                 ; build -d
    ADD R3, R3, #1
    ADD R3, R4, R3  

    ; remainder -= d
    BRn PRIME_NEXT_DIVISOR
    ADD R4, R3, #0
    BR PRIME_REMAINDER_LOOP

PRIME_NEXT_DIVISOR
    ADD R4, R4, #0             ; set CC from final remainder
    BRz IS_NOT_PRIME           ; if remainder==0 then d divides n => composite
    ADD R2, R2, #1             ; try next divisor
    BR PRIME_OUTER_LOOP

IS_PRIME
    AND R0, R0, #0
    ADD R0, R0, #1             ; return true
    BR PRIME_RETURN

IS_NOT_PRIME
    AND R0, R0, #0             ; return false

PRIME_RETURN
    LDR R7, R6, #0             ; restore return address
    ADD R6, R6, #1             ; pop stack
    RET
