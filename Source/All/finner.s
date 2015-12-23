#ifndef FINNER
#define FINNER
;###############################################################################
;# S12CForth - FINNER - Inner Interpreter                                      #
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
;#    This module implements the inner interpreter of the S12CForth virtual    #
;#    machine.                                                                 #
;#                                                                             #
;#    The inner interpreter implements these registers:                        #
;#         W = Working register. 					       #
;#             The W register points to the CFA of the current word, but it    #
;#             may be overwritten.	   			               #
;#             Used for indexed addressing and arithmetics.		       #
;#	       Index Register X is used to implement W.                        #
;#        IP = Instruction pointer.					       #
;#             Points to the next execution token.			       #
;#        NP = NEXT (instruction advancer) poiner			       #
;#  									       #
;#    Program termination options:                                             #
;#        ABORT:   Termination program in case of an error                     #
;#  		   Reset of the system				               #
;#        QUIT:    Regular termitation of a program                            #
;#                 Clean up of the system, exept for the program's output      #
;#        SUSPEND: Suspension of the program flow for debug purposes           #
;#                 Preservation of the system's state, exept for the           #
;#       	   interactive shell                                           #
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    January 25, 2013                                                         #
;#      - Initial release                                                      #
;#    October 15, 2015                                                         #
;#      - IP now points to the current instruction instead of the next one     #
;###############################################################################
;# Required Modules:                                                           #
;#    BASE   - S12CBase framework                                              #
;#    FRS    - Forth return stack                                              #
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
;Busy/idle signaling
;------------------- 
;Signal activity -> define macros FORTH_SIGNAL_BUSY and FORTH_SIGNAL_IDLE
;#mac FORTH_SIGNAL_BUSY, 0
;	...code to signal activity (inside CF)
;#emac
;#mac FORTH_SIGNAL_IDLE, 0			;X, Y, and D are preserved 
;	...code to signal inactivity (inside CF)
;#emac
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;Common aliases 
TRUE			EQU	$FFFF
FALSE			EQU	$0000	


;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FINNER_VARS_START_LIN
			ORG 	FINNER_VARS_START, FINNER_VARS_START_LIN
#else
			ORG 	FINNER_VARS_START
FINNER_VARS_START_LIN	EQU	@
#endif	
			ALIGN	1	
IP			DS	2 		;current instruction pointer
NP			DS	2		;pointer to the NEXT code 
	
FINNER_VARS_END		EQU	*
FINNER_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
;===============
#macro	FINNER_INIT, 0
#ifmac FORTH_SIGNAL_BUSY
			FORTH_SIGNAL_BUSY		;signal activity
#endif
			MOVW	#$0000, IP
			MOVW	#NEXT,  NP
#emac

;#Abort action (to be executed in addition of QUIT action)
#macro	FINNER_ABORT, 0
			MOVW	#NEXT,  NP
#emac
	
;#Quit action
#macro	FINNER_QUIT, 0
			;MOVW	#$0000, IP
#emac
	
;#Suspend action (to be executed in addition of QUIT action)
#macro	FINNER_SUSPEND, 0
#emac
	
;Inner interpreter:
;==================
;#NEXT:	Jump to the next instruction
; args:	  IP:  points to the current instruction
; result: IP:  points to next instruction
;         W/X: new CFA
;         Y:   IP (=pointer to current instruction)
; SSTACK: none
;         No registers are preserved
#macro	NEXT, 0	
			JMP	[NP]			;run next instruction	=> 6 cycles	 4 bytes
#emac

;#SKIP_NEXT: Skip next instruction and jump to one after
; args:	  IP:  points to the current instruction
; result: IP:  points to next instruction
;         W/X: new CFA
;         Y:   IP (=pointer to current instruction)
; SSTACK: none
;         No registers are preserved
#macro	SKIP_NEXT, 0	
			JOB	SKIP_NEXT		;run next instruction	=> 3 cycles	 3 bytes
#emac

