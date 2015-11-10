#ifndef FCDICT_TREE_COMPILED
#define FCDICT_TREE_COMPILED
;###############################################################################
;# S12CForth - Search Tree for the Core Dictionary                             #
;###############################################################################
;#    Copyright 2009-2015 Dirk Heisswolf                                       #
;#    This file is part of the S12CForth framework for Freescale's S12(X) MCU  #
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
;#    This file contains a search tree for the NFAs of the S12CForth CORE      #
;#    words.                                                                   #
;#                                                                             #
;###############################################################################
;# Generated on Tue, Nov 10 2015                                               #
;###############################################################################

;###############################################################################
;# Dictionary Tree Structure                                                   #
;###############################################################################
;
; -> #TIB ---------------------------> CFA_NUMBER_TIB 
;    $. -----------------------------> CFA_STRING_DOT 
;    2 -----> D ----> ROP -----------> CFA_TWO_DROP 
;    |        |       UP ------------> CFA_TWO_DUP 
;    |        |       
;    |        OVER ------------------> CFA_TWO_OVER 
;    |        ROT -------------------> CFA_TWO_ROT 
;    |        SWAP ------------------> CFA_TWO_SWAP 
;    |        
;    > -----> IN --------------------> CFA_TO_IN 
;    |        NUMBER ----------------> CFA_TO_NUMBER 
;    |        
;    BASE ---------------------------> CFA_BASE 
;    C -----> ATCH ------------------> CFA_CATCH 
;    |        R ---------------------> CFA_CR 
;    |        
;    D -----> ROP -------------------> CFA_DROP 
;    |        UP --------------------> CFA_DUP 
;    |        
;    E -----> KEY -> ----------------> CFA_EKEY 
;    |        |      ? --------------> CFA_EKEY_QUESTION 
;    |        |      
;    |        MIT -> ----------------> CFA_EMIT 
;    |               ? --------------> CFA_EMIT_QUESTION 
;    |        
;    FIND- -> CDICT -----------------> CFA_FIND_CDICT 
;    |        UDICT -----------------> CFA_FIND_UDICT 
;    |        
;    N -----> OP --------------------> CFA_NOP 
;    |        VC --------------------> CFA_NVC 
;    |        
;    OVER ---------------------------> CFA_OVER 
;    PARSE --------------------------> CFA_PARSE 
;    QUERY --------------------------> CFA_QUERY 
;    R -----> ESUME -----------------> CFA_RESUME (immediate)
;    |        OT --------------------> CFA_ROT 
;    |        
;    S -----> PACE ------------------> CFA_SPACE 
;    |        TATE ------------------> CFA_STATE 
;    |        USPEND ----------------> CFA_SUSPEND 
;    |        WAP -------------------> CFA_SWAP 
;    |        
;    T -----> HROW ------------------> CFA_THROW 
;    |        IB-OFFSET -------------> CFA_LITERAL_RT 
;    |        
;    W -----> AIT -------------------> CFA_WAIT 
;             ORDS -> ---------------> CFA_WORDS 
;                     - -> CDICT ----> CFA_WORDS_CDICT 
;                          UDICT ----> CFA_WORDS_UDICT 

;###############################################################################
;# Constants                                                                   #
;###############################################################################

;Global constants
#ifndef      NULL
NULL                    EQU     
#endif

;Tree depth
FCDICT_TREE_DEPTH       EQU     4

;First CFA
FCDICT_FIRST_CFA        EQU     CFA_NUMBER_TIB

;###############################################################################
;# Macros                                                                      #
;###############################################################################

