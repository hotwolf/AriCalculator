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
;#      ATTN = IRQ alert                                                       #
;#       IRQ = Interrupt request flags                                         #
;#  									       #
;###############################################################################
;# Version History:                                                            #
;#    January 25, 2013                                                         #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    SSTACK	- Subroutine stack                                             #
;#    FRAM	- Forth return stack                                           #
;#    FEXCEPT	- Forth exception handler                                      #
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
;FINNER_ISR_PRIO_C		EQU	CFA_ISR_UNEXPECTED
;FINNER_ISR_PRIO_B		EQU	CFA_ISR_UNEXPECTED
;FINNER_ISR_PRIO_A		EQU	CFA_ISR_UNEXPECTED
;FINNER_ISR_PRIO_9		EQU	CFA_ISR_UNEXPECTED
;FINNER_ISR_PRIO_8		EQU	CFA_ISR_UNEXPECTED
;FINNER_ISR_PRIO_7		EQU	CFA_ISR_UNEXPECTED
;FINNER_ISR_PRIO_6		EQU	CFA_ISR_UNEXPECTED
;FINNER_ISR_PRIO_5		EQU	CFA_ISR_UNEXPECTED
;FINNER_ISR_PRIO_4		EQU	CFA_ISR_UNEXPECTED
;FINNER_ISR_PRIO_3		EQU	CFA_ISR_UNEXPECTED
;FINNER_ISR_PRIO_2		EQU	CFA_ISR_UNEXPECTED
;FINNER_ISR_PRIO_1		EQU	CFA_ISR_UNEXPECTED
;FINNER_ISR_PRIO_0		EQU	CFA_ISR_UNEXPECTED
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;IRQ bits 
IRQ_ATTM		EQU	$8000 ;pay attention to interrupt requests
IRQ_SUSPEND		EQU	$4000 ;suspend ctrl-Z
IRQ_INHIBIT		EQU	$2000 ;block IRQs
IRQ_PRIO_C		EQU	$1000 ;highest priority interrupt request
IRQ_PRIO_B		EQU	$0800
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

