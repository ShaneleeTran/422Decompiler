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
        LEA     FIRSTJMP,A0
        JSR     0(A0,D5)
        RTS
        
****************************************************************************
FIRSTJMP
        JSR     OPCODE0000  *ADDI
        RTS
        JSR     OPCODE0001  *MOVE.B
        RTS
        JSR     OPCODE0010  *MOVE.L
        RTS
        JSR     OPCODE0011  *MOVE.W
        RTS
        JSR     OPCODE0100  *JSR LEA MOVEM RTS
        RTS
        *JSR     OPCODE0101 *not required SUBQ
        *RTS
        JSR     OPCODE0110 *BCC, BLT, BGE
        RTS
        JSR     OPCODE0111  *MOVEQ
        RTS
        JSR     OPCODE1000  *DIVU
        RTS
        JSR     OPCODE1001  *SUB
        RTS
        JSR     OPCODE1010  *bad
        RTS
        JSR     OPCODE1011  *not required CMP
        RTS
        JSR     OPCODE1100  *AND MULS
        RTS
        JSR     OPCODE1101  *ADD ADDA
        RTS
        JSR     OPCODE1110  *ASR ASL ROL
        RTS
        JSR     OPCODE1111  *bad
        RTS

****************************************************************************
OPCODE0000
        MOVE.W  D6,D5
        LSR.W   #$8,D5
        ANDI.W  #$000F,D5
        MULU    #$8,D5
        LEA     SECONDJMP,A0
        JSR     0(A0,D5)
        RTS

****************************************************************************        
OPCODE0001
        MOVE.B  #'M',(A3)+  ;move M into the output
        MOVE.B  #'O',(A3)+  ;move O into the output
        MOVE.B  #'V',(A3)+  ;move V into the output
        MOVE.B  #'E',(A3)+  ;move E into the output
        MOVE.B  #'.',(A3)+  ;move . into the output
        MOVE.B  #'B',(A3)+  ;move B into the output
        MOVE.B  #' ',(A3)+  ;move a space into the output
        MOVE.B  #' ',(A3)+  ;move a space into the output
    
        RTS
        
*****************************************************************************
OPCODE0010
        MOVE.B  #'M',(A3)+  ;move M into the output
        MOVE.B  #'O',(A3)+  ;move O into the output
        MOVE.B  #'V',(A3)+  ;move V into the output
        MOVE.B  #'E',(A3)+  ;move E into the output
        MOVE.B  #'.',(A3)+  ;move . into the output
        MOVE.B  #'L',(A3)+  ;move L into the output
        MOVE.B  #' ',(A3)+  ;move a space into the output
        MOVE.B  #' ',(A3)+  ;move a space into the output
        MOVEQ   #1,D1
        
        RTS

****************************************************************************
OPCODE0011
        MOVE.B  #'M',(A3)+  ;move M into the output
        MOVE.B  #'O',(A3)+  ;move O into the output
        MOVE.B  #'V',(A3)+  ;move V into the output
        MOVE.B  #'E',(A3)+  ;move E into the output
        MOVE.B  #'.',(A3)+  ;move . into the output
        MOVE.B  #'W',(A3)+  ;move W into the output
        MOVE.B  #' ',(A3)+  ;move a space into the output
        MOVE.B  #' ',(A3)+  ;move a space into the output
        
        RTS

***************************************************************************
OPCODE0100
        MOVE.W  D6,D5
        LSR.W   #$8,D5
        ANDI.W  #$000F,D5
        MULU    8,D5
        LEA     THIRDJMP,A0
        JSR     00(A0,D5)
        RTS
        
**************************************************************************
OPCODE0110
        MOVE.B  D6,D5
        LSL.W   #4,D5
        LSR.W   #8,D5
        LSR.W   #4,D5
        CMP.B   #%1110,D5
        BEQ     BGT_OPCODE
        ;else
        CMP.B   #%1111,D5
        BEQ     BLE_OPCODE
        ;else
        CMP.B   #%1001,D5
        BEQ     BVS_OPCODE
         ;else
        MOVE.B  $11,D7
        RTS 
    
BGT_OPCODE
        MOVE.B  #'B',(A3)+
        MOVE.B  #'G',(A3)+
        MOVE.B  #'T',(A3)+
        MOVE.B  #'#',(A3)+
        JSR     BCC_PRINT
        RTS
    
BLE_OPCODE
        MOVE.B  #'B',(A3)+
        MOVE.B  #'L',(A3)+
        MOVE.B  #'E',(A3)+
        MOVE.B  #' ',(A3)+
        JSR     BCC_PRINT
        RTS
    
BVS_OPCODE
        MOVE.B  #'B',(A3)+
        MOVE.B  #'V',(A3)+
        MOVE.B  #'S',(A3)+
        MOVE.B  #' ',(A3)+
        
**********************************************************************
BCC_PRINT
        MOVE.W  A5,D5
        SUB.B   #2,D5
        MOVE.B  (A5)+,D4
        ADD.W   #2,D4
        ADD.W   D4,D5
        MOVE.B  #'$',(A3)+
        MOVE.W  D5,D4
        MOVE.W  #4,D0
        
BCC_START
        ROL.W   #4,D4
        MOVE.L  D4,D5
        ANDI.L  #$0000000F,D5
        
BCC_NUM_CHECK
        CMPI.B  #$09,D5
        BLE     BCC_TO_NUM
        ;else
BCC_TO_ALPHABET
        ADDI.B  #$37,D5
        BRA     BCC_OUTPUT
        
BCC_TO_NUM
        ADDI.B  #$30,D5
        BRA     BCC_OUTPUT

BCC_OUTPUT
        SUBI.B  #1,D0
        MOVE.B  D5,(A3)+
        CMPI.B  #0,D0
        BGT     BCC_START
        RTS

**************************************************************************
GET_LENGTH
        MOVE.B  D6,D3
        LSR.B   #6,D3
        RTS

