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
;#       IRQ = Interrupt request flags to interrupt the program flow.          #
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
;Interrupt service routines
#ifndef	CFA_ISR_PRIO_C
CFA_ISR_PRIO_C		EQU	CFA_ISR_UNEXPECTED
#end
#ifndef	CFA_ISR_PRIO_B
CFA_ISR_PRIO_B		EQU	CFA_ISR_UNEXPECTED
#end
#ifndef	CFA_ISR_PRIO_A
CFA_ISR_PRIO_A		EQU	CFA_ISR_UNEXPECTED
#end
#ifndef	CFA_ISR_PRIO_9
CFA_ISR_PRIO_9		EQU	CFA_ISR_UNEXPECTED
#end
#ifndef	CFA_ISR_PRIO_8
CFA_ISR_PRIO_8		EQU	CFA_ISR_UNEXPECTED
#end
#ifndef	CFA_ISR_PRIO_7
CFA_ISR_PRIO_7		EQU	CFA_ISR_UNEXPECTED
#end
#ifndef	CFA_ISR_PRIO_6
CFA_ISR_PRIO_6		EQU	CFA_ISR_UNEXPECTED
#end
#ifndef	CFA_ISR_PRIO_5
CFA_ISR_PRIO_5		EQU	CFA_ISR_UNEXPECTED
#end
#ifndef	CFA_ISR_PRIO_4
CFA_ISR_PRIO_4		EQU	CFA_ISR_UNEXPECTED
#end
#ifndef	CFA_ISR_PRIO_3
CFA_ISR_PRIO_3		EQU	CFA_ISR_UNEXPECTED
#end
#ifndef	CFA_ISR_PRIO_2
CFA_ISR_PRIO_2		EQU	CFA_ISR_UNEXPECTED
#end
#ifndef	CFA_ISR_PRIO_1
CFA_ISR_PRIO_1		EQU	CFA_ISR_UNEXPECTED
#end
#ifndef	CFA_ISR_PRIO_0
CFA_ISR_PRIO_0		EQU	CFA_ISR_UNEXPECTED
#end
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;IRQ flags 
IRQ_INHIBIT		EQU	$8000
IRQ_SUSPEND		EQU	$4000 ;non-maskable
IRQ_PRIO_D		EQU	$2000 ;highest priority interrupt request
IRQ_PRIO_C		EQU	$1000
IRQ_PRIO_B		EQU	$0400
IRQ_PRIO_A		EQU	$0400
IRQ_PRIO_9		EQU	$0200
IRQ_PRIO_8		EQU	$0100
IRQ_PRIO_7		EQU	$0080
IRQ_PRIO_6		EQU	$0040
IRQ_PRIO_5		EQU	$0020
IRQ_PRIO_4		EQU	$0010
IRQ_PRIO_3		EQU	$0008
IRQ_PRIO_2		EQU	$0004
IRQ_PRIO_1		EQU	$0002
IRQ_PRIO_0		EQU	$0001 ;lowest priority interrupt request
	
;Break indicator Value 
BREAK_INDICATOR_HIVAL	EQU	$0555
BREAK_INDICATOR_LOVAL	EQU	~BREAK_INDICATOR_HIVAL

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
IRQ			DS	2		;attention flags
BREAK_INDICATOR_HI	EQU	IP
BREAK_INDICATOR_LO	EQU	IRQ
	
FINNER_VARS_END		EQU	*
FINNER_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FINNER_INIT, 0
#emac

;Break/suspend handling:
;============-==========
;#Break: Set break indicator and perform a systewm reset
#macro	SCI_BREAK_ACTION, 0
			MOVW	#BREAK_INDICATOR_HIVAL, BREAK_INDICATOR_HI
			MOVW	#BREAK_INDICATOR_LOVAL, BREAK_INDICATOR_LO
			RESET_RESTART_NO_MSG	
#emac

;#Abort action (to be executed in addition of quit action)
#macro	FINNER_ABORT, 0
#emac
	
;#Quit action
#macro	FINNER_QUIT, 0
#emac
	
;#Suspend: Set suspend flag
#macro	SCI_SUSPEND_ACTION, 0
			BSET	IRQ, #IRQ_SUSPEND
#emac
	
;Inner interpreter:
;==================

;#NEXT:	jump to the next instruction
; args:	  IP:   pointer to next instruction
;	  IRQ: pending interrupt requests
; result: IP:   pointer to subsequent instruction
;         W/X:  new CFA
;         Y:    IP (=pointer to subsequent instruction)
; SSTACK: none
;         No registers are preserved
#macro	NEXT, 0	
			JOB	NEXT			;run next instruction	=> 3 cycles	 3 bytes