;Dictionary tree
#macro       FCDICT_TREE, 0
;Local constants
EMPTY_STRING            EQU     $00
BRANCH                  EQU     $00
END_OF_BRANCH           EQU     $00
IMMEDIATE               EQU     $8000
;Root
FCDICT_TREE             FCS     "#TIB"
                        DW      (CFA_NUMBER_TIB>>1)             ;-> #TIB
                        FCS     "$."
                        DW      (CFA_STRING_DOT>>1)             ;-> $.
                        FCS     "2"
                        DB      BRANCH
                        DW      FCDICT_TREE_2                   ;2...
                        FCS     ">"
                        DB      BRANCH
                        DW      FCDICT_TREE_3                   ;>...
                        FCS     "BASE"
                        DW      (CFA_BASE>>1)                   ;-> BASE
                        FCS     "C"
                        DB      BRANCH
                        DW      FCDICT_TREE_5                   ;C...
                        FCS     "D"
                        DB      BRANCH
                        DW      FCDICT_TREE_6                   ;D...
                        FCS     "E"
                        DB      BRANCH
                        DW      FCDICT_TREE_7                   ;E...
                        FCS     "FIND-"
                        DB      BRANCH
                        DW      FCDICT_TREE_8                   ;FIND-...
                        FCS     "N"
                        DB      BRANCH
                        DW      FCDICT_TREE_9                   ;N...
                        FCS     "OVER"
                        DW      (CFA_OVER>>1)                   ;-> OVER
                        FCS     "PARSE"
                        DW      (CFA_PARSE>>1)                  ;-> PARSE
                        FCS     "QUERY"
                        DW      (CFA_QUERY>>1)                  ;-> QUERY
                        FCS     "R"
                        DB      BRANCH
                        DW      FCDICT_TREE_13                  ;R...
                        FCS     "S"
                        DB      BRANCH
                        DW      FCDICT_TREE_14                  ;S...
                        FCS     "T"
                        DB      BRANCH
                        DW      FCDICT_TREE_15                  ;T...
                        FCS     "W"
                        DB      BRANCH
                        DW      FCDICT_TREE_16                  ;W...
                        DB      END_OF_BRANCH
;Subtree 2 =>           "2"       -> FCDICT_TREE+5B
FCDICT_TREE_2           FCS     "D"
                        DB      BRANCH
                        DW      FCDICT_TREE_2_0                 ;2D...
                        FCS     "OVER"
                        DW      (CFA_TWO_OVER>>1)               ;-> 2OVER
                        FCS     "ROT"
                        DW      (CFA_TWO_ROT>>1)                ;-> 2ROT
                        FCS     "SWAP"
                        DW      (CFA_TWO_SWAP>>1)               ;-> 2SWAP
                        DB      END_OF_BRANCH
;Subtree 2->0 =>        "2D"      -> FCDICT_TREE+74
FCDICT_TREE_2_0         FCS     "ROP"
                        DW      (CFA_TWO_DROP>>1)               ;-> 2DROP
                        FCS     "UP"
                        DW      (CFA_TWO_DUP>>1)                ;-> 2DUP
                        DB      END_OF_BRANCH
;Subtree 3 =>           ">"       -> FCDICT_TREE+80
FCDICT_TREE_3           FCS     "IN"
                        DW      (CFA_TO_IN>>1)                  ;-> >IN
                        FCS     "NUMBER"
                        DW      (CFA_TO_NUMBER>>1)              ;-> >NUMBER
                        DB      END_OF_BRANCH
;Subtree 5 =>           "C"       -> FCDICT_TREE+8F
FCDICT_TREE_5           FCS     "ATCH"
                        DW      (CFA_CATCH>>1)                  ;-> CATCH
                        FCS     "R"
                        DW      (CFA_CR>>1)                     ;-> CR
                        DB      END_OF_BRANCH
;Subtree 6 =>           "D"       -> FCDICT_TREE+9B
FCDICT_TREE_6           FCS     "ROP"
                        DW      (CFA_DROP>>1)                   ;-> DROP
                        FCS     "UP"
                        DW      (CFA_DUP>>1)                    ;-> DUP
                        DB      END_OF_BRANCH
;Subtree 7 =>           "E"       -> FCDICT_TREE+A7
FCDICT_TREE_7           FCS     "KEY"
                        DB      BRANCH
                        DW      FCDICT_TREE_7_0                 ;EKEY...
                        FCS     "MIT"
                        DB      BRANCH
                        DW      FCDICT_TREE_7_1                 ;EMIT...
                        ;DB     END_OF_BRANCH
;Subtree 7->0 =>        "EKEY"    -> FCDICT_TREE+B4
FCDICT_TREE_7_0         DB      EMPTY_STRING
                        DW      (CFA_EKEY>>1)                   ;-> EKEY
                        FCS     "?"
                        DW      (CFA_EKEY_QUESTION>>1)          ;-> EKEY?
                        DB      END_OF_BRANCH
