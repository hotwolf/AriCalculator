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
;#    machine.                                                                 #x
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
;#    BASE   - S12CBase framework                                              #
;#    FRS    - Forth return stack                                              #
;#    FIRQ   - Forth interrupt request handler                                 #
;#    FDBG   - Forth debugger                                                  #
;#                                                                             #
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
;# NEXT implementations                                                        #
;###############################################################################
; 
;      +-----------------+
;      |    NEXT_WATCH   |
;      +-----------------+
;              ^ |        
;          IRQ | | no IRQ 
;     received | | pending
;          or  | |  and 
;  breakpoints | | breakpoints 
;      enabled | | disabled
;              | v        
;      +-----------------+
;      |      NEXT       |
;      +-----------------+
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

;NEXT_WATCH usage
#ifmac	FIRQ_BR_NO_IRQS
#ifmac	FIRQ_CALL_NEXT_ISR
FINNER_USE_NEXT_WATCH	EQU	1
#endif
#endif
#ifmac	FDBG_BR_NO_BKPS
#ifmac	FDBG_CHECK_BKP
FINNER_USE_NEXT_WATCH	EQU	1
#endif
#endif
	
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
IP			DS	2 		;instruction pointer
NEXT_PTR		DS	2		;pointer to the NEXT code 

FINNER_VARS_END		EQU	*
FINNER_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FINNER_INIT, 0
#ifmac FORTH_SIGNAL_BUSY
			FORTH_SIGNAL_BUSY		;signal activity
#endif
			MOVW	#$0000, IP
			MOVW	#NEXT,  NEXT_PTR
#emac

;#Abort action (to be executed in addition of quit action)
#macro	FINNER_ABORT, 0
#emac
	
;#Quit action
#macro	FINNER_QUIT, 0
			MOVW	#$0000, IP
			MOVW	#NEXT, NEXT_PTR
#emac
	
;#Suspend action
#macro	FINNER_SUSPEND, 0
#emac

#ifdef	FINNER_USE_NEXT_WATCH
;Interrupt handling:
;==================
;#Request inner interpreter to check for pending interrupts and breakpoints
; (after executing the current word) 
; args:	  none
; result: none
; SSTACK: none
;         No registers are preserved
#macro	FINNER_WATCH, 0
			SEI		 		;make atomic
			LDX	NEXT_PTR		;check for default next
			CPX	#NEXT
			BNE	DONE 			;IRQs are already taken care of
			MOVW	#NEXT_WATCH, NEXT_PTR	;check IRQs at word boundary
DONE			CLI				;allow interrupts
#emac
#endif

;Inner interpreter:
;==================
;#NEXT:	jump to the next instruction
; args:	  IP:   pointer to next instruction
; result: IP:   pointer to subsequent instruction
;         W/X:  new CFA
;         Y:    IP (=pointer to subsequent instruction)
; SSTACK: none
;         No registers are preserved
#macro	NEXT, 0	
			JMP	[NEXT_PTR]		;run next instruction	=> 6 cycles	 4 bytes
#emac

;#SKIP_NEXT: skip next instruction and jump to one after
; args:	  IP:   pointer to next instruction
; result: IP:   pointer to subsequent instruction
;         W/X:  new CFA
;         Y:    IP (=pointer to subsequent instruction)
; SSTACK: none
;         No registers are preserved
#macro	SKIP_NEXT, 0	
			JOB	SKIP_NEXT		;run next instruction	=> 3 cycles	 3 bytes
#emac

;#JUMP_NEXT: Read the next word entry and jump to that instruction 
; args:	  IP:   pointer to next instruction
; result: IP:   pointer to subsequent instruction
;         W/X:  new CFA
;         Y:    IP (=pointer to subsequent instruction)
; SSTACK: none
;         No registers are preserved
#macro	JUMP_NEXT, 0	
			JOB	JUMP_NEXT		;run next instruction	=> 3 cycles	 3 bytes
#emac
	
;CF/CFA/ISR execution from assembly code:
;========================================
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
			MOVW	#IP_RESUME, IP 		;set next IP
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
			MOVW	#IP_RESUME, IP 		;set next IP
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
			MOVW	#IP_RESUME, IP 		;set next IP
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
			MOVW	#IP_RESUME, IP 		;set next IP
			JMP	[0,X]			;execute CF
IP_RESUME		DW	CFA_RESUME
CFA_RESUME		DW	CF_RESUME
CF_RESUME		EQU	*
			RS_PULL IP 			;RS -> IP
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
; args:	  IP:  pointer to next instruction
;	  IRQ: pending interrupt requests
; result: IP:  pointer to subsequent instruction
;         W/X: new CFA
;         Y:   IP (=pointer to subsequent instruction)
; SSTACK: none
; PS:     none
; RS:     none
; throws: none
;         No registers are preserved
SKIP_NEXT		EQU	*
			LDY	IP			;IP -> Y	        => 3 cycles	 3 bytes
			LEAY	2,Y			;IP += 2		=> 2 cycles	 2 bytes
			STY	IP			;			=> 3 cycles	 2 bytes
			JMP	[NEXT_PTR]		;			=> 6 cycles	 4 bytes
							;                   NEXT: 15 cycles
							;                         ---------
							;                         29 cycles

