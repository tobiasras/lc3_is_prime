.ORIG x3000

; ======================================================================
; Program flow:
; 1) Ask user for a number (currently supports one or two digits).
; 2) Reject invalid input by returning -1 from readS.
; 3) Check primality with isPrime.
; 4) Print result with resultS.
; 5) Loop forever.
; ==========================================================================

START:
    LD R6, STACK_TOP          
    JSR readS                 ; returns parsed number in R0, or -1 on bad input
    ADD R0, R0, #0            ; set condition codes from readS return value
    BRn START                 ; if negative, readS signaled invalid input -> retry
    JSR isPrime               ; convert number in R0 to prime flag (1 prime, 0 not)
    JSR resultS               ; print message based on prime flag in R0
    BR START                  ; repeat indefinitely
    HALT

; --- readS ---
; Input : none
; Output: R0 = parsed number (0-99), or -1 for invalid character input
; Note  : This parser currently accepts one-digit (digit + Enter)
;         and two-digit numbers.

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
    JSR multiply               ; R0 = firstDigit * 10
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

LOOP_START
    ADD R0, R0, R2             ; accumulate multiplicand
    ADD R1, R1, #-1            ; decrement remaining iterations
    BRp LOOP_START             ; repeat while multiplier still positive

    LDR R7, R6, #0             
    ADD R6, R6, #1             
    RET


; --- SUBROUTINE: isPrime ---
; Input : R0 = number
; Output: R0 = 1 if prime, 0 otherwise
isPrime
    ADD R6, R6, #-1            ; push return address
    STR R7, R6, #0

    ; n < 2 is not prime
    ADD R1, R0, #-2            ; n-2
    BRn IS_NOT_PRIME           ; if n<2 => not prime
    ; 2 is prime
    BRz IS_PRIME               ; if n==2 => prime

    ; check if divisible by any d where 2 <= d < n
    AND R2, R2, #0
    ADD R2, R2, #2             ; divisor d starts at 2

PRIME_OUTER_LOOP
    ; if d - n == 0, no divisor found => prime
    NOT R3, R0                 ; build -n
    ADD R3, R3, #1
    ADD R3, R2, R3             ; d-n
    BRz IS_PRIME               ; if d==n, no divisors found => prime

    ; remainder = n
    ADD R4, R0, #0             ; remainder candidate starts as n

PRIME_REMAINDER_LOOP
    NOT R3, R2                 ; build -d
    ADD R3, R3, #1
    ADD R3, R4, R3  
    
    ; remainder -= d
    BRn PRIME_NEXT_DIVISOR     ; when remainder < d, d is not a divisor
    ADD R4, R3, #0             ; keep subtracting d
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

; Shared data/constants
STACK_TOP            .FILL xFDFF                                    ; initial stack pointer
ask_for_a_number     .STRINGZ "Input a number.\n"                   ; input prompt
bad_input            .STRINGZ " <-- Bad input! (TYPE A NUMBER)\n"   ; validation error
prime_message        .STRINGZ "The number is a prime\n\n"           ; prime output
not_prime_message    .STRINGZ "The number is not a prime\n\n"       ; non-prime output
NEGATIVE_ASCII_ZERO  .FILL #-48                                     ; constant: -'0'

.END