#ifndef SSTACK_COMPILED
#define SSTACK_COMPILED
;###############################################################################
;# S12CBase - SSTACK - Subroutine Stack Handler                                #
;###############################################################################
;#    Copyright 2010-2016 Dirk Heisswolf                                       #
;#    This file is part of the S12CBase framework for NXP's S12C MCU family.   #
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
;#    January 16, 2016                                                         #
;#      - New generic implementation                                           #
;#    Septemember 28, 2016                                                     #
;#      - S12CBASE overhaul                                                    #
;###############################################################################
;# Required Modules:                                                           #
;#    RESET  - Reset handler                                                   #
;#                                                                             #
;###############################################################################
;###############################################################################
;# Stack Layout                                                                #
;###############################################################################
;        SSTACK_TOP,   +-------------------+
;        ISTACK_TOP -> |                   |
;                      |      ISTACK       |
;                      |                   |
;                      +-------------------+
;                      |                   |
;                      |                   |
;                      |                   |
;                      |                   |
;                      |      SSTACK       |
;                      |                   |
;                      |                   |
;                      |                   |
;                      |                   |
;     SSTACK_BOTTOM,   +-------------------+
;     ISTACK_BOTTOM ->

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Stack allocation
;----------------
;Bottom of the stack (mandatory)
#ifndef	SSTACK_BOTTOM
			ERROR	"SSTACK_BOTTOM is undefined"
#endif
;Top of the stack (optional for range checks)
;SSTACK_TOP		EQU	...

;Range checks
;------------
;General stack range check enable
#ifndef	SSTACK_CHECK_ON
#ifndef	SSTACK_CHECK_OFF
SSTACK_CHECK_OFF	EQU	1 		;default is off
#endif
#endif
	
;Alternative range checks for dynamic boundaries
;#mac SSTACK_BROF, 2
;	...range checking code
;#emac
;#mac SSTACK_BRUF, 2
;	...range checking code
;#emac
	
;Debug code
;----------
#ifndef	SSTACK_DEBUG_ON
#ifndef	SSTACK_DEBUG_OFF
SSTACK_DEBUG_OFF	EQU	1 		;default is off
#endif
#endif

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;Stack size 
;----------
SSTACK_SIZE		EQU	(SSTACK_BOTTOM-SSTACK_TOP)
	
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
;# Stack space                                                                 #
;###############################################################################
#ifdef SSTACK_TOP
#ifdef SSTACK_TOP_LIN
			ORG 	SSTACK_TOP, SSTACK_TOP_LIN
#else
			ORG 	SSTACK_TOP
#endif	
			;Declare RAM space (to be recognized by the assembler) 
			DS	SSTACK_BOTTOM-SSTACK_TOP
#endif	
	
;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization (initialization done by ISTACK module)
;#-----------------------------------------------------
#macro	SSTACK_INIT, 0
#emac

;#Boundary checks
;#---------------
#ifnmac SSTACK_BROF
;#Branch on stack overflow	
; args:   1: required stack capacity (bytes)
;         2: branch address
; result: none
; SSTACK: none
;         X, Y, and D are preserved
#macro	SSTACK_BROF, 2
#ifdef SSTACK_TOP	
			CPS	#SSTACK_TOP+\1 		;=> 2 cycles	 3 bytes
			BLO	\2	      		;=> 3 cycles	 4 bytes
					      		;  ---------	--------
					      		;   5 cycles	 7 bytes
#endif
#emac

#ifnmac SSTACK_BRUF
;#Branch on stack underflow	
; args:   1: required stack capacity (bytes)
;         2: branch address
; result: none
; SSTACK: none
;         X, Y, and D are preserved
#macro	SSTACK_BRUF, 2
			CPS	#SSTACK_BOTTOM+\1 	;=> 2 cycles	 3 bytes
			BHI	\2	      		;=> 3 cycles	 4 bytes
					      		;  ---------	--------
					      		;   5 cycles	 7 bytes
#emac

#ifnmac	SSTACK_PREPUSH
;#Check stack before push operation	
; args:   1: required stack capacity (bytes)
; result: none
; SSTACK: none
;         X, Y, and D are preserved
#macro	SSTACK_PREPUSH, 1 //number of bytes to push
#ifdef	SSTACK_CHECK_ON
			SSTACK_BROF	\1, OF
#ifdef	SSTACK_DEBUG_ON
			JOB	DONE
OF			BGND
DONE			EQU	*	
#else
OF			EQU	SSTACK_OF
#endif
#endif
#emac
#endif

#ifnmac	SSTACK_PREPULL
;#Check stack before pull operation	
; args:   1: expecteded stack content (bytes)
; result: none
; SSTACK: none
;         X, Y, and D are preserved
#macro	SSTACK_PREPULL, 1 //number of bytes to pull
#ifdef	SSTACK_CHECK_ON
			SSTACK_BRUF	\1, UF
#ifdef	SSTACK_DEBUG_ON
			JOB	DONE
UF			BGND
DONE			EQU	*	
#else
UF			EQU	SSTACK_UF
#endif
#endif
#emac
#endif
		
;#Check stack and call subroutine	
; args:   required stack capacity (bytes)
; result: 1: subroutine
;         2: required stack space
; SSTACK: arg 2
;         register content may be changed by the subroutine
; args:   1: Number of bytes to be allocated (args + local vars)
#macro	SSTACK_JOBSR, 2
#ifdef	SSTACK_CHECK_ON
			SSTACK_PREPUSH	\2
#endif
			JOBSR	\1
#emac
	
;#Allocate
; args:   1: Number of bytes
; result: none
; SSTACK: arg 1
;         X, Y, and D are preserved
#macro	SSTACK_ALLOC, 1
#ifdef	SSTACK_CHECK_ON
			SSTACK_PREPUSH	\1
#endif
			LEAS	-\1,SP
#emac

;#Deallocate
; args:   1: Number of bytes
; result: none
; SSTACK: 0 bytes
;         X, Y, and D are preserved
#macro	SSTACK_DEALLOC, 1
#ifdef	SSTACK_CHECK_ON
			SSTACK_PREPULL	\1
#endif
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
#ifdef	SSTACK_CHECK_ON
#ifdef	SSTACK_DEBUG_OFF
SSTACK_OF		EQU	*
			RESET_FATAL	SSTACK_MSG_OF ;throw a fatal error
#endif
#endif
	
;#Handle stack underflows
#ifdef	SSTACK_CHECK_ON
#ifdef	SSTACK_DEBUG_OFF
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
#ifdef	SSTACK_CHECK_ON
#ifdef	SSTACK_DEBUG_OFF
SSTACK_MSG_OF		RESET_MSG	"Subroutine stack overflow"
SSTACK_MSG_UF		RESET_MSG	"Subroutine stack underflow"
#endif
#endif
	
SSTACK_TABS_END		EQU	*
SSTACK_TABS_END_LIN	EQU	@
#endif
