;###############################################################################
;# S12CBase - NVM - Non-Volatile Memory Driver (Mini-BDM-Pod)                  #
;###############################################################################
;#    Copyright 2010-2012 Dirk Heisswolf                                       #
;#    This file is part of the S12CBase framework for Freescale's S12(X) MCU   #
;#    families                                                                 #
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
;#    This module erase and programing routines for the on-chip NVMs.          #
;###############################################################################
;# Version History:                                                            #
;#    November 21, 2012                                                        #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    - none                                                                   #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;  Flash Map:
;  ----------  
;  Block 3		  Block 2		 Block 1S		Block 1N	       Block 0		
;  +---------+ $70_0000	  +---------+ $74_0000	 +---------+ $78_0000	+---------+ $7A_0000   +---------+ $7C_0000	
;  | Page C0 |	       	  | Page D0 |	       	 | Page E0 |	       	| Page E8 |	       | Page F0 |	       	
;  +---------+ $70_4000   +---------+ $74_4000   +---------+ $78_4000   +---------+ $7A_4000   +---------+ $7C_4000  
;  | Page C1 |	       	  | Page D1 |	       	 | Page E1 |	       	| Page E9 |	       | Page F1 |	       	
;  +---------+ $70_8000	  +---------+ $74_8000	 +---------+ $78_8000	+---------+ $7A_8000   +---------+ $7C_8000	
;  | Page C2 |	       	  | Page D2 |	       	 | Page E2 |	       	| Page EA |	       | Page F2 |	       	
;  +---------+ $70_C000	  +---------+ $74_C000	 +---------+ $78_C000	+---------+ $7A_C000   +---------+ $7C_C000	
;  | Page C3 |		  | Page D3 |		 | Page E3 |		| Page EB |	       | Page F3 |		
;  +---------+ $71_0000   +---------+ $74_0000   +---------+ $79_0000   +---------+ $7B_0000   +---------+ $7D_0000  
;  | Page C4 |	       	  | Page D4 |	       	 | Page E4 |	       	| Page EC |	       | Page F4 |	       	
;  +---------+ $71_4000   +---------+ $75_4000   +---------+ $79_4000   +---------+ $7B_4000   +---------+ $7D_4000  
;  | Page C5 |	       	  | Page D5 |	       	 | Page E5 |	       	| Page ED |	       | Page F5 |	       	
;  +---------+ $71_8000   +---------+ $75_8000   +---------+ $79_8000   +---------+ $7B_8000   +---------+ $7D_8000  
;  | Page C6 |	       	  | Page D6 |	       	 | Page E6 |	       	| Page EE |	       | Page F6 |	       	
;  +---------+ $71_C000   +---------+ $75_C000   +---------+ $79_C000   +---------+ $7B_C000   +---------+ $7D_C000  
;  | Page C7 |		  | Page D7 |		 | Page E7 |		| Page EF |	       | Page F7 |		
;  +---------+ $72_0000   +---------+ $75_0000   +---------+            +---------+            +---------+ $7E_0000  
;  | Page C8 |	       	  | Page D8 |	       	                	                       | Page F8 |	       	
;  +---------+ $72_4000   +---------+ $76_4000                                                 +---------+ $7E_4000  
;  | Page C9 |	       	  | Page D9 |	       	                                               | Page F9 |	       	
;  +---------+ $72_8000   +---------+ $76_8000                                                 +---------+ $7E_8000  
;  | Page CA |	       	  | Page DA |	       	                                               | Page FA |	       	
;  +---------+ $72_C000   +---------+ $76_C000                                                 +---------+ $7E_C000  
;  | Page CB |		  | Page DB |		                                               | Page FB |		
;  +---------+ $73_0000   +---------+ $77_0000                                                 +---------+ $7F_0000  
;  | Page CC |	       	  | Page DC |	       	                                               | Page FC |	       	
;  +---------+ $73_4000   +---------+ $77_4000                                                 +---------+ $7F_4000  
;  | Page CD |	       	  | Page DD |	       	                                               | Program |	       	
;  +---------+ $73_8000   +---------+ $77_8000                                                 +---------+ $7F_8000  
;  | Page CE |	       	  | Page DE |	       	                                               | Page FE |	       	
;  +---------+ $73_C000   +---------+ $77_C000                                                 +---------+
;  | Page CF |		  | Page DF |		               	                               | Program |		
;  +---------+            +---------+                                                          +---------+           
;
;  Status Byte:
;  ------------  
;  Last byte of each page (local address BFFF).
;
	
