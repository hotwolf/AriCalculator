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
\ #   size   - unsigned single-cell integer (size of struct in cells <2^15)     #
\ #   esize  - unsigned single-cell integer (size of estruct in cells =size+1)  #
\ #   dsize  - unsigned single-cell integer (size of dstruct in cells =2*size)  #
\ #   struc  - multi-cell data structure of "size" cells                        #
\ #   estruc - extended multi-cell data structure                               #
\ #   dstruc - double multi-cell data structure                                 #
\ ###############################################################################
\ # Version History:                                                            #
\ #    April 8, 2015                                                            #
\ #      - Initial release                                                      #
\ ###############################################################################
\ # Required Word Sets:                                                         #
\ #    ANSForth                    - CORE word set                              #
\ #                                - CORE EXT word set                          #
\ #                                - DOUBLE word set                            #
\ #    S12CForth/GForth/SwiftForth - SP@ and SP! word                           #
\ #    Stack                       - Supplemental stack operations              #
\ #    Shift                       - Supplemental shift operations              #
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

\ TUCK*SWAP
\ # Replace x1 by the product of x1 and x2.
\ # args:   x2:  size of data structures (in cells)
\ #         x1:  data structure
\ # result: x2:  data structure
\ #         x1': x1*x2
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: TUCK*SWAP ( x1 x2 -- x1' x2 )
TUCK * SWAP ;

\ SWAP1+OVER*SWAP
\ # Replace x1 by the product of (1+x1) and x2.
\ # args:   x2:  size of data structures (in cells)
\ #         x1:  data structure
\ # result: x2:  data structure
\ #         x1': (1+x1)*x2
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: SWAP1+OVER*SWAP ( x1 x2 -- x1' x2 )
SWAP 1+ OVER * SWAP ;

\ NC2SE
\ # Sign extend two multi-cell numbers.
\ # args:   size:    size of each struc (in cells)
\ #         struc2:  signed number
\ #         struc1:  signed number
\ # result: esize:   extended size
\ #         estruc2: sign extensed number
\ #         estruc1: sign extensed number
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NC2SE ( struc1 struc2 size -- estruc1 estruc2 esize )
DUP 1+ PICK 0< OVER 1+ UNROLL          \ sign extend struc2
OVER 0< SWAP                           \ sign extend struc1
1+ ;                                   \ increment size

\ # Stack Operations ############################################################

\ NCDUP
\ # Duplicate the multi-cell data structure at the top of the stack.
\ # args:   size:  size of data structures (in cells)
\ #         struc: data structure
\ # result: struc: duplicated data structure
\ #         struc: data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NCDUP ( struc size --  struc struc ) \ PUBLIC
MDUP ;

\ NC2DUP
\ # Duplicate two  multi-cell data structure at the top of the stack.
\ # args:   size:  size of data structures (in cells)
\ #         struc0: data structure
\ #         struc1: data structure
\ # result: struc0: duplicated data structure
\ #         struc1: duplicated data structure
\ #         struc0: data structure
\ #         struc1: data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NC2DUP ( struc1 struc0 size --  struc1 struc0 struc1 struc0 ) \ PUBLIC
2* MDUP ;

\ NCDROP
\ # Remove two multi-cell data structure at the top of the stack.
\ # args:   size:  size of data structures (in cells)
\ #         struc: data structure
\ # result: -
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
\ #         result out of range (-11)
: NCDROP ( struc size --  ) \ PUBLIC
SDEALLOC ;

\ NC2DROP
\ # Remove two multi-cell data structure at the top of the stack.
\ # args:   size:   size of data structures (in cells)
\ #         struc0: data structure
\ #         struc1: data structure
\ # result: -
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
\ #         result out of range (-11)
: NC2DROP ( struc1 struc0 size --  ) \ PUBLIC
2* SDEALLOC ;

\ NCPICK
\ # Duplicate a multi-cell data structure from within the parameter stack.
\ # args:   size:   size of data structures (in cells)
\ #         u:      position of data structure to be copied
\ #         struc0: data structure
\ #         ...
\ #         strucu: data structure to be duplicated
\ # result: strucu: duplicated data structure
\ #         struc0: data structure
\ #         ...
\ #         strucu: duplicated data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
\ #         result out of range (-11)
: NCPICK ( strucu ... struc0 u size -- strucu ... struc0 strucu ) \ PUBLIC
TUCK*SWAP MPICK ;

\ NCPLACE
\ # Opposite of NCPICK. Replace a multi-cell data structure anywhere on the
\ # parameter stack.
\ # args:   size:     size of data structures (in cells)
\ #         u:        position of data structure to be replaced
\ #         strucu':  data structure to replace strucu
\ #         struc0:   data structure
\ #         ...
\ #         strucu:   data structure to be replaced
\ # result: struc0:   data structure
\ #         ...
\ #         strucu-1: data structure
\ #         strucu':  data structure which replaced strucu
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
\ #         result out of range (-11)
: NCPLACE ( strucu ... struc0 strucu' u size -- strucu' strucu-1... struc0 ) \ PUBLIC
SWAP1+OVER*SWAP MPLACE ;

\ NCROLL
\ # Rotate over multiple multi-cell data structures.
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
\ #         return stack overflow (-5)
\ #         result out of range (-11)
: NCROLL ( strucu ... struc0 u size -- strucu-1 ... struc0 strucu ) \ PUBLIC
TUCK*SWAP MROLL ;

\ NCUNROLL
\ # Opposite of NCROLL. Insert a multi-cell data structure anywhere into the
\ # parameter stack.
\ # args:   size:     size of each struc (in cells)
\ #         u:        number of structs to rotate
\ #         strucu:   data structure to be wrapped
\ #         struc0:   data structure
\ #         ...
\ #         strucu-1: data structure
\ # result: struc0:   data structure
\ #         ...
\ #         strucu:   wrapped data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
\ #         result out of range (-11)
: NCUNROLL ( strucu-1 ... struc0  strucu u size -- strucu ...  struc0 )     \ PUBLIC
SWAP1+OVER*SWAP MUNROLL ;

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
\ #         return stack overflow (-5)
\ #         result out of range (-11)
: NCREMOVE ( strucu ... struc0 u size -- strucu-1 ...  struc0 ) \ PUBLIC
TUCK*SWAP SREMOVE ;

\ NCOVER
\ # Duplicate previous multi-cell data structure.
\ # args:   size:   size of each struc (in cells)
\ #         struc2: data structure
\ #         struc1: data structure
\ # result: struc1: duplicated data structure
\ #         struc2: data structure
\ #         struc1: data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NCOVER ( struc1 struc2 size -- struc1 struc2 struc1 ) \ PUBLIC
1 SWAP NCPICK ;

\ NCSWAP
\ # Swap two multi-cell data structures.
\ # args:   size:   size of each struc (in cells
\ #         struc2: data structure
\ #         struc1: data structure
\ # result: struc1: swapped data structure
\ #         struc2: swapped data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NCSWAP ( struc1 struc2 size -- struc2 struc1 ) \ PUBLIC
1 SWAP NCROLL ;

\ NCROT
\ # Rotate over three multi-cell data structures.
\ # args:   size:   size of each struc (in cells)
\ #         struc3: data structure to
\ #         struc2: data structure to
\ #         struc1: data structure to be wrapped
\ # result: struc1: data structure
\ #         struc3: data structure
\ #         struc2: wrapped data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NCROT ( struc1 struc2 struc3 size -- struc2 struc3 struc1 ) \ PUBLIC
2 SWAP NCROLL ;

\ NCUNROT
\ # Reverse rotate over three multi-cell data structures.
\ # args:   size:   size of each struc (in cells)
\ #         struc3: data structure to
\ #         struc2: data structure to
\ #         struc1: data structure to be wrapped
\ # result: struc2: data structure
\ #         struc1: data structure
\ #         struc3: wrapped data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NCUNROT ( struc1 struc2 struc3 size -- struc3 struc1 struc2 ) \ PUBLIC
2 SWAP NCUNROLL ;

\ NCNIP
\ # Remove the first multi-cell data structure below the TOS.
\ # args:   size:  size of each struc (in cells)
\ #         struc2: data structure
\ #         struc1: data structure to be removed
\ # result: struc2: data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NCNIP ( struc1 struc2 size -- struc2 ) \ PUBLIC
1 SWAP NCREMOVE ;

\ NCTUCK
\ # Copy the first multi-cell data structure below the second one.
\ # args:   size:  size of each struc (in cells)
\ #         struc2: data structure
\ #         struc1: data structure
\ # result: sstruc2: data structure
\ #         struc1: data structure
\ #         struc2: duplicated data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NCTUCK ( struc1 struc2 size -- struc2 struc1 struc2 ) \ PUBLIC
0 SWAP NCPLACE ;

\ # Logic Operations ############################################################

\ NCINVERT
\ # Calculate 1's complement of a multi-cell data structure.
\ # args:   size:   size of each struc (in cells)
\ #         struc1: data structure
\ # result: struc2: resulting data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NCINVERT ( struc1 size -- struc2 ) \ PUBLIC
0 DO	  	                        \ iterate over structure size
    I PICK                              \ pick cell from struc
    INVERT                              \ invert cell
    I PLACE                             \ place result
LOOP ;                                  \ next iteration

\ NCLOGIC
\ # Perform any bitwise logic operation of two multi-cell data structures.
\ # args:   xt:     bitwise logic operation ( x1 x2 -- x3 )
\ #         size:   size of each struc (in cells)
\ #         struc1: data structure
\ #         struc2: data structure
\ # result: struc3: resulting data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NCLOGIC ( struc1 struc2 size xt -- struc3 )  \ PUBLIC
SWAP DUP 4 + 4 DO                       \ iterate over structure size
    2DUP I + 1- PICK                    \ pick cell from struc2
    I PICK                              \ pick cell from struc1
    ROT EXECUTE                         \ execute logic operation
    OVER I + PLACE                      \ place result
LOOP     \                              \ next iteration
1+ SDEALLOC ;                           \ free stack space
    
\ NCAND
\ # Perform a bitwise AND of two multi-cell data structures.
\ # args:   size:   size of each struc (in cells)
\ #         struc1: data structure
\ #         struc2: data structure
\ # result: struc3: resulting data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NCAND ( struc1 struc2 size -- struc3 ) \ PUBLIC
['] AND NCLOGIC ;

\ NCOR
\ # Perform a bitwise OR of two multi-cell data structures.
\ # args:   size:   size of each struc (in cells)
\ #         struc1: data structure
\ #         struc2: data structure
\ # result: struc3: resulting data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NCOR ( struc1 struc2 size -- struc2 )  \ PUBLIC
['] OR NCLOGIC ;
    
\ NCXOR
\ # Perform a bitwise XOR of two multi-cell data structures.
\ # args:   size:   size of each struc (in cells)
\ #         struc1: data structure
\ #         struc2: data structure
\ # result: struc3: resulting data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NCXOR ( struc1 struc2 size -- struc3 ) \ PUBLIC
['] XOR NCLOGIC ;

\ # Shift Operations ############################################################

\ NCLCSHIFT
\ # Perform a logical left shift of u cells on struc1, giving struc2
\ # Put zeroes into the least significant cells vacated by the shift.
\ # args:   size:   size of each struc (in cells).
\ #         u:      number of cells to shift
\ #         struc1: data structure
\ # result: struc2: shifted data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NCLCSHIFT ( struc1 u size -- struc2 ) \ PUBLIC
2DUP 2>R                                \ save u and size
OVER - 0 SWAP SMOVE                     \ move cells
2R> OVER - SWAP M0PLACE ;               \ insert zeros

\ NCLBSHIFT
\ # Perform a logical left shift of u bits on struc1, giving struc2
\ # Put zeroes into the least significant bits vacated by the shift.
\ # args:   size:   size of each struc (in cells).
\ #         u:      number of bits to shift (< bits/cell)
\ #         struc1: data structure
\ # result: struc2: shifted data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NCLBSHIFT ( struc1 u size -- struc2 ) \ PUBLIC
0                                       \ initialize carry
2 ROT 1+ DO                             \ iterate over size
    I PICK 2 PICK MLSHIFT UNROT OR      \ rotate cell 
    I PLACE                             \ store result
-1 +LOOP                                \ next iteration
2DROP ;                                 \ clean up

\ NCLSHIFT
\ # Perform a logical left shift of u bits on struc1, giving struc2
\ # Put zeroes into the least significant bits vacated by the shift.
\ # args:   size:   size of each struc (in cells).
\ #         u:      number of bits to shift
\ #         struc1: data structure
\ # result: struc2: shifted data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NCLSHIFT ( struc1 u size -- struc2 ) \ PUBLIC
SWAP BITS/CELL /MOD                     \ determine cell and bit shift distances
TUCK 2OVER - NIP 2>R                    \ save cell shift parameters
SWAP NCLCSHIFT                          \ cell shift
2R> NCLBSHIFT ;                         \ bit shift

\ NCRCSHIFT
\ # Perform a logical rightt shift of u cells on struc1, giving struc2
\ # Put zeroes into the most significant cells vacated by the shift.
\ # args:   size:   size of each struc (in cells).
\ #         u:      number of cells to shift
\ #         struc1: data structure
\ # result: struc2: shifted data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NCRCSHIFT ( struc1 u size -- struc2 ) \ PUBLIC
OVER >R                                 \ save u and size
OVER - 0 UNROT  SMOVE                   \ move cells
0 R>  M0PLACE ;                         \ insert zeros

\ NCRBSHIFT
\ # Perform a logical right shift of u bits on struc1, giving struc2
\ # Put zeroes into the most significant bits vacated by the shift.
\ # args:   size:   size of each struc (in cells).
\ #         u:      number of bits to shift (< bits/cell)
\ #         struc1: data structure
\ # result: struc2: shifted data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NCRBSHIFT ( struc1 u size -- struc2 ) \ PUBLIC
0                                       \ initialize carry
SWAP 2 + 2 DO                           \ iterate over size
    I PICK 2 PICK MRSHIFT ROT OR        \ rotate cell 
    I PLACE                             \ store result
    LOOP                                \ next iteration
2DROP ;                                 \ clean up

\ NCRSHIFT
\ # Perform a logical right shift of u bits on struc1, giving struc2
\ # Put zeroes into the most significant bits vacated by the shift.
\ # args:   size:   size of each struc (in cells).
\ #         u:      number of bits to shift
\ #         struc1: data structure
\ # result: struc2: shifted data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NCRSHIFT ( struc1 u size -- struc2 ) \ PUBLIC
SWAP BITS/CELL /MOD                     \ determine cell and bit shift distances
TUCK 2OVER - NIP 2SWAP 2>R              \ save cell shift parameters
NCRBSHIFT                               \ bit shift
R> R> NCRCSHIFT ;                       \ cell shift    

\ # Alignment Operations ########################################################

\ NCCL0
\ # Count leading zeros.
\ # args:   size:  size of each struc (in cells).
\ #         struc: data structure
\ # result: n:     number of leading zeros in x (-1 is struc=0)
\ #         struc: data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NCCL0 ( struc size -- struc n ) \ PUBLIC
-1 SWAP                                 \ default result (-1)
1+ 1 DO                                 \ iterate over size
    I PICK ?DUP IF                      \ check if cell is zero
        CL0                             \ count leading bits within cell
	I 1- BITS/CELL * +  \ determine leading zeros  
        NIP LEAVE                       \ clean up
    THEN                                \ cell check complete
LOOP ;                                  \ next iteration

\ NCCT0
\ # Count trailing zeros.
\ # args:   size:  size of each struc (in cells).
\ #         struc: data structure
\ # result: n:     number of leading zeros in x (-1 if struc=0)
\ #         struc: data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NCCT0 ( struc size -- struc n ) \ PUBLIC
-1 SWAP                                 \ default result (-1)
2 OVER 1+ DO                            \ iterate over size
    I PICK ?DUP IF                      \ check if cell is zero
        CT0                             \ count leading bits within cell
	OVER 1+ I -                     \ determine trailing cells  
	BITS/CELL * +                   \ determine trailing zeros  
        NIP SWAP LEAVE                  \ clean up
    THEN                                \ cell check complete
-1 +LOOP                                \ next iteration
DROP ;                                  \ clean up

\ NCLALIGN
\ # Left shift a multi cell structure until until the MSB is set, unless all
\ # data are equal to zero.
\ # args:   size:   size of each struc (in cells) 
\ #         struc1: data structure
\ # result: u:      number of performed shifts
\ #         struc2: shifted data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NCLALIGN ( struc1 size -- struc2 u ) \ PUBLIC
DUP >R NCCL0                            \ find leading zero
DUP 0> IF                               \ check shifting is required
    R> OVER >R NCLSHIFT R>              \ shift bits
ELSE                                    \ no shifting  required
    R> DROP                             \ clean up
THEN ;                                  \ done

\ NCRALIGN
\ # Right shift a multi cell structure until until the MSB is set, unless all
\ # data are equal to zero.
\ # args:   size:   size of each struc (in cells)
\ #         struc1: data structure
\ # result: u:      number of performed shifts (-1 if struc1=0)
\ #         struc2: shifted data structure (0 if struc1=0)
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NCRALIGN ( struc1 size -- struc2 u ) \ PUBLIC
DUP >R NCCT0                            \ find trailing zero
DUP 0> IF                               \ check shifting is required
    R> OVER >R NCRSHIFT R>              \ shift bits
ELSE                                    \ no shifting  required
    R> DROP                             \ clean up
THEN ;                                  \ done

\ # Unsigned Compare Operations ################################################

\ NC0=
\ # Check if all bits in a multi-cell data structure are zero.
\ # args:   size:  size of each struc (in cells)
\ #         struc: data structure
\ # result: flag:  true if all bits in data struc are zero
\ #         struc: data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NC0= ( struc size -- struc flag ) \ PUBLIC
TRUE 1 ROT DO				\ iterate over size
    I PICK IF                           \ check if cell !=0
        INVERT LEAVE                    \ terminate loop
    THEN                                \ check done
-1 +LOOP ;				\ next iteration
\ Alternative implementation:
\ 0 DO                                  \ iterate over size
\     I PICK ?DUP IF                    \ check if cell !=0
\         LEAVE                         \ terminate loop
\     THEN                              \ check done
\ LOOP                                  \ next iteration
\ DUP 0= ?DUP NIP ;                     \ prepare result

\ NC0=
\ # Check if any bit in a multi-cell data structure is not zero.
\ # args:   size:  size of each struc (in cells)
\ #         struc: data structure
\ # result: flag:  true if any bit in struc is not zero
\ #         struc: data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NC0<> ( struc size -- struc flag ) \ PUBLIC
NC0= 0= ;

\ NC=
\ # Check if two multi-cell data structure are equal.
\ # args:   size:   size of each struc (in cells)
\ #         struc2: data structure
\ #         struc1: data structure
\ # result: flag:  true ==0
\ #         struc2: data structure
\ #         struc1: data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NC= ( struc1 struc2 size -- struc1 struc2 flag ) \ PUBLIC
DUP 1+ 1 ROT DO				\ iterate over size
    I PICK                              \ pick cell from struc2
    DUP I + PICK                        \ pick cell from struc1
    XOR IF                              \ check if cells are unequal
        0= LEAVE                        \ leave inverted result and terminate
    THEN                                \ check done
-1 +LOOP				\ next iteration
0<> ;                                   \ prepare result

\ NC<>
\ # Check if two multi-cell data structure are equal.
\ # args:   size:   size of each struc (in cells)
\ #         struc2: data structure
\ #         struc1: data structure
\ # result: flag:  true if !=0
\ #         struc2: data structure
\ #         struc1: data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NC<> ( struc1 struc2 size -- struc1 struc2 flag ) \ PUBLIC
NC= INVERT ;

\ NCU<
\ # Interpret data multi-cell data structure as unsigned integer and check if
\ # struc1 is less than struc2.
\ # args:   size:   size of each struc (in cells)
\ #         struc2: data structure
\ #         struc1: data structure
\ # result: struc2: data structure
\ #         struc1: data structure
\ #         flag:  true if struc1 < struc2
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NCU< ( struc1 struc2 size -- struc1 struc2 flag ) \ PUBLIC
1+ DUP 1 DO	                        \ iterate over size
    I PICK                              \ pick cell from struc2
    OVER I + PICK                       \ pick cell from struc1
    2DUP XOR IF                         \ check if cells are unequal
        U< NIP LEAVE                    \ evaluate struc1>struc2
    ELSE                                \ cells are equal
        2DROP                           \ clean up
    THEN                                \ check done
LOOP	  			        \ next iteration
0= ;                                    \ invert result

\ NCU>
\ # Interpret data multi-cell data structure as signed integer and check if
\ # struc1 is greater than struc2.
\ # args:   size:   size of each struc (in cells)
\ #         struc2: data structure
\ #         struc1: data structure
\ # result: flag:  true if struc1 > struc2
\ #         size:  size of each struc (in cells)
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NCU> ( struc1 struc2 size -- flag ) \ PUBLIC
1+ DUP 1 DO	                        \ iterate over size
    I PICK                              \ pick cell from struc2
    OVER I + PICK                       \ pick cell from struc1
    2DUP XOR IF                         \ check if cells are unequal
        U> NIP LEAVE                    \ evaluate struc1<struc2
    ELSE                                \ cells are equal
        2DROP                           \ clean up
    THEN                                \ check done
LOOP	  			        \ next iteration
0= ;                                    \ invert result

\ NCMSB0=
\ # Check if the MSB of a multi-cell data structure is cleared.
\ # args:   size:  size of each struc (in cells)
\ #         struc: data structure
\ # result: flag:  true if MSB is cleared
\ #         size:  size of each struc (in cells)
\ #         struc: data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NCMSB0= ( struc size -- struc size flag ) \ PUBLIC 
OVER 0< INVERT ;

\ NCLS=
\ # Check if the LSB of a multi-cell data structure is cleared.
\ # args:   size:  size of each struc (in cells)
\ #         struc: data structure
\ # result: flag:  true if LSB is cleared
\ #         size:  size of each struc (in cells)
\ #         struc: data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NCLSB0= ( struc size -- struc size flag ) \ PUBLIC 
DUP PICK 1 AND 0= ;

\ # Arithmetic Operations #######################################################

\ NC2*
\ # Shift a multi-cell data number one bit towards the most significant bit.
\ # args:   size:   size of each struc (in cells)
\ #         struc1: data structure
\ # result: struc2: shifted data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NC2* ( struc1 size -- struc2 ) \ PUBLIC
OVER 2*                                 \ shift most significant cell
OVER 1+ 2 DO                            \ iterate over structure size-1
    I 1+ PICK 0 D2*                     \ shift cell
    ROT OR                              \ propagate overflow to previous cell
    I PLACE                             \ update previous cell
LOOP                                    \ next iteration
SWAP 1- PLACE ;                         \ update last cell

\ NC2*1+
\ # Shift a multi-cell data number one bit towards the most significant bit and
\ # set the least significant bit to one.
\ # args:   size:   size of each struc (in cells, >1)
\ #         struc1: data structure
\ # result: struc2: shifted data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NC2*1+ ( struc1 size -- struc2 ) \ PUBLIC
OVER 2*                                 \ shift most significant cell
OVER 1+ 2 DO                            \ iterate over structure size-1
    I 1+ PICK 0 D2*                     \ shift cell
    ROT OR                              \ propagate overflow to previous cell
    I PLACE                             \ update previous cell
LOOP                                    \ next iteration
1+ SWAP 1- PLACE ;                      \ update last cell

\ NC2/
\ # Shift a signed multi-cell number one bit towards the least significant bit.
\ # args:   size:   size of each struc (in cells, >1)
\ #         struc1: data structure
\ # result: struc2: shifted data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NC2/ ( struc1 size -- struc2 ) \ PUBLIC
DUP PICK 2/                             \ shift least significant cell
2 ROT DO               	                \ iterate backwards over size 
    [ -1 1 RSHIFT ] LITERAL AND         \ clear MSB of previous cell
    0 I PICK D2/                        \ shift cell
    UNROT OR                            \ propagate overflow to previous cell
    I PLACE                             \ update previous cell
-1 +LOOP                                \ next iteration
NIP ;                                   \ update last cell

\ NCU2/
\ # Shift a unsigned multi-cell number one bit towards the least significant
\ # bit.
\ # args:   size:   size of each struc (in cells, >1)
\ #         struc1: data structure
\ # result: struc2: shifted data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NCU2/ ( struc1 size -- struc2 size ) \ PUBLIC
NC2/                                    \ signed shift
[ -1 1 RSHIFT ] LITERAL AND ;           \ clear most significant bit

\ NC1UE+
\ # Add two unsigned multi-cell numbers with extended result.
\ # args:   size:   size of struc (in cells)
\ #         u:      operand
\ #         struc:  operand
\ # result: estruc: result
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NC1UE+ ( struc u size -- estruc ) \ PUBLIC
1 SWAP DO                               \ iterate over size
    0 I 1+ PICK 0 D+                    \ add carry to cell of struc
    SWAP I PLACE                        \ place result
-1 +LOOP ;                              \ next iteration    

\ NCUE+
\ # Add two unsigned multi-cell numbers with extended result.
\ # args:   size:   size of each struc (in cells)
\ #         struc2: operand
\ #         struc1: operand
\ # result: estruc: result
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NCUE+ ( struc1 struc2 size -- estruc ) \ PUBLIC
DUP 1- DO                               \ store size-1 in loop counter
    0                                   \ push initial carry
    2 I 2 + DO                          \ iterate over size
        0 I PICK 0 D+                   \ add cell from struc2 to carry
	I J + 1+ PICK 0 D+              \ add cell from struc1
        SWAP I J + PLACE                \ place result 
    -1 +LOOP                            \ next iteration
    I PLACE                             \ place carry
    I SDEALLOC                          \ free stack space
LOOP ;                                  \ clean up outer loop

\ NC+
\ # Add two multi-cell numbers.
\ # args:   size:   size of each struc (in cells)
\ #         struc2: operand
\ #         struc1: operand
\ # result: struc3: result
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NC+ ( struc1 struc2 size -- struc3 ) \ PUBLIC
NCUE+ DROP ;

\ NCSE+
\ # Add two signed multi-cell numbers with extended result.
\ # args:   size:   size of each struc (in cells)
\ #         struc2: operand
\ #         struc1: operand
\ # result: estruc: result
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NCSE+ ( struc1 struc2 size -- estruc ) \ PUBLIC
NC2SE NC+ ;

\ NC1UE-
\ # Subtract u from struc with extended result.
\ # args:   size:   size of struc (in cells)
\ #         u:      operand
\ #         struc:  operand
\ # result: estruc: result
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NC1UE- ( struc u size -- estruc ) \ PUBLIC
1 SWAP DO                               \ iterate over size
     I PICK 0 ROT 0 D- 1 AND            \ subtract carry from cell of struc
     SWAP I PLACE                       \ place result
-1 +LOOP                               \ next iteration    
NEGATE ; 

\ NCUE-
\ # Zero extend both unsigned multi-cell numbers ans subtract struc2 from struc1.
\ # args:   size:   size of each struc (in cells)
\ #         struc2: operand
\ #         struc1: operand
\ # result: estruc: result
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NCUE- ( struc1 struc2 size -- estruc ) \ PUBLIC
DUP 1- DO                               \ store size-1 in loop counter
    0                                   \ push initial carry
    1 I 2 + DO                          \ iterate over size
        S>D I PICK 0 D-                   \ add cell from struc2 to carry
	I J + 1+ PICK 0 D+              \ add cell from struc1
        SWAP I J + PLACE                \ place result 
    -1 +LOOP                            \ next iteration
    I PLACE                             \ place carry
    I SDEALLOC                          \ free stack space
LOOP ;                                  \ clean up outer loop

\ NC-
\ # Subtract struc2 from struc1.
\ # args:   size:   size of each struc (in cells)
\ #         struc2: operand
\ #         struc1: operand
\ # result: struc3: result
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NC- ( struc1 struc2 size -- struc3 ) \ PUBLIC
NCUE- DROP ;

\ NCSE-
\ # Sign extend both unsigned multi-cell numbers ans subtract struc2 from struc1.
\ # args:   size:   size of each struc (in cells)
\ #         struc2: operand
\ #         struc1: operand
\ # result: estruc: result
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NCSE- ( struc1 struc2 size -- estruc ) \ PUBLIC
NC2SE NC- ;

\ NC1U*
\ # Multiply an unsigned multi-cell number with an unsigned single cell number.
\ # args:   size:   size of a struc (in cells)
\ #         u:      factor
\ #         struc:  factor
\ # result: estruc: product
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NC1U* ( struc u size -- estruc ) \ PUBLIC
0                                       \ initialize intermediate result
2 ROT 1+ DO                             \ iterate over size
    OVER I 1+ PICK UM*                  \ multiply cells
    ROT 0 D+                            \ add to intermediate result
    SWAP I PLACE                        \ store result
 -1 +LOOP                               \ next iteration
NIP ;                                   \ clean up

\ NCU*
\ # Multiply two unsigned multi-cell numbers.
\ # args:   size:   size of each factor (in cells)
\ #         struc2: factor
\ #         struc1: factor
\ # result: dstruc: accumulated product
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
\ # 
\ # +--------+ -  Example: size=5				       
\ # |  size  | |  outer      inner           cell of                              
\ # +--------+ |  loop (J):  loop (I):       result:  	 
\ # | interm.| |        12    2+2*size-> 12   8, 9	       
\ # | result | |        11            12 11   7		       
\ # | 3 cells| |        10         12 11 10   6		       
\ # +--------+ |         9      12 11 10  9   5		       
\ # | result | |I        8   12 11 10  9  8   4		       
\ # | 1 cell | |         7   11 10  9  8      3		       
\ # | per    | |         6   10  9  8         2		       
\ # | inner  | |         5    9  8            1		       
\ # | iterat.| |         4    8 <-3+size      0                
\ # +--------+ |  
\ # |        | |  Example: size=4				       
\ # |        | V  outer      inner        cell of                            
\ # | struc2 |	  loop (J):  loop (I):    result:  	  
\ # |        |	        10 2+2*size-> 10   6, 7	       
\ # |        |	         9         10  9   5	            
\ # +--------+	         8      10  9  8   4	       	       
\ # |        |	         7   10  9  8  7   3	       	       
\ # |        |	         6    9  8  7      2	       	       
\ # | struc1 |	         5    8  7         1	       	       
\ # |        |	         4    7 <-3+size   0        	       
\ # |        |	  	       
\ # +--------+	     
\ # 
: NCU* ( struc2 struc1 size -- dstruc ) \ PUBLIC
0 0 ROT                                 \ initialize intermediate result
DUP 2* 3 +                              \ set upper boundary for outer loop
4                                       \ set lower boundary for outer loop
DO                                      \ outer loop
    0 SWAP                              \ expand intermediate result
    DUP 2* 3 + OVER I + MIN             \ set upper boundary for inner loop
    OVER 3 + I MAX                      \ set lower boundary of inner loop
    \ CR ." outer loop: " I . ." --> inner loop: " 2DUP . .
    DO                                  \ inner loop
        I PICK                          \ pick cell from struc2
        OVER 2* J + 7 + I - PICK        \ pick cell from struc1
        \ CR ."    inner loop: " I . ." ---> " 2DUP U. ." * " U. ." = " 
        UM*                             \ multiply cells
        \ 2DUP D.
        SWAP 0 6 PICK 0 D+ SWAP 5 PLACE \ add product to intermediate result  
        ROT >R D+ R>                    \
    LOOP                                \ next iteration of the inner loop
LOOP                                    \ next iteration of the outer loop
NIP 2* DUP SREMOVE ;                    \ clean up  

\ NC1U/MOD
\ # Perform unsigned division.
\ # args:   size:   size of each struc (in cells)
\ #         u1:     denominator
\ #         struc1: numerator
\ # result: u2:     remainder
\ #         struc2: quotient
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
\ #         division by zero (-10)
: NC1U/MOD ( struc1 u1 size -- struc2 u2 ) \ PUBLIC
0 	     	       	       	      	\ initialize intermediate result
SWAP 2 + 2  DO                          \ iterate over size
    OVER I 1+ PICK UNROT UM/MOD         \ divide one cell
    I PLACE                             \ store result
LOOP                                    \ next iteration
NIP ;                                   \ clean up

\ NCU/MOD
\ # Perform an unsigned division with remainder.
\ # args:   size:   size of each struc (in cells)
\ #         struc2: denominator
\ #         struc1: numerator
\ # result: struc4: remainder
\ #         struc3: quotient
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
\ #         division by zero (-10)
: NCU/MOD ( struc1 struc2 size -- struc3 struc4 ) \ PUBLIC
>R                                      \ save size
R@ 2* R@ M0INS                          \ allocate space for the quotient
R@ NCSWAP R@ NCCL0 R> 2>R               \ count leading zeros of the numerator
R@ NCSWAP R@ NCCL0                      \ count leading zeros of the denominator
DUP 0< IF                               \ check for devision by zero
    -10 THROW                           \ throw exception
THEN                                    \ denominator>0
2R> >R - 0 MAX                          \ calculate alignment
R> 2DUP 2>R NCLSHIFT                    \ align denominator
R@ NCU< 0= IF                           \ check if numerator>=aligned denom.
    1 R@ 3 * 1- PLACE                   \ set result to 1     
    R@ NC2DUP R@ NC-                    \ numerator-=aligned denominator 
    1 R@ NCPLACE                        \ update numerator
THEN                                    \ check done
R> R> 0 ?DO                             \ iterate over shifts
    DUP >R NCU2/                        \ shift denominator
    R@ NCU< IF                          \ check if numerator<shifted denom.
        2 R@ NCPICK R@ NC2*             \ pick and shift result
        2 R@ NCPLACE                    \ update result
    ELSE                                \ numerator>=shifted denom.
        2 R@ NCPICK R@ NC2*1+           \ pick and shift and increment result
        2 R@ NCPLACE                    \ update result
        R@ NC2DUP R@ NC-                \ numerator-=shifted denominator 
        1 R@ NCPLACE                    \ update numerator
    THEN                                \ check done
    R>                                  \ clean up return stack
LOOP                                    \ next iteration
NCDROP ;                                \ remove denominator

\ NCU/
\ # Perform an unsigned division.
\ # args:   size:   size of each struc (in cells)
\ #         struc2: denominator
\ #         struc1: numerator
\ # result: struc3: quotient
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
\ #         division by zero (-10)
: NCU/ ( struc1 struc2 size -- struc3 ) \ PUBLIC
DUP >R NCU/MOD R> NCDROP ;

\ NCUMOD
\ # Perform an unsigned modulus calculation.
\ # args:   size:   size of each struc (in cells)
\ #         struc2: denominator
\ #         struc1: numerator
\ # result: struc3: remainder
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
\ #         division by zero (-10)
: NCUMOD ( struc1 struc2 size -- struc3 ) \ PUBLIC
DUP >R NCU/MOD R> NCNIP  ;

\ # Signed Compare Operations ##################################################

\ NC0<
\ # Interpret data multi-cell data structure as signed integer and check if it
\ # is less than zero.
\ # args:   struc: data structure
\ # result: flag:  true if <0
\ #         struc: data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NC0< ( struc -- struc flag ) \ PUBLIC
DUP 0< ;                                \ check most significant cell

\ NC<
\ # Interpret data multi-cell data structure as signed integer and check if
\ # struc1 is less than struc2.
\ # args:   size:   size of each struc (in cells)
\ #         struc2: data structure
\ #         struc1: data structure
\ # result: flag:  true if struc1 < struc2
\ #         struc2: data structure
\ #         struc1: data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NC< ( struc1 struc2 size -- struc1 struc2 flag ) \ PUBLIC
DUP >R NC2DUP                           \ duplicate data
R@ NC- NC0<                             \ struc1 - struc2
R> SWAP >R NC2DROP R> ;                 \ clean up

\ NC>
\ # Interpret data multi-cell data structure as signed integer and check if
\ # struc2 is less than struc1.
\ # args:   size:   size of each struc (in cells)
\ #         struc2: data structure
\ #         struc1: data structure
\ # result: flag:  true if struc1 > struc2
\ #         struc2: data structure
\ #         struc1: data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NC> ( struc1 struc2 size -- struc1 struc2 flag ) \ PUBLIC
DUP >R NC2DUP                           \ duplicate data
R@ NCSWAP                               \ swap data
R@ NC- NC0<                             \ struc1 - struc2
R> SWAP >R NC2DROP R> ;                 \ clean up

\ # Common Calculations #########################################################

\ NCUGCD
\ # Calculate the greatest common divisor of two unsigned multi cell structures.
\ # args:   size:   size of each struc (in cells)
\ #         struc2: data structure
\ #         struc1: data structure
\ # result: struc3: GCD
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NCUGCD ( struc1 struc2 size -- struc3 ) \ PUBLIC
>R                                      \ save size
BEGIN                                   \ check for terminating condition
    R@ NC0<>                            \ check if struc2 is non-zero
WHILE                                   \ iterate until struc2 is zero
    R@ TUCK                             \ struc2 -> struc1
    R@ NCUMOD                           \ struc1 mod struc2 -> struc2
REPEAT                                  \ next iteration
R> NCDROP ;                             \ clean up

\ NCUCANCEL
\ # Cancel the common factors of two unsigned multi cell structures.
\ # data are equal to zero.
\ # args:   size:   size of each struc (in cells)
\ #         struc2: denominator
\ #         struc1: numerator
\ # result: struc4: new denominator
\ #         struc3: new numerator
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NCUCANCEL ( struc1 struc2 size -- struc3 struc4 ) \ PUBLIC
>R                                      \ save size
R@ NC2DUP R@ NCUGCD                     \ calculate GCD 
R@ NCTUCK R@ NCU/                       \ calculate new denominator
R@ NCUNROT R@ NCU/                      \ calculate new numerator
R> NCSWAP ;                             \ put result in order

\ NCUROUND
\ # Round and right align an unsigned multi cell data structure.
\ # data are equal to zero.
\ # args:   size2:  size of struc2 (in cells)
\ #         size1:  size of struc1 (in cells) (size1>size2)
\ #         struc1: data structure
\ # result: flag:   true if result has been rounded
\ #         u:      exponent
\ #         struc2: approximated data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
: NCROUND ( struc1 size1 size2 -- struc2 u1 u2 ) \ PUBLIC
2DUP 2>R - NC0= IF                      \ check if rounding can be omitted 
    2R@ - SDEALLOC                      \ drop leading cells    
    R> NCRALIGN                         \ right align
    FALSE                               \ return cleared approximation flag
    R> DROP                             \ clean up
ELSE                                    \ rounding is required    
   2R@ DROP NCLALIGN 2R> ROT >R 2>R     \ left align 
   CELLMSB R@ 1+ NC1UE+                 \ add rounding offset
   R@ 1+ NCRALIGN 2R> ROT               \ right align
   R> - BITS/CELL 2OVER - * + >R        \ calculate exponent
   TUCK - SREMOVE                       \ drop trailing cells 
    R>                                  \ return exponent
    TRUE                                \ return set approximation flag
THEN ;                                  \ done    

\ # Output ######################################################################

\ NC#
\ # Divide struc1 by the number in BASE giving the quotient struc2 and the
\ # remainder n.  (n is the least-significant digit of struc1.) Convert n to
\ # external form and add the resulting character to the beginning of the
\ # pictured numeric output string.
\ # args:   size:   size of each struc (in cells)
\ #         struc1: data structure
\ # result: struc2: data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
\ #         pictured numeric output string overflow (-17)
: NC# ( struc1 size -- struc2 ) \ PUBLIC
BASE @ SWAP NC1U/MOD 0 # 2DROP ;
\ BASE @ SWAP NC1U/MOD . ;

\ NC#S
\ # Convert one digit of struc1 according to the rule for NC#. Continue
\ # conversion until the quotient is zero.
\ # args:   size:  size of each struc (in cells)
\ #         struc: data structure
\ # result: none
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
\ #         pictured numeric output string overflow (-17)
: NC#S ( struc size -- ) \ PUBLIC
>R                                      \ save size
BEGIN                                   \ interate over all digits
    R@ NC#                              \ extract one digit
    R@ NC0=                             \ check if quotient is zero
UNTIL                                   \ next iteration
R> SDEALLOC ;                           \ clean up

\ NCU.
\ # Print multi cell structure as unsugned number.
\ # args:   size:   size of each struc (in cells)
\ #         struc1: data structure
\ # result: -
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         return stack overflow (-5)
\ #         pictured numeric output string overflow (-17)
: NCU. ( struc size -- ) \ PUBLIC
<# NC#S [ 0 0 ] 2LITERAL #> TYPE ;