#emac
;#SKIP_NEXT: skip next instruction and jump to one after
; args:	  IP:   pointer to next instruction
;	  IRQ: pending interrupt requests
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
;	  IRQ: pending interrupt requests
; result: IP:   pointer to subsequent instruction
;         W/X:  new CFA
;         Y:    IP (=pointer to subsequent instruction)
; SSTACK: none
;         No registers are preserved
#macro	JUMP_NEXT, 0	
			JOB	JUMP_NEXT		;run next instruction	=> 3 cycles	 3 bytes
#emac

;Enable/disable interrupts:
;==========================

;#INHIBIT_IRQS
; args:	  none
; result: none
; SSTACK: none
;         X, Y, and D are preserved
#macro	ALLOW_IRQS, 0	
			BCLR	IRQ, #((IRQ_INHIBIT)>>8)
#emac

;#ALLOW_IRQS
; args:	  none
; result: none
; SSTACK: none
;         X, Y, and D are preserved
#macro	INHIBIT_IRQS, 0	
			BSET	IRQ, #((IRQ_INHIBIT)>>8)
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
			RS_PULL IP, 			;RS -> IP
#emac
	
;Execute a CFA directly from assembler code
; args:   X: CFA
; result: see CF
; SSTACK: none
; PS:     see CF
; RS:     1+CF usage
; throws: FEXCPT_EC_RSOF (plus exceptions thrown by CF)
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
	
;Execute interrupt service routine
; args:   X: ISR (CFA)
; result: see CF
; SSTACK: none
; PS:     see CF
; RS:     1+CF usage
; throws: FEXCPT_EC_RSOF (plus exceptions thrown by CF)
;         No registers are preserved
#macro	EXEC_ISR_X, 0
			INHIBIT_IRQS
			EXEC_CFA_X
			ALLOW_IRQS
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

;Entry point:
;============
FSTART			EQU	*			





	
;Inner interpreter:
;==================

;#NEXT:	jump to the next instruction
; args:	  IP:   pointer to next instruction
;	  IRQ: pending interrupt requests
; result: IP:   pointer to subsequent instruction
;         W/X:  new CFA
;         Y:    IP (=pointer to subsequent instruction)
; SSTACK: none
; PS:     none
; RS:     none
; throws: none
;         No registers are preserved
NEXT			EQU	*
			LDY	IP			;IP -> Y	        => 3 cycles	 3 bytes
			LDD	IRQ			;check IRQ flags	=> 3 cycles	 3 bytes
			BNE	NEXT_			;	 	      	=> 1 cycle	 4 bytes
NEXT_1			LDX	2,Y+			;IP += 2, CFA -> X	=> 3 cycles 	 2 bytes   
			STY	IP			;	  	  	=> 3 cycles	 3 bytes 
			JMP	[0,X]			;JUMP [CFA]             => 6 cycles	 4 bytes
							;                         ---------	--------
							;                         19 cycles	19 bytes
			;Update (IP in Y, IRQ in D)
NEXT_			STY	IP
			;Some IRQ flags set (IP in Y, IRQ in D)
NEXT_			LSLD				;remove inhibit flag 
			BEQ	NEXT_1			;no IRQs
			BMI	NEXT_			;execute SUSPEND
			BCS	NEXT_1			;interrupts inhibited
			;Check high prio IRQs (IP in Y, IRQ<<1 in D)
			LSRA				;only check prio C..8
			LDAB	#$80
			LDX	#(ISR_TAB-6)
NEXT_			LSRB				;find first one loop
			LEAX	2,X
			LSLA
			BEQ	NEXT_
			BCC	NEXT_
			


	
			;Pending interrupt found (IP in Y, ISR table pointer in X, flag mask in B)
			COMB				;clear request flag
			SEI
			ANDB	IRQ
			STAB	IRQ
			CLI
			LDX	0,X 			;execute ISR
			EXEC_ISR_X
			NEXT				;next instruction
			;Check low prio IRQs (IP in Y, ISR table pointer in X)
NEXT_			LDAA	IRQ+1
			LDAB	#(IRQ_SUSPEND>>8)


	

			COMB				;clear request and inhibit interrupts
			ANDB	IRQ
			ORAB	#(IRQ_INHIBIT>>8)


			STAB	IRQ
			LDX	0,X 			;execute ISR
			EXEC_CFA_X
			ALLOW_IRQS ;
			

	

	

;#SKIP_NEXT: skip next instruction and jump to one after
; args:	  IP:   pointer to next instruction
;	  IRQ: pending interrupt requests
; result: IP:   pointer to subsequent instruction
;         W/X:  new CFA
;         Y:    IP (=pointer to subsequent instruction)
; SSTACK: none
; PS:     none
; RS:     none
; throws: none
;         No registers are preserved
SKIP_NEXT		EQU	*
			LDY	IP			;IP -> Y	        => 3 cycles	 3 bytes
			LEAY	2,Y			;IP += 2		=> 2 cycles	 2 bytes
			LDD	IRQ			;check IRQ flags       => 3 cycles	 3 bytes
			BMI	IRQ_HANDLER		;		      	=> 1 cycle	 4 bytes
			LDX	2,Y+			;IP += 2, CFA -> X	=> 3 cycles 	 2 bytes   
			STY	IP			;		  	=> 3 cycles	 3 bytes 
			JMP	[0,X]			;JUMP [CFA]             => 6 cycles	 4 bytes
							;                         ---------	--------
							;                         21 cycles	21 bytes

