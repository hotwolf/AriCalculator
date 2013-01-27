;###############################################################################
;# S12CForth - FINNER - Inner Interpreter                                      #
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
;#    This module implements the inner interpreter of the S12CForth virtual    #
;#    machine.                                                                 #
;#                                                                             #
;#    The inner interpreter uses these registers:                              #
;#         W = Working register. 					       #
;#             The W register points to the CFA of the current word, but it    #
;#             may be overwritten.	   			               #
;#             Used for indexed addressing and arithmetics.		       #
;#	       Index Register X is used to implement W.                        #
;#        IP = Instruction pointer.					       #
;#             Points to the next execution token.			       #
;#  IRQ_STAT = IRQ status register.					       #
;#             The inner interpreter only uses bits 1 and 0. The remaining     #
;#  	       may be used by the interrupt handler.                           #
;#  									       #
;###############################################################################
;# Version History:                                                            #
;#    January 25, 2013                                                         #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    FRS	- Forth return stack                                           #
;#    FINT	- Forth interrupt handler                                      #
;#    FSTART	- Forth start-up procedure                                     #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################

;###############################################################################
;# Code Field Structure                                                        #
;###############################################################################
;	
;        +-----------+
;        |    CFA    | -> ASM code	
;        +-----------+    +-----------+
;  IP -> | PRIMITIVE | -> |    CFA    | -> ASM code
;        +-----------+    +-----------+
;                         | PRIMITIVE |
;                         +-----------+
;   IP   = PRIMITIVE        
;  [IP]  = CFA	
; [[IP]] = ASM code	
;	

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Implement inner iterpreter instructuons inline 
#ifndef FINNER_INLINE_ON
#ifndef FINNER_INLINE_OFF
FINNER_INLINE_OFF	EQU	1 			;default is FINNER_INLINE_OFF
#endif	
#endif	
	
;Interrupt handler (interrupts are disabled if no handler is defined)
;FINNER_INT_HANDLER	EQU	FINT_INT_HANDLER 	;
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;Interrupt requests (bits 15..3 may be used by the interrupt handler)
FINNER_IRQ_EN		EQU	$01
FINNER_IRQ		EQU	$02
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FINNER_VARS_START_LIN
			ORG 	FINNER_VARS_START, FINNER_VARS_START_LIN
#else
			ORG 	FINNER_VARS_START
FINNER_VARS_START_LIN	EQU	@
#endif	

IP			DS	2 		;instruction pointer
#ifdef	FINNER_INT_HANDLER
IRQ_STAT		DS	2 		;IRQ status register
#endif	

FINNER_VARS_END		EQU	*
FINNER_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FINNER_INIT, 0
			;Initialize IRQ status 
			CLR	FINNER_IRQ_STAT
#emac

;FINNER_CHECK_IRQ:	check IRQ status
; args:   none
; result: none
; SSTACK: none
;        X, Y, and D are preserved 
#macro	FINNER_CHECK_IRQ, 0	
#ifdef	FINNER_INT_HANDLER
			BRSET	(IRQ_STAT+1),#(FINNER_IRQ_EN|FINNER_IRQ),FINNER_INT_HANDLER+1
#endif	
#emac
	
#ifdef FINNER_INLINE_ON
;NEXT:	jump to the next instruction
; args:   IP:  next execution token
; result: IP:  next execution token
; 	  W/X: current CFA
; 	  Y:   IP
; SSTACK: none
;        D is preserved 
#macro	NEXT, 0	
NEXT			FINNER_CHECK_IRQ 		;			=> 5 cycles      5 bytes
			LDY	IP			;IP -> Y	        => 3 cycles	 3 bytes
			LDX	2,Y+			;IP += 2, CFA -> X	=> 3 cycles 	 2 bytes   
			STY	IP			;	  	  	=> 3 cycles	 3 bytes 
			JMP	[0,X]			;JUMP [CFA]             => 6 cycles	 4 bytes
							;                         ---------	--------
							;                         20 cycles	17 bytes
#emac

;SKIP_NEXT: skip next instruction and jump to one after
; args:   IP:  next execution token
; result: IP:  next execution token
; 	  W/X: current CFA
; 	  Y:   IP
; SSTACK: none
;        D is preserved 
#macro	SKIP_NEXT, 0	
SKIP_NEXT		FINNER_CHECK_IRQ 		;			=> 5 cycles      5 bytes
			LDY	IP			;IP -> Y	        => 3 cycles	 3 bytes
			LEAY	2,Y			;IP += 2		=> 2 cycles	 2 bytes
			LDX	2,Y+			;IP += 2, CFA -> X	=> 3 cycles 	 2 bytes   
			STY	IP			;		  	=> 3 cycles	 3 bytes 
			JMP	[0,X]			;JUMP [CFA]             => 6 cycles	 4 bytes
							;                         ---------	--------
							;                         22 cycles	19 bytes
#emac