***********************************************************************
OPCODE0111
        MOVE.B  #'M',(A3)+  ;move M into the output
        MOVE.B  #'O',(A3)+  ;move O into the output
        MOVE.B  #'V',(A3)+  ;move V into the output
        MOVE.B  #'E',(A3)+  ;move E into the output
        MOVE.B  #'.',(A3)+  ;move . into the output
        MOVE.B  #'Q',(A3)+  ;move Q into the output
        MOVE.B  #' ',(A3)+  ;a space into the output
        MOVE.B  #'#',(A3)+
        MOVE.B  #'$',(A3)+
    
        MOVE.W  D6,D4
        MOVEQ   #2,D0
    
GET_MSB2
        ROL.W   #8,D4
        ROL.W   #4,D4
        MOVE.L  D4,D5
        ANDI.L  #$0000000F, D5
        
ASCII_CHECK2
        CMPI.B  #$09,D5
        BLE     CHAR_TO_NUM
        ;else
CHAR_TO_ALPHABET2      
        ADDI.B  #$37,D5
        BRA     MOVE_TO_GOOD_DATA
        
CHAR_TO_NUM2
        ADDI.B  #$30,D5
        BRA     MOVE_TO_GOOD_DATA
        
MOVE_TO_GOOD_DATA2
        SUBI.B  #1,D0
        MOVE.B  D5,(A3)+
        ROL.W   #8,D4
        CMPI.B  #0,D0
        BGT     GET_MSB2
        ;else
        MOVE.W  D6,D5
        ANDI.W  #$0E00,D5
        ROR.W   #5,D5
        ROR.W   #4,D5
        MULU    #6,D5
        MOVE.B  #',',(A3)+
        MOVE.B  #'D',(A3)+
        LEA     REG_NUM,A0
        JSR     00(A0,D5)
        RTS

********************************************************************
OPCODE1000
        MOVE.B  #'D',(A3)+  ;move D into the output
        MOVE.B  #'I',(A3)+  ;move I into the output
        MOVE.B  #'V',(A3)+  ;move V into the output
        MOVE.B  #'U',(A3)+  ;move U into the output
        MOVE.B  #' ',(A3)+  ;move a space into the output
        JSR     EA_GET
        MOVE.B  #',',(A3)+  ;move a comma into the output
        MOVE.B  #'D',(A3)+	;move a D into the output
        MOVE.W  D6,D3
        LSL.W   #4,D3
        LSR.W   #8,D3
        LSR.W   #5,D3
        MULU    #6,D3
        LEA     REG_NUM,A0
        JSR     00(A0,D3)
        RTS
        
*********************************************************************
OPCODE1001
        MOVE.B  #'S',(A3)+
        MOVE.B  #'U',(A3)+
        MOVE.B  #'B',(A3)+
        MOVE.B  #'.',(A3)+
        
        JSR     GET_LENGTH
        CMP.B   #%00,D3
        BEQ     SUB_BYTE
        ;else
        CMP.B   #$01,D3
        BEQ     SUB_WORD
        ;else
        CMP.B   #$02,D3
        BEQ     SUB_LONG
        ;else
        MOVE.B  $11,D7
        RTS
        
SUB_BYTE
        MOVE.B  #'B',(A3)+
        BRA     SUB_DONE   
        
SUB_WORD
        MOVE.B  #'W',(A3)+
        BRA     SUB_DONE
        
SUB_LONG
        MOVE.B  #'L',(A3)+
        BRA     SUB_DONE
        
SUB_DONE
        MOVE.B  #' ',(A3)+
        MOVE.W  D6,D5
        LSL.W   #7,D5
        LSR.W   #8,D5
        LSR.W   #7,D5
        *CMP.B   #00,D5 ;ea stuff
        *BEQ     DST_DN
        *CMP.B   #$01,D5
        *BEQ     EAISDEST
        MOVE.B  $11,D7
        RTS
        
****************************************************************
DST_DN
        *1221*

****************************************************************
OPCODE1010
        MOVE.B  $11,D7
        RTS

****************************************************************
OPCODE1011
        MOVE.W  D6, D5
        LSL.W   #7, D5
        LSR.W   #8, D5
        LSR.W   #5, D5
        MULU    #8, D5
        *LEA     OPTABLECONT,A0
        JSR     0(A0,D5)
        RTS
        
****************************************************************              
OPCODE1100
        MOVE.W  D6,D5
        LSL.W   #7,D5
        LSR.W   #8,D5
        LSR.W   #5,D5
        CMP.B   #$07, D5
        *BEQ    MULSINST
        MOVE.B  #'A',(A3)+
        MOVE.B  #'N',(A3)+
        MOVE.B  #'D',(A3)+
        MOVE.B  #'.',(A3)+
        JSR     GET_LENGTH
        CMP.B   #%00, D3
        BEQ     ANDBYTE
        CMP.B   #$01, D3
        BEQ     ANDWORD
        CMP.B   #$02, D3
        BEQ     ANDLONG
        MOVE.B  $11, D7
        RTS
ANDBYTE
        MOVE.B  #'B',(A3)+
        BRA     ANDEND
ANDWORD
        MOVE.B  #'W',(A3)+
        BRA     ANDEND
ANDLONG
        MOVE.B  #'L',(A3)+
        MOVEQ   #1, D1
        BRA     ANDEND
ANDEND
        MOVE.B  #' ',(A3)+
        MOVE.W  D6,D5
        LSL.W   #7,D5
        LSR.W   #8,D5
        LSR.W   #7,D5
        CMP.B   #00,D5
        *BEQ    DNIDEST
        CMP.B   #$01,D5
        *BEQ    EAISDEST
        MOVE.B  $11, D7
        RTS
