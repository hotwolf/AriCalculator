;###############################################################################
;# S12CForth - FEXCPT - Forth Exception Words                                  #
;###############################################################################
;#    Copyright 2010 Dirk Heisswolf                                            #
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
;#    This is a modification of David Armstrong's S12X FIG Forth               #
;#    implementation (see http://mamoru.tbreesama.googlepages.com/).           #
;#                                                                             #
;#    Forth virtual machine registers are defined as follows:                  #
;#       W   = Working register. 					       #
;#             The W register points to the data field of the current word,    #
;#             but it may be overwritten.				       #
;#             Used for indexed addressing and arithmetics.		       #
;#	       Index Register X is used to implement W.                        #
;#       IP  = Instruction pointer.					       #
;#             Points to the next execution token.			       #
;#       PSP = Parameter Stack Pointer.					       #
;#	       Points one cell beyond the top of the parameter stack           #
;#       RSP = Return stack pointer.					       #
;#	       Points one cell beyond the top of the return stack.             #
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
;                   RSP->                	
;                         +----------------------+
;                         |                      |
;                         |                      |
;                         |                      | 
;                         +----------------------+
;               HANDLER-> |   previous HANDLER   |
;                         +----------------------+
;                         |     PSP at CATCH     |
;                         +----------------------+
;                         | IP after CATCH call  |
;                         +----------------------+

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
;FEXCPT_EC_7			EQU	-7 	;do-loops nested too deeply during execution
FEXCPT_EC_DICTOF		EQU	-8 	;dictionary overflow
FEXCPT_EC_INVALADR		EQU	-9 	;invalid memory address
FEXCPT_EC_0DIV			EQU	-10	;division by zero
FEXCPT_EC_RESOR			EQU	-11	;result out of range
;FEXCPT_EC_12			EQU	-12	;argument type mismatch
FEXCPT_EC_UDEFWORD		EQU	-13	;undefined word
FEXCPT_EC_COMPONLY		EQU	-14	;interpreting a compile-only word
;FEXCPT_EC_15			EQU	-15	;invalid FORGET
;FEXCPT_EC_16			EQU	-16	;attempt to use zero-length string as a name
FEXCPT_EC_PADOF			EQU	-17	;pictured numeric output string overflow
FEXCPT_EC_TIBOF			EQU	-18	;parsed string overflow
;FEXCPT_EC_19			EQU	-19	;definition name too long
;FEXCPT_EC_20			EQU	-20	;write to a read-only location
;FEXCPT_EC_21			EQU	-21	;unsupported operation (e.g., AT-XY on a too-dumb terminal)
;FEXCPT_EC_22			EQU	-22	;control structure mismatch
;FEXCPT_EC_23			EQU	-23	;address alignment exception
;FEXCPT_EC_24			EQU	-24	;invalid numeric argument
;FEXCPT_EC_25			EQU	-25	;return stack imbalance
;FEXCPT_EC_26			EQU	-26	;loop parameters unavailable
;FEXCPT_EC_27			EQU	-27	;invalid recursion
;FEXCPT_EC_28			EQU	-28	;user interrupt
FEXCPT_EC_COMPNEST		EQU	-29	;compiler nesting
;FEXCPT_EC_30			EQU	-30	;obsolescent feature
;FEXCPT_EC_31			EQU	-31	;>BODY used on non-CREATEd definition
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
	
;Additional error codes 
;FEXCPT_EC_CESF			EQU	FEXCPT_MSG_CESF
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
			ORG	FEXCPT_VARS_START
HANDLER			DS	2 	;pointer tho the most recent exception
					;handler 
FEXCPT_VARS_END		EQU	*

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FEXCPT_INIT, 0
			MOVW	#$0000, HANDLER ;reset exception handler
#emac

;#Throw an exception from within an assembler primitive
#macro	FEXCPT_THROW, 1
			LDD	#\1		;set error code
			JOB	FEXCPT_THROW	;throw exception
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG	FEXCPT_CODE_START
;Exceptions
FEXCPT_THROW_PSOF	EQU	FMEM_THROW_PSOF		;"Parameter stack overflow"
FEXCPT_THROW_PSUF	EQU	FMEM_THROW_PSUF		;"Parameter stack underflow"
FEXCPT_THROW_RSOF	EQU	FMEM_THROW_RSOF		;"Parameter stack overflow"
FEXCPT_THROW_RSUF	EQU	FMEM_THROW_RSUF 	;"Return stack underflow"
FEXCPT_THROW_CESF	FEXCPT_THROW	 FEXCPT_EC_CESF	;"Corrupt exception stack frame"
				
