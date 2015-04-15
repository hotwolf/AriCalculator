\ ###############################################################################
\ # AriCalculator - Multi-Cell Data Operations                                  #
\ ###############################################################################
\ #    Copyright 2015 Dirk Heisswolf                                            #
\ #    This file is part of the AriCalculator's operating system.               #
\ #                                                                             #
\ #    The AriCalculator's operating system is free software: you can           #
\ #    redistribute it and/or modify it under the tems of the GNU General       #
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
\ #   size   - unsigned single-cell integer (cells per data structure)          #
\ #   struc  - a data structure of "size" cells                                 #
\ #   estruc - a data structure of "size+1" cells                                 #
\ #   dstruc - a data structure of "2*size" cells                               #
\ ###############################################################################
\ # Version History:                                                            #
\ #    April 8, 2015                                                            #
\ #      - Initial release                                                      #
\ ###############################################################################
\ # Required Word Sets:                                                         #
\ #    ANSForth                    - CORE word set                              #
\ #                                  #CORE EXT word set                          #
\ #                                  DOUBLE word set                            #
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

\ NCDROP
\ # Remove a multi-cell data structure from TOS
\ # args:   size:  size of struc (in cells)
\ #         struc: data structure
\ # result: size:  size of struc (in cells)
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NCDROP ( struc size -- size )         \ PUBLIC
DUP                                     \ duplicate size
1+ CELLS SP@ +                          \ calculate new sack pointer
TUCK !                                  \ save size    
SP! ; 			                \ set new stack pointer

\ NCPICK
\ # Duplicate a multi-cell data structure from within the parameter stack
\ # args:   size:   size of data structures (in cells)
\ #         u:      position of data structure to be copied
\ #         struc0: data structure
\ #         ...
\ #         strucu: data structure to be duplicated
\ # result: size:   size of data structures (in cells)
\ #         strucu: duplicated data structure
\ #         struc0: data structure
\ #         ...
\ #         strucu: duplicated data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         result out of range (-11)
: NCPICK ( strucu ... struc0 u size -- strucu ... struc0 strucu size ) \ PUBLIC
DUP ROT 1+ * 1+                         \ calculate PICK offset
OVER 0 DO                               \ iterate size times
    DUP PICK ROT ROT                    \ pick one cell
LOOP                                    \ next iteration
DROP ;                                  \ drop PICK offset

\ NCPLACE
\ # Opposite of NCPICK. Replace a multi-cell data structure anywhere on the
\ # parameter stack.
\ # args:   size:     size of data structures (in cells)
\ #         u:        position of data structure to be replaced
\ #         strucu':  data structure to replace strucu
\ #         struc0:   data structure
\ #         ...
\ #         strucu:   data structure to be replaced
\ # result: size:     size of data structures (in cells)
\ #         struc0:   data structure
\ #         ...
\ #         strucu-1: data structure
\ #         strucu':  data structure which replaced strucu
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         result out of range (-11)
: NCPLACE ( strucu ... struc0 strucu' u size -- strucu' strucu-1... struc0 size ) \ PUBLIC
DUP ROT 1+ * 1+                         \ calculate PLACE offset
OVER 0 DO                               \ iterate size times
    ROT OVER PLACE                      \ place one cell
LOOP                                    \ next iteration
DROP ;                                  \ drop PLACE offset

\ NCROLL
\ #Rotate over multiple multi-cell data structures
\ # args:   size:     size of each struc (in cells)
\ #         u:        number of structs to rotate
\ #         struc0:   data structure
\ #         ...
\ #         strucu:   data structure to be wrapped
\ # result: size:     size of each struc (in cells)
\ #         strucu:   wrapped data structure
\ #         struc0:   data structure
\ #         ...
\ #         strucu-1: data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         result out of range (-11)
: NCROLL ( strucu ... struc0 u size -- strucu-1 ... struc0 strucu size ) \ PUBLIC
DUP ROT 1+ * 1+                         \ calculate ROLL offset
OVER 0 DO                               \ iterate size times
    DUP ROLL ROT ROT                    \ rotate one cell
LOOP                                    \ next iteration
DROP ;                                  \ drop ROLL offset