MULS
        MOVE.B  #'M',(A3)+
        MOVE.B  #'U',(A3)+
        MOVE.B  #'L',(A3)+
        MOVE.B  #'S',(A3)+
        MOVE.B  #'.',(A3)+
        MOVE.B  #'W',(A3)+
        MOVE.B  #' ',(A3)+
        JSR     EA_GET
        MOVE.W  D6,D5
        LSL.W   #4,D5
        LSR.W   #8,D5
        LSR.W   #5,D5
        MULU    #6,D5
        MOVE.B  #',',(A3)+
        MOVE.B  #'D',(A3)+
        LEA     REG_NUM,A0
        JSR     00(A0,D5)
        RTS
        
****************************************************************        
OPCODE1110
        MOVE.W  D6,D5
        LSL.W   #8,D5
        LSR.W   #6,D5
        CMP.B   #03,D5
        *BEQ MEMORYCHECKS
DECODESHIFT
        MOVE.W  D6,D5
        LSL.W   #8,D5
        LSL.W   #3,D5
        LSR.W   #8,D5
        LSR.W   #6,D5
        CMP.B   #$00, D5
        BEQ     DISASR
        CMP.B   #$01, D5
        BEQ     DISLSL
        CMP.B   #$03, D5
        *BEQ     DISROL
        MOVE.B  $11, D7
        RTS
DISASR
        MOVE.W  D6,D5
        LSL.W   #7,D5
        LSR.W   #8,D5
        LSR.W   #7,D5
        CMP.B   #$00, D5
        BEQ     DISASRCONT
        MOVE.B  #11,D7
        RTS
DISASRCONT
        MOVE.B  #'A',(A3)+ 
        MOVE.B  #'S',(A3)+ 
        MOVE.B  #'R',(A3)+
        MOVE.B  #'.',(A3)+
        JSR     GET_LENGTH
        CMP.B   #%00,D3
        BEQ     SHIFTBYTE
        CMP.B   #$01,D4
        BEQ     SHIFTWORD
        CMP.B   #$02,D4
        BEQ     SHIFTLONG
        MOVE.B  $11,D7
        JSR     EA_GET
        RTS
DISLSL
        MOVE.W  D6,D5
        LSL.W   #7,D5
        LSR.W   #8,D5
        LSR.W   #7,D5
        BEQ     DISLSLCONT
        MOVE.B  $11,D7
        JSR     EA_GET
        RTS
DISLSLCONT
        MOVE.B  #'L',(A3)+ 
        MOVE.B  #'S',(A3)+ 
        MOVE.B  #'L',(A3)+
        MOVE.B  #'.',(A3)+
        JSR     GET_LENGTH
        CMP.B   #%00, D3
        BEQ     SHIFTBYTE
        CMP.B   #$01, D4
        BEQ     SHIFTWORD
        CMP.B   #$02, D4
        BEQ     SHIFTLONG
        MOVE.B  $11, D7
        JSR     EA_GET
        RTS   
SHIFTBYTE
        MOVE.B  #'B',(A3)+
        *BRA    GETDATANUMBER
SHIFTWORD
        MOVE.B  #'W',(A3)+
        *BRA    GETDATANUMBER
SHIFTLONG
        MOVE.B  #'L',(A3)+
        *BRA    GETDATANUMBER
DISROLR
        MOVE.W  D6,D5
        LSL.W   #7,D5
        LSR.W   #8,D5
        LSR.W   #7,D5
        CMP.B   #$01,D5
        BEQ     DISROLRLEFT
        CMP.B   #$00,D5
        BEQ     DISRORRIGHT
        MOVE.B  $11,D7
        RTS
DISROLRLEFT
        MOVE.B  #'R',(A3)+
        MOVE.B  #'O',(A3)+
        MOVE.B  #'L',(A3)+
        MOVE.B  #'.',(A3)+
        JSR     GET_LENGTH
        CMP.B   #%00,D3
        BEQ     SHIFTBYTE
        CMP.B   #%01,D3
        BEQ     SHIFTWORD
        CMP.B   #$02,D3
        BEQ     SHIFTLONG
        MOVE.B  $11,D7
        JSR     EA_GET
        RTS
DISRORRIGHT
        MOVE.B  #'R',(A3)+
        MOVE.B  #'O',(A3)+
        MOVE.B  #'R',(A3)+
        MOVE.B  #'.',(A3)+
        JSR     GET_LENGTH
        CMP.B   #%00,D3
        BEQ     SHIFTBYTE
        CMP.B   #%01,D3
        BEQ     SHIFTWORD
        CMP.B   #$02,D3
        BEQ     SHIFTLONG
        MOVE.B  $11,D7
        JSR     EA_GET
        RTS
GETDATANUMBER
        MOVE.W  D6,D3
        LSL.W   #4,D3
        LSR.W   #8,D3
        LSR.W   #5,D3
        
************************************************   
OPCODE1101 *ADD AND ADDA*
        MOVE.B  #'A',(A3)+
        MOVE.B  #'D',(A3)+
        MOVE.B  #'D',(A3)+
        BRA     ADDA
        
ADD
        MOVE.B  #'.',(A3)+
        JSR     GET_LENGTH
        CMP.B   #%00, D3
        BEQ     ADDBYTE
        CMP.B   #$01, D3
        BEQ     ADDWORD
        CMP.B   #$02, D3
        BEQ     ADDLONG
        MOVE.B  $11, D7
        RTS
        
ADDBYTE
        MOVE.B  #'B',(A3)+
        RTS     DONEADD
        
ADDWORD
        MOVE.B  #'W',(A3)+
        RTS     DONEADD
        
ADDLONG
        MOVE.B  #'L',(A3)+
        RTS     DONEADD
        
ADDA  
        MOVE.W  D6,D5
        LSL.W   #7,D5
        LSR.W   #8,D5
        LSR.W   #5,D5
        CMP.B   #$03, D5
        BEQ     ADDAW
        CMP.B   #$07,D5
        BEQ     ADDALW
        BRA     ADD
ADDAW
        MOVE.B  #'A',(A3)+
        MOVE.B  #'.',(A3)+
        MOVE.B  #'W',(A3)+
        BRA     ADDREG
