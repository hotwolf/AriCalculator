;###############################################################################
;# S12CForth - FEXCPT - Forth Exception Words                                  #
;###############################################################################
;#    Copyright 2010-2013 Dirk Heisswolf                                       #
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
;#    This module implements the exception handling of the S12CForth virtual   #
;#    machine. The following Forth variables belong to this module:            #
;#                                                                             #
;#      HANDLER = Points to the next exception stack frame                     #
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    June 15, 2009                                                            #
;#      - Initial release, based on Michael Milendorf's paper                  #
;#       "Catch and Throw                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    BASE   - S12CBase framework                                              #
;#    FCORE  - Forth core words                                                #
;#    FMEM   - Forth memories                                                  #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################

;###############################################################################
;# Memory Layout                                                               #
;###############################################################################
;                                
;           RS:               	
;           +---------------------+
;     RSP-> |                     |
;           |                     |
;           |                     | 
;           +---------------------+ <-+
; HANDLER-> |  previous HANDLER   |   |
;           +---------------------+   |error
;           |     PSP at CATCH    |   |stack
;           +---------------------+   |frame
;           | xt after CATCH call |   |
;           +---------------------+ <-+

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;PPAGE for error message look-up
;FEXCEPT_ERRPP			EQU	$FE 


;###############################################################################
;# Constants                                                                   #
;###############################################################################
;Standard error codes (ANS Forth)
FEXCPT_EC_ABORT			EQU	-1 	;ABORT
FEXCPT_EC_ABORTQ		EQU	-2 	;ABORT"
FEXCPT_EC_PSOF			EQU	-3 	;stack overflow
FEXCPT_EC_PSUF			EQU	-4 	;stack underflow
FEXCPT_EC_RSOF			EQU	-5 	;return stack overflow
FEXCPT_EC_RSUF			EQU	-6 	;return stack underflow
FEXCPT_EC_DOOF			EQU	-7 	;do-loops nested too deeply during execution
FEXCPT_EC_DICTOF		EQU	-8 	;dictionary overflow
FEXCPT_EC_INVALADR		EQU	-9 	;invalid memory address
FEXCPT_EC_0DIV			EQU	-10	;division by zero
FEXCPT_EC_RESOR			EQU	-11	;result out of range
;FEXCPT_EC_12			EQU	-12	;argument type mismatch
FEXCPT_EC_UDEFWORD		EQU	-13	;undefined word
FEXCPT_EC_COMPONLY		EQU	-14	;interpreting a compile-only word
;FEXCPT_EC_15			EQU	-15	;invalid FORGET
FEXCPT_EC_NONAME		EQU	-16	;attempt to use zero-length string as a name
FEXCPT_EC_PADOF			EQU	-17	;pictured numeric output string overflow
FEXCPT_EC_STROF			EQU	-18	;parsed string overflow
;FEXCPT_EC_19			EQU	-19	;definition name too long
;FEXCPT_EC_20			EQU	-20	;write to a read-only location
;FEXCPT_EC_21			EQU	-21	;unsupported operation (e.g., AT-XY on a too-dumb terminal)
FEXCPT_EC_CTRLSTRUC		EQU	-22	;control structure mismatch
;FEXCPT_EC_23			EQU	-23	;address alignment exception
FEXCPT_EC_INVALNUM		EQU	-24	;invalid numeric argument
;FEXCPT_EC_25			EQU	-25	;return stack imbalance
;FEXCPT_EC_26			EQU	-26	;loop parameters unavailable
;FEXCPT_EC_27			EQU	-27	;invalid recursion
;FEXCPT_EC_28			EQU	-28	;user interrupt
FEXCPT_EC_COMPNEST		EQU	-29	;compiler nesting
;FEXCPT_EC_30			EQU	-30	;obsolescent feature
FEXCPT_EC_NONCREATE		EQU	-31	;>BODY used on non-CREATEd definition
FEXCPT_EC_INVALNAME		EQU	-32	;invalid name argument (e.g., TO xxx)
;FEXCPT_EC_33			EQU	-33	;block read exception
;FEXCPT_EC_34			EQU	-34	;block write exception
;FEXCPT_EC_35			EQU	-35	;invalid block number
;FEXCPT_EC_36			EQU	-36	;invalid file position
;FEXCPT_EC_37			EQU	-37	;file I/O exception
;FEXCPT_EC_38			EQU	-38	;non-existent file
;FEXCPT_EC_39			EQU	-39	;unexpected end of file
FEXCPT_EC_INVALBASE		EQU	-40	;invalid BASE for floating point conversion
;FEXCPT_EC_41			EQU	-41	;loss of precision
;FEXCPT_EC_42			EQU     -42	;floating-point divide by zero
;FEXCPT_EC_43			EQU	-43	;floating-point result out of range
;FEXCPT_EC_44			EQU	-44	;floating-point stack overflow
;FEXCPT_EC_45			EQU	-45	;floating-point stack underflow
;FEXCPT_EC_46			EQU	-46	;floating-point invalid argument
;FEXCPT_EC_47			EQU	-47	;compilation word list deleted
;FEXCPT_EC_48			EQU	-48	;invalid POSTPONE
;FEXCPT_EC_49			EQU	-49	;search-order overflow
;FEXCPT_EC_50			EQU	-50	;search-order underflow
;FEXCPT_EC_51			EQU	-51	;compilation word list changed
;FEXCPT_EC_52			EQU	-52	;control-flow stack overflow
FEXCPT_EC_CESF			EQU	-53	;exception stack overflow
;FEXCPT_EC_54			EQU	-54	;floating-point underflow
;FEXCPT_EC_55			EQU	-55	;floating-point unidentified fault
FEXCPT_EC_QUIT			EQU	-56	;QUIT
;FEXCPT_EC_57			EQU	-57	;exception in sending or receiving a character
;FEXCPT_EC_58			EQU	-58	;[IF], [ELSE], or [THEN] exception
	
