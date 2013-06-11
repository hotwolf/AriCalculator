;###############################################################################
;# S12CForth- FCDICT - Core Dictionary of the S12CForth Framework              #
;###############################################################################
;#    Copyright 2010 - 2013 Dirk Heisswolf                                     #
;#    This file is part of the S12CForth framework for Freescale's S12C MCU    #
;#    family.                                                                  #
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
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    April 23, 2009                                                           #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    FEXCPT - Forth Exception Handler                                         #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FCDICT_VARS_START_LIN
			ORG 	FCDICT_VARS_START, FRS_VARS_START_LIN
#else
			ORG 	FCDICT_VARS_START
FCDICT_VARS_START_LIN	EQU	@

FCDICT_VARS_END		EQU	*
FCDICT_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FCDICT_INIT, 0
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FCDICT_CODE_START_LIN
			ORG 	FCDICT_CODE_START, FCDICT_CODE_START_LIN
#else
			ORG 	FCDICT_CODE_START
FCDICT_CODE_START_LIN	EQU	@
#endif












	
;Skip whitespace
; args:   Y
; SSTACK: none
; PS:     none
; RS:     none
; throws: nothing
#macro	FCORE_DICT_SKIP, 0
#emac


			;Skip whitespace (string pointer in X, dict pointer in Y)
			STRING_SKIP_WS 			;truncate preceding whitespaces (SSTACK: 3 bytes)

			;Check string character (string pointer in X, dict pointer in Y)
			LDD	1,X+ 			;load next two characters
			BMI	FCORE_DICT_FIND_ 	;last character in word
			CMPB	#$20			;" "	
			BLS	FCORE_DICT_FIND_ 	;last character in word
			
			
			
	


			STRING_UPPER			;make upper case  (SSTACK: 3 bytes)
			TSTB
	
			;Check dictionary tree (char in B, next char pointer in X, dict pointer in Y)
FCORE_DICT_FIND_1	LDAA	1,Y+   			;check subtree
			BEQ	FCORE_DICT_FIND_	;zero termination found
			BMI	FCORE_DICT_FIND_ 	;end of substring
			CBA
			BEQ	FCORE_DICT_FIND_6 	;character match



	
			;Skip to next subtree (char in B, next char pointer in X, dict pointer in Y)
FCORE_DICT_FIND_2	TST	1,Y+			;skip to next substring
			BEQ	FCORE_DICT_FIND_3	;zero termination found	
			BPL	FCORE_DICT_FIND_2	;no termination found
FCORE_DICT_FIND_3	TST	2,+Y 			;skip over pointer
			BNE	FCORE_DICT_FIND_1	;check next subtree
			
			;Word not found
			LDX	#$0000
			;Done

	
			;End of substring found ()
			ANDA	#$7F
			
			






	
	
			JOB	FCORE_DICT_FIND_1	;try next substring
	



				BPL	LABEL_NEXT_SUBSTR
			;End of substring (next char pointer in Y, subtree pointer in X)
FCORE_DICT_FIND_5	LDX	2,X+
			JOB	FCORE_DICT_FIND_2	;next substring
				
			;Check next string character (next char pointer in Y, dict pointer in X)
FCORE_DICT_FIND_6	LDD	1,Y+
			BPL	FCORE_DICT_FIND_1a	;not end of string, yet
			
			;End of string (char in A, next char pointer in Y, dict pointer in X)
FCORE_DICT_FIND_7	ANDA	#$7F
			LDAB	1,X+   			;check character in dictionary
			BMI	FCORE_DICT_FIND_
			CBA
			BNE	FAIL
			TST	1,X+   			;check for termination
			BNE	FAIL


			


	

LABEL_1			LDAA	1,+Y 			;load character	

	

	;; first match
	;; next match
	;; lookup







	
FCDICT_CODE_END		EQU	*
FCDICT_CODE_END_LIN	EQU	@

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef FCDICT_TABS_START_LIN
			ORG 	FCDICT_TABS_START, FCDICT_TABS_START_LIN
#else
			ORG 	FCDICT_TABS_START
FCDICT_TABS_START_LIN	EQU	@
#endif	

;#Dictionary tree
FCDICT_TREE		FCDICT_TREE

FCDICT_TABS_END		EQU	*
FCDICT_TABS_END_LIN	EQU	@

;###############################################################################
;# Words                                                                       #
;###############################################################################
#ifdef FCDICT_WORDS_START_LIN
			ORG 	FCDICT_WORDS_START, FCDICT_WORDS_START_LIN
#else
			ORG 	FCDICT_WORDS_START
FCDICT_WORDS_START_LIN	EQU	@
#endif	

FCDICT_WORDS_END		EQU	*
FCDICT_WORDS_END_LIN	EQU	@

