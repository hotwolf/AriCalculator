#ifndef FCDICT_TREE_COMPILED
#define FCDICT_TREE_COMPILED
;###############################################################################
;# S12CForth - Search Tree for the Core Dictionary                             #
;###############################################################################
;#    Copyright 2009-2016 Dirk Heisswolf                                       #
;#    This file is part of the S12CForth framework for NXP's S12(X) MCU        #
;#    families.                                                                #
;#                                                                             #
;#    S12CForth is free software: you can redistribute it and/or modify        #
;#    it under the terms of the GNU General Public License as published by     #
;#    the Free Software Foundation, either version 3 of the License, or        #
;#    (at your option) any later version.                                      #
;#                                                                             #
;#    S12CForth is distributed in the hope that it will be useful,             #
;#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #
;#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
;#    GNU General Public License for more details.                             #
;#                                                                             #
;#    You should have received a copy of the GNU General Public License        #
;#    along with S12CForth.  If not, see <http://www.gnu.org/licenses/>.       #
;###############################################################################
;# Description:                                                                #
;#    This file contains a search tree for S12CForth CORE dictionary.          #
;#                                                                             #
;###############################################################################
;# Generated on Fri, Nov 18 2016                                               #
;###############################################################################

;###############################################################################
;# Dictionary Tree Structure                                                   #
;###############################################################################
;
; -> ! --------------------------------------> CF_STORE
;    # ---> ---------------------------------> CF_NUMBER_SIGN
;    |      TIB -----------------------------> CF_NUMBER_TIB
;    |      
;    ' --------------------------------------> CF_TICK
;    ( --------------------------------------> CF_PAREN
;    * ---> ---------------------------------> CF_STAR
;    |      / -> ----------------------------> CF_STAR_SLASH
;    |           MOD ------------------------> CF_STAR_SLASH_MOD
;    |      
;    + ---> ---------------------------------> CF_PLUS
;    |      ! -------------------------------> CF_PLUS_STORE
;    |      LOOP ----------------------------> CF_PLUS_LOOP
;    |      
;    , --------------------------------------> CF_COMMA
;    - --------------------------------------> CF_MINUS
;    . ---> ---------------------------------> CF_DOT
;    |      " -------------------------------> CF_DOT_QUOTE
;    |      ( -------------------------------> CF_DOT_PAREN
;    |      R -------------------------------> CF_DOT_R
;    |      S -------------------------------> CF_DOT_S
;    |      
;    / ---> ---------------------------------> CF_SLASH
;    |      MOD -----------------------------> CF_SLASH_MOD
;    |      
;    0 ---> < -> ----------------------------> CF_ZERO_LESS
;    |      |    > --------------------------> CF_ZERO_NOT_EQUALS
;    |      |    
;    |      = -------------------------------> CF_ZERO_EQUALS
;    |      > -------------------------------> CF_ZERO_GREATER
;    |      
;    1 ---> + -------------------------------> CF_ONE_PLUS
;    |      - -------------------------------> CF_ONE_MINUS
;    |      
;    2 ---> ! -------------------------------> CF_TWO_STORE
;    |      * -------------------------------> CF_TWO_STAR
;    |      / -------------------------------> CF_TWO_SLASH
;    |      @ -------------------------------> CF_TWO_FETCH
;    |      D -------> ROP ------------------> CF_TWO_DROP
;    |      |          UP -------------------> CF_TWO_DUP
;    |      |          
;    |      LITERAL -------------------------> CF_2LITERAL
;    |      OVER ----------------------------> CF_TWO_OVER
;    |      ROT -----------------------------> CF_2ROT
;    |      SWAP ----------------------------> CF_TWO_SWAP
;    |      
;    : --------------------------------------> CF_COLON
;    ; --------------------------------------> CF_SEMICOLON
;    < --------------------------------------> CF_LESS_THAN
;    = --------------------------------------> CF_EQUALS
;    > ---> ---------------------------------> CF_GREATER_THAN
;    |      IN -> ---------------------------> CF_TO_IN
;    |      |     T -------------------------> CF_TO_INT
;    |      |     
;    |      R -------------------------------> CF_TO_R
;    |      
;    ?D --> O -------------------------------> CF_QUESTION_DO
;    |      UP ------------------------------> CF_QUESTION_DUP
;    |      
;    @ --------------------------------------> CF_FETCH
;    A ---> B ----> ORT -> ------------------> CF_ABORT
;    |      |       |      " ----------------> CF_ABORT_QUOTE
;    |      |       |      
;    |      |       S -----------------------> CF_ABS
;    |      |       
;    |      GAIN ----------------------------> CF_AGAIN
;    |      L ----> IGN -> ------------------> CF_ALIGN
;    |      |       |      ED ---------------> CF_ALIGNED
;    |      |       |      
;    |      |       LOT ---------------------> CF_ALLOT
;    |      |       
;    |      ND ------------------------------> CF_AND
;    |      
;    B ---> ASE -----------------------------> CF_BASE
;    |      EGIN ----------------------------> CF_BEGIN
;    |      INARY ---------------------------> CF_BINARY
;    |      L -------------------------------> CF_BL
;    |      
;    C ---> ! -------------------------------> CF_C_STORE
;    |      @ -------------------------------> CF_C_FETCH
;    |      A ---> SE -----------------------> CF_CASE
;    |      |      TCH ----------------------> CF_CATCH
;    |      |      
;    |      ELL -> + ------------------------> CF_CELL_PLUS
;    |      |      S ------------------------> CF_CELLS
;    |      |      
;    |      HAR -> + ------------------------> CF_CHAR_PLUS
;    |      |      S ------------------------> CF_CHARS
;    |      |      
;    |      LS ------------------------------> CF_CLS
;    |      O ---> MPILE, -------------------> CF_COMPILE_COMMA
;    |      |      NSTANT -------------------> CF_CONSTANT
;    |      |      UNT ----------------------> CF_COUNT
;    |      |      
;    |      R -------------------------------> CF_CR
;    |      
;    D ---> . ---> --------------------------> CF_D_DOT
;    |      |      R ------------------------> CF_D_DOT_R
;    |      |      
;    |      E ---> CIMAL --------------------> CF_DECIMAL
;    |      |      PTH ----------------------> CF_DEPTH
;    |      |      
;    |      O -------------------------------> CF_DO
;    |      ROP -----------------------------> CF_DROP
;    |      UP ------------------------------> CF_DUP
;    |      
;    E ---> LSE -----------------------------> CF_ELSE
;    |      MIT -----------------------------> CF_EMIT
;    |      N ----> D ----------> CASE ------> CF_ENDCASE
;    |      |       |             OF --------> CF_ENDOF
;    |      |       |             
;    |      |       VIRONMENT? --------------> CF_ENVIRONMENT_QUERY
;    |      |       
;    |      RASE ----------------------------> CF_ERASE
;    |      X ----> ECUTE -------------------> CF_EXECUTE
;    |              PECT --------------------> CF_EXPECT
;    |      
;    F ---> ALSE ----------------------------> CF_FALSE
;    |      ILL -----------------------------> CF_FILL
;    |      
;    HE --> RE ------------------------------> CF_HERE
;    |      X -------------------------------> CF_HEX
;    |      
;    I ---> ---------------------------------> CF_I
;    |      F -------------------------------> CF_IF
;    |      N -> TERPRET --------------------> CF_INTERPRET
;    |           VERT -----------------------> CF_INVERT
;    |      
;    J --------------------------------------> CF_J
;    L ---> EAVE ----------------------------> CF_LEAVE
;    |      ITERAL --------------------------> CF_LITERAL
;    |      OOP -----------------------------> CF_LOOP
;    |      SHIFT ---------------------------> CF_L_SHIFT
;    |      U ------> -----------------------> CF_LU
;    |                - -> CDICT ------------> CF_LU_CDICT
;    |                     NV ----> CBUF ----> CF_LU_NVCBUF
;    |                     |        DICT ----> CF_LU_NVDICT
;    |                     |        
;    |                     UDICT ------------> CF_LU_UDICT
;    |      
;    M ---> * -------------------------------> CF_M_STAR
;    |      AX ------------------------------> CF_MAX
;    |      IN ------------------------------> CF_MIN
;    |      O --> D -------------------------> CF_MOD
;    |            NITOR ---------------------> CF_MONITOR
;    |            VE ------------------------> CF_NEGATE
;    |      
;    N ---> IP ------------------------------> CF_NIP
;    |      OP ------------------------------> CF_NOP
;    |      V{ ------------------------------> CF_NV_OPEN
;    |      
;    O ---> F -------------------------------> CF_OF
;    |      R -------------------------------> CF_OR
;    |      VER -----------------------------> CF_OVER
;    |      
;    P ---> ARSE ----------------------------> CF_PARSE
;    |      ICK -----------------------------> CF_PICK
;    |      ROMPT ---------------------------> CF_PROMPT
;    |      
;    QU --> ERY -----------------------------> CF_QUERY
;    |      IT ------------------------------> CF_QUIT
;    |      
;    R ---> EPEAT ---------------------------> CF_REPEAT
;    |      O -----> LL ---------------------> CF_ROLL
;    |      |        T ----------------------> CF_ROT
;    |      |        
;    |      SHIFT ---------------------------> CF_R_SHIFT
;    |      TERR. ---------------------------> CF_RTERR_DOT
;    |      
;    S ---> , -------------------------------> CF_STRING_COMMA
;    |      . -------------------------------> CF_STRING_DOT
;    |      >D ------------------------------> CF_S_TO_D
;    |      KIP&PARSE -----------------------> CF_SKIP_AND_PARSE
;    |      M/REM ---------------------------> CF_S_M_SLASH_REM
;    |      OURCE -----> --------------------> CF_SOURCE
;    |      |            -ID ----------------> CF_SOURCE_ID
;    |      |            
;    |      PA --------> CE -> --------------> CF_SPACE
;    |      |            |     S ------------> CF_SPACES
;    |      |            |     
;    |      |            N ------------------> CF_SPAN
;    |      |            
;    |      TATE ----------------------------> CF_STATE
;    |      WAP -----------------------------> CF_SWAP
;    |      YNERR. --------------------------> CF_SYNERR_DOT
;    |      
;    T ---> H ---> EN -----------------------> CF_THEN
;    |      |      ROW ----------------------> CF_THROW
;    |      |      
;    |      IB ------------------------------> CF_TIB
;    |      RUE -----------------------------> CF_TRUE
;    |      UCK -----------------------------> CF_TUCK
;    |      
;    U ---> . -> ----------------------------> CF_U_DOT
;    |      |    R --------------------------> CF_U_DOT_R
;    |      |    
;    |      < -------------------------------> CF_U_LESS_THAN
;    |      > -------------------------------> CF_U_GREATER_THAN
;    |      M -> * --------------------------> CF_U_M_STAR
;    |      |    /MOD -----------------------> CF_U_M_SLASH_MOD
;    |      |    
;    |      N -> LOOP -----------------------> CF_UNLOOP
;    |           TIL ------------------------> CF_UNTIL
;    |      
;    VA --> LUE -----------------------------> CF_VALUE
;    |      RIABLE --------------------------> CF_VARIABLE
;    |      
;    W ---> HILE ----------------------------> CF_WHILE
;    |      ORDS -> -------------------------> CF_WORDS
;    |              - -> CDICT --------------> CF_WORDS_CDICT
;    |                   NVDICT -------------> CF_WORDS_NVDICT
;    |                   UDICT --------------> CF_WORDS_UDICT
;    |      
;    XOR ------------------------------------> CF_XOR
;    [ --------------------------------------> CF_LEFT_BRACKET
;    \ --------------------------------------> CF_BACKSLASH
;    ] --------------------------------------> CF_RIGHT_BRACKET
;    }NV ------------------------------------> CF_NV_CLOSE

;###############################################################################
;# Constants                                                                   #
;###############################################################################

;Global constants
#ifndef      NULL
NULL                    EQU     
#endif

;Tree depth
FCDICT_TREE_DEPTH       EQU     5

;First CF
FCDICT_FIRST_CF         EQU     CF_STORE

;Character count of the first word
FCDICT_FIRST_CC         EQU     1                               ;"!"

;###############################################################################
;# Macros                                                                      #
;###############################################################################

;Dictionary tree
#macro       FCDICT_TREE, 0
;Local constants
EMPTY_STRING            EQU     $00
BRANCH                  EQU     $00
END_OF_BRANCH           EQU     $00
;Root
FCDICT_TREE             FCS     "!"
                        DW      CF_STORE                        ;-> !
                        DW      CF_WORDS_UDICT                  ;-> WORDS-UDICT
                        DB      END_OF_BRANCH
#emac

;#Set pointer structure to first CDICT entry
; args:   1: address of CDICT root
;         2: index register to address tree entry structure
;         3: offset of tree entry structure
; result: none
; SSTACK: none
;         All registers are preserved
#macro FCDICT_INIT_ITERATOR, 3
                        MOVW #(\1+$00), (\3+$08),\2   ;FCDICT_TREE         ("!")
                        MOVW #NULL,     (\3+$06),\2   ;unused
                        MOVW #NULL,     (\3+$04),\2   ;unused
                        MOVW #NULL,     (\3+$02),\2   ;unused
                        MOVW #NULL,     (\3+$00),\2   ;unused
#emac

#endif 
