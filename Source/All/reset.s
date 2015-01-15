#ifndef RESET
#define	RESET
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

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Error detection
;---------------
;COP detection
#ifndef	RESET_COP_ON
#ifndef	RESET_COP_OFF
RESET_COP_ON		EQU	1 		;default is RESET_COP_ON
#endif
#endif

;Clock failure detection
#ifndef	RESET_CLKFAIL_ON
#ifndef	RESET_CLKFAIL_OFF
RESET_CLKFAIL_ON	EQU	1 		;default is RESET_CLKFAIL_ON
#endif
#endif

;Power failure detection
#ifndef	RESET_POWFAIL_ON
#ifndef	RESET_POWFAIL_OFF
RESET_POWFAIL_ON	EQU	1 		;default is RESET_POWFAIL_ON
#endif
#endif

;Code runaway detection
#ifndef	RESET_CODERUN_ON
#ifndef	RESET_CODERUN_OFF
RESET_CODERUN_OFF	EQU	1 		;default is RESET_CODERUN_OFF
#endif
#endif

;Welcome message
;---------------
;RESET_WELCOME		FCS	"Hello, this is S12CBase!"
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;Flags
RESET_FLG_POR		EQU	$40 		;power on     (PORF)
RESET_FLG_POWFAIL	EQU	$20 		;power loss   (LVRF)
RESET_FLG_CODERUN	EQU	$04 		;code runaway (ILAF)
RESET_FLG_COP		EQU	$02		;watchdog timeout
RESET_FLG_CLKFAIL	EQU	$01		;clock faiure

;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef RESET_VARS_START_LIN
			ORG 	RESET_VARS_START, RESET_VARS_START_LIN
#else
			ORG 	RESET_VARS_START
#endif	

RESET_AUTO_LOC1		EQU	* 		;1st auto-place location
			ALIGN	1
	
RESET_MSG		DS	2 		;error message to be displayed
RESET_MSG_CHKSUM	DS	1		;checksum for the error message
	
RESET_AUTO_LOC2		EQU	*		;2nd auto-place location

;#Flags
RESET_FLGS		EQU	((RESET_AUTO_LOC1&1)*RESET_AUTO_LOC1)+(((~RESET_AUTO_LOC1)&1)*RESET_AUTO_LOC2)
			UNALIGN	((~RESET_AUTO_LOC1)&1)

RESET_VARS_END		EQU	*
RESET_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	RESET_INIT, 0
			LDAA	RESET_FLGS 		;flags -> A
			;Check for power failure (flags in A)
			BITA	#RESET_FLG_POR
			BNE	<RESET_INIT_		 ;print welcome message	
			


	


			;Check for power failure (flags in A)
#ifdef	RESET_POWFAIL_ON
	
			LDY	#RESET_STR_POWFAIL
			BITA	#RESET_FLG_POWFAIL
			BNE	<RESET_INIT_2		 ;print error message
#endif
			;Check for clock failure (flags in A)
#ifdef	RESET_CLKFAIL_ON
			LDY	#RESET_STR_CLKFAIL
			BITA	#RESET_FLG_CLKFAIL
			BNE	<RESET_INIT_2		 ;print error message
#endif
			;Check for code runaway (flags in A)
#ifdef	RESET_CODERUN_ON
			LDY	#RESET_STR_CODERUN
			BITA	#RESET_FLG_CODERUN
			BNE	<RESET_INIT_2		 ;print error message
#endif
			;Check for COP reset (flags in A)
#ifdef	RESET_COP_ON
			BITA	#RESET_FLG_COP
			BEQ	<RESET_INIT_3		 ;print welcome message
#endif
			;Check custom error
			LDX	RESET_MSG
			LDY	#RESET_INIT_1
			JOB	RESET_CALC_CHECKSUM	
RESET_INIT_1		EQU	*
#ifdef	RESET_COP_ON
			;Check if error message is valid (checksum in A, valid/invalid in C)
			LDY	#RESET_STR_COP
			BCC	<RESET_INIT_2		 ;print error message
#else
			BCC	<RESET_INIT_3		 ;print welcome message
#endif
			;Verify checksum (checksum in A)
			CMPA	RESET_MSG_CHKSUM
			BNE	<RESET_INIT_3		 ;print welcome message
			LDY	RESET_MSG
			;BEQ	RESET_INIT_5 		 ;empty message
			BEQ	RESET_INIT_4 		 ;empty message
	
			;Print error message (error message in Y)
RESET_INIT_2		LDX	#RESET_STR_FATAL
			STRING_PRINT_BL
			TFR	Y, X
			JOB	RESET_INIT_4	
			;Print welcome message
RESET_INIT_3		LDX	#RESET_WELCOME
RESET_INIT_4		STRING_PRINT_BL
			;Print exlamation mark and new line
			;LDX	#STRING_STR_EXCLAM_NL
			;STRING_PRINT_BL
			;Remove custom error message
RESET_INIT_5		LDD	$0000
			STD	RESET_MSG
			STAA	RESET_MSG_CHKSUM
			;Wait until message has been transmitted
			SCI_TX_DONE_BL
			;Done 
RESET_INIT_6		EQU	*
#emac
	
;#Perform a reset due to a fatal error (immediate error code)
; args: 1: message pointer	
#macro	RESET_FATAL, 1
			;BGND
			LDX	#\1
			JOB	RESET_FATAL_X
#emac

;#Perform a reset due to a fatal error (error code in X)
; args: X: message pointer	
#macro	RESET_FATAL_X, 0
			;BGND
			JOB	RESET_FATAL_X
#emac

;#Perform a system restart
; args: none
#macro	RESET_RESTART 0
			;BGND
			COP_RESET
