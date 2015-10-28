#ifndef MMAP_COMPILED
#define MMAP_COMPILED
;###############################################################################
;# S12CBase - MMAP - Memory Map (OpenBDC Pod)				       #
;###############################################################################
;#    Copyright 2015 Dirk Heisswolf					       #
;#    This file is part of the S12CBase framework for Freescale's S12C MCU     #
;#    family.								       #
;#									       #
;#    S12CBase is free software: you can redistribute it and/or modify	       #
;#    it under the terms of the GNU General Public License as published by     #
;#    the Free Software Foundation, either version 3 of the License, or	       #
;#    (at your option) any later version.				       #
;#									       #
;#    S12CBase is distributed in the hope that it will be useful,	       #
;#    but WITHOUT ANY WARRANTY; without even the implied warranty of	       #
;#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the	       #
;#    GNU General Public License for more details.			       #
;#									       #
;#    You should have received a copy of the GNU General Public License	       #
;#    along with S12CBase.  If not, see <http://www.gnu.org/licenses/>.	       #
;###############################################################################
;# Description:								       #
;#    This module module performs all the necessary steps to initialize the    #
;#    device after each reset.						       #
;###############################################################################
;# Required Modules:							       #
;#    REGDEF - Register Definitions					       #
;#									       #
;# Requirements to Software Using this Module:				       #
;#    - none								       #
;###############################################################################
;# Version History:							       #
;#    April 4, 2010							       #
;#	- Initial release						       #
;#    July 9, 2012							       #
;#	- Added support for linear PC					       #
;#	- Updated memory mapping					       #
;#    January 29, 2015							       #
;#	- Updated during S12CBASE overhaul				       #
;#    October 27, 2015							       #
;#	- Cleanup							       #
;###############################################################################
;  Flash Memory Map:
;  -----------------
;		     S12C128				  S12C32
;		 +-------------+ $0000		      +-------------+ $0000
;		 |  Registers  |		      |	 Registers  |
;		 +-------------+ $0400		      +-------------+ $0400
;		 |/////////////|		      |/////////////|
;	  RAM->+ +-------------+ $1000	       RAM->+ +-------------+ $1000
;	       | |  Variables  |		    | |	 Variables  |
;	FLASH->+ +-------------+ $2000		    + +-------------+ $1800
;	       | |   Page 3D   |		      |/////////////|
;	       | +-------------+ $4000	     FLASH->+ +-------------+ $4000
;	       | |   Page 3E   |		    | |	  Page 3E   |
;	       | +-------------+ $8000		    | +-------------+ $8000
;	       | | Page Window |		    | | Page Window |
;	       + +-------------+ $C000		    + +-------------+ $C000
;	      P| |   Code      |		  P | |	   Code	    |
;	      a| +-------------+		  a | +-------------+
;	      g| |  Tables     |		  g | |	  Tables    |
;	      e| +-------------+		  e | +-------------+
;	       | |/////////////|		    | |/////////////|
;	      3| +-------------+ $FF80		  3 | +-------------+ $FF80
;	      F| |  Vectors    |		  F | |	 Vectors    |
;	       + +-------------+ $10000		    + +-------------+ $10000
;
;  RAM Memory Map:
;  ---------------
;		     S12C128				  S12C32
;		 +-------------+ $0000		      +-------------+ $0000
;		 |  Registers  |		      |	 Registers  |
;		 +-------------+ $0400		      +-------------+ $0400
;		 |/////////////|		      |/////////////|
;	  RAM->+ +-------------+ $E000	       RAM->+ +-------------+ $F800
;	       | |  Variables  |		    | |	 Variables  |
;	       | +-------------+		    | +-------------+
;	       | |    Code     |		    | |	   Code	    |
;	       | +-------------+		    | +-------------+
;	       | |   Tables    |		    | |	  Tables    |
;	       | +-------------+		    | +-------------+
;	       | |/////////////|		    | |/////////////|
;	       | +-------------+ $FF80		    | +-------------+ $FF80
;	       | |  Vectors    |		    | |	 Vectors    |
;	       + +-------------+ $10000		    + +-------------+ $10000

;###############################################################################
;# Configuration							       #
;###############################################################################
;Device selection
#ifndef MMAP_S12C32
#ifndef MMAP_S12C128
MMAP_S12C128		EQU	1		;default is S12C128
#endif
#endif

;RAM or flash
#ifndef MMAP_RAM
#ifndef MMAP_FLASH
MMAP_FLASH		EQU	1		;default is flash
#endif
#endif

