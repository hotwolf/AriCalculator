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
;FEXCPT_EC_STROF		EQU	-18	;parsed string overflow
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
;FEXCPT_EC_53  			EQU	-53	;exception stack overflow
;FEXCPT_EC_54			EQU	-54	;floating-point underflow
;FEXCPT_EC_55			EQU	-55	;floating-point unidentified fault
FEXCPT_EC_QUIT			EQU	-56	;QUIT
FEXCPT_EC_COMERR		EQU	-57	;exception in sending or receiving a character
;FEXCPT_EC_58			EQU	-58	;[IF], [ELSE], or [THEN] exception
	
;S12CForth specific error codes 
FEXCPT_EC_LITOR			EQU	-59	;literal out of range

;FEXCPT_EC_NOMSG			EQU	-59	;empty message string
;FEXCPT_EC_DICTPROT		EQU	-60	;destruction of dictionary structure
;FEXCPT_EC_RESUME		EQU	-61	;resume from suspend

;Highest standard error code value
FEXCPT_EC_MAX			EQU	FEXCPT_EC_LITOR

;Character limit fopr error messages
FEXCPT_MSG_LIMIT		EQU	64 	;Valid error messages must be shorter than 65 chars
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FEXCPT_VARS_START_LIN
			ORG 	FEXCPT_VARS_START, FEXCPT_VARS_START_LIN
#else
			ORG 	FEXCPT_VARS_START
FEXCPT_VARS_START_LIN	EQU	@
#endif	

HANDLER			DS	2 	;pointer tho the most recent exception
					;handler 
FEXCPT_VARS_END		EQU	*
FEXCPT_VARS_END_LIN	EQU	@

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

;Functions:
;==========
;#Print error message
; args:   D: error code
; result: none
; SSTACK: 26 bytes
;         X, Y and D are preserved
#macro	FEXCPT_PRINT_MSG, 0
			SSTACK_JOBSR	FEXCPT_PRINT_MSG, 26
#emac

;CATCH and THROW from assembly code:
;===================================
;#Throw an exception from within an assembler primitive (error code in D)
; args:   D: error code
; result: none
; SSTACK: none
; PS:     none
; RS:     none
;         no registers are preserved 
#macro	THROW_D, 0
			;BGND
			JOB	FEXCPT_THROW	;throw exception
#emac
	
;#Throw an exception from within an assembler primitive (immediate error code)
; args:   1: error code
; result: none
; SSTACK: none
; PS:     none
; RS:     none
;         no registers are preserved 
#macro	THROW, 1
			LDD	#\1		;set error code
			THROW_D
#emac

;Error message table:
;====================
;#Error message table entry
; args: 1: error code
; 	2: message string
#macro	FEXCPT_MSG, 2
			DB	\1		 ;error code
			FCS	\2		 ;error message
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FEXCPT_CODE_START_LIN
			ORG 	FEXCPT_CODE_START, FEXCPT_CODE_START_LIN
#else
			ORG 	FEXCPT_CODE_START
FEXCPT_CODE_START_LIN	EQU	@
#endif

;#Print error message
; args:   D: error code
; result: none
; SSTACK: 26 bytes
;         X, Y and D are preserved
FEXCPT_PRINT_MSG	EQU	*
			;Check if a message is to be printed (error code in D)			
			TBEQ	D, FEXCPT_PRINT_MSG_6				;no error message (error code =  0)
			CPD	#FEXCPT_EC_ABORTQ 				;check for ABORT code (-1 or -2)
			BHS	FEXCPT_PRINT_MSG_6				;no error message (error code = -1 or -2)
			CPD	#FEXCPT_EC_QUIT					;check for QUIT code (-56)
			BEQ	FEXCPT_PRINT_MSG_6				;no error message (error code = -56)
			;Save registers (error code in D)
			PSHX
			PSHY		
			PSHD
			;Print message header (error code in D)			
			LDX	#FEXCPT_MSG_HEAD 				;messeage head
			FCOM_PRINT_BL						;(SSTACK: 10 bytes)
			;Check for standard error messages (error code in D)
			CPD	#FEXCPT_EC_MAX 					;check for user defined error message
			BLS	FEXCPT_PRINT_MSG_				;check user defined error message
			;Determine standard error message (error code in D)			
			LDX     #FEXCPT_MSGTAB					;start at the beginning of the lookup table
