#ifndef FUDICT_COMPILED
#define FUDICT_COMPILED
;###############################################################################
;# S12CForth - FUDICT - User Dictionary and User Variables                     #
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

;Max. line length
FUDICT_LINE_WIDTH	EQU	DEFAULT_LINE_WIDTH

;NULL pointer
#ifndef NULL
NULL			EQU	$0000
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

HLD			DS	2 	;start of PAD space 
PAD			DS	2 	;end of PAD space 
	
UDICT_LAST_NFA		DS	2 	;pointer to the most recent NFA of the UDICT

FUDICT_VARS_END		EQU	*
FUDICT_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FUDICT_INIT, 0
			;Initialize NFA pointers
			CLRA
			CLRB
			STD	UDICT_LAST_NFA
			;Initialize compile pointers
#ifdef	DP
			LDD	DP
#else
			LDD	#UDICT_PS_START
#endif
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
			MOVW	CP_SAVED, CP 		;restore cp
#emac
	
;#Suspend action (to be executed in addition of quit action)
#macro	FUDICT_SUSPEND, 0
#emac

;#User dictionary (UDICT)
;========================
;Complile operations:
;====================	





;#Check if there is room in the DICT space and deallocate the PAD (CP+bytes -> X)
; args:   1: required space in bytes (constant, A, B, or D are valid args)
; result: Y: CP+new bytes
; SSTACK: none
; throws: FEXCPT_EC_DICTOF
;        X and D are preserved 
#macro	UDICT_CHECK_OF, 1
			LDY	CP	 		;=> 3 cycles
			LEAY	\1,Y			;=> 2 cycles
			STY	PAD			;=> 3 cycles
			STY	HLD			;=> 3 cycles
#ifndef	FUDICT_NO_CHECK
			LEAY	PS_PADDING,Y		;=> 2 cycles
			CPY	PSP			;=> 3 cycles
			BHI	FUDICT_THROW_DICTOF	;=> 3 cycles/ 4 cycles
			LEAY	-PS_PADDING,Y		;=> 2 cycles
#endif
							;  -------------------
							;   21 cycles/20 cycles
#emac			

;Compile cell into user dictionary
; args:   D: cell value
; result: Y: CP+new bytes
; SSTACK: none
;         X and D are preserved 
#macro	FUDICT_COMPILE_CELL, 0
			STD	[CP] 			;store cell in next free space
			UDICT_CHECK_OF 2		;allocate storage space
			STY	CP			;update compile pointer
#emac			

;Dictionary operations:
;======================	
;#Look-up word in user dictionary 
; args:   X: string pointer (terminated string)
; result: D: {IMMEDIATE, CFA>>1} of new word, zero if word not found
; SSTACK: 12 bytes
;         X and Y are preserved
#macro	FUDICT_FIND, 0
			SSTACK_JOBSR	FUDICT_FIND, 12
#emac
	
;#Look-up word in any user defined dictionary 
; args:   X: string pointer (terminated string)
;	  Y: start of dictionary (last NFA)
; result: D: {IMMEDIATE, CFA>>1} of new word, zero if word not found
; SSTACK: 8 bytes
;         X and Y are preserved
#macro	FUDICT_GENFIND, 0
			SSTACK_JOBSR	FUDICT_GENFIND, 8
#emac
	
;#Reverse lookup a CFA and print the corresponding word
; args:   D: CFA
; result: C-flag: set if successful
;	  Y: start of dictionary (last NFA)
; SSTACK: 22 bytes
;         All registers are preserved
#macro	FUDICT_REVPRINT_BL, 0
			SSTACK_JOBSR	FUDICT_REVPRINT_BL,	22
#emac

;#Generic reverse lookup a CFA and print the corresponding word
; args:   D: CFA
; result: C-flag: set if successful
;	  Y: start of dictionary (last NFA)
; SSTACK: 18 bytes
;         All registers are preserved
#macro	FUDICT_GENREVPRINT_BL, 0
			SSTACK_JOBSR	FUDICT_GENREVPRINT_BL,	18