;###############################################################################
;# Configuration                                                               #
;###############################################################################
;General settings
;----------------
;Oscillator frequency
#ifndef	CLOCK_OSC_FREQ
CLOCK_OSC_FREQ		EQU	10000000 	;default is 10MHz
#endif

;NVM settings
;-------------
;Clock divider 
#ifndef	NVM_FDIV_VAL
NVM_FDIV_VAL		EQU	((CLOCK_OSC_FREQ/1000000)-1) ;default is $0A
#endif

;Flash size
#ifndef	NVM_1024K
#ifndef	NVM_512K
NVM_1024K		EQU	1 		;default is 1MB
#endif
#endif
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;Status byte 
NVM_SBYTE_ADDR		EQU	$BFFF

	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef NVM_VARS_START_LIN
			ORG 	NVM_VARS_START, NVM_VARS_START_LIN
#else
			ORG 	NVM_VARS_START
NVM_VARS_START_LIN	EQU	@			
#endif	

NVM_VARS_END		EQU	*
NVM_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	NVM_INIT, 0
;			;Flash configuration
;			MOVB	#NVM_FDIV_VAL, FCLKDIV 		;set prescaler
;			MOVW	#((IGNSF<<8)|DFDIE), FCNFG
;			MOVB	#(FPOPEN|FPHS1|FPHS0|FPLDIS), FPROT
;
;			;Select the most recent PPAGE 
;			NVM_SET_PPAGE
#emac

;#Set PPAGE
; args:   none
; result: C-flag: set if successful
; SSTACK: ? bytes
;         X, Y and D are preserved 
#macro NVM_SET_PPAGE, 0
#emac

;#Invalidate current page and start a new one
; args:   none
; result: C-flag: set if successful
; SSTACK: ? bytes
;         X, Y and D are preserved 
#macro NVM_INVALIDATE_PAGE, 0
#emac

;#Erase all flash pages
; args:   none
; result: C-flag: set if successful
; SSTACK: ? bytes
;         X, Y and D are preserved 
#macro NVM_ERASE_ALL, 0
#emac

;#Copy data string into flash 
; args:   X: start of source (RAM address)
;         Y: start of destination (paged flash address)
;         D: number of bytes to copy 
; result: C-flag: set if successful
; SSTACK: ? bytes
;         X, Y and D are preserved 
#macro NVM_COPY, 0
#emac

	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef NVM_CODE_START_LIN
			ORG 	NVM_CODE_START, NVM_CODE_START_LIN
#else
			ORG 	NVM_CODE_START
NVM_CODE_START_LIN	EQU	@			
#endif	

;#Set PPAGE
; args:   none
; result: C-flag: set if successful
; SSTACK: ? bytes
;         X, Y and D are preserved 
NVM_SET_PPAGE		EQU	*
			;Set first PPAGE
#ifdef	NVM_1024K
			MOVB	#$C0, PPAGE
#else
#ifdef	NVM_1024K
			MOVB	#$E0, PPAGE
#else
			MOVB	#$F8, PPAGE
#endif	
#endif	
			



	
;#Erase flash
; args:   none
; result: C-flag: set if successful
; SSTACK: ? bytes
;         X, Y and D are preserved 
NVM_ERASE_FLASH		EQU	*



	



	
			;Command complete interrupt 
NVM_ISR_CC		EQU	*




			;Error interrupt 
NVM_ISR_ERROR		EQU	*



	
NVM_CODE_END		EQU	*	
NVM_CODE_END_LIN	EQU	@	

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef NVM_TABS_START_LIN
			ORG 	NVM_TABS_START, NVM_TABS_START_LIN
#else
			ORG 	NVM_TABS_START
NVM_TABS_START_LIN	EQU	@			
#endif	

NVM_TABS_END		EQU	*	
NVM_TABS_END_LIN	EQU	@	
