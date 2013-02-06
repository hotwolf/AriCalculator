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
;#  									       #
;###############################################################################
;# Version History:                                                            #
;#    January 25, 2013                                                         #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    SSTACK	- Subroutine stack                                             #
;#    FRAM	- Forth return stack                                           #
;#    FIRQ	- Forth interrupt handler                                      #
;#    FSTART	- Forth start-up procedure                                     #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################

;###############################################################################
;# Code Field Structure                                                        #
;###############################################################################
;	
;        +-------------+
;        |     CFA     | -> ASM code	
;        +-------------+    +-------------+
;  IP -> |     xt      | -> |     CFA     | -> ASM code
;        +-------------+    +-------------+
;        |     xt      |    |     xt      |
;        +-------------+    +-------------+
;                           |     xt      |
;                           +-------------+
;	
;   IP   = next execution token        
;  [IP]  = CFA of next execution token	
; [[IP]] = ASM code of next execution token
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
	
;Word-aligh variables
#ifndef FINNER_WALGN_ON
#ifndef FINNER_WALGN_OFF
FINNER_INLINE_ON	EQU	1 			;default is FINNER_INLINE_ON
#endif	
#endif	
	
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FINNER_VARS_START_LIN
			ORG 	FINNER_VARS_START, FINNER_VARS_START_LIN
#else
			ORG 	FINNER_VARS_START
FINNER_VARS_START_LIN	EQU	@
#endif	
#ifdef 	FINNER_WALGN_ON
			ALIGN	1
#endif	
	
IP			DS	2 		;instruction pointer

FINNER_VARS_END		EQU	*
FINNER_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FINNER_INIT, 0
#emac

;#Quit action
#macro	FINNER_QUIT, 0
#emac
	
;#Abort action (also in case of break or error)
#macro	FINNER_ABORT, 0
			;Quit action
			FINNER_QUIT	
#emac
	
#ifdef FINNER_INLINE_ON
;NEXT: jump to the next instruction
; args:   IP:  new execution token
; result: IP:  subsequent execution token
; 	  W/X: new CFA
; 	  Y:   IP (= subsequent execution token)
; SSTACK: none
;        D is preserved 
#macro	NEXT, 0	
NEXT			LDY	IP			;IP -> Y	        => 3 cycles	 3 bytes
#ifdef	FIRQ_ON						;
			FIRQ_HANDLE_IRQS		;			=> 5 cycles      5 bytes
#endif							;
			LDX	2,Y+			;IP += 2, CFA -> X	=> 3 cycles 	 2 bytes
			STY	IP			;	  	  	=> 3 cycles	 3 bytes 
			JMP	[0,X]			;JUMP [CFA]             => 6 cycles	 4 bytes
							;                         ---------	--------
							;                         20 cycles	17 bytes
#emac

;SKIP_NEXT: skip next instruction and jump to one after
; args:   IP:  execution token to be skipped
; result: IP:  subsequent execution token
; 	  W/X: new CFA
; 	  Y:   IP (= subsequent execution token)
; SSTACK: none
;        D is preserved 
#macro	SKIP_NEXT, 0	
SKIP_NEXT		LDY	IP			;IP -> Y	        => 3 cycles	 3 bytes
			LEAY	2,Y			;IP += 2		=> 2 cycles	 2 bytes
#ifdef	FIRQ_ON						;
			FIRQ_HANDLE_IRQS		;			=> 5 cycles      5 bytes
#endif							;
			LDX	2,Y+			;IP += 2, CFA -> X	=> 3 cycles 	 2 bytes
			STY	IP			;		  	=> 3 cycles	 3 bytes 
			JMP	[0,X]			;JUMP [CFA]             => 6 cycles	 4 bytes
							;                         ---------	--------
							;                         22 cycles	19 bytes
#emac

;JUMP_NEXT: Read the next word entry and jump to that instruction 
; args:   IP:  pointer to the new execution token
; result: IP:  subsequentexecution token
; 	  W/X: new CFA
; 	  Y:   IP (= subsequent execution token)
; SSTACK: none
;        D is preserved 
#macro	JUMP_NEXT, 0	
JUMP_NEXT		LDY	[IP]			;[IP] -> Y	        => 6 cycles	 4 bytes
#ifdef	FIRQ_ON					;
			FIRQ_HANDLE_IRQS		;			=> 5 cycles      5 bytes
#endif							;
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

;Execute a CFA directly from assembler code
; args:   1: CFA
; result: see CF
; SSTACK: none
; PS:     see CF
; RS:     1+CF usage
; throws: FEXCPT_EC_RSOF (plus exceptions thrown by CF)
#macro	EXEC_CFA, 1
			RS_PUSH IP			;IP -> RS
			MOVW	#IP_RESUME, IP 		;set next IP
			LDX	#\1			;set W
			JMP	[0,X]			;execute CF
IP_RESUME		DW	CFA_RESUME
CFA_RESUME		DW	CF_RESUME
CF_RESUME		EQU	*
			RS_PULL IP, 			;RS -> IP
