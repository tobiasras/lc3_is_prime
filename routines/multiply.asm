; Standalone demo harness for multiply
.ORIG x3000
    LD R6, STACK_TOP
    LD R0, TEST_A
    LD R1, TEST_B
    JSR multiply                  ; result in R0
    HALT

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

; Local data used by standalone harness
STACK_TOP  .FILL xFDFF
TEST_A     .FILL #3
TEST_B     .FILL #3

.END
