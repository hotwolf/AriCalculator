#ifndef	DELAY_COMPILED 
#define	DELAY_COMPILED
;###############################################################################
;# S12CBase - DELAY - Delay Driver                                             #
;###############################################################################
;#    Copyright 2010-2016 Dirk Heisswolf                                       #
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
;#    The module drives sequential patterns onto the LEDs.                     #
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    January20, 2016                                                          #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    TIM - Timer Driver                                                       #
;#                                                                             #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;TIM configuration
;Output compare channel
;TIM instance for baud rate detection, shutdown, and flow control
#ifndef	DELAY_TIM
DELAY_TIM		EQU	TIOS 		;default is the TIM instance associated with TIOS
#endif
#ifndef	DELAY_OC
DELAY_OC		EQU	3 		;default is OC3
#endif
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;#Timer configuration
; TIOS 
DELAY_TIOS_INIT		EQU	1<<DELAY_OC

;#Output compare register
DELAY_OC_TC		EQU	DELAY_TIM+TC0_OFFSET+(2*DELAY_OC);OC compare register
	
;#Shortest OC period (8 bus cycles)
DELAY_MIN_TC		EQU	8*(CLOCK_BUS_FREQ/TIM_FREQ)
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef DELAY_VARS_START_LIN
			ORG 	DELAY_VARS_START, DELAY_VARS_START_LIN
#else
			ORG 	DELAY_VARS_START
DELAY_VARS_START_LIN	EQU	@			
#endif	

DELAY_REM_TIME		DS	2 		;counts remaining timer intervalls
	
DELAY_VARS_END		EQU	*
DELAY_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
;#--------------
#macro	DELAY_INIT, 0
#emac
	
;#User functions
;#--------------
;#Start a delay of a given time (or longer)
; args:   D: delay in ms
; result: none
; SSTACK: 6 bytes
;         X, Y, and D are preserved 
#macro DELAY_INDUCE, 0
			SSTACK_JOBSR	DELAY_INDUCE, 6
#emac

;#Wait until delay is over - non-blocking
; args:   none
; result: C-flag: set if successful (delay over)
; SSTACK: 0 bytes
;         X, Y, and D are preserved 
#macro DELAY_WAIT_NB, 0
			JOBSR	DELAY_WAIT_NB
#emac

;#Wait until delay is over - blocking
; args:   none
; result: none
; SSTACK: 2 bytes
;         X, Y, and D are preserved 
#macro DELAY_WAIT_BL, 0
			SSTACK_JOBSR	DELAY_WAIT_BL, 2
#emac

;#Millisecond delay - blocking
; args:   D: delay in ms
; result: none
; SSTACK: 8 bytes
;         X, Y, and D are preserved 
#macro DELAY_MS_BL, 0
			SSTACK_JOBSR	DELAY_MS_BL, 8
#emac

;#Helper functions
;#----------------
;#Turn a non-blocking subroutine into a blocking subroutine	
; args:   1: non-blocking function
;         2: subroutine stack usage of non-blocking function
; SSTACK: stack usage of non-blocking function + 2
;         rgister output of the non-blocking function is preserved
#macro	DELAY_MAKE_BL, 2
			;Disable interrupts
LOOP			SEI
			;Call non-blocking function
			//SSTACK_PREPUSH	\2
			JOBSR	\1
			BCC	WAIT 		;function unsuccessful
			;Enable interrupts
			CLI
			;Done
			SSTACK_PREPULL	2
			RTS
			;Wait for next interrupt
WAIT			ISTACK_WAIT
			;Try again
			SSTACK_PREPUSH	\2
			JOB	LOOP	
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef DELAY_CODE_START_LIN
			ORG 	DELAY_CODE_START, DELAY_CODE_START_LIN
#else
			ORG 	DELAY_CODE_START
#endif

;#Start a delay of a given time (or longer)
; args:   D: delay in ms
; result: none
; SSTACK: 6 bytes
;         X, Y, and D are preserved 
DELAY_INDUCE		EQU	*
			;Save registers (ms delay in D)
			PSHY					;save Y
			PSHD					;save D
			;Calculate tc delay (ms delay in D)
			LDY	#(TIM_FREQ/1000) 		;TIM freq in kHz -> Y
			EMUL					;D * Y -> Y:D
			;Adjust tc delay if LSW is to short (tc delay in Y:D)
			EXG	D, Y 				;tc delay ->D:Y
			CPY	#DELAY_MIN_TC			;check for min. timer delay
			SBCB	#0				;subtract one
			SBCA	#0				; timer intervall
			BCS	DELAY_INDUCE_1 		;do nothing
			EXG	D, Y 				;adjusted tc delay ->Y:D
			;Set up timer (adjusted tc delay in Y:D)
			SEI		       			;start of atomic sequence
			STY	DELAY_REM_TIME			;set remainig time counter
			TIM_EN		DELAY_TIM, DELAY_OC	;enable timer
			TIM_SET_DLY_D	DELAY_TIM, DELAY_OC	;RPO PWO OPwP
			CLI		       			;end of atomic sequence
			;Restore registers (ms delay in D)
DELAY_INDUCE_1	SSTACK_PREPULL	6			;check SSTACK
			PULD					;restore D
			PULY					;restore Y
			RTS					;done
	
;#Wait until delay is over - non-blocking
; args:   none
; result: C-flag: set if successful (delay over)
; SSTACK: 0 bytes
;         X, Y, and D are preserved 
DELAY_WAIT_NB		EQU	*
			CLC					;flag failure by default
			TIM_BREN DELAY_TIM,DELAY_OC,DELAY_WAIT_NB_1;delau still ongoing
			SEC					;flag success
DELAY_WAIT_NB_1		RTS					;done

;#Wait until delay is over - blocking
; args:   none
; result: none
; SSTACK: 2 bytes
;         X, Y, and D are preserved 
DELAY_WAIT_BL		EQU	*
			DELAY_MAKE_BL	DELAY_WAIT_NB, 0
	
;#Millisecond delay - blocking
; args:   D: delay in ms
; result: none
; SSTACK: 8 bytes
;         X, Y, and D are preserved 
DELAY_MS_BL		EQU	*
			DELAY_INDUCE				;initiate delay
			DELAY_WAIT_BL				;wait
			RTS					;done
	
;#ISR
;---- 
DELAY_ISR		EQU	*			
			;Clear interrupt flag
			TIM_CLRIF DELAY_TIM, DELAY_OC		;clear interrupt flag		
			;Adjust remaining time
			LDX	DELAY_REM_TIME			;remaining time -> X
			BEQ	DELAY_ISR_1			;delay is over
			DEX					;decrement remaining time
			STX	DELAY_REM_TIME			;update remaining time
			ISTACK_RTI				;done
			;Delay is over 
DELAY_ISR_1		TIM_DIS	DELAY_TIM, DELAY_OC 		;disable timer
			ISTACK_RTI				;done
			
DELAY_CODE_END		EQU	*
DELAY_CODE_END_LIN	EQU	@

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef DELAY_TABS_START_LIN
			ORG 	DELAY_TABS_START, DELAY_TABS_START_LIN
#else
			ORG 	DELAY_TABS_START
#endif	

DELAY_TABS_END		EQU	*
DELAY_TABS_END_LIN	EQU	@
#endif
