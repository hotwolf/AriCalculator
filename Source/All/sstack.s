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
;###############################################################################
;# Required Modules:                                                           #
;#    SSTACK - Interrupt Stack Handler                                         #
;#    ERROR  - Error Handler                                                   #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
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

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Debug option for stack over/underflows
;SSTACK_DEBUG		EQU	1 
	
;Disable stack range checks
;ISTACK_NO_CHECK	EQU	1 
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
SSTACK_DEPTH		EQU	24
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
;#Initialization
#macro	SSTACK_INIT, 0
#emac

;#Allocate local memory
#macro	SSTACK_ALLOC, 1
			SSTACK_PREPUSH	\1
			LEAS	-\1,SP
#emac

;#Push accu A onto stack
#macro	SSTACK_PSHA, 0
			SSTACK_PREPUSH	1
			PSHA
#emac

;#Push accu B onto stack
#macro	SSTACK_PSHB, 0
			SSTACK_PREPUSH	1
			PSHB
#emac

;#Push accu D onto stack
#macro	SSTACK_PSHD, 0
			SSTACK_PREPUSH	2
			PSHD
#emac

;#Push index X onto stack
#macro	SSTACK_PSHX, 0
			SSTACK_PREPUSH	2
			PSHX
#emac

;#Push index X and accu B onto stack
#macro	SSTACK_PSHXB, 0
			SSTACK_PREPUSH	3
			PSHX
			PSHB
#emac

;#Push index X and accu D onto stack
#macro	SSTACK_PSHXD, 0
			SSTACK_PREPUSH	4
			PSHX
			PSHD
#emac

;#Push index Y onto stack
#macro	SSTACK_PSHY, 0
			SSTACK_PREPUSH	2
			PSHY
#emac

;#Push index Y and accu A onto the stack
#macro	SSTACK_PSHYA, 0
			SSTACK_PREPUSH	3
			PSHY
			PSHA
#emac

;#Push index Y and accu B onto the stack
#macro	SSTACK_PSHYB, 0
			SSTACK_PREPUSH	3
			PSHY
			PSHB
#emac

;#Push index Y and accu D onto the stack
#macro	SSTACK_PSHYD, 0
			SSTACK_PREPUSH	4
			PSHY
			PSHD
#emac

;#Push index X and Y onto the stack
#macro	SSTACK_PSHYX, 0
			SSTACK_PREPUSH	4
			PSHY
			PSHX
#emac

;#Push index X, Y and accu A onto the stack
#macro	SSTACK_PSHYXA, 0
			SSTACK_PREPUSH	5
			PSHY
			PSHX
			PSHA
#emac

;#Push index X, Y and accu B onto the stack
#macro	SSTACK_PSHYXB, 0
			SSTACK_PREPUSH	5
			PSHY
			PSHX
			PSHB
#emac

;#Push index X, Y and accu D onto the stack
#macro	SSTACK_PSHYXD, 0
			SSTACK_PREPUSH	6
			PSHY
			PSHX
			PSHD
#emac

;#Deallocate local memory
#macro	SSTACK_DEALLOC, 1
			SSTACK_PREPULL	\1
			LEAS	\1,SP
#emac
	
;#Pull accu A from stack
#macro	SSTACK_PULA, 0
			SSTACK_PREPULL	1
			PULA
#emac

;#Pull accu A from stack and return
#macro	SSTACK_PULA_RTS, 0
			SSTACK_PREPULL	3
			PULA
			RTS
#emac

;#Pull accu A, index X and Y from the stack
#macro	SSTACK_PULAXY, 0
			SSTACK_PREPULL	5
			PULA
			PULX
			PULY
#emac

;#Pull accu A and index Y from the stack
#macro	SSTACK_PULAY, 0
			SSTACK_PREPULL	3
			PULA
			PULY
#emac

;#Pull accu B from stack
#macro	SSTACK_PULB, 0
			SSTACK_PREPULL	1
			PULB
#emac

;#Pull accu B from stack and return without error
#macro	SSTACK_PULB_RTS_NOERR, 0
			SSTACK_PREPULL	3
			SEC
			PULB
