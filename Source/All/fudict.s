;###############################################################################
;# S12CForth- FUDUCT - User Ductionary and User Variables                      #
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
;#    This module implements the volatile user dictionary, user variables, and #
;#    the PAD.                                                                 #
;#                                                                             #
;#    The following registers are implemented:                                 #
;#          STATE = 0 -> Interpretation state    	       		       #
;#                 -1 -> Compilation state     		       	               #
;#             CP = Compile pointer                                            #
;#                  Points to the next free space after the dictionary         #
;#            PAD = Beginning of the PAD buffer 			       #
;#                  Points to the next byte after the PAD		       #
;#            HLD = Pointer for pictured numeric output			       #
;#                  Points to the first character on the PAD                   #
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
;          UDUCT_PS_END
;	
;                           Word format:
;                           +-----------------------------+
;                     NFA-> |  IMMEDIATE / Previous NFA   |	
;                           +--------------+--------------+
;                           |                             | 
;                           |            Name             | 
;                           |                             | 
;                           |              +--------------+ 
;                           |              |    Padding   | 
;                           +--------------+--------------+
;                     CFA-> |       Code Field Address    |	
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
;STATE variable 
STATE_INTERPRET		EQU	FALSE
STATE_COMPILE		EQU	TRUE

;NVC variable 
NVC_VOLATILE		EQU	FALSE
NVC_NON_VOLATILE	EQU	TRUE
	
;Prompt characters	 
FUDICT_PRCHAR_NVC	EQU	FOUTER_PRCHAR_NVC
FUDICT_PRCHAR_SUSPEND	EQU	FOUTER_PRCHAR_SUSPEND

;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FUDICT_VARS_START_LIN
			ORG 	FUDICT_VARS_START, FRS_VARS_START_LIN
#else
			ORG 	FUDICT_VARS_START
FUDICT_VARS_START_LIN	EQU	@
#endif

			ALIGN	1	
STATE			DS	2 		;interpreter state (0:iterpreter, -1:compile)
CP			DS	2 	;compile pointer (next free space in the dictionary space) 
HLD			DS	2	;pointer for pictured numeric output
PAD                     DS	2	;end of the PAD buffer
UDICT_LAST_NFA		DS	2 	;pointer to the most recent NFA of the UDICT

FUDICT_VARS_END		EQU	*
FUDICT_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FUDICT_INIT, 0
#ifndef FNVDICT_INFO
			;Initialize the compile data pointer
			MOVW	#UDICT_PS_START, CP
	
	
			MOVW	$#0000, UDICT_LAST_NFA
			LDD	#UDICT_START
			STD	CP
			STD	CP_SAVED
	
			;Initialize PAD (DICT_START in D)
			STD	PAD 		;Pad is allocated on demand
			STD	HLD

#emac

;#Abort action (to be executed in addition of quit and suspend action)
#macro	FUDICT_ABORT, 0
#emac
	
;#Quit action (to be executed in addition of suspend action)
#macro	FUDICT_QUIT, 0
#emac
	
;#Suspend action
#macro	FUDICT_SUSPEND, 0
#emac

;#User dictionary (UDICT)
;----------------------- 
;#Check if there is room in the DICT space and deallocate the PAD (CP+bytes -> X)
; args:   1: required space (bytes)
; result: X: CP-new bytes
; SSTACK: none
; throws: FEXCPT_EC_DICTOF
;        Y and D are preserved 
#macro	UDICT_CHECK_OF, 1
			LDX	CP 			;=> 3 cycles
			LEAX	\1,X			;=> 2 cycles
			CPX	PSP			;=> 3 cycles
			BHI	FUDICT_DICTOF_HANDLER	;=> 3 cycles/ 4 cycles
			STX	PAD			;=> 3 cycles
			STX	HLD			;=> 3 cycles
							;  -------------------
							;   17 cycles/12 cycles
#emac			

;#Check if there is room in the DICT space and deallocate the PAD (CP+bytes -> X)
; args:   A: required space (bytes)
; result: X: CP-new bytes
; SSTACK: none
; throws: FEXCPT_EC_DICTOF
;        Y and D are preserved 
#macro	UDICT_CHECK_OF_A, 0
			LDX	CP 			;=> 3 cycles
			LEAX	A,X			;=> 2 cycles
			CPX	PSP			;=> 3 cycles
			BHI	FUDICT_DICTOF_HANDLER	;=> 3 cycles/ 4 cycles
			STX	PAD			;=> 3 cycles
			STX	HLD			;=> 3 cycles
							;  --------------------
							;   17 cycles/12 cycles
#emac			
	
