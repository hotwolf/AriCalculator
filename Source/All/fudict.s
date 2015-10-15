#ifndef FUDICT_COMPILED
#define FUDICT_COMPILED
;###############################################################################
;# S12CForth- FUDICT - User Dictionary and User Variables                      #
;###############################################################################
;#    Copyright 2010-2015 Dirk Heisswolf                                       #
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
;#    This module implements the volatile user dictionary, user variables, and #
;#    the PAD.                                                                 #
;#                                                                             #
;#    The following registers are implemented:                                 #
;#             CP = Compile pointer                                            #
;#                  Points to the next free space after the dictionary         #
;#       CP_SAVED = Previous compile pointer                                   #
;#                                                                             #
;#    Compile strategy:                                                        #
;#    The user dictionary is 16-bit aligned and is allocated below the NVDICT  #
;#    variables. Both data and compile pointer are represented by the variable #
;#    CP.                                                                      #
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
;# Memory Layout                                                               #
;###############################################################################
;        
;      	                    +--------------+--------------+	     
;         UDICT_PS_START -> |                             | 	     
;                           |     NVDICT Variables        |	     
;                           |                             | <- [DP]	     
;                           | --- --- --- --- --- --- --- |          
;                           |              |              |	     
;                           |       User Dictionary       |	     
;                           |       User Variables        |	     
;                           |              |              | <- [UDICT_LAST_NFA]	     
;                           |              v              |	     
;                       -+- | --- --- --- --- --- --- --- |
;             UDICT_PADDING |                             | <- [CP]	     
;                       -+- | --- --- --- --- --- --- --- |          
;                           |              ^              | <- [HLD]	     
;                           |             PAD             |	     
;                       -+- | --- --- --- --- --- --- --- |          
;             PS_PADDING |  |                             | <- [PAD]          
;                       -+- .                             .          
;                           .                             .          
;                           | --- --- --- --- --- --- --- |          
;                           |              ^              | <- [PSP]	  
;                           |              |              |		  
;                           |       Parameter stack       |		  
;    	                    |              |              |		  
;                           +--------------+--------------+        
;              PS_EMPTY, ->   
;          UDICT_PS_END
;	
;                           Word format:
;                           +---+-------------------------+
;                     NFA-> |IMM|    Previous NFA >> 1    |	
;                           +---+----------+--------------+
;                           |                             | 
;                           |            Name             | 
;                           |                             | 
;                           |              +--------------+ 
;                           |              |    Padding   | 
;                           +--------------+--------------+
;                     CFA-> |     Code Field Pointer      |	
;                           +--------------+--------------+
;                           |                             | 
;                           |            Data             | 
;                           |                             | 
;                           +--------------+--------------+   
	
;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Boundaries
;UDICT_PS_START		EQU	0
;UDICT_PS_END		EQU	0

;Debug option for dictionary overflows
;FUDICT_DEBUG		EQU	1 
	
;Disable dictionary range checks
;FUDICT_NO_CHECK	EQU	1 

;Safety distance between the user dictionary and the PAD
#ifndef UDICT_PADDING
UDICT_PADDING		EQU	4 	;default is 4 bytes
#endif

;PAD SIZE
#ifndef PAD_SIZE
PAD_SIZE		EQU	84 	;default is 84 bytes
#endif
#ifndef PAD_MINSIZE
PAD_MINSIZE		EQU	4 	;default is 4 bytes
#endif
	
;Safety distance between the PAD and the parameter stack
#ifndef PS_PADDING
PS_PADDING		EQU	16 	;default is 16 bytes
#endif

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;NVC variable 
NVC_VOLATILE		EQU	FALSE
NVC_NON_VOLATILE	EQU	TRUE
	
;Max. line length
FUDICT_LINE_WIDTH	EQU	DEFAULT_LINE_WIDTH
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FUDICT_VARS_START_LIN
	ORG 	FUDICT_VARS_START, FUDICT_VARS_START_LIN
#else
			ORG 	FUDICT_VARS_START
FUDICT_VARS_START_LIN	EQU	@
#endif

			ALIGN	1	
CP			DS	2 	;compile pointer (next free space in the dictionary space) 
CP_SAVED		DS	2 	;previous compile pointer

UDICT_LAST_NFA		DS	2 	;pointer to the most recent NFA of the UDICT

