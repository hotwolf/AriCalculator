#ifndef FEXCPT
#define FEXCPT
;###############################################################################
;# S12CForth - FEXCPT - Forth Exception Words                                  #
;###############################################################################
;#    Copyright 2009-2016 Dirk Heisswolf                                       #
;#    This file is part of the S12CForth framework for NXP's S12C MCU          #
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
;#    S12CForth register assignments:                                          #
;#      IP  (instruction pounter)     = PC (subroutine theaded)                #
;#      RSP (return stack pointer)    = SP                                     #
;#      PSP (parameter stack pointer) = Y                                      #
;#  									       #
;#    Interrupts must be disabled while Y is temporarily used for other        #
;#    purposes.								       #
;#  									       #
;#    S12CForth system variables:                                              #
;#        HANDLER = Points to the next exception stack frame                   #
;#  									       #
;#    Program termination options:                                             #
;#        ABORT:                                                               #
;#        QUIT:                                                                #
;#                                                                             #
;#    The following notation is used to describe the stack layout in the word  #
;#    definitions:                                                             #
;#                                                                             #
;#    Symbol          Data type                       Size on stack	       #
;#    ------          ---------                       -------------	       #
;#    flag            flag                            1 cell		       #
;#    true            true flag                       1 cell		       #
;#    false           false flag                      1 cell		       #
;#    char            character                       1 cell		       #
;#    n               signed number                   1 cell		       #
;#    +n              non-negative number             1 cell		       #
;#    u               unsigned number                 1 cell		       #
;#    n|u 1           number                          1 cell		       #
;#    x               unspecified cell                1 cell		       #
;#    xt              execution token                 1 cell		       #
;#    addr            address                         1 cell		       #
;#    a-addr          aligned address                 1 cell		       #
;#    c-addr          character-aligned address       1 cell		       #
;#    d-addr          double address                  2 cells (non-standard)   #
;#    d               double-cell signed number       2 cells		       #
;#    +d              double-cell non-negative number 2 cells		       #
;#    ud              double-cell unsigned number     2 cells		       #
;#    d|ud 2          double-cell number              2 cells		       #
;#    xd              unspecified cell pair           2 cells		       #
;#    colon-sys       definition compilation          implementation dependent #
;#    do-sys          do-loop structures              implementation dependent #
;#    case-sys        CASE structures                 implementation dependent #
;#    of-sys          OF structures                   implementation dependent #
;#    orig            control-flow origins            implementation dependent #
;#    dest            control-flow destinations       implementation dependent #
;#    loop-sys        loop-control parameters         implementation dependent #
;#    nest-sys        definition calls                implementation dependent #
;#    i*x, j*x, k*x 3 any data type                   0 or more cells	       #
;#  									       #
;#    Counted strings are implemented as terminated strings. String            #
;#    termination is done by setting bit 7 in the last character of the        #   
;#    string. Pointers to empty strings have the value $0000.		       #
;#  									       #
;###############################################################################
;# Version History:                                                            #
;#    June 15, 2009                                                            #
;#      - Initial release, based on Michael Milendorf's paper                  #
;#       "Catch and Throw                                                      #
;#    October 6, 2016                                                          #
;#      - Started subroutine threaded implementation                           #
;###############################################################################
;# Required Modules:                                                           #
;#    BASE   - S12CBase framework                                              #
;#    FPS    - Forth parameter stack                                           #
;#    FRS    - Forth return stack                                              #
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
;Standard THROW codes (ANS Forth)
FEXCPT_TC_ABORT			EQU	-1 	;ABORT
FEXCPT_TC_ABORTQ		EQU	-2 	;ABORT"
FEXCPT_TC_PSOF			EQU	-3 	;stack overflow
FEXCPT_TC_PSUF			EQU	-4 	;stack underflow
FEXCPT_TC_RSOF			EQU	-5 	;return stack overflow
FEXCPT_TC_RSUF			EQU	-6 	;return stack underflow
FEXCPT_TC_DOOF			EQU	-7 	;do-loops nested too deeply during execution
FEXCPT_TC_DICTOF		EQU	-8 	;dictionary overflow
FEXCPT_TC_INVALADR		EQU	-9 	;invalid memory address
FEXCPT_TC_0DIV			EQU	-10	;division by zero
FEXCPT_TC_RESOR			EQU	-11	;result out of range
;FEXCPT_TC_12			EQU	-12	;argument type mismatch
FEXCPT_TC_UDEFWORD		EQU	-13	;undefined word	
FEXCPT_TC_COMPONLY		EQU	-14	;interpreting a compile-only word
;FEXCPT_TC_15			EQU	-15	;invalid FORGET
FEXCPT_TC_NONAME		EQU	-16	;attempt to use zero-length string as a name
FEXCPT_TC_PADOF			EQU	-17	;pictured numeric output string overflow
;FEXCPT_TC_STROF		EQU	-18	;parsed string overflow
;FEXCPT_TC_19			EQU	-19	;definition name too long
;FEXCPT_TC_20			EQU	-20	;write to a read-only location
;FEXCPT_TC_21			EQU	-21	;unsupported operation (e.g., AT-XY on a too-dumb terminal)
FEXCPT_TC_CTRLSTRUC		EQU	-22	;control structure mismatch
;FEXCPT_TC_23			EQU	-23	;address alignment exception
FEXCPT_TC_INVALNUM		EQU	-24	;invalid numeric argument
;FEXCPT_TC_25			EQU	-25	;return stack imbalance
;FEXCPT_TC_26			EQU	-26	;loop parameters unavailable
;FEXCPT_TC_27			EQU	-27	;invalid recursion
;FEXCPT_TC_28			EQU	-28	;user interrupt
FEXCPT_TC_COMPNEST		EQU	-29	;compiler nesting
;FEXCPT_TC_30			EQU	-30	;obsolescent feature
FEXCPT_TC_NONCREATE		EQU	-31	;>BODY used on non-CREATEd definition
FEXCPT_TC_INVALNAME		EQU	-32	;invalid name argument (e.g., TO xxx)
;FEXCPT_TC_33			EQU	-33	;block read exception
;FEXCPT_TC_34			EQU	-34	;block write exception
;FEXCPT_TC_35			EQU	-35	;invalid block number
;FEXCPT_TC_36			EQU	-36	;invalid file position
;FEXCPT_TC_37			EQU	-37	;file I/O exception
;FEXCPT_TC_38			EQU	-38	;non-existent file
;FEXCPT_TC_39			EQU	-39	;unexpected end of file
FEXCPT_TC_INVALBASE		EQU	-40	;invalid BASE for floating point conversion
;FEXCPT_TC_41			EQU	-41	;loss of precision
;FEXCPT_TC_42			EQU     -42	;floating-point divide by zero
;FEXCPT_TC_43			EQU	-43	;floating-point result out of range
;FEXCPT_TC_44			EQU	-44	;floating-point stack overflow
;FEXCPT_TC_45			EQU	-45	;floating-point stack underflow
;FEXCPT_TC_46			EQU	-46	;floating-point invalid argument
;FEXCPT_TC_47			EQU	-47	;compilation word list deleted
;FEXCPT_TC_48			EQU	-48	;invalid POSTPONE
;FEXCPT_TC_49			EQU	-49	;search-order overflow
;FEXCPT_TC_50			EQU	-50	;search-order underflow
;FEXCPT_TC_51			EQU	-51	;compilation word list changed
;FEXCPT_TC_52			EQU	-52	;control-flow stack overflow
FEXCPT_TC_EXCPTERR  		EQU	-53	;exception stack overflow
;FEXCPT_TC_54			EQU	-54	;floating-point underflow
;FEXCPT_TC_55			EQU	-55	;floating-point unidentified fault
FEXCPT_TC_QUIT			EQU	-56	;QUIT
FEXCPT_TC_COMERR		EQU	-57	;exception in sending or receiving a character
;FEXCPT_TC_58			EQU	-58	;[IF], [ELSE], or [THEN] exception
	