;#Throw an exception
; args:   D: error code
FEXCPT_THROW	EQU	*
		;Check STATE variable 
		LDX	STATE	     					;exceptions in compilation state are uncaught
		BNE	FEXCPT_THROW_2 					;compilation state	
		;Restore RSP
FEXCPT_THROW_1	LDX	HANDLER						;check if an exception handler excists
		BEQ	FEXCPT_THROW_2					;no exception handler
		STX	RSP						;restore RS	
		;Check if RSP is valid
		RS_CHECK_UF	3, FEXCPT_THROW_CESF			;three entries must be on the RS  
		RS_CHECK_OF	0, FEXCPT_THROW_CESF			;check for RS overflow
		;Caught exception (RSP in X)
 		;Restore stacks
		MOVW	2,X+, HANDLER					;pull previous HANDLER (RSP -> X)
		MOVW	2,X+, PSP					;pull previous PSP (RSP -> X)		
		MOVW	2,X+, IP					;pull next IP (RSP -> X)		
		;Check if PSP is valid
		PS_CHECK_UFOF 0,FEXCPT_THROW_CESF,1,FEXCPT_THROW_CESF	;check PSP (PSP -> Y)
		STD	0,Y						;push error code onto PS
		STX	RSP						;set RSP
		STY	PSP						;set PSP
		NEXT
		;Uncaught exception (error code in D)
FEXCPT_THROW_2	CPD	#FEXCPT_EC_ABORT 				;check if an ABORT has been requested
		BEQ	CF_ABORT
		CPD	#FEXCPT_EC_ABORTQ 				;check if an ABORT" has been requested
		BEQ	CF_ABORT_QUOTE_RT
		CPD	#FEXCPT_EC_QUIT 				;check if a QUIT has been requested
		BEQ	CF_QUIT
		CPD	#-((FEXCPT_MSGTAB_END-FEXCPT_MSGTAB_START)/2) 	;check for standard error code
		BLO	FEXCPT_THROW_3					;custom error message
		LDX     FEXCPT_MSGTAB_END 				;look-up standard error message
		LSLD
		LDD	D,X
FEXCPT_THROW_3	TFR	D, Y
FEXCPT_THROW_4	ERROR_PRINT						;print error message
		JOB	CF_ABORT 					;execute abort
		
;#Handle a corrupt exception stack frame
; args:   none
FEXCPT_CESF	EQU	*
		LDY	#FEXCPT_MSG_CESF				;set error message
		JOB	FEXCPT_THROW_4
	
FEXCPT_CODE_END		EQU	*
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG	FEXCPT_TABS_START
	
				;Assign error messages to error codes 