FUDICT_VARS_END		EQU	*
FUDICT_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FUDICT_INIT, 0
#ifnmac FNVDICT_INIT
			;Initialize the compile data pointer
			MOVW	#UDICT_PS_START, CP
	
	
			MOVW	#0000, UDICT_LAST_NFA
			LDD	#UDICT_PS_START
			STD	CP
			STD	CP_SAVED
	
			;Initialize PAD (DICT_START in D)
			STD	PAD 		;Pad is allocated on demand
			STD	HLD

#emac

;#Abort action (to be executed in addition of quit action)
#macro	FUDICT_ABORT, 0
#emac
	
;#Quit action
#macro	FUDICT_QUIT, 0
#emac
	
;#Suspend action
#macro	FUDICT_SUSPEND, 0
#emac

;#User dictionary (UDICT)
;========================
;Complile operations:
;====================	
;#Check if there is room in the DICT space and deallocate the PAD (CP+bytes -> X)
; args:   1: required space in bytes (constant, A, B, or D are valid args)
; result: X: CP_PRELIM+new bytes
; SSTACK: none
; throws: FEXCPT_EC_DICTOF
;        Y and D are preserved 
#macro	UDICT_CHECK_OF, 1
			LDX	CP	 		;=> 3 cycles
			LEAX	\1,X			;=> 2 cycles
			STX	PAD			;=> 3 cycles
			STX	HLD			;=> 3 cycles
#ifndef	FUDICT_NO_CHECK
			CPX	PSP			;=> 3 cycles
			BHI	FUDICT_THROW_DICTOF	;=> 3 cycles/ 4 cycles
#endif
							;  -------------------
							;   17 cycles/12 cycles
#emac			

;Compile cell into user dictionary
; args:   X: cell value
; result: X: CP_PRELIM+new bytes
; SSTACK: none
;         X and D are preserved 
#macro	FUDICT_COMPILE_CELL, 0
			STX	[CP] 			;store cell in next free space
			UDICT_CHECK_OF 2		;allocate storage space
#emac			

;Dictionary operations:
;======================	
;#Look-up word in user dictionary 
; args:   X: string pointer (terminated string)
; result: X: execution token (unchanged if word not found)
;	  D: 1=immediate, -1=non-immediate, 0=not found
; SSTACK: 8 bytes
;         Y is preserved
#macro	FUDICT_FIND, 0
			SSTACK_JOBSR	FUDICT_FIND, 8
#emac
	
;#Reverse lookup a CFA and print the corresponding word
; args:   D: CFA
; result: C-flag: set if successful
; SSTACK: 6 bytes
;         All registers are preserved
#macro	FUDICT_REVPRINT, 0
			SSTACK_JOBSR	6
#emac
		
;#Pictured numeric output buffer (PAD)
;=====================================
;PAD_CHECK_OF: check if there is room for one more character on the PAD (HLD -> X)
; args:   none
; result: X: HLD
; SSTACK: none
; throws: FEXCPT_EC_PADOF
;        Y and D are preserved 
#macro	PAD_CHECK_OF, 0
			LDX	HLD 			;=> 3 cycles
			CPX	CP			;=> 3 cycles
			BLS	FUDICT_THROW_PADOF	;=> 3 cycles/ 4 cycles
							;  -------------------
							;   9 cycles/10 cycles
#emac			
	
;PAD_ALLOC: allocate the PAD buffer (PAD_SIZE bytes if possible) (PAD -> D)
; args:   none
; result: D: PAD (= HLD)
; SSTACK: 2 bytes
; throws: FEXCPT_EC_PADOF
;        X and Y are preserved 
#macro	PAD_ALLOC, 0 
			SSTACK_JOBSR	FUDICT_PAD_ALLOC, 2
			TBEQ	D, FUDICT_THROW_PADOF 	;no space available at all
#emac			

;PAD_DEALLOC: deallocate the PAD buffer  (PAD -> D)
; args:   none
; result: D: CP (= HLD = PAD)
; SSTACK: none
;        X and Y are preserved 
#macro	PAD_DEALLOC, 0 
			LDD	CP
			STD	PAD
			STD	HLD
#emac			

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FUDICT_CODE_START_LIN
			ORG 	FUDICT_CODE_START, FUDICT_CODE_START_LIN
