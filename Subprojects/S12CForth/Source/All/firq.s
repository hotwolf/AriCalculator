#ifndef FIRQ
#define FIRQ
;###############################################################################
;# S12CForth - FIRQ - Interrupt Request Handler                                #
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
;#    This module propagates interrupt requests to the inner interpreter.      #
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    Februuary 17, 2015                                                       #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    BASE   - S12CBase framework                                              #
;#    FRS    - Forth return stack                                              #
;#    FIRQ   - Forth interrupt request handler                                 #
;#                                                                             #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
						    
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FIRQ_VARS_START_LIN
			ORG 	FIRQ_VARS_START, FIRQ_VARS_START_LIN
#else
			ORG 	FIRQ_VARS_START
FIRQ_VARS_START_LIN	EQU	@
#endif	
			ALIGN	1	
FIRQ_VARS_END		EQU	*
FIRQ_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FIRQ_INIT, 0
#emac

;#Abort action (to be executed in addition of quit and suspend action)
#macro	FIRQ_ABORT, 0
#emac
	
;#Quit action (to be executed in addition of suspend action)
#macro	FIRQ_QUIT, 0
#emac
	
;#Suspend action
#macro	FIRQ_SUSPEND, 0
#emac

;Interrupt handling:
;==================
;#Determine next ISR and clear IRQ
; args:	  none
; result: X: CFA of next ISR ($0000 if no IRQ is pending)
; SSTACK: none
;         No registers are preserved
#ifnmac	FIRQ_GET_ISR
#macro	FIRQ_GET_ISR, 0
			LDX	#$0000
#emac
#endif
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FIRQ_CODE_START_LIN
			ORG 	FIRQ_CODE_START, FIRQ_CODE_START_LIN
#else
			ORG 	FIRQ_CODE_START
FIRQ_CODE_START_LIN	EQU	@
#endif

;Code fields:
;============ 	
;CF_WAIT ( -- ) Wait until NP is modified
; args:   none	
; result: none
			;Wait for any internal system event
CF_WAIT_1		EQU	*
#ifmac FORTH_SIGNAL_IDLE
			FORTH_SIGNAL_IDLE		;signal inactivity
#endif
			ISTACK_WAIT			;wait for next interrupt
#ifmac FORTH_SIGNAL_BUSY
			FORTH_SIGNAL_BUSY		;signal activity
#endif
CF_WAIT			EQU	*
			;Check for change of NEXT_PTR 
			SEI				;disable interrupts
			LDX	NP			;check for default NEXT pointer
			CPX	#NEXT
			BEQ	CF_WAIT_1	 	;still default next pointer
			CLI				;enable interrupts
			;Execute non-default NEXT
			NEXT
	
FIRQ_CODE_END		EQU	*
FIRQ_CODE_END_LIN	EQU	@
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef FIRQ_TABS_START_LIN
			ORG 	FIRQ_TABS_START, FIRQ_TABS_START_LIN
#else
			ORG 	FIRQ_TABS_START
FIRQ_TABS_START_LIN	EQU	@
#endif	
	
FIRQ_TABS_END		EQU	*
FIRQ_TABS_END_LIN	EQU	@

;###############################################################################
;# Words                                                                       #
;###############################################################################
#ifdef FIRQ_WORDS_START_LIN
			ORG 	FIRQ_WORDS_START, FIRQ_WORDS_START_LIN
#else
			ORG 	FIRQ_WORDS_START
FIRQ_WORDS_START_LIN	EQU	@
#endif	
			ALIGN	1
;#ANSForth Words:
;================
	
;#S12CForth Words:
;================
;Word: WAIT ( -- )
;Wait for any interrupt event. (Wait until NEXT_PTR has been changed.)
CFA_WAIT		DW	CF_WAIT
	
	
FIRQ_WORDS_END		EQU	*
FIRQ_WORDS_END_LIN	EQU	@
#endif