;Interrupt service routines and defined masks
#ifdef	FINNER_ISR_PRIO_C
FINNER_DEF_PRIO_C	EQU	IRQ_PRIO_PRIO_C
#else	
FINNER_DEF_PRIO_C	EQU	0
FINNER_ISR_PRIO_C	EQU	FINNER_ISR_UNEXPECTED
#end
#ifdef	FINNER_ISR_PRIO_B
FINNER_DEF_PRIO_B	EQU	IRQ_PRIO_PRIO_B
#else	
FINNER_DEF_PRIO_B	EQU	0
FINNER_ISR_PRIO_B	EQU	FINNER_ISR_UNEXPECTED
#end
#ifdef	FINNER_ISR_PRIO_A
FINNER_DEF_PRIO_A	EQU	IRQ_PRIO_PRIO_A
#else	
FINNER_DEF_PRIO_A	EQU	0
FINNER_ISR_PRIO_A	EQU	FINNER_ISR_UNEXPECTED
#end
#ifdef	FINNER_ISR_PRIO_9
FINNER_DEF_PRIO_9	EQU	IRQ_PRIO_PRIO_9
#else	
FINNER_DEF_PRIO_9	EQU	0
FINNER_ISR_PRIO_9	EQU	FINNER_ISR_UNEXPECTED
#end
#ifdef	FINNER_ISR_PRIO_8
FINNER_DEF_PRIO_8	EQU	IRQ_PRIO_PRIO_8
#else	
FINNER_DEF_PRIO_8	EQU	0
FINNER_ISR_PRIO_8	EQU	FINNER_ISR_UNEXPECTED
#end
#ifdef	FINNER_ISR_PRIO_7
FINNER_DEF_PRIO_7	EQU	IRQ_PRIO_PRIO_7
#else	
FINNER_DEF_PRIO_7	EQU	0
FINNER_ISR_PRIO_7	EQU	FINNER_ISR_UNEXPECTED
#end
#ifdef	FINNER_ISR_PRIO_6
FINNER_DEF_PRIO_6	EQU	IRQ_PRIO_PRIO_6
#else	
FINNER_DEF_PRIO_6	EQU	0
FINNER_ISR_PRIO_6	EQU	FINNER_ISR_UNEXPECTED
#end
#ifdef	FINNER_ISR_PRIO_5
FINNER_DEF_PRIO_5	EQU	IRQ_PRIO_PRIO_5
#else	
FINNER_DEF_PRIO_5	EQU	0
FINNER_ISR_PRIO_5	EQU	FINNER_ISR_UNEXPECTED
#end
#ifdef	FINNER_ISR_PRIO_4
FINNER_DEF_PRIO_4	EQU	IRQ_PRIO_PRIO_4
#else	
FINNER_DEF_PRIO_4	EQU	0
FINNER_ISR_PRIO_4	EQU	FINNER_ISR_UNEXPECTED
#end
#ifdef	FINNER_ISR_PRIO_3
FINNER_DEF_PRIO_3	EQU	IRQ_PRIO_PRIO_3
#else	
FINNER_DEF_PRIO_3	EQU	0
FINNER_ISR_PRIO_3	EQU	FINNER_ISR_UNEXPECTED
#end
#ifdef	FINNER_ISR_PRIO_2
FINNER_DEF_PRIO_2	EQU	IRQ_PRIO_PRIO_2
#else	
FINNER_DEF_PRIO_2	EQU	0
FINNER_ISR_PRIO_2	EQU	FINNER_ISR_UNEXPECTED
#end
#ifdef	FINNER_ISR_PRIO_1
FINNER_DEF_PRIO_1	EQU	IRQ_PRIO_PRIO_1
#else	
FINNER_DEF_PRIO_1	EQU	0
FINNER_ISR_PRIO_1	EQU	FINNER_ISR_UNEXPECTED
#end
#ifdef	FINNER_ISR_PRIO_0
FINNER_DEF_PRIO_0	EQU	IRQ_PRIO_PRIO_0
#else	
FINNER_DEF_PRIO_0	EQU	0
FINNER_ISR_PRIO_0	EQU	FINNER_ISR_UNEXPECTED
#end
FINNER_DEF_PRIO_C_8	EQU	IRQ_PRIO_PRIO_C|IRQ_PRIO_PRIO_B|IRQ_PRIO_PRIO_A|IRQ_PRIO_PRIO_9|IRQ_PRIO_PRIO_8
FINNER_DEF_PRIO_7_4	EQU	IRQ_PRIO_PRIO_7|IRQ_PRIO_PRIO_6|IRQ_PRIO_PRIO_5|IRQ_PRIO_PRIO_4
FINNER_DEF_PRIO_3_0	EQU	IRQ_PRIO_PRIO_3|IRQ_PRIO_PRIO_2|IRQ_PRIO_PRIO_1|IRQ_PRIO_PRI|O_0
FINNER_DEF_PRIOS	EQU	IRQ_PRIO_PRIO_C_8|IRQ_PRIO_PRIO_7_4|IRQ_PRIO_PRIO_3_0
FINNER_UNDEF_PRIOS	EQU 	~IRQ_PRIO_PRIOS

