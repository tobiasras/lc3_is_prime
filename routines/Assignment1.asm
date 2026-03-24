.ORIG x3000

        LD R0,A        ; Loader A ind i R0
        LD R1,B        ; Loader B ind i R1

X       NOT R2,R1      ; R2 = bitwise NOT B
        ADD R2,R2,#1   ; R2 = -B

        ADD R2,R2,R0   ; R2 = A - B
        BRz DONE       ; Hvis R2 = 0 (altså A == B), hopper vi til DONE

        ADD R0,R0,#1   ; Lægger 1 til R0(altså A)
        ADD R1,R1,#-1  ; Trækker 1 fra R1(altså B)
        BRnzp X       ; Hopper tilbage til X

DONE    ST R1,C        ; Gemmer midpunktet i C
        TRAP x25       ; Stopper programemt

A       .BLKW 1 ; Resevere 1 plads i hukkomelsen til A
B       .BLKW 1 ; Resevere 1 plads i hukkomelsen til B
C       .BLKW 1 ; Resevere 1 plads i hukkomelsen til C

.END