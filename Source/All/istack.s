#ifndef ISTACK_COMPILED
#define ISTACK_COMPILED
;###############################################################################
;# S12CBase - ISTACK - Interrupt Stack Handler                                 #
;###############################################################################
;#    Copyright 2010-2016 Dirk Heisswolf                                       #
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
;#    January 16, 2016                                                         #
;#      - New generic implementation                                           #
;###############################################################################
;# Required Modules:                                                           #
;#    - none                                                                   #
;#                                                                             #
;###############################################################################
;###############################################################################
;# Stack Layout                                                                #
;###############################################################################
;                      +-------------------+
;        ISTACK_TOP -> |                   |
;                      |                   |
;                      |      ISTACK       |     
;                      |                   |
;                      |                   |
;                      +-------------------+
;     ISTACK_BOTTOM ->
;

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;CPU
#ifndef	ISTACK_S12
#ifndef	ISTACK_S12X
ISTACK_S12		EQU	1 		;default is S12
#endif
#endif

;Wait mode when idle
#ifndef	ISTACK_WAI
#ifndef	ISTACK_NO_WAI
ISTACK_WAI		EQU	1 		;default is no WAI
#endif
#endif

;Stack allocation
#ifndef	ISTACK_SIZE
ISTACK_SIZE		EQU	ISTACK_FRAME_SIZE;default is one stack frame
#endif
;...or...
;ISTACK_TOP		EQU	...		;top of stack
;ISTACK_BOTTOM		EQU	...		;bottom of stack

;Enable stack range checks
#ifndef	ISTACK_CHECK_ON
#ifndef	ISTACK_CHECK_OFF
ISTACK_CHECK_OFF	EQU	1 		;default is S12
#endif
#endif

;Range checks
;#mac ISTACK_PREPUSH, 0
;	...code to start signaling active baud rate detection (inside ISR)
;#emac
;#mac ISTACK_PREPULL, 0
;	...code to stop signaling active baud rate detection (inside ISR)
;#emac
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
ISTACK_CCR		EQU	%0100_0000
	
;S12 stack layout:
;        +----------------+ 
;        |      CCR       | SP+0
;        +----------------+ 
;        |       B        | SP+1 
;        +----------------+ 
;        |       A        | SP+2
;        +----------------+ 
;        |       Xh       | SP+3 
;        +----------------+ 
;        |       Xl       | SP+4 
;        +----------------+ 
;        |       Yh       | SP+5 
;        +----------------+ 
;        |       Yl       | SP+6 
;        +----------------+ 
;        |      RTNh      | SP+7 
;        +----------------+ 
;        |      RTNl      | SP+8 
;        +----------------+ 	
#ifdef	ISTACK_S12
ISTACK_FRAME_SIZE	EQU	9
ISTACK_FRAME_CCR	EQU	0	
ISTACK_FRAME_D		EQU	1	
ISTACK_FRAME_X		EQU	3	
ISTACK_FRAME_Y		EQU	5	
ISTACK_FRAME_RTN	EQU	7	
#endif

;S12X stack layout:
;        +----------------+ 
;        |      CCRh      | SP+0
;        +----------------+ 
;        |      CCRl      | SP+1
;        +----------------+ 
;        |       B        | SP+2 
;        +----------------+ 
;        |       A        | SP+3
;        +----------------+ 
;        |       Xh       | SP+4 
;        +----------------+ 
;        |       Xl       | SP+5 
;        +----------------+ 
;        |       Yh       | SP+6 
;        +----------------+ 
;        |       Yl       | SP+7 
;        +----------------+ 
;        |      RTNh      | SP+8 
;        +----------------+ 
;        |      RTNl      | SP+9 
;        +----------------+ 	
#ifdef	ISTACK_S12X
ISTACK_FRAME_SIZE	EQU	10
ISTACK_FRAME_CCR	EQU	0	
ISTACK_FRAME_D		EQU	2	
ISTACK_FRAME_X		EQU	4	
ISTACK_FRAME_Y		EQU	6	
ISTACK_FRAME_RTN	EQU	8	
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

#ifndef	ISTACK_TOP
#ifndef	ISTACK_BOTTOM
;Default allocation 
ISTACK_TOP		DS	ISTACK_SIZE
ISTACK_BOTTOM		EQU	*
#endif	
#endif	

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

#ifnmac	ISTACK_PREPUSH
;#Check stack before push operation	
; args:   1: required stack capacity (bytes)
; result: none 
; SSTACK: none
;         X, Y, and D are preserved
#macro	ISTACK_PREPUSH, 1 //number of bytes to push
#emac
#endif

#ifnmac	ISTACK_PREPULL
;#Check stack before pull operation	
; args:   1: expecteded stack content (bytes)
; result: none 
; SSTACK: none
;         X, Y, and D are preserved 
#macro	ISTACK_PREPULL, 1 //number of bytes to pull
#emac
#endif
	
;#Wait until any interrupt has been serviced
; args:   none 
; ISTACK: none
;         X, Y, and D are preserved 
#macro	ISTACK_WAIT, 0
#ifdef	ISTACK_CHECK_ON
			ISTACK_PREPUSH	ISTACK_FRAME_SIZE
#endif
			;Wait for the next interrupt
			COP_SERVICE			;already taken care of by WAI
			CLI		
#ifdef	ISTACK_WAI
			WAI
#endif
#emac
	
;#Return from interrupt
; args:   none 
; ISTACK: -9 (S12)/-10 (S12X)
;         X, Y, and D are pulled from the interrupt stack
#macro	ISTACK_RTI, 0
#ifdef	ISTACK_CHECK_ON
			ISTACK_PREPULL	ISTACK_FRAME_SIZE
#endif
			;End ISR
			RTI
#emac	

;#Replace return address in stack frame
; args:   1: new return address (any address mode)
; ISTACK: none
;         X, Y, and D are preserved 
#macro	ISTACK_PRPLACE_RTN, 1
			MOVW	\1, ISTACK_RTN,SP
#emac	

;#Insert return address into stack frame
; args:   1: new return address (any address mode)
; ISTACK: none
;         X, Y, and D are preserved 
#macro	ISTACK_PRPLACE_RTN, 1
#ifdef	ISTACK_S12
			MOVB	ISTACK_FRAME_CCR,SP, 2,-SP
#else			
			MOVW	ISTACK_FRAME_CCR,SP, 2,-SP
#endif
			MOVW	(2+ISTACK_FRAME_D),SP, ISTACK_FRAME_D,SP
			MOVW	(2+ISTACK_FRAME_X),SP, ISTACK_FRAME_X,SP
			MOVW	(2+ISTACK_FRAME_Y),SP, ISTACK_FRAME_Y,SP
			MOVW	\1,                    ISTACK_FRAME_RTN,SP
	
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
	
ISTACK_TABS_END		EQU	*
ISTACK_TABS_END_LIN	EQU	@
#endif
