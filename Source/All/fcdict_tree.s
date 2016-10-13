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
;# Generated on Thu, Oct 13 2016                                               #
;###############################################################################

;###############################################################################
;# Dictionary Tree Structure                                                   #
;###############################################################################
;
; -> 2 -----> D ----> ROP ---------> CF_TWO_DROP
;    |        |       UP ----------> CF_TWO_DUP
;    |        |       
;    |        OVER ----------------> CF_TWO_OVER
;    |        ROT -----------------> CF_2ROT
;    |        SWAP ----------------> CF_TWO_SWAP
;    |        
;    >INT -------------------------> CF_TO_INT
;    C -----> OMPILE, -------------> CF_COMPILE_COMMA
;    |        R -------------------> CF_CR
;    |        
;    D -----> ROP -----------------> CF_DROP
;    |        UP ------------------> CF_DUP
;    |        
;    L -----> ITERAL --------------> CF_LITERAL
;    |        U ------> -----------> CF_LU
;    |                  -CDICT ----> CF_LU_CDICT
;    |        
;    NOP --------------------------> CF_NOP
;    OVER -------------------------> CF_OVER
;    P -----> ARSE ----------------> CF_PARSE
;    |        ROMPT ---------------> CF_PROMPT
;    |        
;    QUERY ------------------------> CF_QUERY
;    ROT --------------------------> CF_ROT
;    S -----> PACE --------> ------> CF_SPACE
;    |        |              S ----> CF_SPACES
;    |        |              
;    |        WAP -----------------> CF_SWAP
;    |        YNTAX-ERROR ---------> CF_SYNTAX_ERROR
;    |        
;    WORDS -> ---------------------> CF_WORDS
;             -CDICT --------------> CF_WORDS_CDICT

;###############################################################################
;# Constants                                                                   #
;###############################################################################

;Global constants
#ifndef      NULL
NULL                    EQU     
#endif

;Tree depth
FCDICT_TREE_DEPTH       EQU     3

;First CF
FCDICT_FIRST_CF         EQU     CF_TWO_DROP

;Character count of the first word
FCDICT_FIRST_CC         EQU     5                               ;"2DROP"

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
FCDICT_TREE             FCS     "2"
                        DB      BRANCH
                        DW      FCDICT_TREE_0                   ;2...
                        FCS     ">INT"
                        DW      CF_TO_INT                       ;-> >INT
                        FCS     "C"
                        DB      BRANCH
                        DW      FCDICT_TREE_2                   ;C...
                        FCS     "D"
                        DB      BRANCH
                        DW      FCDICT_TREE_3                   ;D...
                        FCS     "L"
                        DB      BRANCH
                        DW      FCDICT_TREE_4                   ;L...
                        FCS     "NOP"
                        DW      CF_NOP                          ;-> NOP
                        FCS     "OVER"
                        DW      CF_OVER                         ;-> OVER
                        FCS     "P"
                        DB      BRANCH
                        DW      FCDICT_TREE_7                   ;P...
                        FCS     "QUERY"
                        DW      CF_QUERY                        ;-> QUERY
                        FCS     "ROT"
                        DW      CF_ROT                          ;-> ROT
                        FCS     "S"
                        DB      BRANCH
                        DW      FCDICT_TREE_10                  ;S...
                        FCS     "WORDS"
                        DB      BRANCH
                        DW      FCDICT_TREE_11                  ;WORDS...
                        ;DB     END_OF_BRANCH
;Subtree 11 =>          "WORDS" -> FCDICT_TREE+3D
FCDICT_TREE_11          DB      EMPTY_STRING
                        DW      CF_WORDS                        ;-> WORDS
                        FCS     "-CDICT"
                        DW      CF_WORDS_CDICT                  ;-> WORDS-CDICT
                        DB      END_OF_BRANCH
;Subtree 0 =>           "2"     -> FCDICT_TREE+49
FCDICT_TREE_0           FCS     "D"
                        DB      BRANCH
                        DW      FCDICT_TREE_0_0                 ;2D...
                        FCS     "OVER"
                        DW      CF_TWO_OVER                     ;-> 2OVER
                        FCS     "ROT"
                        DW      CF_2ROT                         ;-> 2ROT
                        FCS     "SWAP"
                        DW      CF_TWO_SWAP                     ;-> 2SWAP
                        DB      END_OF_BRANCH
;Subtree 0->0 =>        "2D"    -> FCDICT_TREE+5F
FCDICT_TREE_0_0         FCS     "ROP"
                        DW      CF_TWO_DROP                     ;-> 2DROP
                        FCS     "UP"
                        DW      CF_TWO_DUP                      ;-> 2DUP
                        DB      END_OF_BRANCH
;Subtree 2 =>           "C"     -> FCDICT_TREE+69
FCDICT_TREE_2           FCS     "OMPILE,"
                        DW      CF_COMPILE_COMMA                ;-> COMPILE,
                        FCS     "R"
                        DW      CF_CR                           ;-> CR
                        DB      END_OF_BRANCH
;Subtree 3 =>           "D"     -> FCDICT_TREE+76
FCDICT_TREE_3           FCS     "ROP"
                        DW      CF_DROP                         ;-> DROP
                        FCS     "UP"
                        DW      CF_DUP                          ;-> DUP
                        DB      END_OF_BRANCH
;Subtree 4 =>           "L"     -> FCDICT_TREE+80
FCDICT_TREE_4           FCS     "ITERAL"
                        DW      CF_LITERAL                      ;-> LITERAL
                        FCS     "U"
                        DB      BRANCH
                        DW      FCDICT_TREE_4_1                 ;LU...
                        ;DB     END_OF_BRANCH
;Subtree 4->1 =>        "LU"    -> FCDICT_TREE+8C
FCDICT_TREE_4_1         DB      EMPTY_STRING
                        DW      CF_LU                           ;-> LU
                        FCS     "-CDICT"
                        DW      CF_LU_CDICT                     ;-> LU-CDICT
                        DB      END_OF_BRANCH
;Subtree 7 =>           "P"     -> FCDICT_TREE+98
FCDICT_TREE_7           FCS     "ARSE"
                        DW      CF_PARSE                        ;-> PARSE
                        FCS     "ROMPT"
                        DW      CF_PROMPT                       ;-> PROMPT
                        DB      END_OF_BRANCH
;Subtree 10 =>          "S"     -> FCDICT_TREE+A6
FCDICT_TREE_10          FCS     "PACE"
                        DB      BRANCH
                        DW      FCDICT_TREE_10_0                ;SPACE...
                        FCS     "WAP"
                        DW      CF_SWAP                         ;-> SWAP
                        FCS     "YNTAX-ERROR"
                        DW      CF_SYNTAX_ERROR                 ;-> SYNTAX-ERROR
                        ;DB     END_OF_BRANCH
;Subtree 10->0 =>       "SPACE" -> FCDICT_TREE+BF
FCDICT_TREE_10_0        DB      EMPTY_STRING
                        DW      CF_SPACE                        ;-> SPACE
                        FCS     "S"
                        DW      CF_SPACES                       ;-> SPACES
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
                        MOVW #(\1+$00), (\3+$04),\2   ;FCDICT_TREE         ("2")
                        MOVW #(\1+$49), (\3+$02),\2   ;FCDICT_TREE_0       ("D")
                        MOVW #(\1+$5F), (\3+$00),\2   ;FCDICT_TREE_0_0     ("ROP")
#emac

#endif