;#Check if there is room in the DICT space and deallocate the PAD (CP+bytes -> X)
; args:   D: required space (bytes)
; result: X: CP-new bytes
; SSTACK: none
; throws: FEXCPT_EC_DICTOF
;        Y and D are preserved 
#macro	DICT_CHECK_OF_D, 0
			LDX	CP 			;=> 3 cycles
			LEAX	D,X			;=> 2 cycles
			CPX	PSP			;=> 3 cycles
			BHI	FUDICT_DICTOF_HANDLER	;=> 3 cycles/ 4 cycles
			STX	PAD			;=> 3 cycles
			STX	HLD			;=> 3 cycles
							;  --------------------
							;   17 cycles/12 cycles
#emac			
	
;#Pictured numeric output buffer (PAD)
;-------------------------------------
;PAD_CHECK_OF: check if there is room for one more character on the PAD (HLD -> X)
; args:   none
; result: X: HLD
; SSTACK: none
; throws: FEXCPT_EC_PADOF
;        Y and D are preserved 
#macro	PAD_CHECK_OF, 0
			LDX	HLD 			;=> 3 cycles
			CPX	CP			;=> 3 cycles
			BLS	FUDICT_PADOF_HANDLER	;=> 3 cycles/ 4 cycles
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
			TBEQ	D, FUDICT_PADOF_HANDLER 	;no space available at all
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


;Search word in dictionary
; args:   X: string pointer
;         D: char count 
; result: C-flag: set if word is in the dictionary	
;         D: {IMMEDIATE, CFA>>1} if word has been found, unchanged otherwise 
; SSTACK: 16  bytes
;         X and Y are preserved 
FUDICT_SEARCH		EQU	*










	
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
			JOB	FUDICT_PAD_ALLOC_1 	;allocate PAD
			;Not enough space available
FUDICT_PAD_ALLOC_4	LDD 	$0000 			;signal failure
			JOB	FUDICT_PAD_ALLOC_2	;done


;Code fields:
;============












	
;.CPROMPT ( -- ) Print the interpretation prompt
; args:   none
; result: none
; SSTACK: 8 bytes
; PS:     1 cell
; RS:     1 cells
; throws: FEXCPT_EC_PSUF
CF_DOT_CPROMPT		EQU	*
			;Print line break 
			EXEC_CF	CF_CR
#ifdef	NVC
			;Check for NVM compile 
			LDD	NVC				;check non-volatile compile flag
			BEQ	CF_DOT_CPROMPT_1		;volatile compile
			PS_PUSH	#FOUTER_PRCHAR_NVC		;print prompt character
			EXEC_CF	CF_EMIT
CF_DOT_CPROMPT_1	EQU	*
#endif
;			;Check for SUSPEND 
;			LDD	IP				;check instruction pointer
;			BEQ	CF_DOT_CPROMPT_2		;QUIT shell
;			PS_PUSH	#FOUTER_PRCHAR_SUSPEND		;print prompt character
;			EXEC_CF	CF_EMIT
			;Print interpretation prompt
			PS_PUSH	#FOUTER_CPROMPT			;print prompt string
			;Done
			NEXT
	

;Error handlers:
;===============
;#Dictionary overflow handler
FUDICT_DICTOF_HANDLER	EQU	*
			;FEXCPT_THROW	FMEM_EC_DICTOF

;#PAD overflow handler
FUDICT_PADOF_HANDLER	EQU	*
			;FEXCPT_THROW	FMEM_EC_PADOF

;#PS overflow handler
FUDICT_PSOF_HANDLER	EQU	*
			;FEXCPT_THROW	FMEM_EC_PSOF

;#PS underflow handler
FUDICT_PSUF_HANDLER	EQU	*
			;FEXCPT_THROW	FMEM_EC_PSUF

;#RS overflow handler
RAM_RSOF_HANDLER	EQU	*
			;FEXCPT_THROW	FMEM_EC_RSOF
	
;#RS underflow handler
FUDICT_RSUF_HANDLER	EQU	*
			;FEXCPT_THROW	FMEM_EC_RSUF
			BGND

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

;System prompts
FUDICT_CPROMPT		FCS	"+ "

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
;Word: STATE ( -- a-addr ) 
;a-addr is the address of a cell containing the compilation-state flag. STATE is
;true when in compilation state, false otherwise. The true value in STATE is
;non-zero. Only the following standard words alter the value in STATE:
; : (colon), ; (semicolon), ABORT, QUIT, :NONAME, [ (left-bracket), and
; ] (right-bracket). 
;  Note:  A program shall not directly alter the contents of STATE. 
;
;Throws:
;"Parameter stack overflow"
CFA_STATE		DW	CF_CONSTANT_RT
			DW	STATE

;S12CForth Words:
;================
;Word: .CPROMPT ( -- )
;Print the compilation prompt
;
;Throws:x
;"Parameter stack overflow"
CFA_DOT_CPROMPT		DW	CF_DOT_CPROMPT
	
FUDICT_WORDS_END	EQU	*
FUDICT_WORDS_END_LIN	EQU	@