ADDALW
        MOVE.B  #'A',(A3)+
        MOVE.B  #'.',(A3)+
        MOVE.B  #'L',(A3)+
        MOVEQ   #1,D1
        BRA     ADDREG
ADDREG
        MOVE.B  #' ',(A3)+
        JSR     EA_GET
        MOVE.B  #',',(A3)+
        MOVE.B  #'A',(A3)+
        MOVE.W  D6,D5
        LSL.W   #4,D5
        LSR.W   #8,D5
        LSR.W   #5,D5
        MULU    #6,D5
        LEA     REG_NUM,A0
        JSR     00(A0,D5)
        RTS
        
DONEADD
        MOVE.B  #' ',(A3)+
        MOVE.W  D6,D5
        LSL.W   #7,D5
        LSR.W   #8,D5
        LSR.W   #7,D5
        BEQ     CHECKDN
        CMP.B   #$01,D5
        BEQ     CHECKEA
        MOVE.B  $11,D7
        RTS
    
CHECKDN
        JSR     EA_GET
        MOVE.W  D6,D5
        LSL.W   #4,D5
        LSR.W   #8,D5
        LSR.W   #5,D5
        MULU    #6,D5
        MOVE.B  #',',(A3)+
        MOVE.B  #'D',(A3)+
        LEA     REG_NUM,A0
        JSR     00(A0,D5)
        RTS
        
CHECKEA
        MOVE.W  D6,D5
        LSL.W   #4,D5
        LSR.W   #8,D5
        LSR.W   #5,D5
        MULU    #6,D5
        MOVE.B  #'D',(A3)+
        LEA     REG_NUM,A0
        JSR     00(A0,D5)
        MOVE.B  #',',(A3)+
        JSR     EA_GET
        RTS
           
***********************************
OPCODE1111
        MOVE.B  $11,D7
        RTS    

******************************************************************
SECONDJMP
        JSR     OPCODE20110     ;ADDI
        RTS
        JSR     OPCODE20000     ;bad
        RTS
        JSR     OPCODE20100     ;bad
        RTS
        JSR     OPCODE21110     ;bad
        RTS
    
******************************************************************
OPCODE20110
        MOVE.B  #'A',(A3)+  ;move A into the output
        MOVE.B  #'D',(A3)+  ;move D into the output
        MOVE.B  #'D',(A3)+  ;move Insert D into the output
        MOVE.B  #'I',(A3)+  ;move I into the output
        MOVE.B  #'.',(A3)+  ;move . into the output
    
        JSR     GET_LENGTH    
        CMP.B   #%00,D3
        BEQ     ADDI_BYTE
        ;else
        CMP.B   #$01,D3
        BEQ     ADDI_WORD
        ;else
        CMP.B   #$02,D3
        BEQ     ADDI_LONG
        ;else
        MOVE.B  $11,D7
        RTS
    
ADDI_BYTE
        MOVE.B  #'B',(A3)+
        MOVE.B	#' ',(A3)+
        JSR		IMMEDIATE
        MOVE.B	#',',(A3)+
        BRA     ADDI_DONE
        
ADDI_WORD
        MOVE.B  #'W',(A3)+
        MOVE.B	#' ',(A3)+
 	    JSR		IMMEDIATE
 	    MOVE.B	#',',(A3)+
        BRA     ADDI_DONE

ADDI_LONG
        MOVE.B  #'L',(A3)+
        MOVE.B	#' ',(A3)+
        MOVEQ   #1,D1
        JSR     IMMEDIATE
        MOVE.B	#',',(A3)+
        BRA     ADDI_DONE
        
ADDI_DONE
        JSR     EA_GET
        RTS

**********************************************************
OPCODE20000
OPCODE20100
OPCODE21110
        MOVE.B  $11,D7
        RTS
        
********************************************************** 
IMMEDIATE
        MOVE.B  #'#',(A3)+
        MOVE.B  #'$',(A3)+
        MOVE.B  #' ',(A4)+
        MOVE.B  #'#',(A4)+
        MOVE.B  #'$',(A4)+
        
        CMPI.B  #1,D1
        BEQ     LONG
        ;else
        MOVEQ   #4,D0
        MOVE.W  (A5)+,D4        
WORD_GET_MSB                
        ROL.W   #4,D4
        MOVE.W  D4,D5
        ANDI.L  #$0000000F,D5
        CMPI.B  #$09,D5
        BLE     WORD_TO_NUM
        ;else
        ADDI.B  #$37,D5
        BRA     WORD_TO_ASCII
    
WORD_TO_NUM
        ADDI.B  #$30,D5
        BRA     WORD_TO_ASCII

WORD_TO_ASCII
        SUBI.B  #1,D0
        MOVE.B  D5,(A3)+
        MOVE.B  D5,(A4)+
        CMPI.B  #0,D0
        BGT     WORD_GET_MSB
        ;else
        RTS
        
LONG
        MOVEQ   #8,D0
        MOVE.L  (A5)+,D4
LONG_GET_MSB              	
        ROL.L   #4,D4
        MOVE.W  D4,D5
        ANDI.L  #$0000000F,D5
        CMPI.B  #$09,D5
        BLE     LONG_TO_NUM
        ;else
        ADDI.B  #$37,D5
        BRA     LONG_TO_ASCII
        
LONG_TO_NUM
        ADDI.B  #$30,D5
        BRA     LONG_TO_ASCII
        
LONG_TO_ASCII
        SUBI.B  #1,D0
        MOVE.B  D5,(A3)+
        MOVE.B  D5,(A4)+
        CMPI.B  #0,D0
        BGT     LONG_GET_MSB
        ;else
        RTS

