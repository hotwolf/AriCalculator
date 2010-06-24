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
;#    The S12CBase framework uses two stacks in its assembly code:             #
;#      1. An interrupt stack, which is implemented in this module             #
;#      2. An subroutine stack, which is implemented in the SSTACK module      #
;#                                                                             #
;#    The interrupt stack is solely intended to store interrupt stack frames.  #
;#    It must not be used for subrutine calls storing temporary data. The      #
;#    interrupt stack is implemented using the S12s stack pointer register SP. #
;#                                                                             #
;#    The S12CBase framework doesn't allow nested interrupts. This has the     #
;#    effect that the SP register will hold only three values:                 #
;#      1. one, for running in the idle loop                                   #
;#      2. one, for executing the main program, or an interrupt service        #
;#         routine that was initiated wlile running in the idle loop           #
;#      3. one, for executing an ISR that interrupted the main program         #
;#    The SP can be used to determine the applications state for debug         #
;#    purposes.                                                                #
;#                                                                             #
;#    The value of the SP rerister is checked whenever an ISR is ended with    #
;#    macro call "ISTACK_RTI". Upon detection of a broken interrupt stack will #
;#    a fatal error will be reported to the ERROR module.                      #
;#                                                                             #
;#    The idle loop does not touch any of the CPU12 registers. This allows     #
;#    that parts of the idle stack frame (field for A, B, X, and Y) can be     #
;#    used as general purpose storage. By convention, the ownership of this    #
;#    storage space goes to the code in main program, which switches over to   #
;#    idle loop.                                                               #
;###############################################################################
;# Version History:                                                            #
;#    April 4, 2010                                                            #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    ERROR - Error Handler                                                    #
;;#                                                                            #
;# Requirements to Software Using this Module:                                 #
;#    - The state of the X- and the I-bit in the Condition Code Register must  #
;#      be modified.                                                           #
;#    - The content of the stack pounter must not be modified.                 #
;#    - All interrupt service routines must end with the macro call            #
;#      "ISTACK_RTI".                                                          #
;###############################################################################
;# Global Defines:                                                             #
;#    DEBUG - Prevents idle loop from entering WAIT mode.                      #
;###############################################################################

;###############################################################################
;# Stack Layout                                                                #
;###############################################################################
;                       ---+--------------+
;  ISTACK_SP_ISR ->      ^ |      CCR     | -> Stack pointer value in ISR
;                       P| +--------------+
;                       R| |       B      |
;                       O| +--------------+
;                       G| |       A      |
;                       R| +--------------+
;                       A| |              |
;                       M| |       X      |
;                        | |              |
;                       C| +--------------+
;                       O| |              |
;                       N| |       Y      |
;                       T| |              |
;                       E| +--------------+
;                       X| |    Return    |
;                       T| |    Address   |
;                        v |              |
;  ISTACK_IDLE_CCR,     ---+--------------+
;  ISTACK_SP_RUN ->      ^ |   Idle CCR   |  -> Stack pointer value during
;                        | +--------------+     program or ISR execution 
;                      I | |              | 
;                      D | |              |
;                      L | |              |
;                      E | +              +
;                        | | 6 bytes for  | 
;                      C | |  temporary   |
;                      O | |   storage    |
;                      N | +              +
;                      T | |              | 
;                      E | |              |
;                      X | |              |
;                      T | +--------------+
;  ISTACK_IDLE_RETADR -> | |    Return    |
;                        | |  Address to  |
;                        v |   Idle Loop  |
;  ISTACK_SP_IDLE,      ---+--------------+
;  ISTACK_VAR_END ->                         -> Stack pointer when idle 
;

;###############################################################################
;# Constants                                                                   #
;###############################################################################
ISTACK_CCR		EQU	%0100_0000
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
			ORG	ISTACK_VARS_START
	
ISTACK_SP_ISR		EQU	*
			DS	9
ISTACK_IDLE_CCR		EQU	*
ISTACK_SP_RUN		DS	1
ISTACK_TMP0		DS	1
ISTACK_TMP1		DS	1
ISTACK_TMP2		DS	1
ISTACK_TMP3		DS	1
ISTACK_TMP4		DS	1
ISTACK_TMP5		DS	1
ISTACK_IDLE_RETADR	DS	2
ISTACK_SP_IDLE		EQU	*

ISTACK_VARS_END		EQU	*

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	ISTACK_INIT, 0
			;Prepare stack for RUN level
			MOVW	#ISTACK_IDLELOOP, ISTACK_IDLE_RETADR 
			MOVB	#ISTACK_CCR, ISTACK_IDLE_CCR	
			LDS	#ISTACK_SP_RUN	

			;Enable interrupts
			CLI
#emac	

;#Return from interrupt
#macro	ISTACK_RTI, 0
			;Verify SP at the end of each ISR
			CPS	#ISTACK_SP_ISR
			BNE	ISTACK_RTI_1
	                RTI
ISTACK_RTI_1		CPS	#ISTACK_SP_RUN
			;BNE	ISTACK_INVALSP
			;RTI

			BNE	ISTACK_RTI_2
			RTI
ISTACK_RTI_2		BGND

#emac	

;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG	ISTACK_CODE_START
;#Idle Loop	
ISTACK_IDLELOOP		EQU	*
#ifdef	DEBUG
			COP_SERVICE
#else
			WAI
#endif
			JOB	ISTACK_IDLELOOP

;#Invalid Stack Pointer Handler
ISTACK_INVALSP		EQU	*
			;Check for stack overflow
			CPS	#ISTACK_SP_ISR
			BHS	ISTACK_INVALSP_1
			ERROR_RESTART	ISTACK_MSG_OF	
	
			;Check for stack underflow
ISTACK_INVALSP_1	CPS		#ISTACK_SP_RUN
			BLS		ISTACK_INVALSP_2
			ERROR_RESTART	ISTACK_MSG_UF

			;SP must have been manually altered
ISTACK_INVALSP_2	ERROR_RESTART	ISTACK_MSG_CORPT
	
ISTACK_CODE_END		EQU	*
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG	ISTACK_TABS_START
;#Error Messages
ISTACK_MSG_OF		ERROR_MSG	ERROR_LEVEL_FATAL, "Interrupt stack overflow"
ISTACK_MSG_UF		ERROR_MSG	ERROR_LEVEL_FATAL, "Interrupt stack underflow"
ISTACK_MSG_CORPT	ERROR_MSG	ERROR_LEVEL_FATAL, "Interrupt stack pointer corrupt"

ISTACK_TABS_END		EQU	*
