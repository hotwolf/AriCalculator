#ifndef FENV_TREE_COMPILED
#define FENV_TREE_COMPILED
;###############################################################################
;# S12CForth - Search Tree for the Core Environment                            #
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
;#    This file contains a search tree for S12CForth environment queries.      #
;#                                                                             #
;###############################################################################
;# Generated on Mon, Nov 14 2016                                               #
;###############################################################################

;###############################################################################
;# Environment Tree Structure                                                   #
;###############################################################################
;
; -> / ------------------> COUNTED-STRING ----> ENV_COUNTED_STRING
;    |                     HOLD --------------> ENV_HOLD
;    |                     PAD ---------------> ENV_PAD
;    |                     
;    ADDRESS-UNIT-BITS -----------------------> ENV_ADDRESS_UNIT_BITS
;    CORE ---------------> -------------------> ENV_CORE
;    |                     -EXT --------------> ENV_CORE_EXT
;    |                     
;    FLOORED ---------------------------------> ENV_FLOORED
;    MAX- ---------------> CHAR --------------> ENV_MAX_CHAR
;    |                     D -----------------> ENV_MAX_D
;    |                     N -----------------> ENV_MAX_N
;    |                     U ----> -----------> ENV_MAX_U
;    |                             D ---------> ENV_MAX_UD
;    |                     
;    RETURN-STACK-CELLS ----------------------> ENV_RETURN_STACK_CELLS
;    STACK-CELLS -----------------------------> ENV_STACK_CELLS

;###############################################################################
;# Constants                                                                   #
;###############################################################################

;Global constants
#ifndef      NULL
NULL                    EQU     
#endif

;Tree depth
FENV_TREE_DEPTH       EQU     3

;First CF
FENV_FIRST_CF         EQU     ENV_COUNTED_STRING

;Character count of the first word
FENV_FIRST_CC         EQU     15                               ;"/COUNTED-STRING"

;###############################################################################
;# Macros                                                                      #
;###############################################################################

;Environment tree
#macro       FENV_TREE, 0
;Local constants
EMPTY_STRING            EQU     $00
BRANCH                  EQU     $00
END_OF_BRANCH           EQU     $00
;Root
FENV_TREE               FCS     "/"
                        DB      BRANCH
                        DW      FENV_TREE_0                     ;/...
                        FCS     "ADDRESS-UNIT-BITS"
                        DW      ENV_ADDRESS_UNIT_BITS           ;-> ADDRESS-UNIT-BITS
                        FCS     "CORE"
                        DB      BRANCH
                        DW      FENV_TREE_2                     ;CORE...
                        FCS     "FLOORED"
                        DW      ENV_FLOORED                     ;-> FLOORED
                        FCS     "MAX-"
                        DB      BRANCH
                        DW      FENV_TREE_4                     ;MAX-...
                        FCS     "RETURN-STACK-CELLS"
                        DW      ENV_RETURN_STACK_CELLS          ;-> RETURN-STACK-CELLS
                        FCS     "STACK-CELLS"
                        DW      ENV_STACK_CELLS                 ;-> STACK-CELLS
                        ;DB     END_OF_BRANCH
;Subtree 2 =>           "CORE"  -> FENV_TREE+4F
FENV_TREE_2             DB      EMPTY_STRING
                        DW      ENV_CORE                        ;-> CORE
                        FCS     "-EXT"
                        DW      ENV_CORE_EXT                    ;-> CORE-EXT
                        DB      END_OF_BRANCH
;Subtree 0 =>           "/"     -> FENV_TREE+59
FENV_TREE_0             FCS     "COUNTED-STRING"
                        DW      ENV_COUNTED_STRING              ;-> /COUNTED-STRING
                        FCS     "HOLD"
                        DW      ENV_HOLD                        ;-> /HOLD
                        FCS     "PAD"
                        DW      ENV_PAD                         ;-> /PAD
                        DB      END_OF_BRANCH
;Subtree 4 =>           "MAX-"  -> FENV_TREE+75
FENV_TREE_4             FCS     "CHAR"
                        DW      ENV_MAX_CHAR                    ;-> MAX-CHAR
                        FCS     "D"
                        DW      ENV_MAX_D                       ;-> MAX-D
                        FCS     "N"
                        DW      ENV_MAX_N                       ;-> MAX-N
                        FCS     "U"
                        DB      BRANCH
                        DW      FENV_TREE_4_3                   ;MAX-U...
                        ;DB     END_OF_BRANCH
;Subtree 4->3 =>        "MAX-U" -> FENV_TREE+85
FENV_TREE_4_3           DB      EMPTY_STRING
                        DW      ENV_MAX_U                       ;-> MAX-U
                        FCS     "D"
                        DW      ENV_MAX_UD                      ;-> MAX-UD
                        DB      END_OF_BRANCH
#emac

#endif
