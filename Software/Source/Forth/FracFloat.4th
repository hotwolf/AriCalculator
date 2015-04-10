\ ###############################################################################
\ # AriCalculator - Fractional Floating Point Number Format                     #
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
\ #   This module contains the definition and basic manipulation routines for   #
\ #   the Fractional Float number format.                                       #
\ #                                                                             #
\ # Data types:                                                                 #
\ #   ff         - fractional floating point number                             #
\ ###############################################################################
\ # Version History:                                                            #
\ #    April 1, 2015                                                            #
\ #      - Initial release                                                      #
\ ###############################################################################
\ # Required Word Sets:                                                         #
\ #    ANSForth - CORE words                                                    #
\ #    NStack   - Stack Operations for Multi-Cell Data Structures               #
\ #    Quad     - Quad cell number operations                                   #
\ ###############################################################################
\ #                                                                             #
\ # Number Format:                                                              #
\ # ==============                                                              #
\ #                                                                             #
\ #     ^  +-----------------+                                                  #
\ #     |  |      info       | +0 CELLS   FF-INFO                               #
\ #     |  +-----------------+                                                  #
\ #   8 |  |     exponent    | +1 CELLS   FF-EXP                                #
\ #   W |  +-----------------+                                                  #
\ #   O |  |                 | +2 CELLS   FF-NOM-H                              #
\ #   R |  |    Nominator    | +3 CELLS   FF-NOM-M                              #
\ #   D |  |                 | +4 CELLS   FF-NOM-L                              #
\ #   S |  +-----------------+                                                  #
\ #     |  |                 | +5 CELLS   FF-DNOM-H                             #
\ #     |  |   Denominator   | +6 CELLS   FF-DNOM-M                             #
\ #     |  |                 | +7 CELLS   FF-DNOM-L                             #
\ #     v  +-----------------+                                                  #
\ #                                                                             #
\ #                                                                             #
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

\ # Stack Operations ############################################################

\ Drop last fractional float number
\ # args:   ff: fractional float number
\ # result: --
\ # throws: stack overflow (-3)
\           stack underflow (-4)
: FFDROP ( ff -- )			\ PUBLIC
8 NDROP ;

\ Duplicate last fractional float number
\ # args:   ff: fractional float number
\ # result: ff: duplicated fractional float number
\ #         ff: fractional float number
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: FFDUP ( ff -- ff ff)  \ PUBLIC
8 NDUP ;

\ Duplicate previous fractional float number
\ # args:   ff2: fractional float number
\ #         ff1: fractional float number
\ # result: ff1: duplicated fractional float number 
\ #         ff2: fractional float number
\ #         ff1: fractional float number
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: FFOVER ( ff1 ff2 -- ff1 ff2 ff1 )  \ PUBLIC
8 NOVER ;

\ Swap two fractional float numbers
\ # args:   ff1: fractional float number
\ #         ff2: fractional float number
\ # result: ff2: fractional float number
\ #         ff1: fractional float number
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: FFSWAP ( ff2 ff1 -- ff1 ff2 )  \ PUBLIC
8 NSWAP ;

\ ROTATE over three fractional float numbers
\ # args:   ff3: fractional float number
\ #         ff2: fractional float number
\ #         ff1: fractional float number
\ # result: ff1: fractional float number
\ #         ff3: fractional float number
\ #         ff2: fractional float number
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: FFROT ( ff1 ff2 ff3 -- ff2 ff3 ff1 )   \ PUBLIC
8 NROT ;

\ Rotate over multiple fractional float numbers
\ # args:   u:     number of FF numbers to rotate
\ #         ff0:   fractional float number
\ #         ...
\ #         ffu:   fractional float number
\ # result: ffu:   fractional float number
\ #         ff0:   fractional float number
\ #         ...
\ #         ffu-1: fractional float number
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         result out of range (-11)
: FFROLL ( ffu ... ff0 u -- ffu-1 ...  ff0 ffu ) \ PUBLIC
8 NROLL ;

\ # Quad-Cell Operations ########################################################

\ Extract a quad-cell value from a fractional float number
\ # args:   u:  cell offset (relative to ff)
\ #         ff: number
\ # result: qu: quad-cell value
\ #         ff: number
\ # throws: stack overflow (-3)
\           stack underflow (-4)
: FFEXTQ ( ff u -- ff qu )
0 SWAP					\ push most significant cell (=0)
1+ 3 NPICK				\ extract tripple-cell number from FF
Q2*  					\ left shift quad number 
Q1+ ;					\ set least significant bit

\ Insert a quad-cell value into a fractional float number
\ # args:   u:  cell offset (relative to ff)
\ #         qu: quad-cell value
\ #         ff: number
\ # result: ff: resulting numbernumber
\ # throws: stack overflow (-3)
\           stack underflow (-4)
: FFINSQ ( ff qu u -- ff )




;




