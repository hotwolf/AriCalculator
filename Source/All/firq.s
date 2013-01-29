;###############################################################################
;# S12CForth - FINT - Interrupt Suppoert for the S12CForth Framework           #
;###############################################################################
;#    Copyright 2011 Dirk Heisswolf                                            #
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
;#    This module provides a method for assemler level drivers to translate    #
;#    hardware interrupts into interrupts of the Forth program flow.           #
;#                                                                             #
;#    Whenever a driver wants to propagate an interrupt to the Forth system,   #
;#    it puts the xt of the associated ISR Forth word into a FIFI. This is     #
;#    accomplished by calling the FINT_IRQ subroutine.                         #
;#                                                                             #
;#    The S12CForth inner interpreter and the blocking I/O words are checking  #
;#    the content of the FIFO on a regular basis (primary non-blocking         #
;#    S12CForth words are not interrupted). If xt's have been queued, then the #
;#    context of the current program flow is pushed onto the return stack and  #
;#    all queued ISR xt's are executed. ISR words are not interruptable.       #
;#                                                                             #
;#    After all queued ISR xt's have been executed, the previous execution     #
;#    context is pulled from the return stack and the program flow is resumed. #
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    February 3, 2011                                                         #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    BASE - S12CBase framework                                                #
;#    FCORE - Forth core words                                                 #
;#    FMEM - Forth memories                                                    #
;#    FEXCPT - Forth exceptions                                                #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
			ORG	FINT_VARS_START
FINT_VARS_END		EQU	*

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FINT_INIT, 0
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG	FINT_CODE_START
;#Queue an interrupt
; args:   D: ISR xt
; result: D: error code (0=no error)
; SSTACK: 16 bytes
;         X and Y are preserved
FINT_CONVERT	EQU	*
			;Save registers (ISR xt in D)
			SSTACK_PSHYX				;save index X and Y
	
FINT_CODE_END		EQU	*



;#Common code fragments	
;NEXT:	jump to the next instruction
#macro	NEXT, 0	
NEXT			LDY	IP			;IP -> Y	        => 3 cycles
			LDX	2,Y+			;IP += 2, CFA -> X	=> 3 cycles   
			STY	IP			;	  	  	=> 3 cycles 
			JMP	[0,X]			;JUMP [CFA]             => 6 cycles
							;                         ---------
							;                         15 cycles
#emac

;SKIP_NEXT: skip next instruction and jump to one after
#macro	SKIP_NEXT, 0	
SKIP_NEXT		LDY	IP			;IP -> Y	        => 3 cycles
			LEAY	2,Y			;IP += 2		=> 2 cycles
			LDX	2,Y+			;IP += 2, CFA -> X	=> 3 cycles    
			STY	IP			;		  	=> 3 cycles 
			JMP	[0,X]			;JUMP [CFA]             => 6 cycles
							;                         ---------
							;                         17 cycles
#emac

;JUMP_NEXT: Read the next word entry and jump to that instruction 
#macro	JUMP_NEXT, 0	
JUMP_NEXT		LDY	[IP]			;[IP] -> Y	        => 6 cycles
			LDX	2,Y+			;IP += 2, CFA -> X	=> 3 cycles   
			STY	IP			;	  	  	=> 3 cycles 
			JMP	[0,X]			;JUMP [CFA]             => 6 cycles
							;                         ---------
							;                         18 cycles
#emac

;EXEC_CFA: Execute a Forth word (CFA) directly from assembler code 
#macro	EXEC_CFA, 3	;args: 1:CFA 2:RS overflow handler, 3:RS underflow handler
			RS_PUSH	IP, \2			;IP -> RS			
			MOVW	#IP_RESUME, IP 		;set next IP
			LDX	#\1			;set W
			JMP	[0,X]			;execute CF
IP_RESUME		DW	CFA_RESUME
CFA_RESUME		DW	CF_RESUME
CF_RESUME		RS_PULL	IP, \3 			;RS -> IP
#emac


	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG	FINT_TABS_START
;Error message 
FINT_OF_MSG		FCS	"Interrupt queue overflow"

FINT_TABS_END		EQU	*

;###############################################################################
;# Forth words                                                                 #
;###############################################################################
			ORG	FINT_WORDS_START	
FINT_WORDS_END		EQU	*
FINT_LAST_NFA		EQU	FINT_PREV_NFA