********************************************************************
THIRDJMP
        JSR     OPCODE30000     ;bad
        RTS
        JSR     OPCODE30001     ;LEA 0
        RTS
        JSR     OPCODE30010     ;not required
        RTS
        JSR     OPCODE30011     ;LEA 1
        RTS
        JSR     OPCODE30100     ;bad
        RTS
        JSR     OPCODE30101     ;LEA 2
        RTS
        JSR     OPCODE30110     ;bad
        RTS
        JSR     OPCODE30111     ;LEA 3
        RTS
        JSR     OPCODE31000     ;MOVEM
        RTS
        JSR     OPCODE31001     ;LEA 3
        RTS
        JSR     OPCODE31010     ;bad
        RTS
        JSR     OPCODE31011     ;LEA 4
        RTS
        JSR     OPCODE31100     ;MOVEM
        RTS
        JSR     OPCODE31101     ;LEA 5
        RTS
        JSR     OPCODE31110     ;JSR
        RTS
        JSR     OPCODE31111     ;LEA 6
        RTS

*bad
OPCODE30000
OPCODE30010
OPCODE30100
OPCODE30110
OPCODE31010
        MOVE.B	$11, D7
        RTS

******************************************************************
OPCODE30001
        JSR     LEA_ADDPRINT
        MOVE.B  #',',(A3)+
        MOVE.B  #'A',(A3)+
        MOVE.B  #'0',(A3)+
        RTS
        
*****************************************************************
OPCODE30011
        JSR     LEA_ADDPRINT
        MOVE.B  #',',(A3)+
        MOVE.B  #'A',(A3)+
        MOVE.B  #'1',(A3)+
        RTS

******************************************************************
OPCODE30101
        JSR     LEA_ADDPRINT
        MOVE.B  #',',(A3)+
        MOVE.B  #'A',(A3)+
        MOVE.B  #'2',(A3)+
        RTS

OPCODE30111
        JSR     LEA_ADDPRINT
        MOVE.B  #',',(A3)+
        MOVE.B  #'A',(A3)+
        MOVE.B  #'3',(A3)+
        RTS
        
OPCODE31000
        MOVE.B  #'M',(A3)+
        MOVE.B  #'O',(A3)+
        MOVE.B  #'V',(A3)+
        MOVE.B  #'E',(A3)+
        MOVE.B  #'M',(A3)+
        MOVE.B  #'.',(A3)+
        JSR     MSB_LENGTH
        CMP.B   #%0, D3
        BEQ     ENDWORDDATA
        CMP.B   #%1, D3
        BEQ     ENDLONGDATA
        MOVE.B  #$11, D7
        RTS

LISTFINDER
        MOVE.B  #' ',(A3)+
        MOVE.W  (A5)+, D5
        MOVE.W  D5,D4
        CLR.B   D1
        CLR.L   D3
        MOVE.B  D6,D3
        ANDI.B  #$38,D3
        CMPI.B  #$20,D3
        BEQ     DECREMENT
REGFINDER
        LSR.B   #1,D5
        BCS     DATACONF
        ADDI.B  #1,D1
        CMPI.B  #8,D1
        BEQ     ADDRESSFINDER
        BRA     REGFINDER
DATACONF
        MOVE.B  #'D',(A3)+
        MOVE.B  D1,D0
        ADDI.B  #$30,D0
        MOVE.B  D0,(A3)+

LISTLOOP
        ADDI.B  #1,D1
        CMPI.B  #8,D1
        BEQ     PRINTLIST
        LSR.B   #1,D5
        BCS     MOREDATA
        ADDI.B  #1,D1
        CMPI.B  #8,D1
        BEQ     PRINTLIST
        BRA     LISTLOOP
PRINTLIST
        MOVE.B  #'/',(A3)+
        BRA     ADREGFINDER
MOREDATA
        MOVE.B  #'-',(A3)+
LISTDATA
        LSR.B   #1,D5
        BCC     LISTLOOPCONT
        CMPI.B  #7,D1
        BEQ     LISTLOOPCONT
        ADDI.B  #1,D1
        BRA     LISTDATA
LISTLOOPCONT
        MOVE.B  #'D',(A3)+
        MOVE.B  D1,D0
        ADDI.B  #$30,D0
        MOVE.B  D0,(A3)+
        MOVE.B  #'/',(A3)+
        MOVEQ   #8,D1
        BRA     ADREGFINDER
ADREGFINDER
        LSL.W   #1,D5
        BCS     REGFOUND
        SUBI.B  #1,D1
        CMPI.B  #0,D1
        BEQ     ENDLISTFINDER
        BRA     ADREGFINDER
REGFOUND
        MOVE.B  #'A',(A3)+
        MOVE.B  D1,D0
        SUBI.B  #1,D0
        ADDI.B  #$30,D0
        MOVE.B  D0,(A3)+
ADDRESSFINDER
        SUBI.B  #1,D1
        CMPI.B  #0,D1
        BEQ     ENDLISTFINDER
        LSL.W   #1,D5
        BCS     MOREADDRESS
        SUBI.B  #1,D1
        CMPI.B  #0,D1
        BEQ     ENDLISTFINDER
        BRA     ADDRESSFINDER
MOREADDRESS
        MOVE.B  #'-',(A3)+
ADDRESSCONT
        LSL.W   #1,D5
        BCC     PRINTADDR
        SUBI.B  #1,D1
        CMPI.B  #0,D1
        BEQ     PRINTADDR
        BRA     ADDRESSCONT
PRINTADDR
        MOVE.B  #'A',(A3)+
        MOVE.B  D1,D0
        SUBI.B  #1,D0
        ADDI.B  #$30,D0
        MOVE.B  D0,(A3)+
        BRA     ENDLISTFINDER
DECREMENT
        LSL.W   #1,D5
        BCS     DECREMENTFOUND
        ADDI.B  #1,D1
        CMPI.B  #8,D1
        BEQ     ADDRESSPREDEC
        BRA     DECREMENT
DECREMENTFOUND
        MOVE.B  #'D',(A3)+
        MOVE.B  D1,D0
        ADDI.B  #$30,D0
        MOVE.B  D0,(A3)+