;###############################################################################
;# Security and Protection						       #
;###############################################################################
#ifdef	MMAP_FLASH
			;Align to D-Bug12XZ programming granularity
			ORG	$FF0C, $FFFF0C	;unprotect
			FILL	$FF, 4
			;ORG	$FF08, $FFFF08	;unprotect
			;FILL	$FF, 8

			;Unsecure
			ORG	$FF0F, $FFFF0F	;unsecure
			DB	$FE
#endif

;###############################################################################
;# Constants								       #
;###############################################################################
;# Memory sizes
MMAP_REG_SIZE		EQU	$0400		;	      1K
#ifdef	MMAP_S12C32
MMAP_RAM_SIZE		EQU	$800		;S12C32	 ->   2K
MMAP_FLASH_SIZE		EQU	$8000		;S12C32	 ->  32K
#else
MMAP_RAM_SIZE		EQU	$1000		;S12C128 ->   4K
MMAP_FLASH_SIZE		EQU	$20000		;S12C128 -> 128K
#endif

;# Memory Locations
MMAP_REG_START		EQU	$0000
MMAP_REG_END		EQU	MMAP_REG_START+MMAP_REG_SIZE
MMAP_INITRG_VAL		EQU	MMAP_REG_START>>8

#ifdef	MMAP_RAM
MMAP_RAM_END		EQU	$10000
MMAP_RAM_START		EQU	MMAP_RAM_END-MMAP_RAM_SIZE
MMAP_INITRM_VAL		EQU	((MMAP_RAM_START>>8)&$C0)|RAMHAL
#else
MMAP_RAM_START		EQU	$1000
MMAP_RAM_END		EQU	MMAP_RAM_START+MMAP_RAM_SIZE
MMAP_INITRM_VAL		EQU	(MMAP_RAM_START>>8)&$C0
#endif

#ifdef	MMAP_FLASH
MMAP_FLASHWIN_START	EQU	$8000
MMAP_FLASHWIN_END	EQU	$C000

#ifdef	MMAP_S12C128
MMAP_FLASH3D_START	EQU	MMAP_RAM_END
MMAP_FLASH3D_END	EQU	$4000
MMAP_FLASH3D_START_LIN	EQU	$F4000+MMAP_FLASH3D_START
MMAP_FLASH3D_END_LIN	EQU	$F8000
#endif

MMAP_FLASH3E_START	EQU	$4000
MMAP_FLASH3E_END	EQU	$8000
MMAP_FLASH3E_START_LIN	EQU	$F8000
MMAP_FLASH3E_END_LIN	EQU	$FC000

MMAP_FLASH3F_START	EQU	$C000
MMAP_FLASH3F_END	EQU	$10000
MMAP_FLASH3F_START_LIN	EQU	$FC000
MMAP_FLASH3F_END_LIN	EQU	$100000
#endif

;# Vector table
#ifndef VECTAB_START
VECTAB_START		EQU	$FF80
VECTAB_START_LIN	EQU	$FFF80
#endif

;###############################################################################
;# Variables								       #
;###############################################################################
#ifdef MMAP_VARS_START_LIN
			ORG	MMAP_VARS_START, MMAP_VARS_START_LIN
#else
			ORG	MMAP_VARS_START
MMAP_VARS_START_LIN	EQU	@
#endif

MMAP_VARS_END		EQU	*
MMAP_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros								       #
;###############################################################################
;#Initialization
#macro	MMAP_INIT, 0
			;Setup and lock RAM and register space
			MOVW	#((MMAP_RAM_START&$F800)|(MMAP_REG_START>>8)), INITRM
#ifdef	MMAP_FLASH
			;Setup and lock flash space
			MOVB	#(ROMHM|ROMON), MISC

#ifnmac	NVM_SET_PPAGE
#ifdef	MMAP_S12C32
			MOVB	#$FE, PPAGE
#else
			MOVB	#$FC, PPAGE
#endif
#endif
#endif
#emac

;###############################################################################
;# Code									       #
;###############################################################################
#ifdef MMAP_CODE_START_LIN
			ORG	MMAP_CODE_START, MMAP_CODE_START_LIN
#else
			ORG	MMAP_CODE_START
MMAP_CODE_START_LIN	EQU	@
#endif

MMAP_CODE_END		EQU	*
MMAP_CODE_END_LIN	EQU	@

;###############################################################################
;# Tables								       #
;###############################################################################
#ifdef MMAP_TABS_START_LIN
			ORG	MMAP_TABS_START, MMAP_TABS_START_LIN
#else
			ORG	MMAP_TABS_START
MMAP_TABS_START_LIN	EQU	@
#endif

MMAP_TABS_END		EQU	*
MMAP_TABS_END_LIN	EQU	@
#endif