\ NUNROLL
\ # Opposite of NCROLL. Insert a multi-cell data structure anywhere into the
\ # parameter stack.
\ # args:   size:     size of each struc (in cells)
\ #         u:        number of structs to rotate
\ #         strucu:   data structure to be wrapped
\ #         struc0:   data structure
\ #         ...
\ #         strucu-1: data structure
\ # result: size:     size of each struc (in cells)
\ #         struc0:   data structure
\ #         ...
\ #         strucu:   wrapped data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         result out of range (-11)
: NCUNROLL ( strucu-1 ... struc0  strucu u size -- strucu ...  struc0 size )     \ PUBLIC
DUP ROT 1+ * 1+                         \ calculate UNROLL offset
OVER 0 DO                               \ iterate size times
    ROT OVER UNROLL                     \ rotate one cell
LOOP                                    \ next iteration
DROP ;                                  \ drop UNROLL offset

\ NCREMOVE
\ # Remove a multi-cell data structure anywhere from the parameter stack.
\ # args:   size:     size of each struc (in cells)
\ #         u:        number of structs to rotate
\ #         struc0:   data structure
\ #         ...
\ #         strucu:   data structure to be dropped
\ # result: size:     size of each struc (in cells)
\ #         struc0:   data structure
\ #         ...
\ #         strucu-1: shifted data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         result out of range (-11)
: NCREMOVE ( strucu ... struc0 u size -- strucu-1 ...  struc0 size ) \ PUBLIC
DUP ROT 1+ * 1+                         \ calculate REMOVE offset
OVER 0 DO                               \ iterate size times
    DUP I - REMOVE                      \ rotate one cell
LOOP                                    \ next iteration
DROP ;                                  \ drop REMOVE offset

\ NCDUP
\ #Duplicate last multi-cell data structure
\ # args:   size:   size of each struc (in cells)
\ #         struc: data structure
\ # result: size:   size of each struc (in cells)
\ #         struc: duplicated data structure
\ #         struc: data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NCDUP ( struc size -- struc struc size )  \ PUBLIC
0 SWAP NCPICK ;

\ NCOVER
\ #Duplicate previous multi-cell data structure
\ # args:   size:   size of each struc (in cells)
\ #         struc2: data structure
\ #         struc1: data structure
\ # result: size:   size of each struc (in cells)
\ #         struc1: duplicated data structure
\ #         struc2: data structure
\ #         struc1: data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NCOVER ( struc1 struc2 size -- struc1 struc2 struc1 size ) \ PUBLIC
1 SWAP NCPICK ;

\ Swap two multi-cell data structure
\ # args:   size:   size of each struc (in cells
\ #         struc2: data structure
\ #         struc1: data structure
\ # result: size:   size of each struc (in cells
\ #         struc1: swapped data structure
\ #         struc2: swapped data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NCSWAP ( struc1 struc2 size -- struc2 struc1 size ) \ PUBLIC
1 SWAP NCROLL ;

\ NCROT
\ #ROTATE over three multi-cell data structures
\ # args:   size:   size of each struc (in cells)
\ #         struc3: data structure to
\ #         struc2: data structure to
\ #         struc1: data structure to be wrapped
\ # result: size:   size of each struc (in cells)
\ #         struc1: data structure
\ #         struc3: data structure
\ #         struc2: wrapped data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NCROT ( struc1 struc2 struc3 size -- struc2 struc3 struc1 size ) \ PUBLIC
2 SWAP NCROLL ;

\ NCNIP
\ # Remove the first multi-cell data structure below the TOS
\ # args:   size:  size of each struc (in cells)
\ #         struc2: data structure
\ #         struc1: data structure to be removed
\ # result: size:  size of each struc (in cells)
\ #         struc2: data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NCNIP ( struc1 struc2 size -- struc2 size ) \ PUBLIC
1 SWAP NCREMOVE ;

\ NCTUCK
\ # Copy the first multi-cell data structure below the second one
\ # args:   size:  size of each struc (in cells)
\ #         struc2: data structure
\ #         struc1: data structure
\ # result: size:  size of each struc (in cells)
\ #         sstruc2: data structure
\ #         struc1: data structure
\ #         struc2: duplicated data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NCTUCK ( struc1 struc2 size -- struc2 size ) \ PUBLIC
0 SWAP NCPLACE ;

    
\ # Arithmetic Operations #######################################################