DECREMENTDATA
        ADDI.B  #1,D1
        CMPI.B  #8,D1
        BEQ     PRINTDECDATA
        LSL.W   #1,D5
        BCS     MOREPREDEC
        ADDI.B  #1,D1
        CMPI.B  #8,D1
        BEQ     PRINTDECDATA
        BRA     DECREMENTDATA
PRINTDECDATA
        MOVE.B  #'/',(A3)+
        BRA     ADDRESSPREDEC
MOREPREDEC
        MOVE.B  #'-',(A3)+
DECREMENTCONT
        LSL.W   #1,D5
        BCC     PRINTDECCONT
        CMPI.B  #7,D1
        BEQ     PRINTDECCONT
        ADDI.B  #1,D1
        BRA     DECREMENTCONT
PRINTDECCONT
        MOVE.B  #'D',(A3)+
        MOVE.B  D1,D0
        ADDI.B  #$30, D0
        MOVE.B  D0,(A3)+
        MOVEQ   #8,D1
        BRA     ADDRESSPREDEC        
ADDRESSPREDEC
        MOVE.B  D4,D5
ADDRESSREG  
        LSR.B   #1,D5
        BCS     REGCHECK
        SUBI.B  #1,D1
        CMPI.B  #0,D1
        BEQ     ENDLISTFINDER
        BRA     ADDRESSREG
REGCHECK
        MOVE.B  #'A',(A3)+
        MOVE.B  D1,D0
        SUBI.B  #1,D0
        ADDI.B  #$30,D0
        MOVE.B  D0,(A3)+
REGPREDEC
        SUBI.B  #1,D1
        CMPI.B  #0,D1
        BEQ     ENDLISTFINDER
        LSR.B   #1,D5
        BCS     REGCHECKREPEAT
        SUBI.B  #1,D1
        CMPI.B  #0,D1
        BEQ     ENDLISTFINDER
        BRA     REGPREDEC
REGCHECKREPEAT
        MOVE.B  #'-',(A3)+
ADDPREDEC    
        LSR.B   #1,D5
        BCC     PRINTADDPREDEC
        SUBI.B  #1,D1
        CMPI.B  #0,D1
        BEQ     PRINTADDPREDEC
        BRA     ADDPREDEC
PRINTADDPREDEC
        MOVE.B  #'A',(A3)+
        MOVE.B  D1,D0
        SUBI.B  #1,D0
        ADDI.B  #$30,D0
        MOVE.B  D0,(A3)+
        BRA     ENDLISTFINDER
ENDLISTFINDER
        CLR.B   D1
        MOVE.B  #',',(A3)+
        JSR     EA_GET
        RTS
ENDWORDDATA
        MOVE.B  #'W',(A3)+
        BRA     LISTFINDER
ENDLONGDATA
        MOVE.B  #'L',(A3)+
        BRA     LISTFINDER

*******************************************
OPCODE31001
        JSR     LEA_ADDPRINT   
        MOVE.B  #',',(A3)+
        MOVE.B  #'A',(A3)+
        MOVE.B  #'4',(A3)+
        RTS

OPCODE31011
        JSR     LEA_ADDPRINT
        MOVE.B  #',',(A3)+
        MOVE.B  #'A',(A3)+
        MOVE.B  #'5',(A3)+
        RTS
OPCODE31100
        MOVE.B  #'M',(A3)+
        MOVE.B  #'O',(A3)+
        MOVE.B  #'V',(A3)+
        MOVE.B  #'E',(A3)+
        MOVE.B  #'M',(A3)+
        MOVE.B  #'.',(A3)+
        JSR     MSB_LENGTH
        CMP.B   #%0, D3
        BEQ     ENDWORDDATA2
        CMP.B   #%1, D3
        BEQ     ENDLONGDATA2
        MOVE.B  #$11, D7
        RTS
MEMREG
        MOVE.B  #' ',(A3)+
        MOVEQ   #1,D7
        CLR.B   D3
        JSR     EA_GET
        MOVE.B  #',',(A3)+
        MOVE.W  (A5)+,D5
        CLR.B   D1
REGFINDER2
        LSR.B   #1,D5
        BCS     DATACONF2
        ADDI.B  #1,D1
        CMPI.B  #8,D1
        BEQ     ADDRESSFINDER2
        BRA     REGFINDER2
DATACONF2
        MOVE.B  #'D',(A3)+
        MOVE.B  D1,D0
        ADDI.B  #$30,D0
        MOVE.B  D0,(A3)+

LISTLOOP2
        ADDI.B  #1,D1
        CMPI.B  #8,D1
        BEQ     PRINTLIST2
        LSR.B   #1,D5
        BCS     MOREDATA2
        ADDI.B  #1,D1
        CMPI.B  #8,D1
        BEQ     PRINTLIST2
        BRA     LISTLOOP2
PRINTLIST2
        MOVE.B  #'/',(A3)+
        BRA     ADREGFINDER2
MOREDATA2
        MOVE.B  #'-',(A3)+
LISTDATA2
        LSR.B   #1,D5
        BCC     LISTLOOPCONT2
        CMPI.B  #7,D1
        BEQ     LISTLOOPCONT2
        ADDI.B  #1,D1
        BRA     LISTDATA2
LISTLOOPCONT2
        MOVE.B  #'D',(A3)+
        MOVE.B  D1,D0
        ADDI.B  #$30,D0
        MOVE.B  D0,(A3)+
        MOVE.B  #'/',(A3)+
        MOVEQ   #8,D1
        BRA     ADREGFINDER2
ADREGFINDER2
        LSL.W   #1,D5
        BCS     REGFOUND2
        SUBI.B  #1,D1
        CMPI.B  #0,D1
        BEQ     ENDLISTFINDER2
        BRA     ADREGFINDER2
REGFOUND2
        MOVE.B  #'A',(A3)+
        MOVE.B  D1,D0
        SUBI.B  #1,D0
        ADDI.B  #$30,D0
        MOVE.B  D0,(A3)+
