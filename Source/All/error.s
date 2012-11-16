;###############################################################################
;# S12CBase - RESET - Reset Handler                                            #
;###############################################################################
;#    Copyright 2010-2012 Dirk Heisswolf                                       #
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
;###############################################################################
;# Required Modules:                                                           #
;#    PRSTR  - String printing routines                                        #
;#    CLOCK  - Clock driver                                                    #
;#    COP    - Watchdog handler                                                #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Single reset vector (D-Bug12X bootloader)
;ERROR_SINGLE_VECTOR	EQU	1 

;Welcome message
;MAIN_WELCOME_STRING	FCS	"Hello, this is S12CBase!"
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;Severity levels
RESET_LEVEL_INFO	EQU	(RESET_STRINGTAB_INFO-RESET_STRINGTAB)>>1
RESET_LEVEL_WARNING	EQU	(RESET_STRINGTAB_WARNING-RESET_STRINGTAB)>>1
RESET_LEVEL_ERROR	EQU	(RESET_STRINGTAB_ERROR-RESET_STRINGTAB)>>1
RESET_LEVEL_FATAL	EQU	(RESET_STRINGTAB_FATAL-RESET_STRINGTAB)>>1

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
	
RESET_MSG		DS	2 		;Reset message to be displayed

RESET_AUTO_LOC2		EQU	1		;2nd auto-place location

RESET_MSG_CHECK		EQU	((RESET_VARS_START&1)*RESET_AUTO_LOC1)+((~RESET_VARS_START_LOC1&1)*RESET_AUTO_LOC2)

			UNALIGN	(~RESET_VARS_START_LOC1&1)

RESET_VARS_END		EQU	*
RESET_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	RESET_INIT, 0
#emac
	
;#Print error message
; args:   Y: pointer to the error message
; SSTACK: 18 bytes
;         X, Y, and D are preserved 
#macro	RESET_PRINT, 0
			SSTACK_JOBSR	RESET_PRINT
#emac

;#Perform a reset due to a fatal error
;# Args: message pointer	
#macro	RESET_RESTART, 1
			BGND
			LDD	#\1
			JOB	RESET_RESTART
#emac
	
;Error Message Definition
#macro	RESET_MSG, 2
			DB	\1
			FCS	\2
#emac
	
#emac
	
;#Print error message
; args:   Y: pointer to the error message
; SSTACK: 18 bytes
;         X, Y, and D are preserved 
#macro	RESET_PRINT, 0
			SSTACK_JOBSR	RESET_PRINT
#emac

;#Perform a reset due to a fatal error
;# Args: message pointer	
#macro	RESET_RESTART, 1
			BGND
			LDD	#\1
			JOB	RESET_RESTART
#emac
	
;Error Message Definition
#macro	RESET_MSG, 2
			DB	\1
			FCS	\2
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
RESET_COP_ENTRY		EQU	*



	





	
			;COP or fatal error
			LDD	RESET_MSG 		;check for valid error message
			TFR	D, Y			;calculate checksum
			ABA
			COMA
			CMPA	RESET_MSG_CHECK		;compare checksum
#ifdef	RESET_SINGLE_VECTOR
			BNE	RESET_DEF_RESET_ENTRY
#else
			BNE	RESET_COP_RESET_ENTRY_1
#endif
			LEAX	1,Y 			;check if error message has a valid format
			PRINT_STRCNT
			CMPA	#$FF
 #ifdef	RESET_SINGLE_VECTOR
			BEQ	RESET_DEF_RESET_ENTRY
#else
			BNE	RESET_COP_RESET_ENTRY_2
RESET_COP_RESET_ENTRY_1	LDY	RESET_MSG_COP
#endif
			;Print ettor message
RESET_COP_RESET_ENTRY_2	JOB	RESET_DEF_RESET_ENTRY_1

;#Default reset entry point
RESET_DEF_RESET_ENTRY	EQU	*
			;No error
			PRINT_LINE_BREAK_BL 		;print line break sequence (SSTACK:11 bytes)
			LDX	#RESET_WELCOME_STRING	;print welcome message
			PRINT_STR_BL 			;print string (SSTACK: 13 bytes)
			;Wait for string to be printed before continuing
RESET_DEF_RESET_ENTRY_1	PRINT_WAIT
			JOB	START_OF_CODE

;#Print error message
; args:   Y: pointer to the error message
; SSTACK: 18 bytes
;         X, Y, and D are preserved 
RESET_PRINT		EQU	*
			;Save registers 
			SSTACK_PSHYXB			;save registers

			;Print error level 
			LDAB	0,Y 			;read error level
			CMPB	#((RESET_STRINGTAB_END-RESET_STRINGTAB)>>1) ;check level
			BHS	RESET_PRINT_1 		;invalid error level
			LDX	#RESET_STRINGTAB
			LSLB
			LDX	B,X
			PRINT_LINE_BREAK_BL 		;print line break sequence (SSTACK:11 bytes)
			PRINT_STR_BL 			;print string (SSTACK: 13 bytes)
	
			;Print error message
                        LEAX	1,Y
			PRINT_STRCNT 			;chack if error message has a valid format
			CMPA	#$FF
			BEQ	RESET_PRINT_1 		;message too long (probably not terminated)	
			PRINT_STR_BL 			;print string (SSTACK:13 bytes)

			;Print error message
 			LDAB	#"!"	   		;print exclamation mark
			PRINT_CHAR_BL 			;print character (SSTACK:8 bytes)
			
			;Restore registers 
			SSTACK_PULBXY_RTS		;restore registers abd return

			;Throw a fatal error
RESET_PRINT_1		RESET_RESTART	RESET_MSG_UNKNOWN		
	
;#Perform a reset due to a fatal error
;# Args: D: message pointer	
RESET_RESTART		EQU	*
			STD	RESET_MSG 	;save error message
			ABA			;calculate checksum
			COMA	
			STAA	RESET_MSG_CHECK	;save checksum
			COP_RESET

;#Trigger a fatal error if a reset accurs
RESET_ISR		EQU	*
			LDD	#RESET_MSG_UEXPIRQ	;Unexpected interrupt
			JOB	RESET_RESTART

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

;#Error strings
RESET_STRING_INFO	FCS	"Info! "
RESET_STRING_WARNING	FCS	"Warning! "
RESET_STRING_ERROR	FCS	"Error! "
RESET_STRING_FATAL	FCS	"Fatal Error! "

;#Error string table
RESET_STRINGTAB		EQU	*
RESET_STRINGTAB_INFO	DW	RESET_STRING_INFO
RESET_STRINGTAB_WARNING	DW	RESET_STRING_WARNING
RESET_STRINGTAB_ERROR	DW	RESET_STRING_ERROR
RESET_STRINGTAB_FATAL	DW	RESET_STRING_FATAL
RESET_STRINGTAB_END	EQU	*

;#Welcome strings
#ifdef	MAIN_WELCOME_STRING
RESET_WELCOME_STRING	EQU	MAIN_WELCOME_STRING
#else
RESET_WELCOME_STRING	FCS	"Hello!"
#endif

;#Error messages
RESET_MSG_COP		RESET_MSG	RESET_LEVEL_FATAL, "Watchdog timeout"
RESET_MSG_UEXPIRQ	RESET_MSG	RESET_LEVEL_FATAL, "Unexpected interrupt"
	
RESET_TABS_END		EQU	*
RESET_TABS_END_LIN	EQU	@