;Non-standard error codes 
FEXCPT_EC_NOMSG			EQU	-59	;empty message string
FEXCPT_EC_DICTPROT		EQU	-60	;destruction of dictionary structure
FEXCPT_EC_COMERR		EQU	-61	;invalid RX data
FEXCPT_EC_COMOF			EQU	-62	;RX buffer overflow
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FEXCEPT_VARS_START_LIN
			ORG 	FEXCEPT_VARS_START, FEXCEPT_VARS_START_LIN
#else
			ORG 	FEXCEPT_VARS_START
FEXCEPT_VARS_START_LIN	EQU	@
#endif	

HANDLER			DS	2 	;pointer tho the most recent exception
					;handler 
FEXCEPT_VARS_END		EQU	*
FEXCEPT_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FEXCPT_INIT, 0
			MOVW	#$0000, HANDLER ;reset exception handler
#emac

;#Abort action (to be executed in addition of quit and suspend action)
#macro	FEXCPT_ABORT, 0
#emac
	
;#Quit action (to be executed in addition of suspend action)
#macro	FEXCPT_QUIT, 0
#emac
	
;#Suspend action
#macro	FEXCPT_SUSPEND, 0
#emac
	
;#Throw an exception from within an assembler primitive (immediate error code)
; args:   1: error code
; result: none
; SSTACK: none
;         no registers are preserved 
#macro	FEXCPT_THROW, 1
			LDD	#\1		;set error code
			FEXCPT_THROW_D
#emac

;#Throw an exception from within an assembler primitive (error code in D)
; args:   D: error code
; result: none
; SSTACK: none
;         no registers are preserved 
#macro	FEXCPT_THROW_D, 0
			;BGND
			JOB	FEXCPT_THROW	;throw exception
#emac

;#Throw a fatal erroe from within an assembler primitive (immediate error code)
; args:   1: error code
; result: none
; SSTACK: none
;         no registers are preserved 
#macro	FEXCPT_FATAL, 1
			RESET_FATAL, \1	
#emac

;#Error message
; args: 1: error code
; 	2: message string
; result: none
; SSTACK: none
;         no registers are preserved 
#macro	FEXCPT_MSG, 2
			DB	\1		 ;error code
#emac			FCS	\2		 ;error message

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FEXCEPT_CODE_START_LIN
			ORG 	FEXCEPT_CODE_START, FEXCEPT_CODE_START_LIN
#else
			ORG 	FEXCEPT_CODE_START
FEXCEPT_CODE_START_LIN	EQU	@
#endif



	
	