\ NC2*
\ # Shift a multi-cell data number one bit towards the most significant bit.
\ # args:   size:   size of each struc (in cells)
\ #         struc1: data structure
\ # result: size:   size of each struc (in cells)
\ #         struc2: shifted data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NC2* ( struc1 size -- struc2 size ) \ PUBLIC
OVER 2*                                 \ shift most significant cell
OVER 1 DO                               \ iterate over structure size-1
    I 2 + PICK 0 D2*                    \ shift cell
    ROT OR                              \ propagate overflow to previous cell
    I 1+ PLACE                          \ update previous cell
LOOP                                    \ next iteration
OVER PLACE ;                            \ update last cell

\ NC2/
\ # Shift a signed multi-cell number one bit towards the least significant bit.
\ # args:   size:   size of each struc (in cells)
\ #         struc1: data structure
\ # result: size:   size of each struc (in cells)
\ #         struc2: shifted data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NC2/ ( struc1 size -- struc2 size ) \ PUBLIC
DUP PICK 2/                             \ shift least significant cell
OVER 1 SWAP DO               	        \ iterate backwards over size 
    [ -1 1 RSHIFT ] LITERAL AND         \ clear MSB of previous cell
    I PICK 0 SWAP D2/                   \ shift cell
    ROT ROT OR SWAP                     \ propagate overflow to previous cell
    I 1+ PLACE                          \ update previous cell
-1 +LOOP                                \ next iteration
1 PLACE ;                               \ update last cell

\ NCU2/
\ # Shift a unsigned multi-cell number one bit towards the least significant
\ # bit.
\ # significant bit.
\ # args:   size:   size of each struc (in cells)
\ #         struc1: data structure
\ # result: size:   size of each struc (in cells)
\ #         struc2: shifted data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NCU2/ ( struc1 size -- struc2 size ) \ PUBLIC
NC2/                                    \ signed shift
SWAP [ -1 1 RSHIFT ] LITERAL AND SWAP ; \ clear most significant bit

\ NC+
\ # Add two unsigned multi-cell numbers
\ # args:   size:   size of each struc (in cells)
\ #         struc1: operand
\ #         struc2: operand
\ # result: size:   size of each struc (in cells)
\ #         struc3: result
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NC+ ( struc1 struc2 size -- struc3 size ) \ PUBLIC
DUP 0                                   \ push initial carry
0 ROT DO                                \ iterate over size
    OVER SWAP                           \ duplicate size
    OVER I + 2 + PICK 0 SWAP M+         \ add struc2 operand to carry
    I 3 + PICK M+                       \ add struc1
    SWAP ROT I + 1+ PLACE               \ replace struc2
 -1 +LOOP                               \ next iteration
DROP NCDROP ;                           \ drop struc1                 

\ NC-
\ # Subtract struc1 from struc2
\ # args:   size:   size of each struc (in cells)
\ #         struc1: operand
\ #         struc2: operand
\ # result: size:   size of each struc (in cells)
\ #         struc3: result
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NC- ( struc1 struc2 size -- struc3 size ) \ PUBLIC
DUP 1                                   \ push initial carry
0 ROT DO                                \ iterate over size
    OVER SWAP                           \ duplicate size
    OVER I + 2 + PICK 0 SWAP M+         \ add struc2 operand to carry
    I 3 + PICK INVERT M+                \ subtract struc1
    SWAP ROT I + 1+ PLACE               \ replace struc2
 -1 +LOOP                               \ next iteration
DROP NCDROP ;                           \ drop struc1                 

\ NC2UE
\ # Extend two multi-cell numbers by one cell
\ # args:   size1:  size of original multi-cell numbers (in cells)
\ #         struc1: multi-cell number
\ #         struc2: multi-cell number
\ # result: size2:  size of extended numbers (=size1+1)
\ #         struc3: extended number, equal to struc1
\ #         struc4: extended number, equal to struc2
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ : NC2UEX ( struc1 struc2 size1 -- struc3 struc4 size2 ) \ PUBLIC
0 OVER 1+ UNROLL                       \ extend struc2
0 SWAP                                 \ extend struc1
1+ ;                                   \ increment size

\ NCUE+
\ # Extend and add two unsigned multi-cell numbers
\ # args:   size1:   size of each operand (in cells)
\ #         struc1: operand
\ #         struc2: operand
\ # result: size2:   size of the result (=sitruc1+1)
\ #         estruc: result
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NCUE+ ( struc1 struc2 size1 -- estruc size2 ) \ PUBLIC
NC2UE NC+ ;

