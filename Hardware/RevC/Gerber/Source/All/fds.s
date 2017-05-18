#ifndef FDS_COMPILED
#define FDS_COMPILED
;###############################################################################
;# S12CForth- FDS                                                              #
;###############################################################################
;#    Copyright 2009-2016 Dirk Heisswolf                                       #
;#    This file is part of the S12CForth framework for NXP's S12C MCU          #
;#                                                                             #
;#    S12CForth is free software: you can redistribute it and/or modify        #
;#    it under the terms of the GNU General Public License as published by     #
;#    the Free Software Foundation, either version 3 of the License, or        #
;#    (at your option) any later version.                                      #
;#                                                                             #
;#    S12CForth is distributed in the hope that it will be useful,             #
;#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #
;#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
;#    GNU General Public License for more details.                             #
;#                                                                             #
;#    You should have received a copy of the GNU General Public License        #
;#    along with S12CForth.  If not, see <http://www.gnu.org/licenses/>.       #
;###############################################################################
;# Description:                                                                #
;#    This module implements the data space.                                   #
;#                                                                             #
;#    The parameter stack uses these registers:                                #
;#            DP = Data space pointer.			    	               #
;#	           Points to the next free byte                                #
;#                                                                             #
;#    The following notation is used to describe the stack layout in the word  #
;#    definitions:                                                             #
;#                                                                             #
;#    Symbol          Data type                       Size on stack	       #
;#    ------          ---------                       -------------	       #
;#    flag            flag                            1 cell		       #
;#    true            true flag                       1 cell		       #
;#    false           false flag                      1 cell		       #
;#    char            character                       1 cell		       #
;#    n               signed number                   1 cell		       #
;#    +n              non-negative number             1 cell		       #
;#    u               unsigned number                 1 cell		       #
;#    n|u 1           number                          1 cell		       #
;#    x               unspecified cell                1 cell		       #
;#    xt              execution token                 1 cell		       #
;#    addr            address                         1 cell		       #
;#    a-addr          aligned address                 1 cell		       #
;#    c-addr          character-aligned address       1 cell		       #
;#    d-addr          double address                  2 cells (non-standard)   #
;#    d               double-cell signed number       2 cells		       #
;#    +d              double-cell non-negative number 2 cells		       #
;#    ud              double-cell unsigned number     2 cells		       #
;#    d|ud 2          double-cell number              2 cells		       #
;#    xd              unspecified cell pair           2 cells		       #
;#    colon-sys       definition compilation          implementation dependent #
;#    do-sys          do-loop structures              implementation dependent #
;#    case-sys        CASE structures                 implementation dependent #
;#    of-sys          OF structures                   implementation dependent #
;#    orig            control-flow origins            implementation dependent #
;#    dest            control-flow destinations       implementation dependent #
;#    loop-sys        loop-control parameters         implementation dependent #
;#    nest-sys        definition calls                implementation dependent #
;#    i*x, j*x, k*x 3 any data type                   0 or more cells	       #
;#  									       #
;###############################################################################
;# Version History:                                                            #
;#    April 23, 2009                                                           #
;#      - Initial release                                                      #
;#    October 4, 2016                                                          #
;#      - Started subroutine threaded implementation                           #
;###############################################################################
;# Required Modules:                                                           #
;#    BASE    - S12CBase framework                                             #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################

;###############################################################################
;# Memory Layout                                                               #
;###############################################################################
; Memory layout:
; ==============       
;      	                    +----------+----------+	     
;            DS_PS_START -> |          |          |	     
;                           |   User Variables    |	     
;                           |          |          |	     
;                           |          v          |	     
;                           | --- --- --- --- --- |
;    	                    |                     | <- [DP]		  
;    	                    |                     |		  
;    	                    .                     .		  
;    	                    .                     .		  
;                           | --- --- --- --- --- |
;                           |          ^          | <- [CFSP]	  
;                           |          |          |	     
;                           | Control-flow stack  |		  
;                           |          |          |	     
;                           +----------+----------+        
;    	          [CVARS]-> |         CP          | 		  
;    	                    |        CFSP         |		  
;    	                    |         ...         |		  
;                           +----------+----------+        
;                           |          |          |
;                           |  User Dictionary    |	     
;                           |          |          |	     
;                           |          v          |	     
;                           | --- --- --- --- --- |
;                           |                     | <- [CP]	     
;    	                    |                     |		  
;    	                    |                     |		  
;                           | --- --- --- --- --- |          
;                           |          ^          | <- [HLD]	     
;                           |         PAD         |	     
;                           | --- --- --- --- --- |          
;                           |                     | <- [PAD]          
;                           .                     .          
;                           .                     .          
;                           | --- --- --- --- --- |          
;                           |          ^          | <- [PSP=Y]	  
;                           |          |          |		  
;                           |   Parameter stack   |		  
;    	                    |          |          |		  
;                           +----------+----------+        
;    	                    |       Canary        |	 		  
;                           +----------+----------+        
;              DS_PS_END ->   
	
