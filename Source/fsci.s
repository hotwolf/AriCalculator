;###############################################################################
;# S12CForth - FSCI - Forth wrapper for the S12CBase SCI driver                #
;###############################################################################
;#    Copyright 2010 Dirk Heisswolf                                            #
;#    This file is part of the S12CForth framework for Freescale's S12C MCU    #
;#    family.                                                                  #
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
;#    This module implements Forth words for the S12CBase SCI driver           # 
;#                                                                             #
;###############################################################################
;# Version History:                                                            #
;#    April 23, 2009                                                           #
;#      - Initial release                                                      #
;###############################################################################
;# Required Modules:                                                           #
;#    BASE - S12CBase framework                                                #
;#    FCORE - Forth core words                                                 #
;#    FMEM - Forth memories                                                    #
;#    FEXCPT - Forth exceptions                                                #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################

;###############################################################################
;# Memory Layout                                                               #
;###############################################################################
;        
;      	                    +--------------+--------------+
;        FMEM_VARS_START -> |            HERE             |
;      	                    +--------------+--------------+
;                           |             PSP             |
;      	                    +--------------+--------------+
;                           |             RSP             |
;      	                    +--------------+--------------+          
;                           |             PAD             |          
;      	                    +--------------+--------------+	     
;                           |             HLD             |          
;      	                    +--------------+--------------+	     
;                           |         NUMBER_TIB          |          
;      	                    +--------------+--------------+          
;                           |            TO_IN            |	     
;      	                    +--------------+--------------+	     
;    	     UDICT_START -> |              |              | 	     
;                           |       User Dictionary       |	     
;                           |              |              |	     
;                           |              v              |	     
;                           | --- --- --- --- --- --- --- |	     
;                           |                             | <- [HERE], CP  
;                           | --- --- --- --- --- --- --- |          
;                           |              ^              | <- [HLD]	     
;                           |             PAD             |	     
;                           | --- --- --- --- --- --- --- |          
;                           |                             | <- [PAD]          
;                           .                             .          
;                           .                             .          
;                           | --- --- --- --- --- --- --- |          
;                           |              ^              | <- [PSP]	  
;                           |              |              |		  
;                           |       Parameter stack       |		  
;    	                    |              |              |		  
;              PS_EMPTY,    +--------------+--------------+        
;              TIB_START -> |              |              | |          
;                           |       Text Input Buffer     | | [TIB_CNT]
;                           |              |              | |	       
;                           |              v              | <	       
;                           | --- --- --- --- --- --- --- | 	       
;                           .                             . <- [TIB_START+TIB_CNT]	       
;                           .                             .            
;                           | --- --- --- --- --- --- --- |            
;                           |              ^              | <- [RSP]
;                           |              |              |
;                           |        Return Stack         |
;                           |              |              |
;               RS_EMPTY,   +--------------+--------------+
;          FMEM_VARS_END ->                                 

;###############################################################################
;# Constants                                                                   #
;###############################################################################
	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
			ORG	FSCI_VARS_START
FSCI_VARS_END		EQU	*

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	FSCI_INIT, 0
#emac

;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG	FSCI_CODE_START
FSCI_CODE_END		EQU	*
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG	FSCI_TABS_START
FSCI_TABS_END		EQU	*

;###############################################################################
;# Forth words                                                                 #
;###############################################################################
			ORG	FSCI_WORDS_START

FSCI_WORDS_END		EQU	*
FSCI_LAST_NFA		EQU	FSCI_PREV_NFA