;#Throw an exception
; args:   D: error code
; result: none
; SSTACK: none
;         no registers are preserved 
FEXCPT_THROW		EQU	*
			;Check if exception is cought
			LDX	HANDLER						;check if an exception handler exists
			BEQ	FEXCPT_THROW_2					;no exception handler
			;Cought exception, verify stack frame (RSP in X, error code in D)
			STX	RSP						;restore RS	
			RS_CHECK_UF	3, FEXCPT_THROW_1			;three entries must be on the RS  
			RS_CHECK_OF	0, FEXCPT_THROW_1			;check for RS overflow
 			;Restore stacks (RSP in X, error code in D)
			LDX	RSP
			MOVW	2,X+, HANDLER					;pull previous HANDLER (RSP -> X)
			MOVW	2,X+, PSP					;pull previous PSP (RSP -> X)		
			MOVW	2,X+, IP					;pull next IP (RSP -> X)		
			;Check if PSP is valid (RSP in X, error code in D)
			PS_CHECK_UFOF 0,FEXCPT_THROW_1,1,FEXCPT_THROW_1		;check PSP (PSP -> Y)
			;Return error code (RSP in X, error code in D)
			STD	0,Y						;push error code onto PS
			STX	RSP						;set RSP
			STY	PSP						;set PSP
			NEXT
FEXCPT_THROW_CESF	;Corrupt exception stack frame (error code in D)
FEXCPT_THROW_1		LDY	#FEXCPT_EC_CESF
			JOB	FEXCPT_THROW_4 					;print error message
			;Uncought exception, check for special error codes (error code in D)
FEXCPT_THROW_2		CPD	#FEXCPT_EC_ABORT 				;check for ABORT				
			BEQ	FEXCPT_THROW_6
			CPD	#FEXCPT_EC_ABORTQ 				;check for ABORT"				
			BEQ	FEXCPT_THROW_7
			CPD	#FEXCPT_EC_QUIT 				;check for QUIT				
			BEQ	FEXCPT_THROW_8
			CPD	#-((FEXCPT_MSGTAB_END-FEXCPT_MSGTAB_START)/2) 	;check for standard error code
			BLO	FEXCPT_THROW_3					;custom error message
			;Standard error code (error code in D)
			LDX     #FEXCPT_MSGTAB_END 				;look-up standard error message
			LSLD
			LDD	D,X	
			;Custom error code (error message in D)
FEXCPT_THROW_3		TFR	D, Y						;error message -> Y
			;Check message format (error message in Y)
			LEAX	1,Y						;count chars in message
			PRINT_STRCNT						
			IBEQ	A, FEXCPT_THROW_9 				;invalid error message
			;Check error level (error message in Y)
			LDAA	0,Y
			CMPA	#ERROR_LEVEL_FATAL
			BEQ	FEXCPT_THROW_5 					;fatal error
			CMPA	#ERROR_LEVEL_ERROR
			BNE	FEXCPT_THROW_9 					;invalid error message
			;Error (error message in Y)
FEXCPT_THROW_4		ERROR_PRINT						
			JOB	CF_ABORT_RT	
			;Fatal error (error message in Y)
FEXCPT_THROW_5		TFR	Y, D
			JOB	ERROR_RESTART
			;ABORT
FEXCPT_THROW_6		EQU	CF_ABORT_RT
			;JOB	CF_ABORT_RT	
			;ABORT" (message pointer in ABORT_QUOTE_MSG)
FEXCPT_THROW_7		LDX	ABORT_QUOTE_MSG
			BEQ	FEXCPT_THROW_9
			PRINT_STRCNT						
			IBEQ	A, FEXCPT_THROW_9				;invalid error message
			PRINT_LINE_BREAK
			PRINT_STR
			JOB	CF_ABORT_RT
			;QUIT
FEXCPT_THROW_8		EQU	CF_QUIT_RT
			;JOB	CF_QUIT_RT
			;Invalid error message 
FEXCPT_THROW_9		LDY	#FEXCPT_MSG_UNKNOWN
			JOB	FEXCPT_THROW_5

;#Code Fields:
;=============

;CATCH ( i*x xt -- j*x 0 | i*x n )
;Push an exception frame on the exception stack and then execute the execution
;token xt (as with EXECUTE) in such a way that control can be transferred to a
;point just after CATCH if THROW is executed during the execution of xt.
;If the execution of xt completes normally (i.e., the exception frame pushed by
;this CATCH is not popped by an execution of THROW) pop the exception frame and
;return zero on top of the data stack, above whatever stack items would have
;been returned by xt EXECUTE. Otherwise, the remainder of the execution
;semantics are given by THROW.
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
;"Parameter stack overflow"
;"Return stack overflow"
;"Corrupt exception stack frame"
CF_CATCH		PS_CHECK_UF	1, CF_CATCH_PSUF 	;check PS requirements (PSP -> Y)
			RS_CHECK_OF	3, CF_CATCH_RSOF	;check RS requirements 
			;Build exception stack frame 
			LDX	RSP				;RSP -> X
			MOVW	IP,	 2,-X			;IP      > RS
			LEAY	2,Y
			STY		 2,-X			;PSP     > RS
			MOVW	HANDLER, 2,-X			;HANDLER > RS			
			STX	RSP
			STX	HANDLER		      		;RSP -> HANDLER
			;Execute xt (RSP in X, PSP+2 in Y)
			MOVW	#IP_CATCH_RESUME, IP 		;set next IP	
			LDX	-2,Y 				;execute xt
			STY	PSP
			JMP	[0,X]
			;Resume CATCH, no exception was thrown