FEXCPT_MSGTAB_START	EQU	*
			;DW	FEXCPT_MSG_UNKNOWN	;-58 [IF], [ELSE], or [THEN] exception
			;DW	FEXCPT_MSG_UNKNOWN	;-57 exception in sending or receiving a character
			;DW	FEXCPT_MSG_UNKNOWN	;-56 QUIT
			;DW	FEXCPT_MSG_UNKNOWN	;-55 floating-point unidentified fault
			;DW	FEXCPT_MSG_UNKNOWN	;-54 floating-point underflow
			;DW	FEXCPT_MSG_UNKNOWN	;-53 exception stack overflow
			DW	FEXCPT_MSG_CESF		;-52 control-flow stack overflow
			DW	FEXCPT_MSG_UNKNOWN	;-51 compilation word list changed
			DW	FEXCPT_MSG_UNKNOWN	;-50 search-order underflow
			DW	FEXCPT_MSG_UNKNOWN	;-49 search-order overflow
			DW	FEXCPT_MSG_UNKNOWN	;-48 invalid POSTPONE
			DW	FEXCPT_MSG_UNKNOWN	;-47 compilation word list deleted
			DW	FEXCPT_MSG_UNKNOWN	;-46 floating-point invalid argument
			DW	FEXCPT_MSG_UNKNOWN	;-45 floating-point stack underflow
			DW	FEXCPT_MSG_UNKNOWN	;-44 floating-point stack overflow
			DW	FEXCPT_MSG_UNKNOWN	;-43 floating-point result out of range
			DW	FEXCPT_MSG_UNKNOWN	;-42 floating-point divide by zero
			DW	FEXCPT_MSG_UNKNOWN	;-41 loss of precision
			DW	FEXCPT_MSG_INVALBASE	;-40 invalid BASE for floating point conversion
			DW	FEXCPT_MSG_UNKNOWN	;-39 unexpected end of file
			DW	FEXCPT_MSG_UNKNOWN	;-38 non-existent file
			DW	FEXCPT_MSG_UNKNOWN	;-37 file I/O exception
			DW	FEXCPT_MSG_UNKNOWN	;-36 invalid file position
			DW	FEXCPT_MSG_UNKNOWN	;-35 invalid block number
			DW	FEXCPT_MSG_UNKNOWN	;-34 block write exception
			DW	FEXCPT_MSG_UNKNOWN	;-33 block read exception
			DW	FEXCPT_MSG_UNKNOWN	;-32 invalid name argument (e.g., TO xxx)
			DW	FEXCPT_MSG_UNKNOWN	;-31 >BODY used on non-CREATEd definition
			DW	FEXCPT_MSG_UNKNOWN	;-30 obsolescent feature
			DW	FEXCPT_MSG_COMPNEST	;-29 compiler nesting
			DW	FEXCPT_MSG_UNKNOWN	;-28 user interrupt
			DW	FEXCPT_MSG_UNKNOWN	;-27 invalid recursion
			DW	FEXCPT_MSG_UNKNOWN	;-26 loop parameters unavailable
			DW	FEXCPT_MSG_UNKNOWN	;-25 return stack imbalance
			DW	FEXCPT_MSG_UNKNOWN	;-24 invalid numeric argument
			DW	FEXCPT_MSG_UNKNOWN	;-23 address alignment exception
			DW	FEXCPT_MSG_UNKNOWN	;-22 control structure mismatch
			DW	FEXCPT_MSG_UNKNOWN	;-21 unsupported operation (e.g., AT-XY on a too-dumb terminal)
			DW	FEXCPT_MSG_UNKNOWN	;-20 write to a read-only location
			DW	FEXCPT_MSG_UNKNOWN	;-19 definition name too long
			DW	FEXCPT_MSG_TIBOF	;-18 parsed string overflow
			DW	FEXCPT_MSG_PADOF	;-17 pictured numeric output string overflow
			DW	FEXCPT_MSG_UNKNOWN	;-16 attempt to use zero-length string as a name
			DW	FEXCPT_MSG_UNKNOWN	;-15 invalid FORGET
			DW	FEXCPT_MSG_COMPONLY	;-14 interpreting a compile-only word
			DW	FEXCPT_MSG_UDEFWORD	;-13 undefined word
			DW	FEXCPT_MSG_UNKNOWN	;-12 argument type mismatch
			DW	FEXCPT_MSG_RESOR	;-11 result out of range
			DW	FEXCPT_MSG_0DIV		;-10 division by zero
			DW	FEXCPT_MSG_UNKNOWN	;-9  invalid memory address
			DW	FEXCPT_MSG_DICTOF	;-8  dictionary overflow
			DW	FEXCPT_MSG_UNKNOWN	;-7  do-loops nested too deeply during execution
			DW	FEXCPT_MSG_RSUF		;-6  return stack underflow
			DW	FEXCPT_MSG_RSOF		;-5  return stack overflow
			DW	FEXCPT_MSG_PSUF		;-4  stack underflow
			DW	FEXCPT_MSG_PSOF		;-3  stack overflow
			DW	FEXCPT_MSG_UNKNOWN	;-2  ABORT"
			DW	FEXCPT_MSG_UNKNOWN	;-1  ABORT
FEXCPT_MSGTAB_END	EQU	*
			
