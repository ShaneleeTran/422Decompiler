*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
CR      EQU $0D
LF      EQU $0A       

    ORG    $1000
    
START:                  ; first instruction of program

* Put program code here
        LEA     WELCOME_MSG,A1  ; welcome message
        MOVE.B  #14,D0
        TRAP    #15
        MOVE.B  #0,CUR_LINE
        
USR_IN_STRT
        LEA     USR_STRT_MSG,A1  ; user start address message
        MOVE.B  #14,D0
        TRAP    #15
        
        LEA     STRT_INPUT,A1
    
        MOVE.B  #2,D0           ;read user input as string
        TRAP    #15
              
        JSR     CHECK_INPUT_LEN   ;checks the length of user input
        
        CMP.B   #1,D4
        BEQ     PASS_LEN_TEST        
        ;else      
        LEA     BAD_INPUT_MSG,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     USR_IN_STRT
        
PASS_LEN_TEST        
        JSR     ASCII_TO_HEX
        MOVEA.L D3,A5
        
        JSR     CHECK_INPUT_ODD
        CMP.B   #1,D4
        BEQ     PASS_ODD_TEST
        ;else
        BRA     USR_IN_STRT
        
PASS_ODD_TEST
        JSR     CHECK_INPUT_BOUNDS
        CMP.B   #0,D4
        BEQ     USR_IN_STRT
        MOVE.L  D3,D7
        MOVEA.L D3,A5
        
USR_IN_END
        LEA     USR_END_MSG,A1
        MOVE.B  #14,D0
        TRAP    #15
        
        LEA     END_INPUT,A1
        
        MOVEQ   #2,D0
        TRAP    #15
        CLR.L   D3
        
        JSR     CHECK_INPUT_LEN
        
        CMP.B   #1,D4
        BEQ     PASS_LEN_TEST2
        ;else
        LEA     BAD_INPUT_MSG,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     USR_IN_END
        
PASS_LEN_TEST2
        JSR     ASCII_TO_HEX
        MOVEA.L D3,A6
        
        JSR     CHECK_INPUT_ODD
        CMP.B   #1,D4
        BEQ     PASS_ODD_TEST2
        ;else
        
        BRA     USR_IN_END
        
PASS_ODD_TEST2
        JSR     CHECK_INPUT_BOUNDS
        CMP.B   #0,D4
        BEQ     USR_IN_END
        ;else
        MOVEA.L D3,A6
        
        ADD     #2,A6
        LEA     WAIT_MSG,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     CONT_INPUT
        
********************************************************************************
CHECK_INPUT_LEN
        CLR.L   D4
        CMPI.B  #$0,D1   ;if length of Hex is 0
        BEQ     BAD_INPUT
        ;else        
        CMPI.B  #$8,D1  ;if length of Hex is greater than 8
        BGT     BAD_INPUT
        ;else
        MOVE.B  #$1,D4
        RTS

********************************************************************************
BAD_INPUT
        MOVEQ   #$0,D4
        RTS
        
********************************************************************************        
ASCII_TO_HEX
        CMPI.B  #$0,D1
        BEQ     ACII_TO_HEX_FINISHED
        MOVE.B  (A1)+,D2    ;move right one character
        CMPI.B  #$39,D2
        BLE     NUM         ;if the character is a number less than 9      
        ;else
LETTER
        SUBI.B  #$37,D2
        BRA     RESIZE

********************************************************************************                
NUM
        SUBI.B  #$30,D2
        BRA     RESIZE

********************************************************************************
RESIZE
        SUBI.B  #$1,D1
        ADD.B   D2,D3
        CMPI.B  #$0,D1
        BEQ     ASCII_TO_HEX
        ;else        
        ROL.L   #4,D3   ; rotate left 4 bits to the next char
        BRA     ASCII_TO_HEX
        
*******************************************************************************
ACII_TO_HEX_FINISHED
        RTS

*******************************************************************************
CHECK_INPUT_ODD
        CLR.L   D4
        CLR.L   D2
        MOVE.W  D3,D2
        MOVE.L  #$00000002,D1
        DIVU    D1,D2
        SWAP    D2
        CMP.B   #1,D2
        BEQ     BAD_INPUT_ODD
        ;else
        MOVE.B  #$1,D4
        RTS
        
******************************************************************************
BAD_INPUT_ODD
        LEA     BAD_INPUT_ODD_MSG,A1
        MOVE.B  #14,D0
        TRAP    #15
        MOVEQ   #$0,D4
        CLR.L   D3
        RTS

