;###############################################################################
;# S12CForth - Search Tree for the Core Dictionary                             #
;###############################################################################
;#    Copyright 2009-2013 Dirk Heisswolf                                       #
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
;# Generated on Tue, Jan 07 2014                                               #
;###############################################################################

;###############################################################################
;# Dictionary Tree Structure                                                   #
;###############################################################################
;
; -> #TIB ----------------------> CFA_NUMBER_TIB 
;    $. ------------------------> CFA_STRING_DOT 
;    . -------> +---------------> CFA_DOT 
;    |          PROMPT ---------> CFA_DOT_PROMPT 
;    |          R --------------> CFA_DOT_R 
;    |          
;    2 -------> D ----> ROP ----> CFA_TWO_DROP 
;    |          |       UP -----> CFA_TWO_DUP 
;    |          |       
;    |          OVER -----------> CFA_TWO_OVER 
;    |          ROT ------------> CFA_TWO_ROT 
;    |          SWAP -----------> CFA_TWO_SWAP 
;    |          
;    > -------> IN -------------> CFA_TO_IN 
;    |          NUMBER ---------> CFA_TO_NUMBER 
;    |          
;    BASE ----------------------> CFA_BASE 
;    C -------> ATCH -----------> CFA_CATCH 
;    |          R --------------> CFA_CR 
;    |          
;    D -------> . ---> +--------> CFA_D_DOT 
;    |          |      R -------> CFA_D_DOT_R 
;    |          |      
;    |          ROP ------------> CFA_DROP 
;    |          UP -------------> CFA_DUP 
;    |          
;    E -------> KEY -> +--------> CFA_EKEY 
;    |          |      ? -------> CFA_EKEY_QUESTION 
;    |          |      
;    |          MIT ------------> CFA_EMIT 
;    |          
;    HEX. ----------------------> CFA_HEX_DOT 
;    INTEGER -------------------> CFA_INTEGER 
;    NOP -----------------------> CFA_NOP 
;    OVER ----------------------> CFA_OVER 
;    P -------> ARSE -----------> CFA_PARSE 
;    |          RIO ------------> CFA_PRIO 
;    |          
;    QUERY ---> +---------------> CFA_QUERY 
;    |          -APPEND --------> CFA_QUERY_APPEND 
;    |          
;    ROT -----------------------> CFA_ROT 
;    S -------> EARCH-CDICT ----> CFA_SEARCH_CDICT 
;    |          PACES ----------> CFA_SPACES 
;    |          TATE -----------> CFA_STATE 
;    |          WAP ------------> CFA_SWAP 
;    |          
;    T -------> DICT -----------> CFA_TDICT 
;    |          HROW -----------> CFA_THROW 
;    |          IB-OFFSET ------> CFA_TIB_OFFSET 
;    |          
;    U. ------------------------> CFA_U_DOT 
;    W -------> AIT ------------> CFA_WAIT 
;               ORDS-CDICT -----> CFA_WORDS_CDICT 

;###############################################################################
;# Macros                                                                      #
;###############################################################################

#ifndef FCDICT_TREE_EXTSTS
FCDICT_TREE_EXISTS      EQU     1

;Global constants
FCDICT_TREE_DEPTH       EQU     3

;Dictionary tree
#macro       FCDICT_TREE, 0
;Local constants
EMPTY_STRING            EQU     $00
BRANCH                  EQU     $00
END_OF_BRANCH           EQU     $00
IMMEDIATE               EQU     $8000
;Root
FCDICT_TREE_TOP         FCS     "#TIB"
                        DW      (CFA_NUMBER_TIB>>1)             ;-> #TIB
                        FCS     "$."
                        DW      (CFA_STRING_DOT>>1)             ;-> $.
                        FCS     "."
                        DB      BRANCH
                        DW      FCDICT_TREE_2                   ;....
                        FCS     "2"
                        DB      BRANCH
                        DW      FCDICT_TREE_3                   ;2...
                        FCS     ">"
                        DB      BRANCH
                        DW      FCDICT_TREE_4                   ;>...
                        FCS     "BASE"
                        DW      (CFA_BASE>>1)                   ;-> BASE
                        FCS     "C"
                        DB      BRANCH
                        DW      FCDICT_TREE_6                   ;C...
                        FCS     "D"
                        DB      BRANCH
                        DW      FCDICT_TREE_7                   ;D...
                        FCS     "E"
                        DB      BRANCH
                        DW      FCDICT_TREE_8                   ;E...
                        FCS     "HEX."
                        DW      (CFA_HEX_DOT>>1)                ;-> HEX.
                        FCS     "INTEGER"
                        DW      (CFA_INTEGER>>1)                ;-> INTEGER
                        FCS     "NOP"
                        DW      (CFA_NOP>>1)                    ;-> NOP
                        FCS     "OVER"
                        DW      (CFA_OVER>>1)                   ;-> OVER
                        FCS     "P"
                        DB      BRANCH
                        DW      FCDICT_TREE_13                  ;P...
                        FCS     "QUERY"
                        DB      BRANCH
                        DW      FCDICT_TREE_14                  ;QUERY...
                        FCS     "ROT"
                        DW      (CFA_ROT>>1)                    ;-> ROT
                        FCS     "S"
                        DB      BRANCH
                        DW      FCDICT_TREE_16                  ;S...
                        FCS     "T"
                        DB      BRANCH
                        DW      FCDICT_TREE_17                  ;T...
                        FCS     "U."
                        DW      (CFA_U_DOT>>1)                  ;-> U.
                        FCS     "W"
                        DB      BRANCH
                        DW      FCDICT_TREE_19                  ;W...
                        ;DB     END_OF_BRANCH
