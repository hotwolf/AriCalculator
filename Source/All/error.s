;###############################################################################
;# S12CBase - ERROR - Error Handler                                            #
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
;###############################################################################
;# Required Modules:                                                           #
;#    PRINT  - SCI output routines                                             #
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
ERROR_LEVEL_INFO	EQU	(ERROR_STRINGTAB_INFO-ERROR_STRINGTAB)>>1
ERROR_LEVEL_WARNING	EQU	(ERROR_STRINGTAB_WARNING-ERROR_STRINGTAB)>>1
ERROR_LEVEL_ERROR	EQU	(ERROR_STRINGTAB_ERROR-ERROR_STRINGTAB)>>1
ERROR_LEVEL_FATAL	EQU	(ERROR_STRINGTAB_FATAL-ERROR_STRINGTAB)>>1

;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef ERROR_VARS_START_LIN
			ORG 	ERROR_VARS_START, ERROR_VARS_START_LIN
#else
			ORG 	ERROR_VARS_START
#endif	

ERROR_AUTO_LOC1		EQU	* 		;1st auto-place location
			ALIGN	1
	
ERROR_MSG		DS	2 		;Reset message to be displayed

ERROR_AUTO_LOC2		EQU	1		;2nd auto-place location

ERROR_MSG_CHECK		EQU	((ERROR_VARS_START&1)*ERROR_AUTO_LOC1)+((~ERROR_VARS_START_LOC1&1)*ERROR_AUTO_LOC2)

			UNALIGN	(~ERROR_VARS_START_LOC1&1)

ERROR_VARS_END		EQU	*
ERROR_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	ERROR_INIT, 0
#emac
	
;#Print error message
; args:   Y: pointer to the error message
; SSTACK: 18 bytes
;         X, Y, and D are preserved 
#macro	ERROR_PRINT, 0
			SSTACK_JOBSR	ERROR_PRINT
#emac

;#Perform a reset due to a fatal error
;# Args: message pointer	
#macro	ERROR_RESTART, 1
			BGND
			LDD	#\1
			JOB	ERROR_RESTART
#emac
	
;Error Message Definition
#macro	ERROR_MSG, 2
			DB	\1
			FCS	\2
#emac
	
#emac
	
;#Print error message
; args:   Y: pointer to the error message
; SSTACK: 18 bytes
;         X, Y, and D are preserved 
#macro	ERROR_PRINT, 0
			SSTACK_JOBSR	ERROR_PRINT
#emac

;#Perform a reset due to a fatal error
;# Args: message pointer	
#macro	ERROR_RESTART, 1
			BGND
			LDD	#\1
			JOB	ERROR_RESTART
#emac
	
;Error Message Definition
#macro	ERROR_MSG, 2
			DB	\1
			FCS	\2
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef ERROR_CODE_START_LIN
			ORG 	ERROR_CODE_START, ERROR_CODE_START_LIN
#else
			ORG 	ERROR_CODE_START
#endif

;#COP reset entry point
ERROR_COP_RESET_ENTRY	EQU	*
			;COP or fatal error
			LDD	ERROR_MSG 		;check for valid error message
			TFR	D, Y			;calculate checksum
			ABA
			COMA
			CMPA	ERROR_MSG_CHECK		;compare checksum
#ifdef	ERROR_SINGLE_VECTOR
			BNE	ERROR_DEF_RESET_ENTRY
#else
			BNE	ERROR_COP_RESET_ENTRY_1
#endif
			LEAX	1,Y 			;check if error message has a valid format
			PRINT_STRCNT
			CMPA	#$FF
 #ifdef	ERROR_SINGLE_VECTOR
			BEQ	ERROR_DEF_RESET_ENTRY
#else
			BNE	ERROR_COP_RESET_ENTRY_2
ERROR_COP_RESET_ENTRY_1	LDY	ERROR_MSG_COP
#endif
			;Print ettor message
ERROR_COP_RESET_ENTRY_2	JOB	ERROR_DEF_RESET_ENTRY_1