#else
			ORG 	FUDICT_CODE_START
FUDICT_CODE_START_LIN	EQU	@
#endif

;#User dictionary (UDICT)
;========================
;Complile operations:
;====================	



;Dictionary operations:
;======================	
;#Look-up word in user dictionary 
; args:   X: string pointer (terminated string)
; result: X: execution token (unchanged if word not found)
;	  D: 1=immediate, -1=non-immediate, 0=not found
; SSTACK: 8 bytes
;         Y is preserved
FUDICT_FIND		EQU	*
			;Save registers (string pointer in X)
			PSHY						;save Y
			PSHX						;string pointer
			MOVW	UDICT_LAST_NFA, 2,-SP			;current NFA	
			;Compare strings (string pointer in X)
FUDICT_FIND_1		LDY	0,SP					;current NFA -> Y
			LEAY	2,Y					;start of dict string -> Y
FUDICT_FIND_2		LDAB	1,X+					;string char -> A
			CMPB	1,Y+ 					;compare chars
			BNE	FUDICT_FIND_ 				;mismatch
			BRCLR	-1,X,#$7F,FUDICT_FIND_2 		;check next char
			;Match (pointer to code field or padding in Y)
			LEAY	1,Y 					;increment dict pointer
			TFR	Y, D 					;dict pointer -> D
			ANDB	#$FE 					;align dict pointer
			TFR	D, X 					;execution  token -> X
			LDAB	[0,SP] 					;immediate flag -> B
			LSLB						;immediate flag -> C
			ROLB						;immediate flag -> B
			LSLB						;B*2 -> B
			DECB						;B-1 -> B
			SEX	B, D					;B -> D
			;Done (result in D, execution token/string pointer X)
FUDICT_FIND_3		SSTACK_PREPULL	8 				;check stack
			LDY	4,+SP					;restore Y	
			RTS
			;Mismatch
			STX	2,SP 					;string pointer -> X
			LDD	[0,SP] 					;previous NFA  -> D
			LSLD						;remove immediate flag
			STD	0,SP 					;update current NFA
			BNE	FUDICT_FIND_1 				;compare strings
			;Search unsuccessful (string pointer in X)
			CLRA						;set result
			CLRB
			JOB	FUDICT_FIND_3 				;done





;#Pictured numeric output buffer (PAD)
;=====================================







	
;PAD_ALLOC: allocate the PAD buffer (PAD_SIZE bytes if possible) (PAD -> D)
; args:   none
; result: D: PAD (= HLD), $0000 if no space is available
; SSTACK: 2
;        X and Y are preserved 
FUDICT_PAD_ALLOC	EQU	*
			;Calculate available space
			LDD	PSP
			SUBD	CP
			;BLS	FUDICT_PAD_ALLOC_4 	;no space available at all
			;Check if requested space is available
			CPD	#(PAD_SIZE+PS_PADDING)
			BLO	FUDICT_PAD_ALLOC_3	;reduce size
			LDD	CP
			ADDD	#PAD_SIZE
			;Allocate PAD
FUDICT_PAD_ALLOC_1	STD	PAD
			STD	HLD
			;Done 
FUDICT_PAD_ALLOC_2	SSTACK_PREPULL	2
			RTS
			;Reduce PAD size 
FUDICT_PAD_ALLOC_3	CPD	#(PAD_MINSIZE+PS_PADDING)
			BLO	FUDICT_PAD_ALLOC_4		;not enough space available
			LDD	PSP
			SUBD	#PS_PADDING
			JOB	FUDICT_PAD_ALLOC_1 		;allocate PAD
			;Not enough space available
FUDICT_PAD_ALLOC_4	LDD 	$0000 				;signal failure
			JOB	FUDICT_PAD_ALLOC_2		;done

