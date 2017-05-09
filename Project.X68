*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
CR      EQU $0D
LF      EQU $0A

START_ADDR  DC.L    0
END_ADDR    DC.L    0
CUR_ADDR    DS.W    0        

    ORG    $1000
    
START:                  ; first instruction of program

* Put program code here
        LEA     WELCOME_MSG,A1  ; welcome message
        MOVE.B  #14,D0
        TRAP    #15
    
        LEA     USER_START,A1  ; user start message
        MOVE.B  #14,D0
        TRAP    #15
    
        MOVE.B  #2,D0           ;read user input as string
        TRAP    #15
        
        ; ascii to hex        
        JSR     CHECK_HEX_LEN
        JSR     CHAR_TO_HEX
        
        MOVE.L  (A1),START_ADDR   ; move hex into START_ADDR
        
        LEA     USER_END,A1  ; user end message
        MOVE.B  #14,D0
        TRAP    #15        
    
        MOVE.B  #2,D0           ;read user input as string
        TRAP    #15
        
        ;ascii to hex                     
        JSR     CHECK_HEX_LEN        
        JSR     CHAR_TO_HEX
        
        MOVE.L  (A1),END_ADDR ;move hex into END_ADDR
        
        *scan memory region        
*MAIN_LOOP    MOVE.L    CUR_ADDR,A2
*        MOVE.L     END_ADDR,A3
*        CMPA.W  A2,A3
*        BEQ     END

;       MOVE.W  (A2)+,D5
        MOVE.W   #$f000,D6   0010 1111 1111 1111
        AND.W    D5,D6          0010 000000000000
        
        CMP.W   #$0000,D6
        
        
        CMP.W   #$2000,D6
        BEQ     0010
*        MOVE.L (A0),D1
*        CLR.L   D0
        *ROL.L   $#04,D1
*        MOVE.W  (A0),D0
*       BRA MAIN_LOOP        
        
        
END                
    SIMHALT             ; halt simulator

CHECK_HEX_LEN   CMPI.B #$0,D1   ;if length of Hex is 0
                BEQ STOP_PROGRAM
                
                CMPI.B  #$8,D1  ;if length of Hex is greater than 8
                BGT STOP_PROGRAM
                
                RTS

STOP_PROGRAM    LEA ERROR_MSG,A1    ;address error message
                MOVE.B  #14,D0
                TRAP    #15
                MOVE.B  #9,D0   ;end the program
                TRAP    #15

CHAR_TO_HEX     CMPI.B  #$0,D1
                BEQ     HEX_FINISHED
                MOVE.B  (A1)+,D2    ;move right one character
                CMPI.B  #$39,D2
                BLE     NUM         ;if the character is a number less than 9
                
LETTER          SUB.B   #37,D2
                BRA     RESIZE                
                
NUM             SUBI.B  #$30,D2
                BRA     RESIZE
                
RESIZE          SUBI.B  #$1,D1
                ADD.B   D2,D3
                CMPI.B  #$0,D1
                BEQ     HEX_FINISHED
                
                ROL.L   #4,D3   ; rotate left 4 bits to the next char
                BRA     CHAR_TO_HEX
                
                
HEX_FINISHED    RTS
* Put variables and constants here

WELCOME_MSG DC.B    'Shanelee Tran and Tyler Do Disassembler',CR,LF,0
USER_START DC.B     'Enter starting address: ',0
USER_END    DC.B    CR,LF,'Enter ending address: ',0
ERROR_MSG   DC.B    CR,LF,'Invalid address',0
TEST_MSG    DC.B    CR,LF,'you made it',0

    END    START        ; last line of source









*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