;Interrupt flag clearing masks
FINNER_MASK_PRIO_C	EQU	IRQ_PRIO_C|IRQ_ATTN|FINNER_UNDEF_PRIOS
FINNER_MASK_PRIO_B	EQU	IRQ_PRIO_B|FINNER_MASK_PRIO_C
FINNER_MASK_PRIO_A	EQU	IRQ_PRIO_A|FINNER_MASK_PRIO_B
FINNER_MASK_PRIO_9	EQU	IRQ_PRIO_9|FINNER_MASK_PRIO_A
FINNER_MASK_PRIO_8	EQU	IRQ_PRIO_8|FINNER_MASK_PRIO_9
FINNER_MASK_PRIO_7	EQU	IRQ_PRIO_7|FINNER_MASK_PRIO_8
FINNER_MASK_PRIO_6	EQU	IRQ_PRIO_6|FINNER_MASK_PRIO_7
FINNER_MASK_PRIO_5	EQU	IRQ_PRIO_5|FINNER_MASK_PRIO_6
FINNER_MASK_PRIO_4	EQU	IRQ_PRIO_4|FINNER_MASK_PRIO_5
FINNER_MASK_PRIO_3	EQU	IRQ_PRIO_3|FINNER_MASK_PRIO_4
FINNER_MASK_PRIO_2	EQU	IRQ_PRIO_2|FINNER_MASK_PRIO_3
FINNER_MASK_PRIO_1	EQU	IRQ_PRIO_1|FINNER_MASK_PRIO_2
FINNER_MASK_PRIO_0	EQU	IRQ_PRIO_0|FINNER_MASK_PRIO_1
						    
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
IRQ			DS	2		;interrupt flags
	
FINNER_VARS_END		EQU	*
FINNER_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FINNER_INIT, 0
#emac

;#Abort action (to be executed in addition of quit and suspend action)
#macro	FINNER_ABORT, 0
#emac
	
;#Quit action (to be executed in addition of suspend action)
#macro	FINNER_QUIT, 0
#emac
	
;#Suspend action
#macro	FINNER_SUSPEND, 0
#emac
	
;Break/suspend handling:
;=======================
;#Break: Set break indicator and perform a systewm reset
#macro	SCI_BREAK_ACTION, 0
			RESET_RESTART_NO_MSG	
#emac

;#Suspend: Set suspend flag
#macro	SCI_SUSPEND_ACTION, 0
			BSET	IRQ, #(IRQ_ATTN|IRQ_SUSPEND)
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

; args:	  none
; result: none
; SSTACK: none
;         X and Y are preserved
#macro	ALLOW_IRQS, 0	
			SEI				;make operation atomic
			LDD	IRQ			;fetch IRQ
			ANDA	#~IRQ_INIBIT		;clear IRQ_INHIBIT bit
			BNE	ALLOW_IRQS_1		;set IRQ_ATTN
			TBEQ	B, ALLOW_IRQS_2		;don't set IRQ_ATTN
ALLOW_IRQS_1		ORAA	#IRQ_ATTN		;set IRQ_ATTN
ALLOW_IRQS_2		STAA	IRQ			;update IRQ
			CLI				;end atomic operation
#emac

;#ALLOW_IRQS
;#INHIBIT_IRQS
; args:	  none
; result: none
; SSTACK: none
;         X and Y are preserved
#macro	INHIBIT_IRQS, 0	
			SEI				;make operation atomic
			LDAA	IRQ			;fetch IRQ
			BITA	#~IRQ_SUSPEND		;check IRQ_SUSPEND bit
			BNE	INHIBIT_IRQS_1		;keep IRQ_ATTN set
			ANDA	#~IRQ_ATTN		;clear IRQ_ATTN
INHIBIT_IRQS_1		STAA	IRQ			;update IRQ
			CLI				;end atomic operation
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


;#SKIP_NEXT: skip next instruction and jump to one after
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
			STY	IP
			JOB	SKIP_NEXT_1
SKIP_NEXT_1		EQU	NEXT_1

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
			STY	IP
			JOB	JUMP_NEXT_1
JUMP_NEXT_1		EQU	NEXT_1
	
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
NEXT_1			LDAA	IRQ			;check IRQ_ATTN flag	=> 3 cycles	 3 bytes
			BMI	NEXT_2			;	 	      	=> 1 cycle	 4 bytes
			LDX	2,Y+			;IP += 2, CFA -> X	=> 3 cycles 	 2 bytes   
			STY	IP			;	  	  	=> 3 cycles	 3 bytes 
			JMP	[0,X]			;JUMP [CFA]             => 6 cycles	 4 bytes
							;                         ---------	--------
							;                         19 cycles	19 bytes
			;Check for IRQs