#emac
	
;#Perform a system restart without welcome message
; args: none
#macro	RESET_RESTART_NO_MSG 0
			;BGND
			JOB	RESET_RESTART_NO_MSG
#emac
	
;#Calculate the checksum of the custom error message
; args:   X:      error message	
;         Y:      return address	
; result: A:      checksum
;         C-flag: set if message is valid
;         none of the registers are preserved 
#macro	RESET_CALC_CHECKSUM, 1
			LDY	#DONE
			JOB	RESET_CALC_CHECKSUM
DONE			EQU	*
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef RESET_CODE_START_LIN
			ORG 	RESET_CODE_START, RESET_CODE_START_LIN
#else
			ORG 	RESET_CODE_START
#endif

;#COP reset entry point
;----------------------
#ifdef	RESET_COP_ON
RESET_COP_ENTRY		EQU	*
			;Capture COP  
			MOVB	#RESET_FLG_COP, RESET_FLGS	
			JOB	START_OF_CODE
#else
RESET_COP_ENTRY		EQU	RESET_EXT_ENTRY
#endif

;#Clock monitor reset entry point
;--------------------------------
#ifdef	RESET_CLKFAIL_ON
RESET_CM_ENTRY		EQU	*
			;Capture clock failure
			MOVB	#RESET_FLG_CLKFAIL, RESET_FLGS	
			JOB	START_OF_CODE
#else
RESET_CM_ENTRY		EQU	RESET_EXT_ENTRY
#endif
	
;#External reset entry point
;---------------------------
RESET_EXT_ENTRY		EQU	*
			;Capture CRG/CPMU flags
#ifdef	CRGFLG
			MOVB	CRGFLG, RESET_FLGS
#else
#ifdef	CPMUFLG
			MOVB	CPMUFLG, RESET_FLGS
#else
			CLR	RESET_FLGS
#endif
#endif
			JOB	START_OF_CODE

;#Subroutines
;------------

;#Perform a system restart
; args: none
RESET_RESTART		EQU	RESET_FATAL_X_4
	
;#Perform a system restart without welcome message
; args: none
RESET_RESTART_NO_MSG	EQU	*
			LDX	#$0000
			JOB	RESET_FATAL_X_1
	
;#Perform a reset due to a fatal error
; args: X: message pointer	
RESET_FATAL_X		EQU	*
			STX	RESET_MSG
RESET_FATAL_X_1		LDY	RESET_FATAL_X_2

;#Calculate the checksum of the custom error message
; args:   X:      error message	
;         Y:      return address	
; result: A:      checksum
;;        C-flag: set if message is valid
;         none of the registers are preserved 
RESET_CALC_CHECKSUM	EQU	*
			;Initialize checksum generation
			CLRA
			;Check for empty message 
			TBEQ	X, RESET_CALC_checksum_3
	
			;Get next character
RESET_CALC_CHECKSUM_1	LDAB	1,X+
			BMI	RESET_CALC_CHECKSUM_2 	;last charcter reached
			CMPB	#STRING_SYM_SPACE
			BLO	<RESET_CALC_CHECKSUM_4 	;message is invalid
			CMPB	#STRING_SYM_TILDE
			BHI	<RESET_CALC_CHECKSUM_4 	;message is invalid
			ABA
			ROLA
			ADCA	#$00
			JOB	RESET_CALC_CHECKSUM_1
			;Last charcter reached
RESET_CALC_CHECKSUM_2	CMPB	#(STRING_SYM_SPACE|$80)
			BLO	<RESET_CALC_CHECKSUM_4 	;message is invalid
			CMPB	#(STRING_SYM_TILDE|80)
			BHI	<RESET_CALC_CHECKSUM_4 	;message is invalid
			;Message is valid
			ABA
			ROLA
			ADCA	#$00
RESET_CALC_CHECKSUM_3	COMA
			SEC
			JMP	0,Y
			;Message is invalid
RESET_CALC_CHECKSUM_4	CLC
			JMP	0,Y
			
;#Perform a reset due to a fatal error...continued
			;Check if message is valid (checksum in A, valid/invalid in C-flag)  
RESET_FATAL_X_2		BCC	RESET_FATAL_X_4		;clear message
			STAA	RESET_MSG_CHKSUM
			;Trigger COP 	
RESET_FATAL_X_3		COP_RESET
			;Clear message
RESET_FATAL_X_4		CLRA
			CLRB
			STD	RESET_MSG
			STAA	RESET_MSG_CHKSUM
			JOB	RESET_FATAL_X_3 	;trigger COP

;#Trigger a fatal error if a reset accurs
RESET_ISR_FATAL		EQU	*
			RESET_FATAL	RESET_STR_ILLIRQ	

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

;#Welcome string
#ifndef	RESET_WELCOME
RESET_WELCOME       	FCS	"Hello, this is S12CBase"
#endif

;#Error indicator
RESET_STR_FATAL		FCS	"Fatal! "

;#Error messages
#ifdef	RESET_COP_ON
RESET_STR_COP		FCS	"Watchdog timeout"
#endif
#ifdef	RESET_CLKFAIL_ON
RESET_STR_CLKFAIL	FCS	"Clock failure"
#endif
#ifdef	RESET_POWFAIL_ON
RESET_STR_POWFAIL	FCS	"Power loss"
#endif
#ifdef	RESET_CODERUN_ON
RESET_STR_CODERUN	FCS	"Code runaway"
#endif
RESET_STR_ILLIRQ	FCS	"Illegal interrupt"

	
RESET_TABS_END		EQU	*
RESET_TABS_END_LIN	EQU	@
#endif
