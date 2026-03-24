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