;S12CForth specific error codes 
FEXCPT_TC_LITOR			EQU	-256	;literal out of range

;FEXCPT_TC_DICTPROT		EQU	-61	;destruction of dictionary structure
;FEXCPT_TC_NOMSG		EQU	-62	;empty message string
;FEXCPT_TC_DICTPROT		EQU	-63	;destruction of dictionary structure
;FEXCPT_TC_RESUME		EQU	-64	;resume from suspend

;Highest system THROW code value
;ANS Forth Standard: Standard THROW codes: [-255...-1]
;                      System THROW codes: [-4095...-256]
;                User defined THROW codes: [-32768...-4096] [32767...0]
FEXCPT_SYSTC_MAX		EQU	$F000 ;-4096

;Character limit for error messages
FEXCPT_MSG_LIMIT		EQU	64 	;Valid error messages must be shorter than 65 chars

;Default exception handler  
FEXCPT_DEFAULT_HANDLER		EQU	$0000 	;initial exception handler
	
;#String termination 
FEXCPT_TERM			EQU	STRING_TERM

;#ASCII code 
FEXCPT_SYM_BEEP			EQU	STRING_SYM_BEEP		;acoustic signal

;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FEXCPT_VARS_START_LIN
				ORG 	FEXCPT_VARS_START, FEXCPT_VARS_START_LIN
