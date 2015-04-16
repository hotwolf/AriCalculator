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
\ #   uq         - unsugned quad cell number number                             #
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

\ FFDROP
\ #Drop last fractional float number
\ # args:   ff: fractional float number
\ # result: --
\ # throws: stack overflow (-3)
\           stack underflow (-4)
: FFDROP ( ff -- )			\ PUBLIC
8 NCDROP DROP ;

\ FFDUP
\ Duplicate last fractional float number
\ # args:   ff: fractional float number
\ # result: ff: duplicated fractional float number
\ #         ff: fractional float number
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: FFDUP ( ff -- ff ff)  \ PUBLIC
8 NCDUP DROP ;

\ NCOVER
\ Duplicate previous fractional float number
\ # args:   ff2: fractional float number
\ #         ff1: fractional float number
\ # result: ff1: duplicated fractional float number 
\ #         ff2: fractional float number
\ #         ff1: fractional float number
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: FFOVER ( ff1 ff2 -- ff1 ff2 ff1 )  \ PUBLIC
8 NCOVER DROP ;

\ FFSWAP
\ Swap two fractional float numbers
\ # args:   ff1: fractional float number
\ #         ff2: fractional float number
\ # result: ff2: fractional float number
\ #         ff1: fractional float number
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: FFSWAP ( ff2 ff1 -- ff1 ff2 )  \ PUBLIC
8 NCSWAP DROP ;

\ FFROT
\ Rotate over three fractional float numbers
\ # args:   ff3: fractional float number
\ #         ff2: fractional float number
\ #         ff1: fractional float number
\ # result: ff1: fractional float number
\ #         ff3: fractional float number
\ #         ff2: fractional float number
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: FFROT ( ff1 ff2 ff3 -- ff2 ff3 ff1 )   \ PUBLIC
8 NCROT DROP ;

\ FFROLL
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
8 NCROLL DROP ;

\ # Quad-Cell Operations ########################################################

\ FFPICKQ
\ Extract a quad-cell value from a nominator or denominator field
\ # args:   u:  cell offset
\ #         ...
\ #         ff: number
\ # result: q:  unsigned quad-cell value
\ #         ...
\ #         ff: number
\ # throws: stack overflow (-3)
\           stack underflow (-4)
: FFPICKQ ( ff ... u -- ff ... q )      \ public
3 MPICK                                 \ pick nominator/denominator field
0 4 NC2*1+ DROP ;                       \ shift value

\ FFPLACEQ
\ Insert a quad-cell value into a fractional float number
\ # args:   u:  cell offset (relative to ff)
\ #         u:  quad-cell value
\ #         ...
\ #         ff1: number
\ # result: ...
\ #         ff2: resulting number
\ # throws: stack overflow (-3)
\           stack underflow (-4)
: FFPLACEQ ( ff1 ... q -- ff2 ... ) \ PUBLIC
4 UNROLL                                \ move u out of the way
4 NC2/ 2DROP                            \ shift value
3 ROLL                                  \ retrieve u                               
3 MPLACE ;                              \ place nominator/denominator field

\ # Arithetic Operations ########################################################

