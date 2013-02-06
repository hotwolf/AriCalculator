;###############################################################################
;# S12CForth - FIRQ - Interrupt Support for the S12CForth Framework            #
;###############################################################################
;#    Copyright 2011-2013 Dirk Heisswolf                                       #
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
;#    This module provides a method for assembler level drivers to translate   #
;#    hardware interrupts into interrupts of the Forth program flow.           #
;#                                                                             #
;#    Whenever a driver wants to propagate an interrupt to the Forth system,   #
;#    it puts the xt of the associated ISR Forth word into a FIFI. This is     #
;#    accomplished by calling the FIRQ_IRQ subroutine.                         #
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
;#    The IRQ handler uses these registers:                                    #
;#     	ISTAT = Tell swhich interrupt levels ate currently blocked             #
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    February 3, 2013                                                         #
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
;# Memory Layout                                                               #
;###############################################################################
;              
;       RS:      	
;       +--------------+
;       |              |
;       |              |
;       |              | 
;       +--------------+
; RSP-> |  xt of RTI   |
;       +--------------+
;       | xt after ISR |
;       +--------------+

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Enable interrupts 
#ifndef	FIRQ_ON
#ifndef	FIRQ_OFF
FIRQ_ON			EQU	1 ;default is FIRQ_ON
#endif
#endif
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;#Interrupt status bits
FIRQ_ISTAT_SUSPEND	EQU	$0008	;suspend
FIRQ_ISTAT_ABORT	EQU	$0004	;break (results in abort)
FIRQ_ISTAT_IRQEN	EQU	$0002	;IRQ enable
FIRQ_ISTAT_ATTN		EQU	$0001	;make inner loop pay attention to interrupts

;#Queue element
FIRQ_QUEUE_NEXT		EQU	$0000	;next element
FIRQ_QUEUE_CFA		EQU	$0002	;CFA of service  routine
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FIRQ_VARS_START_LIN
			ORG 	FIRQ_VARS_START, FIRQ_VARS_START_LIN
#else
			ORG 	FIRQ_VARS_START
FIRQ_VARS_START_LIN	EQU	@
#endif	
#ifdef	FIRQ_ON

FIRQ_AUTO_LOC1		EQU	* 		;1st auto-place location
			ALIGN	1
			
FIRQ_QUEUE_START	DS	2 		;points to the first element of the queue
FIRQ_QUEUE_END		DS	2		;points to the next field of the last element

FIRQ_AUTO_LOC2		EQU	1		;2nd auto-place location
			UNALIGN	1
;#Flags
FIRQ_ISTAT		EQU	((FIRQ_VARS_START&1)*FIRQ_AUTO_LOC1)+((~FIRQ_VARS_START&1)*FIRQ_AUTO_LOC2)
			UNALIGN	(~FIRQ_AUTO_LOC1&1)

#endif
FIRQ_VARS_END		EQU	*
FIRQ_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FIRQ_INIT, 0
#ifdef	FIRQ_ON
			;Initialize IRQ state
			MOVW	#$0000,	FIRQ_QUEUE_START	;initialize queue
			MOVW	#(FIRQ_QUEUE_START-FIRQ_QUEUE_NEXT), FIRQ_QUEUE_END
			CLR	FIRQ_ISTAT	   	;	disable IRQs
#endif
#emac

;#QUIT action
#macro	FIRQ_QUIT, 0
#ifdef	FIRQ_ON
#endif
#emac
	
;#ABORT action (also in case of break or error)
#macro	FIRQ_ABORT, 0
#ifdef	FIRQ_ON
			;Quit action
			FIRQ_QUIT

			;Reset IRQ state
			MOVW	#$0000,	FIRQ_QUEUE_START	;initialize queue
			MOVW	#(FIRQ_QUEUE_START-FIRQ_QUEUE_NEXT), FIRQ_QUEUE_END
			CLR	FIRQ_ISTAT	   	;	disable IRQs
#endif
#emac
	
;Queue IRQ
; args:   1: Queue element
; result: none
; SSTACK: none
;         X, Y, and D are preserved
#macro	FIRQ_QUEUE_IRQ, 1	
			MOVW	\1, [FIRQ_QUEUE_END] ;
			MOVW	\1, FIRQ_QUEUE_END
#emac

;Queue IRQ
; args:   X: Queue element
; result: none
; SSTACK: none
;         X, Y, and D are preserved
#macro	FIRQ_QUEUE_IRQ_X, 0	
			STX	[FIRQ_QUEUE_END] ;
			STX	FIRQ_QUEUE_END
#emac

;Check for IRQs
; args:   1: branch address if IRQs are pending
; result: none
; SSTACK: none
;         X, Y, and D are preserved
#macro	FIRQ_CHECK_IRQ, 0	
			BRSET	FIRQ_ISTAT, #IRQ_ISTAT_ATTN, \1
#emac	

;Execute all IRQs
; args:   none
; result: none
; SSTACK: none
;         X, Y, and D are preserved
#macro	FIRQ_EXEC_IRQ, 0	
			EXEC_CF	EXEC

	
