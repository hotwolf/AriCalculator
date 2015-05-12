\ ###############################################################################
\ # AriCalculator - Supplemental Shift Operations                               #
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
\ #   This module implements general purpose stack operations which are not     #
\ #   part of the ANSForh standard.                                             #
\ ###############################################################################
\ # Version History:                                                            #
\ #    April 10, 2015                                                           #
\ #      - Initial release                                                      #
\ ###############################################################################
\ # Required Word Sets:                                                         #
\ #    ANSForth                    - CORE word set                              #
\ #    S12CForth/GForth/SwiftForth - SP@ SP! >R >R 2>R 2R>                      #
\ #    Stack                       - Supplemental stack operations              #
\ ###############################################################################

\ ###############################################################################
\ # Configuration                                                               #
\ ###############################################################################
        
\ ###############################################################################
\ # Constants                                                                   #
\ ###############################################################################
    
\ ###############################################################################
\ # Variables                                                                   #
\ ###############################################################################
    
\ ###############################################################################
\ # Code                                                                        #
\ ###############################################################################

\ # Helper functions ############################################################
\ BITS/CELL
\ # Determine the cell size in bits
\ # args:   -
\ # result: u:  bits per cell
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: BITS/CELL ( -- u )
0 1                                     \ test cell and bit count
BEGIN                                   \ iterate over bits
    DUP                                 \ check test cell
WHILE                                   \ iterate until all bits are cleared
    2* SWAP                             \ shift test cell
    1+ SWAP                             \ increment bit count
REPEAT                                  \ next iteration
DROP ;                                  \ clean up

\ # Multi-Cell Operations #######################################################

\ MLSHIFT
\ # Perform a logical left shift of u bit-places on x1, giving x2 and carry over
\ # x3.
\ # args:   u:  shift distance
\ #         x1: data
\ # result: x3: carry over data
\ #         x2: data
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: MLSHIFT ( x1 u -- x2 x3 ) \ PUBLIC
2DUP LSHIFT UNROT                       \ calculate x2 (result)
[ BITS/CELL ] LITERAL SWAP - RSHIFT ;   \ calculate x3 (carry over)

\ MRSHIFT
\ # Perform a logical right shift of u bit-places on x1, giving x3 and carry over
\ # x2.
\ # args:   u:  shift distance
\ #         x1: data
\ # result: x3: carry over data
\ #         x2: data
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: MRSHIFT ( x1 u -- x2 x3 ) \ PUBLIC
2DUP [ BITS/CELL ] LITERAL SWAP -       \ calculate x2 (carry over)
LSHIFT UNROT RSHIFT ;                   \ calculate x3 (result)