ADDRESSFINDER2
        SUBI.B  #1,D1
        CMPI.B  #0,D1
        BEQ     ENDLISTFINDER2
        LSL.W   #1,D5
        BCS     MOREADDRESS2
        SUBI.B  #1,D1
        CMPI.B  #0,D1
        BEQ     ENDLISTFINDER2
        BRA     ADDRESSFINDER2
MOREADDRESS2
        MOVE.B  #'-',(A3)+
ADDRESSCONT2
        LSL.W   #1,D5
        BCC     PRINTADDR2
        SUBI.B  #1,D1
        CMPI.B  #0,D1
        BEQ     PRINTADDR2
        BRA     ADDRESSCONT2
PRINTADDR2
        MOVE.B  #'A',(A3)+
        MOVE.B  D1,D0
        SUBI.B  #1,D0
        ADDI.B  #$30,D0
        MOVE.B  D0,(A3)+
        BRA     ENDLISTFINDER2
DECREMENT2
        LSL.W   #1,D5
        BCS     DECREMENTFOUND2
        ADDI.B  #1,D1
        CMPI.B  #8,D1
        BEQ     ADDRESSPREDEC2
        BRA     DECREMENT2
DECREMENTFOUND2
        MOVE.B  #'D',(A3)+
        MOVE.B  D1,D0
        ADDI.B  #$30,D0
        MOVE.B  D0,(A3)+
DECREMENTDATA2
        ADDI.B  #1,D1
        CMPI.B  #8,D1
        BEQ     PRINTDECDATA2
        LSL.W   #1,D5
        BCS     MOREPREDEC2
        ADDI.B  #1,D1
        CMPI.B  #8,D1
        BEQ     PRINTDECDATA2
        BRA     DECREMENTDATA2
PRINTDECDATA2
        MOVE.B  #'/',(A3)+
        BRA     ADDRESSPREDEC2
MOREPREDEC2
        MOVE.B  #'-',(A3)+
DECREMENTCONT2
        LSL.W   #1,D5
        BCC     PRINTDECCONT2
        CMPI.B  #7,D1
        BEQ     PRINTDECCONT2
        ADDI.B  #1,D1
        BRA     DECREMENTCONT2
PRINTDECCONT2
        MOVE.B  #'D',(A3)+
        MOVE.B  D1,D0
        ADDI.B  #$30, D0
        MOVE.B  D0,(A3)+
        MOVEQ   #8,D1
        BRA     ADDRESSPREDEC2       
ADDRESSPREDEC2
        MOVE.B  D4,D5
ADDRESSREG2
        LSR.B   #1,D5
        BCS     REGCHECK2
        SUBI.B  #1,D1
        CMPI.B  #0,D1
        BEQ     ENDLISTFINDER2
        BRA     ADDRESSREG2
REGCHECK2
        MOVE.B  #'A',(A3)+
        MOVE.B  D1,D0
        SUBI.B  #1,D0
        ADDI.B  #$30,D0
        MOVE.B  D0,(A3)+
REGPREDEC2
        SUBI.B  #1,D1
        CMPI.B  #0,D1
        BEQ     ENDLISTFINDER2
        LSR.B   #1,D5
        BCS     REGCHECKREPEAT2
        SUBI.B  #1,D1
        CMPI.B  #0,D1
        BEQ     ENDLISTFINDER2
        BRA     REGPREDEC2
REGCHECKREPEAT2
        MOVE.B  #'-',(A3)+
ADDPREDEC2    
        LSR.B   #1,D5
        BCC     PRINTADDPREDEC2
        SUBI.B  #1,D1
        CMPI.B  #0,D1
        BEQ     PRINTADDPREDEC2
        BRA     ADDPREDEC2
PRINTADDPREDEC2
        MOVE.B  #'A',(A3)+
        MOVE.B  D1,D0
        SUBI.B  #1,D0
        ADDI.B  #$30,D0
        MOVE.B  D0,(A3)+
        BRA     ENDLISTFINDER2
ENDWORDDATA2
        MOVE.B  #'W',(A3)+
        BRA     MEMREG
ENDLONGDATA2
        MOVE.B  #'L',(A3)+
        BRA     MEMREG
ENDLISTFINDER2
        CMPI.B  #1,D3
        BEQ     WORDPLUS
        CMPI.B  #2,D3
        BEQ     LONGPLUS
        BRA     FINISHLIST
WORDPLUS
        ADDA.L  #2,A5
        BRA     FINISHLIST
LONGPLUS
        ADDA.L  #4,A5
        BRA     FINISHLIST
FINISHLIST
        RTS
        
********************************************************
MSB_LENGTH
        MOVE.B  D6,D3
        LSR.B   #6,D3
        RTS
        
*******************************************************    
OPCODE31101
        JSR     LEA_ADDPRINT
        MOVE.B  #',',(A3)+
        MOVE.B  #'A',(A3)+
        MOVE.B  #'6',(A3)+
        RTS

******************************************************
OPCODE31110
        CMP.W   #$4E75, D6
        BEQ     PRINT_RTS 
        MOVE.B  #'J',(A3)+
        MOVE.B  #'S',(A3)+
        MOVE.B  #'R',(A3)+
        MOVE.B  #' ',(A3)+
        JSR     EA_GET
        RTS
        
PRINT_RTS        
        MOVE.B  #'R',(A3)+
        MOVE.B  #'T',(A3)+
        MOVE.B  #'S',(A3)+
        RTS
        
******************************************************
OPCODE31111
        JSR     LEA_ADDPRINT
        MOVE.B  #',',(A3)+
        MOVE.B  #'A',(A3)+
        MOVE.B  #'7',(A3)+
        RTS
       
*******************************************************
LEA_ADDPRINT
        MOVE.B  #'L',(A3)+
        MOVE.B  #'E',(A3)+
        MOVE.B  #'A',(A3)+
        MOVE.B  #' ',(A3)+
        JSR     EA_GET
        RTS
        