#emac

;Iterator operations:
;====================
;Set interator to first word in CDICT
; args:   1: iterator (indexed address)
; result: none
; SSTACK: none
;         All registers are preserved
#macro FUDICT_ITERATOR_FIRST, 1
			MOVW	UDICT_LAST_NFA, \1 	;last NFA -> ITERATOR
#emac

;Advance iterator
; args:   1:      iterator (indexed address)
; result: D:      previous NFA (NULL if no previous NFA exists)
;         Z-flag: set if no previous NFA exists
; SSTACK: none
;         X and Y are preserved
#macro FUDICT_ITERATOR_NEXT, 1
 			LDD	[\1] 			;(previous NFA>>1) -> D
			LSLD 				; previous NFA -> D
			STD	\1			; previous NFA -> ITERATOR
#emac

;Get length of word referenced by current iterator
; args:   1: iterator (indexed address)
;         D: old char count 
; result: D: new char count
;	  X: points to the byte after the string
; SSTACK: none
;         Y is preserved
#macro FUDICT_ITERATOR_WC, 1
			LDX	\1 			;current NFA -> X
			LEAX	2,X			;start of string -> X
			FIO_SKIP_AND_COUNT		;count chars
#emac

;Print word referenced by current iterator (BLOCKING)
; args:   1: iterator (indexed address)
; result: X: points to the byte after the string
; SSTACK: 10 bytes
;         Y and D are preserved
#macro FUDICT_ITERATOR_PRINT, 1
			LDX	\1 			;current NFA -> X
			LEAX	2,X			;start of string -> X
			FIO_PRINT_BL                 ;print string
#emac

;Get CFA of word referenced by current iterator
; args:   1: iterator (indexed address)
; result: D: {IMMEDIATE, CFA>>1}
;         X: CFA pointer
; SSTACK: none
;         Y is preserved
#macro FUDICT_ITERATOR_CFA, 1
			LDX	\1 			;current NFA -> X
			LEAX	2,X			;start of string -> X
			BRCLR	1,X+, #FIO_TERM, *	;skip over string
			FUDICT_WORD_ALIGN X 		;word align X
			LDD	2,+X			;{IMMEDIATE, CFA>>1} -> D
#emac

;Pointer operations:
;===================
;Word align index register
; args:   1:   index register
; result: [1]: word aligned address
; SSTACK: none
;         All registers except for 1 are preserved
#macro FUDICT_WORD_ALIGN, 1
			EXG	D, \1 			; index <-> D
			ANDB	#$FE			; word align D 
			EXG	D, \1 			; index <-> D
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
; result: D: {IMMEDIATE, CFA>>1} of new word, zero if word not found
; SSTACK: 12 bytes
;         X and Y are preserved
FUDICT_FIND		EQU	*
			;Save registers (string pointer in X)
			PSHY						;start of dictionary
#ifdef	NVC
			;Check NVC (string pointer in X)
			LDY	NVC 					;check NVC
			BNE	FUDICT_FIND_1 				;no UDICT if NVC is set
#endif
			;Search UDICT (string pointer in X)
			LDY	UDICT_LAST_NFA 				;start of UDICT -> Y
			FUDICT_GENFIND					;(SSTACK: 8 bytes)
			;Done (result in D)
FUDICT_FIND_1		SSTACK_PREPULL	4 				;check stack
			PULY						;restore Y
			RTS

;#Look-up word in any user defined dictionary 
; args:   X: string pointer (terminated string)
;	  Y: start of dictionary (last NFA)
; result: D: {IMMEDIATE, CFA>>1} of new word, zero if word not found
; SSTACK: 8 bytes
;         X and Y are preserved
FUDICT_GENFIND	EQU	*
			;Save registers (string pointer in X, start of dictionary in Y)
			PSHX						;string pointer
			PSHY						;start of dictionary
			PSHY						;ITERATOR -> 0,SP
			;Compare strings (string pointer in X)
			LDY	0,SP					;current NFA -> Y
