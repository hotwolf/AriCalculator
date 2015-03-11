#ifndef ISTACK_COMPILED
#define ISTACK_COMPILED
;###############################################################################
;# S12CBase - ISTACK - Interrupt Stack Handler                                 #
;###############################################################################
;#    Copyright 2010-2012 Dirk Heisswolf                                       #
;#    This file is part of the S12CBase framework for Freescale's S12C MCU     #
;#    family.                                                                  #
;#                                                                             #
;#    S12CBase is free software: you can redistribute it and/or modify         #
;#    it under the terms of the GNU General Public License as published by     #
;#    the Free Software Foundation, either version 3 of the License, or        #
;#    (at your option) any later version.                                      #
;#                                                                             #
;#    S12CBase is distributed in the hope that it will be useful,              #
;#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #
;#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
;#    GNU General Public License for more details.                             #
;#                                                                             #
;#    You should have received a copy of the GNU General Public License        #
;#    along with S12CBase.  If not, see <http://www.gnu.org/licenses/>.        #
;###############################################################################
;# Description:                                                                #
;#    Early versions of S12CBase framework used to have separate stacks        #
;#    interrupt handling and subroutine calls. These two stacks have noe been  #
;#    combined to one. However the API of the separate stacks has been kept:   #
;#    => The ISTACK module implements all functions required for interrupt     #
;#       handling.                                                             #
;#    => The SSTACK module implements all functions for subroutine calls and   #
;#       temporary RAM storage.                                                #
;#                                                                             #
;#    All of the stacking functions check the upper and lower boundaries of    #
;#    the stack. Fatal errors are thrown if the stacking space is exceeded.    #
;#                                                                             #
;#    The ISTACK module no longer implements an idle loop. Instead it offers   #
;#    the macro ISTACK_WAIT to build local idle loops for drivers which        #
;#    implement blocking I/O.                                                  #
;###############################################################################
;# Version History:                                                            #
;#    April 4, 2010                                                            #
;#      - Initial release                                                      #
;#    January 8, 2011                                                          #
;#      - Combined ISTACK and SSTACK                                           #
;#    June 29, 2012                                                            #
;#      - Added support for linear PC                                          #
;#      - Added debug option "ISTACK_DEBUG"                                    #
;#      - Added option to disable stack range checks "ISTACK_NO_CHECK"         #
;#      - Added support for multiple interrupt nesting levels                  #
;#    July 27, 2012                                                            #
;#      - Added macro "ISTACK_CALL_ISR"                                        #
;###############################################################################
;# Required Modules:                                                           #
;#    SSTACK - Subroutine stack handler                                        #
;#    RESET  - Reset handler                                                   #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;###############################################################################
;# Stack Layout                                                                #
;###############################################################################
; ISTACK_VARS_START,   +-------------------+
;        ISTACK_TOP -> |                   |
;                      | ISTACK_FRAME_SIZE |
;                      |                   |
;                      +-------------------+
;        SSTACK_TOP -> |                   |
;                      |                   |
;                      |                   |
;                      |                   |
;                      |    SSTACK_DEPTH   |
;                      |                   |
;                      |                   |
;                      |                   |
;     SSTACK_BOTTOM,   |                   |
;     ISTACK_BOTTOM,   +-------------------+
;   ISTACK_VARS_END ->
;

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Debug option for stack over/underflows
;ISTACK_DEBUG		EQU	1 
;ISTACK_NO_WAI		EQU	1 
	
;Disable stack range checks
;ISTACK_NO_CHECK	EQU	1 

;Interrupt nesting levels
#ifndef	ISTACK_LEVELS
ISTACK_LEVELS		EQU	1	 	;default is 1
#endif

;CPU
#ifndef	ISTACK_S12
#ifndef	ISTACK_S12X
ISTACK_S12		EQU	1 		;default is S12
#endif
#endif
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
ISTACK_CCR		EQU	%0100_0000
#ifdef	ISTACK_S12
ISTACK_FRAME_SIZE	EQU	9
#endif

#ifdef	ISTACK_S12X
ISTACK_FRAME_SIZE	EQU	10
#endif

;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef ISTACK_VARS_START_LIN
			ORG 	ISTACK_VARS_START, ISTACK_VARS_START_LIN
#else
			ORG 	ISTACK_VARS_START
ISTACK_VARS_START_LIN	EQU	@
#endif	

ISTACK_TOP		EQU	*
			DS	ISTACK_FRAME_SIZE*ISTACK_LEVELS
#ifdef	SSTACK_DEPTH
			DS	SSTACK_DEPTH
#endif	
ISTACK_BOTTOM		EQU	*

ISTACK_VARS_END		EQU	*
ISTACK_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	ISTACK_INIT, 0
			;Set stack pointer
			LDS	#ISTACK_BOTTOM	
			;Enable interrupts
			CLI