;#Default reset entry point
ERROR_DEF_RESET_ENTRY	EQU	*
			;No error
			PRINT_LINE_BREAK_BL 		;print line break sequence (SSTACK:11 bytes)
			LDX	#ERROR_WELCOME_STRING	;print welcome message
			PRINT_STR_BL 			;print string (SSTACK: 13 bytes)
			;Wait for string to be printed before continuing
ERROR_DEF_RESET_ENTRY_1	PRINT_WAIT
			JOB	START_OF_CODE

;#Print error message
; args:   Y: pointer to the error message
; SSTACK: 18 bytes
;         X, Y, and D are preserved 
ERROR_PRINT		EQU	*
			;Save registers 
			SSTACK_PSHYXB			;save registers

			;Print error level 
			LDAB	0,Y 			;read error level
			CMPB	#((ERROR_STRINGTAB_END-ERROR_STRINGTAB)>>1) ;check level
			BHS	ERROR_PRINT_1 		;invalid error level
			LDX	#ERROR_STRINGTAB
			LSLB
			LDX	B,X
			PRINT_LINE_BREAK_BL 		;print line break sequence (SSTACK:11 bytes)
			PRINT_STR_BL 			;print string (SSTACK: 13 bytes)
	
			;Print error message
                        LEAX	1,Y
			PRINT_STRCNT 			;chack if error message has a valid format
			CMPA	#$FF
			BEQ	ERROR_PRINT_1 		;message too long (probably not terminated)	
			PRINT_STR_BL 			;print string (SSTACK:13 bytes)

			;Print error message
 			LDAB	#"!"	   		;print exclamation mark
			PRINT_CHAR_BL 			;print character (SSTACK:8 bytes)
			
			;Restore registers 
			SSTACK_PULBXY_RTS		;restore registers abd return

			;Throw a fatal error
ERROR_PRINT_1		ERROR_RESTART	ERROR_MSG_UNKNOWN		
	
;#Perform a reset due to a fatal error
;# Args: D: message pointer	
ERROR_RESTART		EQU	*
			STD	ERROR_MSG 	;save error message
			ABA			;calculate checksum
			COMA	
			STAA	ERROR_MSG_CHECK	;save checksum
			COP_RESET

;#Trigger a fatal error if a reset accurs
ERROR_ISR		EQU	*
			LDD	#ERROR_MSG_UEXPIRQ	;Unexpected interrupt
			JOB	ERROR_RESTART

ERROR_CODE_END		EQU	*	
ERROR_CODE_END_LIN	EQU	@	

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef ERROR_TABS_START_LIN
			ORG 	ERROR_TABS_START, ERROR_TABS_START_LIN
#else
			ORG 	ERROR_TABS_START
#endif	

;#Error strings
ERROR_STRING_INFO	FCS	"Info! "
ERROR_STRING_WARNING	FCS	"Warning! "
ERROR_STRING_ERROR	FCS	"Error! "
ERROR_STRING_FATAL	FCS	"Fatal Error! "

;#Error string table
ERROR_STRINGTAB		EQU	*
ERROR_STRINGTAB_INFO	DW	ERROR_STRING_INFO
ERROR_STRINGTAB_WARNING	DW	ERROR_STRING_WARNING
ERROR_STRINGTAB_ERROR	DW	ERROR_STRING_ERROR
ERROR_STRINGTAB_FATAL	DW	ERROR_STRING_FATAL
ERROR_STRINGTAB_END	EQU	*

;#Welcome strings
#ifdef	MAIN_WELCOME_STRING
ERROR_WELCOME_STRING	EQU	MAIN_WELCOME_STRING
#else
ERROR_WELCOME_STRING	FCS	"Hello!"
#endif

;#Error messages
ERROR_MSG_COP		ERROR_MSG	ERROR_LEVEL_FATAL, "Watchdog timeout"
ERROR_MSG_UEXPIRQ	ERROR_MSG	ERROR_LEVEL_FATAL, "Unexpected interrupt"
	
ERROR_TABS_END		EQU	*
ERROR_TABS_END_LIN	EQU	@