FUDICT_GENFIND_1	LEAY	2,Y					;start of dict string -> Y
FUDICT_GENFIND_2	LDAB	1,X+					;string char -> A
			CMPB	1,Y+ 					;compare chars
			BNE	FUDICT_GENFIND_4 			;mismatch
			BRCLR	-1,X, #FIO_TERM, FUDICT_GENFIND_2 	;check next char
			;Match (pointer to code field or padding in Y)
			FUDICT_WORD_ALIGN Y 				;word align Y
			LDD	2,Y 					;{IMMEDIATE, CFA>>1} -> D
			;Done (result in D)
FUDICT_GENFIND_3	SSTACK_PREPULL	8 				;check stack
			LEAS	2,SP 					;clean up temporary variables
			PULY						;restore Y
			PULX						;restore X
			RTS
			;Mismatch
FUDICT_GENFIND_4	FUDICT_ITERATOR_NEXT	(0,SP) 			;advance iterator
			TFR	D, Y 					;new NFA -> Y
			BNE	FUDICT_GENFIND_1 			;compare strings
			;Search unsuccessful (string pointer in X)
			CLRA						;set result
			CLRB						; -> not found
			JOB	FUDICT_GENFIND_3 			;done

;#Reverse lookup a CFA and print the corresponding word
; args:   D: CFA
; result: C-flag: set if successful
; SSTACK: 22 bytes
;         All registers are preserved
FUDICT_REVPRINT_BL	EQU	*
			;Save registers (CFA in D, start of dictionary in X)
			PSHY						;save Y
#ifdef NVC
			;Check NVC (string pointer in X)
			LDY	NVC 					;check NVC
			BNE	FUDICT_REVPRINT_1 			;no UDICT if NVC is set
#endif
			;Reverse look-up CFA
			LDY	UDICT_LAST_NFA				;start of UDICT -> Y
			FUDICT_GENREVPRINT_BL 				;(SSTACK: 18 bytes)
			BCC	FUDICT_REVPRINT_1 			;no success
			;Success
			SSTACK_PREPULL	4 				;check stack
			PULY						;restore Y
			SEC						;flag success	
			RTS
			;Failure
FUDICT_REVPRINT_1	SSTACK_PREPULL	4 				;check stack
			PULY						;restore Y
			CLC						;flag failure	
			RTS

;#Generic reverse lookup a CFA and print the corresponding word
; args:   D: CFA
;	  Y: start of dictionary (last NFA)
; result: C-flag: set if successful
; SSTACK: 18 bytes
;         All registers are preserved
FUDICT_GENREVPRINT_BL	EQU	*
			;Save registers (CFA in D, start of dictionary in X)
			PSHX						;string pointer
			PSHD						;CFA
			;Allocate iterator (CFA in D, start of dictionary in X)
			;FUDICT_ITERATOR_FIRST	(2,-SP)			;ITERATOR -> 0,SP
			PSHY						;ITERATOR -> 0,SP
			;Check CFA
FUDICT_GENREVPRINT_BL_1	FUDICT_ITERATOR_CFA	(0,SP)			;{IMMEDIATE, CFA>>1} -> D
			LSLD						;remove IMMEDIATE flag
			CPD	2,SP 					;compare CFAs
			BEQ	FUDICT_GENREVPRINT_BL_2 		;match
			;Mismatch		
			FUDICT_ITERATOR_NEXT 	(0,SP)			;advance iterator
			BNE	FUDICT_GENREVPRINT_BL_1 		;check next CFA
			;Search unsucessful					
			SSTACK_PREPULL	8 				;check stack
			CLC						;flag failure
			JOB	FUDICT_GENREVPRINT_BL_3 		;done
			;Search unsucessful		
FUDICT_GENREVPRINT_BL_2	FUDICT_ITERATOR_PRINT 	(0,SP)			;print word (SSTACK: 10 bytes)
			SSTACK_PREPULL	8 				;check stack
			SEC						;flag success
			;Done		
