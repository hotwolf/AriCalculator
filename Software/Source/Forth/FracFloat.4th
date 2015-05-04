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
\ #   uq         - unsigned quad cell number number                             #
\ #   info       - info field of a fractional floating point number             #
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

\ FFINFO-POSITIVE
\ # Positive sign field.
\ # args:   --
\ # result: info: positive info field
\ # throws: stack overflow (-3)
$0001 CONSTANT FFINFO-POSITIVE

\ FFINFO-NEGATIVE
\ # Negative sign field.
\ # args:   --
\ # result: info: negative info field
\ # throws: stack overflow (-3)
$0003 CONSTANT FFINFO-NEGATIVE

\ FFINFO-PI
\ # Number is multiple of Pi.
\ # args:   --
\ # result: info: pi info field
\ # throws: stack overflow (-3)
$0004 CONSTANT FFINFO-PI

\ FFINFO-APPROX
\ # Number is an approximation.
\ # args:   --
\ # result: info: approximation info field
\ # throws: stack overflow (-3)
$0008 CONSTANT FFINFO-APPROX

\ FFPI
\ # Push an approximation of pi onto the stack.
\ # 428224593349304/136308121570117 = 3.14159265358979323846264338327569743446
\ # Error: 0.00000000000000000000000000000380544973 (exact by 29 decimal digits)
\ # Nominator (hex):   18577CEC54AB *16+1
\ # Denominator (hex): 3DFC5A9545A2 *2+1
\ # args:   --
\ # result: ff: approximation of pi
\ # throws: stack overflow (-3)
: FFPI ( -- ff ) \ PUBLIC
$45A2                                   \ denominator (least significant cell) 
$5A95                                   \ denominator 
$3DFC                                   \ denominator (most significant cell) 
$54AB                                   \ nominator (least significant cell) 
$7CEC                                   \ nominator
$1857                                   \ nominator (most significant cell) 
3                                       \ exponent (2^3)
[ FFINFO-POSITIVE                       \ positive number 
  FFINFO-APPROX   OR]                   \ approximation
LITERAL ;

\ ###############################################################################
\ # Variables                                                                   #
\ ###############################################################################
    
\ ###############################################################################
\ # Code                                                                        #
\ ###############################################################################

\ # Stack Operations ############################################################

\ FFDROP
\ # Drop last fractional float number.
\ # args:   ff: fractional float number
\ # result: --
\ # throws: stack underflow (-4)
: FFDROP ( ff -- ) \ PUBLIC
8 SDEALLOC ;

\ FF2DROP
\ # Drop last two fractional float numbers.
\ # args:   ff2: fractional float number
\ #         ff1: fractional float number
\ # result: --
\ # throws: stack underflow (-4)
: FF2DROP ( ff1 ff2 -- ) \ PUBLIC
$10 SDEALLOC ;

\ FFDUP
\ # Duplicate last fractional float number.
\ # args:   ff: fractional float number
\ # result: ff: duplicated fractional float number
\ #         ff: fractional float number
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: FFDUP ( ff -- ff ff) \ PUBLIC
8 NCDUP ;

\ FF2DUP
\ # Duplicate last two fractional float numbers.
\ # args:   ff2: fractional float number
\ #         ff1: fractional float number
\ # result: ff2: duplicated fractional float number
\ #         ff1: duplicated fractional float number
\ #         ff2: fractional float number
\ #         ff1: fractional float number
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: FF2DUP ( ff1 ff2 -- ff1 ff2 ff1 ff2 ) \ PUBLIC
$10 NCDUP ;

\ NCOVER
\ # Duplicate previous fractional float number.
\ # args:   ff2: fractional float number
\ #         ff1: fractional float number
\ # result: ff1: duplicated fractional float number 
\ #         ff2: fractional float number
\ #         ff1: fractional float number
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: FFOVER ( ff1 ff2 -- ff1 ff2 ff1 ) \ PUBLIC
8 NCOVER ;

\ NC2OVER
\ # Duplicate previous fractional float numper pair.
\ # args:   ff4: fractional float number
\ #         ff3: fractional float number
\ #         ff2: fractional float number
\ #         ff1: fractional float number
\ # result: ff1: duplicated fractional float number 
\ #         ff2: duplicated fractional float number
\ #         ff4: fractional float number
\ #         ff3: fractional float number
\ #         ff2: fractional float number
\ #         ff1: fractional float number
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: FF2OVER ( ff1 ff2 ff3 ff4 -- ff1 ff2 ff3 ff4 ff1 ff2 ) \ PUBLIC
$10 NCOVER ;

