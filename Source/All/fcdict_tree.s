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
;# Generated on Thu, Jan 07 2016                                               #
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
;    : -----> -----------------------> CFA_COLON (immediate)
;    |        NONAME ----------------> CFA_COLON_NONAME (immediate)
;    |        
;    ; ------------------------------> CFA_SEMICOLON (immediate)
;    > -----> IN --------------------> CFA_TO_IN 
;    |        NUMBER ----------------> CFA_TO_NUMBER 
;    |        
;    BASE ---------------------------> CFA_BASE 
;    C -----> ATCH ------------------> CFA_CATCH 
;    |        OMPILE-ONLY -----------> CFA_COMPILE_ONLY 
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
;    I -----> MMEDIATE --------------> CFA_IMMEDIATE 
;    |        NTERPRET-ONLY ---------> CFA_INTERPRET_ONLY 
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
;    THROW --------------------------> CFA_THROW 
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
                        FCS     ":"
                        DB      BRANCH
                        DW      FCDICT_TREE_3                   ;:...
                        FCS     ";"
                        DW      (CFA_SEMICOLON>>1)|IMMEDIATE    ;-> ;
                        FCS     ">"
                        DB      BRANCH
                        DW      FCDICT_TREE_5                   ;>...
                        FCS     "BASE"
                        DW      (CFA_BASE>>1)                   ;-> BASE
                        FCS     "C"
                        DB      BRANCH
                        DW      FCDICT_TREE_7                   ;C...
                        FCS     "D"
                        DB      BRANCH
                        DW      FCDICT_TREE_8                   ;D...
                        FCS     "E"
                        DB      BRANCH
                        DW      FCDICT_TREE_9                   ;E...
                        FCS     "FIND-"
                        DB      BRANCH
                        DW      FCDICT_TREE_10                  ;FIND-...
                        FCS     "I"
                        DB      BRANCH
                        DW      FCDICT_TREE_11                  ;I...
                        FCS     "N"
                        DB      BRANCH
                        DW      FCDICT_TREE_12                  ;N...
                        FCS     "OVER"
                        DW      (CFA_OVER>>1)                   ;-> OVER
                        FCS     "PARSE"
                        DW      (CFA_PARSE>>1)                  ;-> PARSE
                        FCS     "QUERY"
                        DW      (CFA_QUERY>>1)                  ;-> QUERY
                        FCS     "R"
                        DB      BRANCH
                        DW      FCDICT_TREE_16                  ;R...
                        FCS     "S"
                        DB      BRANCH
                        DW      FCDICT_TREE_17                  ;S...
                        FCS     "THROW"
                        DW      (CFA_THROW>>1)                  ;-> THROW
                        FCS     "W"
                        DB      BRANCH
                        DW      FCDICT_TREE_19                  ;W...
                        ;DB     END_OF_BRANCH
;Subtree 3 =>           ":"       -> FCDICT_TREE+6B
FCDICT_TREE_3           DB      EMPTY_STRING
                        DW      (CFA_COLON>>1)|IMMEDIATE        ;-> :
                        FCS     "NONAME"
                        DW      (CFA_COLON_NONAME>>1)|IMMEDIATE ;-> :NONAME
                        DB      END_OF_BRANCH
;Subtree 2 =>           "2"       -> FCDICT_TREE+78
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
;Subtree 2->0 =>        "2D"      -> FCDICT_TREE+91
FCDICT_TREE_2_0         FCS     "ROP"
                        DW      (CFA_TWO_DROP>>1)               ;-> 2DROP
                        FCS     "UP"
                        DW      (CFA_TWO_DUP>>1)                ;-> 2DUP
                        DB      END_OF_BRANCH
;Subtree 5 =>           ">"       -> FCDICT_TREE+9D
FCDICT_TREE_5           FCS     "IN"
                        DW      (CFA_TO_IN>>1)                  ;-> >IN
                        FCS     "NUMBER"
                        DW      (CFA_TO_NUMBER>>1)              ;-> >NUMBER
                        DB      END_OF_BRANCH
;Subtree 7 =>           "C"       -> FCDICT_TREE+AC
FCDICT_TREE_7           FCS     "ATCH"
                        DW      (CFA_CATCH>>1)                  ;-> CATCH
                        FCS     "OMPILE-ONLY"
                        DW      (CFA_COMPILE_ONLY>>1)           ;-> COMPILE-ONLY
                        FCS     "R"
                        DW      (CFA_CR>>1)                     ;-> CR
                        DB      END_OF_BRANCH
