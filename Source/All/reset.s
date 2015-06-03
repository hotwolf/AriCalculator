#ifndef RESET_COMPILED
#define	RESET_COMPILED
;###############################################################################
;# S12CBase - RESET - Reset Handler                                            #
;###############################################################################
;#    Copyright 2010-2015 Dirk Heisswolf                                       #
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
;#    This module detects the cause of the previous system reset and prints a  #
;#    status message over the SCI interface.                                   #
;#                                                                             #
;#    The reset handler also provides routines for triggering system resets    #
;#    from software.                                                           #
;###############################################################################
;# Version History:                                                            #
;#    April 4, 2010                                                            #
;#      - Initial release                                                      #
;#    May 30, 2010                                                             #
;#      - Changed "Initialization failure" error to "Unknown cause" error      #
;#    June 8, 2010                                                             #
;#      - Changed checksum for error message                                   #
;#      - Fixed COP error handling                                             #
;#    July 2, 2010                                                             #
;#      - compined error messages "Unknown cause" and "Unknown error" to       #
;#        "Unknown problem"                                                    #
;#      - changed error codes                                                  #
;#    June 29, 2012                                                            #
;#      - Added support for linear PC                                          #
;#      - Added option to only use one shared reset vector                     #
;#    November 16, 2012                                                        #
;#      - Total redo, now called reset handler and only supporting fatal       #
;#  	  errors                                                               #
;#    June 20, 2013                                                            #
;#      - Added macros "RESET_RESTART" and "RESET_RESTART_NO_MSG"              #
;#    January 15, 2015                                                         #
;#      - Changed configuration options                                        #
;###############################################################################
;# Required Modules:                                                           #
;#    REGDEF - Register definitions                                            #
;###############################################################################
;# Error Detection:                                                            #
;# +-------------------------+-------+-------+---------+---------------------+ #
;# |                         |       | P L I |         |                     | #
;# |                         |       | O V L |         |                     | #
;# |                         | Reset | R R A | Message |                     | #
;# | Cause                   | Vector| F F F | Pointer | Display             | #
;# +-------------------------+-------+-------+---------+---------------------+ #
;# | Power-On Reset          | $FFFE | 1 0 0 |  $0000  | Welcome message     | #
;# +-------------------------+-------+-------+---------+---------------------+ #
;# | External Pin Reset      | $FFFE | 0 0 0 |  $0000  | Welcome message     | #
;# +-------------------------+-------+-------+---------+---------------------+ #
;# | Low Voltage Reset       | $FFFE | - 1 - |    -    | Error (Low voltage) | #
;# +-------------------------+-------+-------+---------+---------------------+ #
;# | Illegal Address Reset   | $FFFE |  -0 1 |	  -    | Error (Code fail)   | #
;# +-------------------------+-------+-------+---------+---------------------+ #
;# | Clock Monitor Reset     | $FFFC | - - - | CLK Msg | Error (Clock fail)  | #
;# +-------------------------+-------+-------+---------+---------------------+ #
;# | COP Reset               | $FFFA | - - - | COP Msg | Error (Inresponsive)| #
;# +-------------------------+-------+-------+---------+---------------------+ #
;# | Fatal Application Error | $FFFA | - - - |  Valid  | Error (Application) | #
;# +-------------------------+-------+-------+---------+---------------------+ #
;###############################################################################
	
;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Replace system resets by BGND instructions
;RESET_DEBUG		EQU	1 

;Monitor low voltage reset
#ifndef	RESET_LVR_CHECK_ON
#ifndef	RESET_LVR_CHECK_OFF
#ifdef LVRF
RESET_LVR_CHECK_ON	EQU	1 		;enable LVR check if LVRF flag exists
#else
RESET_LVR_CHECK_OFF	EQU	1 		;disable LVR check if LVRF flag doesn't exist
#endif
#endif
#endif

;Monitor illegal address reset
#ifndef	RESET_IAR_CHECK_ON
#ifndef	RESET_IAR_CHECK_OFF
#ifdef ILAF
RESET_IAR_CHECK_ON	EQU	1 		;enable IAR check if ILAF flag exists
#else
RESET_LVR_CHECK_OFF	EQU	1 		;disable IAR check if ILAF flag doesn't exist
#endif
#endif
#endif