;#JUMP_NEXT: Read the next word entry and jump to that instruction 
; args:	  IP:  points to the current instruction
; result: IP:  points to next instruction
;         W/X: new CFA
;         Y:   IP (=pointer to current instruction)
; SSTACK: none
;         No registers are preserved
#macro	JUMP_NEXT, 0	
			JOB	JUMP_NEXT		;run next instruction	=> 3 cycles	 3 bytes
#emac
	
;CF/CFA execution from assembly code:
;====================================
;Execute a CF directly from assembler code
; args:   1: CF
; result: see CF
; SSTACK: none
; PS:     see CF
; RS:     1+CF usage
; throws: FEXCPT_EC_RSOF (plus exceptions thrown by CF)
;         No registers are preserved
#macro	EXEC_CF, 1
			RS_PUSH IP			;IP -> RS
			MOVW	#(IP_RESUME-2), IP 	;set next IP
			JOB	\1			;execute CF
IP_RESUME		DW	CFA_RESUME
CFA_RESUME		DW	CF_RESUME
CF_RESUME		EQU	*
			RS_PULL IP 			;RS -> IP
#emac

;Execute a CF directly from assembler code
; args:   X: CF
; result: see CF
; SSTACK: none
; PS:     see CF
; RS:     1+CF usage
; throws: FEXCPT_EC_RSOF (plus exceptions thrown by CF )
;         No registers are preserved
#macro	EXEC_CF_X, 0
			RS_PUSH_KEEP_X IP		;IP -> RS
			MOVW	#(IP_RESUME-2), IP 	;set next IP
			JMP	0,X 			;execute CF
IP_RESUME		DW	CFA_RESUME
CFA_RESUME		DW	CF_RESUME
CF_RESUME		EQU	*
			RS_PULL IP 			;RS -> IP
#emac

;Execute a CFA directly from assembler code
; args:   1: CFA
; result: see CFA
; SSTACK: none
; PS:     see CFA
; RS:     1+CF usage
; throws: FEXCPT_EC_RSOF (plus exceptions thrown by CFA)
;         No registers are preserved
#macro	EXEC_CFA, 1
			RS_PUSH IP			;IP -> RS
			MOVW	#(IP_RESUME-2), IP 	;set next IP
			LDX	#\1
			JMP	[0,X]			;execute CF
IP_RESUME		DW	CFA_RESUME
CFA_RESUME		DW	CF_RESUME
CF_RESUME		EQU	*
			RS_PULL IP 			;RS -> IP
#emac
	
;Execute a CFA directly from assembler code
; args:   X: CFA
; result: see CFA
; SSTACK: none
; PS:     see CFA
; RS:     1+CF usage
; throws: FEXCPT_EC_RSOF (plus exceptions thrown by CFA)
;         No registers are preserved
#macro	EXEC_CFA_X, 0
			RS_PUSH_KEEP_X IP		;IP -> RS
			MOVW	#(IP_RESUME-2), IP 	;set next IP
			JMP	[0,X]			;execute CF
IP_RESUME		DW	CFA_RESUME
CFA_RESUME		DW	CF_RESUME
CF_RESUME		EQU	*
			RS_PULL IP 			;RS -> IP
#emac

;Idle state:
;===========
;#Wait for a system event (I-flag must be est before execution)
; args:	  none
; result: none
; SSTACK: none
;         No registers are preserved
#macro	FINNER_WAIT, 0
			LDX	NP			;check for default NEXT pointer
			CPX	#NEXT			;
			BNE	FINNER_WAIT_1	 	;NEXT pointer has been substituted
			;Wait for any  system event
#ifmac FORTH_SIGNAL_IDLE
			FORTH_SIGNAL_IDLE		;signal inactivity
#endif
			ISTACK_WAIT			;wait for next interrupt
#ifmac FORTH_SIGNAL_BUSY
			FORTH_SIGNAL_BUSY		;signal activity
#endif
			;Execute NEXT  
FINNER_WAIT_1		CLI				;enable interrupts
			EXEC_CF	CF_NOP			;execute substitute NEXT
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
	
;Inner interpreter:
;==================