\ NCUE-
\ # Extend and subtract struc1 from struc2
\ # args:   size1:   size of each operand (in cells)
\ #         struc1: operand
\ #         struc2: operand
\ # result: size2:   size of the result (=sitruc1+1)
\ #         estruc: result
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NCUE- ( struc1 struc2 size1 -- estruc size2 ) \ PUBLIC
NC2UE NC- ;

\ NC2SE
\ # Sign extend two multi-cell numbers by one cell
\ # args:   size1:  size of original multi-cell numbers (in cells)
\ #         struc1: multi-cell number
\ #         struc2: multi-cell number
\ # result: size2:  size of sign extended numbers (=size1+1)
\ #         struc3: sign extended number, equal to struc1
\ #         struc4: sign extended number, equal to struc2
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
 : NC2SE ( struc1 struc2 size1 -- struc3 struc4 size2 ) \ PUBLIC
DUP 1+  PICK 0< OVER 1+ UNROLL         \ sign extend struc2
OVER 0< SWAP                           \ sign extend struc1
1+ ;                                   \ increment size

\ NCSE+
\ # Sign extend and add two unsigned multi-cell numbers
\ # args:   size1:   size of each operand (in cells)
\ #         struc1: operand
\ #         struc2: operand
\ # result: size2:   size of the result (=sitruc1+1)
\ #         estruc: result
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NCSE+ ( struc1 struc2 size1 -- estruc size2 ) \ PUBLIC
NC2SE NC+ ;

\ NCUE-
\ # Sign extend and subtract struc1 from struc2
\ # args:   size1:   size of each operand (in cells)
\ #         struc1: operand
\ #         struc2: operand
\ # result: size2:   size of the result (=sitruc1+1)
\ #         estruc: result
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NCSE- ( struc1 struc2 size1 -- estruc size2 ) \ PUBLIC
NC2SE NC- ;









\ NCU*
\ # Unsugned multiplication of two unsigned multi-cell data structures
\ # args:   size:   size of each struc (in cells)
\ #         struc1: operand
\ #         struc2: operand
\ # result: size:   size of each struc (in cells)
\ #         dstruc: product
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ : NCU* ( struc2 struc1 size -- dstruc ) \ PUBLIC
\ SP@ 
\ DUP 0 DO                               \ iterate over struc1 (J)	       	       	      	
\ DUP 0 DO                               \ iterate over struc2 (I)


\ # Logic Operations ############################################################

\ NCINVERT
\ # 1's complement of a multi-cell data structure
\ # args:   size:   size of each struc (in cells)
\ #         struc1: data structure
\ # result: struc2: resulting data structure
\ # throws: size:   size of each struc (in cells)
\ #         stack overflow (-3)
\ #         stack underflow (-4)
: NCINVERT ( struc1 size -- struc2 size ) \ PUBLIC
DUP 0 DO	  	                \ iterate over structure size
    DUP ROLL                            \ pick cell from struc
    INVERT                              \ invert cell
    SWAP                                \ swap result
LOOP ;                                  \ next iteration

\ NCLOGIC
\ # Bitwise logic operation of two multi-cell data structures
\ # args:   xt:     bitwise logic operation ( x1 x2 -- x3 )
\ #         size:   size of each struc (in cells)
\ #         struc1: data structure
\ # result: struc2: resulting data structure
\ # throws: size:   size of each struc (in cells)
\ #         stack overflow (-3)
\ #         stack underflow (-4)
: NCLOGIC ( struc1 size xt -- struc2 size ) \ PUBLIC
SWAP 2 + DUP 2 DO	                \ iterate over structure size
    DUP ROLL 2OVER                      \ place operator cells next to each other
    EXECUTE                             \ execute logic operation
    OVER UNROLL ROT DROP                \ rotate result away
LOOP                                    \ next iteration
NIP 2 - ;                               \ restore structure size
    
