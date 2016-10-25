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
;# Generated on Tue, Oct 25 2016                                               #
;###############################################################################

;###############################################################################
;# Dictionary Tree Structure                                                   #
;###############################################################################
;
; -> ! ----------------------------------> CF_STORE
;    ( ----------------------------------> CF_PAREN
;    * ------> --------------------------> CF_STAR
;    |         / -> ---------------------> CF_STAR_SLASH
;    |              MOD -----------------> CF_STAR_SLASH_MOD
;    |         
;    + ------> --------------------------> CF_PLUS
;    |         ! ------------------------> CF_PLUS_STORE
;    |         
;    - ----------------------------------> CF_MINUS
;    . ------> --------------------------> CF_DOT
;    |         R ------------------------> CF_DOT_R
;    |         S ------------------------> CF_DOT_S
;    |         
;    / ------> --------------------------> CF_SLASH
;    |         MOD ----------------------> CF_SLASH_MOD
;    |         
;    0 ------> < -> ---------------------> CF_ZERO_LESS
;    |         |    > -------------------> CF_ZERO_NOT_EQUALS
;    |         |    
;    |         = ------------------------> CF_ZERO_EQUALS
;    |         > ------------------------> CF_ZERO_GREATER
;    |         
;    1 ------> + ------------------------> CF_ONE_PLUS
;    |         - ------------------------> CF_ONE_MINUS
;    |         
;    2 ------> ! ------------------------> CF_TWO_STORE
;    |         * ------------------------> CF_TWO_STAR
;    |         / ------------------------> CF_TWO_SLASH
;    |         @ ------------------------> CF_TWO_FETCH
;    |         D -------> ROP -----------> CF_TWO_DROP
;    |         |          UP ------------> CF_TWO_DUP
;    |         |          
;    |         LITERAL ------------------> CF_2LITERAL
;    |         OVER ---------------------> CF_TWO_OVER
;    |         ROT ----------------------> CF_2ROT
;    |         SWAP ---------------------> CF_TWO_SWAP
;    |         
;    < ----------------------------------> CF_LESS_THAN
;    = ----------------------------------> CF_EQUALS
;    > ------> --------------------------> CF_GREATER_THAN
;    |         IN -> --------------------> CF_TO_IN
;    |         |     T ------------------> CF_TO_INT
;    |         |     
;    |         R ------------------------> CF_TO_R
;    |         
;    ?DUP -------------------------------> CF_QUESTION_DUP
;    @ ----------------------------------> CF_FETCH
;    A ------> B ------> ORT -> ---------> CF_ABORT
;    |         |         |      " -------> CF_ABORT_QUOTE
;    |         |         |      
;    |         |         S --------------> CF_ABS
;    |         |         
;    |         LIGNED -------------------> CF_ALIGNED
;    |         ND -----------------------> CF_AND
;    |         
;    B ------> ASE ----------------------> CF_BASE
;    |         INARY --------------------> CF_BINARY
;    |         L ------------------------> CF_BL
;    |         
;    C ------> ! ------------------------> CF_C_STORE
;    |         @ ------------------------> CF_C_FETCH
;    |         ATCH ---------------------> CF_CATCH
;    |         ELL --> + ----------------> CF_CELL_PLUS
;    |         |       , ----------------> CF_CELL_COMMA
;    |         |       S ----------------> CF_CELLS
;    |         |       
;    |         HAR --> + ----------------> CF_CHAR_PLUS
;    |         |       , ----------------> CF_CHAR_COMMA
;    |         |       S ----------------> CF_CHARS
;    |         |       
;    |         LS -----------------------> CF_CLS
;    |         O ----> MPILE, -----------> CF_COMPILE_COMMA
;    |         |       NSTANT -----------> CF_CONSTANT
;    |         |       UNT --------------> CF_COUNT
;    |         |       
;    |         R ------------------------> CF_CR
;    |         
;    D ------> . ---> -------------------> CF_D_DOT
;    |         |      R -----------------> CF_D_DOT_R
;    |         |      
;    |         E ---> CIMAL -------------> CF_DECIMAL
;    |         |      PTH ---------------> CF_DEPTH
;    |         |      
;    |         ROP ----------------------> CF_DROP
;    |         UP -----------------------> CF_DUP
;    |         
;    E ------> MIT ----------------------> CF_EMIT
;    |         XECUTE -------------------> CF_EXECUTE
;    |         
;    FALSE ------------------------------> CF_FALSE
;    HEX --------------------------------> CF_HEX
;    INVERT -----------------------------> CF_INVERT
;    L ------> ITERAL -------------------> CF_LITERAL
;    |         SHIFT --------------------> CF_L_SHIFT
;    |         U ------> ----------------> CF_LU
;    |                   - -> CDICT -----> CF_LU_CDICT
;    |                        NVDICT ----> CF_LU_NVDICT
;    |                        UDICT -----> CF_LU_UDICT
;    |         
;    M ------> AX -----------------------> CF_MAX
;    |         IN -----------------------> CF_MIN
;    |         O --> D ------------------> CF_MOD
;    |               NITOR --------------> CF_MONITOR
;    |               VE -----------------> CF_MOVE
;    |         
;    N ------> EGATE --------------------> CF_NEGATE
;    |         OP -----------------------> CF_NOP
;    |         
;    O ------> R ------------------------> CF_OR
;    |         VER ----------------------> CF_OVER
;    |         
;    P ------> ARSE ---------------------> CF_PARSE
;    |         ICK ----------------------> CF_PICK
;    |         ROMPT --------------------> CF_PROMPT
;    |         
;    QU -----> ERY ----------------------> CF_QUERY
;    |         IT -----------------------> CF_QUIT
;    |         
;    R ------> O -----> LL --------------> CF_ROLL
;    |         |        T ---------------> CF_ROT
;    |         |        
;    |         SHIFT --------------------> CF_R_SHIFT
;    |         TERR. --------------------> CF_RTERR_DOT
;    |         
;    S ------> , ------------------------> CF_STRING_COMMA
;    |         . ------------------------> CF_STRING_DOT
;    |         >D -----------------------> CF_S_TO_D
;    |         KIP&PARSE ----------------> CF_SKIP_AND_PARSE
;    |         M/REM --------------------> CF_S_M_SLASH_REM
;    |         PACE ------> -------------> CF_SPACE
;    |         |            S -----------> CF_SPACES
;    |         |            
;    |         TATE ---------------------> CF_STATE
;    |         WAP ----------------------> CF_SWAP
;    |         YNERR. -------------------> CF_SYNERR_DOT
;    |         
;    T ------> HROW ---------------------> CF_THROW
;    |         RUE ----------------------> CF_TRUE
;    |         UCK ----------------------> CF_TUCK
;    |         
;    U ------> . -> ---------------------> CF_U_DOT
;    |         |    R -------------------> CF_U_DOT_R
;    |         |    
;    |         < ------------------------> CF_U_LESS_THAN
;    |         > ------------------------> CF_U_GREATER_THAN
;    |         M -> * -------------------> CF_U_M_STAR
;    |              /MOD ----------------> CF_U_M_SLASH_MOD
;    |         
;    VA -----> LUE ----------------------> CF_VALUE
;    |         RIABLE -------------------> CF_VARIABLE
;    |         
;    WORDS --> --------------------------> CF_WORDS
;    |         - -> CDICT ---------------> CF_WORDS_CDICT
;    |              NVDICT --------------> CF_WORDS_NVDICT
;    |              UDICT ---------------> CF_WORDS_UDICT
;    |         
;    XOR --------------------------------> CF_XOR
;    \ ----------------------------------> CF_BACKSLASH

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
                        FCS     "("
                        DW      CF_PAREN                        ;-> (
                        FCS     "*"
                        DB      BRANCH
                        DW      FCDICT_TREE_2                   ;*...
                        FCS     "+"
                        DB      BRANCH
                        DW      FCDICT_TREE_3                   ;+...
                        FCS     "-"
                        DW      CF_MINUS                        ;-> -
                        FCS     "."
                        DB      BRANCH
                        DW      FCDICT_TREE_5                   ;....
                        FCS     "/"
                        DB      BRANCH
                        DW      FCDICT_TREE_6                   ;/...
                        FCS     "0"
                        DB      BRANCH
                        DW      FCDICT_TREE_7                   ;0...
                        FCS     "1"
                        DB      BRANCH
                        DW      FCDICT_TREE_8                   ;1...
                        FCS     "2"
                        DB      BRANCH
                        DW      FCDICT_TREE_9                   ;2...
                        FCS     "<"
                        DW      CF_LESS_THAN                    ;-> <
                        FCS     "="
                        DW      CF_EQUALS                       ;-> =
                        FCS     ">"
                        DB      BRANCH
                        DW      FCDICT_TREE_12                  ;>...
                        FCS     "?DUP"
                        DW      CF_QUESTION_DUP                 ;-> ?DUP
                        FCS     "@"
                        DW      CF_FETCH                        ;-> @
                        FCS     "A"
                        DB      BRANCH
                        DW      FCDICT_TREE_15                  ;A...
                        FCS     "B"
                        DB      BRANCH
                        DW      FCDICT_TREE_16                  ;B...
                        FCS     "C"
                        DB      BRANCH
                        DW      FCDICT_TREE_17                  ;C...
                        FCS     "D"
                        DB      BRANCH
                        DW      FCDICT_TREE_18                  ;D...
                        FCS     "E"
                        DB      BRANCH
                        DW      FCDICT_TREE_19                  ;E...
                        FCS     "FALSE"
                        DW      CF_FALSE                        ;-> FALSE
                        FCS     "HEX"
                        DW      CF_HEX                          ;-> HEX
                        FCS     "INVERT"
                        DW      CF_INVERT                       ;-> INVERT
                        FCS     "L"
                        DB      BRANCH
                        DW      FCDICT_TREE_23                  ;L...
                        FCS     "M"
                        DB      BRANCH
                        DW      FCDICT_TREE_24                  ;M...
                        FCS     "N"
                        DB      BRANCH
                        DW      FCDICT_TREE_25                  ;N...
                        FCS     "O"
                        DB      BRANCH
                        DW      FCDICT_TREE_26                  ;O...
                        FCS     "P"
                        DB      BRANCH
                        DW      FCDICT_TREE_27                  ;P...
                        FCS     "QU"
                        DB      BRANCH
                        DW      FCDICT_TREE_28                  ;QU...
                        FCS     "R"
                        DB      BRANCH
                        DW      FCDICT_TREE_29                  ;R...
                        FCS     "S"
                        DB      BRANCH
                        DW      FCDICT_TREE_30                  ;S...
                        FCS     "T"
                        DB      BRANCH
                        DW      FCDICT_TREE_31                  ;T...
                        FCS     "U"
                        DB      BRANCH
                        DW      FCDICT_TREE_32                  ;U...
                        FCS     "VA"
                        DB      BRANCH
                        DW      FCDICT_TREE_33                  ;VA...
                        FCS     "WORDS"
                        DB      BRANCH
                        DW      FCDICT_TREE_34                  ;WORDS...
                        FCS     "XOR"
                        DW      CF_XOR                          ;-> XOR
                        FCS     "\"
                        DW      CF_BACKSLASH                    ;-> \
                        ;DB     END_OF_BRANCH
;Subtree 2 =>           "*"     -> FCDICT_TREE+9E
FCDICT_TREE_2           DB      EMPTY_STRING
                        DW      CF_STAR                         ;-> *
                        FCS     "/"
                        DB      BRANCH
                        DW      FCDICT_TREE_2_1                 ;*/...
                        ;DB     END_OF_BRANCH
;Subtree 2->1 =>        "*/"    -> FCDICT_TREE+A5
FCDICT_TREE_2_1         DB      EMPTY_STRING
                        DW      CF_STAR_SLASH                   ;-> */
                        FCS     "MOD"
                        DW      CF_STAR_SLASH_MOD               ;-> */MOD
                        DB      END_OF_BRANCH
;Subtree 3 =>           "+"     -> FCDICT_TREE+AE
FCDICT_TREE_3           DB      EMPTY_STRING
                        DW      CF_PLUS                         ;-> +
                        FCS     "!"
                        DW      CF_PLUS_STORE                   ;-> +!
                        DB      END_OF_BRANCH
;Subtree 5 =>           "."     -> FCDICT_TREE+B5
FCDICT_TREE_5           DB      EMPTY_STRING
                        DW      CF_DOT                          ;-> .
                        FCS     "R"
                        DW      CF_DOT_R                        ;-> .R
                        FCS     "S"
                        DW      CF_DOT_S                        ;-> .S
                        DB      END_OF_BRANCH
;Subtree 6 =>           "/"     -> FCDICT_TREE+BF
FCDICT_TREE_6           DB      EMPTY_STRING
                        DW      CF_SLASH                        ;-> /
                        FCS     "MOD"
                        DW      CF_SLASH_MOD                    ;-> /MOD
                        DB      END_OF_BRANCH
;Subtree 7 =>           "0"     -> FCDICT_TREE+C8
FCDICT_TREE_7           FCS     "<"
                        DB      BRANCH
                        DW      FCDICT_TREE_7_0                 ;0<...
                        FCS     "="
                        DW      CF_ZERO_EQUALS                  ;-> 0=
                        FCS     ">"
                        DW      CF_ZERO_GREATER                 ;-> 0>
                        ;DB     END_OF_BRANCH
;Subtree 7->0 =>        "0<"    -> FCDICT_TREE+D2
FCDICT_TREE_7_0         DB      EMPTY_STRING
                        DW      CF_ZERO_LESS                    ;-> 0<
                        FCS     ">"
                        DW      CF_ZERO_NOT_EQUALS              ;-> 0<>
                        DB      END_OF_BRANCH
;Subtree 8 =>           "1"     -> FCDICT_TREE+D9
FCDICT_TREE_8           FCS     "+"
                        DW      CF_ONE_PLUS                     ;-> 1+
                        FCS     "-"
                        DW      CF_ONE_MINUS                    ;-> 1-
                        DB      END_OF_BRANCH
;Subtree 9 =>           "2"     -> FCDICT_TREE+E0
FCDICT_TREE_9           FCS     "!"
                        DW      CF_TWO_STORE                    ;-> 2!
                        FCS     "*"
                        DW      CF_TWO_STAR                     ;-> 2*
                        FCS     "/"
                        DW      CF_TWO_SLASH                    ;-> 2/
                        FCS     "@"
                        DW      CF_TWO_FETCH                    ;-> 2@
                        FCS     "D"
                        DB      BRANCH
                        DW      FCDICT_TREE_9_4                 ;2D...
                        FCS     "LITERAL"
                        DW      CF_2LITERAL                     ;-> 2LITERAL
                        FCS     "OVER"
                        DW      CF_TWO_OVER                     ;-> 2OVER
                        FCS     "ROT"
                        DW      CF_2ROT                         ;-> 2ROT
                        FCS     "SWAP"
                        DW      CF_TWO_SWAP                     ;-> 2SWAP
                        DB      END_OF_BRANCH
;Subtree 9->4 =>        "2D"    -> FCDICT_TREE+10B
FCDICT_TREE_9_4         FCS     "ROP"
                        DW      CF_TWO_DROP                     ;-> 2DROP
                        FCS     "UP"
                        DW      CF_TWO_DUP                      ;-> 2DUP
                        DB      END_OF_BRANCH
;Subtree 12 =>          ">"     -> FCDICT_TREE+115
FCDICT_TREE_12          DB      EMPTY_STRING
                        DW      CF_GREATER_THAN                 ;-> >
                        FCS     "IN"
                        DB      BRANCH
                        DW      FCDICT_TREE_12_1                ;>IN...
                        FCS     "R"
                        DW      CF_TO_R                         ;-> >R
                        ;DB     END_OF_BRANCH
;Subtree 12->1 =>       ">IN"   -> FCDICT_TREE+120
FCDICT_TREE_12_1        DB      EMPTY_STRING
                        DW      CF_TO_IN                        ;-> >IN
                        FCS     "T"
                        DW      CF_TO_INT                       ;-> >INT
                        DB      END_OF_BRANCH
;Subtree 15 =>          "A"     -> FCDICT_TREE+127
FCDICT_TREE_15          FCS     "B"
                        DB      BRANCH
                        DW      FCDICT_TREE_15_0                ;AB...
                        FCS     "LIGNED"
                        DW      CF_ALIGNED                      ;-> ALIGNED
                        FCS     "ND"
                        DW      CF_AND                          ;-> AND
                        DB      END_OF_BRANCH
;Subtree 15->0 =>       "AB"    -> FCDICT_TREE+138
FCDICT_TREE_15_0        FCS     "ORT"
                        DB      BRANCH
                        DW      FCDICT_TREE_15_0_0              ;ABORT...
                        FCS     "S"
                        DW      CF_ABS                          ;-> ABS
                        ;DB     END_OF_BRANCH
;Subtree 15->0->0 =>    "ABORT" -> FCDICT_TREE+141
FCDICT_TREE_15_0_0      DB      EMPTY_STRING
                        DW      CF_ABORT                        ;-> ABORT
                        FCS     '"'
                        DW      CF_ABORT_QUOTE                  ;-> ABORT"
                        DB      END_OF_BRANCH
;Subtree 16 =>          "B"     -> FCDICT_TREE+148
FCDICT_TREE_16          FCS     "ASE"
                        DW      CF_BASE                         ;-> BASE
                        FCS     "INARY"
                        DW      CF_BINARY                       ;-> BINARY
                        FCS     "L"
                        DW      CF_BL                           ;-> BL
                        DB      END_OF_BRANCH
;Subtree 17 =>          "C"     -> FCDICT_TREE+158
FCDICT_TREE_17          FCS     "!"
                        DW      CF_C_STORE                      ;-> C!
                        FCS     "@"
                        DW      CF_C_FETCH                      ;-> C@
                        FCS     "ATCH"
                        DW      CF_CATCH                        ;-> CATCH
                        FCS     "ELL"
                        DB      BRANCH
                        DW      FCDICT_TREE_17_3                ;CELL...
                        FCS     "HAR"
                        DB      BRANCH
                        DW      FCDICT_TREE_17_4                ;CHAR...
                        FCS     "LS"
                        DW      CF_CLS                          ;-> CLS
                        FCS     "O"
                        DB      BRANCH
                        DW      FCDICT_TREE_17_6                ;CO...
                        FCS     "R"
                        DW      CF_CR                           ;-> CR
                        DB      END_OF_BRANCH
;Subtree 17->3 =>       "CELL"  -> FCDICT_TREE+17C
FCDICT_TREE_17_3        FCS     "+"
                        DW      CF_CELL_PLUS                    ;-> CELL+
                        FCS     ","
                        DW      CF_CELL_COMMA                   ;-> CELL,
                        FCS     "S"
                        DW      CF_CELLS                        ;-> CELLS
                        DB      END_OF_BRANCH
;Subtree 17->4 =>       "CHAR"  -> FCDICT_TREE+186
FCDICT_TREE_17_4        FCS     "+"
                        DW      CF_CHAR_PLUS                    ;-> CHAR+
                        FCS     ","
                        DW      CF_CHAR_COMMA                   ;-> CHAR,
                        FCS     "S"
                        DW      CF_CHARS                        ;-> CHARS
                        DB      END_OF_BRANCH
;Subtree 17->6 =>       "CO"    -> FCDICT_TREE+190
FCDICT_TREE_17_6        FCS     "MPILE,"
                        DW      CF_COMPILE_COMMA                ;-> COMPILE,
                        FCS     "NSTANT"
                        DW      CF_CONSTANT                     ;-> CONSTANT
                        FCS     "UNT"
                        DW      CF_COUNT                        ;-> COUNT
                        DB      END_OF_BRANCH
;Subtree 18 =>          "D"     -> FCDICT_TREE+1A6
FCDICT_TREE_18          FCS     "."
                        DB      BRANCH
                        DW      FCDICT_TREE_18_0                ;D....
                        FCS     "E"
                        DB      BRANCH
                        DW      FCDICT_TREE_18_1                ;DE...
                        FCS     "ROP"
                        DW      CF_DROP                         ;-> DROP
                        FCS     "UP"
                        DW      CF_DUP                          ;-> DUP
                        ;DB     END_OF_BRANCH
;Subtree 18->0 =>       "D."    -> FCDICT_TREE+1B7
FCDICT_TREE_18_0        DB      EMPTY_STRING
                        DW      CF_D_DOT                        ;-> D.
                        FCS     "R"
                        DW      CF_D_DOT_R                      ;-> D.R
                        DB      END_OF_BRANCH
;Subtree 18->1 =>       "DE"    -> FCDICT_TREE+1BE
FCDICT_TREE_18_1        FCS     "CIMAL"
                        DW      CF_DECIMAL                      ;-> DECIMAL
                        FCS     "PTH"
                        DW      CF_DEPTH                        ;-> DEPTH
                        DB      END_OF_BRANCH
;Subtree 19 =>          "E"     -> FCDICT_TREE+1CB
FCDICT_TREE_19          FCS     "MIT"
                        DW      CF_EMIT                         ;-> EMIT
                        FCS     "XECUTE"
                        DW      CF_EXECUTE                      ;-> EXECUTE
                        DB      END_OF_BRANCH
;Subtree 23 =>          "L"     -> FCDICT_TREE+1D9
FCDICT_TREE_23          FCS     "ITERAL"
                        DW      CF_LITERAL                      ;-> LITERAL
                        FCS     "SHIFT"
                        DW      CF_L_SHIFT                      ;-> LSHIFT
                        FCS     "U"
                        DB      BRANCH
                        DW      FCDICT_TREE_23_2                ;LU...
                        ;DB     END_OF_BRANCH
;Subtree 23->2 =>       "LU"    -> FCDICT_TREE+1EC
FCDICT_TREE_23_2        DB      EMPTY_STRING
                        DW      CF_LU                           ;-> LU
                        FCS     "-"
                        DB      BRANCH
                        DW      FCDICT_TREE_23_2_1              ;LU-...
                        DB      END_OF_BRANCH
;Subtree 23->2->1 =>    "LU-"   -> FCDICT_TREE+1F4
FCDICT_TREE_23_2_1      FCS     "CDICT"
                        DW      CF_LU_CDICT                     ;-> LU-CDICT
                        FCS     "NVDICT"
                        DW      CF_LU_NVDICT                    ;-> LU-NVDICT
                        FCS     "UDICT"
                        DW      CF_LU_UDICT                     ;-> LU-UDICT
                        DB      END_OF_BRANCH
;Subtree 24 =>          "M"     -> FCDICT_TREE+20B
FCDICT_TREE_24          FCS     "AX"
                        DW      CF_MAX                          ;-> MAX
                        FCS     "IN"
                        DW      CF_MIN                          ;-> MIN
                        FCS     "O"
                        DB      BRANCH
                        DW      FCDICT_TREE_24_2                ;MO...
                        DB      END_OF_BRANCH
;Subtree 24->2 =>       "MO"    -> FCDICT_TREE+218
FCDICT_TREE_24_2        FCS     "D"
                        DW      CF_MOD                          ;-> MOD
                        FCS     "NITOR"
                        DW      CF_MONITOR                      ;-> MONITOR
                        FCS     "VE"
                        DW      CF_MOVE                         ;-> MOVE
                        DB      END_OF_BRANCH
;Subtree 25 =>          "N"     -> FCDICT_TREE+227
FCDICT_TREE_25          FCS     "EGATE"
                        DW      CF_NEGATE                       ;-> NEGATE
                        FCS     "OP"
                        DW      CF_NOP                          ;-> NOP
                        DB      END_OF_BRANCH
;Subtree 26 =>          "O"     -> FCDICT_TREE+233
FCDICT_TREE_26          FCS     "R"
                        DW      CF_OR                           ;-> OR
                        FCS     "VER"
                        DW      CF_OVER                         ;-> OVER
                        DB      END_OF_BRANCH
;Subtree 27 =>          "P"     -> FCDICT_TREE+23C
FCDICT_TREE_27          FCS     "ARSE"
                        DW      CF_PARSE                        ;-> PARSE
                        FCS     "ICK"
                        DW      CF_PICK                         ;-> PICK
                        FCS     "ROMPT"
                        DW      CF_PROMPT                       ;-> PROMPT
                        DB      END_OF_BRANCH
;Subtree 28 =>          "QU"    -> FCDICT_TREE+24F
FCDICT_TREE_28          FCS     "ERY"
                        DW      CF_QUERY                        ;-> QUERY
                        FCS     "IT"
                        DW      CF_QUIT                         ;-> QUIT
                        DB      END_OF_BRANCH
;Subtree 29 =>          "R"     -> FCDICT_TREE+259
FCDICT_TREE_29          FCS     "O"
                        DB      BRANCH
                        DW      FCDICT_TREE_29_0                ;RO...
                        FCS     "SHIFT"
                        DW      CF_R_SHIFT                      ;-> RSHIFT
                        FCS     "TERR."
                        DW      CF_RTERR_DOT                    ;-> RTERR.
                        DB      END_OF_BRANCH
;Subtree 29->0 =>       "RO"    -> FCDICT_TREE+26C
FCDICT_TREE_29_0        FCS     "LL"
                        DW      CF_ROLL                         ;-> ROLL
                        FCS     "T"
                        DW      CF_ROT                          ;-> ROT
                        DB      END_OF_BRANCH
;Subtree 30 =>          "S"     -> FCDICT_TREE+274
FCDICT_TREE_30          FCS     ","
                        DW      CF_STRING_COMMA                 ;-> S,
                        FCS     "."
                        DW      CF_STRING_DOT                   ;-> S.
                        FCS     ">D"
                        DW      CF_S_TO_D                       ;-> S>D
                        FCS     "KIP&PARSE"
                        DW      CF_SKIP_AND_PARSE               ;-> SKIP&PARSE
                        FCS     "M/REM"
                        DW      CF_S_M_SLASH_REM                ;-> SM/REM
                        FCS     "PACE"
                        DB      BRANCH
                        DW      FCDICT_TREE_30_5                ;SPACE...
                        FCS     "TATE"
                        DW      CF_STATE                        ;-> STATE
                        FCS     "WAP"
                        DW      CF_SWAP                         ;-> SWAP
                        FCS     "YNERR."
                        DW      CF_SYNERR_DOT                   ;-> SYNERR.
                        ;DB     END_OF_BRANCH
;Subtree 30->5 =>       "SPACE" -> FCDICT_TREE+2AA
FCDICT_TREE_30_5        DB      EMPTY_STRING
                        DW      CF_SPACE                        ;-> SPACE
                        FCS     "S"
                        DW      CF_SPACES                       ;-> SPACES
                        DB      END_OF_BRANCH
;Subtree 31 =>          "T"     -> FCDICT_TREE+2B1
FCDICT_TREE_31          FCS     "HROW"
                        DW      CF_THROW                        ;-> THROW
                        FCS     "RUE"
                        DW      CF_TRUE                         ;-> TRUE
                        FCS     "UCK"
                        DW      CF_TUCK                         ;-> TUCK
                        DB      END_OF_BRANCH
;Subtree 32 =>          "U"     -> FCDICT_TREE+2C2
FCDICT_TREE_32          FCS     "."
                        DB      BRANCH
                        DW      FCDICT_TREE_32_0                ;U....
                        FCS     "<"
                        DW      CF_U_LESS_THAN                  ;-> U<
                        FCS     ">"
                        DW      CF_U_GREATER_THAN               ;-> U>
                        FCS     "M"
                        DB      BRANCH
                        DW      FCDICT_TREE_32_3                ;UM...
                        ;DB     END_OF_BRANCH
;Subtree 32->0 =>       "U."    -> FCDICT_TREE+2D0
FCDICT_TREE_32_0        DB      EMPTY_STRING
                        DW      CF_U_DOT                        ;-> U.
                        FCS     "R"
                        DW      CF_U_DOT_R                      ;-> U.R
                        DB      END_OF_BRANCH
;Subtree 32->3 =>       "UM"    -> FCDICT_TREE+2D7
FCDICT_TREE_32_3        FCS     "*"
                        DW      CF_U_M_STAR                     ;-> UM*
                        FCS     "/MOD"
                        DW      CF_U_M_SLASH_MOD                ;-> UM/MOD
                        DB      END_OF_BRANCH
;Subtree 33 =>          "VA"    -> FCDICT_TREE+2E1
FCDICT_TREE_33          FCS     "LUE"
                        DW      CF_VALUE                        ;-> VALUE
                        FCS     "RIABLE"
                        DW      CF_VARIABLE                     ;-> VARIABLE
                        DB      END_OF_BRANCH
;Subtree 34 =>          "WORDS" -> FCDICT_TREE+2EF
FCDICT_TREE_34          DB      EMPTY_STRING
                        DW      CF_WORDS                        ;-> WORDS
                        FCS     "-"
                        DB      BRANCH
                        DW      FCDICT_TREE_34_1                ;WORDS-...
                        DB      END_OF_BRANCH
;Subtree 34->1 =>       "WORDS-"-> FCDICT_TREE+2F7
FCDICT_TREE_34_1        FCS     "CDICT"
                        DW      CF_WORDS_CDICT                  ;-> WORDS-CDICT
                        FCS     "NVDICT"
                        DW      CF_WORDS_NVDICT                 ;-> WORDS-NVDICT
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