IP_CATCH_RESUME		DW	CFA_CATCH_RESUME
CFA_CATCH_RESUME	DW	CF_CATCH_RESUME
CF_CATCH_RESUME		RS_CHECK_UF 	3, CF_CATCH_CESF	;check for RS underflow (RSP -> X)
			PS_CHECK_OF	1, CF_CATCH_PSOF	;check for PS overflow (PSP-2 -> Y)
			;Check if HANDLER points to the top of the RS (RSP in X, PSP-2 in Y)
			CPX	HANDLER				;check if RSP==HANDLER
			BNE	CF_CATCH_CESF			;corrupt exception stack frame
			;Restore error stack frame (RSP in X, PSP-2 in Y)
			LEAX	4,X
			MOVW	2,X+, IP
			STX	RSP
			;Push 0x0 onto the PS (RSP in X, PSP-2 in Y)
			MOVW	#$0000, 0,Y			;push 0 onto PS
			STY	PSP
			;Done 
			NEXT	
CF_CATCH_PSUF		JOB	FEXCPT_THROW_PSUF			
CF_CATCH_PSOF		JOB	FEXCPT_THROW_PSOF			
CF_CATCH_RSOF		JOB	FEXCPT_THROW_RSOF			
CF_CATCH_CESF		JOB	FEXCPT_THROW_CESF		;corrupt exception stack frame 

;THROW ( k*x n -- k*x | i*x n )
;If any bits of n are non-zero, pop the topmost exception frame from the
;exception stack, along with everything on the return stack above that frame.
;Then restore the input source specification in use before the corresponding
;CATCH and adjust the depths of all stacks defined by this Standard so that they
;are the same as the depths saved in the exception frame (i is the same number
;as the i in the input arguments to the corresponding CATCH), put n on top of
;the data stack, and transfer control to a point just after the CATCH that
;pushed that exception frame.
;If the top of the stack is non zero and there is no exception frame on the
;exception stack, the behavior is as follows:
;If n is minus-one (-1), perform the function of ABORT (the version of
;ABORT in the Core word set), displaying no message.
;If n is minus-two, perform the function of ABORT" (the version of
;ABORT" in the Core word set), displaying the characters ccc associated with the
;ABORT" that generated the THROW.
;Otherwise, the system may display an implementation-dependent message giving
;information about the condition associated with the THROW code n. Subsequently,
;the system shall perform the function of ABORT (the version of ABORT
;in the Core word set).
;
;S12CForth implementation details:
;Throws:
;"Parameter stack underflow"
CF_THROW		PS_CHECK_UF	1, CF_THROW_PSUF	;PS for underflow (RSP -> Y)
			LDD	2,Y+				;check if TOS is 0
			BEQ	CF_THROW_1			;NEXT
			STX	PSP
			JOB	FEXCPT_THROW
CF_THROW_1		STX	PSP
			NEXT

CF_THROW_PSUF		JOB	FEXCPT_THROW_PSUF			
	
;ERROR"
;Non-standard S12CForth extension!
;Defines a new throwable error code (n).		
;Interpretation: ( "ccc<quote>" -- n )
;Parse ccc delimited by " (double-quote) and put the error code onto the parameter stack.
;Compilation: ( "ccc<quote>" -- )
;Parse ccc delimited by " (double-quote). Append the run-time semantics given ;"
;below to the current definition.
;Run-time: ( -- n )
;Put the error code onto the parameter stack.
;
;S12CForth implementation details:
;Trows:
;"Parameter stack overflow"
;"Dictionary overflow"
;"Parsed string overflow"
;"Empty message string"
CF_ERROR_QUOTE		;Parse quote
			LDAA	#$22 				;double quote
			SSTACK_JOBSR	FCORE_PARSE
			TBEQ	X, CF_ERROR_QUOTE_NOMSG 	;empty quote
			IBEQ	A, CF_ERROR_QUOTE_STROF		;add CFA to count
			TAB
			CLRA	
			;Check state (string pointer in X, char count+1 in D)
			LDY	STATE				;ensure that compile mode is on
			BEQ	CF_ERROR_QUOTE_3		;interpetation mode
			;Compile mode (string pointer in X, char count+1 in D) 
			ADDD	#3				;check for dictionary overflow
			TFR	X, Y
			DICT_CHECK_OF_D	CF_ERROR_QUOTE_DICTOF 
			;Append run-time CFA (string pointer in Y)
			LDX	CP
			MOVW	#CFA_ERROR_QUOTE_RT, 2,X+
			;Append error level (CP in X, string pointer in Y)
