*-----------------------------------------------------------
* Title      : Disassembler Final
* Written by : Brent and Parker
* Date       : 3/17/21
* Description: Final Project for CSS 422
*-----------------------------------------------------------

;************************ Define Constants ********************************* 
CR                  EQU     $0D     ;carriage return
LF                  EQU     $0a     ;line feed
stack               EQU     $000A0000
lines_per_screen    EQU     15
buffer_size         EQU     64      ;size of buffer
nibble1             EQU     $F000   ;1st nibble in code (bits 15-12)
nibble2             EQU     $0F00   ;2nd nibble in code (bits 11-8)
nibble3             EQU     $00F0   ;3rd nibble in code (bits 7-4)
nibble4             EQU     $000F   ;4th nibble in code (bits 3-0)
right1              EQU     1       ;shift 1 time
right2              EQU     2       ;shift 2 times
right3              EQU     3       ;shift 3 times to extract src mode
right4              EQU     4       ;shift 4 times to extract 3rd nibble
right5              EQU     5       ;shift 5 times (unused)
right6              EQU     6       ;shift 6 times to extract dst mode
right7              EQU     7       ;shift 7 times
right8              EQU     8       ;shift 8 to extract 2nd nibble
right9              EQU     9       ;shift 9 times to check 2nd nibble?
right10             EQU     10      ;shift 10
right12             EQU     12      ;shift 12 to extract 3rd byte
right16             EQU     16      ;shift 16 to extract 2nd byte
right24             EQU     24      ;shift 24 to extract 1st byte
dest_mode           EQU     $01C0   ; --> 0000 0001 1100 0000 (used for destination in MOVE/MOVEA
dest_reg            EQU     $0E00   ;destination register (0000 0111 0000 0000)

ea_type_immediate   EQU     0
ea_type_move        EQU     1
ea_type_movea       EQU     2
ea_type_movea6      EQU     12
ea_type_lea         EQU     3
ea_type_destonly    EQU     4
ea_type_ext         EQU     5
ea_type_movem       EQU     6
ea_type_trap        EQU     7
ea_type_quick       EQU     8
ea_type_branch      EQU     9
ea_type_math        EQU     10
ea_type_rotation    EQU     11

    ORG    $1000
START:                              ;first instruction of program
    LEA     stack, SP               ;SP @ $A0000

;********************************** Welcome Message ******************************************** 
WELCOME:
    LEA     welcome_message,A1      ;load the welcome message into A1
    MOVE.B  #14,D0
    TRAP    #15                     ;print contents of welcome_message


;*********************************** Get Starting Address *************************************** 
GET_STARTING_ADDRESS:
    ;prompt for address
    MOVE.B  #14,D0    
    LEA     get_start_address,A1    ;load the get_start_address message into A1
    TRAP    #15                     ;print get_start_address
    
    ;get user input address, store, and convert
    LEA     ascii_start,A1          ;store
    MOVE.B  #2,D0                   ;get user input    
    TRAP    #15                     ;another trap to get input
    JSR     ATOI                    ;address is now in hex format in memory location
    
    ;at this point our address is in D4 in hex
    ;check if > 0
    CMP.L   #0,D4                       ;compare to D4
    BLE     STARTA_ERROR_LESS_THAN_ZERO ;branch to ERROR_LESS_THAN_ZERO if less than 0
    
    ;address is > 0 so check if even / odd
    ROR.L   #1,D4
    BCS     STARTA_ERROR_NOT_EVEN
    ROL.L   #1,D4    
    
    ;address is > 0 and verified even
    MOVE.l    (ascii_start),D5      ;load into A5
    MOVE.l    D5,A5                ;load into A5


;******************************** Get Ending Address ******************************************** 
GET_ENDING_ADDRESS:
    ;prompt for address 
    MOVE.B  #14,D0
    LEA     get_end_address,A1      ;load the get_end_address message into A1  
    TRAP    #15                     ;print get_end_address
    
    ;get user input address, store, and convert
    LEA     ascii_end,A1            ;store 
    MOVE.B  #2,D0                   ;get user input
    TRAP    #15                     ;another trap to get intput
    JSR ATOI

    ;perform checks:
    ;1.) even
    ROR.L   #1,D4
    BCS     ENDA_ERROR_NOT_EVEN
    ROL.L   #1,D4    
    
    ;2.) less than 00FFFFFF
    CMP.L   #$00FFFFFF,D4
    BGE     ENDA_ERROR_LARGE    
    
    ;3.) greater than starting address
    CMP.L   D4,A5
    BGE     ENDA_ERROR_LESS_THAN_STARTA
    
    ;good --> store in A6
    MOVE.l    (ascii_end),D6      ;load into D6
    MOVE.l    D6,A6               ;load into A6


;************************************ Main Loop???? ***********************************************
;get pointer to first given address
;pull hex code from that address and store in A1?
;take hex code and go to OP_TABLE


;A5 = starting address
;A6 = ending address
START_DECODING:
    CLR.L   D2                             ;clear screen line counter

DECODING_LOOP:
    JSR     OP_START                       ;get complete line of instruction to decode   

    ;RETURN FROM OP FINISH HERE
    
    ;print buffer to screen
    MOVE.B  #$0D, D0
    LEA     buffer,A1
    TRAP    #15
    
    ;check if we have hit ending address (current memory past ending address)
    CMP.L   A5,A6                       ;THE SOURCE OPERAND IS SUBTRACTED FROM THE DESTINATION OPERAND (A6-A5)--> (600 - 400)
    BLE     REPEAT_OR_FINISH
    
    ;CHECK FOR FFFF
    CMP.W   #$FFFF,(A5)
    BEQ     REPEAT_OR_FINISH
    
    ADDI.B  #1,D2
    CMP.B   #lines_per_screen,D2
    BGE     FILLED_SCREEN
    BRA     DECODING_LOOP
    
REPEAT_OR_FINISH:    
    MOVE.B  #14,D0
    LEA     prompt_again,A1
    TRAP    #15
    
    ;get user input
    MOVE.B  #2,D0
    LEA     ascii_y_or_n,A1
    TRAP    #15
    
    ;check user input and handle accordingly
    CLR     D3
    MOVE.B  ascii_y_or_n,D3
    CMPI.B  #'y',D3
    BEQ     GET_STARTING_ADDRESS
    CMPI.B  #'Y',D3
    BEQ     GET_STARTING_ADDRESS
    CMPI.B  #'n',D3
    BEQ     DONE
    CMPI.B  #'N',D3
    BEQ     DONE
    
    ;nothing was entered, try again
    BRA     REPEAT_OR_FINISH    

FILLED_SCREEN:
    MOVE.B  #14,D0
    LEA     prompt_enter,A1
    TRAP    #15
    MOVE.B  #$05,D0
    TRAP    #15
    BRA     START_DECODING  
       
DONE:
    SIMHALT                                 ; halt simulator



;**************************************************************** OP Stuff *********************************************************************************************** 

;A0 = POINTER TO OP_TABLE???
;A1 = 
;A2 = buffer (this is our decoded string that will print to screen)
;A3 = 
;A4 = current memory address for buffer (used for clearing????)
;A5 = starting address / current address in memory
;A6 = ending address
;A7 = SP

;D0
;D1
;D2 = ?
;D3 = buffer size (used for loop = 64)
;D4 = 
;D5
;D6
;D7

OP_START
    MOVEM.L         D2, -(SP)

    JSR         OP_DATA_CLR         ;clear buffer
    LEA         buffer, A2          ;A2 now points to buffer, which is cleared   

    ;print out current mem address by putting into buffer and then adding a ' ' (tab)
    MOVE.L      #$0003,D2           ;? BINARY --> 0011 ?
    JSR         ITOA_ADDRESS        ;convert A5 (current address) to ASCII and put in buffer
    MOVE.B      #$09, (A2)+         ;adds a ' ' to buffer
    
    ;at this point buffer has the memory address and a space, ready for op code
    
    LEA         OP_TABLE, A0
    CLR.L       D0
    MOVE.W      (A5)+,D0            ;moves opcode from current address into D0
    MOVE.L      D0,D1               ;should move into D1
    MOVE.B      #right12,D2         ;move immediate value 12 into D2
    LSR.W       D2,D1               ;shift D1 by 12 bits, leaving just 4 bits (this is our opcode???)
    MULU        #6,D1               ;computes opcode table jump displacement
    JMP         0(A0,D1)            ;jumps to opcode table entry (A0 = OP_TABLE)

OP_FINISH:
    MOVEM.L     (SP)+,D2
    RTS 


OP_DATA_CLR:
    CLR.L       D3               
    MOVE.B      #64,D3
    LEA         buffer, A4

OP_DATA_CLR_LOOP:
    MOVE.B      #0, (A4)+
    SUBI        #1, D3
    BGT         OP_DATA_CLR_LOOP
    RTS                                 ;need RTS to return


