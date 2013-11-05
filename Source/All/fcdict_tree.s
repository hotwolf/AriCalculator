;###############################################################################
;# S12CForth - Search Tree for the Core Dictionary                             #
;###############################################################################
;#    Copyright 2009-2013 Dirk Heisswolf                                       #
;#    This file is part of the S12CForth framework for Freescale's S12(X) MCU  #
;#    familtree_layout_widthies.                                                                #
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
;# Generated on Tue, Nov 05 2013                                               #
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
;    > -------> IN -------------> CFA_TO_IN 
;    |          NUMBER ---------> CFA_TO_NUMBER 
;    |          
;    BASE ----------------------> CFA_BASE 
;    D. ------> +---------------> CFA_D_DOT 
;    |          R --------------> CFA_D_DOT_R 
;    |          
;    E -------> KEY -> +--------> CFA_EKEY 
;    |          |      ? -------> CFA_EKEY_QUESTION 
;    |          |      
;    |          MIT ------------> CFA_SPACES 
;    |          
;    HEX. ----------------------> CFA_HEX_DOT 
;    INTEGER -------------------> CFA_INTEGER 
;    MINUS ---------------------> CFA_MINUS 
;    NOP -----------------------> CFA_NOP 
;    P -------> ARSE -----------> CFA_PARSE 
;    |          RIO ------------> CFA_PRIO 
;    |          
;    QUERY ---------------------> CFA_QUERY 
;    S -------> EARCH-CDICT ----> CFA_SEARCH_CDICT 
;    |          PACE -----------> CFA_SPACE 
;    |          TATE -----------> CFA_STATE 
;    |          
;    U. ------------------------> CFA_U_DOT 
;    WAIT ----------------------> CFA_WAIT 

;###############################################################################
;# Macros                                                                      #
;###############################################################################

#ifndef FCDICT_TREE_EXTSTS
FCDICT_TREE_EXISTS      EQU     1

;Instantiate dictionary tree
; args:   none
; result: none
; SSTACK: none
; PS:     none
; RS:     none
; throws: nothing
#macro       FCDICT_TREE, 0
;Local constants
STRING_TERMINATION      EQU     $00
END_OF_SUBTREE          EQU     $00
IMMEDIATE               EQU     $8000
;Root
FCDICT_TREE_TOP         FCS     "#TIB"
                        DB      STRING_TERMINATION
                        DW      (CFA_NUMBER_TIB>>1)             ;-> #TIB
                        FCS     "$."
                        DB      STRING_TERMINATION
                        DW      (CFA_STRING_DOT>>1)             ;-> $.
                        FCS     "."
                        DW      FCDICT_TREE_2                   ;....
                        FCS     ">"
                        DW      FCDICT_TREE_3                   ;>...
                        FCS     "BASE"
                        DB      STRING_TERMINATION
                        DW      (CFA_BASE>>1)                   ;-> BASE
                        FCS     "D."
                        DW      FCDICT_TREE_5                   ;D....
                        FCS     "E"
                        DW      FCDICT_TREE_6                   ;E...
                        FCS     "HEX."
                        DB      STRING_TERMINATION
                        DW      (CFA_HEX_DOT>>1)                ;-> HEX.
                        FCS     "INTEGER"
                        DB      STRING_TERMINATION
                        DW      (CFA_INTEGER>>1)                ;-> INTEGER
                        FCS     "MINUS"
                        DB      STRING_TERMINATION
                        DW      (CFA_MINUS>>1)                  ;-> MINUS
                        FCS     "NOP"
                        DB      STRING_TERMINATION
                        DW      (CFA_NOP>>1)                    ;-> NOP
                        FCS     "P"
                        DW      FCDICT_TREE_11                  ;P...
                        FCS     "QUERY"
                        DB      STRING_TERMINATION
                        DW      (CFA_QUERY>>1)                  ;-> QUERY
                        FCS     "S"
                        DW      FCDICT_TREE_13                  ;S...
                        FCS     "U."
                        DB      STRING_TERMINATION
                        DW      (CFA_U_DOT>>1)                  ;-> U.
                        FCS     "WAIT"
                        DB      STRING_TERMINATION
                        DW      (CFA_WAIT>>1)                   ;-> WAIT
                        ;DB     END_OF_SUBTREE
;Subtree 2 => "."
FCDICT_TREE_2           DB      STRING_TERMINATION
                        DW      (CFA_DOT>>1)                    ;-> .
                        FCS     "PROMPT"
                        DB      STRING_TERMINATION
                        DW      (CFA_DOT_PROMPT>>1)             ;-> .PROMPT
                        FCS     "R"
                        DB      STRING_TERMINATION
                        DW      (CFA_DOT_R>>1)                  ;-> .R
                        DB      END_OF_SUBTREE
;Subtree 3 => ">"
FCDICT_TREE_3           FCS     "IN"
                        DB      STRING_TERMINATION
                        DW      (CFA_TO_IN>>1)                  ;-> >IN
                        FCS     "NUMBER"
                        DB      STRING_TERMINATION
                        DW      (CFA_TO_NUMBER>>1)              ;-> >NUMBER
                        DB      END_OF_SUBTREE
;Subtree 5 => "D."
FCDICT_TREE_5           DB      STRING_TERMINATION
                        DW      (CFA_D_DOT>>1)                  ;-> D.
                        FCS     "R"
                        DB      STRING_TERMINATION
                        DW      (CFA_D_DOT_R>>1)                ;-> D.R
                        DB      END_OF_SUBTREE
;Subtree 6 => "E"
FCDICT_TREE_6           FCS     "KEY"
                        DW      FCDICT_TREE_6_0                 ;EKEY...
                        FCS     "MIT"
                        DB      STRING_TERMINATION
                        DW      (CFA_SPACES>>1)                 ;-> EMIT
                        ;DB     END_OF_SUBTREE
;Subtree 6->0 => "EKEY"
FCDICT_TREE_6_0         DB      STRING_TERMINATION
                        DW      (CFA_EKEY>>1)                   ;-> EKEY
                        FCS     "?"
                        DB      STRING_TERMINATION
                        DW      (CFA_EKEY_QUESTION>>1)          ;-> EKEY?
                        DB      END_OF_SUBTREE
;Subtree 11 => "P"
FCDICT_TREE_11          FCS     "ARSE"
                        DB      STRING_TERMINATION
                        DW      (CFA_PARSE>>1)                  ;-> PARSE
                        FCS     "RIO"
                        DB      STRING_TERMINATION
                        DW      (CFA_PRIO>>1)                   ;-> PRIO
                        DB      END_OF_SUBTREE
;Subtree 13 => "S"
FCDICT_TREE_13          FCS     "EARCH-CDICT"
                        DB      STRING_TERMINATION
                        DW      (CFA_SEARCH_CDICT>>1)           ;-> SEARCH-CDICT
                        FCS     "PACE"
                        DB      STRING_TERMINATION
                        DW      (CFA_SPACE>>1)                  ;-> SPACE
                        FCS     "TATE"
                        DB      STRING_TERMINATION
                        DW      (CFA_STATE>>1)                  ;-> STATE
                        DB      END_OF_SUBTREE
#emac
#endif
