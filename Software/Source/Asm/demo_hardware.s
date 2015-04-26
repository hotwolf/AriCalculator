;###############################################################################
;# AriCalculator - Demo                                                        #
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
;#    This demo application transmits each byte it receives via the SCI.       #
;#                                                                             #
;# Usage:                                                                      #
;#    1. Upload S-Record                                                       #
;#    2. Execute code at address "START_OF_CODE"                               #
;###############################################################################
;# Version History:                                                            #
;#    August 18, 2014                                                          #
;#      - Initial release                                                      #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;# LRE or flash
#ifndef DEMO_LRE
#ifndef DEMO_FLASH
DEMO_LRE		EQU	1 		;default is LRE
#endif
#endif

;# Memory map:
MMAP_S12G240		EQU	1 		;S12G240
#ifdef DEMO_LRE
MMAP_RAM		EQU	1 		;use RAM memory map
#else
MMAP_FLASH		EQU	1 		;use FLASH memory map
#endif

;# Vector table
VECTAB_DEBUG		EQU	1 		;multiple dummy ISRs
		
;# COP debug
COP_DEBUG		EQU     1		;disable COP	

; ISTACK debug
#ifdef DEMO_LRE
ISTACK_DEBUG		EQU     1		;don't execute WAI
#endif

;###############################################################################
;# Resource mapping                                                            #
;###############################################################################
			ORG	MMAP_RAM_START, MMAP_RAM_START 
#ifdef DEMO_LRE
;Code
DEMO_CODE_START		EQU	*
DEMO_CODE_START_LIN	EQU	@
			ORG	DEMO_CODE_END, 	DEMO_CODE_END_LIN

;Tables
DEMO_TABS_START		EQU	*
DEMO_TABS_START_LIN	EQU	@
			ORG	DEMO_TABS_END, 	DEMO_TABS_END_LIN
#endif
	
;Variables
DEMO_VARS_START		EQU	*
DEMO_VARS_START_LIN	EQU	@
			ORG	DEMO_VARS_END, 	DEMO_VARS_END_LIN

#ifndef DEMO_LRE
			ORG	$E000, $3E000
;Code
DEMO_CODE_START		EQU	*
DEMO_CODE_START_LIN	EQU	@
			ORG	DEMO_CODE_END, 	DEMO_CODE_END_LIN

;Tables
DEMO_TABS_START		EQU	*
DEMO_TABS_START_LIN	EQU	@
			ORG	DEMO_TABS_END, 	DEMO_TABS_END_LIN

			ALIGN 	7, $FF ;align to D-Bug12XZ programming granularity
#endif

;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef DEMO_VARS_START_LIN
			ORG 	DEMO_VARS_START, DEMO_VARS_START_LIN
#else
			ORG 	DEMO_VARS_START
#endif	

DEMO_KEY_CODE		DS	1 	;pushed key stroke
DEMO_PAGE   		DS	1	;current display page
DEMO_COL    		DS	1	;current key pad ccolumn
DEMO_CUR_KEY 		DS	1	;current key code
	
BASE_VARS_START		EQU	*
BASE_VARS_START_LIN	EQU	@
			ORG	BASE_VARS_END, 	BASE_VARS_END_LIN

DEMO_VARS_END		EQU	*
DEMO_VARS_END_LIN	EQU	@
	
;###############################################################################
;# Macros                                                                      #
;###############################################################################
;;Break handler
;#macro	SCI_BREAK_ACTION, 0
;			LED_BUSY_ON 
;#emac
;	
;;Suspend handler
;#macro	SCI_SUSPEND_ACTION, 0
;			LED_BUSY_OFF
;#emac

;VBAT -> busy LED
#macro	VMON_VBAT_LVACTION, 0
			LED_BUSY_OFF
#emac
#macro	VMON_VBAT_HVACTION, 0
			LED_BUSY_ON
#emac

;VUSB -> error LED
#macro	VMON_VUSB_LVACTION, 0
			SCI_DISABLE
			LED_COMERR_OFF
#emac
#macro	VMON_VUSB_HVACTION, 0
			SCI_ENABLE
			LED_COMERR_ON
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef DEMO_CODE_START_LIN
			ORG 	DEMO_CODE_START, DEMO_CODE_START_LIN
#else
			ORG 	DEMO_CODE_START
#endif	

;Application code
START_OF_CODE		EQU	*		;Start of code
			;Initialization
			BASE_INIT

DEMO_KEY_STROKE_LOOP	EQU	*
			;Wait for key stroke
			KEYS_GET_BL 		;key code -> A
			STAA	DEMO_KEY_CODE

			;Print key code (key code in A)
			LDX	#DEMO_PRINT_HEADER 		;print header
			STRING_PRINT_BL
			LDY	#$0000 				;reverse digits
			TFR	A, X
			LDAB	#16 				;set base
			NUM_REVERSE
			NUM_REVPRINT_BL
			NUM_CLEAN_REVERSE
	
			;Display keystroke
			;Clear page 7
			LDAB #7					;switch to page 1
			DEMO_SWITCH_PAGE_BL
			DEMO_CLEAR_COLUMNS_IMM_BL 128 		;clear entire page

			;Initialize variables
			CLR	DEMO_PAGE
			MOVB	#$29, DEMO_CUR_KEY

			;Switch to next page 
DEMO_PAGE_LOOP		LDAB	DEMO_PAGE 			;increment page count
    	                CMPB	#7				;check is key search is complete
			BHS	DEMO_KEY_STROKE_LOOP		;wait for next key stroke
			;INCB
			CLR	DEMO_COL			;clear column counter

			;Left margin
			DEMO_CLEAR_COLUMNS_IMM_BL 31+4 		;draw left margin
	
			;Draw next box