;#SKIP_NEXT: skip the next instruction and jump to the one after
; args:	  IP:  points to the current instruction
; result: IP:  points to next instruction
;         W/X: new CFA
;         Y:   IP (=pointer to current instruction)
; SSTACK: none
; PS:     none
; RS:     none
; throws: none
;         No registers are preserved
SKIP_NEXT		EQU	*
			LDY	IP			;IP -> Y	        => 3 cycles	 3 bytes
			LEAY	2,Y			;IP += 2		=> 2 cycles	 2 bytes
			STY	IP			;			=> 3 cycles	 2 bytes
			JMP	[NP]			;			=> 6 cycles	 4 bytes
							;                   NEXT: 15 cycles
							;                         ---------
							;                         29 cycles

;#JUMP_NEXT: Read the next word entry and jump to that instruction 
; args:	  IP:  points to the current instruction
; result: IP:  points to next instruction
;         W/X: new CFA
;         Y:   IP (=pointer to current instruction)
; SSTACK: none
; PS:     none
; RS:     none
; throws: none
;         No registers are preserved
JUMP_NEXT		EQU	*
			LDY	IP			;old IP     -> Y	=> 3 cycles	 3 bytes
			LDY	2,Y			;new IP     -> Y	=> 3 cycles	 2 bytes
			LEAY	-2,Y			;new IP - 2 -> Y	=> 1 cycle	 2 bytes
			STY	IP			;			=> 3 cycles	 2 bytes
			JMP	[NP]			;			=> 6 cycles	 4 bytes
							;                   NEXT: 15 cycles
							;                         ---------
							;                         31 cycles

;#NEXT: jump to the next instruction
; args:	  IP:  points to the current instruction
; result: IP:  points to next instruction
;         W/X: new CFA
;         Y:   IP (=pointer to current instruction)
; SSTACK: none
; PS:     none
; RS:     none
; throws: none
NEXT			EQU	*
			LDY	IP			;IP -> Y	        => 3 cycles	 3 bytes
			LDX	2,+Y			;IP += 2, CFA -> X	=> 3 cycles 	 2 bytes   
			STY	IP			;	  	  	=> 3 cycles	 3 bytes 
			JMP	[0,X]			;JUMP [CFA]             => 6 cycles	 4 bytes
							;                         ---------
							;                         15 cycles

;Code fields:
;============ 	
;CF_INNER ( -- ) Execute the first execution token after the CFA (CFA in X)
; args:   IP:  old execution token	
;         W/X: old CFA
; result: IP:  new execution token
; 	  W/X: new CFA
; 	  Y:   IP (= new execution token)
CF_INNER		EQU		*
			TFR		X, Y		;old CFA+2 -> Y		=> 1 cycle	
			RS_PUSH		IP		;old IP -> RS		=>22 cycles
			LDX		2,+Y		;new CFA -> X		=> 3 cycles
			STY		IP		;new IP  -> IP		=> 3 cycles
			JMP		[0,X]		;JUMP [new CFA]         => 6 cycles
							;                         ---------
							;                         35 cycles
			;Old implementation: 
			;------------------- 
			;RS_PUSH_KEEP_X	IP		;IP -> RS		=>22 cycles
			;LEAY		2,X		;CFA+2 -> IP		=> 2 cycles
			;STY		IP		;			=> 3 cycles
			;LDX		2,X		;new CFA -> X		=> 3 cycles
			;JMP		[0,X]		;JUMP [new CFA]         => 6 cycles
							;                         ---------
							;                         36 cycles

;CF_EOW ( -- ) End of  word
; args:   top of RS: next execution token	
; result: IP:  current execution token
CF_EOW			EQU	*
			RS_PULL IP			;RS -> IP		=>14 cycles
CF_EOW_1		NEXT


;CF_NOP ( -- ) No operation
; args:   none	
; result: none
CF_NOP			EQU		CF_EOW_1
	
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
			ALIGN	1, $FF
;#ANSForth Words:
;================
	
;#S12CForth Words:
;================
;EOW ( -- )
;End of word
CFA_EOW			DW	CF_EOW

;Word: NOP ( -- )
;No operation
CFA_NOP			DW	CF_NOP

FINNER_WORDS_END	EQU	*
FINNER_WORDS_END_LIN	EQU	@
#endif