CF_ERROR_QUOTE_1	MOVB	#ERROR_LEVEL_ERROR, 1,X+
			;Append quote (CP in X, string pointer in Y)
			CPSTR_Y_TO_X
			STX	CP
			INTERPRET_ONLY	CF_ERROR_QUOTE_2
			STX	CP_SAVED
			;Done
CF_ERROR_QUOTE_2	NEXT
			;Interpretation mode  (string pointer in X, char count+1 in D) 
CF_ERROR_QUOTE_3	ADDD	#1				;check for dictionary overflow
			TFR	X, Y
			DICT_CHECK_OF_D	CF_ERROR_QUOTE_DICTOF
			TFR	Y, X
			;Push CP onto PS (string pointer in Y)
			PS_CHECK_OF	1, CF_ERROR_QUOTE_PSOF 	;(PSP-2 cells -> Y)
			MOVW	CP, 0,Y
			STY	PSP
			TFR	X, Y
			LDX	CP
			JOB	CF_ERROR_QUOTE_1
	
CF_ERROR_QUOTE_PSOF	JOB	FEXCPT_THROW_PSOF			
CF_ERROR_QUOTE_DICTOF	JOB	FEXCPT_THROW_DICTOF			
CF_ERROR_QUOTE_STROF	JOB	FEXCPT_THROW_STROF		
CF_ERROR_QUOTE_NOMSG	JOB	FEXCPT_THROW_NOMSG		

;ERROR" run-time semantics
;
;S12CForth implementation details:
;Throws:
;"Parameter stack overflow"
CF_ERROR_QUOTE_RT		PS_CHECK_OF	1, CF_ERROR_QUOTE_PSOF 	;(PSP-2 cells -> Y)
				;PUSH error code onto the PS 
				LDX	IP
				STX	0,Y
				STY	PSP
				;Advance IP (IP in X)
				LEAX	1,X
				PRINT_STRCNT
				LEAX	A,X
				STX	IP
				;Done
				NEXT
	
FEXCEPT_CODE_END		EQU	*
FEXCEPT_CODE_END_LIN	EQU	@

;###############################################################################
;# Tables                                                                      #
;###############################################################################
;Tabes in unpaged address space
;------------------------------ 
#ifdef FEXCEPT_TABS_START_LIN
			ORG 	FEXCEPT_TABS_START, FEXCEPT_TABS_START_LIN
#else
			ORG 	FEXCEPT_TABS_START
FEXCEPT_TABS_START_LIN	EQU	@
#endif	