#emac	

;#Wait until any interrupt has been serviced
; args:   none 
; ISTACK: none
;         X, Y, and D are preserved 
#macro	ISTACK_WAIT, 0
#ifndef	ISTACK_NO_CHECK
			;Verify SP before runnung ISRs
			CPS	#ISTACK_TOP+ISTACK_FRAME_SIZE
			BLO	OF ;ISTACK_OF
			CPS	#ISTACK_BOTTOM
			BHI	UF ;ISTACK_UF
#endif
			;Wait for the next interrupt
			COP_SERVICE			;already taken care of by WAI
			CLI		
#ifndef	ISTACK_DEBUG
#ifndef	ISTACK_NO_WAI
			WAI
#endif
#endif
#ifndef	ISTACK_NO_CHECK
#ifdef	ISTACK_DEBUG
			JOB	DONE
OF			BGND	
UF			BGND
#else
OF			EQU	ISTACK_OF	
UF			EQU	ISTACK_UF
#endif
#endif
DONE			EQU	*
#emac
	
;#Return from interrupt
; args:   none 
; ISTACK: -9 (S12)/-10 (S12X)
;         X, Y, and D are pulled from the interrupt stack
#macro	ISTACK_RTI, 0
#ifndef	ISTACK_NO_CHECK
			;Verify SP at the end of each ISR
			CPS	#ISTACK_TOP
			BLO	OF
			CPS	#ISTACK_BOTTOM-ISTACK_FRAME_SIZE
			BHI	UF
#endif
			;End ISR
			RTI
#ifndef	ISTACK_NO_CHECK
#ifdef	ISTACK_DEBUG
OF			BGND	
UF			BGND
#else
OF			JOB	ISTACK_OF	
UF			JOB	ISTACK_UF
#endif
#endif
#emac	

;#Clear I-flag is there is still room on the stack
; args:   none
; ISTACK: none
;         X, Y and B are preserved
#macro	ISTACK_CHECK_AND_CLI, 0 
			CPS	#ISTACK_BOTTOM-ISTACK_FRAME_SIZE
			BHI	DONE
#ifdef ISTACK_S12X	
			;LDAA	#$00
			LDAA	#$01
			TFR	A, CCRH
#endif
			CLI
DONE			EQU	*
#emac	

;#Call ISR from application code
; args:   none 
; ISTACK:  -9 (S12)/-10 (S12X)
;         X, Y, and D are pudhed onto the interrupt stack
#macro	ISTACK_CALL_ISR, 1
			SEI	
#ifndef	ISTACK_NO_CHECK 
			CPS	#ISTACK_TOP-ISTACK_FRAME_SIZE
			BLO	OF
			CPS	#ISTACK_BOTTOM
			BHS	UF
#ifdef	ISTACK_DEBUG
			JOB	DONE
UF			BGND
OF			BGND
DONE			EQU	*	
#else
UF			EQU	ISTACK_UF
OF			EQU	ISTACK_OF
#endif
#endif
			MOVW	#DONE, 2,-SP
			PSHY
			PSHX
			PSHD
#ifdef	ISTACK_S12	
			PSHC
#endif
#ifdef	ISTACK_S12X	
			EXG	CCRW, D
			PSHD
			EXG	CCRW, D
#endif
			JOB	\1
DONE			EQU	*
#emac	
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef ISTACK_CODE_START_LIN
			ORG 	ISTACK_CODE_START, ISTACK_CODE_START_LIN
#else
			ORG 	ISTACK_CODE_START
ISTACK_CODE_START_LIN	EQU	@
#endif
	
;#Handle stack overflows
#ifndef	ISTACK_NO_CHECK
#ifndef	ISTACK_DEBUG
ISTACK_OF		EQU	*
			RESET_FATAL	ISTACK_MSG_OF ;throw a fatal error
#endif
#endif

;#Handle stack underflows
#ifndef	ISTACK_NO_CHECK
#ifndef	ISTACK_DEBUG
ISTACK_UF		EQU	*
			RESET_FATAL	ISTACK_MSG_UF ;throw a fatal error
#endif
#endif
	
ISTACK_CODE_END		EQU	*
ISTACK_CODE_END_LIN	EQU	@
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef ISTACK_TABS_START_LIN
			ORG 	ISTACK_TABS_START, ISTACK_TABS_START_LIN
#else
			ORG 	ISTACK_TABS_START
ISTACK_TABS_START_LIN	EQU	@
#endif	

;#Error Messages
#ifndef	ISTACK_NO_CHECK 
#ifndef	ISTACK_DEBUG
ISTACK_MSG_OF		FCS	"Interrupt stack overflow"
ISTACK_MSG_UF		FCS	"Interrupt stack underflow"
#endif
#endif
	
ISTACK_TABS_END		EQU	*
ISTACK_TABS_END_LIN	EQU	@
#endif