NEXT_2			SEI				;make operation atomic
			LDD	IRQ			;refetch IRQ
			LSLD				;remove IRQ_ATTN bit
			BMI	NEXT_4 			;suspend
			LSLD				;remove IRQ_SUSPEND bit
			LSLD				;remove IRQ_INHIBIT bit
			BLS	NEXT_ 			;No IRQs or IRQs are inhibited (C+Z=1)
			;Find pending IRQ (IRQ<<3 in D)
			LDX	#-2
NEXT_3			LEAX	2, X			;point to next vector table entry
			LSLD				;remove next IRQ_PRIO bit
			BHI	NEXT_3			;check next lower IRQ_PRIO bit
			;Clear interrupt flag (table offset in X) 
			LDD	FINNER_MASK_TAB,X 	;fetch mask
			AMDD	IRQ			;apply mask
			ORAA	#(IRQ_INHIBIT>>8)	;set IRQ_INHIBIT flag
			STD	IRQ			;update IRQ
			CLI				;end atomic operation
			;Execute ISR (table offset in X) 
			LDX	FINNER_ISR_TAB,X 	;fetch ISR vector
			EXEC_CFA_X			;execute ISR
			ALLOW_IRQS			;enable pending interrupts
			JOB	NEXT_2			;check for further interrupt requests
			;Suspend  (IRQ<<1 in D)
NEXT_4			;Catch all exceptions


			;No IRQs to execute 
NEXT_			BCLR	IRQ, #IRQ_ATTN 		;clear IRQ_ATTN bit
			CLI				;end atomic operation
			JOB	NEXT		
	
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
CF_EXIT			RS_PULL_Y			;RS -> Y (= IP)		=>12 cycles
			STY		IP 		;			=> 3 cycles	=> 3 cycles 
			JOB		CF_EXIT_1
CF_EXIT_1		EQU		NEXT_1


;Word: IRQEN ( -- )
;Enable interrupts 
CF_IRQEN		ALLOW_IRQS
			NEXT

;Word: IRQDIS ( -- )
;Disable interrupts 
CF_IRQDIS		INIBIT_IRQS
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

FINNER_ISR_TAB		EQU	*
			DW	FINNER_ISR_PRIO_C
			DW	FINNER_ISR_PRIO_B
			DW	FINNER_ISR_PRIO_A
			DW	FINNER_ISR_PRIO_9
			DW	FINNER_ISR_PRIO_8
			DW	FINNER_ISR_PRIO_7
			DW	FINNER_ISR_PRIO_6
			DW	FINNER_ISR_PRIO_5
			DW	FINNER_ISR_PRIO_4
			DW	FINNER_ISR_PRIO_3
			DW	FINNER_ISR_PRIO_2
			DW	FINNER_ISR_PRIO_1
			DW	FINNER_ISR_PRIO_0

FINNER_MASK_TAB		EQU	*
			DW	FINNER_MASK_PRIO_C
			DW	FINNER_MASK_PRIO_B
			DW	FINNER_MASK_PRIO_A
			DW	FINNER_MASK_PRIO_9
			DW	FINNER_MASK_PRIO_8
			DW	FINNER_MASK_PRIO_7
			DW	FINNER_MASK_PRIO_6
			DW	FINNER_MASK_PRIO_5
			DW	FINNER_MASK_PRIO_4
			DW	FINNER_MASK_PRIO_3
			DW	FINNER_MASK_PRIO_2
			DW	FINNER_MASK_PRIO_1
			DW	FINNER_MASK_PRIO_0
	
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
CFA_RTI			DW	CF_RTI
	
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