******************************************************
REG_NUM
        JMP     REG000
        JMP     REG001
        JMP     REG010
        JMP     REG011
        JMP     REG100
        JMP     REG101
        JMP     REG110
        JMP     REG111

******************************************************
REG000
        MOVE.B  #'0',(A3)+
        RTS
        
REG001
        MOVE.B  #'1',(A3)+
        RTS        

REG010
        MOVE.B  #'2',(A3)+
        RTS
        
REG011
        MOVE.B  #'3',(A3)+
        RTS
        
REG100
        MOVE.B  #'4',(A3)+
        RTS

REG101
        MOVE.B  #'5',(A3)+
        RTS
        
REG110
        MOVE.B  #'6',(A3)+
        RTS
        
REG111
        MOVE.B  #'7',(A3)+
        RTS
        
**********************************************************
EA_GET
        CLR.W   D4
        CLR.W   D5
        MOVE.B  D6,D5
        MOVE.B  D6,D4
        ANDI.B  #$07,D5
        LSR.B   #3,D4
        ANDI.B  #$07,D4
        MULU    #$6,D4
        LEA     EA_TABLE,A0
        JSR     00(A0,D4)
        RTS

**********************************************************
EA_TABLE
        JMP    EA000
        JMP    EA001
        JMP    EA010
        JMP    EA011
        JMP    EA100
        JMP    EA101
        JMP    EA110
        JMP    EA111
        
*********************************************************        
EA000
        MOVE.B #'D',(A3)+
        MULU   #$6,D5
        LEA    REG_NUM,A1
        JSR    00(A1,D5)
        RTS
        
EA001
        MOVE.B #'A',(A3)+
        MULU   #$6,D5
        LEA    REG_NUM,A1
        JSR    00(A1,D5)
        RTS

EA010
        MOVE.B #'(',(A3)+
        MOVE.B #'A',(A3)+
        MULU   #$6,D5
        LEA    REG_NUM,A1
        JSR    00(A1,D5)
        MOVE.B #')',(A3)+
        RTS       

EA011
        MOVE.B #'(',(A3)+
        MOVE.B #'A',(A3)+
        MULU   #$6,D5
        LEA    REG_NUM,A1
        JSR    00(A1,D5)
        MOVE.B #')',(A3)+
        MOVE.B #'+',(A3)+
        RTS

EA100
        MOVE.B	#'-',(A3)+
        MOVE.B	#'(',(A3)+
        MOVE.B	#'A',(A3)+
        MULU	#$6,D5
        LEA		REG_NUM,A1
        JSR    	00(A1,D5)
        MOVE.B 	#')',(A3)+
        RTS
EA101
        MOVE.B  $11, D7
        *BRA    GETWORDFORBADDATA	

EA110
        MOVE.B  $11, D7
        RTS

EA111
        MULU   #$6,D5
        *LEA    ABSOLUTE,A1
        JSR    00(A1,D5)
        RTS

******************************************************* 
ABSOCODE
       JMP     ABSOCODE000
       JMP     ABSOCODE001
       JMP     ABSOCODE010
       JMP     ABSOCODE011
       JMP     ABSOCODE100

ABSOCODE000
       MOVE.B  #'$',(A3)+
       MOVE.B  #' ',(A4)+
       MOVE.B  #'$',(A4)+
       MOVEQ   #4,D0
       CMPI.B  #1,D7
       BEQ     WORDABSO
       BRA     ABSOMOVEW
WORDABSO
        MOVEA.L A5,A2
        ADDA.L  #$2,A2
        MOVE.W  (A2)+,D4
        BRA     ABSOCONVERT
ABSOMOVEW
        MOVE.W  (A5)+,D4
ABSOCONVERT
        ROL.W   #4,D4
        MOVE.W  D4,D5
        ANDI.W  #$000F,D5
ABSOASCI
        CMPI.B  #$09,D5
        BLE     ABSONUM
ABSOLET
        ADDI.B  #37,D5
        BRA     ABSOCONVERT2
ABSONUM
        ADDI.B  #$30,D5
        BRA     ABSOCONVERT2
ABSOCONVERT2
        SUBI.B  #1,D0
        MOVE.B  D5,(A3)+
        MOVE.B  D5,(A4)+
        CMPI.B  #0,D0
        BGT     ABSOCONVERT
        MOVEQ   #1,D3
        RTS
**********************************
ABSOCODE001
       MOVE.B  #'$',(A3)+
       MOVE.B  #' ',(A4)+
       MOVE.B  #'$',(A4)+
       MOVEQ   #8,D0
       CMPI.B  #1,D7
       BEQ     LONGABSO
       BRA     ABSOMOVEL
LONGABSO
        MOVEA.L A5,A2
        ADDA.L  #$2,A2
        MOVE.W  (A2)+,D4
        BRA     ABSOCONVERTL
ABSOMOVEL
        MOVE.L  (A5)+,D4
ABSOCONVERTL
        ROL.W   #4,D4
        MOVE.W  D4,D5
        ANDI.W  #$0000000F,D5  
ABSOASCILONG
        CMPI.B  #$09,D5
        BLE     ABSONUMLONG
ABSOLETLONG
        ADDI.B  #37,D5
        BRA     ABSOCONVERTLONG
ABSONUMLONG
        ADDI.B  #$30,D5
        BRA     ABSOCONVERTLONG
ABSOCONVERTLONG
        SUBI.B  #1,D0
        MOVE.B  D5,(A3)+
        MOVE.B  D5,(A4)+
        CMPI.B  #0,D0
        BGT     ABSOCONVERTL
        MOVEQ   #2,D3
        RTS
********************************
ABSOCODE010
        MOVE.B  $11,D7
        *BRA    GETWORDFORBADDATA
*********************************
ABSOCODE011       
        MOVE.B  $11,D7
        *BRA    GETWORDFORBADDATA
*********************************
ABSOCODE100
        MOVE.B       
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
