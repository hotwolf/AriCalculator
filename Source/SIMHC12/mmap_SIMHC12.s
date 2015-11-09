#ifndef MMAP_COMPILED
#define MMAP_COMPILED
;###############################################################################
;# S12CBase - MMAP - Memory Map (SIMHC12)				       #
;###############################################################################
;#    Copyright 2010-2015 Dirk Heisswolf				       #
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
;#    November 15, 2012							       #
;#	- Initial release						       #
;#    January 30, 2015							       #
;#	- Updated during S12CBASE overhaul				       #
;#    October 27, 2015							       #
;#	- Cleanup							       #
;###############################################################################
;  Memory Map (64K RAM):
;  ---------------------
;	     +-------------+ $0000
;	     |	Registers  |
;	     +-------------+ $0200
; pretend    |/////////////|
;     RAM->+ +-------------+ $0800
;	   | |	Variables  |
;	   | +-------------+
;	   | |/////////////|
;	   + +-------------+ $4000
; pretend    |/////////////|
;   Flash->+ +-------------+ $8000
;	   | | Page Window |
;	   | +-------------+ $C000
;	   | |	  Code	   |
;	   | +-------------+
;	   | |	Tables	   |
;	   | +-------------+
;	   | |/////////////|
;	   | +-------------+ $FFC0
;	   | |	Vectors	   |
;	   + +-------------+

;###############################################################################
;# Configuration							       #
;###############################################################################

;###############################################################################
;# Constants								       #
;###############################################################################
;# Memory sizes
MMAP_REG_SIZE		EQU	$0200		;512B
MMAP_RAM_SIZE		EQU	$0800		; 2K
MMAP_FLASH_SIZE		EQU	$8000		; 32K

;# Memory Locations
;Register space
MMAP_REG_START		EQU	$0000
MMAP_REG_END		EQU	MMAP_REG_START+MMAP_REG_SIZE
MMAP_INITRG_VAL		EQU	MMAP_REG_START>>8

;RAM
MMAP_RAM_START		EQU	$0800
MMAP_RAM_END		EQU	MMAP_RAM_START+MMAP_RAM_SIZE
MMAP_INITRM_VAL		EQU	(MMAP_RAM_START>>8)&$C0

;FLASH
MMAP_FLASHWIN_START	EQU	$8000
MMAP_FLASHWIN_END	EQU	$C000

MMAP_FLASH3F_START	EQU	$C000
MMAP_FLASH3F_END	EQU	$10000
MMAP_FLASH3F_START_LIN	EQU	$C000
MMAP_FLASH3F_END_LIN	EQU	$10000

;# Vector table
VECTAB_START			EQU	$FF80
VECTAB_START_LIN		EQU	$00FF80

;###############################################################################
;# Security and Protection						       #
;###############################################################################
			;ORG	$FF0D	;unprotect
			;DB	$FF
			;ORG	$FF0F	;unsecure
			;DB	$FE

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
			CLR	INITRG
			;MOVB	#((MMAP_RAM_START>>8)&$F8), INITRM
			;MOVB	#(((MMAP_EEPROM_START>>8)&$F1)|$01), INITEE ;keep whatever reset value
			;MOVB	#$FE, PPAGE
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