;Maximum error message length
#ifndef			RESET_MSG_LENGTH
RESET_MSG_LENGTH 	EQU	64
#endif
		
;###############################################################################
;# Constants                                                                   #
;###############################################################################

;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef RESET_VARS_START_LIN
			ORG 	RESET_VARS_START, RESET_VARS_START_LIN
#else
			ORG 	RESET_VARS_START
#endif	
			;ALIGN	1
RESET_MSG_REQ		DS	2 		;requested error message
RESET_MSG_PTR		DS	2 		;validated error message
	
RESET_VARS_END		EQU	*
RESET_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	RESET_INIT, 0
			;Capture and clear CRG/CPMU flags
#ifdef	CRGFLG
			LDAA	CRGFLG 			;capture flags
			MOVB	#$FF, CRGFLG		;clear flags
#else
#ifdef	CPMUFLG
			LDAA	CPMUFLG			;capture flags;
			MOVB	#$FF, CPMUFLG		;clear flags
#endif
#endif
#ifdef	RESET_LVR_CHECK_ON
			;Check for low voltage reset (flags in A)
			LDY	#RESET_MSG_POWFAIL
			BITA	#LVRF
			BNE	RESET_INIT_4 		;low voltage reset detected
#endif
#ifdef	RESET_IAR_CHECK_ON
			;Check for illegal address reset (flags in A)
			LDY	#RESET_MSG_ILLADDR
			BITA	#ILAF
			BNE	RESET_INIT_4 		;illegal address reset detected
#endif
			;Check for power-on or external pin reset (flags in A)
			LDY	RESET_MSG_PTR
			BEQ	RESET_INIT_5 		;power-on or external pin reset detected
			;Check if error message is valid (string in Y)
			CLRA	  			;initialize C0
			LDX	#((RESET_MSG_LENGTH-1)<<8);initialize char limit and C1
			;Validate next character (string pointer in Y, char limit:C1 in X, C0 in A)
			LDAB	1,Y+ 			;next char -> B
			BMI	RESET_INIT_2		;string termination found
			;Validate next character (string pointer in Y, char limit:C1 in X, C0:char in D)
