; finished .EQU $3000
; res_hi   .EQU $3002
; res_lo   .EQU $3004
         .ORG $0000
         BRA $0200

         .ORG $0200
result   .EQU $0300
op_A     .EQU $0310
op_B     .EQU $0312

init LW r1, r0, op_A
     LW r2, r0, op_B
     ;.DW 0110 0000 1100 1010
     .DW $60CA
     SW r0, r3, result
    ; LI r3, $8000
;multiply
 ;    SW r0, r3, start
;wait LW r4, r0, finished
 ;    BRN end
;done
;     BRA wait
;end  LW r6, r0, res_hi
 ;    LW r7, r0, res_lo