;********************************* jump table ****************************************
OP_TABLE:
    JMP         opcode0000              ;ORI (ANDI, SUBI, ADDI, EORI, CMPI)                                 $0
    JMP         opcode0001              ;MOVE.B                                                             $1    
    JMP         opcode0010              ;MOVEA.L, MOVE.L                                                    $2
    JMP         opcode0011              ;MOVEA.W MOVE.W                                                     $3
    JMP         opcode0100              ;NOP, MOVEM, LEA (CLR, NOT, EXT, TRAP, STOP, RTE, RTS, JSR, JMP     $4
    JMP         opcode0101              ;ADDQ (SUBQ)                                                        $5
    JMP         opcode0110              ;BRA.bw, BSR.bw (BEQ)                                               $6
    JMP         opcode0111              ;MOVEQ.l                                                            $7
    JMP         opcode1000              ;DIVU (DIVS, OR)                                                    $8
    JMP         opcode1001              ;SUB                                                                $9
    JMP         opcode1010              ;not assigned                                                       $A
    JMP         opcode1011              ;CMP (EOR)                                                          $B
    JMP         opcode1100              ;MULU (MULS, AND)                                                   $C
    JMP         opcode1101              ;ADD, ADDA                                                          $D
    JMP         opcode1110              ;ASL, ASR (LSL, LSR, ROL, ROR)                                      $E
    JMP         opcode1111              ;not assigned                                                       $F




;A0 = POINTER TO OP_TABLE
;A1 = 
;A2 = buffer (this is our decoded string that will print to screen)
;A3 = pointer to op_xxx_table
;A4 = current memory address for buffer (used for clearing????)
;A5 = starting address / current address in memory
;A6 = ending address
;A7 = SP

;D0 = full instruction
;D1 = full instruction for manipulating (temporary)
;D2 = will store immediate value for comparing
;D3 = buffer size (used for loop = 64)
;D4 = 
;D5 = 
;D6 = 
;D7 = 



;ORI (ANDI, SUBI, ADDI, EORI, CMPI)                                 $0
opcode0000:                                 
    MOVE.L      D0,D1                   ;D1 has full instruction
    ANDI.W      #nibble2,D1             ;check bits 11,10,9,8
    MOVE.B      #right8, D2             ;store immediate value 8 in D2
    LSR.W       D2, D1                  ;shift to isolate next nibble (bits 11-8)
    MULU        #6, D1                  ;multiply by 6 to get displacement
    LEA         OP_0000_TABLE, A3       ;load op_0000_table into address register
    JMP         0(A3,D1)                ;jumps to opcode table entry (A0 = OP_TABLE)

;MOVE.B                                                             $1
opcode0001:
    JMP         OP_MOVEB                ;no need to break down, only MOVE.B


;MOVEA.L, MOVE.L                                                    $2
opcode0010:
    MOVE.L      D0,D1                   ;D1 has full instruction
    ANDI        #dest_mode, D1          ;0000 0001 1100 0000
    MOVE.B      #right6, D2             ;D2 now 00000111
    LSR.W       D2, D1                  ;shifting destination mode in D1 to far right by 3
    CMP.B       #1,D1                   ;does d1 = 001?
    BEQ         OP_MOVEAL               ;if d1 = 001, go to MOVEA
    JMP         OP_MOVEL                ;else jump to MOVEL

;MOVEA.W MOVE.W                                                     $3
opcode0011:
    MOVE.L      D0,D1                   ;D1 has full instruction
    ANDI        #dest_mode, D1          ;0000 0001 1100 0000
    MOVE.B      #right6, D2             ;D2 now 00000111
    LSR.W       D2, D1                  ;shifting destination mode in D1 to far right by 3
    CMP.B       #1,D1                   ;does d1 = 001?
    BEQ         OP_MOVEAW               ;if d1 = 001, go to MOVEAW
    JMP         OP_MOVEW                ;else jump to MOVEW

;NOP, MOVEM, LEA (CLR, NOT, EXT, TRAP, STOP, RTE, RTS, JSR, JMP)     $4
opcode0100:
    MOVE.L      D0,D1                   ;D1 has full instruction
    ANDI.W      #nibble2,D1             ;check bits 11,10,9,8
    MOVE.B      #right8, D2             ;store immediate value 8 in D2
    LSR.W       D2, D1                  ;shift to isolate next nibble (bits 11-8)
    MULU        #6, D1                  ;multiply by 6 to get displacement
    LEA         OP_0100_TABLE, A3       ;load op_0000_table into address register
    JMP         0(A3,D1)                ;jumps to opcode table entry (A0 = OP_TABLE)

;ADDQ (SUBQ)                                                        $5
opcode0101:
    MOVE.L      D0,D1
    ANDI.W      #nibble2,D1
    LSR.W       #right8,D1
    ANDI.W      #1,D1
    CMP.B       #0,D1
    BEQ         OP_ADDQ
    CMP.B       #1,D1   
    BEQ         OP_SUBQ
    
    JMP         OP_UNSUPPORTED_OPCODE

;BRA.bw, BSR.bw (BEQ)                                               $6
opcode0110:
    MOVE.L      D0,D1                   ;D1 has full instruction
    ANDI.W      #nibble2,D1             ;check bits 11,10,9,8
    MOVE.B      #right8, D2             ;store immediate value 8 in D2
    LSR.W       D2, D1                  ;shift to isolate next nibble (bits 11-8)
    MULU        #6, D1                  ;multiply by 6 to get displacement
    LEA         OP_0110_TABLE, A3       ;load op_0110_table into address register
    JMP         0(A3,D1)                ;jumps to opcode table entry (A0 = OP_TABLE)

;MOVEQ                                                            $7
opcode0111:
    JMP         OP_MOVEQ

;DIVU (DIVS, OR)                                                    $8
opcode1000:
    MOVE.L      D0,D1
    ANDI.W      #nibble2,D1
    LSR.W       #8,D1
    ANDI.B      #1,D1
    CMP.B       #0,D1
    BEQ         OP_DIVU
    CMP.B       #1,D1
    BEQ         OP_DIVS

    JMP         OP_UNSUPPORTED_OPCODE

;SUB                                                                $9
opcode1001:
    JMP         OP_SUB


;not assigned                                                       $A
opcode1010:
    JMP         OP_UNSUPPORTED_OPCODE


;CMP (EOR)                                                          $B
opcode1011:
    JMP         OP_CMP


;MULU (MULS, AND)                                                   $C
opcode1100:
    MOVE.L      D0,D1
    ANDI.W      #nibble2,D1
    LSR.W       #8,D1
    ANDI.B      #1,D1
    CMP.B       #0,D1
    BEQ         OP_MULU
    CMP.B       #1,D1
    BEQ         OP_MULS
    JMP         OP_UNSUPPORTED_OPCODE

;ADD, ADDA                                                          $D
opcode1101:
    ;ADD and ADDA differ on bits 6,7... ADD will never be 11 for bits 6,7... use as check
    CLR         D1
    CLR         D2
    MOVE.L      D0,D1
    ANDI.W      #nibble3, D1
    MOVE.B      #right6, D2
    LSR.W       D2,D1
    
    ;at this point we have our bits of interest in bits 1,0
    
    CMP         #3,D1                               ;check if bits == 11
    BEQ         OP_ADDA                             ;if yes, branch ADDA
    BRA         OP_ADD                              ;else branch ADD

;ASL, ASR (LSL, LSR, ROL, ROR)                                      $E
opcode1110:
    CLR D1
    CLR D2
    MOVE.L      D0, D1
    ANDI.W      #nibble2, D1
    MOVE.B      #right8, D2
    LSR.W       D2, D1                              ;D1 has 0003 or 0004
    ANDI.W      #0001,D1                            ;isolate single bit
    
    ;at this point we have our single bit of interest in bit 0
    
    CMP         #0,D1                               ;check if bit == 0
    BEQ         OP_ASR                              ;if yes, branch to ASR
    BRA         OP_ASL                              ;else, branch to ASL


;not assigned                                                       $F
opcode1111:
    JMP         OP_INVALID_OPCODE


;******************************** OP_XXX_TABLES ************************************
;once in OP_XXX_TABLE , we will use these entries to jump to specific op code to put into buffer

OP_0000_TABLE:
    jmp OP_ORI                                      ;0  
    jmp OP_UNSUPPORTED_OPCODE                       ;1
    jmp OP_ANDI                                     ;2
    jmp OP_UNSUPPORTED_OPCODE                       ;3
    jmp OP_SUBI                                     ;4
    jmp OP_UNSUPPORTED_OPCODE                       ;5
    jmp OP_ADDI                                     ;6
    jmp OP_UNSUPPORTED_OPCODE                       ;7
    jmp OP_UNSUPPORTED_OPCODE                       ;8
    jmp OP_UNSUPPORTED_OPCODE                       ;9
    jmp OP_EORI                                     ;10
    jmp OP_UNSUPPORTED_OPCODE                       ;11
    jmp OP_CMPI                                     ;12
    jmp OP_UNSUPPORTED_OPCODE                       ;13
    jmp OP_UNSUPPORTED_OPCODE                       ;14
    jmp OP_UNSUPPORTED_OPCODE                       ;15


;NOP, MOVEM, LEA (CLR, NOT, EXT, TRAP, STOP, RTE, RTS, JSR, JMP     $4
;NOP    1110
;MOVEM  1D00
;LEA    AN1
OP_0100_TABLE:
    jmp OP_UNSUPPORTED_OPCODE                           ;0  
    jmp OP_LEA                                          ;1      (address 0001)
    jmp OP_UNSUPPORTED_OPCODE                           ;2
    jmp OP_LEA                                          ;3      (address 0011)
    jmp OP_UNSUPPORTED_OPCODE                           ;4 
    jmp OP_LEA                                          ;5      (address 0101)
    jmp OP_UNSUPPORTED_OPCODE                           ;6 
    jmp OP_LEA                                          ;7      (address 0111) 
    jmp OP_MOVEM                                        ;8                         
    jmp OP_LEA                                          ;9      (address 1001) 
    jmp OP_UNSUPPORTED_OPCODE                           ;10 
    jmp OP_LEA                                          ;11     (address 1011) 
    jmp OP_MOVEM                                        ;12                       
    jmp OP_LEA                                          ;13     (address 1101)
    jmp OP_NOP                                          ;14
    jmp OP_LEA                                          ;15     (address 1111)


;BRA nibble 2 = 0000 (0) , BSR nibble 2 = 0001 (1)
OP_0110_TABLE:
    jmp OP_BRA                                          ;0
    jmp OP_BSR                                          ;1
    jmp OP_UNSUPPORTED_OPCODE                           ;2
    jmp OP_UNSUPPORTED_OPCODE                           ;3
    jmp OP_UNSUPPORTED_OPCODE                           ;4
    jmp OP_UNSUPPORTED_OPCODE                           ;5
    jmp OP_UNSUPPORTED_OPCODE                           ;6
    jmp OP_UNSUPPORTED_OPCODE                           ;7
    jmp OP_UNSUPPORTED_OPCODE                           ;8
    jmp OP_UNSUPPORTED_OPCODE                           ;9
    jmp OP_UNSUPPORTED_OPCODE                           ;10
    jmp OP_UNSUPPORTED_OPCODE                           ;11
    jmp OP_UNSUPPORTED_OPCODE                           ;12
    jmp OP_UNSUPPORTED_OPCODE                           ;13
    jmp OP_UNSUPPORTED_OPCODE                           ;14
    jmp OP_UNSUPPORTED_OPCODE                           ;15


;******************************** OP_INSTRUCTION_XXXX******************************************
;this is where we are putting ascii text into buffer

OP_ORI:
    MOVE.B  #'O', (A2)+
    MOVE.B  #'R', (A2)+
    MOVE.B  #'I', (A2)+
    
    ;call OP_CHECK_SIZE to append a .b/.w/.l
    JSR     OP_CHECK_SIZE
    
    MOVE.L  #ea_type_immediate, D1              ;preps for EA_START and puts 0 into D1

    JSR     EA_START
    JMP     OP_FINISH

OP_ANDI:  ;(optional)
    MOVE.B  #'A', (A2)+
    MOVE.B  #'N', (A2)+
    MOVE.B  #'D', (A2)+
    MOVE.B  #'I', (A2)+
    
    ;call OP_CHECK_SIZE to append a .b/.w/.l
    JSR     OP_CHECK_SIZE
    
    MOVE.L  #ea_type_immediate, D1              ;preps for EA_START and puts 0 into D1

    JSR     EA_START
    JMP     OP_FINISH


OP_SUBI:  ;(optional)
    MOVE.B  #'S', (A2)+
    MOVE.B  #'U', (A2)+
    MOVE.B  #'B', (A2)+
    MOVE.B  #'I', (A2)+
    
    ;call OP_CHECK_SIZE to append a .b/.w/.l
    JSR     OP_CHECK_SIZE
    
    MOVE.L  #ea_type_immediate, D1              ;preps for EA_START and puts 0 into D1

    JSR     EA_START
    JMP     OP_FINISH


OP_ADDI:  ;(optional)
    MOVE.B  #'A', (A2)+
    MOVE.B  #'D', (A2)+
    MOVE.B  #'D', (A2)+
    MOVE.B  #'I', (A2)+
    
    ;call OP_CHECK_SIZE to append a .b/.w/.l
    JSR     OP_CHECK_SIZE
   
    MOVE.L  #ea_type_immediate, D1              ;preps for EA_START and puts 0 into D1

    JSR     EA_START
    JMP     OP_FINISH


OP_EORI:  ;(optional)
    MOVE.B  #'E', (A2)+
    MOVE.B  #'O', (A2)+
    MOVE.B  #'R', (A2)+
    MOVE.B  #'I', (A2)+
    
    ;call OP_CHECK_SIZE to append a .b/.w/.l
    JSR     OP_CHECK_SIZE
    
    MOVE.L  #ea_type_immediate, D1              ;preps for EA_START and puts 0 into D1
    
    JSR     EA_START
    JMP     OP_FINISH


OP_CMPI:  ;(optional)
    MOVE.B  #'C', (A2)+
    MOVE.B  #'M', (A2)+
    MOVE.B  #'P', (A2)+
    MOVE.B  #'I', (A2)+
    
    
    ;call OP_CHECK_SIZE to append a .b/.w/.l
    JSR     OP_CHECK_SIZE

    MOVE.L  #ea_type_immediate, D1              ;preps for EA_START and puts 0 into D1

    JSR     EA_START
    JMP     OP_FINISH


OP_MOVEB:
    MOVE.B  #'M', (A2)+
    MOVE.B  #'O', (A2)+
    MOVE.B  #'V', (A2)+
    MOVE.B  #'E', (A2)+
    MOVE.B  #'.', (A2)+
    MOVE.B  #'B', (A2)+
    
    MOVE.L  #ea_type_move, D1                   ;preps for EA_START and puts 1 into D1
    
    JSR     EA_START
    JMP     OP_FINISH

OP_MOVEAL:
    MOVE.B  #'M', (A2)+
    MOVE.B  #'O', (A2)+
    MOVE.B  #'V', (A2)+
    MOVE.B  #'E', (A2)+
    MOVE.B  #'A', (A2)+
    MOVE.B  #'.', (A2)+
    MOVE.B  #'L', (A2)+
    
    MOVE.L  #ea_type_movea, D1                   ;preps for EA_START and puts 2 into D1
    
    JSR     EA_START
    JMP     OP_FINISH

OP_MOVEL:
    MOVE.B  #'M', (A2)+
    MOVE.B  #'O', (A2)+
    MOVE.B  #'V', (A2)+
    MOVE.B  #'E', (A2)+
    MOVE.B  #'.', (A2)+
    MOVE.B  #'L', (A2)+
    
    MOVE.L  #ea_type_move, D1                   ;preps for EA_START and puts 1 into D1
    
    JSR     EA_START
    JMP     OP_FINISH


OP_MOVEAW:
    MOVE.B  #'M', (A2)+
    MOVE.B  #'O', (A2)+
    MOVE.B  #'V', (A2)+
    MOVE.B  #'E', (A2)+
    MOVE.B  #'A', (A2)+
    MOVE.B  #'.', (A2)+
    MOVE.B  #'W', (A2)+
    
    MOVE.L  #ea_type_movea, D1                   ;preps for EA_START and puts 2 into D1
    
    JSR     EA_START
    JMP     OP_FINISH


OP_MOVEW:
    MOVE.B  #'M', (A2)+
    MOVE.B  #'O', (A2)+
    MOVE.B  #'V', (A2)+
    MOVE.B  #'E', (A2)+
    MOVE.B  #'.', (A2)+
    MOVE.B  #'W', (A2)+
    
    MOVE.L  #ea_type_move, D1                   ;preps for EA_START and puts 1 into D1
    
    JSR     EA_START
    JMP     OP_FINISH


OP_NOP:
    MOVE.B  #'N', (A2)+
    MOVE.B  #'O', (A2)+
    MOVE.B  #'P', (A2)+
    
    ;NO EA
    JMP     OP_FINISH


OP_MOVEM:   
    MOVE.B  #'M', (A2)+
    MOVE.B  #'O', (A2)+
    MOVE.B  #'V', (A2)+
    MOVE.B  #'E', (A2)+
    MOVE.B  #'M', (A2)+
    
    ;call OP_CHECK_SIZE to append a .b/.w/.l
    JSR     OP_CHECK_SIZE_MOVEM
    
    MOVE.L  #ea_type_movem, D1                   ;preps for EA_START and puts 6 into D1
    
    JSR     EA_START
    JMP     OP_FINISH

OP_LEA:
    MOVE.B  #'L', (A2)+
    MOVE.B  #'E', (A2)+
    MOVE.B  #'A', (A2)+
    
    MOVE.L  #ea_type_lea, D1                   ;preps for EA_START and puts 3 into D1
    
    JSR     EA_START
    JMP     OP_FINISH

OP_CLR:  ;(optional)
    JMP     OP_UNSUPPORTED_OPCODE 


OP_NOT:  ;(optional)
    JMP     OP_UNSUPPORTED_OPCODE 


OP_EXT:  ;(optional)
    JMP     OP_UNSUPPORTED_OPCODE 


OP_TRAP:  ;(optional)
    JMP     OP_UNSUPPORTED_OPCODE 

 
OP_STOP:  ;(optional)
    JMP     OP_UNSUPPORTED_OPCODE 


OP_RTE:  ;(optional)
    JMP     OP_UNSUPPORTED_OPCODE 


OP_RTS:  ;(optional)
    JMP     OP_UNSUPPORTED_OPCODE 


OP_JSR:  ;(optional)
    JMP     OP_UNSUPPORTED_OPCODE 


OP_JMP:  ;(optional)
    JMP     OP_UNSUPPORTED_OPCODE 


OP_ADDQ:
    MOVE.B  #'A', (A2)+
    MOVE.B  #'D', (A2)+
    MOVE.B  #'D', (A2)+
    MOVE.B  #'Q', (A2)+
    
    ;call OP_CHECK_SIZE to append a .b/.w/.l
    JSR     OP_CHECK_SIZE

    MOVE.L  #ea_type_quick, D1                   ;preps for EA_START and puts 8 into D1

    JSR     EA_START
    JMP     OP_FINISH

OP_SUBQ:  ;(optional)
    MOVE.B  #'S', (A2)+
    MOVE.B  #'U', (A2)+
    MOVE.B  #'B', (A2)+
    MOVE.B  #'Q', (A2)+
    
    ;call OP_CHECK_SIZE to append a .b/.w/.l
    JSR     OP_CHECK_SIZE
    
    MOVE.L  #ea_type_quick, D1                      ;preps for EA_START and puts 8 into D1

    JSR     EA_START
    JMP     OP_FINISH

OP_BRA:                                     
    MOVE.B  #'B', (A2)+
    MOVE.B  #'R', (A2)+
    MOVE.B  #'A', (A2)+

    MOVE.L  #ea_type_branch,D1
    
    JSR     EA_START
    JMP     OP_FINISH


OP_BSR:
    MOVE.B  #'B', (A2)+
    MOVE.B  #'S', (A2)+
    MOVE.B  #'R', (A2)+
    
    MOVE.L  #ea_type_branch,D1
    
    JSR     EA_START                        
    JMP     OP_FINISH


OP_BEQ:
    JMP     OP_UNSUPPORTED_OPCODE 


OP_MOVEQ:
    MOVE.B  #'M', (A2)+
    MOVE.B  #'O', (A2)+
    MOVE.B  #'V', (A2)+
    MOVE.B  #'E', (A2)+
    MOVE.B  #'Q', (A2)+
    
    ;DO WE NEED A .L ?
    
    MOVE.L  #ea_type_quick, D1                      ;preps for EA_START and puts 8 into D1
    
    JSR     EA_START
    JMP     OP_FINISH


OP_DIVU:
    MOVE.B  #'D', (A2)+
    MOVE.B  #'I', (A2)+
    MOVE.B  #'V', (A2)+
    MOVE.B  #'U', (A2)+
  
    MOVE.L  #ea_type_math, D1                       ;preps for EA_START and puts 10 into D1
  
    JSR     EA_START
    JMP     OP_FINISH    


OP_DIVS:  ;(optional)
    MOVE.B  #'D', (A2)+
    MOVE.B  #'I', (A2)+
    MOVE.B  #'V', (A2)+
    MOVE.B  #'S', (A2)+
  
    MOVE.L  #ea_type_math, D1                       ;preps for EA_START and puts 10 into D1
  
    JSR     EA_START
    JMP     OP_FINISH   


OP_OR:  ;(optional)
    JMP     OP_UNSUPPORTED_OPCODE 


OP_SUB:
    MOVE.B  #'S', (A2)+
    MOVE.B  #'U', (A2)+
    MOVE.B  #'B', (A2)+

    JSR     OP_CHECK_SIZE                       ;call OP_CHECK_SIZE to append a .b/.w/.l
    
    MOVE.L  #ea_type_math, D1                   ;preps for EA_START and puts 10 into D1
    
    ;at this point it will return with SUB.X and go to EA_START
    JSR     EA_START
    JMP     OP_FINISH    


OP_CMP:
    MOVE.B  #'C', (A2)+
    MOVE.B  #'M', (A2)+
    MOVE.B  #'P', (A2)+
  
    JSR     OP_CHECK_SIZE                       ;call OP_CHECK_SIZE to append a .b/.w/.l  
    
    MOVE.L  #ea_type_math, D1                   ;preps for EA_START and puts 10 into D1
    
    ;at this point it will return with SUB.X and go to EA_START
    JSR     EA_START
    JMP     OP_FINISH    
    

OP_EOR:  ;(optional)
    JMP     OP_UNSUPPORTED_OPCODE 


OP_MULU:
    MOVE.B  #'M', (A2)+
    MOVE.B  #'U', (A2)+
    MOVE.B  #'L', (A2)+
    MOVE.B  #'U', (A2)+

    MOVE.L  #ea_type_math, D1                   ;preps for EA_START and puts 10 into D1
    
    JSR     EA_START
    JMP     OP_FINISH    

OP_MULS:  ;(optional)
    MOVE.B  #'M', (A2)+
    MOVE.B  #'U', (A2)+
    MOVE.B  #'L', (A2)+
    MOVE.B  #'S', (A2)+

    MOVE.L  #ea_type_math, D1                   ;preps for EA_START and puts 10 into D1

    JSR     EA_START
    JMP     OP_FINISH


OP_AND:  ;(optional)
    JMP     OP_UNSUPPORTED_OPCODE 


OP_ADD:
    MOVE.B  #'A', (A2)+
    MOVE.B  #'D', (A2)+
    MOVE.B  #'D', (A2)+

    ;call OP_CHECK_SIZE to append a .b/.w/.l
    JSR     OP_CHECK_SIZE
    
    MOVE.L  #ea_type_math, D1                       ;preps for EA_START and puts 10 into D1

    JSR     EA_START
    JMP     OP_FINISH

OP_ADDA:
    MOVE.B  #'A', (A2)+
    MOVE.B  #'D', (A2)+
    MOVE.B  #'D', (A2)+
    MOVE.B  #'A', (A2)+

    ;call OP_CHECK_SIZE to append a .b/.w/.l
    JSR     OP_CHECK_SIZE_ADDA
    
    MOVE.L  #ea_type_math, D1                       ;preps for EA_START and puts 10 into D1

    JSR     EA_START
    JMP     OP_FINISH


OP_ASL:
    MOVE.B  #'A', (A2)+
    MOVE.B  #'S', (A2)+
    MOVE.B  #'L', (A2)+

    ;call OP_CHECK_SIZE to append a .b/.w/.l
    JSR     OP_CHECK_SIZE
    
    MOVE.L  #ea_type_rotation, D1                   ;preps for EA_START and puts 10 into D1
    
    JSR     EA_START
    JMP     OP_FINISH


OP_ASR:
    MOVE.B  #'A', (A2)+
    MOVE.B  #'S', (A2)+
    MOVE.B  #'R', (A2)+

    ;call OP_CHECK_SIZE to append a .b/.w/.l
    JSR     OP_CHECK_SIZE
    
    MOVE.L  #ea_type_rotation, D1                   ;preps for EA_START and puts 10 into D1

    JSR     EA_START
    JMP     OP_FINISH

OP_LSL:  ;(optional)
    JMP     OP_UNSUPPORTED_OPCODE 



OP_LSR:  ;(optional)
    JMP     OP_UNSUPPORTED_OPCODE 



OP_ROL:  ;(optional)
    JMP     OP_UNSUPPORTED_OPCODE 



OP_ROR:  ;(optional)
    JMP     OP_UNSUPPORTED_OPCODE 



OP_UNSUPPORTED_OPCODE:
    ;print error message
    MOVE.B  #14,D0
    LEA     unsupported_opcode_message,A1
    TRAP    #15
    
    ;return to start of program
    JMP     GET_STARTING_ADDRESS
    
OP_INVALID_OPCODE:
    MOVE.B  #14,D0
    LEA     invalid_opcode_message,A1
    TRAP    #15
    
    JMP     GET_STARTING_ADDRESS  
    
;D0 HAS COMPLETE INSTRUCTION
OP_CHECK_SIZE:
    CLR     D1                                      ;CLEAR D1
    CLR     D2                                      ;clear D2
    MOVE.L  D0,D1                                   ;D0 and D1 both have complete opcode
    ANDI.W  #nibble3,D1                             ;isolate nibble 3
    MOVE.B  #right6, D2                             ;putting immediate value 6 in D2
    LSR.W   D2, D1                                  ;bits 7,6 --> bits 1,0
    
     
    CMP     #00,D1                                  ;compare bits 1,0 to 00
    BEQ     OP_SIZE_BYTE                            ;if bits == 00, size byte
    CMP     #01,D1                                  ;compare bits to 01
    BEQ     OP_SIZE_WORD                            ;if bits == 01, size word
    BRA     OP_SIZE_LONG                            ;else size long


OP_CHECK_SIZE_MOVEM:
    CLR     D1                                      ;CLEAR D1
    CLR     D2                                      ;clear D2
    MOVE.L  D0,D1                                   ;D0 and D1 both have complete opcode
    ANDI.W  #nibble3,D1                             ;isolate nibble 3
    MOVE.B  #right6, D2                             ;putting immediate value 6 in D2
    LSR.W   D2, D1                                  ;bits 7,6 --> bits 1,0
    
    ANDI.W  #1,D1    
    CMP     #0,D1                                   ;compare bits 1,0 to 00
    BEQ     OP_SIZE_WORD                            ;if bits == 00, size WORD
    CMP     #1,D1                                   ;compare bits to 01
    BEQ     OP_SIZE_LONG                            ;if bits == 01, size LONG

OP_SIZE_BYTE
    MOVE.B  #'.', (A2)+
    MOVE.B  #'B', (A2)+
    RTS

OP_SIZE_WORD
    MOVE.B  #'.', (A2)+
    MOVE.B  #'W', (A2)+
    RTS


OP_SIZE_LONG
    MOVE.B  #'.', (A2)+
    MOVE.B  #'L', (A2)+
    RTS


OP_CHECK_SIZE_ADDA:
    CLR     D1                                      ;CLEAR D1
    CLR     D2                                      ;clear D2
    MOVE.L  D0,D1                                   ;D0 and D1 both have complete opcode
    ANDI.W  #nibble2,D1                             ;isolate nibble 2
    MOVE.B  #right8, D2                             ;putting immediate value 8 in D2
    LSR.W   D2, D1                              
    
    ;at this point we have our single bit in bit 0
    
    ANDI.W  #0001,D1                                ;isolate bit 0
    CMP     #0,D1                                   ;check if bit == 0
    BEQ     OP_SIZE_WORD                            ;if yes, size = word
    BRA     OP_SIZE_LONG                            ;else, size = long
 

;**************************************************************** ATOI **********************************************************************************************
ATOI:
        MOVE.L      D1,D2                   ;loop variable (size) is in D2
        MOVEA.L     A1,A2                   ;pointer to next char
        CLR.L       D4

ATOI_LOOP  
        CLR         D3                      ;clear d3
        SUBI.L      #1,D2                   ;subtract 1 from loop counter
        MOVE.B      (A2)+,D3                 ;move current byte to D3, then increment to next
        CMP.B       #$2F,D3
        BLE         ATOI_ERROR              ;if less than 30, not a number, branch to error
        CMP.B       #$39,D3                 ;check byte to see if number or letter
        BLE         ATOI_NUMBER             ;30<x<39 --> number
        CMP.B       #$40,D3
        BLE         ATOI_ERROR
        CMP.B       #$46,D3
        BLE         ATOI_UPPERCASE_LETTER   ;less than 47, it is uppercase letter
        CMP.B       #$60,D3
        BLE         ATOI_ERROR
        CMP.B       #$66,D3
        BLE         ATOI_LOWERCASE_LETTER
        CMP.B       #$67,D3
        BGE         ATOI_ERROR        
    

ATOI_NUMBER
;number --> d1 = d1 - $30
    SUBI.B          #$30, D3                    ;subtract 30 if number
    JMP             ATOI_FORMAT                 ;testing

ATOI_UPPERCASE_LETTER
;letter --> d1 = d1 - $37
    SUBI.B          #$37,D3                     ;subtract 37 if UPPER case letter
    JMP             ATOI_FORMAT                 ;testing

ATOI_LOWERCASE_LETTER
    SUBI.B          #$57,D3                     ;subtract 57(20 + 37)
    JMP             ATOI_FORMAT                 ;testing

ATOI_FORMAT
    ADD.B           D3,D4                       ;add the byte to D4 so can add later   
    CMP.B           #0,D2                       
    BEQ             ATOI_DONE                   ;check if done (loop counter D2 is at 0)
    ASL.L           #4,D4                       ;logical shift left to make room
    JMP             ATOI_LOOP                   ;go back to loop
    

ATOI_DONE 
    MOVE.L         D4,(A1)                      ;at this point, move the new address in D4 to mem location                                
    RTS                                         ;used to RTS after a branch statement
    
ATOI_ERROR:
    ;print error message
    MOVE.B  #14,D0
    LEA     invalid_character_message,A1
    TRAP    #15
    
    ;return to start of program
    JMP     GET_STARTING_ADDRESS

;************************************* ITOA *******************************************************************************************************************
;A0
;A1
;A2 = buffer (this is our decoded string that will print to screen)
;A3
;A4 = current memory address for buffer
;A5 = starting address / current address in memory
;A6 = ending address
;A7 = SP

;D0 = counter
;D1 = 
;D2 = ?
;D3 = buffer size (used for loop = 64)
;D4 = value being converted
;D5 =
;D6 = 
;D7 = 
ITOA:
    MOVE.L         A5,D4                        ;D4 has data to convert to ascii

ITOA_LOOP:
    CMP.B           #0,D5
    BEQ             ITOA_FINISH                 ;when 0, branch to finish to complete


ITOA_ADDRESS:
    CLR.L       D4                              ;D4 = 0000 0000
    MOVE.L      A5,D4                           ;our address is now in D4 and ready to deconstruct
    MOVE.B      #8,D0                           ;counter
    JMP         ITOA_ADDRESS_LOOP
ITOA_ADDRESS_LOOP:
    CMP.B       #0,D0                           ;check if done
    BEQ         ITOA_FINISH                     ;if at 0, branch to ITOA_FINISH
    ROL.L       #4,D4                           ;rotate left 4 bits, to get MSB to beginning 
    MOVE.B      D4,D1                           ;store in D1 (this will be whole byte, we want half)
    ANDI.W      #$000F,D1                       ;character is now isolated
    
    JSR         ITOA_HEX2ASCII                  ;JSR to convert
    SUBI        #1,D0                           ;subtract 1 from counter
    JMP         ITOA_ADDRESS_LOOP               ;loop again!

ITOA_HEX2ASCII:
    CMP.B       #$A,D1                          ;compare byte in D1 to hex value A
    BGE         ITOA_LETTER                     ;if greater than/equal A, it is letter
    CMP.B       #$A,D1                          ;compare byte in D1 to hex value A
    BLT         ITOA_NUMBER                     ;if less than, it is number

ITOA_NUMBER:
    ADDI.B      #$30,D1                         ;add $30 to D1 to convert
    MOVE.B      D1,(A2)+                        ;add to buffer and increment to next position
    RTS

ITOA_LETTER:
    ADDI.B      #$37,D1                         ;add 37 to D1 to convert
    MOVE.B      D1,(A2)+                        ;add to buffer and increment to next position
    RTS

ITOA_FINISH:
    RTS


;******************************************************** Message Error Handling ***************************************************************************************** 
STARTA_ERROR_LESS_THAN_ZERO:
    MOVE.B  #14,D0
    LEA     error_message_1,A1                  ;load the get_end_address message into A1
    TRAP    #15    
    JMP     GET_STARTING_ADDRESS

STARTA_ERROR_NOT_EVEN:
    MOVE.B  #14,D0
    LEA     error_message_2,A1                  ;load error_message_2
    TRAP    #15    
    JMP     GET_STARTING_ADDRESS

ENDA_ERROR_NOT_EVEN:
    MOVE.B  #14,D0
    LEA     error_message_3,A1                  ;load error_message_3
    TRAP    #15
    JMP     GET_ENDING_ADDRESS

ENDA_ERROR_LARGE:
    MOVE.B  #14,D0
    LEA     error_message_4,A1                  ;load error_message_4
    TRAP    #15
    JMP     GET_ENDING_ADDRESS
    
ENDA_ERROR_LESS_THAN_STARTA:
    MOVE.B  #14,D0
    LEA     error_message_5,A1                  ;load error_message_5
    TRAP    #15
    JMP     GET_ENDING_ADDRESS

;******************************************************************* EA Stuff ******************************************************************************************** 

EA_START:
    LEA         EA_TYPE_TABLE, A0
    
    MULU        #6,D1                           ;computes opcode table jump displacement
    JMP         0(A0,D1)                        ;jump to correct table input


EA_TYPE_TABLE:
    JMP         EA_IMMEDIATE                    ;0  DONE
    JMP         EA_MOVE                         ;1  DONE
    JMP         EA_MOVEA                        ;2  DONE
    JMP         EA_LEA                          ;3  DONE
    JMP         EA_DESTONLY                     ;4  JMP, CLR
    JMP         EA_EXT                          ;5
    JMP         EA_MOVEM                        ;6
    JMP         EA_TRAP                         ;7
    JMP         EA_QUICK                        ;8  DONE
    JMP         EA_BRANCH                       ;9  DONE
    JMP         EA_MATH                         ;10 DONE    DIVU, DIVS, SUB, CMP, MULU, ADD, ADDA
    JMP         EA_ROTATION                     ;11         ASL, ASR 
    JMP         EA_FINISH                       

EA_FINISH:
    RTS 
    


;********************************************  EA_TYPE  ****************************************************   

EA_IMMEDIATE:                                   ;value 0
    MOVE.B  #$09, (A2)+                         ;adds a ' ' to buffer
    MOVE.B  #'#',(A2)+                          ;add a # to buffer
    MOVE.B  #'$',(A2)+                          ;add a $ to buffer
    
    ;check size which is bits 6,7 and store in D6
    ;get immediate value from memory based off size and store in D7
    JSR     EA_CHECK_SIZE
    
    ;at this point our size is in D6 and data is in D7 and memory has been advanced
    ;convert immediate data to ascii and put on buffer
    JSR     EA_ITOA_IMMEDIATE
    
    LEA     EA_MODE_TABLE,A0                    ;load table
    MOVE.B  #',',(A2)+                          ;add a # to buffer
    MOVE.B  #$09, (A2)+                         ;adds a ' ' to buffer
    
    ;source mode are bits 3,4,5   |   ;source register are bits 0,1,2
    
    ;isolate source mode - bits 3,4,5 and store in D4
    MOVE.L  D0,D4
    LSR.W   #3,D4
    ANDI.W  #$7,D4
    MULU    #6,D4
    
    ;isolate source register - bits 0,1,2 and store in D5
    MOVE.L  D0,D5
    ANDI.W  #$7,D5

    JSR     EA_JMP_HELPER
    JMP     EA_FINISH

;D4 = mode      --> source / destination
;D5 = register  --> source / destination   
EA_MOVE:
    MOVE.B  #$09, (A2)+                     ;adds a ' ' to buffer
    LEA     EA_MODE_TABLE,A0                ;load table
    
    ;source mode are bits 3,4,5   |         ;source register are bits 0,1,2
    
    ;isolate source mode
    MOVE.L  D0,D4
    LSR.W   #3,D4
    ANDI.W  #$7,D4
    MULU    #6,D4
        
    ;isolate source register
    MOVE.L  D0,D5
    ANDI.W  #$7,D5
    
    JSR    EA_JMP_HELPER
    MOVE.B  #',',(A2)+                      ;add ',' to buffer  
    
    ;isolate destination mode
    MOVE.L  D0,D4
    LSR.W   #6,D4
    ANDI.W  #$7,D4
    MULU    #6,D4
    
    ;isolate destination register 
    MOVE.L  D0,D5
    LSR.W   #4,D5
    LSR.W   #5,D5                           
    ANDI.W  #$7,D5   
    JSR     EA_JMP_HELPER

    JMP     EA_FINISH
    

EA_MOVEA:
    MOVE.B  #$09, (A2)+                     ;adds a ' ' to buffer
    LEA     EA_MODE_TABLE,A0                ;load table

    ;source mode are bits 3,4,5   |         ;source register are bits 0,1,2
    
    ;isolate source mode
    MOVE.L  D0,D4
    LSR.W   #3,D4
    ANDI.W  #$7,D4
    MULU    #6,D4
        
    ;isolate source register
    MOVE.L  D0,D5
    ANDI.W  #$7,D5
    
    JSR    EA_JMP_HELPER
    MOVE.B  #',',(A2)+                      ;add ',' to buffer
    
    ;isolate destination mode --> SHOULD ALWAYS BE 001 AND GO TO ADDRESS REGISTER
    MOVE.L  D0,D4
    LSR.W   #6,D4
    ANDI.W  #$7,D4
    MULU    #6,D4
    
    ;isolate destination register 
    MOVE.L  D0,D5
    LSR.W   #4,D5
    LSR.W   #5,D5                           ;HAVE TO BREAK UP SHIFT
    ANDI.W  #$7,D5   
    JSR     EA_JMP_HELPER

    JMP     EA_FINISH

EA_LEA:
    MOVE.B  #$09, (A2)+                     ;adds a ' ' to buffer
    LEA     EA_MODE_TABLE,A0                ;load table
    
    ;source mode are bits 3,4,5   |         ;source register are bits 0,1,2
    
    ;isolate source mode
    MOVE.L  D0,D4
    LSR.W   #3,D4
    ANDI.W  #$7,D4
    MULU    #6,D4
        
    ;isolate source register
    MOVE.L  D0,D5
    ANDI.W  #$7,D5
    
    JSR    EA_JMP_HELPER
    MOVE.B  #',',(A2)+                      ;add ',' to buffer
    
    ;isolate destination mode --> SHOULD ALWAYS BE 001 AND GO TO ADDRESS REGISTER
    MOVE.L  #1,D4
    MULU    #6,D4
    
    ;isolate destination register 
    MOVE.L  D0,D5
    LSR.W   #4,D5
    LSR.W   #5,D5                       ;HAVE TO BREAK UP SHIFT
    ANDI.W  #$7,D5   
    JSR     EA_JMP_HELPER

    JMP     EA_FINISH

EA_DESTONLY:        ;JMP, CLR   
    JMP     EA_UNSUPPORTED_TYPE


EA_EXT:
    JMP     EA_UNSUPPORTED_TYPE


EA_MOVEM:
    MOVE.B  #$09, (A2)+                     ;adds a ' ' to buffer
    LEA     EA_MODE_TABLE,A0                ;load table
    
    MOVE.L  D0,D1                           ;
    MOVE.W  (A5)+,D2                        ;come back and verify D2 is free!!!!!
    
    ;D1 = 4890 | D2 = 0080 (source)
    
    ;if direction (bit 10) == 0, destination is in opcode, source is in the second operand
    ;if direction (bit 10) == 1, the source is in the opcode, destination is in the operand
    
    ;check direction (bit 10)
    ANDI.W  #nibble2,D1
    LSR.W   #5,D1
    LSR.W   #5,D1                           ;total of 10 shifts
    ANDI.W  #1,D1
    CMP.B   #0,D1
    BEQ     EA_MOVEM_REG_TO_MEM
    CMP.B   #1,D1
    BEQ     EA_MOVEM_MEM_TO_REG
    
    
;MOVEM.W    D/A2,(A7)    
EA_MOVEM_REG_TO_MEM:                        ;bit 10 == 0
    ;check if data register or address register
    CLR     D6
    MOVE.W  D2,D6
    ANDI.W  #$FF00,D6                       ;isolate nibble 1 and 2
    CMP.W   #0,D6                           ;check if 0
    BEQ     EA_MOVEM_DATAREG_TO_MEM         ;if 0, source is data register
    
    MOVE.W  D2,D6
    ANDI.W  #$00FF,D6
    CMP.W   #0,D6
    BEQ     EA_MOVEM_ADDRREG_TO_MEM         ;else it is address register
    
    
    ;else, both are populated and we need to handle mixture
    
    MOVE.L  D2,D6
    CLR     D7
    
    ANDI.W  #$00FF,D6
    MOVE.B  #0,D7
    CLR     D5
    CLR     D3
    CLR     D1
    BSR     MOVEM_LOOP
    
    MOVE.B  #'D',(A2)+
    ADDI.B  #$30,D3
    MOVE.B  D3,(A2)+
    
    
    ADDI.B  #$30,D5
    CLR     D1
    MOVE.W  #0,D1
    
    JSR MOVEM_CHECK_MULTIPLE
    
    MOVE.B  #'/',(A2)+
    
    MOVE.L  D2,D6
    CLR D7
    
    ANDI.W  #$FF00,D6
    LSR.W   #8,D6
    MOVE.B  #0,D7
    CLR     D5
    CLR     D3
    CLR     D1
    MOVE.B  #'A',(A2)+
    
    BSR     MOVEM_LOOP
    
    ADDI.B  #$30,D3
    MOVE.B  D3,(A2)+
    
    ADDI.B  #$30,D5
    CLR     D1
    MOVE.W  #1,D1
    
    JSR MOVEM_CHECK_MULTIPLE
    
    
    ;handle second part now
    
    MOVE.B  #',',(A2)+                          ;add ',' to buffer

    LEA     EA_MODE_TABLE,A0                    ;load table
    
    ;isolate source mode
    MOVE.L  D0,D4
    LSR.W   #3,D4   
    ANDI.W  #$7,D4
    
    ;check for mode 111 -> immediate data
    CMP.W   #$7,D4
    ;if immediate data, leave and get immediate data rather than another register
    BEQ     EA_MOVEM_IMMEDIATE_DESTINATION     
    
    MULU    #6,D4
     
    ;isolate source register
    MOVE.L  D0,D5
    ANDI.W  #$7,D5
    
    JSR    EA_JMP_HELPER
    JMP     EA_FINISH

EA_MOVEM_DATAREG_TO_MEM:    
    MOVE.L  D2,D6                               ;replenish D6 with stuff
    CLR     D7
    
    MOVE.B  #0,D7
    CLR D5
    CLR D3
    CLR D1
    
    MOVE.B  #'D',(A2)+                          ;add 'D' to buffer
    BSR     MOVEM_LOOP                          ;enter loop to get number

    ;convert d3 to ascii and add to buffer
    ADDI.B  #$30,D3                             ;convert to ASCII
    MOVE.B  D3,(A2)+                            ;put on buffer

    ;check d5 and handle
    ADDI.B  #$30,D5
    
    CLR     D1
    MOVE.W  #0,D1                               ;FLAG TO INDICATE D
    
    JSR     MOVEM_CHECK_MULTIPLE
    
    MOVE.B  #',',(A2)+                          ;add ',' to buffer

    LEA     EA_MODE_TABLE,A0                    ;load table
    
    ;isolate source mode
    MOVE.L  D0,D4
    LSR.W   #3,D4   
    ANDI.W  #$7,D4
    
    ;check for mode 111 -> immediate data
    CMP.W   #$7,D4
    ;if immediate data, leave and get immediate data rather than another register
    BEQ     EA_MOVEM_IMMEDIATE_DESTINATION     
    
    MULU    #6,D4
     
    ;isolate source register
    MOVE.L  D0,D5
    ANDI.W  #$7,D5
    
    JSR    EA_JMP_HELPER
    JMP     EA_FINISH


    
MOVEM_CHECK_MULTIPLE:
    CMP     D3,D5
    BNE     MOVEM_MULTIPLE
    RTS
    
MOVEM_MULTIPLE:
    MOVE.B  #'-',(A2)+                          ;add '-' to buffer
    ;CHECK D1 FOR A OR D
    CMP.W   #0,D1                               ;check if 0 --> D
    BEQ     MOVEM_MULTIPLE_D
    CMP.W   #1,D1
    BEQ     MOVEM_MULTIPLE_A

    RTS

MOVEM_MULTIPLE_D:
    MOVE.B  #'D',(A2)+                          ;add 'D' to buffer
    MOVE.B  D5,(A2)+                            ;put on buffer
    RTS

MOVEM_MULTIPLE_A:
    MOVE.B  #'A',(A2)+                          ;add 'D' to buffer
    MOVE.B  D5,(A2)+                            ;put on buffer
    RTS

EA_MOVEM_ADDRREG_TO_MEM:
    MOVE.L  D2,D6                               ;replenish D6 with stuff
    CLR     D7
    
    MOVE.B  #0,D7
    CLR D5
    CLR D3
    CLR D1
    
    MOVE.B  #'A',(A2)+                          ;add 'A' to buffer
    LSR.W   #8,D6                               ;shift 8 times
    BSR     MOVEM_LOOP                          ;enter loop to get number
    
    ;convert d3 to ascii and add to buffer
    ADDI.B  #$30,D3                             ;convert to ASCII
    MOVE.B  D3,(A2)+                            ;put on buffer
    
    ADDI.B  #$30,D5
    
    CLR     D1
    MOVE.W  #1,D1                               ;FLAG TO INDICATE A
    
    JSR MOVEM_CHECK_MULTIPLE
    
    MOVE.B  #',',(A2)+                          ;add ',' to buffer
    
    LEA     EA_MODE_TABLE,A0                    ;load table
    
    ;isolate source mode
    MOVE.L  D0,D4
    LSR.W   #3,D4
    ANDI.W  #$7,D4
    MULU    #6,D4
        
    ;isolate source register
    MOVE.L  D0,D5
    ANDI.W  #$7,D5
    
    JSR    EA_JMP_HELPER
    JMP     EA_FINISH

;MOVEM.W (A7),D/A2
EA_MOVEM_MEM_TO_REG:                            ;bit 10 == 1
    LEA     EA_MODE_TABLE,A0                    ;load table
    
    ;isolate source mode
    MOVE.L  D0,D4
    LSR.W   #3,D4
    ANDI.W  #$7,D4

    ;check for mode 111 -> immediate data
    CMP.W   #$7,D4
    ;if immediate data, leave and get immediate data rather than another register
    BEQ     EA_MOVEM_IMMEDIATE_SOURCE

    MULU    #6,D4
        
    ;isolate source register
    MOVE.L  D0,D5
    ANDI.W  #$7,D5

    JSR    EA_JMP_HELPER
    MOVE.B  #',',(A2)+                          ;add ',' to buffer
    
    ;our operand is in D2
    CLR     D6
    MOVE.W  D2,D6
    ANDI.W  #$FF00,D6                           ;isolate nibble 1 and 2
    CMP.W   #0,D6                               ;check if 0
    BEQ     EA_MOVEM_MEM_TO_DATAREG             ;if 0, source is data register
    
    MOVE.W  D2,D6
    ANDI.W  #$00FF,D6 
    CMP.W   #0,D6
    BEQ     EA_MOVEM_MEM_TO_ADDRREG             ;else it is address register

    ;else, both are populated and we need to handle mixture (D7/A5)
    MOVE.L  D2,D6                               ;replenish D6 with stuff
    CLR     D7

    ANDI.W  #$00FF,D6                           ;work on first half
    MOVE.B  #0,D7
    CLR D5
    CLR D3
    CLR D1
    MOVE.B  #'D',(A2)+                          ;add 'D' to buffer
    BSR     MOVEM_LOOP                          ;enter loop to get number
    ;convert d7 to ascii and add to buffer
    ADDI.B  #$30,D3                             ;convert to ASCII
    MOVE.B  D3,(A2)+                            ;put on buffer
    ;check multiple
    ADDI.B  #$30,D5
    CLR     D1
    MOVE.W  #0,D1                               ;FLAG TO INDICATE D
    
    JSR MOVEM_CHECK_MULTIPLE

    MOVE.B  #'/',(A2)+                          ;add '/' to buffer

    MOVE.L  D2,D6                               ;replenish D6 with stuff
    CLR     D7

    ANDI.W  #$FF00,D6                           ;work on FIRST half
    LSR.W   #8,D6                               ;shift 8 times
    MOVE.B  #0,D7
    CLR D5
    CLR D3
    CLR D1
    MOVE.B  #'A',(A2)+                          ;add 'A' to buffer
    BSR     MOVEM_LOOP                          ;enter loop to get number
    ;convert d7 to ascii and add to buffer
    ADDI.B  #$30,D3                             ;convert to ASCII
    MOVE.B  D3,(A2)+                            ;put on buffer
    ;check multiple
    ADDI.B  #$30,D5
    CLR     D1
    MOVE.W  #1,D1                               ;FLAG TO INDICATE A
    
    JSR MOVEM_CHECK_MULTIPLE

    JMP     EA_FINISH    
        
EA_MOVEM_MEM_TO_DATAREG: 
    MOVE.L  D2,D6                               ;replenish D6 with stuff
    CLR     D7
    
    MOVE.B  #0,D7
    CLR D5
    CLR D3
    CLR D1
    
    MOVE.B  #'D',(A2)+                          ;add 'D' to buffer
    BSR     MOVEM_LOOP                          ;enter loop to get number
    
    ;convert d7 to ascii and add to buffer
    ADDI.B  #$30,D3                             ;convert to ASCII
    MOVE.B  D3,(A2)+                            ;put on buffer

    ;check multiple
    ADDI.B  #$30,D5
    
    CLR     D1
    MOVE.W  #0,D1                               ;FLAG TO INDICATE D
    
    JSR MOVEM_CHECK_MULTIPLE

    JMP     EA_FINISH
   
EA_MOVEM_MEM_TO_ADDRREG:
    MOVE.L  D2,D6                               ;replenish D6 with stuff
    CLR     D7  
    
    MOVE.B  #0,D7
    CLR D5
    CLR D3
    CLR D1
       
    MOVE.B  #'A',(A2)+                          ;add 'A' to buffer
    LSR.W   #8,D6                               ;shift 8 times
    BSR     MOVEM_LOOP                          ;enter loop to get number
    
    ;convert d7 to ascii and add to buffer
    ADDI.B  #$30,D3                             ;convert to ASCII
    MOVE.B  D3,(A2)+                            ;put on buffer

    ;check multiple   
    ADDI.B  #$30,D5 
    CLR     D1
    MOVE.W  #1,D1                               ;FLAG TO INDICATE A
    
    JSR MOVEM_CHECK_MULTIPLE

    JMP     EA_FINISH

MOVEM_LOOP  
    ;D1 = min_set_flag (0 = not set, 1 = set) | D3 = MIN | D5 = MAX | D7 = COUNTER (STARTS AT 0)
    ;D6 = OUR SECOND OPERAND
     
    LSR.W   #1,D6               ;1000
    BCS     MOVEM_CARRY
    ADDI.W  #1,D7
    CMP     #8,D7
    BLE     MOVEM_LOOP
    RTS

MOVEM_CARRY:
    CMP         #0,D1
    BEQ         MOVEM_SET_MIN
    
    MOVE.W      D7,D5
    ADDI.W      #1,D7  
    JMP         MOVEM_LOOP

MOVEM_SET_MIN:
    MOVE.W      D7,D3           ;set min
    MOVE.W      D7,D5           ;set max
    MOVE.W      #1,D1           ;set flag
    ADDI.W      #1,D7  
    JMP         MOVEM_LOOP



EA_MOVEM_IMMEDIATE_DESTINATION:
    ;GET NEXT WORD VALUE AT A5 AND INCREMENT
    MOVE.W  (A5),D7                             ;immediate value is in D7 now
    MOVE.B  #'$',(A2)+                          ;add '$' to buffer
    
    ;convert to ascii and put on buffer
    JSR     EA_ITOA_WORD

    JMP     EA_FINISH

EA_MOVEM_IMMEDIATE_SOURCE:
    ;GET NEXT WORD VALUE AT A5 AND INCREMENT
    MOVE.W  (A5),D7                             ;immediate value is in D7 now
    MOVE.B  #'$',(A2)+                          ;add '$' to buffer
    
    ;convert to ascii and put on buffer
    JSR     EA_ITOA_WORD

    MOVE.B  #',',(A2)+                          ;add ',' to buffer
    
    ;our operand is in D2
    CLR     D6
    MOVE.W  D2,D6
    ANDI.W  #$FF00,D6                           ;isolate nibble 1 and 2
    CMP.W   #0,D6                               ;check if 0
    BEQ     EA_MOVEM_MEM_TO_DATAREG             ;if 0, source is data register
    BRA     EA_MOVEM_MEM_TO_ADDRREG             ;else it is address register

EA_TRAP:
    JMP     EA_UNSUPPORTED_TYPE

EA_QUICK:
    ;ADDQ/SUBQ  -->  opcode = 0101 (stored in D0)
    ;MOVEQ      -->  opcode = 0111 (stored in D0)
    MOVE.B  #$09, (A2)+                         ;adds a ' ' to buffer
    MOVE.B  #'#',(A2)+                          ;add a # to buffer
    MOVE.B  #'$',(A2)+                          ;add a $ to buffer
    
    MOVE.L  D0,D1                               ;should move into D1
    
    ;check for MOVEQ
    LSR.W   #right6,D1
    LSR.W   #right6,D1  
    CMP.W   #$7,D1
    BEQ     EA_QUICK_MOVEQ
    
    CLR     D1                                  ;else not MOVEQ, reset D1 and continue with ADDQ / SUBQ
    MOVE.L  D0,D1
    ANDI.W  #dest_reg,D1                        ;isolate destination register(11,10,9)
    LSR.W   #right8,D1                          ;shift 8 times
    LSR.W   #right1,D1                          ;shift 1 time for total of 9 times
    
    ;at this point we have our number, so convert to ASCII and put on buffer
    ADDI.B  #$30,D1                             ;convert to ASCII
    MOVE.B  D1,(A2)+                            ;put on buffer
    
    
    ;ready for destination address
    MOVE.B  #',',(A2)+                          ;add ',' to buffer  
    LEA     EA_MODE_TABLE,A0                    ;load table
    
    
    ;isolate source mode
    MOVE.L  D0,D4
    LSR.W   #3,D4
    ANDI.W  #$7,D4
    MULU    #6,D4
        
    ;isolate source register
    MOVE.L  D0,D5
    ANDI.W  #$7,D5
    
    JSR    EA_JMP_HELPER
    
    JMP     EA_FINISH

EA_QUICK_MOVEQ:
    MOVE.L  D0,D1
    ANDI.W  #$00FF,D1                   ;isolate bits 7-0
    
    ;our bits are isolated in D1, move to D7 for ITOA function
    MOVE.L  D1,D7
    JSR     EA_ITOA_BYTE_CONVERT
    
    MOVE.B  #',',(A2)+                  ;add ',' to buffer
    MOVE.B  #'D',(A2)+                  ;add ',' to buffer
    MOVE.L  D0,D1
    ANDI.W  #nibble2,D1
    LSR.W   #8,D1
    LSR.W   #1,D1
    
    ;at this point we have our number, so convert to ASCII and put on buffer
    ADDI.B  #$30,D1                     ;convert to ASCII
    MOVE.B  D1,(A2)+                    ;put on buffer

    JMP     EA_FINISH

EA_BRANCH:
    ;PROGRAM COUNTER @ A5
    ;BRA or BSR
    ;displacement bits are 7-0 
    MOVE.L  D0,D1
    ANDI.W  #$00FF,D1                   ;isolate bits 7-0
    ;PERFORM CHECKS 0000 0000 = WORD VALUE, 1111 1111 = LONG VALUE
    
    CMP.B   #$00,D1
    BEQ     EA_BRANCH_16
    
    ;if not 0
    CMP.B   #$FF,D1
    BEQ     EA_BRANCH_32
    
    ;OTHERWISE... HANDLE 8-BITDISPLACEMENT IN OPCODE!    
    MOVE.L  D0,D1
    ANDI.W  #$00FF,D1    
    BRA     EA_BRANCH_8_BIT_DISPLACEMENT
    

EA_BRANCH_8_BIT_DISPLACEMENT:
    ;D0,D1 HAVE OPCODE
    LSR     #7,D1
    
    CMP.B   #0,D1
    BEQ     EA_BRANCH_POSITIVE              ;bit = 0
    BRA     EA_BRANCH_NEGATIVE              ;bit = 1

EA_BRANCH_POSITIVE:
    MOVE.L  D0,D1
    
    ANDI.W  #$00FF,D1                       ;isolate displacement
    MOVE.W  A5,D7                           ;current address    
    ADD     D1,D7                           ;add    
    MOVE.B  #$09, (A2)+                     ;adds a ' ' to buffer
    
    JSR     EA_BRANCH_ITOA_HELPER
    JMP     EA_FINISH

EA_BRANCH_NEGATIVE:
    MOVE.L  D0,D1
    ANDI.W  #$00FF,D1
    NEG.B   D1  
    
    MOVE.W  A5,D7
    SUB     D1,D7

    MOVE.B  #$09, (A2)+                     ;adds a ' ' to buffer

    JSR     EA_BRANCH_ITOA_HELPER
    JMP     EA_FINISH

EA_BRANCH_ITOA_HELPER:
    MOVE.L  D7,D2                           ;PRESERVE COPY
    LSR.W   #right8,D7
    LSR.W   #right8,D7
    LSR.W   #right8,D7
    JSR     EA_ITOA_BYTE_CONVERT

    MOVE.L  D2,D7
    LSR.W   #right8,D7
    LSR.W   #right8,D7    
    JSR     EA_ITOA_BYTE_CONVERT

    MOVE.L  D2,D7
    LSR.W   #right8,D7
    JSR     EA_ITOA_BYTE_CONVERT

    MOVE.L  D2,D7
    JSR     EA_ITOA_BYTE_CONVERT

    JMP     EA_ITOA_DONE

EA_BRANCH_16:
    MOVE.W  (A5),D1 
    MOVE.W  D1,D7
    ADD.W   A5,D7
    
    MOVE.B  #$09, (A2)+                             ;adds a ' ' to buffer
    MOVE.B  #'$',(A2)+                              ;add '$' to buffer
    
    ;convert to ASCII and put on buffer
    ;D7 HAS DISPLACEMENT   
    JSR     BRANCH_16_ITOA
    
    JMP     EA_FINISH

EA_BRANCH_32:
    ;come back and implement branch 32



BRANCH_16_ITOA:
    ;D7 HAS OUR DISPLACEMENT... CONVERT TO ASCII!   
    LSR.W   #right8,D7                             
    JSR     EA_ITOA_BYTE_CONVERT                    
    MOVE.W  (A5)+,D7                               
    ADD.W   A5,D7                                 
    SUBI.B  #2,D7                                   ;SUBI 2 to account for post increment of A5
    ANDI.W  #$00FF,D7                              
    JSR     EA_ITOA_BYTE_CONVERT          
    
    JMP     EA_ITOA_DONE


EA_MATH:
    ;source mode 3, 4, 5 | source register 0, 1, 2 | destination register 11, 10, 9
    MOVE.B  #$09, (A2)+                             ;add a ' ' to buffer
    LEA     EA_MODE_TABLE,A0                        ;load mode table
    
    ;isolate source mode
    MOVE.L  D0,D4
    LSR.W   #3,D4
    ANDI.W  #$7,D4
    MULU    #6,D4
    
    ;isolate source register
    MOVE.L  D0,D5
    ANDI.W  #$7,D5
    
    JSR     EA_JMP_HELPER
    
    MOVE.B  #',',(A2)+                              ;add a ',' to buffer
    
    ;condition for ADDA - opcode == 1101 && bits 7,6 == 11
    ;check for ADDA and leave if yes, otherwise continue
    MOVE.L  D0,D1                                   ;complete opcode in D1
    LSR.W   #6,D1                                   ;shift right 6
    LSR.W   #6,D1                                   ;shift another 6 to = 12 total
    
    CMP     #$D,D1                                  ;check if opcode = 1101
    BNE     EA_MATH_CONTINUE                        ;if not 1101, skip and go to math
    
    ;if we are here, we know opcode is 1101 and further check
    MOVE.L  D0,D1
    LSR.W   #6,D1
    ANDI.W  #3,D1
    CMP.B   #3,D1
    BNE     EA_MATH_CONTINUE
    
    ;if d1 == 3, both conditions met so process as ADDA
    ;destination mode is 1 (address register)
    MOVE.L  #1,D4
    MULU    #6,D4
    
    ;isolate destination register 
    MOVE.L  D0,D5
    LSR.W   #4,D5
    LSR.W   #5,D5                      
    ANDI.W  #$7,D5   
 
    JSR     EA_JMP_HELPER 
    JMP     EA_FINISH
        
EA_MATH_CONTINUE:       
    ;destination mode is 0 (data register)
    MOVE.L  #0,D4
    MULU    #6,D4
    
    ;isolate destination register 
    MOVE.L  D0,D5
    LSR.W   #4,D5
    LSR.W   #5,D5                      
    ANDI.W  #$7,D5  
    
    JSR     EA_JMP_HELPER 
    JMP     EA_FINISH
    

EA_ROTATION:
    MOVE.B  #$09, (A2)+                             ;adds a ' ' to buffer
    MOVE.L  D0,D1                                   ;complete opcode
    
    ANDI.W  #$00FF,D1
    LSR.W   #6,D1
    CMP     #3,D1
    BEQ     EA_ROTATION_MODE_7
    
    MOVE.L  D0,D1
    LSR.W   #5,D1                                   ;shift right 5
    ANDI.W  #1,D1
    
    CMP     #0,D1
    BEQ     EA_ROTATION_IMMEDIATE                   ;it is immediate value
    BRA     EA_ROTATION_REGISTER                    ;else register 
    
EA_ROTATION_MODE_7:
    ;WE KNOW IT IS MODE 7 - CHECK FOR IMMEDIATE SHORT OR IMMEDIATE LONG
    MOVE.L  D0,D1
    ANDI.W  #7,D1
    CMP.W   #0,D1   
    BEQ     EA_111_ABSOLUTE_SHORT_HELPER
    JSR     EA_111_ABSOLUTE_LONG   
    JMP     EA_FINISH

EA_111_ABSOLUTE_SHORT_HELPER:
    JSR     EA_111_ABSOLUTE_SHORT
    JMP     EA_FINISH

EA_ROTATION_CONTINUE:
    MOVE.L  D0,D1                                   ;get rotation value
    ANDI.W  #nibble2,D1                             ;isolate nibble 2
    LSR.W   #8,D1
    LSR.W   #1,D1                                   ;total of 9 shifts right
    
    ;at this point we have our number, so convert to ASCII and put on buffer
    ADDI.B  #$30,D1                                 ;convert to ASCII
    MOVE.B  D1,(A2)+                                ;put on buffer
    
    MOVE.B  #',',(A2)+                              ;add ',' to buffer 
    MOVE.B  #'D',(A2)+                              ;add 'D' to buffer
    
    MOVE.L  D0,D1                                   ;complete opcode
    ANDI.W  #7,D1                       
    
    ADDI.B  #$30,D1                                 ;convert to ASCII
    MOVE.B  D1,(A2)+                                ;put on buffer
    
    JMP     EA_FINISH                       

EA_ROTATION_IMMEDIATE:
    MOVE.B  #'#',(A2)+                              ;add '#' to buffer
    BRA     EA_ROTATION_CONTINUE
    
EA_ROTATION_REGISTER:
    MOVE.B  #'D',(A2)+                              ;add 'D' to buffer
    BRA     EA_ROTATION_CONTINUE
    
EA_JMP_HELPER
    JMP     0(A0,D4)

EA_UNSUPPORTED_TYPE:
    ;print error message
    MOVE.B  #14,D0
    LEA     unsupported_ea_type,A1
    TRAP    #15
    
    ;return to start of program
    JMP     GET_STARTING_ADDRESS


;********************************************  EA_MODE_TABLE  ****************************************************  
EA_MODE_TABLE:
    JMP     EA_MODE_000
    JMP     EA_MODE_001
    JMP     EA_MODE_010
    JMP     EA_MODE_011
    JMP     EA_MODE_100
    JMP     EA_MODE_101
    JMP     EA_MODE_110
    JMP     EA_MODE_111
    ;JMP     EA_MODE_FINISH

;********************************************  EA_MODE_XXX  ****************************************************    
EA_MODE_000:                                        ;Data register 'Dn'
    MOVE.B  #'D',(A2)+                              ;put D on buffer
    MOVE.B D5,D3                                    ;move to d3 for conversion
    JSR     EA_HEX_TO_ASCII                         ;puts register on buffer  
    RTS
    
EA_MODE_001:                                        ;Address Register 'An'
    MOVE.B  #'A',(A2)+                              ;put A on buffer
    MOVE.B  D5,D3                                   ;move to d3 for conversion
    JSR     EA_HEX_TO_ASCII                         ;puts register on buffer  
    RTS

EA_MODE_010:                                        ;Address direct --> '(An)'
    MOVE.B  #'(',(A2)+                              ;put ( on buffer
    MOVE.B  #'A',(A2)+                              ;put A on buffer
    MOVE.B  D5,D3                                   ;move to D3 for conversion
    JSR     EA_HEX_TO_ASCII                         ;convert and put on buffer   
    MOVE.B  #')',(A2)+                              ;put ) on buffer
    RTS

EA_MODE_011:                                        ;Address with Postincrement --> '(An)+' 
    MOVE.B  #'(',(A2)+                              ;put ( on buffer
    MOVE.B  #'A',(A2)+                              ;put A on buffer
    MOVE.B  D5,D3                                   ;move to D3 for conversion
    JSR     EA_HEX_TO_ASCII                         ;convert and put on buffer   
    MOVE.B  #')',(A2)+                              ;put ) on buffer
    MOVE.B  #'+',(A2)+                              ;put + on buffer
    RTS

EA_MODE_100:                                        ;Address with Predecrement --> '-(An)'
    MOVE.B  #'-',(A2)+                              ;put - on buffer
    MOVE.B  #'(',(A2)+                              ;put ( on buffer
    MOVE.B  #'A',(A2)+                              ;put A on buffer
    MOVE.B  D5,D3                                   ;move to D3 for conversion
    JSR     EA_HEX_TO_ASCII                         ;convert and put on buffer   
    MOVE.B  #')',(A2)+                              ;put ) on buffer
    RTS

;unsupported --> ;Address with Displacement --> '(d16, An)
EA_MODE_101:                                        
    MOVE.B  #14,D0
    LEA     unsupported_ea_mode_message,A1
    TRAP    #15    
    JMP     GET_STARTING_ADDRESS

;unsupported --> ;unsupported_ea_mode_message
EA_MODE_110:
    MOVE.B  #14,D0
    LEA     unsupported_ea_mode_message,A1
    TRAP    #15
    JMP     GET_STARTING_ADDRESS

;some form of immediate data: short, long, immediate
EA_MODE_111:
    ;D4 = MODE | D5 = register (000, 001, 100)
    ;000 = Absolute Short (xxx).w
    ;001 = Absolute Long (xxx).l
    ;100 = Immediate data
    
    CMP.B   #000,D5
    BEQ     EA_111_ABSOLUTE_SHORT
    CMP.B   #001,D5
    BEQ     EA_111_ABSOLUTE_LONG
    CMP.B   #$4,D5
    BEQ     EA_111_IMMEDIATE
    
    ;ELSE, HANDLE ERROR
    MOVE.B  #14,D0
    LEA     unsupported_ea_register_message,A1
    TRAP    #15
    JMP     GET_STARTING_ADDRESS
            
    
EA_111_ABSOLUTE_SHORT:
    ;A5 is looking at correct spot
    ;ADD WORD VALUE AT A5 ON TO BUFFER AT A2 AND INCREMENT BY WORD
    MOVE.B  #'$',(A2)+                              ;put $ on buffer
    MOVE.W  (A5),D7
    CLR     D6
    MOVE.B  #01,D6                                  ;word size in EA_ITOA_IMMEDIATE
    JSR     EA_ITOA_IMMEDIATE
    RTS

EA_111_ABSOLUTE_LONG:
    MOVE.B  #'$',(A2)+                              ;put $ on buffer
    MOVE.W  (A5),D7
    CLR     D6
    MOVE.B  #02,D6                                  ;long size in EA_ITOA_IMMEDIATE        
    JSR     EA_ITOA_IMMEDIATE
    RTS

EA_111_IMMEDIATE:
    MOVE.B  #'#',(A2)+                              ;put $ on buffer
    MOVE.B  #'$',(A2)+                              ;put $ on buffer
    
    MOVE.L  D0,D1
    ANDI.W  #$F000,D1
    LSR.W   #6,D1
    LSR.W   #6,D1                                   ;total of 12 times
    
    
    ;check size and branch accordingly
    MOVE.W  D1,D6
    MOVE.W  (A5),D7
    JSR EA_ITOA_IMMEDIATE
    
    JMP EA_FINISH
   
    

EA_HEX_TO_ASCII:
    ADDI.B      #$30,D3                             ;add $30 to D1 to convert
    MOVE.B      D3,(A2)+                            ;add to buffer and increment to next position
    RTS     


EA_CHECK_SIZE:
    CLR     D6
    MOVE.L  D0,D6                                   ;complete opcode --> D6
    ANDI.W  #nibble3,D6                             ;isolating nibble 3
    LSR.W   #right6,D6                              ;shifting bits 7,6 --> 1,0
    
    CMP     #00,D6
    BEQ     EA_SIZE_BYTE
    CMP     #01,D6
    BEQ     EA_SIZE_WORD
    BRA     EA_SIZE_LONG

EA_SIZE_BYTE:
    MOVE.W  (A5)+,D7
    RTS

EA_SIZE_WORD:
    MOVE.W  (A5),D7
    RTS

EA_SIZE_LONG:
    MOVE.W  (A5),D7
    RTS


EA_ITOA_IMMEDIATE:
    ;D3 = counter, D7 = value to be converted, D6 = size
    CMP.B   #%00,D6
    BEQ     EA_ITOA_BYTE
    CMP.B   #%01,D6
    BEQ     EA_ITOA_WORD
    CMP.B   #%10,D6     
    BEQ     EA_ITOA_LONG
    
EA_ITOA_BYTE:
    JSR     EA_ITOA_BYTE_CONVERT
    JMP     EA_ITOA_DONE

EA_ITOA_WORD:
    LSR.W   #right8,D7
    JSR     EA_ITOA_BYTE_CONVERT
    MOVE.W  (A5)+,D7
    JSR     EA_ITOA_BYTE_CONVERT
    
    JMP     EA_ITOA_DONE
    
EA_ITOA_LONG:
    LSR.W   #right8,D7
    JSR     EA_ITOA_BYTE_CONVERT
    MOVE.W  (A5)+,D7
    JSR     EA_ITOA_BYTE_CONVERT

    MOVE.W  (A5),D7
    LSR.W   #right8,D7
    JSR     EA_ITOA_BYTE_CONVERT
    MOVE.W  (A5)+,D7
    JSR     EA_ITOA_BYTE_CONVERT

    JMP     EA_ITOA_DONE

EA_ITOA_BYTE_CONVERT:
    MOVE.W  D7,D3
    ANDI.W  #$F0,D3
    LSR.W   #right4,D3
    JSR     EA_ITOA_NIBBLE_CONVERT
    
    MOVE.W  D7,D3
    ANDI.W  #$0F,D3
    JSR     EA_ITOA_NIBBLE_CONVERT
    RTS

EA_ITOA_NIBBLE_CONVERT:
    CMP.B   #9,D3
    BGT     EA_ITOA_LETTER
    BRA     EA_ITOA_NUMBER

EA_ITOA_HEX2ASCII:



EA_ITOA_NUMBER:
    ADDI.B  #$30,D3
    MOVE.B  D3,(A2)+
    RTS

EA_ITOA_LETTER:
    ADDI.B  #$37,D3
    MOVE.B  D3,(A2)+
    RTS

EA_ITOA_DONE
    RTS

    
;****************************************** MESSAGES ***************************************************
welcome_message             DC.B    'Welcome to 68k disassembler',CR,LF,0

get_start_address           DC.B    'Please enter a starting address in hexadecimal',CR,LF,0

get_end_address             DC.B    'Please enter an ending address in hexadecimal',CR,LF,0

atoi_error_invalid          DC.B    'Invalid address, characters must be $0-F',CR,LF,0

error_message_1             DC.B    'Invalid Address: Must be greater than 0',CR,LF,0

error_message_2             DC.B    'Invalid Address: Must be even',CR,LF,0

error_message_3             DC.B    'Invalid Address: Must be even',CR,LF,0

error_message_4             DC.B    'Invalid Address: Must be less than $00FFFFFF',CR,LF,0

error_message_5             DC.B    'Invalid Address: Must be greater than starting address',CR,LF,0

prompt_enter                DC.B    'Hit Enter to Continue',CR,LF,0

prompt_again                DC.B    'Do You Want to Run Program Again with New Memory Locations? Enter Y or N ',CR,LF,0

unsupported_opcode_message  DC.B    'Unsupported Opcode, Restarting Program ',CR,LF,0

invalid_opcode_message      DC.B    'Invalid Opcode, Restarting Program ',CR,LF,0 

wrong_size_message          DC.B     'Wrong Size, Restarting Program ',CR,LF,0 

unsupported_ea_mode_message DC.B    'Unsupported EA Mode, Restarting Program ',CR,LF,0

unsupported_ea_register_message DC.B    'Unsupported EA Register, Restarting Program ',CR,LF,0

unsupported_ea_type          DC.B    'Unsupported EA Type, Restarting Program ',CR,LF,0

invalid_character_message   DC.B    'Invalid Character, Restarting Program ',CR,LF,0
                              

ascii_start:
    DS.w    10          
    
ascii_end:
    DS.w    10         

buffer                  ;storing op code
    DS.W    64          
    
ascii_y_or_n:
    DS.W    8
    

    END    START        ; last line of source
