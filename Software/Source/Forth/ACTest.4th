\ ###############################################################################
\ # AriCalculator - Top Level Source File for Code Development                  #
\ ###############################################################################
\ #    Copyright 2015 Dirk Heisswolf                                            #
\ #    This file is part of the AriCalculator's operating system.               #
\ #                                                                             #
\ #    The AriCalculator's operating system is free software: you can           #
\ #    redistribute it and/or modify it under the terms of the GNU General      #
\ #    Public License as published bythe Free Software Foundation, either       #
\ #    version 3 of the License, or (at your option) any later version.         #
\ #                                                                             #
\ #    The AriCalculator's operating system is distributed in the hope that it  #
\ #    will be useful, but WITHOUT ANY WARRANTY; without even the implied       #
\ #    warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See    #
\ #    the GNU General Public License for more details.                         #
\ #                                                                             #
\ #    You should have received a copy of the GNU General Public License        #
\ #    along with the AriCalculator's operating system.  If not, see            #
\ #    <http://www.gnu.org/licenses/>.                                          #
\ ###############################################################################
\ # Description:                                                                #
\ #   This main source file of the AriCalculatior OS.                           #
\ #   It includes all further source files for compilation on PC based Forth    #
\ #   systems like GForth or SwiftForth.                                        #
\ ###############################################################################
\ # Version History:                                                            #
\ #    April 10, 2015                                                           #
\ #      - Initial release                                                      #
\ ###############################################################################
\ # Required Word Sets:                                                         #
\ #    Gforth/SwiftForth - INCLUDE word                                         #
\ #    ANSForth          - CORE word set                                        #
\ #                        CORE EXT word set                                    #
\ #    Stack             - Supplemental stack operations                        #
\ #    NCell             - Multi-cell operations                                #
\ #    FracFloat         - Fractional floating point number support             #
\ #                                                                             #
\ ###############################################################################

\ ###############################################################################
\ # Configuration                                                               #
\ ###############################################################################
DECIMAL

\ ###############################################################################
\ # Constants                                                                   #
\ ###############################################################################
    
\ ###############################################################################
\ # Variables                                                                   #
\ ###############################################################################
    
\ ###############################################################################
\ # Code                                                                        #
\ ###############################################################################
MARKER ACREMOVE                 \ remove AC code from dictionary

INCLUDE Stack.4th               \ compile supplemental stack words
INCLUDE NCell.4th               \ compile multi-cell words
INCLUDE FracFloat.4th           \ compile fractional floating point number words


: DEMO
8 7 6 5 4 3 2 1 0 .s ;