/###############################################################################
/# AriCalculator - Fractional Float Number Format                              #
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
/#    April 1, 2015                                                            #
/#      - Initial release                                                      #
/###############################################################################
/# Required Modules:                                                           #
/#    ANSForth                                                                 #
/#    Tripple      - Trpple cell numbers                                       #
/###############################################################################
/#                                                                             #
/# Number Format:                                                              #
/# ==============                                                              #
/#                                                                             #
/#     ^  +-----------------+                                                  #
/#     |  |      info       | +0 FF-INFO                                       #
/#     |  +-----------------+                                                  #
/#   8 |  |     exponent    | +2 FF-EXP                                        #
/#   W |  +-----------------+                                                  #
/#   O |  |                 | +4 FF-NOM-H                                      #
/#   R |  |    Nominator    | +6 FF-NOM-M                                      #
/#   D |  |                 | +8 FF-NOM-L                                      #
/#   S |  +-----------------+                                                  #
/#     |  |                 | +A FF-DNOM-H                                     #
/#     |  |   Denominator   | +C FF-DNOM-M                                     #
/#     |  |                 | +E FF-DNOM-L                                     #
/#     v  +-----------------+                                                  #
/#                                                                             #
/#                                                                             #
/###############################################################################
/# Configuration                                                               #
/###############################################################################
	
/###############################################################################
/# Constants                                                                   #
/###############################################################################
DECIMAL
 2 CONSTANT FF-EXP         /offset of exponent in FF number
 4 CONSTANT FF-NOM-H       /offset of nominator in FF format   (high word)
 6 CONSTANT FF-NOM-M       /offset of nominator in FF format   (middle word)
 8 CONSTANT FF-NOM-L       /offset of nominator in FF format   (low word)
10 CONSTANT FF-DNOM-H      /offset of denominator in FF format (high word)
12 CONSTANT FF-DNOM-M      /offset of denominator in FF format (middle word)
14 CONSTANT FF-DNOM-L      /offset of denominator in FF format (low word)
    
/###############################################################################
/# Variables                                                                   #
/###############################################################################
VARIABLE AP               /Arithmetic stack pointer
    
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