;Subtree 8 =>           "D"       -> FCDICT_TREE+C6
FCDICT_TREE_8           FCS     "ROP"
                        DW      (CFA_DROP>>1)                   ;-> DROP
                        FCS     "UP"
                        DW      (CFA_DUP>>1)                    ;-> DUP
                        DB      END_OF_BRANCH
;Subtree 9 =>           "E"       -> FCDICT_TREE+D2
FCDICT_TREE_9           FCS     "KEY"
                        DB      BRANCH
                        DW      FCDICT_TREE_9_0                 ;EKEY...
                        FCS     "MIT"
                        DB      BRANCH
                        DW      FCDICT_TREE_9_1                 ;EMIT...
                        ;DB     END_OF_BRANCH
;Subtree 9->0 =>        "EKEY"    -> FCDICT_TREE+DF
FCDICT_TREE_9_0         DB      EMPTY_STRING
                        DW      (CFA_EKEY>>1)                   ;-> EKEY
                        FCS     "?"
                        DW      (CFA_EKEY_QUESTION>>1)          ;-> EKEY?
                        DB      END_OF_BRANCH
;Subtree 9->1 =>        "EMIT"    -> FCDICT_TREE+E7
FCDICT_TREE_9_1         DB      EMPTY_STRING
                        DW      (CFA_EMIT>>1)                   ;-> EMIT
                        FCS     "?"
                        DW      (CFA_EMIT_QUESTION>>1)          ;-> EMIT?
                        DB      END_OF_BRANCH
;Subtree 10 =>          "FIND-"   -> FCDICT_TREE+EF
FCDICT_TREE_10          FCS     "CDICT"
                        DW      (CFA_FIND_CDICT>>1)             ;-> FIND-CDICT
                        FCS     "UDICT"
                        DW      (CFA_FIND_UDICT>>1)             ;-> FIND-UDICT
                        DB      END_OF_BRANCH
;Subtree 11 =>          "I"       -> FCDICT_TREE+100
FCDICT_TREE_11          FCS     "MMEDIATE"
                        DW      (CFA_IMMEDIATE>>1)              ;-> IMMEDIATE
                        FCS     "NTERPRET-ONLY"
                        DW      (CFA_INTERPRET_ONLY>>1)         ;-> INTERPRET-ONLY
                        DB      END_OF_BRANCH
;Subtree 12 =>          "N"       -> FCDICT_TREE+11C
FCDICT_TREE_12          FCS     "OP"
                        DW      (CFA_NOP>>1)                    ;-> NOP
                        FCS     "VC"
                        DW      (CFA_NVC>>1)                    ;-> NVC
                        DB      END_OF_BRANCH
;Subtree 16 =>          "R"       -> FCDICT_TREE+127
FCDICT_TREE_16          FCS     "ESUME"
                        DW      (CFA_RESUME>>1)|IMMEDIATE       ;-> RESUME
                        FCS     "OT"
                        DW      (CFA_ROT>>1)                    ;-> ROT
                        DB      END_OF_BRANCH
;Subtree 17 =>          "S"       -> FCDICT_TREE+135
FCDICT_TREE_17          FCS     "PACE"
                        DW      (CFA_SPACE>>1)                  ;-> SPACE
                        FCS     "TATE"
                        DW      (CFA_STATE>>1)                  ;-> STATE
                        FCS     "USPEND"
                        DW      (CFA_SUSPEND>>1)                ;-> SUSPEND
                        FCS     "WAP"
                        DW      (CFA_SWAP>>1)                   ;-> SWAP
                        DB      END_OF_BRANCH
;Subtree 19 =>          "W"       -> FCDICT_TREE+153
FCDICT_TREE_19          FCS     "AIT"
                        DW      (CFA_WAIT>>1)                   ;-> WAIT
                        FCS     "ORDS"
                        DB      BRANCH
                        DW      FCDICT_TREE_19_1                ;WORDS...
                        ;DB     END_OF_BRANCH
;Subtree 19->1 =>       "WORDS"   -> FCDICT_TREE+161
FCDICT_TREE_19_1        DB      EMPTY_STRING
                        DW      (CFA_WORDS>>1)                  ;-> WORDS
                        FCS     "-"
                        DB      BRANCH
                        DW      FCDICT_TREE_19_1_1              ;WORDS-...
                        DB      END_OF_BRANCH
;Subtree 19->1->1 =>    "WORDS-"  -> FCDICT_TREE+169
FCDICT_TREE_19_1_1      FCS     "CDICT"
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
