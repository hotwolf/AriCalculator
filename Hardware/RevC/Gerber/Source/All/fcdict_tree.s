#ifndef FCDICT_TREE_COMPILED
#define FCDICT_TREE_COMPILED
;###############################################################################
;# S12CForth - Search Tree for the Core Dictionary                             #
;###############################################################################
;#    Copyright 2009-2017 Dirk Heisswolf                                       #
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
;# Generated on Fri, Jan 27 2017                                               #
;###############################################################################

;###############################################################################
;# Dictionary Tree Structure                                                   #
;###############################################################################
;
; -> ! ---------------------------------> CF_STORE
;    # -----> --------------------------> CF_NUMBER_SIGN
;    |        TIB ----------------------> CF_NUMBER_TIB
;    |        
;    ' ---------------------------------> CF_TICK
;    ( ---------------------------------> CF_PAREN
;    * -----> --------------------------> CF_STAR
;    |        / -> ---------------------> CF_STAR_SLASH
;    |             MOD -----------------> CF_STAR_SLASH_MOD
;    |        
;    + -----> --------------------------> CF_PLUS
;    |        ! ------------------------> CF_PLUS_STORE
;    |        LOOP ---------------------> CF_PLUS_LOOP
;    |        
;    , ---------------------------------> CF_COMMA
;    - ---------------------------------> CF_MINUS
;    . -----> --------------------------> CF_DOT
;    |        " ------------------------> CF_DOT_QUOTE
;    |        ( ------------------------> CF_DOT_PAREN
;    |        R ------------------------> CF_DOT_R
;    |        S ------------------------> CF_DOT_S
;    |        
;    / -----> --------------------------> CF_SLASH
;    |        MOD ----------------------> CF_SLASH_MOD
;    |        
;    0 -----> < -> ---------------------> CF_ZERO_LESS
;    |        |    > -------------------> CF_ZERO_NOT_EQUALS
;    |        |    
;    |        = ------------------------> CF_ZERO_EQUALS
;    |        > ------------------------> CF_ZERO_GREATER
;    |        
;    1 -----> + ------------------------> CF_ONE_PLUS
;    |        - ------------------------> CF_ONE_MINUS
;    |        
;    2 -----> ! ------------------------> CF_TWO_STORE
;    |        * ------------------------> CF_TWO_STAR
;    |        / ------------------------> CF_TWO_SLASH
;    |        @ ------------------------> CF_TWO_FETCH
;    |        CONSTANT -----------------> CF_TWO_CONSTANT
;    |        D --------> ROP ----------> CF_TWO_DROP
;    |        |           UP -----------> CF_TWO_DUP
;    |        |           
;    |        LITERAL ------------------> CF_TWO_LITERAL
;    |        OVER ---------------------> CF_TWO_OVER
;    |        ROT ----------------------> CF_2ROT
;    |        SWAP ---------------------> CF_TWO_SWAP
;    |        
;    : ---------------------------------> CF_COLON
;    ; ---------------------------------> CF_SEMICOLON
;    < ---------------------------------> CF_LESS_THAN
;    = ---------------------------------> CF_EQUALS
;    > -----> --------------------------> CF_GREATER_THAN
;    |        IN -> --------------------> CF_TO_IN
;    |        |     T ------------------> CF_TO_INT
;    |        |     
;    |        R ------------------------> CF_TO_R
;    |        
;    ?D ----> O ------------------------> CF_QUESTION_DO
;    |        UP -----------------------> CF_QUESTION_DUP
;    |        
;    @ ---------------------------------> CF_FETCH
;    A -----> B ----> ORT -> -----------> CF_ABORT
;    |        |       |      " ---------> CF_ABORT_QUOTE
;    |        |       |      
;    |        |       S ----------------> CF_ABS
;    |        |       
;    |        HEAD ---------------------> CF_AHEAD
;    |        L ----> IGN -> -----------> CF_ALIGN
;    |        |       |      ED --------> CF_ALIGNED
;    |        |       |      
;    |        |       LOT --------------> CF_ALLOT
;    |        |       
;    |        ND -----------------------> CF_AND
;    |        
;    B -----> ASE ----------------------> CF_BASE
;    |        INARY --------------------> CF_BINARY
;    |        L ------------------------> CF_BL
;    |        
;    C -----> ! ------------------------> CF_C_STORE
;    |        @ ------------------------> CF_C_FETCH
;    |        ATCH ---------------------> CF_CATCH
;    |        ELL --> + ----------------> CF_CELL_PLUS
;    |        |       S ----------------> CF_CELLS
;    |        |       
;    |        HAR --> + ----------------> CF_CHAR_PLUS
;    |        |       S ----------------> CF_CHARS
;    |        |       
;    |        O ----> MPILE, -----------> CF_COMPILE_COMMA
;    |        |       NSTANT -----------> CF_CONSTANT
;    |        |       UNT --------------> CF_COUNT
;    |        |       
;    |        R ----> ------------------> CF_CR
;    |                EATE -------------> CF_CREATE
;    |        
;    D -----> . ------> ----------------> CF_D_DOT
;    |        |         R --------------> CF_D_DOT_R
;    |        |         
;    |        ECIMAL -------------------> CF_DECIMAL
;    |        O ------> ----------------> CF_DO
;    |        |         ES> ------------> CF_DOES
;    |        |         
;    |        ROP ----------------------> CF_DROP
;    |        UP -----------------------> CF_DUP
;    |        
;    E -----> LSE ----------------------> CF_ELSE
;    |        MIT ----------------------> CF_EMIT
;    |        NVIRONMENT? --------------> CF_ENVIRONMENT_QUERY
;    |        RASE ---------------------> CF_ERASE
;    |        X -----------> ECUTE -----> CF_EXECUTE
;    |                       IT --------> CF_EXIT
;    |                       PECT ------> CF_EXPECT
;    |        
;    F -----> ALSE ---------------------> CF_FALSE
;    |        ILL ----------------------> CF_FILL
;    |        
;    HE ----> RE -----------------------> CF_HERE
;    |        X ------------------------> CF_HEX
;    |        
;    I -----> --------------------------> CF_I
;    |        F ------------------------> CF_IF
;    |        N -> TERPRET -------------> CF_INTERPRET
;    |             VERT ----------------> CF_INVERT
;    |        
;    J ---------------------------------> CF_J
;    L -----> EAVE ---------------------> CF_LEAVE
;    |        ITERAL -------------------> CF_LITERAL
;    |        OOP ----------------------> CF_LOOP
;    |        SHIFT --------------------> CF_L_SHIFT
;    |        U ------> ----------------> CF_LU
;    |                  - -> CDICT -----> CF_LU_CDICT
;    |                       NVCBUF ----> CF_LU_NVCBUF
;    |                       UDICT -----> CF_LU_UDICT
;    |        
;    M -----> * ------------------------> CF_M_STAR
;    |        AX -----------------------> CF_MAX
;    |        IN -----------------------> CF_MIN
;    |        O --> D ------------------> CF_MOD
;    |              NITOR --------------> CF_MONITOR
;    |              VE -----------------> CF_MOVE
;    |        
;    N -----> AME, ---------------------> CF_NAME_COMMA
;    |        EGATE --------------------> CF_NEGATE
;    |        IP -----------------------> CF_NIP
;    |        OP -----------------------> CF_NOP
;    |        
;    O -----> R ------------------------> CF_OR
;    |        VER ----------------------> CF_OVER
;    |        
;    P -----> ARSE ---------------------> CF_PARSE
;    |        ICK ----------------------> CF_PICK
;    |        ROMPT --------------------> CF_PROMPT
;    |        
;    QU ----> ERY ----------------------> CF_QUERY
;    |        IT -----------------------> CF_QUIT
;    |        
;    R -----> O -----> LL --------------> CF_ROLL
;    |        |        T ---------------> CF_ROT
;    |        |        
;    |        SHIFT --------------------> CF_R_SHIFT
;    |        TERR. --------------------> CF_RTERR_DOT
;    |        
;    S -----> >D -----------------------> CF_S_TO_D
;    |        KIP&PARSE ----------------> CF_SKIP_AND_PARSE
;    |        M/REM --------------------> CF_S_M_SLASH_REM
;    |        OURCE -----> -------------> CF_SOURCE
;    |        |            -ID ---------> CF_SOURCE_ID
;    |        |            
;    |        PA --------> CE -> -------> CF_SPACE
;    |        |            |     S -----> CF_SPACES
;    |        |            |     
;    |        |            N -----------> CF_SPAN
;    |        |            
;    |        T ---------> ATE ---------> CF_STATE
;    |        |            RING, -------> CF_STRING_COMMA
;    |        |            
;    |        WAP ----------------------> CF_SWAP
;    |        YNERR. -------------------> CF_SYNERR_DOT
;    |        
;    T -----> H ---> EN ----------------> CF_THEN
;    |        |      ROW ---------------> CF_THROW
;    |        |      
;    |        IB -----------------------> CF_TIB
;    |        RUE ----------------------> CF_TRUE
;    |        UCK ----------------------> CF_TUCK
;    |        YPE ----------------------> CF_TYPE
;    |        
;    U -----> . -----> -----------------> CF_U_DOT
;    |        |        R ---------------> CF_U_DOT_R
;    |        |        
;    |        < ------------------------> CF_U_LESS_THAN
;    |        > ------------------------> CF_U_GREATER_THAN
;    |        M -----> * ---------------> CF_U_M_STAR
;    |        |        /MOD ------------> CF_U_M_SLASH_MOD
;    |        |        
;    |        NLOOP --------------------> CF_UNLOOP
;    |        
;    VA ----> LUE ----------------------> CF_VALUE
;    |        RIABLE -------------------> CF_VARIABLE
;    |        
;    WORDS -> --------------------------> CF_WORDS
;    |        - -> CDICT ---------------> CF_WORDS_CDICT
;    |             UDICT ---------------> CF_WORDS_UDICT
;    |        
;    XOR -------------------------------> CF_XOR
;    [ ---------------------------------> CF_LEFT_BRACKET
;    \ ---------------------------------> CF_BACKSLASH
;    ] ---------------------------------> CF_RIGHT_BRACKET

;###############################################################################
;# Constants                                                                   #
;###############################################################################

;Global constants
#ifndef      NULL
NULL                    EQU     
#endif

;Tree depth
FCDICT_TREE_DEPTH       EQU     4

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
                        FCS     "#"
                        DB      BRANCH
                        DW      FCDICT_TREE_1                   ;#...
                        FCS     "'"
                        DW      CF_TICK                         ;-> '
                        FCS     "("
                        DW      CF_PAREN                        ;-> (
                        FCS     "*"
                        DB      BRANCH
                        DW      FCDICT_TREE_4                   ;*...
                        FCS     "+"
                        DB      BRANCH
                        DW      FCDICT_TREE_5                   ;+...
                        FCS     ","
                        DW      CF_COMMA                        ;-> ,
                        FCS     "-"
                        DW      CF_MINUS                        ;-> -
                        FCS     "."
                        DB      BRANCH
                        DW      FCDICT_TREE_8                   ;....
                        FCS     "/"
                        DB      BRANCH
                        DW      FCDICT_TREE_9                   ;/...
                        FCS     "0"
                        DB      BRANCH
                        DW      FCDICT_TREE_10                  ;0...
                        FCS     "1"
                        DB      BRANCH
                        DW      FCDICT_TREE_11                  ;1...
                        FCS     "2"
                        DB      BRANCH
                        DW      FCDICT_TREE_12                  ;2...
                        FCS     ":"
                        DW      CF_COLON                        ;-> :
                        FCS     ";"
                        DW      CF_SEMICOLON                    ;-> ;
                        FCS     "<"
                        DW      CF_LESS_THAN                    ;-> <
                        FCS     "="
                        DW      CF_EQUALS                       ;-> =
                        FCS     ">"
                        DB      BRANCH
                        DW      FCDICT_TREE_17                  ;>...
                        FCS     "?D"
                        DB      BRANCH
                        DW      FCDICT_TREE_18                  ;?D...
                        FCS     "@"
                        DW      CF_FETCH                        ;-> @
                        FCS     "A"
                        DB      BRANCH
                        DW      FCDICT_TREE_20                  ;A...
                        FCS     "B"
                        DB      BRANCH
                        DW      FCDICT_TREE_21                  ;B...
                        FCS     "C"
                        DB      BRANCH
                        DW      FCDICT_TREE_22                  ;C...
                        FCS     "D"
                        DB      BRANCH
                        DW      FCDICT_TREE_23                  ;D...
                        FCS     "E"
                        DB      BRANCH
                        DW      FCDICT_TREE_24                  ;E...
                        FCS     "F"
                        DB      BRANCH
                        DW      FCDICT_TREE_25                  ;F...
                        FCS     "HE"
                        DB      BRANCH
                        DW      FCDICT_TREE_26                  ;HE...
                        FCS     "I"
                        DB      BRANCH
                        DW      FCDICT_TREE_27                  ;I...
                        FCS     "J"
                        DW      CF_J                            ;-> J
                        FCS     "L"
                        DB      BRANCH
                        DW      FCDICT_TREE_29                  ;L...
                        FCS     "M"
                        DB      BRANCH
                        DW      FCDICT_TREE_30                  ;M...
                        FCS     "N"
                        DB      BRANCH
                        DW      FCDICT_TREE_31                  ;N...
                        FCS     "O"
                        DB      BRANCH
                        DW      FCDICT_TREE_32                  ;O...
                        FCS     "P"
                        DB      BRANCH
                        DW      FCDICT_TREE_33                  ;P...
                        FCS     "QU"
                        DB      BRANCH
                        DW      FCDICT_TREE_34                  ;QU...
                        FCS     "R"
                        DB      BRANCH
                        DW      FCDICT_TREE_35                  ;R...
                        FCS     "S"
                        DB      BRANCH
                        DW      FCDICT_TREE_36                  ;S...
                        FCS     "T"
                        DB      BRANCH
                        DW      FCDICT_TREE_37                  ;T...
                        FCS     "U"
                        DB      BRANCH
                        DW      FCDICT_TREE_38                  ;U...
                        FCS     "VA"
                        DB      BRANCH
                        DW      FCDICT_TREE_39                  ;VA...
                        FCS     "WORDS"
                        DB      BRANCH
                        DW      FCDICT_TREE_40                  ;WORDS...
                        FCS     "XOR"
                        DW      CF_XOR                          ;-> XOR
                        FCS     "["
                        DW      CF_LEFT_BRACKET                 ;-> [
                        FCS     "\"
                        DW      CF_BACKSLASH                    ;-> \
                        FCS     "]"
                        DW      CF_RIGHT_BRACKET                ;-> ]
                        ;DB     END_OF_BRANCH
;Subtree 1 =>           "#"     -> FCDICT_TREE+AF
FCDICT_TREE_1           DB      EMPTY_STRING
                        DW      CF_NUMBER_SIGN                  ;-> #
                        FCS     "TIB"
                        DW      CF_NUMBER_TIB                   ;-> #TIB
                        DB      END_OF_BRANCH
;Subtree 4 =>           "*"     -> FCDICT_TREE+B8
FCDICT_TREE_4           DB      EMPTY_STRING
                        DW      CF_STAR                         ;-> *
                        FCS     "/"
                        DB      BRANCH
                        DW      FCDICT_TREE_4_1                 ;*/...
                        ;DB     END_OF_BRANCH
;Subtree 4->1 =>        "*/"    -> FCDICT_TREE+BF
FCDICT_TREE_4_1         DB      EMPTY_STRING
                        DW      CF_STAR_SLASH                   ;-> */
                        FCS     "MOD"
                        DW      CF_STAR_SLASH_MOD               ;-> */MOD
                        DB      END_OF_BRANCH
;Subtree 5 =>           "+"     -> FCDICT_TREE+C8
FCDICT_TREE_5           DB      EMPTY_STRING
                        DW      CF_PLUS                         ;-> +
                        FCS     "!"
                        DW      CF_PLUS_STORE                   ;-> +!
                        FCS     "LOOP"
                        DW      CF_PLUS_LOOP                    ;-> +LOOP
                        DB      END_OF_BRANCH
;Subtree 8 =>           "."     -> FCDICT_TREE+D5
FCDICT_TREE_8           DB      EMPTY_STRING
                        DW      CF_DOT                          ;-> .
                        FCS     '"'
                        DW      CF_DOT_QUOTE                    ;-> ."
                        FCS     "("
                        DW      CF_DOT_PAREN                    ;-> .(
                        FCS     "R"
                        DW      CF_DOT_R                        ;-> .R
                        FCS     "S"
                        DW      CF_DOT_S                        ;-> .S
                        DB      END_OF_BRANCH
;Subtree 9 =>           "/"     -> FCDICT_TREE+E5
FCDICT_TREE_9           DB      EMPTY_STRING
                        DW      CF_SLASH                        ;-> /
                        FCS     "MOD"
                        DW      CF_SLASH_MOD                    ;-> /MOD
                        DB      END_OF_BRANCH
;Subtree 10 =>          "0"     -> FCDICT_TREE+EE
FCDICT_TREE_10          FCS     "<"
                        DB      BRANCH
                        DW      FCDICT_TREE_10_0                ;0<...
                        FCS     "="
                        DW      CF_ZERO_EQUALS                  ;-> 0=
                        FCS     ">"
                        DW      CF_ZERO_GREATER                 ;-> 0>
                        ;DB     END_OF_BRANCH
;Subtree 10->0 =>       "0<"    -> FCDICT_TREE+F8
FCDICT_TREE_10_0        DB      EMPTY_STRING
                        DW      CF_ZERO_LESS                    ;-> 0<
                        FCS     ">"
                        DW      CF_ZERO_NOT_EQUALS              ;-> 0<>
                        DB      END_OF_BRANCH
;Subtree 11 =>          "1"     -> FCDICT_TREE+FF
FCDICT_TREE_11          FCS     "+"
                        DW      CF_ONE_PLUS                     ;-> 1+
                        FCS     "-"
                        DW      CF_ONE_MINUS                    ;-> 1-
                        DB      END_OF_BRANCH
;Subtree 12 =>          "2"     -> FCDICT_TREE+106
FCDICT_TREE_12          FCS     "!"
                        DW      CF_TWO_STORE                    ;-> 2!
                        FCS     "*"
                        DW      CF_TWO_STAR                     ;-> 2*
                        FCS     "/"
                        DW      CF_TWO_SLASH                    ;-> 2/
                        FCS     "@"
                        DW      CF_TWO_FETCH                    ;-> 2@
                        FCS     "CONSTANT"
                        DW      CF_TWO_CONSTANT                 ;-> 2CONSTANT
                        FCS     "D"
                        DB      BRANCH
                        DW      FCDICT_TREE_12_5                ;2D...
                        FCS     "LITERAL"
                        DW      CF_TWO_LITERAL                  ;-> 2LITERAL
                        FCS     "OVER"
                        DW      CF_TWO_OVER                     ;-> 2OVER
                        FCS     "ROT"
                        DW      CF_2ROT                         ;-> 2ROT
                        FCS     "SWAP"
                        DW      CF_TWO_SWAP                     ;-> 2SWAP
                        DB      END_OF_BRANCH
;Subtree 12->5 =>       "2D"    -> FCDICT_TREE+13B
FCDICT_TREE_12_5        FCS     "ROP"
                        DW      CF_TWO_DROP                     ;-> 2DROP
                        FCS     "UP"
                        DW      CF_TWO_DUP                      ;-> 2DUP
                        DB      END_OF_BRANCH
;Subtree 17 =>          ">"     -> FCDICT_TREE+145
FCDICT_TREE_17          DB      EMPTY_STRING
                        DW      CF_GREATER_THAN                 ;-> >
                        FCS     "IN"
                        DB      BRANCH
                        DW      FCDICT_TREE_17_1                ;>IN...
                        FCS     "R"
                        DW      CF_TO_R                         ;-> >R
                        ;DB     END_OF_BRANCH
;Subtree 17->1 =>       ">IN"   -> FCDICT_TREE+150
FCDICT_TREE_17_1        DB      EMPTY_STRING
                        DW      CF_TO_IN                        ;-> >IN
                        FCS     "T"
                        DW      CF_TO_INT                       ;-> >INT
                        DB      END_OF_BRANCH
;Subtree 18 =>          "?D"    -> FCDICT_TREE+157
FCDICT_TREE_18          FCS     "O"
                        DW      CF_QUESTION_DO                  ;-> ?DO
                        FCS     "UP"
                        DW      CF_QUESTION_DUP                 ;-> ?DUP
                        DB      END_OF_BRANCH
;Subtree 20 =>          "A"     -> FCDICT_TREE+15F
FCDICT_TREE_20          FCS     "B"
                        DB      BRANCH
                        DW      FCDICT_TREE_20_0                ;AB...
                        FCS     "HEAD"
                        DW      CF_AHEAD                        ;-> AHEAD
                        FCS     "L"
                        DB      BRANCH
                        DW      FCDICT_TREE_20_2                ;AL...
                        FCS     "ND"
                        DW      CF_AND                          ;-> AND
                        DB      END_OF_BRANCH
;Subtree 20->0 =>       "AB"    -> FCDICT_TREE+172
FCDICT_TREE_20_0        FCS     "ORT"
                        DB      BRANCH
                        DW      FCDICT_TREE_20_0_0              ;ABORT...
                        FCS     "S"
                        DW      CF_ABS                          ;-> ABS
                        ;DB     END_OF_BRANCH
;Subtree 20->0->0 =>    "ABORT" -> FCDICT_TREE+17B
FCDICT_TREE_20_0_0      DB      EMPTY_STRING
                        DW      CF_ABORT                        ;-> ABORT
                        FCS     '"'
                        DW      CF_ABORT_QUOTE                  ;-> ABORT"
                        DB      END_OF_BRANCH
;Subtree 20->2 =>       "AL"    -> FCDICT_TREE+182
FCDICT_TREE_20_2        FCS     "IGN"
                        DB      BRANCH
                        DW      FCDICT_TREE_20_2_0              ;ALIGN...
                        FCS     "LOT"
                        DW      CF_ALLOT                        ;-> ALLOT
                        ;DB     END_OF_BRANCH
;Subtree 20->2->0 =>    "ALIGN" -> FCDICT_TREE+18D
FCDICT_TREE_20_2_0      DB      EMPTY_STRING
                        DW      CF_ALIGN                        ;-> ALIGN
                        FCS     "ED"
                        DW      CF_ALIGNED                      ;-> ALIGNED
                        DB      END_OF_BRANCH
;Subtree 21 =>          "B"     -> FCDICT_TREE+195
FCDICT_TREE_21          FCS     "ASE"
                        DW      CF_BASE                         ;-> BASE
                        FCS     "INARY"
                        DW      CF_BINARY                       ;-> BINARY
                        FCS     "L"
                        DW      CF_BL                           ;-> BL
                        DB      END_OF_BRANCH
;Subtree 22 =>          "C"     -> FCDICT_TREE+1A5
FCDICT_TREE_22          FCS     "!"
                        DW      CF_C_STORE                      ;-> C!
                        FCS     "@"
                        DW      CF_C_FETCH                      ;-> C@
                        FCS     "ATCH"
                        DW      CF_CATCH                        ;-> CATCH
                        FCS     "ELL"
                        DB      BRANCH
                        DW      FCDICT_TREE_22_3                ;CELL...
                        FCS     "HAR"
                        DB      BRANCH
                        DW      FCDICT_TREE_22_4                ;CHAR...
                        FCS     "O"
                        DB      BRANCH
                        DW      FCDICT_TREE_22_5                ;CO...
                        FCS     "R"
                        DB      BRANCH
                        DW      FCDICT_TREE_22_6                ;CR...
                        ;DB     END_OF_BRANCH
;Subtree 22->6 =>       "CR"    -> FCDICT_TREE+1C5
FCDICT_TREE_22_6        DB      EMPTY_STRING
                        DW      CF_CR                           ;-> CR
                        FCS     "EATE"
                        DW      CF_CREATE                       ;-> CREATE
                        DB      END_OF_BRANCH
;Subtree 22->3 =>       "CELL"  -> FCDICT_TREE+1CF
FCDICT_TREE_22_3        FCS     "+"
                        DW      CF_CELL_PLUS                    ;-> CELL+
                        FCS     "S"
                        DW      CF_CELLS                        ;-> CELLS
                        DB      END_OF_BRANCH
;Subtree 22->4 =>       "CHAR"  -> FCDICT_TREE+1D6
FCDICT_TREE_22_4        FCS     "+"
                        DW      CF_CHAR_PLUS                    ;-> CHAR+
                        FCS     "S"
                        DW      CF_CHARS                        ;-> CHARS
                        DB      END_OF_BRANCH
;Subtree 22->5 =>       "CO"    -> FCDICT_TREE+1DD
FCDICT_TREE_22_5        FCS     "MPILE,"
                        DW      CF_COMPILE_COMMA                ;-> COMPILE,
                        FCS     "NSTANT"
                        DW      CF_CONSTANT                     ;-> CONSTANT
                        FCS     "UNT"
                        DW      CF_COUNT                        ;-> COUNT
                        DB      END_OF_BRANCH
;Subtree 23 =>          "D"     -> FCDICT_TREE+1F3
FCDICT_TREE_23          FCS     "."
                        DB      BRANCH
                        DW      FCDICT_TREE_23_0                ;D....
                        FCS     "ECIMAL"
                        DW      CF_DECIMAL                      ;-> DECIMAL
                        FCS     "O"
                        DB      BRANCH
                        DW      FCDICT_TREE_23_2                ;DO...
                        FCS     "ROP"
                        DW      CF_DROP                         ;-> DROP
                        FCS     "UP"
                        DW      CF_DUP                          ;-> DUP
                        ;DB     END_OF_BRANCH
;Subtree 23->0 =>       "D."    -> FCDICT_TREE+20C
FCDICT_TREE_23_0        DB      EMPTY_STRING
                        DW      CF_D_DOT                        ;-> D.
                        FCS     "R"
                        DW      CF_D_DOT_R                      ;-> D.R
                        DB      END_OF_BRANCH
;Subtree 23->2 =>       "DO"    -> FCDICT_TREE+213
FCDICT_TREE_23_2        DB      EMPTY_STRING
                        DW      CF_DO                           ;-> DO
                        FCS     "ES>"
                        DW      CF_DOES                         ;-> DOES>
                        DB      END_OF_BRANCH
;Subtree 24 =>          "E"     -> FCDICT_TREE+21C
FCDICT_TREE_24          FCS     "LSE"
                        DW      CF_ELSE                         ;-> ELSE
                        FCS     "MIT"
                        DW      CF_EMIT                         ;-> EMIT
                        FCS     "NVIRONMENT?"
                        DW      CF_ENVIRONMENT_QUERY            ;-> ENVIRONMENT?
                        FCS     "RASE"
                        DW      CF_ERASE                        ;-> ERASE
                        FCS     "X"
                        DB      BRANCH
                        DW      FCDICT_TREE_24_4                ;EX...
                        DB      END_OF_BRANCH
;Subtree 24->4 =>       "EX"    -> FCDICT_TREE+23E
FCDICT_TREE_24_4        FCS     "ECUTE"
                        DW      CF_EXECUTE                      ;-> EXECUTE
                        FCS     "IT"
                        DW      CF_EXIT                         ;-> EXIT
                        FCS     "PECT"
                        DW      CF_EXPECT                       ;-> EXPECT
                        DB      END_OF_BRANCH
;Subtree 25 =>          "F"     -> FCDICT_TREE+250
FCDICT_TREE_25          FCS     "ALSE"
                        DW      CF_FALSE                        ;-> FALSE
                        FCS     "ILL"
                        DW      CF_FILL                         ;-> FILL
                        DB      END_OF_BRANCH
;Subtree 26 =>          "HE"    -> FCDICT_TREE+25C
FCDICT_TREE_26          FCS     "RE"
                        DW      CF_HERE                         ;-> HERE
                        FCS     "X"
                        DW      CF_HEX                          ;-> HEX
                        DB      END_OF_BRANCH
;Subtree 27 =>          "I"     -> FCDICT_TREE+264
FCDICT_TREE_27          DB      EMPTY_STRING
                        DW      CF_I                            ;-> I
                        FCS     "F"
                        DW      CF_IF                           ;-> IF
                        FCS     "N"
                        DB      BRANCH
                        DW      FCDICT_TREE_27_2                ;IN...
                        DB      END_OF_BRANCH
;Subtree 27->2 =>       "IN"    -> FCDICT_TREE+26F
FCDICT_TREE_27_2        FCS     "TERPRET"
                        DW      CF_INTERPRET                    ;-> INTERPRET
                        FCS     "VERT"
                        DW      CF_INVERT                       ;-> INVERT
                        DB      END_OF_BRANCH
;Subtree 29 =>          "L"     -> FCDICT_TREE+27F
FCDICT_TREE_29          FCS     "EAVE"
                        DW      CF_LEAVE                        ;-> LEAVE
                        FCS     "ITERAL"
                        DW      CF_LITERAL                      ;-> LITERAL
                        FCS     "OOP"
                        DW      CF_LOOP                         ;-> LOOP
                        FCS     "SHIFT"
                        DW      CF_L_SHIFT                      ;-> LSHIFT
                        FCS     "U"
                        DB      BRANCH
                        DW      FCDICT_TREE_29_4                ;LU...
                        ;DB     END_OF_BRANCH
;Subtree 29->4 =>       "LU"    -> FCDICT_TREE+29D
FCDICT_TREE_29_4        DB      EMPTY_STRING
                        DW      CF_LU                           ;-> LU
                        FCS     "-"
                        DB      BRANCH
                        DW      FCDICT_TREE_29_4_1              ;LU-...
                        DB      END_OF_BRANCH
;Subtree 29->4->1 =>    "LU-"   -> FCDICT_TREE+2A5
FCDICT_TREE_29_4_1      FCS     "CDICT"
                        DW      CF_LU_CDICT                     ;-> LU-CDICT
                        FCS     "NVCBUF"
                        DW      CF_LU_NVCBUF                    ;-> LU-NVCBUF
                        FCS     "UDICT"
                        DW      CF_LU_UDICT                     ;-> LU-UDICT
                        DB      END_OF_BRANCH
;Subtree 30 =>          "M"     -> FCDICT_TREE+2BC
FCDICT_TREE_30          FCS     "*"
                        DW      CF_M_STAR                       ;-> M*
                        FCS     "AX"
                        DW      CF_MAX                          ;-> MAX
                        FCS     "IN"
                        DW      CF_MIN                          ;-> MIN
                        FCS     "O"
                        DB      BRANCH
                        DW      FCDICT_TREE_30_3                ;MO...
                        DB      END_OF_BRANCH
;Subtree 30->3 =>       "MO"    -> FCDICT_TREE+2CC
FCDICT_TREE_30_3        FCS     "D"
                        DW      CF_MOD                          ;-> MOD
                        FCS     "NITOR"
                        DW      CF_MONITOR                      ;-> MONITOR
                        FCS     "VE"
                        DW      CF_MOVE                         ;-> MOVE
                        DB      END_OF_BRANCH
;Subtree 31 =>          "N"     -> FCDICT_TREE+2DB
FCDICT_TREE_31          FCS     "AME,"
                        DW      CF_NAME_COMMA                   ;-> NAME,
                        FCS     "EGATE"
                        DW      CF_NEGATE                       ;-> NEGATE
                        FCS     "IP"
                        DW      CF_NIP                          ;-> NIP
                        FCS     "OP"
                        DW      CF_NOP                          ;-> NOP
                        DB      END_OF_BRANCH
;Subtree 32 =>          "O"     -> FCDICT_TREE+2F1
FCDICT_TREE_32          FCS     "R"
                        DW      CF_OR                           ;-> OR
                        FCS     "VER"
                        DW      CF_OVER                         ;-> OVER
                        DB      END_OF_BRANCH
;Subtree 33 =>          "P"     -> FCDICT_TREE+2FA
FCDICT_TREE_33          FCS     "ARSE"
                        DW      CF_PARSE                        ;-> PARSE
                        FCS     "ICK"
                        DW      CF_PICK                         ;-> PICK
                        FCS     "ROMPT"
                        DW      CF_PROMPT                       ;-> PROMPT
                        DB      END_OF_BRANCH
;Subtree 34 =>          "QU"    -> FCDICT_TREE+30D
FCDICT_TREE_34          FCS     "ERY"
                        DW      CF_QUERY                        ;-> QUERY
                        FCS     "IT"
                        DW      CF_QUIT                         ;-> QUIT
                        DB      END_OF_BRANCH
;Subtree 35 =>          "R"     -> FCDICT_TREE+317
FCDICT_TREE_35          FCS     "O"
                        DB      BRANCH
                        DW      FCDICT_TREE_35_0                ;RO...
                        FCS     "SHIFT"
                        DW      CF_R_SHIFT                      ;-> RSHIFT
                        FCS     "TERR."
                        DW      CF_RTERR_DOT                    ;-> RTERR.
                        DB      END_OF_BRANCH
;Subtree 35->0 =>       "RO"    -> FCDICT_TREE+32A
FCDICT_TREE_35_0        FCS     "LL"
                        DW      CF_ROLL                         ;-> ROLL
                        FCS     "T"
                        DW      CF_ROT                          ;-> ROT
                        DB      END_OF_BRANCH
;Subtree 36 =>          "S"     -> FCDICT_TREE+332
FCDICT_TREE_36          FCS     ">D"
                        DW      CF_S_TO_D                       ;-> S>D
                        FCS     "KIP&PARSE"
                        DW      CF_SKIP_AND_PARSE               ;-> SKIP&PARSE
                        FCS     "M/REM"
                        DW      CF_S_M_SLASH_REM                ;-> SM/REM
                        FCS     "OURCE"
                        DB      BRANCH
                        DW      FCDICT_TREE_36_3                ;SOURCE...
                        FCS     "PA"
                        DB      BRANCH
                        DW      FCDICT_TREE_36_4                ;SPA...
                        FCS     "T"
                        DB      BRANCH
                        DW      FCDICT_TREE_36_5                ;ST...
                        FCS     "WAP"
                        DW      CF_SWAP                         ;-> SWAP
                        FCS     "YNERR."
                        DW      CF_SYNERR_DOT                   ;-> SYNERR.
                        ;DB     END_OF_BRANCH
;Subtree 36->3 =>       "SOURCE"-> FCDICT_TREE+366
FCDICT_TREE_36_3        DB      EMPTY_STRING
                        DW      CF_SOURCE                       ;-> SOURCE
                        FCS     "-ID"
                        DW      CF_SOURCE_ID                    ;-> SOURCE-ID
                        DB      END_OF_BRANCH
;Subtree 36->4 =>       "SPA"   -> FCDICT_TREE+36F
FCDICT_TREE_36_4        FCS     "CE"
                        DB      BRANCH
                        DW      FCDICT_TREE_36_4_0              ;SPACE...
                        FCS     "N"
                        DW      CF_SPAN                         ;-> SPAN
                        ;DB     END_OF_BRANCH
;Subtree 36->4->0 =>    "SPACE" -> FCDICT_TREE+377
FCDICT_TREE_36_4_0      DB      EMPTY_STRING
                        DW      CF_SPACE                        ;-> SPACE
                        FCS     "S"
                        DW      CF_SPACES                       ;-> SPACES
                        DB      END_OF_BRANCH
;Subtree 36->5 =>       "ST"    -> FCDICT_TREE+37E
FCDICT_TREE_36_5        FCS     "ATE"
                        DW      CF_STATE                        ;-> STATE
                        FCS     "RING,"
                        DW      CF_STRING_COMMA                 ;-> STRING,
                        DB      END_OF_BRANCH
;Subtree 37 =>          "T"     -> FCDICT_TREE+38B
FCDICT_TREE_37          FCS     "H"
                        DB      BRANCH
                        DW      FCDICT_TREE_37_0                ;TH...
                        FCS     "IB"
                        DW      CF_TIB                          ;-> TIB
                        FCS     "RUE"
                        DW      CF_TRUE                         ;-> TRUE
                        FCS     "UCK"
                        DW      CF_TUCK                         ;-> TUCK
                        FCS     "YPE"
                        DW      CF_TYPE                         ;-> TYPE
                        DB      END_OF_BRANCH
;Subtree 37->0 =>       "TH"    -> FCDICT_TREE+3A3
FCDICT_TREE_37_0        FCS     "EN"
                        DW      CF_THEN                         ;-> THEN
                        FCS     "ROW"
                        DW      CF_THROW                        ;-> THROW
                        DB      END_OF_BRANCH
;Subtree 38 =>          "U"     -> FCDICT_TREE+3AD
FCDICT_TREE_38          FCS     "."
                        DB      BRANCH
                        DW      FCDICT_TREE_38_0                ;U....
                        FCS     "<"
                        DW      CF_U_LESS_THAN                  ;-> U<
                        FCS     ">"
                        DW      CF_U_GREATER_THAN               ;-> U>
                        FCS     "M"
                        DB      BRANCH
                        DW      FCDICT_TREE_38_3                ;UM...
                        FCS     "NLOOP"
                        DW      CF_UNLOOP                       ;-> UNLOOP
                        ;DB     END_OF_BRANCH
;Subtree 38->0 =>       "U."    -> FCDICT_TREE+3C2
FCDICT_TREE_38_0        DB      EMPTY_STRING
                        DW      CF_U_DOT                        ;-> U.
                        FCS     "R"
                        DW      CF_U_DOT_R                      ;-> U.R
                        DB      END_OF_BRANCH
;Subtree 38->3 =>       "UM"    -> FCDICT_TREE+3C9
FCDICT_TREE_38_3        FCS     "*"
                        DW      CF_U_M_STAR                     ;-> UM*
                        FCS     "/MOD"
                        DW      CF_U_M_SLASH_MOD                ;-> UM/MOD
                        DB      END_OF_BRANCH
;Subtree 39 =>          "VA"    -> FCDICT_TREE+3D3
FCDICT_TREE_39          FCS     "LUE"
                        DW      CF_VALUE                        ;-> VALUE
                        FCS     "RIABLE"
                        DW      CF_VARIABLE                     ;-> VARIABLE
                        DB      END_OF_BRANCH
;Subtree 40 =>          "WORDS" -> FCDICT_TREE+3E1
FCDICT_TREE_40          DB      EMPTY_STRING
                        DW      CF_WORDS                        ;-> WORDS
                        FCS     "-"
                        DB      BRANCH
                        DW      FCDICT_TREE_40_1                ;WORDS-...
                        DB      END_OF_BRANCH
;Subtree 40->1 =>       "WORDS-"-> FCDICT_TREE+3E9
FCDICT_TREE_40_1        FCS     "CDICT"
                        DW      CF_WORDS_CDICT                  ;-> WORDS-CDICT
                        FCS     "UDICT"
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
                        MOVW #(\1+$00), (\3+$06),\2   ;FCDICT_TREE         ("!")
                        MOVW #NULL,     (\3+$04),\2   ;unused
                        MOVW #NULL,     (\3+$02),\2   ;unused
                        MOVW #NULL,     (\3+$00),\2   ;unused
#emac

#endif