FUDICT_GENREVPRINT_BL_3	LEAS	2,SP 					;remove iterator
			PULD						;restore D
			PULX						;restore X
			RTS

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
;: ( C: "<spac2es>name" -- colon-sys )
;Skip leading space delimiters. Parse name delimited by a space. Create a
;definition for name, called a colon definition. Enter compilation state and
;start the current definition, producing colon-sys. Append the initiation
;semantics given below to the current definition.
;The execution semantics of name will be determined by the words compiled into
;the body of the definition. The current definition shall not be findable in the
;dictionary until it is ended (or until the execution of DOES> in some systems).
;Initiation: ( i*x -- i*x )  ( R:  -- nest-sys )
;Save implementation-dependent information nest-sys about the calling
;definition. The stack effects i*x represent arguments to name.
;name Execution: ( i*x -- j*x )
;Execute the definition name. The stack effects i*x and j*x represent arguments
;to and results from name, respectively.
;
;S12CForth implementation details:
;colon-sys is the NFA if the new definition. $0000 is used for :NONAME
;definitions. 
;Throws:
;"Parameter stack overflow"
;"Missing name argument"
;"Dictionary overflow"
;"Compiler nesting"
CF_COLON		EQU	*			
			;Ensure interpretation state  
			INTERPRET_ONLY				;check for nested definition
			;Push colon-sys (new NFA)onto PS 
			PS_PUSH	CP 				;push pointer to new NFA
			;Parse name
			CLRA					;whitespace delimeters
			FOUTER_PARSE				;parse TIM
			TBEQ	D, CF_COLON_2			;missing name argument
			;Allocate header (char count in D, string pointer in X)
			ADDD	#5 				;add padding, NFA, and CFA			
			ANDB	#$FE				;word align char count
			UDICT_CHECK_OF	D			;new_compile count in Y
			MOVB	#$FF, -3,Y			;flash friendly padding
			MOVW	#CF_INNER, -2,Y			;execution semantics (inner interpreter)
			LDD	CP				;start of header -> D
			STY	CP				;update CP
			TFR	D, Y				;start of header -> Y
			LDD	UDICT_LAST_NFA			;last NFA -> D
			LSRD					;shift pointer
			STD	2,Y+				;link in new header
			;Copy name into header (start of name in Y, string pointer in X)	
CF_COLON_1		LDAB	1,X+ 				;char -> B
			FIO_UPPER				;make upper case (SSTACK: 2 bytes)
			STAB	1,Y+				;append char to name
			BPL	CF_COLON_1			;loop untill termination is found
			;Set compile state 	
			MOVW	#STATE_COMPILE, STATE 		;switch to compile state
			NEXT
			;Missing name argument
CF_COLON_2		FEXCPT_THROW	FEXCPT_EC_NONAME,	;Error -16! "Missing name argument"

:NONAME ( C:  -- colon-sys )  ( S:  -- xt )
;Create an execution token xt, enter compilation state and start the current
;definition, producing colon-sys. Append the initiation semantics given below
;to the current definition.
;The execution semantics of xt will be determined by the words compiled into the
;body of the definition. This definition can be executed later by using
;xt EXECUTE.
;If the control-flow stack is implemented using the data stack, colon-sys shall
;be the topmost item on the data stack.
;Initiation: ( i*x -- i*x ) ( R:  -- nest-sys )
;Save implementation-dependent information nest-sys about the calling
;definition. The stack effects i*x represent arguments to xt.
;xt Execution: ( i*x -- j*x )
;Execute the definition specified by xt. The stack effects i*x and j*x represent
;arguments to and results from xt, respectively.
;
;S12CForth implementation details:
;colon-sys is the NFA if the new definition. $0000 is used for :NONAME
;definitions. 
;Throws:
;"Parameter stack overflow"
;"Compiler nesting"
;"Dictionary overflow"
CF_COLON_NONAME		EQU	*			
			;Ensure interpretation state  
			INTERPRET_ONLY				;check for nested definition
			;Push colon-sys (zero)  )onto PS 
			PS_PUSH	#$0000				;push zero
			;Allocate header
			UDICT_CHECK_OF	2			;new_compile count in Y
			MOVW	#CF_INNER, -2,Y		;execution semantics (inner interpreter)
			STY	CP				;update CP
			;Set compile state 	
			MOVW	#STATE_COMPILE, STATE 		;switch to compile state
			NEXT