\ FFSWAP
\ # Swap two fractional float numbers.
\ # args:   ff2: fractional float number
\ #         ff1: fractional float number
\ # result: ff1: fractional float number
\ #         ff2: fractional float number
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: FFSWAP ( ff1 ff2 -- ff1 ff1 ) \ PUBLIC
8 NCSWAP ;

\ FF2SWAP
\ # Swap two fractional float number pairs.
\ # args:   ff4: fractional float number
\ #         ff3: fractional float number
\ #         ff2: fractional float number
\ #         ff1: fractional float number
\ # result: ff2: fractional float number
\ #         ff1: fractional float number
\ #         ff4: fractional float number
\ #         ff3: fractional float number
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: FF2SWAP ( ff1 ff2 ff3 ff4 -- ff3 ff4 ff1 ff2 ) \ PUBLIC
$10 NCSWAP ;

\ FFROT
\ # Rotate over three fractional float numbers.
\ # args:   ff3: fractional float number
\ #         ff2: fractional float number
\ #         ff1: fractional float number
\ # result: ff1: fractional float number
\ #         ff3: fractional float number
\ #         ff2: fractional float number
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: FFROT ( ff1 ff2 ff3 -- ff2 ff3 ff1 ) \ PUBLIC
8 NCROT ;

\ FF2ROT
\ # Rotate over three fractional float number pairs.
\ # args:   ff6: fractional float number
\ #         ff5: fractional float number
\ #         ff4: fractional float number
\ #         ff3: fractional float number
\ #         ff2: fractional float number
\ #         ff1: fractional float number
\ # result: ff2: fractional float number
\ #         ff1: fractional float number
\ #         ff6: fractional float number
\ #         ff5: fractional float number
\ #         ff4: fractional float number
\ #         ff3: fractional float number
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: FF2ROT ( ff1 ff2 ff3 ff4 ff5 ff6-- ff3 ff4 ff5 ff6 ff1 ff2 ) \ PUBLIC
$10 NCROT ;

\ FFPICK
\ # Duplicate a fractional float number from within the parameter stack.
\ # args:   size: size of data structures (in cells)
\ #         u:    position of data structure to be copied
\ #         ff0:  data structure
\ #         ...
\ #         ffu:  data structure to be duplicated
\ # result: ffu:  duplicated data structure
\ #         ff0:  data structure
\ #         ...
\ #         ffu:  duplicated data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         result out of range (-11)
: FFPICK ( ffu ... ff0 u size -- ffu ... ff0 ffu ) \ PUBLIC
8 NCPICK ;

\ FFPLACE
\ # Replace a fractional float number anywhere on the parameter stack.
\ # args:   u:     position of the cell to be replaced
\ #         ffu':  cell to replace xu  
\ #         ff0:   untouched cell
\ #         ...
\ #         ffu-1: untouched cell
\ #         ffu:   cell to be replaced
\ # result: ff0:   untouched cell
\ #         ...
\ #         ffu-1: untouched cell
\ #         ffu':  cell which replaced xu  
\ #         stack underflow (-4)
: FFPLACE ( ffu ffu-1 ... ff0 ffu' u -- ffu' ffu-1 ... ff0 ) \ PUBLIC
8 NCPLACE ;

\ FFROLL
\ # Rotate over multiple fractional float numbers.
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
8 NCROLL ;

\ FFUNROLL
\ # Opposite of FFROLL. Insert a fractional float number anywhere into the
\ # parameter stack.
\ # args:   u:     position of the insertion
\ #         ffu:   cell to be inserted
\ #         ff0:   untouched cell
\ #         ...
\ #         ffu-1: untouched cell
\ # result: ff0:   untouched cell
\ #         ...
\ #         ffu-1: untouched cell
\ #         ffu:   inserted cell
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: FFUNROLL ( ffu-1 ... ff0 ffu u -- ffu ffu-1 ... ff0 ) \ PUBLIC
8 NCUNROLL ;

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