#else				
				ORG 	FEXCPT_VARS_START
FEXCPT_VARS_START_LIN		EQU	@
#endif				
				
HANDLER				DS	2 		;pointer tho the most recent exception handler 
ABORT_QUOTE_MSG			DS	2		;pointer to latest ABORT" message
				
FEXCPT_VARS_END			EQU	*
FEXCPT_VARS_END_LIN		EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization (executed along with ABORT action)
;===============
#macro	FEXCPT_INIT, 0
				MOVW	#FEXCPT_DEFAULT_HANDLER, HANDLER;reset exception handler
#emac

;#Abort action (to be executed in addition of QUIT action)
;=============
#macro	FEXCPT_ABORT, 0
#emac
	
;#Quit action
;============
#macro	FEXCPT_QUIT, 0
#emac

;Error message table
;===================
;#Error message table entry
; args: 1: error code
; 	2: message string
#macro	FEXCPT_MSG, 2
				DW	\1		 ;error code
				FCS	\2		 ;error message
#emac

;Monitor
;=======
#macro	FEXCPT_MONITOR, 0
#emac

;Functions:
;==========
;#Throw an exception from within an assembler primitive (immediate error code)
; args:   1: error code
; result: none
; SSTACK: none
; PS:     none
; RS:     none
;         no registers are preserved 
#macro	THROW, 1
			LDD	#\1 				;THROW code -> D
			JOB	CF_THROW_1			;throw exception
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

;#IO
;===
;#Transmit one char
; args:   B: data to be send
; SSTACK: 8 bytes
;         X, Y, and D are preserved
FEXCPT_TX_CHAR		EQU	SCI_TX_BL

;#Prints a MSB terminated string
; args:   X: start of the string
; result: X: points to the byte after the string
; SSTACK: 10 bytes
;         Y and D are preserved
FEXCPT_TX_STRING	EQU	STRING_PRINT_BL

;#Validate error message
; args:   X:      start of the string
; result: C-flag: set if message is valid
; SSTACK: 5 bytes
;         X, Y and D are preserved
FEXCPT_CHECK_ERRMSG	EQU	STRING_PRINT_BL
			;Save registers (string pointer in X)
			PSHX					;save X
			PSHA					;save A
			;Check string (string pointer in X)
			LDAA	#FEXCPT_MSG_LIMIT		;max. message length -> A
			CLC					;signal failure by default