;; 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: colon-sys -- )
;Append the run-time semantics below to the current definition. End the current
;definition, allow it to be found in the dictionary and enter interpretation
;state, consuming colon-sys. If the data-space pointer is not aligned, reserve
;enough data space to align it.
;Run-time: ( -- ) ( R: nest-sys -- )
;Return to the calling definition specified by nest-sys.
;
;S12CForth implementation details:
;colon-sys is the NFA if the new definition. $0000 is used for :NONAME
;definitions. 
;Throws:
;"Parameter stack underflow"
;"Dictionary overflow"
;"Compile-only word"

CF_SEMICOLON		EQU	*			
			;Ensure interpretation state  
			COMPILE_ONLY			 	;ensure that compile mode is on
			;Terminate compilation
			UDICT_CHECK_OF	2			;new_compile count in Y
			MOVW	#CFA_EOW, -2,Y			;execution semantics (end of woed)
			STY	CP				;update CP
			;Pull colon-sys
			PS_PULL_D 				;colon-sys -> D
			BEQ	CF_SEMICOLON_2			;don't update UDICT_LAST_NFA
			STD	UDICT_LAST_NFA			;update UDICT_LAST_NFA
			;Save CP 	
CF_SEMICOLON_1		MOVW	CP, CP_SAVED
			;Set interpretation state 	
			MOVW	#STATE_COMPILE, STATE 		;switch to compile state
			NEXT
			;Push xt onto PS
			PS_PUSH	CP_SAVED
CF_SEMICOLON_2		JOB	CF_SEMICOLON_1	

;IMMEDIATE ( -- )
;Make the most recent definition an immediate word. An ambiguous condition
;exists if the most recent definition does not have a name.
;
;S12CForth implementation details:
;Modifies most recent named definition.
			;Modify most recent header
CF_IMMEDIATE		LDX	UDICT_LAST_NFA  		;find most recent named definition
			BEQ	CF_IMMEDIATE_1			;UDICT is empty
			BSET	0,X, #$80 			;set immediate bit
			;Done 
CF_IMMEDIATE_1		NEXT
	
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
			FOUTER_FIND_FORMAT		;(SSTACK: 2 bytes)
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
			; PS layout:
			; +--------+--------+
			; |    Iterator     | PSP+0
			; +--------+--------+
			; | Column counter  | PSP+2
			; +--------+--------+
#ifdef NVC
			;Check NVC 
			LDD	NVC			;check NVC
			BNE	CF_WORDS_UDICT_4	;no UDICT if NVC is set
#endif
			;Print header
			PS_PUSH	#FUDICT_WORDS_HEADER
			;Allocate stack space
			PS_CHECK_OF	2		;new PSP -> Y
			STY	PSP
			;Initialize iterator and column counter (PSP in Y)
			FUDICT_ITERATOR_FIRST	(0,Y)	;initialize iterator
			MOVW #FUDICT_LINE_WIDTH, 2,Y	;initialize column count
			;Check column width (PSP in Y)
CF_WORDS_UDICT_1	LDD	2,Y 			;column clint -> D
			FUDICT_ITERATOR_WC (0,Y)
			CPD	#(FUDICT_LINE_WIDTH+1)	;check line width
			BLS	CF_WORDS_UDICT_2 	;insert white space
			;Insert line break (PSP in Y)			
			MOVW	#$0000, 2,Y		;reset column counter
			EXEC_CF	CF_CR 			;print line break
			JOB	CF_WORDS_UDICT_3	;print word
			;Insert white space (PSP in Y, new column count in D)
