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
;# Generated on Sat, Oct 15 2016                                               #
;###############################################################################

;###############################################################################
;# Dictionary Tree Structure                                                   #
;###############################################################################
;
; -> $ -----> , -------------------> CF_STRING_COMMA
;    |        . -------------------> CF_STRING_DOT
;    |        
;    2 -----> D ----> ROP ---------> CF_TWO_DROP
;    |        |       UP ----------> CF_TWO_DUP
;    |        |       
;    |        OVER ----------------> CF_TWO_OVER
;    |        ROT -----------------> CF_2ROT
;    |        SWAP ----------------> CF_TWO_SWAP
;    |        
;    >INT -------------------------> CF_TO_INT
;    ABORT -> ---------------------> CF_ABORT
;    |        " -------------------> CF_ABORT_QUOTE
;    |        
;    C -----> ATCH ----------------> CF_CATCH
;    |        OMPILE, -------------> CF_COMPILE_COMMA
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
;    QU ----> ERY -----------------> CF_QUERY
;    |        IT ------------------> CF_QUIT
;    |        
;    R -----> OT ------------------> CF_ROT
;    |        TERR. ---------------> CF_RTERR_DOT
;    |        
;    S -----> KIP&PARSE -----------> CF_SKIP_AND_PARSE
;    |        PACE ----------------> CF_SPACE
;    |        WAP -----------------> CF_SWAP
;    |        YNERR. --------------> CF_SYNERR_DOT
;    |        
;    THROW ------------------------> CF_THROW
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
FCDICT_FIRST_CF         EQU     CF_STRING_COMMA

;Character count of the first word
FCDICT_FIRST_CC         EQU     2                               ;"$,"

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
FCDICT_TREE             FCS     "$"
                        DB      BRANCH
                        DW      FCDICT_TREE_0                   ;$...
                        FCS     "2"
                        DB      BRANCH
                        DW      FCDICT_TREE_1                   ;2...
                        FCS     ">INT"
                        DW      CF_TO_INT                       ;-> >INT
                        FCS     "ABORT"
                        DB      BRANCH
                        DW      FCDICT_TREE_3                   ;ABORT...
                        FCS     "C"
                        DB      BRANCH
                        DW      FCDICT_TREE_4                   ;C...
                        FCS     "D"
                        DB      BRANCH
                        DW      FCDICT_TREE_5                   ;D...
                        FCS     "L"
                        DB      BRANCH
                        DW      FCDICT_TREE_6                   ;L...
                        FCS     "NOP"
                        DW      CF_NOP                          ;-> NOP
                        FCS     "OVER"
                        DW      CF_OVER                         ;-> OVER
                        FCS     "P"
                        DB      BRANCH
                        DW      FCDICT_TREE_9                   ;P...
                        FCS     "QU"
                        DB      BRANCH
                        DW      FCDICT_TREE_10                  ;QU...
                        FCS     "R"
                        DB      BRANCH
                        DW      FCDICT_TREE_11                  ;R...
                        FCS     "S"
                        DB      BRANCH
                        DW      FCDICT_TREE_12                  ;S...
                        FCS     "THROW"
                        DW      CF_THROW                        ;-> THROW
                        FCS     "WORDS"
                        DB      BRANCH
                        DW      FCDICT_TREE_14                  ;WORDS...
                        ;DB     END_OF_BRANCH
;Subtree 3 =>           "ABORT" -> FCDICT_TREE+4D
FCDICT_TREE_3           DB      EMPTY_STRING
                        DW      CF_ABORT                        ;-> ABORT
                        FCS     '"'
                        DW      CF_ABORT_QUOTE                  ;-> ABORT"
                        DB      END_OF_BRANCH
;Subtree 0 =>           "$"     -> FCDICT_TREE+54
FCDICT_TREE_0           FCS     ","
                        DW      CF_STRING_COMMA                 ;-> $,
                        FCS     "."
                        DW      CF_STRING_DOT                   ;-> $.
                        DB      END_OF_BRANCH