*****************************************************************************        
CHECK_INPUT_BOUNDS
        CLR.L   D4
        MOVE.L  #LOW_ADDR,D1
        CMP.L   D1,D3
        BLT     BAD_INPUT_LOW
        ;else
        MOVE.L  #HIGH_ADDR,D1
        CMP.L   D1,D3
        BGT     BAD_INPUT_HIGH
        ;else
        MOVEQ   #$1,D4
        RTS
        
*****************************************************************************
BAD_INPUT_LOW
        LEA     BAD_INPUT_LOW_MSG,A1
        MOVE.B  #14,D0
        TRAP    #15
        MOVE.B  #$0,D4
        CLR.L   D3
        RTS
        
*****************************************************************************
BAD_INPUT_HIGH
        LEA     BAD_INPUT_HIGH_MSG,A1
        MOVE.B  #14,D0
        TRAP    #15
        MOVE.B  #$0,D4
        CLR.L   D3
        RTS
        
*****************************************************************************
CONT_INPUT
        MOVE.B  #12,D0
        MOVE.B  #0,D1
        TRAP    #15
        
        MOVE.B  #5,D0        
        TRAP    #15
        
        BRA     MAIN_LOOP

****************************************************************************
MAIN_LOOP     
        MOVE.W   (A5)+, D6
        LEA     GOODDATA, A3
        LEA     BADDATA, A4
        JSR     ADDRPRNT
        JSR     BAD
        JSR     DSMBLE
        CMP.B   $FF,D7
        BEQ     BAD_PRINT
        MOVE.B  #$00, (A3)+
        LEA     GOODDATA, A1
        MOVEQ   #13,D0
        TRAP    #15
END_LOOP
        CMP.W   A5,A6
        BEQ     END
        CMP.W   A6,A5
        BGT     END
        ADD.B   #1, CUR_LINE
        CMP.B   #29, CUR_LINE
        BRA     MAIN_LOOP
****************************************************************************

BAD
        MOVE.B	#'B',(A4)+			Insert B into the output
        MOVE.B	#'A',(A4)+			Insert A into the output
        MOVE.B	#'D',(A4)+			Insert D into the output
        MOVE.B	#' ',(A4)+			Insert a space into the output
        MOVE.B	#'D',(A4)+			Insert D into output
        MOVE.B	#'A',(A4)+			Insert A into output
        MOVE.B	#'T',(A4)+			Insert T into output
        MOVE.B	#'A',(A4)+			Insert A into output
        MOVE.B	#' ',(A4)+			Insert a space into output
        MOVE.B #'$',(A4)+           Insert a $ into output
        
*BAD_GET
        MOVEQ   #4,D0
        MOVE.W  D6,D4
        
ADDRPRNT
        MOVEQ   #8, D0
        MOVE.L  A5, D4
        SUB.B   #2, D4

GET_MSB
        ROL.L   #4,D4
        MOVE.L  D4,D5
        ANDI.L  #$0000000F, D5
        
ASCII_CHECK
        CMPI.B #$09,D5
        BLE     CHAR_TO_NUM
        ;else
CHAR_TO_ALPHABET        
        ADDI.B  #$37,D5
        BRA     MOVE_TO_GOOD_DATA
        
CHAR_TO_NUM
        ADDI.B  #$30,D5
        BRA     MOVE_TO_GOOD_DATA
        
MOVE_TO_GOOD_DATA
        SUBI.B  #1,D0
        MOVE.B  D5,(A3)+
        MOVE.B  D5,(A4)+
        CMPI.B  #0,D0
        BGT     GET_MSB
        MOVE.B  #$20,(A3)+
        MOVE.B  #$20,(A3)+
        MOVE.B  #$20,(A4)+
        MOVE.B  #$20,(A4)+
        RTS
        
***************************************************************************
BAD_PRINT
        MOVE.B  #$00,(A4)+
        LEA     BADDATA,A1
        MOVEQ   #13,D0
        TRAP    #15
        CLR.L   D7
        BRA     END_LOOP

***************************************************************************
DSMBLE  
        CLR.B   D1
        MOVE.W  D6,D5
        LSR.W   #8, D5
        LSR.W   #4, D5
        MULU    #8, D5
        LEA     FIRSTJMP, A0
        JSR     0(A0,D5)
        RTS

****************************************************************************
FIRSTJMP
        JSR     FIRST0001
        RTS

****************************************************************************        
FIRST0001
        MOVE.B  #'M',(A3)+                  move M into the output
        MOVE.B  #'O',(A3)+                  move O into the output
        MOVE.B  #'V',(A3)+                  move V into the output
        MOVE.B  #'E',(A3)+                  move E into the output
        MOVE.B  #'.',(A3)+                  move . into the output
        MOVE.B  #'B',(A3)+                  move B into the output
        MOVE.B  #' ',(A3)+                  move a space into the output
        MOVE.B  #' ',(A3)+                  move a space into the output
    
        RTS                                 Return the instruction
        