;###############################################################################
;# Configuration                                                               #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################

;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FDS_VARS_START_LIN
			ORG 	FDS_VARS_START, FDS_VARS_START_LIN
#else
			ORG 	FDS_VARS_START

FDS_VARS_START_LIN	EQU	@
#endif	

			ALIGN	1	
DP			DS	2		;data pointer (next free space)
	
FDS_VARS_END		EQU	*
FDS_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization (executed along with ABORT action)
;===============
#macro	FDS_INIT, 0
			MOVW	#DS_PS_START, DS 		;reset data space pointer
#emac
	
;#Abort action (to be executed in addition of QUIT action)
;=============
#macro	FDS_ABORT, 0
#emac
	
;#Quit action
;============
#macro	FDS_QUIT, 0
#emac
	
;#System integrity monitor
;=========================
#macro	FDS_MON, 0
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FDS_CODE_START_LIN
			ORG 	FDS_CODE_START, FDS_CODE_START_LIN
#else
			ORG 	FDS_CODE_START
FDS_CODE_START_LIN	EQU	@
#endif

;#########
;# Words #
;#########

;Word: ALIGN ( -- )
;If the data-space pointer is not aligned, reserve enough space to align it.
IF_ALIGN		INLINE	CF_ALIGN	
CF_ALIGN		EQU	*
			LDD	DP 			;DP -> D
			ADDD	#1			;increment DP
			ANDB	#FE			;align DP
			STD	DP			;update DP
CF_ALIGN_EOI		RTS				;done

;Word: ALLOT ( n -- )
;If n is greater than zero, reserve n address units of data space. If n is less
;than zero, release |n| address units of data space. If n is zero, leave the
;data-space pointer unchanged.
;If the data-space pointer is aligned and n is a multiple of the size of a cell
;when ALLOT begins execution, it will remain aligned when ALLOT finishes
;execution.
;If the data-space pointer is character aligned and n is a multiple of the size
;of a character when ALLOT begins execution, it will remain character aligned
;when ALLOT finishes execution.
IF_ALLOT		INLINE	CF_ALLOT	
CF_ALLOT		EQU	*
			LDD	DP 			;DP -> D
			ADDD	2,Y+			;DP + n _> DP
			STD	DP			;update DP
CF_ALLOT_EOI		RTS				;done
	
;Word: , ( x -- )
;Reserve one cell of data space and store x in the cell. If the data-space
;pointer is aligned when , begins execution, it will remain aligned when,
;finishes execution. An ambiguous condition exists if the data-space pointer is
;not aligned prior to execution of ,.
IF_COMMA		INLINE	CF_COMMA	
CF_COMMA		EQU	*
			LDX	DP 			;DP -> X
			LEAX	2,X			;allocate data space
			STX	DP			;update DP
			MOVW	2,Y+, -2,X		;copy x
CF_COMMA_EOI		RTS				;done
	
;C, ( char -- )
;Reserve space for one character in the data space and store char in the space.
;If the data-space pointer is character aligned when C, begins execution, it
;will remain character aligned when C, finishes execution. An ambiguous
;condition exists if the data-space pointer is not character-aligned prior to
;execution of C,.
IF_C_COMMA		INLINE	CF_C_COMMA	
CF_C_COMMA		EQU	*
			LDX	DP 			;DP -> X
			INX				;allocate data space
			STX	DP			;update DP
			MOVB	2,Y+, -1,X		;copy char
	
FDS_CODE_END		EQU	*
FDS_CODE_END_LIN	EQU	@

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef FDS_TABS_START_LIN
			ORG 	FDS_TABS_START, FDS_TABS_START_LIN
#else
			ORG 	FDS_TABS_START
FDS_TABS_START_LIN	EQU	@
#endif	

FDS_TABS_END		EQU	*
FDS_TABS_END_LIN	EQU	@
#endif	