#emac	







	
;# Macros for internal use
	
;FIRQ_HANDLE_IRQS: Check for and execute pending IRQs
; args:   IP:  next execution token
; result: IP:  subsequentexecution token
; 	  W/X: new CFA
; 	  Y:   IP (= subsequent execution token)
; SSTACK: none
;         no register content is preserved
#macro	FIRQ_HANDLE_IRQS, 0
#ifdef	FIRQ_ON
			BRSET	FIRQ_ISTAT, #IRQ_ISTAT_ATTN, FIRQ_HANDLE_IRQS
#endif
#emac

	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FIRQ_CODE_START_LIN
			ORG 	FIRQ_CODE_START, FIRQ_CODE_START_LIN
#else
			ORG 	FIRQ_CODE_START
FIRQ_CODE_START_LIN	EQU	@
#endif
#ifdef	FIRQ_ON

;FIRQ_HANDLE_IRQS: Check for and execute pending IRQs
; args:   Y:   next execution token
; result: IP:  subsequentexecution token
; 	  W/X: new CFA
; 	  Y:   IP (= subsequent execution token)
; SSTACK: none
;         no register content is preserved
FIRQ_HANDLE_IRQS	EQU	*
			;Clear attention bit (execution token in Y)
			BCLR	FIRQ_STAT, #IRQ_ISTAT_ATTN
			;Check for Break or suspend (execution token in Y)
			LDAA	FIRQ_STAT 						;capture FIRQ_STAT
			BITA	#(FIRQ_ISTAT_BREAK|FIRQ_ISTAT_SUSPEND)
			BNE	FIRQ_HANDLE_IRQS_ 					;handle break or suspend
			;Check if interrupts are disabled (execution token in Y, FIRQ_STAT in A)
			BITA	#FIRQ_ISTAT_IRQEN
			BEQ	FIRQ_HANDLE_IRQS_ 					;interrupts are disabled
			;Check for queued interrupts (execution token in Y, FIRQ_STAT in A) 
			SEI								;avoid interrupt interference
			LDX	FIRQ_QUEUE_START
			BEQ	FIRQ_HANDLE_IRQS_ 					;queue is empty
			;Remove first FISR from queue (first element in X, execution token in Y)
			LDD	FIRQ_QUEUE_NEXT,X
			STD	FIRQ_QUEUE_START
			BNE	FIRQ_HANDLE_IRQS_A 					;queue has more than one elements
			MOVW	#(FIRQ_QUEUE_START-FIRQ_QUEUE_NEXT), FIRQ_QUEUE_END	;restore end pointer
			;Execute first FISR in queue (first element in X, execution token in Y)
FIRQ_HANDLE_IRQS_A	CLI				    				;release interrupts
			BCLR	FIRQ_STAT, #IRQ_ISTAT_IRQEN 				;disable further FIRQs
			TFR	Y,D
			RS_CHECK_OF_KEEP_X, 2 						;check stack space
			LDY	RSP 							;stack execution token and CFA_RTI
			STD	2,-Y
			MOVW	#IP_RTI, 2,-Y
			STY	RSP
			LDX	FIRQ_QUEUE_CFA,X
			LEAY	2,X
			STY	IP
			JMP	[0,X]
			;Handle break or suspend (execution token in Y, FIRQ_STAT in A)
			BITA	#FIRQ_ISTAT_SUSPEND
			BNE	FIRQ_HANDLE_IRQS_ 					;handle suspend
			;Handle break (execution token in Y, FIRQ_STAT in A)
			BCLR	FIRQ_STAT, #IRQ_ISTAT_BREAK
			
			




	
			;Handle suspend (execution token in Y, FIRQ_STAT in A)


	



	
macro	RS_CHECK_OF, 1
			LDX	NUMBER_TIB		;=> 3 cycles
			LEAX	(TIB_START+(2*\1)),X	;=> 2 cycles
			CPX	RSP			;=> 3 cycles
			BHI	FRAM_RSOF_HANDLER	;=> 3 cycles/ 4 c

	
			;Execute first ISR in queue (first element in X, execution token in Y)
			BCLR	FIRQ_STAT, #IRQ_ISTAT_IRQEN 				;disable further IRQs
			



	

	
			LDD	FIRQ_QUEUE_NEXT,X
			STD	FIRQ_QUEUE_START
			BNE	FIRQ_HANDLE_IRQS_ 					;queue has more than one elements
			;Queue has only one element (first element in X, execution token in Y)
			MOVW	#(FIRQ_QUEUE_START-FIRQ_QUEUE_NEXT), FIRQ_QUEUE_END	;restore end pointer

	
	
			MOVW	FIRQ_QUEUE_NEXT,X, FIRQ_STAT	;detach from queue	
			MOVW	#$0000, FIRQ_QUEUE_NEXT,X
			

	
	



#endif
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
#ifdef	FIRQ_ON






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
#ifdef	FIRQ_ON






#endif
FIRQ_WORDS_END		EQU	*
FIRQ_WORDS_END_LIN	EQU	@