;Subtree 2 => "."
FCDICT_TREE_2           DB      EMPTY_STRING
                        DW      (CFA_DOT>>1)                    ;-> .
                        FCS     "PROMPT"
                        DW      (CFA_DOT_PROMPT>>1)             ;-> .PROMPT
                        FCS     "R"
                        DW      (CFA_DOT_R>>1)                  ;-> .R
                        DB      END_OF_BRANCH
;Subtree 3 => "2"
FCDICT_TREE_3           FCS     "D"
                        DB      BRANCH
                        DW      FCDICT_TREE_3_0                 ;2D...
                        FCS     "OVER"
                        DW      (CFA_TWO_OVER>>1)               ;-> 2OVER
                        FCS     "ROT"
                        DW      (CFA_TWO_ROT>>1)                ;-> 2ROT
                        FCS     "SWAP"
                        DW      (CFA_TWO_SWAP>>1)               ;-> 2SWAP
                        DB      END_OF_BRANCH
;Subtree 3->0 => "2D"
FCDICT_TREE_3_0         FCS     "ROP"
                        DW      (CFA_TWO_DROP>>1)               ;-> 2DROP
                        FCS     "UP"
                        DW      (CFA_TWO_DUP>>1)                ;-> 2DUP
                        DB      END_OF_BRANCH
;Subtree 4 => ">"
FCDICT_TREE_4           FCS     "IN"
                        DW      (CFA_TO_IN>>1)                  ;-> >IN
                        FCS     "NUMBER"
                        DW      (CFA_TO_NUMBER>>1)              ;-> >NUMBER
                        DB      END_OF_BRANCH
;Subtree 6 => "C"
FCDICT_TREE_6           FCS     "ATCH"
                        DW      (CFA_CATCH>>1)                  ;-> CATCH
                        FCS     "R"
                        DW      (CFA_CR>>1)                     ;-> CR
                        DB      END_OF_BRANCH
;Subtree 7 => "D"
FCDICT_TREE_7           FCS     "."
                        DB      BRANCH
                        DW      FCDICT_TREE_7_0                 ;D....
                        FCS     "ROP"
                        DW      (CFA_DROP>>1)                   ;-> DROP
                        FCS     "UP"
                        DW      (CFA_DUP>>1)                    ;-> DUP
                        ;DB     END_OF_BRANCH
;Subtree 7->0 => "D."
FCDICT_TREE_7_0         DB      EMPTY_STRING
                        DW      (CFA_D_DOT>>1)                  ;-> D.
                        FCS     "R"
                        DW      (CFA_D_DOT_R>>1)                ;-> D.R
                        DB      END_OF_BRANCH
;Subtree 8 => "E"
FCDICT_TREE_8           FCS     "KEY"
                        DB      BRANCH
                        DW      FCDICT_TREE_8_0                 ;EKEY...
                        FCS     "MIT"
                        DW      (CFA_EMIT>>1)                   ;-> EMIT
                        ;DB     END_OF_BRANCH
;Subtree 8->0 => "EKEY"
FCDICT_TREE_8_0         DB      EMPTY_STRING
                        DW      (CFA_EKEY>>1)                   ;-> EKEY
                        FCS     "?"
                        DW      (CFA_EKEY_QUESTION>>1)          ;-> EKEY?
                        DB      END_OF_BRANCH
;Subtree 13 => "P"
FCDICT_TREE_13          FCS     "ARSE"
                        DW      (CFA_PARSE>>1)                  ;-> PARSE
                        FCS     "RIO"
                        DW      (CFA_PRIO>>1)                   ;-> PRIO
                        DB      END_OF_BRANCH
;Subtree 14 => "QUERY"
FCDICT_TREE_14          DB      EMPTY_STRING
                        DW      (CFA_QUERY>>1)                  ;-> QUERY
                        FCS     "-APPEND"
                        DW      (CFA_QUERY_APPEND>>1)           ;-> QUERY-APPEND
                        DB      END_OF_BRANCH
;Subtree 16 => "S"
FCDICT_TREE_16          FCS     "EARCH-CDICT"
                        DW      (CFA_SEARCH_CDICT>>1)           ;-> SEARCH-CDICT
                        FCS     "PACES"
                        DW      (CFA_SPACES>>1)                 ;-> SPACES
                        FCS     "TATE"
                        DW      (CFA_STATE>>1)                  ;-> STATE
                        FCS     "WAP"
                        DW      (CFA_SWAP>>1)                   ;-> SWAP
                        DB      END_OF_BRANCH
;Subtree 17 => "T"
FCDICT_TREE_17          FCS     "DICT"
                        DW      (CFA_TDICT>>1)                  ;-> TDICT
                        FCS     "HROW"
                        DW      (CFA_THROW>>1)                  ;-> THROW
                        FCS     "IB-OFFSET"
                        DW      (CFA_TIB_OFFSET>>1)             ;-> TIB-OFFSET
                        DB      END_OF_BRANCH
;Subtree 19 => "W"
FCDICT_TREE_19          FCS     "AIT"
                        DW      (CFA_WAIT>>1)                   ;-> WAIT
                        FCS     "ORDS-CDICT"
                        DW      (CFA_WORDS_CDICT>>1)            ;-> WORDS-CDICT
                        DB      END_OF_BRANCH
#emac
#endif