FEXCPT_CHECK_ERRMSG_1	BRCLR	0,X, #$60,FEXCPT_CHECK_ERRMSG_2	;C0 char
			BRSET	0,X, #$7F,FEXCPT_CHECK_ERRMSG_2	;DEL char
			BRSET	1,X+,#$80,FEXCPT_CHECK_ERRMSG_3	;string termination
			DBNE	A, FEXCPT_CHECK_ERRMSG_1	;loop
			;Restore registers 
FEXCPT_CHECK_ERRMSG_2	PULA					;restore A
			PULX					;restore X
			RTS					;done
			;Success 
FEXCPT_CHECK_ERRMSG_3	SEC					;flag success
			JOB	FEXCPT_CHECK_ERRMSG_2		;done
		
;#Print THROW code
; args:   d: THROW code
; result: none
; SSTACK: 10 bytes
;         X, Y and D are preserved
FEXCPT_TX_TC		EQU	FOUTER_TX_CELL
	
;#########
;# Words #
;#########
	
;Word: CATCH ( i*x xt -- j*x 0 | i*x n )
;Push an exception frame on the exception stack and then execute the execution
;token xt (as with EXECUTE) in such a way that control can be transferred to a
;point just after CATCH if THROW is executed during the execution of xt.
;If the execution of xt completes normally (i.e., the exception frame pushed by
;this CATCH is not popped by an execution of THROW) pop the exception frame and
;return zero on top of the data stack, above whatever stack items would have
;been returned by xt EXECUTE. Otherwise, the remainder of the execution
;semantics are given by THROW.
IF_CATCH		REGULAR
CF_CATCH		EQU	*
			;Build exception stack frame ( xt )
			;"xt after CATCH call" is already on the RS 
			PSHY					;PSP     -> RS
			MOVW	HANDLER, 2,-SP			;HANDLER -> RS
			STS	HANDLER				;update HANDLER
			; execute xt( xt )
			JSR	2,Y+				;execute xt
			MOVW	#$0000, 2,-Y			;0 -> PS
			JMP	4,+SP				;remove frame and resume



;Word: ABORT" 
;Interpretation: Interpretation semantics for this word are undefined.
;Compilation: ( "ccc<quote>" -- )
;Parse ccc delimited by a " (double-quote). Append the run-time semantics given
;below to the current definition.
;Run-time: ( i*x x1 --  | i*x ) ( R: j*x --  | j*x )
;Remove x1 from the stack. If any bit of x1 is not zero, display ccc and perform
;an implementation-defined abort sequence that includes the function of ABORT.
IF_ABORT_QUOTE		IMMEDIATE
CF_ABORT_QUOTE		EQU	*
			;Parse "ccc<quote>"
			MOVW	#$22, 2,-Y 			;"-delimiter -> PS
			JOBSR	CF_PARSE			;parse "ccc<quote>"
			;Check state 
			LDD	STATE 				;STATE -> D
			BEQ	CF_ABORT_QUOTE_1		;interpretatiom semantics
			;Compilation semantics ( c-addr u )
			MOVW	#CF_ABORT_QUOTE_RT, 2,-Y 	;runtime semantics -> PS
			JOBSR	CF_COMPILE_COMMA		;compile word
			JOBSR	CF_STRING_COMMA			;compile string
			RTS					;done
			;Interpretation semantics ( x1 c-addr u )
CF_ABORT_QUOTE_1	LDD	4,Y 				;check X1
			BNE	CF_ABORT_QUOTE_2		;x1 != 0
			LEAY	6,Y				;clean up PS
			RTS					;done
CF_ABORT_QUOTE_2	JOBSR	CF_CR				;line break
			JOBSR	CF_DOT_STRING			;print ABORT" message
			JOB	CF_ABORT_RT			;uncatchable!!! (for simplicity)

;ABORT" run-time semantics
CF_ABORT_QUOTE_RT	EQU	*
			;Check flag ( i*x x1 )
			LDD	2,Y+ 				;x1 -> X
			BEQ	CF_ABORT_QUOTE_RT_1		;skip over string
			MOVW	2,SP+, ABORT_QUOTE_MSG		;store ABORT" message
			THROW	FEXCPT_TC_ABORTQ		;throw exception
			;Skip over terminated string  