FEXCPT_PRINT_MSG_1	LDAA	1,X+ 						;check the current error code
			BEQ	FEXCPT_PRINT_MSG_3 				;unknown error				
			CBA							;check error code
			BEQ	FEXCPT_PRINT_MSG_7 				;error message found
FEXCPT_PRINT_MSG_2	LDAA	1,X+ 						;skip over message string
			BPL	FEXCPT_PRINT_MSG_2
			JOB	FEXCPT_PRINT_MSG_1			
			;Print unknown error code as signed decimal (error code in B)
FEXCPT_PRINT_MSG_3	LDX	#FEXCPT_MSG_UNKNOWN_NEG 			;messsage string for unknown error codes
			FCOM_PRINT_BL						;(SSTACK: 10 bytes)
			CLRA							;negate error code
			SBA							;positive error code -> A
			TAB							;positive error code -> X
			CLRA						
			TFR	D, X	
			CLRB							;positive error code -> Y:X
			TFR	D, Y	
			LDAB	#10 						;decimal base -> B
			NUM_REVERSE 						;calculate reverse number (SSTACK: 18 bytes)
FEXCPT_PRINT_MSG_4	NUM_REVPRINT_BL						;print reverse number
			NUM_CLEAN_REVERSE 					;clean up stack
			;Restore registers
FEXCPT_PRINT_MSG_5	PULD
			PULY
			PULX
			;Done
FEXCPT_PRINT_MSG_6	RTS
			;Print error message (string pointer in X)	
FEXCPT_PRINT_MSG_7	FCOM_PRINT_BL						;print message
			JOB	FEXCPT_PRINT_MSG_5				;restore registers
			;Check user defined error message (error code in D)
			TFR	D, X 						;string pointer -> X
			TFR	D, Y 						;string pointer -> Y
			LDAA	#FEXCPT_MSG_LIMIT 				;max. message length 
FEXCPT_PRINT_MSG_8	LDAB	1,Y+		  				;get char
			CMPB	#$20						;char < " "?
			BMI	FEXCPT_PRINT_MSG_10 				;termination found
			CMPB	#$20		;" "
			BLO	FEXCPT_PRINT_MSG_9 				;invalid char found
			CMPB	#$7E		;"~"
			BHI	FEXCPT_PRINT_MSG_9 				;invalid char found
			DBNE	A, FEXCPT_PRINT_MSG_8 				;check next char
			;Print unknown error code as hexadecimal number (error code in X)
FEXCPT_PRINT_MSG_9	LDY	#0000 						;error code -> Y:X
			LDAB	#16 						;hexadecimal base -> B
			NUM_REVERSE 						;calculate reverse number (SSTACK: 18 bytes)			
			LDX	#FEXCPT_MSG_UNKNOWN_HEX 			;messsage string for unknown error codes
			FCOM_PRINT_BL						;(SSTACK: 10+6 bytes)
			TAB							;calculate number of leading zeros
			LDAA	#4
			SBA
			LDAB	#"0" 						;print leading zeros
			;FCOM_FILL_BL 						;(SSTACK: 9+6 bytes)
			JOB	FEXCPT_PRINT_MSG_4 				;print error code
			;Check termination char Print (char in B, error code in X)
FEXCPT_PRINT_MSG_10	CMPB	#$A0		;" "
			BLO	FEXCPT_PRINT_MSG_9 				;invalid char found
			CMPB	#$FE		;"~"
			BHI	FEXCPT_PRINT_MSG_9 				;invalid char found
			JOB	FEXCPT_PRINT_MSG_7				;print error message
	