*****************************************************************************
FIRST0010
        MOVE.B  #'M',(A3)+                  move M into the output
        MOVE.B  #'O',(A3)+                  move O into the output
        MOVE.B  #'V',(A3)+                  move V into the output
        MOVE.B  #'E',(A3)+                  move E into the output
        MOVE.B  #'.',(A3)+                  move . into the output
        MOVE.B  #'L',(A3)+                  move L into the output
        MOVE.B  #' ',(A3)+                  move a space into the output
        MOVE.B  #' ',(A3)+                  move a space into the output
        MOVEQ   #1,D1
        
        RTS                                 Return the instruction

****************************************************************************
FIRST0011
        MOVE.B  #'M',(A3)+                  move M into the output
        MOVE.B  #'O',(A3)+                  move O into the output
        MOVE.B  #'V',(A3)+                  move V into the output
        MOVE.B  #'E',(A3)+                  move E into the output
        MOVE.B  #'.',(A3)+                  move . into the output
        MOVE.B  #'W',(A3)+                  move W into the output
        MOVE.B  #' ',(A3)+                  move a space into the output
        MOVE.B  #' ',(A3)+                  move a space into the output
        
        RTS                                 Return the instruction

***************************************************************************
FIRST0100
    MOVE.W  D6,D5
    LSR.W   #$8,D5
    ANDI.W  #$000F,D5
    MULU    8,D5
    *LEA     
    JSR     00(A0,D5)
    RTS
    
**************************************************************************    
FIRST0101
    MOVE.B  #'S',(A3)+  ;move S into the output
    MOVE.B  #'U',(A3)+  ;move U into the output
    MOVE.B  #'B',(A3)+  ;move B into the output
    MOVE.B  #'Q',(A3)+  ;move Q into the output
    MOVE.B  #'.',(A3)+  ;move . into the output
    JSR     GETLENGTH   ;get length of add
    CMP.B   #%00,D3
    BEQ     SUBQBYTE
    ;else
    CMP.B   #$01,D3
    BEQ     SUBQWORD
    ;else
    CMP.B   #$02,D3
    BEQ     SUBQLONG
    ;else
    MOVE.B  $11,D7
    RTS
    
SUBQBYTE
    MOVE.B  #'B',(A3)+
    BRA     SUBQDONE
    
SUBQWORD
    MOVE.B  #'W',(A3)+
    BRA     SUBQDONE
    
SUBQLONG
    MOVE.B  #'L',(A3)+
    BRA     SUBQDONE
    
SUBQDONE
    MOVE.B  #' ',(A3)+
    MOVE.B  #'#',(A3)+
    MOVE.W  D6,D3
    LSL.W   #4,D3
    LSR.W   #8,D3
    LSR.W   #5,D3
    LSR.W   #6,D3
    *LEA     REGISTER,A0
    JSR     00(A0,D3)
    MOVE.B  #' ',(A3)+
    *JSR    EACODE
    RTS

**************************************************************************
GETLENGTH
    MOVE.B  D6,D3
    LSR.B   #6,D3
    RTS
    
*************************************************************************    
  
END                
    SIMHALT             ; halt simulator
               

* Put variables and constants here
CUR_LINE    DS.B    1
STRT_INPUT  DS.B    80
END_INPUT   DS.B    80
WELCOME_MSG DC.B    'Shanelee Tran and Tyler Do Disassembler',CR,LF,0
USR_STRT_MSG    DC.B    CR,LF,'Enter starting address: ',0
USR_END_MSG    DC.B    CR,LF,'Enter ending address: ',0
BAD_INPUT_MSG   DC.B    CR,LF,'Invalid address',0
BAD_INPUT_ODD_MSG   DC.B    CR,LF,'Invalid address, no odd addresses allowed',0
BAD_INPUT_LOW_MSG   DC.B    CR,LF,'Invalid address, too low',0
BAD_INPUT_HIGH_MSG  DC.B    CR,LF,'Invalid address, too high',0
WAIT_MSG    DC.B    CR,LF,'Press any key to continue',0
TEST_MSG    DC.B    CR,LF,'you made it',0
BADDATA DC.L 1
GOODDATA DC.L 1

LOW_ADDR    EQU     $00007000
HIGH_ADDR   EQU     $00FFFFFE
    END    START        ; last line of source















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