;Subtree 1 =>           "2"     -> FCDICT_TREE+5B
FCDICT_TREE_1           FCS     "D"
                        DB      BRANCH
                        DW      FCDICT_TREE_1_0                 ;2D...
                        FCS     "OVER"
                        DW      CF_TWO_OVER                     ;-> 2OVER
                        FCS     "ROT"
                        DW      CF_2ROT                         ;-> 2ROT
                        FCS     "SWAP"
                        DW      CF_TWO_SWAP                     ;-> 2SWAP
                        DB      END_OF_BRANCH
;Subtree 1->0 =>        "2D"    -> FCDICT_TREE+71
FCDICT_TREE_1_0         FCS     "ROP"
                        DW      CF_TWO_DROP                     ;-> 2DROP
                        FCS     "UP"
                        DW      CF_TWO_DUP                      ;-> 2DUP
                        DB      END_OF_BRANCH
;Subtree 4 =>           "C"     -> FCDICT_TREE+7B
FCDICT_TREE_4           FCS     "ATCH"
                        DW      CF_CATCH                        ;-> CATCH
                        FCS     "OMPILE,"
                        DW      CF_COMPILE_COMMA                ;-> COMPILE,
                        FCS     "R"
                        DW      CF_CR                           ;-> CR
                        DB      END_OF_BRANCH
;Subtree 5 =>           "D"     -> FCDICT_TREE+8E
FCDICT_TREE_5           FCS     "ROP"
                        DW      CF_DROP                         ;-> DROP
                        FCS     "UP"
                        DW      CF_DUP                          ;-> DUP
                        DB      END_OF_BRANCH
;Subtree 6 =>           "L"     -> FCDICT_TREE+98
FCDICT_TREE_6           FCS     "ITERAL"
                        DW      CF_LITERAL                      ;-> LITERAL
                        FCS     "U"
                        DB      BRANCH
                        DW      FCDICT_TREE_6_1                 ;LU...
                        ;DB     END_OF_BRANCH
;Subtree 6->1 =>        "LU"    -> FCDICT_TREE+A4
FCDICT_TREE_6_1         DB      EMPTY_STRING
                        DW      CF_LU                           ;-> LU
                        FCS     "-CDICT"
                        DW      CF_LU_CDICT                     ;-> LU-CDICT
                        DB      END_OF_BRANCH
;Subtree 9 =>           "P"     -> FCDICT_TREE+B0
FCDICT_TREE_9           FCS     "ARSE"
                        DW      CF_PARSE                        ;-> PARSE
                        FCS     "ROMPT"
                        DW      CF_PROMPT                       ;-> PROMPT
                        DB      END_OF_BRANCH
;Subtree 10 =>          "QU"    -> FCDICT_TREE+BE
FCDICT_TREE_10          FCS     "ERY"
                        DW      CF_QUERY                        ;-> QUERY
                        FCS     "IT"
                        DW      CF_QUIT                         ;-> QUIT
                        DB      END_OF_BRANCH
;Subtree 11 =>          "R"     -> FCDICT_TREE+C8
FCDICT_TREE_11          FCS     "OT"
                        DW      CF_ROT                          ;-> ROT
                        FCS     "TERR."
                        DW      CF_RTERR_DOT                    ;-> RTERR.
                        DB      END_OF_BRANCH
;Subtree 12 =>          "S"     -> FCDICT_TREE+D4
FCDICT_TREE_12          FCS     "KIP&PARSE"
                        DW      CF_SKIP_AND_PARSE               ;-> SKIP&PARSE
                        FCS     "PACE"
                        DW      CF_SPACE                        ;-> SPACE
                        FCS     "WAP"
                        DW      CF_SWAP                         ;-> SWAP
                        FCS     "YNERR."
                        DW      CF_SYNERR_DOT                   ;-> SYNERR.
                        DB      END_OF_BRANCH
;Subtree 14 =>          "WORDS" -> FCDICT_TREE+F3
FCDICT_TREE_14          DB      EMPTY_STRING
                        DW      CF_WORDS                        ;-> WORDS
                        FCS     "-CDICT"
                        DW      CF_WORDS_CDICT                  ;-> WORDS-CDICT
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
                        MOVW #(\1+$00), (\3+$04),\2   ;FCDICT_TREE         ("$")
                        MOVW #(\1+$54), (\3+$02),\2   ;FCDICT_TREE_0       (",")
                        MOVW #NULL,     (\3+$00),\2   ;unused
#emac

#endif
