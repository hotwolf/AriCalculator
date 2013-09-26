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
;# Generated on Tue, Oct 08 2013                                               #
;###############################################################################

;###############################################################################
;# Dictionary Tree Structure                                                   #
;###############################################################################
;
; -> " ------------> CFA_QUOTE 
;    . --> " ------> CFA_DOT_QUOTE 
;    |     $ ------> CFA_DOT_STRING 
;    |     PROMPT -> CFA_DOT_PROMPT 
;    |     
;    E --> KEY +---> CFA_EKEY 
;    |     |   ? --> CFA_EKEY_QUESTION 
;    |     |   
;    |     MIT +---> CFA_EMIT 
;    |         ? --> CFA_EMIT_QUESTION 
;    |     
;    NOP ----------> CFA_NOP 
;    QUERY --------> CFA_QUERY 
;    WAIT ---------> CFA_WAIT 

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
FCDICT_TREE_TOP         FCS     '"'
                        DB      STRING_TERMINATION
                        DW      (CFA_QUOTE>>1)                  ;-> "
                        FCS     "."
                        DW      FCDICT_TREE_1                   ;....
                        FCS     "E"
                        DW      FCDICT_TREE_2                   ;E...
                        FCS     "NOP"
                        DB      STRING_TERMINATION
                        DW      (CFA_NOP>>1)                    ;-> NOP
                        FCS     "QUERY"
                        DB      STRING_TERMINATION
                        DW      (CFA_QUERY>>1)                  ;-> QUERY
                        FCS     "WAIT"
                        DB      STRING_TERMINATION
                        DW      (CFA_WAIT>>1)                   ;-> WAIT
                        DB      END_OF_SUBTREE
;Subtree 1 => "."
FCDICT_TREE_1           FCS     '"'
                        DB      STRING_TERMINATION
                        DW      (CFA_DOT_QUOTE>>1)              ;-> ."
                        FCS     "$"
                        DB      STRING_TERMINATION
                        DW      (CFA_DOT_STRING>>1)             ;-> .$
                        FCS     "PROMPT"
                        DB      STRING_TERMINATION
                        DW      (CFA_DOT_PROMPT>>1)             ;-> .PROMPT
                        DB      END_OF_SUBTREE
;Subtree 2 => "E"
FCDICT_TREE_2           FCS     "KEY"
                        DW      FCDICT_TREE_2_0                 ;EKEY...
                        FCS     "MIT"
                        DW      FCDICT_TREE_2_1                 ;EMIT...
                        ;DB     END_OF_SUBTREE
;Subtree 2->0 => "EKEY"
FCDICT_TREE_2_0         DB      STRING_TERMINATION
                        DW      (CFA_EKEY>>1)                   ;-> EKEY
                        FCS     "?"
                        DB      STRING_TERMINATION
                        DW      (CFA_EKEY_QUESTION>>1)          ;-> EKEY?
                        DB      END_OF_SUBTREE
;Subtree 2->1 => "EMIT"
FCDICT_TREE_2_1         DB      STRING_TERMINATION
                        DW      (CFA_EMIT>>1)                   ;-> EMIT
                        FCS     "?"
                        DB      STRING_TERMINATION
                        DW      (CFA_EMIT_QUESTION>>1)          ;-> EMIT?
                        DB      END_OF_SUBTREE
#emac
#endif
