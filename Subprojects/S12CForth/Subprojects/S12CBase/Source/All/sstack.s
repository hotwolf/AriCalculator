#ifndef SSTACK_COMPILED
#define SSTACK_COMPILED
;###############################################################################
;# S12CBase - SSTACK - Subroutine Stack Handler                                #
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
;#    Early versions of S12CBase framework used to have separate stacks        #
;#    interrupt handling and subroutine calls. These two stacks have noe been  #
;#    combined to one. However the API of the separate stacks has been kept:   #
;#    => The ISTACK module implements all functions required for interrupt     #
;#       handling.                                                             #
;#    => The SSTACK module implements all functions for subroutine calls and   #
;#       temporary RAM storage.                                                #
;#                                                                             #
;#    All of the stacking functions check the upper and lower boundaries of    #
;#    the stack. Fatal errors are thrown if the stacking space is exceeded.    #
;#                                                                             #
;#    The ISTACK module no longer implements an idle loop. Instead it offers   #
;#    the macro ISTACK_WAIT to build local idle loops for drivers which        #
;#    implement blocking I/O.                                                  #
;###############################################################################
;# Version History:                                                            #
;#    April 4, 2010                                                            #
;#      - Initial release                                                      #
;#    January 8, 2011                                                          #
;#      - Combined ISTACK and SSTACK                                           #
;#    June 29, 2012                                                            #
;#      - Added support for linear PC                                          #
;#      - Debug option "SSTACK_DEBUG"                                          #
;#      - Added new stacking macros                                            #
;#      - Switched from post-checks to pre-checks                              #
;#      - Added option to disable stack range checks "SSTACK_NO_CHECK"         #
;#    November 14, 2012                                                        #
;#      - Removed PSH/PUL macros                                               #
;###############################################################################
;# Required Modules:                                                           #
;#    SSTACK - Subroutine stack handler                                        #
;#    RESET  - Reset handler                                                   #
;###############################################################################
;###############################################################################
;# Stack Layout                                                                #
;###############################################################################
; ISTACK_VARS_START,   +-------------------+
;        ISTACK_TOP -> |                   |
;                      | ISTACK_FRAME_SIZE |
;                      |                   |
;                      +-------------------+
;        SSTACK_TOP -> |                   |
;                      |                   |
;                      |                   |
;                      |                   |
;                      |    SSTACK_DEPTH   |
;                      |                   |
;                      |                   |
;                      |                   |
;     SSTACK_BOTTOM,   |                   |
;     ISTACK_BOTTOM,   +-------------------+
;   ISTACK_VARS_END ->
;
;The SSTACK is checked once before every JOBSR and once before every RTS.

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Debug option for stack over/underflows
;SSTACK_DEBUG		EQU	1 
	
;Disable stack range checks
;SSTACK_NO_CHECK	EQU	1 

;Stack depth 
#ifndef SSTACK_DEPTH
SSTACK_DEPTH		EQU	27
#endif
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
SSTACK_TOP		EQU	ISTACK_TOP+ISTACK_FRAME_SIZE
SSTACK_BOTTOM		EQU	ISTACK_BOTTOM
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef SSTACK_VARS_START_LIN
			ORG 	SSTACK_VARS_START, SSTACK_VARS_START_LIN
#else
			ORG 	SSTACK_VARS_START
#endif	

SSTACK_VARS_END		EQU	*
SSTACK_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization (initialization done by ISTACK module)
#macro	SSTACK_INIT, 0
#emac

;#Check stack boundaries	
; args:   1: required stack capacity (bytes)
;         2: expected stack content  (bytes)
; result: none 
; SSTACK: none
;         X, Y, and D are preserved 
#macro	SSTACK_CHECK_BOUNDARIES, 2
#ifndef	SSTACK_NO_CHECK 
			CPS	#SSTACK_TOP+\1 		;=> 2 cycles	 3 bytes
			BLO	OF	      		;=> 3 cycles	 4 bytes
			CPS	#SSTACK_BOTTOM-\2	;=> 2 cycles	 3 bytes
			BHI	UF			;=> 3 cycles	 4 bytes
					      		;  ---------	--------
					      		;  10 cycles	14 bytes
#ifdef	SSTACK_DEBUG
			JOB	DONE
UF			BGND
OF			BGND
DONE			EQU	*	
#else
UF			EQU	SSTACK_UF
OF			EQU	SSTACK_OF
#endif
#endif
#emac
	
;#Check stack before push operation	
; args:   1: required stack capacity (bytes)
; result: none 
; SSTACK: none
;         X, Y, and D are preserved
#macro	SSTACK_PREPUSH, 1 //number of bytes to push
			SSTACK_CHECK_BOUNDARIES	\1, 0
#emac

;#Check stack before pull operation	
; args:   1: expecteded stack content (bytes)
; result: none 
; SSTACK: none
;         X, Y, and D are preserved 
#macro	SSTACK_PREPULL, 1 //number of bytes to pull
			SSTACK_CHECK_BOUNDARIES	0, \1
#emac
	
;#Check stack and call subroutine	
; args:   required stack capacity (bytes)
; result: 1: subroutine
;         2: required stack space 
; SSTACK: arg 2
;         register content may be changed by the subroutine
; args:   1: Number of bytes to be allocated (args + local vars)
#macro	SSTACK_JOBSR, 2
			SSTACK_PREPUSH	\2
			JOBSR	\1
#emac
	
;#Allocate
; args:   1: Number of bytes
; result: none
; SSTACK: arg 1
;         X, Y, and D are preserved 
#macro	SSTACK_ALLOC, 1
			SSTACK_PREPUSH	\1
			LEAS	-\1,SP
#emac

;#Deallocate
; args:   1: Number of bytes
; result: none
; SSTACK: 0 bytes
;         X, Y, and D are preserved 
#macro	SSTACK_DEALLOC, 1
			SSTACK_PREPULL	\1
			LEAS	\1,SP
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef SSTACK_CODE_START_LIN
			ORG 	SSTACK_CODE_START, SSTACK_CODE_START_LIN
#else
			ORG 	SSTACK_CODE_START
#endif

;#Handle stack overflows
#ifndef	SSTACK_NO_CHECK
#ifndef	SSTACK_DEBUG
SSTACK_OF		EQU	*
			RESET_FATAL	SSTACK_MSG_OF ;throw a fatal error
#endif
#endif

;#Handle stack underflows
#ifndef	SSTACK_NO_CHECK
#ifndef	SSTACK_DEBUG
SSTACK_UF		EQU	*
			RESET_FATAL	SSTACK_MSG_UF ;throw a fatal error
#endif
#endif
		
SSTACK_CODE_END		EQU	*
SSTACK_CODE_END_LIN	EQU	@
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef SSTACK_TABS_START_LIN
			ORG 	SSTACK_TABS_START, SSTACK_TABS_START_LIN
#else
			ORG 	SSTACK_TABS_START
#endif	

;#Error Messages
#ifndef	SSTACK_NO_CHECK 
#ifndef	SSTACK_DEBUG
SSTACK_MSG_OF		RESET_MSG	"Subroutine stack overflow"
SSTACK_MSG_UF		RESET_MSG	"Subroutine stack underflow"
#endif
#endif

SSTACK_TABS_END		EQU	*
SSTACK_TABS_END_LIN	EQU	@
#endif
