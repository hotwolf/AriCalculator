\ ###############################################################################
\ # AriCalculator - Multi-Cell Data Operations                                  #
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
\ #   size  - unsigned single-cell integer (number of cells per data structure) #
\ #   struc - a data structure of "size" cells                                  #
\ ###############################################################################
\ # Version History:                                                            #
\ #    April 8, 2015                                                            #
\ #      - Initial release                                                      #
\ ###############################################################################
\ # Required Word Sets:                                                         #
\ #    ANSForth                    - CORE word set                              #
\ #                                  #CORE EXT word set                          #
\ #                                  #DOUBLE word set                            #
\ #                                  #DOUBLE EXT word set                        #
\ #    S12CForth/GForth/SwiftForth - SP@ and SP! word                           #
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

\ # Stack Operations ############################################################

\ NDROP
\ # Remove a multi-cell data structure from TOS
\ # args:   size:  size of struc (in cells)
\ #         struc: data structure
\ # result: --
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NDROP ( struc size -- )               \ PUBLIC
1+ CELLS SP@ + SP! ; 			\ remove data structure from TOS

\ NPICK
\ # Duplicate a multi-cell data structure from within the parameter stack
\ # args:   size:   size of data structures (in cells)
\ #         u:      position of data structure to be copied
\ #         struc0: data structure
\ #         struc1: data structure
\ #         ...
\ #         strucu: data structure to be duplicated
\ # result: strucu: duplicated data structure
\ #         struc0: data structure
\ #         struc1: data structure
\ #         ...
\ #         strucu: duplicated data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         result out of range (-11)
: NPICK ( strucu ... struc1 struc0 u size -- strucu ... struc1 struc0 strucu )  \ PUBLIC
DUP ROT 1+ *                          \ calculate PICK offset
SWAP 0 DO                             \ iterate size times
    DUP PICK SWAP                     \ pick one cell
LOOP                                  \ next iteration
DROP ;                                \ drop PICK offset