DEMO_COL_LOOP		LDAA	DEMO_CUR_KEY
			CMPA	DEMO_KEY_CODE
			BEQ	DEMO_COL_LOOP_1 		;draw black box
			JOBSR	DEMO_WHITE_BOX
			JOB	DEMO_COL_LOOP_2
DEMO_COL_LOOP_1 	JOBSR	DEMO_BLACK_BOX
DEMO_COL_LOOP_2		INC	DEMO_COL
			DEC	DEMO_CUR_KEY

			;Draw space
			LDAA	#5
			CMPA	DEMO_PAGE
			BHS	DEMO_COL_LOOP_5			;rows E-G
			;Rows A-D (5 in A)
			CMPA	DEMO_COL
			BLO	DEMO_COL_LOOP_3 		;col 5
			;Rows A-D, cols 0-4
			DEMO_CLEAR_COLUMNS_IMM_BL 9 		;draw wide space
			JOB	DEMO_COL_LOOP
			;Rows A-D, col 5
DEMO_COL_LOOP_3		DEC	DEMO_CUR_KEY 			;skip key
DEMO_COL_LOOP_4		DEMO_CLEAR_COLUMNS_IMM_BL 31 		;draw left margin
			JOB	DEMO_PAGE_LOOP
			;Rows E-G (5 in A)
DEMO_COL_LOOP_5		CMPA	DEMO_COL
			BLO	DEMO_COL_LOOP_4 		;draw left margin			
			;Rows E-G, cols 0-5
			DEMO_CLEAR_COLUMNS_IMM_BL 6 		;draw narrow space
			JOB	DEMO_COL_LOOP

;#Switch page (blocking)
; args:   B: target page
; result: none (data input active)
; SSTACK: 13 bytes
;         D is preserved 
DEMO_SWITCH_PAGE_BL	EQU	*
			;Save registers
			PSHB							;push accu B onto the SSTACK			
			;Switch to command input
			DISP_CMD_INPUT_BL					;(SSTACK: 10 bytes)
			;Set page address
			ORAB	#$B0
			DISP_TX_BL	 					;(SSTACK: 7 bytes)
			;Switch to first column
			DISP_TX_IMM_BL	$10 					;(SSTACK: 7 bytes)
			DISP_TX_IMM_BL	$04	 				;(SSTACK: 7 bytes)		
			;Switch to data input
			DISP_DATA_INPUT_BL					;(SSTACK: 10 bytes)
			;Restore registers
			SSTACK_PREPULL	3
			PULB							;pull accu B from the SSTACK
			;Done
			RTS
;Switch page macro
#macro	DEMO_SWITCH_PAGE_BL, 0
			SSTACK_JOBSR	DEMO_SWITCH_PAGE_BL, 13
#emac

;#Clear columns (blocking)
; args:   A: number of columns (data input active)
; result: none (data input active)
; SSTACK: 9 bytes
;         X, Y, and D are preserved 
DEMO_CLEAR_COLUMNS_BL	EQU	*
			;Transmit sequence 
			DISP_TX_IMM_BL	DISP_ESC_START 				;(SSTACK: 7 bytes)
			TAB
			DISP_TX_BL	 					;(SSTACK: 7 bytes)
			DISP_TX_IMM_BL	$00	 				;(SSTACK: 7 bytes)		
			;Done
			SSTACK_PREPULL	2
			RTS

;Clear columns macros
#macro	DEMO_CLEAR_COLUMNS_BL, 0
			SSTACK_JOBSR	DEMO_CLEAR_COLUMNS_BL, 9
#emac
#macro	DEMO_CLEAR_COLUMNS_IMM_BL, 1
			LDAA	#\1
			SSTACK_JOBSR	DEMO_CLEAR_COLUMNS_BL, 9
#emac

;#Draw a white box
; args:   none
; result: none
; SSTACK: 10 bytes
;         D is preserved 
DEMO_WHITE_BOX		DISP_STREAM_FROM_TO_BL	DEMO_WHITE_BOX_START, DEMO_WHITE_BOX_END
			RTS

;#Draw a black box
; args:   none
; result: none
; SSTACK: 10 bytes
;         D is preserved 
DEMO_BLACK_BOX		DISP_STREAM_FROM_TO_BL	DEMO_BLACK_BOX_START, DEMO_BLACK_BOX_END
			RTS
	
BASE_CODE_START		EQU	*
BASE_CODE_START_LIN	EQU	@
			ORG	BASE_CODE_END, 	BASE_CODE_END_LIN

DEMO_CODE_END		EQU	*
DEMO_CODE_END_LIN	EQU	@

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef DEMO_TABS_START_LIN
			ORG 	DEMO_TABS_START, DEMO_TABS_START_LIN
#else
			ORG 	DEMO_TABS_START
#endif	

DEMO_WHITE_BOX_START	DB	$7E DISP_ESC_START $04 $42 $7E
DEMO_WHITE_BOX_END	EQU	*

DEMO_BLACK_BOX_START	DB	DISP_ESC_START $06 $7E
DEMO_BLACK_BOX_END	EQU	*
	
DEMO_PRINT_HEADER	STRING_NL_NONTERM
			FCS	"Key code: "
	
BASE_TABS_START		EQU	*
BASE_TABS_START_LIN	EQU	@
			ORG	BASE_TABS_END, 	BASE_TABS_END_LIN

DEMO_TABS_END		EQU	*
DEMO_TABS_END_LIN	EQU	@

;###############################################################################
;# Includes                                                                    #
;###############################################################################
#include ./base_AriCalculator.s	   									;I/O setup