;JUMP_NEXT: Read the next word entry and jump to that instruction 
; args:   IP:  next execution token
; result: IP:  next execution token
; 	  W/X: current CFA
; 	  Y:   IP
; SSTACK: none
;        D is preserved 
#macro	JUMP_NEXT, 0	
JUMP_NEXT		FINNER_CHECK_IRQ 		;			=> 5 cycles      5 bytes
			LDY	[IP]			;[IP] -> Y	        => 6 cycles	 4 bytes
			LDX	2,Y+			;IP += 2, CFA -> X	=> 3 cycles 	 2 bytes   
			STY	IP			;	  	  	=> 3 cycles	 3 bytes 
			JMP	[0,X]			;JUMP [CFA]             => 6 cycles	 4 bytes
							;                         ---------	--------
							;                         23 cycles	18 bytes
#emac
#else
;NEXT:	jump to the next instruction
; args:   IP:  next execution token
; result: IP:  next execution token
; 	  W/X: current CFA
; 	  Y:   IP
; SSTACK: none
;        D is preserved 
#macro	NEXT, 0	
NEXT			JOB	FINNER_NEXT		;                         23 cycles	 3 bytes
#emac

;SKIP_NEXT: skip next instruction and jump to one after
; args:   IP:  next execution token
; result: IP:  next execution token
; 	  W/X: current CFA
; 	  Y:   IP
; SSTACK: none
;        D is preserved 
#macro	SKIP_NEXT, 0	
SKIP_NEXT		JOB	FINNER_SKIP_NEXT	;                         25 cycles	 3 bytes
#emac

;JUMP_NEXT: Read the next word entry and jump to that instruction 
; args:   IP:  next execution token
; result: IP:  next execution token
; 	  W/X: current CFA
; 	  Y:   IP
; SSTACK: none
;        D is preserved 
#macro	JUMP_NEXT, 0	
JUMP_NEXT		JOB	FINNER_JUMP_NEXT	;                         26 cycles	 3 bytes
#emac
#endif
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FINNER_CODE_START_LIN
			ORG 	FINNER_CODE_START, FINNER_CODE_START_LIN
#else
			ORG 	FINNER_CODE_START
FINNER_CODE_START_LIN	EQU	@
#endif

#ifndef FINNER_INLINE_ON
;FINNER_NEXT:	jump to the next instruction
; args:   IP:  next execution token
; result: IP:  next execution token
; 	  W/X: current CFA
; 	  Y:   IP
; SSTACK: none
;        D is preserved 
FINNER_NEXT		FINNER_CHECK_IRQ 		;			=> 5 cycles      5 bytes
			LDY	IP			;IP -> Y	        => 3 cycles	 3 bytes
			LDX	2,Y+			;IP += 2, CFA -> X	=> 3 cycles 	 2 bytes   
			STY	IP			;	  	  	=> 3 cycles	 3 bytes 
			JMP	[0,X]			;JUMP [CFA]             => 6 cycles	 4 bytes
							;                         ---------	--------
							;                         20 cycles	17 bytes

;FINNER_SKIP_NEXT: skip next instruction and jump to one after
; args:   IP:  next execution token
; result: IP:  next execution token
; 	  W/X: current CFA
; 	  Y:   IP
; SSTACK: none
;        D is preserved 
FINNER_SKIP_NEXT	FINNER_CHECK_IRQ 		;			=> 5 cycles      5 bytes
			LDY	IP			;IP -> Y	        => 3 cycles	 3 bytes
			LEAY	2,Y			;IP += 2		=> 2 cycles	 2 bytes
			LDX	2,Y+			;IP += 2, CFA -> X	=> 3 cycles 	 2 bytes   
			STY	IP			;		  	=> 3 cycles	 3 bytes 
			JMP	[0,X]			;JUMP [CFA]             => 6 cycles	 4 bytes
							;                         ---------	--------
							;                         22 cycles	19 bytes

;FINNER_JUMP_NEXT: Read the next word entry and jump to that instruction 
; args:   IP:  next execution token
; result: IP:  next execution token
; 	  W/X: current CFA
; 	  Y:   IP
; SSTACK: none
;        D is preserved 
FINNER_JUMP_NEXT	FINNER_CHECK_IRQ 		;			=> 5 cycles      5 bytes
			LDY	[IP]			;[IP] -> Y	        => 6 cycles	 4 bytes
			LDX	2,Y+			;IP += 2, CFA -> X	=> 3 cycles 	 2 bytes   
			STY	IP			;	  	  	=> 3 cycles	 3 bytes 
			JMP	[0,X]			;JUMP [CFA]             => 6 cycles	 4 bytes
							;                         ---------	--------
							;                         23 cycles	18 bytes
#endif
	
FINNER_CODE_END		EQU	*
FINNER_CODE_END_LIN	EQU	@
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef FINNER_TABS_START_LIN
			ORG 	FINNER_TABS_START, FINNER_TABS_START_LIN
#else
			ORG 	FINNER_TABS_START
FINNER_TABS_START_LIN	EQU	@
#endif	

FINNER_TABS_END		EQU	*
FINNER_TABS_END_LIN	EQU	@

;###############################################################################
;# Words                                                                       #
;###############################################################################
#ifdef FINNER_WORDS_START_LIN
			ORG 	FINNER_WORDS_START, FINNER_WORDS_START_LIN
#else
			ORG 	FINNER_WORDS_START
FINNER_WORDS_START_LIN	EQU	@
#endif	

FINNER_WORDS_END		EQU	*
FINNER_WORDS_END_LIN	EQU	@