RESET_INIT_1		CMPB	#$20		;" "	;check if character is printable
			BLO	RESET_INIT_3 		;invalid message
			CMPB	#$7E		;"~"    ;check if character is printable
			BHI	RESET_INIT_3		;invalid message
			;Update Fletcher's checksum (string in pointer Y, char limit:C1 in X, C0:char in D)
			ABA				;new C0 -> A
			TAB				;new C0 -> B
			TFR	X, A			;old C1 -> A
			ABA				;new C1 -> A
			EXG	A, B			;C0:C1  -> D	
			EXG	X, D			;C0:C1  -> X, char limit -> A 
			TFR	X, B			;char limit:C1 -> D 
			;Check character limit ((string pointer in Y, C0:C1 in X, char limit:C1 in D)
			DBEQ	A, RESET_INIT_3		;invalid message
			EXG	X, D			;C0:C1  -> D, char limit:C1 ->  X
			LDAB	1,Y+ 			;next char -> B
			BPL	RESET_INIT_1		;string termination found
			;String termination found (string pointer in Y, char limit:C1 in X, C0:char in D)		
RESET_INIT_2		;ANDB	#$7F 			;ignore termination			
			;;Validate next character (string pointer in Y, char limit:C1 in X, C0:char in D)
			;CMPB	#$20		;" "	;check if character is printable
			;BLO	RESET_INIT_3 		;invalid message
			;CMPB	#$7E		;"~"    ;check if character is printable
			;BHI	RESET_INIT_3		;invalid message			
			CMPB	#$A0		;" "	;check if character is printable
			BLO	RESET_INIT_3 		;invalid message
			CMPB	#$FE		;"~"    ;check if character is printable
			BHI	RESET_INIT_3		;invalid message			
			;Update Fletcher's checksum (string in pointer Y, char limit:C1 in X, C0:char in D)
			ABA				;new C0 -> A
			TAB				;new C0 -> B
			TFR	X, A			;old C1 -> A
			ABA				;new C1 -> A
			;Check Fletcher's checksum (string in pointer Y, C1 in A, C0 in B)
			CMPA	1,Y+ 			;check C1 
			BNE	RESET_INIT_3		;invalid message
			CMPB	1,Y+ 			;check C1 
			BEQ	RESET_INIT_5		;valid message
			;Invalid error message
RESET_INIT_3		LDY	#RESET_MSG_UNKNOWN 	;unknown error
			;Update error message
RESET_INIT_4		STY	RESET_MSG_PTR		;set error message
			;Done
RESET_INIT_5		EQU	*
#emac

;Branch on error
; args:   1: branch address 
; result: Y: error message pointer
; SSTACK: none
;         X, and D are preserved 
#macro	RESET_BR_ERR, 1
	LDY	RESET_MSG_PTR
	BNE	\1
#emac
	
;Branch on no error
; args:   1: branch address 
; result: Y: error message pointer
; SSTACK: none
;         X, and D are preserved 
#macro	RESET_BR_NOERR, 1
	LDY	RESET_MSG_PTR
	BEQ	\1
#emac
	
;#Perform a reset due to a fatal error (immediate error code)
; args: 1: message pointer	
;          System is reset and initialized
#macro	RESET_FATAL, 1
			LDX	#\1
			JOB	RESET_FATAL_X
#emac

;#Perform a reset due to a fatal error (error code in X)
; args: X: message pointer	
;          System is reset and initialized
#macro	RESET_FATAL_X, 0
			JOB	RESET_FATAL_X
#emac

;#Error message (w/ Fletcher-16 checksum)
#macro	RESET_MSG, 1
RESET_MSG		FCS	\1
			FLET16	RESET_MSG, *-1	
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef RESET_CODE_START_LIN
			ORG 	RESET_CODE_START, RESET_CODE_START_LIN
#else
			ORG 	RESET_CODE_START
#endif

;#Reset entry points
;--------------------
;Power-on and external reset
RESET_EXT_ENTRY		EQU	*
			MOVW	#RESET_MSG_COP, RESET_MSG_REQ 		;set default request (COP)
			MOVW	#$0000, RESET_MSG_PTR 			;check reset flags 
			JOB	START_OF_CODE
;#Clock monitor reset
RESET_CM_ENTRY		MOVW	#RESET_MSG_COP, RESET_MSG_REQ 		;set default request (COP)
			MOVW	#RESET_MSG_CLKFAIL, RESET_MSG_PTR 	;set clock failure message
			JOB	START_OF_CODE
;COP and user reset
RESET_COP_ENTRY		EQU	START_OF_CODE
			MOVW	RESET_MSG_REQ, RESET_MSG_PTR 		;preserve error message
			MOVW	#RESET_MSG_COP, RESET_MSG_REQ 		;set default request (COP)
			JOB	START_OF_CODE
				
;#Reset trigger
;--------------
;#Perform a reset due to a fatal error
; args: X: message pointer	
;          System is reset and initialized
RESET_FATAL_X		EQU	*
			STX	RESET_MSG_REQ
			;Trigger COP
#ifdef RESET_DEBUG
RESET_FATAL_X_1		BGND		
#else	
RESET_FATAL_X_1		COP_RESET
#endif

RESET_CODE_END		EQU	*	
RESET_CODE_END_LIN	EQU	@	

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef RESET_TABS_START_LIN
			ORG 	RESET_TABS_START, RESET_TABS_START_LIN
#else
			ORG 	RESET_TABS_START
#endif	

;#Error messages
RESET_MSG_COP		RESET_MSG	"System inresponsive"
RESET_MSG_CLKFAIL	RESET_MSG	"Clock failure"
#ifdef RESET_LVR_CHECK_ON	
RESET_MSG_POWFAIL	RESET_MSG	"Power loss"
#endif
#ifdef	RESET_IAR_CHECK_ON
RESET_MSG_ILLADDR	RESET_MSG	"Code runaway"
#endif
RESET_MSG_UNKNOWN	RESET_MSG	"Unknown cause"
	
RESET_TABS_END		EQU	*
RESET_TABS_END_LIN	EQU	@
#endif