\ NPLACE
\ # Opposite of NPICK. Replace a multi-cell data structure anywhere on the
\ # parameter stack.
\ # args:   size:     size of data structures (in cells)
\ #         u:        position of data structure to be replaced
\ #         strucu':  data structure to replace strucu
\ #         struc0:   data structure
\ #         struc1:   data structure
\ #         ...
\ #         strucu-1: data structure
\ #         strucu:   data structure to be replaced
\ # result: struc0:   data structure
\ #         struc1:   data structure
\ #         ...
\ #         strucu-1: data structure
\ #         strucu':  data structure which replaced strucu
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         result out of range (-11)
: NPLACE ( strucu strucu-1 ... struc1 struc0 u size -- strucu' strucu-1... struc1 struc0 ) \ PUBLIC
DUP ROT 1+ *                          \ calculate PLACE offset
SWAP 0 DO                             \ iterate size times
    DUP ROT SWAP PLACE                \ place one cell
LOOP                                  \ next iteration
DROP ;                                \ drop PLACE offset

\ NROLL
\ #Rotate over multiple multi-cell data structures
\ # args:   size:     size of each struc (in cells)
\ #         u:        number of structs to rotate
\ #         struc0:   data structure
\ #         ...
\ #         strucu:   data structure to be wrapped
\ # result: strucu:   wrapped data structure
\ #         struc0:   data structure
\ #         ...
\ #         strucu-1: data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         result out of range (-11)
: NROLL ( strucu ... struc0 u size -- strucu-1 ...  struc0 strucu ) \ PUBLIC
DUP ROT 1+ *                          \ calculate ROLL offset
SWAP 0 DO                             \ iterate size times
    DUP ROLL SWAP                     \ rotate one cell
LOOP                                  \ next iteration
DROP ;                                \ drop ROLL offset

\ NUNROLL
\ # Opposite of NROLL. Insert a multi-cell data structure anywhere into the
\ # parameter stack.
\ # args:   size:     size of each struc (in cells)
\ #         u:        number of structs to rotate
\ #         strucu:   data structure to be wrapped
\ #         struc0:   data structure
\ #         ...
\ #         strucu-1: data structure
\ # result: struc0:   data structure
\ #         ...
\ #         strucu-1: data structure
\ #         strucu:   wrappeddata structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         result out of range (-11)
: NUNROLL ( strucu-1 ... struc0  strucu u size -- strucu ...  struc0 ) \ PUBLIC
DUP ROT 1+ *                          \ calculate UNROLL offset
SWAP 0 DO                             \ iterate size times
    TUCK UNROLL                       \ rotate one cell
LOOP                                  \ next iteration
DROP ;                                \ drop UNROLL offset

\ NREMOVE
\ # Remove a multi-cell data structure anywhere from the parameter stack.
\ # args:   size:     size of each struc (in cells)
\ #         u:        number of structs to rotate
\ #         struc0:   data structure
\ #         ...
\ #         strucu:   data structure to be dropped
\ # result: struc0:   data structure
\ #         ...
\ #         strucu-1: shifted data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         result out of range (-11)
: NREMOVE ( strucu ... struc0 u size -- strucu-1 ...  struc0 ) \ PUBLIC
DUP ROT 1+ *                          \ calculate REMOVE offset
SWAP 0 DO                             \ iterate size times
    DUP I - REMOVE                    \ rotate one cell
LOOP                                  \ next iteration
DROP ;                                \ drop REMOVE offset

\ NDUP
\ #Duplicate last multi-cell data structure
\ # args:   size:   size of each struc (in cells)
\ #         struc: data structure
\ # result: struc: duplicated data structure
\ #         struc: data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NDUP ( struc size -- struc struc)  \ PUBLIC
0 SWAP NPICK ;

\ NOVER
\ #Duplicate previous multi-cell data structure
\ # args:   size:   size of each struc (in cells)
\ #         struc2: data structure
\ #         struc1: data structure
\ # result: struc1: duplicated data structure
\ #         struc2: data structure
\ #         struc1: data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NOVER ( struc1 struc2 size -- struc1 struc2 struc1 )  \ PUBLIC
1 SWAP NPICK ;

\ UNTESTED:

\ Swap two multi-cell data structure
\ # args:   size:   size of each struc (in cells
\ #         struc2: data structure
\ #         struc1: data structure
\ # result: struc1: swapped data structure
\ #         struc2: swapped data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NSWAP ( struc1 struc2 size -- struc2 struc1 )  \ PUBLIC
1 SWAP NROLL ;

\ NROLL
\ #ROTATE over three multi-cell data structures
\ # args:   size:   size of each struc (in cells)
\ #         struc3: data structure to
\ #         struc2: data structure to
\ #         struc1: data structure to be wrapped
\ # result: struc1: data structure
\ #         struc3: data structure
\ #         struc2: wrapped data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NROT ( struc1 struc2 struc3 size -- struc2 struc3 struc1 )   \ PUBLIC
2 SWAP NROLL ;

\ NNIP
\ # Remove the first multi-cell data structure below the TOS
\ # args:   size:  size of each struc (in cells)
\ #         struc2: data structure
\ #         struc1: data structure to be removed
\ # result: struc2: data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NNIP ( struc1 struc2 size -- struc2 ) \ PUBLIC
1 SWAP NREMOVE ;

\ NTUCK
\ # Copy the first multi-cell data structure below the second one
\ # args:   size:  size of each struc (in cells)
\ #         struc2: data structure
\ #         struc1: data structure
\ # result: struc2: data structure
\ #         struc1: data structure
\ #         struc2: duplicated data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NTUCK ( struc1 struc2 size -- struc2 ) \ PUBLIC
1 SWAP NPLACE ;


\ # Compare Operations ############################################################

\ N0=
\ # Check if all bits in multi-cell data structure are zero
\ # args:   size:  size of each struc (in cells)
\ #         struc: data structure
\ # result: flag:  true if all bits in data structure are zero
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: N0= ( struc size -- flag ) \ PUBLIC
1 DO  	      	      	     \ iterate size-1 times
    OR                       \ combine two cells
LOOP                         \ next iteration
0= ;                         \ check if combined cells are zero

\ N0<
\ # Interpret data multi-cell data structure as signed integer and check if it
\ # is greater than zero
\ # args:   size:  size of each struc (in cells)
\ #         struc: data structure
\ # result: flag:  true value is greater than zero
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: N0< ( struc size -- flag )         \ PUBLIC
OVER [ -1 2/ INVERT ] LITERAL AND 0= \ check if sign bit is set
IF                                   \ negative value
    NDROP FALSE                      \ remove structure and return false
ELSE                                 \ positive value
    N0= INVERT                       \ check if value is zero
THEN ;                               \ done

\ N=
\ # Check two multi-cell data structure are equal
\ # args:   size:   size of each struc (in cells)
\ #         struc2: data structure
\ #         struc1: data structure
\ # result: flag:  true equal
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ : N= ( struc1 struc2 size -- flag ) \ PUBLIC






\ N<
\ # Check two multi-cell data structure are equal
\ # args:   size:   size of each struc (in cells)
\ #         struc2: data structure
\ #         struc1: data structure
\ # result: flag:  true equal
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ : N< ( struc1 struc2 size -- flag ) \ PUBLIC




\ N< N> NU> NU<



\ # Logic Operations ############################################################

\ NCAND NCOR NCXOR NINVERT 


\ NCAND
\ # Bitwise AND of two multi-cell data structures
\ # args:   size:   size of each struc (in cells)
\ #         struc2: data structure
\ #         struc1: data structure
\ # result: struc3: resulting data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ : NCAND ( struc1 struc2 size -- struc3 ) \ PUBLIC
\ DUP DO	  	 	     	       \ iterate over structure size



\ # Arithmetic Operations #######################################################