;#Throw an exception
; args:   D: error code
; result: none
; SSTACK: 16 bytes
;         no registers are preserved 
FEXCPT_THROW		EQU	*
			;Check if the excption is cought (error code in D)
			LDX	HANDLER						;check if an exception handler exists
			BNE	FEXCPT_THROW_2					;check exception handler
			;Default exception handler (error code in D)
FEXCPT_THROW_1		CPD	#FEXCPT_EC_ABORTQ 				;check for ABORT code (-1 or -2)
			BHS	CF_ABORT_RT 					;ABORT (-1 or -2)
			CPD	#FEXCPT_EC_QUIT					;check for QUIT code (-56)
			BEQ	CF_QUIT_RT					;QUIT (error code = -56)
			FEXCPT_PRINT_MSG 					;print error message (SSTACK: 26 bytes) 
			LDX	NEXT_PTR 					;check for SUSPEND mode
			CPX	#NEXT_SUSPEND_MODE
			BEQ	CF_QUIT_RT					;SUSPEND
			JOB	CF_ABORT_RT 					;ABORT
			;Cought exception, verify error frame location (HANDLER in X, error code in D)
FEXCPT_THROW_2		CPX	RSP 						;check that HANDLER is on the RS
			BLO	FEXCPT_THROW_1  				;error frame is located above the stack
			CPX	#(RS_EMPTY-6)					;check for 3 cell exception frame
			BHI	FEXCPT_THROW_1 					;error frame is located above the stack
			;Restore stacks (HANDLER in X, error code in D)
			MOVW	2,X+, HANDLER					;pull previous HANDLER (RSP -> X)
			LDY	2,X+						;pull previous PSP (RSP -> X)		
			MOVW	2,X+, IP					;pull next IP (RSP -> X)		
			STX	RSP
			;Check if PSP is valid (new PSP in Y, error code in D)
			CPY	#PS_EMPTY 					;check for PS underflow
			BHI	FEXCPT_THROW_1 					;invalid exception handler
			LDX	PAD
			LEAX	2,X	     					;make sure there is room for the return value
			BLO	FEXCPT_THROW_1 					;invalid exception handler
			;Push error code onto PS (new in Y, error code in D)
			STD	2,-Y						;push error code onto PS
			STY	PSP						;set PSP
			NEXT

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
CF_CATCH		EQU	*
			RS_CHECK_OF	3			;check RS requirements 
			PS_CHECK_UF	1			;check PS requirements (PSP -> Y)
			;Build exception stack frame (PSP in Y)
			LDX	RSP				;RSP -> X
			MOVW	IP,	 2,-X			;IP      > RS
			LEAY	2,Y
			STY		 2,-X			;PSP     > RS
			MOVW	HANDLER, 2,-X			;HANDLER > RS			
			STX	RSP
			STX	HANDLER		      		;RSP -> HANDLER
			;Execute xt (RSP in X, PSP+2 in Y)
			LDX	-2,Y 				;fetch xt
			STY	PSP				;update PSP
			EXEC_CFA_X				;execute xt
			RS_CHECK_UF 	3			;check for RS underflow (RSP -> X)
			PS_CHECK_OF	1			;check for PS overflow (PSP-2 -> Y)
			;Check if HANDLER points to the top of the RS (RSP in X, PSP-2 in Y)
			CPX	HANDLER				;check if RSP==HANDLER
			BEQ	CF_CATCH_1			;HANDLER is ok
			MOVW	#$0000, HANDLER			;reset HANDLER
			;JOB	FEXCPT_THROW_CESF		;throw exception stack frame error
			;Restore previous HANDLER (RSP in X, PSP-2 in Y)