CF_WORDS_UDICT_2	ADDD	#1			;count space char
			STD	CF_WORDS_CDICT_COLCNT,Y	;update column counter
			EXEC_CF	CF_SPACE		;print whitespace
			;Print word						
CF_WORDS_UDICT_3	LDY	PSP				;PSP -> Y
			LDX	0,Y			;word entry -> X
			LEAX	2,X			;start of string -> X
			PS_PUSH_X			;print string
			EXEC_CF	CF_STRING_DOT		;
			;Skip to next word						
			LDY	PSP			;PSP -> Y
			FUDICT_ITERATOR_NEXT	(0,Y)	;advance iterator
			BNE	CF_WORDS_UDICT_1	;print next word					
			;Clean up (PSP in Y)						
			PS_CHECK_UF	2 		;PSP -> Y
			LEAY	2,Y
			STY	PSP
CF_WORDS_UDICT_4	NEXT

;Exceptions:
;===========
;Standard exceptions
#ifndef FUDICT_NO_CHECK
FUDICT_THROW_DICTOF	FEXCPT_THROW	FEXCPT_EC_DICTOF	;parameter stack overflow
FUDICT_THROW_PADOF	FEXCPT_THROW	FEXCPT_EC_PADOF		;PAD overflow
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
FUDICT_STR_NL		EQU	FIO_STR_NL

;#Header line for WORDS output 
FUDICT_WORDS_HEADER	FIO_NL_NONTERM
			FCC	"User Dictionary:"
			;FCC	"UDICT:"
			FIO_NL_TERM

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
;Word: : ( C: "<spac2es>name" -- colon-sys ) 				IMMEDIATE
;Skip leading space delimiters. Parse name delimited by a space. Create a
;definition for name, called a colon definition. Enter compilation state and
;start the current definition, producing colon-sys. Append the initiation
;semantics given below to the current definition.
;The execution semantics of name will be determined by the words compiled into
;the body of the definition. The current definition shall not be findable in the
;dictionary until it is ended (or until the execution of DOES> in some systems).
;Initiation: ( i*x -- i*x )  ( R:  -- nest-sys )
;Save implementation-dependent information nest-sys about the calling
;definition. The stack effects i*x represent arguments to name.
;name Execution: ( i*x -- j*x )
;Execute the definition name. The stack effects i*x and j*x represent arguments
;to and results from name, respectively.
CFA_COLON		DW	CF_COLON

;Word: :NONAME ( C:  -- colon-sys )  ( S:  -- xt ) IMMEDIATE
;Create an execution token xt, enter compilation state and start the current
;definition, producing colon-sys. Append the initiation semantics given below
;to the current definition.
;The execution semantics of xt will be determined by the words compiled into the
;body of the definition. This definition can be executed later by using
;xt EXECUTE.
;If the control-flow stack is implemented using the data stack, colon-sys shall
;be the topmost item on the data stack.
;Initiation: ( i*x -- i*x ) ( R:  -- nest-sys )
;Save implementation-dependent information nest-sys about the calling
;definition. The stack effects i*x represent arguments to xt.
;xt Execution: ( i*x -- j*x )
;Execute the definition specified by xt. The stack effects i*x and j*x represent
;arguments to and results from xt, respectively.
CFA_COLON_NONAME	DW	CF_COLON_NONAME

;Word: ;								IMMEDIATE 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( C: colon-sys -- )
;Append the run-time semantics below to the current definition. End the current
;definition, allow it to be found in the dictionary and enter interpretation
;state, consuming colon-sys. If the data-space pointer is not aligned, reserve
;enough data space to align it.
;Run-time: ( -- ) ( R: nest-sys -- )
;Return to the calling definition specified by nest-sys.
CFA_SEMICOLON		DW	CF_SEMICOLON

;Word: IMMEDIATE ( -- )
;Make the most recent definition an immediate word. An ambiguous condition
;exists if the most recent definition does not have a name.
CFA_IMMEDIATE		DW	CF_IMMEDIATE
	
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
