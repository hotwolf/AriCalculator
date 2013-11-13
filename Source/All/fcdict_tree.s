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
#emac
#endif