#emac

;Execute a CFA directly from assembler code
; args:   1: CFA
; result: see CF
; SSTACK: none
; PS:     see CF
; RS:     1+CF usage
; throws: FEXCPT_EC_RSOF (plus exceptions thrown by CF)
#macro	EXEC_CF, 1
			RS_PUSH IP			;IP -> RS
			MOVW	#IP_RESUME, IP 		;set next IP
			JOB	\1			;execute CF
IP_RESUME		DW	CFA_RESUME
CFA_RESUME		DW	CF_RESUME
CF_RESUME		EQU	*
			RS_PULL IP, 			;RS -> IP
#emac
	
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
;FINNER_NEXT: jump to the next instruction
;NEXT: jump to the next instruction
; args:   IP:  new execution token
; result: IP:  subsequent execution token
; 	  W/X: new CFA
; 	  Y:   IP (= subsequent execution token)
; SSTACK: none
;        D is preserved 
FINNER_NEXT		EQU	*		
ifdef	FIRQ_ON					;
			FIRQ_HANDLE_IRQS		;			=> 5 cycles      5 bytes
#endif							;
			LDY	IP			;IP -> Y	        => 3 cycles	 3 bytes
			LDX	2,Y+			;IP += 2, CFA -> X	=> 3 cycles 	 2 bytes   
			STY	IP			;	  	  	=> 3 cycles	 3 bytes 
			JMP	[0,X]			;JUMP [CFA]             => 6 cycles	 4 bytes
							;                         ---------	--------
							;                         20 cycles	17 bytes

;FINNER_SKIP_NEXT: skip next instruction and jump to one after
; args:   IP:  execution token to be skipped
; result: IP:  subsequent execution token
; 	  W/X: new CFA
; 	  Y:   IP (= subsequent execution token)
; SSTACK: none
;        D is preserved 
FINNER_SKIP_NEXT	EQU	*		
ifdef	FIRQ_ON						;
			FIRQ_HANDLE_IRQS		;			=> 5 cycles      5 bytes
#endif							;
			LDY	IP			;IP -> Y	        => 3 cycles	 3 bytes
			LEAY	2,Y			;IP += 2		=> 2 cycles	 2 bytes
			LDX	2,Y+			;IP += 2, CFA -> X	=> 3 cycles 	 2 bytes   
			STY	IP			;		  	=> 3 cycles	 3 bytes 
			JMP	[0,X]			;JUMP [CFA]             => 6 cycles	 4 bytes
							;                         ---------	--------
							;                         22 cycles	19 bytes

;FINNER_JUMP_NEXT: Read the next word entry and jump to that instruction 
; args:   IP:  pointer to the new execution token
; result: IP:  subsequentexecution token
; 	  W/X: new CFA
; 	  Y:   IP (= subsequent execution token)
; SSTACK: none
;        D is preserved 
FINNER_JUMP_NEXT	EQU	*
ifdef	FIRQ_ON						;
			FIRQ_HANDLE_IRQS		;			=> 5 cycles      5 bytes
#endif							;
			LDY	[IP]			;[IP] -> Y	        => 6 cycles	 4 bytes
			LDX	2,Y+			;IP += 2, CFA -> X	=> 3 cycles 	 2 bytes   
			STY	IP			;	  	  	=> 3 cycles	 3 bytes 
			JMP	[0,X]			;JUMP [CFA]             => 6 cycles	 4 bytes
							;                         ---------	--------
							;                         23 cycles	18 bytes
#endif
	
;Code fields:
;============ 	
;CF_INNER   ( -- )	Execute the first execution token after the CFA (CFA in X)
; args:   IP:  next execution token	
;         W/X: current CFA
; result: IP:  subsequent execution token
; 	  W/X: current CFA
; 	  Y:   IP (= subsequent execution token)
; SSTACK: none
;        D is preserved 
CF_INNER		EQU		*
			RS_PUSH_KEEP_X	IP		;IP -> RS		=>22 cycles
			LEAY		4,X		;CFA+4 -> IP		=> 2 cycles
			STY		IP		;			=> 3 cycles
			LDX		2,X		;new CFA -> X		=> 3 cycles
			JMP		[0,X]		;JUMP [new CFA]         => 6 cycles
							;                         ---------
							;                         36 cycles

;CF_EXIT   ( -- )	End the execution of thhe current word
; args:   top of RS: next execution token	
; result: IP:  subsequent execution token
; 	  W/X: current CFA
; 	  Y:   IP (= subsequent execution token)
; SSTACK: none
;        D is preserved 
CF_EXIT			RS_PULL_Y			;RS -> Y (= IP)		=>12 cycles
			LDX		2,Y+		;IP += 2, CFA -> X	=> 3 cycles
			STY		IP 		;			=> 3 cycles 
			JMP		[0,X]		;JUMP [CFA]             => 6 cycles
							;                         ---------
							;                         24 cycles			
	
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