CF_CATCH_1		LEAX	4,X
			MOVW	2,X+, IP
			STX	RSP
			;Push 0x0 onto the PS (RSP in X, PSP-2 in Y)
			MOVW	#$0000, 0,Y			;push 0 onto PS
			STY	PSP
			;Done 
			NEXT	

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
CF_THROW		PS_CHECK_UF	1			;PS for underflow (PSP -> Y)
			LDD	2,Y+				;check if TOS is 0
			BEQ	CF_THROW_1			;NEXT
			STX	PSP
			JOB	FEXCPT_THROW
CF_THROW_1		STX	PSP
			NEXT
	
FEXCPT_CODE_END		EQU	*
FEXCPT_CODE_END_LIN	EQU	@

;###############################################################################
;# Tables                                                                      #
;###############################################################################
;Tabes in unpaged address space
;------------------------------ 
#ifdef FEXCPT_TABS_START_LIN
			ORG 	FEXCPT_TABS_START, FEXCPT_TABS_START_LIN
#else
			ORG 	FEXCPT_TABS_START
FEXCPT_TABS_START_LIN	EQU	@
#endif	

FEXCPT_MSG_HEAD		STRING_NL_NONTERM
			FCS		"Error! "

FEXCPT_MSG_UNKNOWN_NEG	FCS		"Code: -"
FEXCPT_MSG_UNKNOWN_HEX	FCS		"Code: 0x"
	
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
			;FEXCPT_MSG	FEXCPT_EC_STROF,	"String too long"
			FEXCPT_MSG	FEXCPT_EC_CTRLSTRUC,	"Control structure mismatch"
			;FEXCPT_MSG	FFEXCPT_EC_INVALNUM,	"Invalid numeric argument"
			FEXCPT_MSG	FEXCPT_EC_COMPNEST,	"Nested compilation"
			FEXCPT_MSG	FEXCPT_EC_NONCREATE,	"Illegal operation on non-CREATEd definition"
			;FEXCPT_MSG	FEXCPT_EC_INVALNAME,	"Invalid name argument"
			FEXCPT_MSG	FEXCPT_EC_INVALBASE,	"Invalid BASE"
			;FEXCPT_MSG	FEXCPT_EC_CESF,		"Corrupt exception stack frame"
			FEXCPT_MSG	FEXCPT_EC_NOMSG,	"Empty message string"
			FEXCPT_MSG	FEXCPT_EC_DICTPROT,	"Destruction of dictionary structure"
			FEXCPT_MSG	FEXCPT_EC_COMERR,	"Corrupted RX data"
			DB		0

FEXCPT_MSGTAB_END	EQU	*

FEXCPT_TABS_END		EQU	*
FEXCPT_TABS_END_LIN	EQU	@

;###############################################################################
;# Words                                                                       #
;###############################################################################
#ifdef FEXCPT_WORDS_START_LIN
			ORG 	FEXCPT_WORDS_START, FEXCPT_WORDS_START_LIN
#else
			ORG 	FEXCPT_WORDS_START
FEXCPT_WORDS_START_LIN	EQU	@
#endif	
			ALIGN	1
;#ANSForth Words:
;================
;Word: CATCH ( i*x xt -- j*x 0 | i*x n )
;Push an exception frame on the exception stack and then execute the execution
;token xt (as with EXECUTE) in such a way that control can be transferred to a
;point just after CATCH if THROW is executed during the execution of xt.
;If the execution of xt completes normally (i.e., the2 exception frame pushed by
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

;QUIT ( -- )  ( R:  i*x -- )
;Empty the return stack, store zero in SOURCE-ID if it is present, make the user
;input device the input source, and enter interpretation state. Do not display a
;message. Repeat the following:
;Accept a line from the input source into the input buffer, set >IN to zero, and
;interpret.
;Display the implementation-defined system prompt if in interpretation state,
;all processing has been completed, and no ambiguous condition exists.
CFA_QUIT		DW	CF_INNER
			DW	CFA_LITERAL
			DW

;S12CForth Words:
;================
	
FEXCPT_WORDS_END		EQU	*
FEXCPT_WORDS_END_LIN		EQU	@