;#JUMP_NEXT: Read the next word entry and jump to that instruction 
; args:	  IP:   pointer to next instruction
;	  IRQ: pending interrupt requests
; result: IP:   pointer to subsequent instruction
;         W/X:  new CFA
;         Y:    IP (=pointer to subsequent instruction)
; SSTACK: none
; PS:     none
; RS:     none
; throws: none
;         No registers are preserved
JUMP_NEXT		EQU	*
			LDY	[IP]			;[IP] -> Y	        => 6 cycles	 4 bytes
			LDD	IRQ			;check IRQ flags	=> 3 cycles	 3 bytes
			BMI	IRQ_HANDLER		;		      	=> 1 cycle	 4 bytes
			LDX	2,Y+			;IP += 2, CFA -> X	=> 3 cycles 	 2 bytes   
			STY	IP			;	  	  	=> 3 cycles	 3 bytes 
			JMP	[0,X]			;JUMP [CFA]             => 6 cycles	 4 bytes
							;                         ---------	--------
							;                         22 cycles	20 bytes

;#IRQ_HANDLER: Read the next word entry and jump to that instruction 
; args:	  Y:    next IP (IP register to be ignored)
;         D:    IRQ (pending interrupt requests)
; result: IP:   pointer to subsequent instruction
;         W/X:  new CFA
;         Y:    IP (=pointer to subsequent instruction)
; SSTACK: none
; PS:     none
; RS:     none
; throws: none
;         No registers are preserved

IRQ_HANDLER		EQU	*
			;Check for BREAK 
			LSLD
			LSLD
			BCC	IRQ_HANDLER_ 		;execute BREAK
			;Check for SUSPEND
			LSLD
			BCC	IRQ_HANDLER_ 		;execute BREAK
#ifdef CFA_ISR_PRIO_B
			; 
	

	
			BMI	...
			;Check for Suspend
			LDX	#CF_....
			LSLD
			BMI	...

	
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

;CF_EOW ( -- ) End of  word
; args:   top of RS: next execution token	
; result: IP:  subsequent execution token
; 	  W/X: current CFA
; 	  Y:   IP (= subsequent execution token)
; SSTACK: none
;        D is preserved 
CF_EXIT			LDD		IRQ 		;IRQ state -> X		=> 3 cycles
			BMI		CF_EXIT_1	;handle IRQs		=> 1 cycle
			RS_PULL_Y			;RS -> Y (= IP)		=>12 cycles
			LDX		2,Y+		;IP += 2, CFA -> X	=> 3 cycles
			STY		IP 		;			=> 3 cycles	=> 3 cycles 
			JMP		[0,X]		;JUMP [CFA]             => 6 cycles
							;                         ---------
							;                         28 cycles			
			;Handle IRQs (IRQ status in D)
CF_EXIT_1		LSLD				;check for break
			BMI		___BREAK
			LSLD				;check for suspend
			BMI		___SUSPEND
			








	


	
;Word: IRQEN ( -- )
;Enable interrupts 
CF_IRQEN		ENABLE_IRQS
			NEXT

;Word: IRQDIS ( -- )
;Disable interrupts 
CF_IRQDIS		DISABLE_IRQS
			NEXT

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

CFA_ISR_TAB			EQU	
			DW	CFA_ISR_PRIO_D
			DW	CFA_ISR_PRIO_C
			DW	CFA_ISR_PRIO_B
			DW	CFA_ISR_PRIO_A
			DW	CFA_ISR_PRIO_9
			DW	CFA_ISR_PRIO_8
			DW	CFA_ISR_PRIO_7
			DW	CFA_ISR_PRIO_6
			DW	CFA_ISR_PRIO_5
			DW	CFA_ISR_PRIO_4
			DW	CFA_ISR_PRIO_3
			DW	CFA_ISR_PRIO_2
			DW	CFA_ISR_PRIO_1
			DW	CFA_ISR_PRIO_0
	
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

;#Code Field Addresses:
;======================
			ALIGN	1
; ( -- )
;End of word
CFA_EOW			DW	CF_EOW

; ( -- )
;Return from interrupt
CFA_RTI				DW	CF_RTI
	
;Word: WAI ( -- )
;Wait for interrupt 
CFA_WAI 		DW	CF_WAI
	
;Word: IRQEN ( -- )
;Enable interrupts 
CFA_IRQEN		DW	CF_IRQEN

;Word: IRQDIS ( -- )
;Disable interrupts 
CFA_IRQDIS		DW	CF_IRQDIS
	
FINNER_WORDS_END		EQU	*
FINNER_WORDS_END_LIN	EQU	@