;Subtree 7->1 =>        "EMIT"    -> FCDICT_TREE+BC
FCDICT_TREE_7_1         DB      EMPTY_STRING
                        DW      (CFA_EMIT>>1)                   ;-> EMIT
                        FCS     "?"
                        DW      (CFA_EMIT_QUESTION>>1)          ;-> EMIT?
                        DB      END_OF_BRANCH
;Subtree 8 =>           "FIND-"   -> FCDICT_TREE+C4
FCDICT_TREE_8           FCS     "CDICT"
                        DW      (CFA_FIND_CDICT>>1)             ;-> FIND-CDICT
                        FCS     "UDICT"
                        DW      (CFA_FIND_UDICT>>1)             ;-> FIND-UDICT
                        DB      END_OF_BRANCH
;Subtree 9 =>           "N"       -> FCDICT_TREE+D5
FCDICT_TREE_9           FCS     "OP"
                        DW      (CFA_NOP>>1)                    ;-> NOP
                        FCS     "VC"
                        DW      (CFA_NVC>>1)                    ;-> NVC
                        DB      END_OF_BRANCH
;Subtree 13 =>          "R"       -> FCDICT_TREE+E0
FCDICT_TREE_13          FCS     "ESUME"
                        DW      (CFA_RESUME>>1)|IMMEDIATE       ;-> RESUME
                        FCS     "OT"
                        DW      (CFA_ROT>>1)                    ;-> ROT
                        DB      END_OF_BRANCH
;Subtree 14 =>          "S"       -> FCDICT_TREE+EE
FCDICT_TREE_14          FCS     "PACE"
                        DW      (CFA_SPACE>>1)                  ;-> SPACE
                        FCS     "TATE"
                        DW      (CFA_STATE>>1)                  ;-> STATE
                        FCS     "USPEND"
                        DW      (CFA_SUSPEND>>1)                ;-> SUSPEND
                        FCS     "WAP"
                        DW      (CFA_SWAP>>1)                   ;-> SWAP
                        DB      END_OF_BRANCH
;Subtree 15 =>          "T"       -> FCDICT_TREE+10C
FCDICT_TREE_15          FCS     "HROW"
                        DW      (CFA_THROW>>1)                  ;-> THROW
                        FCS     "IB-OFFSET"
                        DW      (CFA_LITERAL_RT>>1)             ;-> TIB-OFFSET
                        DB      END_OF_BRANCH
;Subtree 16 =>          "W"       -> FCDICT_TREE+120
FCDICT_TREE_16          FCS     "AIT"
                        DW      (CFA_WAIT>>1)                   ;-> WAIT
                        FCS     "ORDS"
                        DB      BRANCH
                        DW      FCDICT_TREE_16_1                ;WORDS...
                        ;DB     END_OF_BRANCH
;Subtree 16->1 =>       "WORDS"   -> FCDICT_TREE+12E
FCDICT_TREE_16_1        DB      EMPTY_STRING
                        DW      (CFA_WORDS>>1)                  ;-> WORDS
                        FCS     "-"
                        DB      BRANCH
                        DW      FCDICT_TREE_16_1_1              ;WORDS-...
                        DB      END_OF_BRANCH
;Subtree 16->1->1 =>    "WORDS-"  -> FCDICT_TREE+136
FCDICT_TREE_16_1_1      FCS     "CDICT"
                        DW      (CFA_WORDS_CDICT>>1)            ;-> WORDS-CDICT
                        FCS     "UDICT"
                        DW      (CFA_WORDS_UDICT>>1)            ;-> WORDS-UDICT
                        DB      END_OF_BRANCH
#emac
;#Set pointer structure to first CDICT entry
; args:   1: address of CDICT root
;         2: index register to address tree entry structure
;         3: offset of tree entry structure
; result: none
; SSTACK: none
;         All registers are preserved
#macro FCDICT_ITERATOR_INIT, 3
                        MOVW #(\1+$00), (\3+$00),\2   ;FCDICT_TREE         ("#TIB")
                        MOVW #NULL,     (\3+$02),\2   ;
                        MOVW #NULL,     (\3+$04),\2   ;
                        MOVW #NULL,     (\3+$06),\2   ;
                        MOVW #NULL,     (\3+$08),\2   ;
#emac
#endif