;Standard error messages 
FEXCPT_MSG_UNKNOWN	ERROR_MSG	ERROR_LEVEL_ERROR, "Unknown problem"
FEXCPT_MSG_PSOF		ERROR_MSG	ERROR_LEVEL_ERROR, "Parameter stack overflow"
FEXCPT_MSG_PSUF		ERROR_MSG	ERROR_LEVEL_ERROR, "Parameter stack underflow" 
FEXCPT_MSG_RSOF		ERROR_MSG	ERROR_LEVEL_ERROR, "Return stack overflow"
FEXCPT_MSG_RSUF		ERROR_MSG	ERROR_LEVEL_ERROR, "Return stack underflow"
FEXCPT_MSG_DICTOF	ERROR_MSG	ERROR_LEVEL_ERROR, "Dictionary overflow"
;FEXCPT_MSG_INVALADR	ERROR_MSG	ERROR_LEVEL_ERROR, "Invalid memory address"
FEXCPT_MSG_0DIV		ERROR_MSG	ERROR_LEVEL_ERROR, "Division by zero"
FEXCPT_MSG_RESOR	ERROR_MSG	ERROR_LEVEL_ERROR, "Result out of range"
FEXCPT_MSG_UDEFWORD	ERROR_MSG	ERROR_LEVEL_ERROR, "Undefined word"
FEXCPT_MSG_COMPONLY	ERROR_MSG	ERROR_LEVEL_ERROR, "Compile-only word"
FEXCPT_MSG_TIBOF	ERROR_MSG	ERROR_LEVEL_ERROR, "TIB overflow"
FEXCPT_MSG_PADOF	ERROR_MSG	ERROR_LEVEL_ERROR, "PAD overflow"
FEXCPT_MSG_COMPNEST	ERROR_MSG	ERROR_LEVEL_ERROR, "Nested compilation"
FEXCPT_MSG_INVALBASE	ERROR_MSG	ERROR_LEVEL_ERROR, "Invalid BASE"
FEXCPT_MSG_CESF		ERROR_MSG	ERROR_LEVEL_ERROR, "Corrupt exception stack frame"

;Additional error messages 
;FEXCPT_MSG_CESF		ERROR_MSG	ERROR_LEVEL_ERROR, "Corrupt exception stack frame"

FEXCPT_TABS_END		EQU	*

;###############################################################################
;# Forth words                                                                 #
;###############################################################################
			ORG	FEXCPT_WORDS_START

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
;
			ALIGN	1
NFA_CATCH		FHEADER, "CATCH", FEXCPT_PREV_NFA, COMPILE
CFA_CATCH		DW	CF_CATCH			;
CF_CATCH		PS_CHECK_UF	1, CF_CATCH_PSUF 	;check PS requirements (PSP -> Y)
			RS_CHECK_OF	3, CF_CATCH_RSOF	;check RS requirements 
			LDX	RSP				;RSP -> X
			MOVW	IP,	 2,-X			;IP      > RS
			STY		 2,-X			;PSP     > RS
			MOVW	HANDLER, 2,-X			;HANDLER > RS			
			STX	RSP
			STX	HANDLER		      		;RSP -> HANDLER
			MOVW	#CF_CATCH_RESTORE, IP 		;set next IP	
			LDX	2,Y+ 				;execute xt
			STY	PSP
			JMP	[0,X]
	
CF_CATCH_RESTORE	RS_CHECK_UF 3, CF_CATCH_CESF	 	;RS for underflow (RSP -> X)
			CPX	HANDLER				;check if RSP=HANDLER
			BNE	CF_CATCH_CESF			;corrupt exception stack frame
			;Switch to previous handler 
			MOVW	4,X+, HANDLER 			;RS > HANDLER
			LDY	2,X+				;RS > IP
			STX	RSP
			;Push 0x0 onto the PS	
			PS_CHECK_OF	1, CF_CATCH_PSOF	;check for PS overflow (PSP-new cells -> Y)
			MOVW	#$0000, 0,Y			;push 0 onto PS 
			STY	PSP
			;Switch over to next instruction	
			LDX	2,Y+ 				;NEXT
			STY	IP
			JMP	[0,X]
	
CF_CATCH_PSUF		JOB	FEXCPT_THROW_PSUF			
CF_CATCH_PSOF		JOB	FEXCPT_THROW_PSOF			
CF_CATCH_RSOF		JOB	FEXCPT_THROW_RSOF			
CF_CATCH_CESF		JOB	FEXCPT_CESF			;corrupt exception stack frame 
	
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
;
			ALIGN	1
NFA_THROW		FHEADER, "THROW", NFA_CATCH, COMPILE
CFA_THROW		DW	CF_THROW
CF_THROW		PS_CHECK_UF	1, CF_THROW_PSUF	;PS for underflow (RSP -> Y)
			LDD	2,Y+				;check if TOS is 0
			BEQ	CF_THROW_1			;NEXT
			STX	PSP
			JOB	FEXCPT_THROW
CF_THROW_1		STX	PSP
			NEXT

CF_THROW_PSUF		JOB	FEXCPT_THROW_PSUF			
	
	
FEXCPT_WORDS_END	EQU	*
FEXCPT_LAST_NFA		EQU	NFA_THROW