FEXCPT_MSGTAB		EQU	*
			FEXCPT_MSG	FEXCPT_EC_PSOF,		"Parameter stack overflow"
			FEXCPT_MSG	FEXCPT_EC_PSUF,		"Parameter stack underflow" 
			FEXCPT_MSG	FEXCPT_EC_RSOF,		"Return stack overflow"
			FEXCPT_MSG	FEXCPT_EC_RSUF,		"Return stack underflow"
			;FEXCPT_MSG	FEXCPT_EC_DOOF,		"DO-loop nested too deeply"	
			FEXCPT_MSG	FEXCPT_EC_DICTOF,	"Dictionary overflow"
			;FEXCPT_MSG	FEXCPT_EC_INVALAD,R	"Invalid memory address"
			FEXCPT_MSG	FEXCPT_EC_0DIV,		"Division by zero"
			FEXCPT_MSG	FEXCPT_EC_RESOR,	"Result out of range"
			FEXCPT_MSG	FEXCPT_EC_UDEFWORD,	"Undefined word"
			FEXCPT_MSG	FEXCPT_EC_COMPONLY,	"Compile-only word"
			FEXCPT_MSG	FEXCPT_EC_NONAME,	"Missing name argument"
			FEXCPT_MSG	FEXCPT_EC_PADOF,	"PAD overflow"
			FEXCPT_MSG	FEXCPT_EC_STROF,	"String too long"
			FEXCPT_MSG	FEXCPT_EC_CTRLSTRUC,	"Control structure mismatch"
			;FEXCPT_MSG	FFEXCPT_EC_INVALNUM,	"Invalid numeric argument"
			FEXCPT_MSG	FEXCPT_EC_COMPNEST,	"Nested compilation"
			FEXCPT_MSG	FEXCPT_EC_NONCREATE,	"Illegal operation on non-CREATEd definition"
			;FEXCPT_MSG	FEXCPT_EC_INVALNAME,	"Invalid name argument"
			FEXCPT_MSG	FEXCPT_EC_INVALBASE,	"Invalid BASE"
			FEXCPT_MSG	FEXCPT_EC_CESF,		"Corrupt exception stack frame"
			FEXCPT_MSG	FEXCPT_EC_NOMSG,	"Empty message string"
			FEXCPT_MSG	FEXCPT_EC_DICTPROT,	"Destruction of dictionary structure"
			FEXCPT_MSG	FEXCPT_EC_COMERR,	"Invalid RX data"
			FEXCPT_MSG	FEXCPT_EC_COMOF		"RX buffer overflow"
			FEXCPT_MSG	0			"Unknown problem"
	
FEXCEPT_TABS_END	EQU	*
FEXCEPT_TABS_END_LIN	EQU	@

;###############################################################################
;# Words                                                                       #
;###############################################################################
#ifdef FEXCEPT_WORDS_START_LIN
			ORG 	FEXCEPT_WORDS_START, FEXCEPT_WORDS_START_LIN
#else
			ORG 	FEXCEPT_WORDS_START
FEXCEPT_WORDS_START_LIN	EQU	@
#endif	

;#Code Field Addresses:
;======================
			ALIGN	1

;Word: CATCH ( i*x xt -- j*x 0 | i*x n )
;Push an exception frame on the exception stack and then execute the execution
;token xt (as with EXECUTE) in such a way that control can be transferred to a
;point just after CATCH if THROW is executed during the execution of xt.
;If the execution of xt completes normally (i.e., the exception frame pushed by
;this CATCH is not popped by an execution of THROW) pop the exception frame and
;return zero on top of the data stack, above whatever stack items would have
;been returned by xt EXECUTE. Otherwise, the remainder of the execution
;semantics are given by THROW.
CFA_CATCH		DW	CF_CATCH

;Word: THROW ( k*x n -- k*x | i*x n )
;If any bits of n are non-zero, pop the topmost exception frame from the
;exception stack, along with everything on the return stack above that frame.
;Then restore the input source specification in use before the corresponding
;CATCH and adjust the depths of all stacks defined by this Standard so that they
;are the same as the depths saved in the exception frame (i is the same number
;as the i in the input arguments to the corresponding CATCH), put n on top of
;the data stack, and transfer control to a point just after the CATCH that
;pushed that exception frame.
;If the top of the stack is non zero and there is no exception frame on the
;exception stack, the behavior is as follows:
;If n is minus-one (-1), perform the function of ABORT (the version of
;ABORT in the Core word set), displaying no message.
;If n is minus-two, perform the function of ABORT" (the version of
;ABORT" in the Core word set), displaying the characters ccc associated with the
;ABORT" that generated the THROW.
;Otherwise, the system may display an implementation-dependent message giving
;information about the condition associated with the THROW code n. Subsequently,
;the system shall perform the function of ABORT (the version of ABORT
;in the Core word set).
CFA_THROW		DW	CF_THROW

;Word ERROR"										IMMEDIATE
;Non-standard S12CForth extension!
;Defines a new throwable error code (n).		
;Interpretation: ( "ccc<quote>" -- n )
;Parse ccc delimited by " (double-quote) and put the error code onto the parameter stack.
;Compilation: ( "ccc<quote>" -- )
;Parse ccc delimited by " (double-quote). Append the run-time semantics given ;"
;below to the current definition.
;Run-time: ( -- n )
;Put the error code onto the parameter stack.
CFA_ERROR_QUOTE		DW	CF_ERROR_QUOTE 			
;ERROR" run-time semantics
CFA_ERROR_QUOTE_RT	DW	CF_ERROR_QUOTE_RT 			
	
FEXCEPT_WORDS_END		EQU	*
FEXCEPT_WORDS_END_LIN	EQU	@