#emac

;#Pull accu B from stack and return with error
#macro	SSTACK_PULB_RTS_ERR, 0
			SSTACK_PREPULL	3
			CLC
			PULB
#emac

;#Pull accu B and index X from stack
#macro	SSTACK_PULBX, 0
			SSTACK_PREPULL	3
			PULB
			PULX
#emac

;#Pull accu B, index X and Y from the stack
#macro	SSTACK_PULBXY, 0
			SSTACK_PREPULL	5
			PULB
			PULX
			PULY
#emac

;#Pull accu B, index X and Y from the stack and return
#macro	SSTACK_PULBXY_RTS, 0
			SSTACK_PREPULL	7
			PULB
			PULX
			PULY
			RTS
#emac

;#Pull index Y and accu B from the stack
#macro	SSTACK_PULBY, 0
			SSTACK_PREPULL	3
			PULB
			PULY
#emac

;#Pull accu D from stack
#macro	SSTACK_PULD, 0
			SSTACK_PREPULL	2
			PULD
#emac

;#Pull accu D and index X from the stack
#macro	SSTACK_PULDX, 0
			PULD
			PULX
			SSTACK_PREPULL	4
#emac

;#Pull accu D, index X and Y from the stack
#macro	SSTACK_PULDXY, 0
			SSTACK_PREPULL	6
			PULD
			PULX
			PULY
#emac

;#Pull index Y and accu D from the stack
#macro	SSTACK_PULDY, 0
			SSTACK_PREPULL	4
			PULD
			PULY
#emac

;#Pull index X from stack
#macro	SSTACK_PULX, 0
			SSTACK_PREPULL	2
			PULX
#emac

;#Pull index X and Y from the stack
#macro	SSTACK_PULXY, 0
			SSTACK_PREPULL	4
			PULX
			PULY
#emac

;#Pull index Y from stack
#macro	SSTACK_PULY, 0
			SSTACK_PREPULL	2
			PULY
#emac

;#Call subroutine	
#macro	SSTACK_JOBSR, 1
			SSTACK_PREPUSH	2
			JOBSR	\1
#emac

;#Return from subroutine	
#macro	SSTACK_RTS, 0
			SSTACK_PREPULL	2
			RTS
#emac

;#Return from subroutine and flag no error (carry cleared)	
#macro	SSTACK_RTS_NOERR, 0
			SSTACK_PREPULL	2
			SEC
			RTS
#emac

;#Return from subroutine and flag an error (carry set)	
#macro	SSTACK_RTS_ERR, 0
			SSTACK_PREPULL	2
			CLC
			RTS
#emac

;#Internal macros 
;#Check stack before push operation	
#macro	SSTACK_PREPUSH 1 //number of bytes to push
#ifndef	SSTACK_NO_CHECK 
			CPS	#SSTACK_TOP-\1
			BLO	OF
			CPS	#SSTACK_BOTTOM
			BHS	UF
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
#macro	SSTACK_PREPULL 1 //number of bytes to push
#ifndef	SSTACK_NO_CHECK 
			CPS	#SSTACK_TOP
			BLO	OF
			CPS	#SSTACK_BOTTOM+\1
			BHS	UF
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

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef SSTACK_CODE_START_LIN
			ORG 	SSTACK_CODE_START, SSTACK_CODE_START_LIN
#else
			ORG 	SSTACK_CODE_START
#endif

;#Stack overflow detected	
SSTACK_OF		EQU	ISTACK_OF

;#Stack underflow detected	
SSTACK_UF		EQU	ISTACK_UF
	
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
#ifdef	ISTACK_NO_CHECK 
SSTACK_MSG_OF		EQU	ISTACK_MSG_OF
SSTACK_MSG_UF		EQU	ISTACK_MSG_UF
#else
ISTACK_MSG_OF		ERROR_MSG	ERROR_LEVEL_FATAL, "System stack overflow"
ISTACK_MSG_UF		ERROR_MSG	ERROR_LEVEL_FATAL, "System stack underflow"
#endif
#endif

SSTACK_TABS_END		EQU	*
SSTACK_TABS_END_LIN	EQU	@
