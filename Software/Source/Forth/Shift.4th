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
\ BITS/CELL
\ # Cell size in bits
MARKER FORGET-BITS/CELL-CALCULATION
:NONAME ( -- u )
0 1                                     \ test cell and bit count
BEGIN                                   \ iterate over bits
    DUP                                 \ check test cell
WHILE                                   \ iterate until all bits are cleared
    2* SWAP                             \ shift test cell
    1+ SWAP                             \ increment bit count
REPEAT                                  \ next iteration
DROP ;                                  \ clean up
EXECUTE FORGET-BITS/CELL-CALCULATION
CONSTANT BITS/CELL

\ ###############################################################################
\ # Variables                                                                   #
\ ###############################################################################
    
\ ###############################################################################
\ # Code                                                                        #
\ ###############################################################################

\ # Helper functions ############################################################
\ BITS/CELL*
\ # Multiply by the number of bits per cell.
\ # args:   u1: number
\ # result: u2: u1 * BITS/CELL
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: BITS/CELL* ( u1 -- u2 ) \ PUBLIC
BITS/CELL * ;

\ # Alignment Operations ########################################################

\ CL0
\ # Count leading zeros.
\ # args:   x: data
\ # result: n: number of leading zeros in x (-1 if x=0)
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: CL0 ( x -- n ) \ PUBLIC
-1 SWAP                                 \ default count
BITS/CELL 0 DO                          \ iterate over bits in cell
    DUP 0< IF                           \ check if MSB is set
        DROP I SWAP LEAVE               \ first one found
    THEN                                \ MSB check complete
    2*                                  \ shift cell towards MSB
LOOP                                    \ next iteration
DROP ;                                  \ clean up

\ CT0
\ # Count trailing zeros.
\ # args:   x: data
\ # result: n: number of trailing zeros in x (-1 if x=0)
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: CT0 ( x -- n ) \ PUBLIC
-1 SWAP                                 \ default count
BITS/CELL 0 DO                          \ iterate over bits in cell
    DUP 1 AND IF                        \ check if MSB is set
        DROP I SWAP LEAVE               \ first one found
    THEN                                \ MSB check complete
    1 RSHIFT                            \ shift cell towards LSB
LOOP                                    \ next iteration
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
BITS/CELL SWAP - RSHIFT ;               \ calculate x3 (carry over)

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
2DUP BITS/CELL SWAP -                   \ calculate x2 (carry over)
LSHIFT UNROT RSHIFT ;                   \ calculate x3 (result)