;Code fields:
;============
;FIND-UDICT ( c-addr -- c-addr 0 |  xt 1 | xt -1 )  
;Find the definition named in the terminated string at c-addr. If the definition is
;not found, return c-addr and zero.  If the definition is found, return its
;execution token xt.  If the definition is immediate, also return one (1),
;otherwise also return minus-one (-1).  For a given string, the values returned
;by FIND-UDICT while compiling may differ from those returned while not compiling. 
; args:   PSP+0: terminated string to match dictionary entry
; result: PSP+0: 1 if match is immediate, -1 if match is not immediate, 0 in
;         	 case of a mismatch
;  	  PSP+2: execution token on match, input string on mismatch
; SSTACK: 8 bytes
; PS:     1 cell
; RS:     1 cell
; throws: FEXCPT_EC_PSOF
;         FEXCPT_EC_PSUF
CF_FIND_UDICT		EQU	*
			;Check PS
			PS_CHECK_UFOF	1, 1 		;new PSP -> Y
			;Search core directory (PSP in Y)
			LDX	2,Y
			FUDICT_FIND 			;(SSTACK: 8 bytes)
			STD	0,Y
			STX	2,Y
			;Done
			NEXT

;WORDS-UDICT ( -- )
;List the definition names in the core dictionary in alphabetical order.
; args:   none
; result: none
; SSTACK: 8 bytes
; PS:     ? cells
; RS:     2 cells
; throws:  FEXCPT_EC_PSOF
CF_WORDS_UDICT		EQU	*
			;PS layout:
			; +--------+--------+
			; |   Current NFA   | PSP+0
			; +--------+--------+
			; | Column counter  | PSP+2
			; +--------+--------+
			;Print header
			PS_PUSH	#FUDICT_WORDS_HEADER
			EXEC_CF	CF_STRING_DOT
			;Initialize PS
			PS_CHECK_OF	2		 	;new PSP -> Y
			STY	PSP
			MOVW	#$0000, 2,Y 			;initialize column counter
			MOVW	UDICT_LAST_NFA, 2,Y 		;initialize current NFA
	








	
;Exceptions:
;===========
;Standard exceptions
#ifndef FUDICT_NO_CHECK
#ifdef FUDICT_DEBUG
FIDICT_THROW_DICTOF	BGND					;parameter stack overflow
FIDICT_THROW_PADOF	BGND					;PAD overflow
#else
FUDICT_THROW_DICTOF	THROW	FEXCPT_EC_DICTOF		;parameter stack overflow
FUDICT_THROW_PADOF	THROW	FEXCPT_EC_PADOF			;PAD overflow
#endif
#endif

FUDICT_CODE_END		EQU	*
FUDICT_CODE_END_LIN	EQU	@

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef FUDICT_TABS_START_LIN
			ORG 	FUDICT_TABS_START, FUDICT_TABS_START_LIN
#else
			ORG 	FUDICT_TABS_START
FUDICT_TABS_START_LIN	EQU	@
#endif	

;#New line string
FUDICT_STR_NL		EQU	STRING_STR_NL

;#Word separator string
FUDICT_STR_SEP		FCS	" "
FUDICT_STR_SEP_CNT	EQU	*-FUDICT_PRINT_SEP_WS

;#Header line for WORDS output 
FUDICT_WORDS_HEADER	STRING_NL_NONTERM
			FCC	"User Dictionary:"
			;FCC	"UDICT:"
			STRING_NL_TERM

FUDICT_TABS_END		EQU	*
FUDICT_TABS_END_LIN	EQU	@

;###############################################################################
;# Words                                                                       #
;###############################################################################
#ifdef FUDICT_WORDS_START_LIN
			ORG 	FUDICT_WORDS_START, FUDICT_WORDS_START_LIN
#else
			ORG 	FUDICT_WORDS_START
FUDICT_WORDS_START_LIN	EQU	@
#endif	

;#ANSForth Words:
;================

;#S12CForth Words:
;=================
;Word: FIND-UDICT ( c-addr -- c-addr 0 |  xt 1 | xt -1 )  
;Find the definition named in the terminated string at c-addr. If the definition is
;not found, return c-addr and zero.  If the definition is found, return its
;execution token xt.  If the definition is immediate, also return one (1),
;otherwise also return minus-one (-1).  For a given string, the values returned
;by FIND-UDICT while compiling may differ from those returned while not compiling. 
CFA_FIND_UDICT		DW	CF_FIND_UDICT

;Word: WORDS-UDICT ( -- )
;List the definition names in the core dictionary in alphabetical order.
CFA_WORDS_UDICT		DW	CF_WORDS_UDICT
		
FUDICT_WORDS_END	EQU	*
FUDICT_WORDS_END_LIN	EQU	@
#endif
