;###############################################################################
;# S12CBase - ISTACK - Interrupt Stack Handler                                 #
;###############################################################################
;#    Copyright 2010 Dirk Heisswolf                                            #
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
;#    the stack. Fatel errors are thrown if the stacking space is exceeded.    #
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
;###############################################################################
;# Required Modules:                                                           #
;#    SSTACK - Subroutine Stack Handler                                        #
;#    ERROR  - Error Handler                                                   #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - The state of the X- and the I-bit in the Condition Code Register must  #
;#      be modified.                                                           #
;###############################################################################
;# Global Defines:                                                             #
;#    DEBUG - Prevents idle loop from entering WAIT mode.                      #
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
;# Constants                                                                   #
;###############################################################################
ISTACK_CCR		EQU	%0100_0000
ISTACK_FRAME_SIZE	EQU	9
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
			ORG	ISTACK_VARS_START
ISTACK_TOP		EQU	*
			DS	9
			DS	SSTACK_DEPTH
ISTACK_BOTTOM		EQU	*
ISTACK_VARS_END		EQU	*

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
#macro	ISTACK_WAIT, 0
			;Verify SP before runnung ISRs
			CPS	#ISTACK_TOP+ISTACK_FRAME_SIZE
			BLO	OF ;ISTACK_OF
			CPS	#ISTACK_BOTTOM
			BHI	UF ;ISTACK_UF
			;Wait for the next interrupt
			;COP_SERVICE			;already taken care of by WAI
			CLI		
			WAI

			JOB	DONE
OF			BGND	
UF			BGND
DONE			EQU	*
#emac
	
;#Return from interrupt
#macro	ISTACK_RTI, 0
			;Verify SP at the end of each ISR
			CPS	#ISTACK_TOP
			BLO	OF
			CPS	#ISTACK_BOTTOM-ISTACK_FRAME_SIZE
			BHI	UF
			;End ISR
			RTI
OF			BGND ;JOB	ISTACK_OF	
UF			BGND ;JOB	ISTACK_UF	
#emac	

;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG	ISTACK_CODE_START

;#Handle stack overflows
ISTACK_OF		EQU	*
			ERROR_RESTART	ISTACK_MSG_OF ;throw a fatal error

;#Handle stack underflows
ISTACK_UF		EQU	*
			ERROR_RESTART	ISTACK_MSG_UF ;throw a fatal error
	
ISTACK_CODE_END		EQU	*
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG	ISTACK_TABS_START
;#Error Messages
ISTACK_MSG_OF		ERROR_MSG	ERROR_LEVEL_FATAL, "System stack overflow"
ISTACK_MSG_UF		ERROR_MSG	ERROR_LEVEL_FATAL, "System stack underflow"

ISTACK_TABS_END		EQU	*