\ NCAND
\ # Bitwise AND of two multi-cell data structures
\ # args:   size:   size of each struc (in cells)
\ #         struc1: data structure
\ # result: struc2: resulting data structure
\ # throws: size:   size of each struc (in cells)
\ #         stack overflow (-3)
\ #         stack underflow (-4)
: NCAND ( struc1 size -- struc2 size ) \ PUBLIC
['] AND NCLOGIC ;
\ Alternative implementation:
\ DUP 0 DO	  	                \ iterate over structure size
\     DUP 1+ ROLL ROT                   \ pick cell from struc1
\     AND                               \ AND operation
\     OVER UNROLL                       \ rotate result away
\ LOOP ;                                \ next iteration

\ NCOR
\ # Bitwise OR of two multi-cell data structures
\ # args:   size:   size of each struc (in cells)
\ #         struc1: data structure
\ # result: size:   size of each struc (in cells)
\ #         struc2: resulting data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NCOR ( struc1 size -- struc2 size )  \ PUBLIC
['] OR NCLOGIC ;
\ Alternative implementation:
\ DUP 0 DO	  	                \ iterate over structure size
\     DUP 1+ ROLL ROT                   \ pick cell from struc1
\     OR                                \ OR operation
\     OVER UNROLL                       \ rotate result away
\ LOOP ;                                \ next iteration
    
\ NCXOR
\ # Bitwise XOR of two multi-cell data structures
\ # args:   size:   size of each struc (in cells)
\ #         struc1: data structure
\ # result: size:   size of each struc (in cells)
\ #         struc2: resulting data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NCXOR ( struc1 size -- struc2 size ) \ PUBLIC
['] XOR NCLOGIC ;
\ Alternative implementation:
\ DUP 0 DO	  	                \ iterate over structure size
\     DUP 1+ ROLL ROT                   \ pick cell from struc1
\     XOR                               \ OR operation
\     OVER UNROLL                       \ rotate result away
\ LOOP ;                                \ next iteration

\ NCLSHIFT
\ # Perform a logical left shift of u bit-places on struc1, giving struc2.
\ # Put zeroes into the least significant bits vacated by the shift.
\ # args:   size:   size of each struc (in cells)
\ #         u:      number of places to shift
\ #         struc1: data structure
\ # result: size:   size of each struc (in cells)
\ #         struc2: shifted data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NCLSHIFT ( struc1 u size -- struc2 size ) \ PUBLIC
SWAP 0 DO                              \ iterate over u
    NC2*			       \ shift by one bit
LOOP ;                                 \ next iteration

\ NCRSHIFT
\ # Perform a logical right shift of u bit-places on struc1, giving struc2.
\ # Put zeroes into the least significant bits vacated by the shift.
\ # args:   size:   size of each struc (in cells)
\ #         u:      number of places to shift
\ #         struc1: data structure
\ # result: size:   size of each struc (in cells)
\ #         struc2: shifted data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NCRSHIFT ( struc1 u size -- struc2 size ) \ PUBLIC
SWAP 0 DO                               \ iterate over u
    NCU2/			        \ shift by one bit
LOOP ;                                  \ next iteration

\ # Compare Operations ############################################################

\ NC0=
\ # Check if all bits in multi-cell data structure are zero
\ # args:   size:  size of each struc (in cells)
\ #         struc: data structure
\ # result: flag:  true if all bits in data structure are zero
\ #         size:  size of each struc (in cells)
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NC0= ( struc size -- size flag ) \ PUBLIC
SWAP OVER 1 DO  	                \ iterate size-1 times
    ROT OR                              \ combine two cells
LOOP                                    \ next iteration
0= ;                                    \ check if combined cells are zero

\ NC0<
\ # Interpret data multi-cell data structure as signed integer and check if it
\ # is less than zero
\ # args:   size:  size of each struc (in cells)
\ #         struc: data structure
\ # result: flag:  true value is greater than zero
\ #         size:  size of each struc (in cells)
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NC0< ( struc size -- size flag ) \ PUBLIC
OVER 0<                                 \ check most significant cell
IF                                      \ negative value
    NCDROP TRUE                         \ return TRUE					
ELSE                                    \ positive or zero value
    NCDROP FALSE 	                \ return FALSE
THEN ;                                  \ done

\ NC=
\ # Check two multi-cell data structure are equal
\ # args:   size:   size of each struc (in cells)
\ #         struc2: data structure
\ #         struc1: data structure
\ # result: flag:  true equal
\ #         size:  size of each struc (in cells)
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NC= ( struc1 struc2 size -- size flag ) \ PUBLIC
NCXOR NC0= ;

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





