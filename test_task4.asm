    .ORG $0000
    LI R4, $2
    LI R7, $5
    LI R5, $3
    ;.DW 0110 0000 0111 1101
    .DW $607D ; multiply R5 and R7 and store in R1
    ;.DW 0110 0001 1010 0111
    .DW $61A7 ; multiply R4 and R7 and store in R6
    LI R2, $2
    ; .DW 0110 0010 1001 0000
    ; .DW $000A
    .DW $6290 ; multiples R2 by 10 and stores in R2
    .DW $000A ; this is immediate
    ADDI R2, R2, $5
    ; .DW 0110 0010 1101 0000
    ; .DW $0004
    .DW $62D0 ; multiples R2 by 4 and stores in R3
    .DW $0004 ; immediate = 4
    STOP
