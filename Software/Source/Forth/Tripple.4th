/###############################################################################
/# AriCalculator - Tripple-Number Words                                        #
/###############################################################################
/#    Copyright 2010-2015 Dirk Heisswolf                                       #
/#    This file is part of the AriCalculator's operating system.               #
/#                                                                             #
/#    The AriCalculator's operating system is free software: you can           #
/#    redistribute it and/or modify it under the terms of the GNU General      #
/#    Public License as published bythe Free Software Foundation, either       #
/#    version 3 of the License, or (at your option) any later version.         #
/#                                                                             #
/#    The AriCalculator's operating system is distributed in the hope that it  #
/#    will be useful, but WITHOUT ANY WARRANTY; without even the implied       #
/#    warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See    #
/#    the GNU General Public License for more details.                         #
/#                                                                             #
/#    You should have received a copy of the GNU General Public License        #
/#    along with the AriCalculator's operating system.  If not, see            #
/#    <http://www.gnu.org/licenses/>.                                          #
/###############################################################################
/# Description:                                                                #
/#   This module contains the definition and basic manipulation routines for   #
/#   the Fractional Float number format.                                       #
/###############################################################################
/# Version History:                                                            #
/#    April 2, 2015                                                            #
/#      - Initial release                                                      #
/###############################################################################
/# Required Modules:                                                           #
/#    ANSForth                                                                 #
/###############################################################################
/#                                                                             #
/# Tripple Cell:                                                               #
/# =============                                                               #
/#                                                                             #
/#          +-----------------+                                                #
/#     PSP->|       high      | + 0 CELLS                                      #
/#          +-----------------+                                                #
/#          |       mid       | + 2 CELLS                                      #
/#          +-----------------+                                                #
/#          |       low       | + 4 CELLS                                      #
/#          +-----------------+                                                #
/#                                                                             #
/###############################################################################
/# Configuration                                                               #
/###############################################################################
	
/###############################################################################
/# Constants                                                                   #
/###############################################################################
DECIMAL
    
/###############################################################################
/# Variables                                                                   #
/###############################################################################
    
/###############################################################################
/# Code                                                                        #
/###############################################################################
    
/#Set arithmetic pointer
/# args:   none
/# result: none
/# throws: none
: SP>AP ( -- )
    SP@ AP ! ;             /copy SP to AP

/#Check if the word at addr is even
/# args:   addr (word address)
/# result: flag (true if even)
/# throws: none
: EVEN? ( addr -- flag)
    @                    /read word
    1 AND                /extract LSB
    1 -;                 /true if zero

/#Normalize nominator of FF at AP
/# args:   none
/# result: none
/# throws: none
: FF-NORM-NOM ( -- )
    DO
	AP FF-NOM-L + @ EVEN? /check if the low word of the denominator is even
    WHILE
	

	    
//#Normalize denominator of FF at AP
/# args:   none
/# result: none
/# throws: none
: FF-NORM-DNOM ( -- )
;