CF_ABORT_QUOTE_RT_1	LDX	2,SP+ 				;string pointer -> X
			BRCLR	1,X+,#FEXCPT_TERM,*		;skip over terminated string
			JMP	0,X				;resume after string
	
;Word: ABORT ( i*x -- ) ( R: j*x -- )
;Empty the data stack and perform the function of QUIT, which includes emptying
;the return stack, without displaying a message.
IF_ABORT		INLINE	CF_ABORT
CF_ABORT		EQU	*
			;Throw ABORT code 
			THROW	FEXCPT_TC_ABORT
CF_ABORT_EOI		EQU	*
	
;Word: QUIT ( -- )  ( R:  i*x -- )
;Empty the return stack, store zero in SOURCE-ID if it is present, make the user
;input device the input source, and enter interpretation state. Do not display a
;message. Repeat the following:
;Accept a line from the input source into the input buffer, set >IN to zero, and
;interpret.
;Display the implementation-defined system prompt if in interpretation state,
;all processing has been completed, and no ambiguous condition exists.
IF_QUIT			INLINE	CF_QUIT
CF_QUIT			EQU	*
			;Throw ABORT code 
			THROW	FEXCPT_TC_ABORT
CF_QUIT_EOI		EQU	*

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
IF_THROW		REGULAR
CF_THROW		EQU	*
			;Check THROW code ( k*x n )
			LDD	2,Y+				;THROW code -> D
			BEQ	CF_THROW_2			;done
			;Check HANDLER ( k*x n ) (THROW code in D)
CF_THROW_1		LDX	HANDLER				;HANDLER -> X
			BEQ	CF_THROW_3			;default handler
			;Resume after QUIT 
			MOVW	2,X+, HANDLER			;update HANDLER
			STY	2,X+				;update PSP
			STD	0,Y				;replace THROW code
			JMP	2,X+				;resume after CATCH
			;Do nothing
CF_THROW_2		RTS					;done
			;Default handler (THROW code in D)
CF_THROW_3		CPD	#FEXCPT_TC_QUIT			;check for QUIT
			BEQ	CF_QUIT_RT
			CPD	#FEXCPT_TC_ABORT 		;check for ABORT
			BEQ	CF_ABORT_RT			;ABORT
			CPD	#FEXCPT_TC_ABORTQ		;check for ABORT"
			BNE	CF_THROW_5			;print error message	
			;Print ABORTQ message
			LDX	ABORT_QUOTE_MSG 		;string pointer -> X
			BEQ	CF_THROW_4			;no message to be printed
			MOVW	#$0000, ABORT_QUOTE_MSG 	;remove message
			JOBSR	FEXCPT_CHECK_ERRMSG		;validate error message
			BCC	CF_THROW_4			;invalid message
			JOBSR	FEXCPT_TX_STRING		;print message
CF_THROW_4		JOB	CF_ABORT_RT			;ABORT
			;Handle standard errors  (THROW code in D)
CF_THROW_5		MOVW	#CF_ABORT_RT, 2,-SP		;push return address (CF_ABORT_RT)
			JOB	CF_DOT_RTERR_1			;printerror message
	
;Word: .RTERR ( n -- ) Print a runtime error message
;Print the runtime error message associated with the THROW code n.
IF_DOT_RTERR		REGULAR
CF_DOT_RTERR		EQU	*
			;Get THROW code ( n )
			LDD	2,Y+				;THROW code -> D
			;Print left string (THROW code in D)
CF_DOT_RTERR_1		LDX	#FEXCPT_STR_RTERR_LEFT 		;left side message -> X
			JOBSR	FEXCPT_TX_STRING		;print substring
			;Check THROW code (THROW code in D)
			CPD	#FEXCPT_SYSTC_MAX		;check for system THROW code
			BLS	CF_DOT_RTERR_4			;user THROW code
			;System THROW code (THROW code in D)
			LDX	#FEXCPT_MSGTAB 			;MESSAGE TABLE -> X