;#JUMP_NEXT: Read the next word entry and jump to that instruction 
; args:	  IP:  pointer to next instruction
;	  IRQ: pending interrupt requests
; result: IP:  pointer to subsequent instruction
;         W/X: new CFA
;         Y:   IP (=pointer to subsequent instruction)
; SSTACK: none
; PS:     none
; RS:     none
; throws: none
;         No registers are preserved
JUMP_NEXT		EQU	*
			LDY	[IP]			;[IP] -> Y	        => 6 cycles	 4 bytes
			STY	IP			;			=> 3 cycles	 2 bytes
			JMP	[NEXT_PTR]		;			=> 6 cycles	 4 bytes
							;                   NEXT: 15 cycles
							;                         ---------
							;                         30 cycles

;NEXT implementations:
;=====================
;#NEXT_WATCH: jump to the next available ISR
; args:	  IP:   pointer to next instruction
; result: IP:   pointer to subsequent instruction
;         W/X:  new CFA
;         Y:    IP (=pointer to subsequent instruction)
; PS:     none
; RS:     1+ISR usage
; throws: none
NEXT_WATCH		EQU	*
#ifdef	FINNER_USE_NEXT_WATCH
			;Restore NEXT
			MOVW	#NEXT, NEXT_PTR		;set default NEXT pointer
#ifmac	FDBG_BR_NO_BKPS
#ifmac	FDBG_CHECK_BKP
			;Check for breakpoints 
			FDBG_BR_NO_BKPS	 NEXT_WATCH_2	;no breakpoints to check
			FDBG_CHECK_BKP			;suspend on breakpoint
#endif
#endif
#ifmac	FIRQ_BR_NO_IRQS
#ifmac	FIRQ_CALL_NEXT_ISR
			;Check for pending IRQs 
NEXT_WATCH_1		FIRQ_BR_NO_IRQS	 NEXT_WATCH_2	;no IRQ
			FIRQ_CALL_NEXT_ISR
			JOB	NEXT_WATCH_1
#endif
#endif
			;No pending IRQs
NEXT_WATCH_2		NEXT
#endif
	
;#NEXT: jump to the next instruction
; args:	  IP:   pointer to next instruction
; result: IP:   pointer to subsequent instruction
;         W/X:  new CFA
;         Y:    IP (=pointer to subsequent instruction)
; PS:     none
; RS:     none
; throws: none
NEXT			EQU	*
			LDY	IP			;IP -> Y	        => 3 cycles	 3 bytes
			LDX	2,Y+			;IP += 2, CFA -> X	=> 3 cycles 	 2 bytes   
			STY	IP			;	  	  	=> 3 cycles	 3 bytes 
			JMP	[0,X]			;JUMP [CFA]             => 6 cycles	 4 bytes
							;                         ---------
							;                         15 cycles
;Code fields:
;============ 	

;CF_INNER ( -- ) Execute the first execution token after the CFA (CFA in X)
; args:   IP:  next execution token	
;         W/X: current CFA
; result: IP:  subsequent execution token
; 	  W/X: current CFA
; 	  Y:   IP (= subsequent execution token)
CF_INNER		EQU		*
			RS_PUSH_KEEP_X	IP		;IP -> RS		=>22 cycles
			LEAY		4,X		;CFA+4 -> IP		=> 2 cycles
			STY		IP		;			=> 3 cycles
			LDX		2,X		;new CFA -> X		=> 3 cycles
			JMP		[0,X]		;JUMP [new CFA]         => 6 cycles
							;                         ---------
							;                         36 cycles

;CF_EOW ( -- ) End of  word
; args:   top of RS: next execution token	
; result: IP:  subsequent execution token
CF_EOW			EQU	*
			RS_PULL IP			;RS -> IP		=>14 cycles
CF_EOW_1		NEXT


;CF_NOP ( -- ) No operation
; args:   none	
; result: none
CF_NOP			EQU		CF_EOW_1

#ifmac	FIRQ_BR_NO_IRQS
#ifmac	FIRQ_CALL_NEXT_ISR
;CF_WAIT ( -- ) Wait until the NEXT_PTR is modified
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
			LDX	NEXT_PTR		;check for default NEXT pointer
			CPX	#NEXT
			BEQ	CF_WAIT_1	 	;still default next pointer
			CLI				;enable interrupts
			;Execute non-default NEXT
			NEXT
#endif
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
			ALIGN	1
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

#ifmac	FIRQ_BR_NO_IRQS
#ifmac	FIRQ_CALL_NEXT_ISR
;Word: WAIT ( -- )
;Wait for any interrupt event. (Wait until NEXT_PTR has been changed.)
CFA_WAIT		DW	CF_WAIT
#endif
#endif
	
FINNER_WORDS_END	EQU	*
FINNER_WORDS_END_LIN	EQU	@
#endif