;###############################################################################
;# FBDM - BDM Pod Firmware:    FEXC - ANS Forth Exception Words                #
;###############################################################################
;#    Copyright 2009 Dirk Heisswolf                                            #
;#    This file is part of the OpenBDM BDM pod firmware.                       #
;#                                                                             #
;#    OpenBDM is free software: you can redistribute it and/or modify          #
;#    it under the terms of the GNU General Public License as published by     #
;#    the Free Software Foundation, either version 3 of the License, or        #
;#    (at your option) any later version.                                      #
;#                                                                             #
;#    OpenBDM is distributed in the hope that it will be useful,               #
;#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #
;#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
;#    GNU General Public License for more details.                             #
;#                                                                             #
;#    You should have received a copy of the GNU General Public License        #
;#    along with OpenBDM.  If not, see <http://www.gnu.org/licenses/>.         #
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
;#    SSTACK  - Subroutine Stack                                               #
;#    ERROR   - Error Handler                                                  #
;#    FMEM    - Forth Stacks and Buffers                                       #
;#    FCORE   - Forth Core Words                                               #
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

;###############################################################################
;# Variables                                                                   #
;###############################################################################
			ORG	FEXC_VARS_START
HANDLER			DS	2 	;pointer tho the most recent exception
					;handler 
FEXC_VARS_END		EQU	*

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FEXC_INIT, 0
			MOVW	#$0000, HANDLER ;reset exception handler
#emac

;#Throw an exception from within an assembler primitive
#macro	FEXC_THROW, 1
			LDD	#\1		;set error code
			JOB	FEXC_THROW	;throw exception
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG	FEXC_CODE_START
	
;#Throw an exception
; args:   D: error code
FEXC_THROW	EQU	*
		;Check STATE variable 
		LDX	STATE	     					;exceptions in compilation state are uncaught
		BNE	FEXC_THROW_3 					;compilation state
	
		;Restore RSP
FEXC_THROW_1	LDX	HANDLER						;check if an exception handler excists
		BEQ	FEXC_THROW_3					;no exception handler
		STX	RSP						;restore RS
	
		;Check if RSP is valid
		RS_CHECK_UF	3, FEXC_THROW_2				;three entries must be on the RS  
		RS_CHECK_OF	0, FEXC_THROW_2				;check for RS overflow

		;Caught exception (RSP in X)
 		;Restore stacks
		MOVW	2,X+, HANDLER					;pull previous HANDLER (RSP -> X)
		MOVW	2,X+, PSP					;pull previous PSP (RSP -> X)		
		MOVW	2,X+, IP					;pull next IP (RSP -> X)		
		PS_CHECK_UFOF 0,FEXC_TRAMP_PSUF,1,FEXC_TRAMP_PSOF	;check PSP (PSP -> Y)
		STD	0,Y						;push error code onto PS
		STX	RSP						;set RSP
		STY	PSP						;set PSP
		NEXT

FEXC_CESF	;Corrupt exception stack frame
FEXC_THROW_2	LDD	#FEXC_MSG_CESF 					;set error message

		;Uncaught exception
FEXC_THROW_3	TFR	D, Y
		ERROR_PRINT						;print error message
		JOB	CF_ABORT 					;execute abort
		
FEXC_CODE_END		EQU	*
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG	FEXC_TABS_START

;#Error Messages
FEXC_MSG_CESF		ERROR_MSG	ERROR_LEVEL_ERROR, "Corrupt exception stack frame"
	
FEXC_TABS_END		EQU	*

;###############################################################################
;# Forth words                                                                 #
;###############################################################################
			ORG	FEXC_WORDS_START

;CATCH ( i*x xt -- j*x 0 | i*x n )
;Push an exception frame on the exception stack and then execute the execution
;token xt (as with EXECUTE) in such a way that control can be transferred to a
;point just after CATCH if THROW is executed during the execution of xt.
;If the execution of xt completes normally (i.e., the exception frame pushed by
;this CATCH is not popped by an execution of THROW) pop the exception frame and
;return zero on top of the data stack, above whatever stack items would have
;been returned by xt EXECUTE. Otherwise, the remainder of the execution
;semantics are given by THROW.
NFA_CATCH		FHEADER, "CATCH", FEXC_PREV_NFA, COMPILE
CFA_CATCH		DW	CF_CATCH			;
CF_CATCH		PS_CHECK_UF	1, FEXC_TRAMP_PSUF 	;check PS requirements (PSP -> Y)
			RS_CHECK_OF	3, FEXC_TRAMP_PSUF	;check RS requirements 
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
	
CF_CATCH_RESTORE	RS_CHECK_UF 3, FEXC_TRAMP_RSUF	 	;RS for underflow (RSP -> X)
			CPX	HANDLER				;check if RSP=HANDLER
			BNE	FEXC_CESF			;corrupt exception stack frame
			MOVW	4,X+, HANDLER 			;RS > HANDLER
			LDY	2,X+				;RS > IP
			STX	RSP
			LDX	2,Y+ 				;NEXT
			STY	IP
			JMP	[0,X]
	
FEXC_TRAMP_PSUF		FMEM_THROW_PSUF			
FEXC_TRAMP_RSOF		FMEM_THROW_RSUF			
FEXC_TRAMP_RSUF		FMEM_ABORT_RSUF		
	
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
NFA_THROW	FHEADER, "THROW", NFA_CATCH, COMPILE
CFA_THROW	DW	CF_THROW
CF_THROW	PS_CHECK_UF	1, FEXC_TRAMP_PSUF	;RS for underflow (RSP -> X)
		LDD	2,X+				;check if TOS is 0
		BEQ	CF_THROW_1			;NEXT
		CPD	#$FFFF				;check if TOS is -1
		BEQ	CF_ABORT			;execute ABORT
		CPD	#$FFFE				;check if TOS is -1
		BEQ	CF_ABORT_QUOTE_RT		;execute the runtime of ABORT"
		JOB	FEXC_THROW_1			
CF_THROW_1	STX	PSP
		NEXT
	
FEXC_WORDS_END		EQU	*
FEXC_LAST_WORD		EQU	NFA_THROW