CF_DOT_RTERR_2		TST	1,X				;check for end of table
			BNE	CF_DOT_RTERR_3			;not yet
			TST	0,X				;check for end of table
			BEQ	CF_DOT_RTERR_6			;no matching entry found
CF_DOT_RTERR_3		CPD	2,X+				;check if entry matches THROW code
			BEQ	CF_DOT_RTERR_5			;matching entry found
			BRCLR	1,X+,#FEXCPT_TERM,*		;skip to next table entry
			JOB	CF_DOT_RTERR_2			;check next table entry
			;User defined THROW code (THROW code in D)
CF_DOT_RTERR_4		TFR	D, X 				;error message -> X
CF_DOT_RTERR_5		JOBSR	FEXCPT_CHECK_ERRMSG		;validate error message
			BCC	CF_DOT_RTERR_6			;print throw code
			JOB	FEXCPT_TX_STRING		;print error message
			;Print THROW code  (THROW code in D)
CF_DOT_RTERR_6		EQU	FEXCPT_TX_TC			;print THROW code

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

;Error messages 
FEXCPT_STR_RTERR_LEFT	DB	FEXCPT_SYM_BEEP
			STRING_NL_NONTERM
			FCS	"!!! Runtime Error: "
FEXCPT_STR_RTERR_RIGHT	STRING_NL_TERM
;
;Message table for standard errors
FEXCPT_MSGTAB		EQU	*
			FEXCPT_MSG	FEXCPT_TC_PSOF,		"Parameter stack overflow"
			FEXCPT_MSG	FEXCPT_TC_PSUF,		"Parameter stack underflow" 
			FEXCPT_MSG	FEXCPT_TC_RSOF,		"Return stack overflow"
			FEXCPT_MSG	FEXCPT_TC_RSUF,		"Return stack underflow"
			;FEXCPT_MSG	FEXCPT_TC_DOOF,		"DO-loop nested too deeply"	
			;FEXCPT_MSG	FEXCPT_TC_DICTOF,	"Dictionary overflow"
			;FEXCPT_MSG	FEXCPT_TC_INVALID,	"Invalid memory address"
			;FEXCPT_MSG	FEXCPT_TC_0DIV,		"Division by zero"
			;FEXCPT_MSG	FEXCPT_TC_RESOR,	"Result out of range"
			;FEXCPT_MSG	FEXCPT_TC_UDEFWORD,	"Undefined word"
			FEXCPT_MSG	FEXCPT_TC_COMPONLY,	"Compile-only word"
			;FEXCPT_MSG	FEXCPT_TC_NONAME,	"Missing name argument"
			FEXCPT_MSG	FEXCPT_TC_PADOF,	"PAD overflow"
			;FEXCPT_MSG	FEXCPT_TC_STROF,	"String too long"
			;FEXCPT_MSG	FEXCPT_TC_CTRLSTRUC,	"Control structure mismatch"
			;FEXCPT_MSG	FFEXCPT_TC_INVALNUM,	"Invalid numeric argument"
			;FEXCPT_MSG	FEXCPT_TC_COMPNEST,	"Nested compilation"
			;FEXCPT_MSG	FEXCPT_TC_NONCREATE,	"Illegal operation on non-CREATEd definition"
			;FEXCPT_MSG	FEXCPT_TC_INVALNAME,	"Invalid name argument"
			FEXCPT_MSG	FEXCPT_TC_INVALBASE,	"Invalid BASE"
			;FEXCPT_MSG	FEXCPT_TC_EXCPTERR,	"Corrupt exception stack frame"
			;FEXCPT_MSG	FEXCPT_TC_NOMSG,	"Empty message string"
			;FEXCPT_MSG	FEXCPT_TC_DICTPROT,	"Destruction of dictionary structure"
			;FEXCPT_MSG	FEXCPT_TC_COMERR,	"Corrupted RX data"
			DW		0 			;end of table

FEXCPT_TABS_END		EQU	*
FEXCPT_TABS_END_LIN	EQU	@

#endif
	
	
