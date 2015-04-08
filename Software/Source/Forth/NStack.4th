\ ###############################################################################
\ # AriCalculator - Stack Operations for Multi-Cell Data Structures             #
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
\ #   This module implements stacking operations for multi-cell data            #
\ #   structures.                                                               #
\ #                                                                             #
\ # Data types:                                                                 #
\ #   size       - unsigned single-cell integer                                 #
\ #   struc      - any multi-cell data structure                                #
\ ###############################################################################
\ # Version History:                                                            #
\ #    April 8, 2015                                                            #
\ #      - Initial release                                                      #
\ ###############################################################################
\ # Required Modules:                                                           #
\ #    ANSForth - CORE word set                                                 #
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
\ Drop a multi-cell data structure
\ # args:   size:  size of struc (in cells)
\ #         struc: data structure
\ # result: --
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NDROP ( size struc -- )               \ PUBLIC
1+ CELLS SP@ + SP! ;

\ Duplicate a multi-cell data structure from within the parameter stack
\ # args:   size1:  size of struc1 (in cells)
\ #         size2:  size of struc2 (in cells)
\ #         struc2: data structure
\ #         struc1: data structure
\ # result: struc1: duplicate data structure
\ #         struc2: data structure
\ #         struc1: data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NPICK ( struc1 struc2 size2 size1 -- struc1 struc2 struc1 ) \ PUBLIC
DUP ROT +                             \ calculate PICK offset
SWAP 0 DO                             \ repeat size1 times
     DUP PICK SWAP                    \ pick one cell
LOOP                                  \ loop
DROP ;                                \ drop PICK offset

\ Rotate over multiple multi-cell data structures
\ # args:   size:     size of each struc (in cells)
\ #         u:        number of structs to rotate
\ #         struc0:   data structure
\ #         ...
\ #         strucu:   data structure
\ # result: strucu:   data structure
\ #         struc0:   data structure
\ #         ...
\ #         strucu-1: data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         result out of range (-11)
: NROLL ( strucu ... struc0 u size -- strucu-1 ...  struc0 strucu ) \ PUBLIC
DUP ROT *                             \ calculate ROLL offset
SWAP 0 DO                             \ repeat size times
    DUP ROLL SWAP                     \ rotate one cell
LOOP
DROP ;                                \ drop ROLL offset

\ Duplicate last multi-cell data structure
\ # args:   size:  size of struc (in cells)
\ #         struc: data structure
\ # result: struc: duplicate data structure
\ #         struc: data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NDUP ( struc size -- struc struc)  \ PUBLIC
0 SWAP NPICK ;

\ Duplicate previous multi-cell data structure
\ # args:   size:   size of struc1 and struc2 (in cells)
\ #         struc2: data structure
\ #         struc1: data structure
\ # result: struc1: duplicate data structure
\ #         struc2: data structure
\ #         struc1: data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NOVER ( struc1 struc2 size -- struc1 struc2 struc1 )  \ PUBLIC
DUP NPICK ;

\ Swap two multi-cell data structure
\ # args:   size:   size of struc1 and struc2 (in cells)
\ #         struc1: data structure
\ #         struc2: data structure
\ # result: struc2: data structure
\ #         struc1: data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NSWAP ( struc2 struc1 size -- struc1 struc2 )  \ PUBLIC
1 SWAP NROLL ;

\ ROTATE over three multi-cell data structures
\ # args:   size:   size of struc1, struc2, and struc3 (in cells)
\ #         struc3: data structure
\ #         struc2: data structure
\ #         struc1: data structure
\ # result: struc1: data structure
\ #         struc3: data structure
\ #         struc2: data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NROT ( struc1 struc2 struc3 size -- struc2 struc3 struc1 )   \ PUBLIC
2 SWAP NROLL ;
