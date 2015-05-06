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
\ #                                  DOUBLE word set                            #
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

\ # Helper functions ############################################################

\ TUCK*SWAP
\ # Replace x1 by the product of x1 and x2.
\ # args:   x2:  size of data structures (in cells)
\ #         x1:  data structure
\ # result: x2:  data structure
\ #         x1': x1*x2
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
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
: NC2SE ( struc1 struc2 size -- estruc1 estruc2 esize )
DUP 1+ PICK 0< OVER 1+ UNROLL          \ sign extend struc2
OVER 0< SWAP                           \ sign extend struc1
1+ ;                                   \ increment size

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

\ # Stack Operations ############################################################

\ NCDUP
\ # Duplicate the multi-cell data structure at the top of the stack.
\ # args:   size:  size of data structures (in cells)
\ #         struc: data structure
\ # result: struc: duplicated data structure
\ #         struc: data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ : NCDUP ( struc size --  struc struc ) \ PUBLIC
\ MDUP ;

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
\ : NC2DUP ( struc1 struc0 size --  struc1 struc0 struc1 struc0 ) \ PUBLIC
\ 2* MDUP ;

\ NCDROP
\ # Remove two multi-cell data structure at the top of the stack.
\ # args:   size:  size of data structures (in cells)
\ #         struc: data structure
\ # result: -
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         result out of range (-11)
\ : NCDROP ( struc size --  ) \ PUBLIC
\ SDEALLOC ;

\ NC2DROP
\ # Remove two multi-cell data structure at the top of the stack.
\ # args:   size:   size of data structures (in cells)
\ #         struc0: data structure
\ #         struc1: data structure
\ # result: -
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         result out of range (-11)
\ : NC2DROP ( struc1 struc0 size --  ) \ PUBLIC
\ 2* NCDROP ;

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
: NCOVER ( struc1 struc2 size -- struc1 struc2 struc1 ) \ PUBLIC
1 SWAP NCPICK ;

\ # Swap two multi-cell data structures.
\ # args:   size:   size of each struc (in cells
\ #         struc2: data structure
\ #         struc1: data structure
\ # result: struc1: swapped data structure
\ #         struc2: swapped data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
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
: NCROT ( struc1 struc2 struc3 size -- struc2 struc3 struc1 ) \ PUBLIC
2 SWAP NCROLL ;

\ NCNIP
\ # Remove the first multi-cell data structure below the TOS.
\ # args:   size:  size of each struc (in cells)
\ #         struc2: data structure
\ #         struc1: data structure to be removed
\ # result: struc2: data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
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
: NCTUCK ( struc1 struc2 size -- struc2 struc1 struc2 ) \ PUBLIC
0 SWAP NCPLACE ;
    
\ # Arithmetic Operations #######################################################

\ NC2*
\ # Shift a multi-cell data number one bit towards the most significant bit.
\ # args:   size:   size of each struc (in cells)
\ #         struc1: data structure
\ # result: struc2: shifted data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
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
\ # set the most significant bit to one.
\ # args:   size:   size of each struc (in cells, >1)
\ #         struc1: data structure
\ # result: struc2: shifted data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
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
: NC2/ ( struc1 size -- struc2 ) \ PUBLIC
DUP PICK 2/                             \ shift least significant cell
2 ROT DO               	                \ iterate backwards over size 
    [ -1 1 RSHIFT ] LITERAL AND         \ clear MSB of previous cell
    0 I PICK D2/                        \ shift cell
    ROT ROT OR                          \ propagate overflow to previous cell
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
: NC1U* ( struc u size -- estruc ) \ PUBLIC
0                                       \ initialize intermediate result
2 ROT 1+ DO                             \ iterate over size
    OVER I 1+ PICK UM*                  \ multiply cells
    ROT 0 D+                            \ add to intermediate result
    SWAP I PLACE                        \ store result
 -1 +LOOP                               \ next iteration
NIP ;                                   \ clean up

\ NC1U/MOD
\ # Perform unsigned division.
\ # args:   size:   size of each struc (in cells)
\ #         u1:     denominator
\ #         struc1: nominator
\ # result: u2:     remainder
\ #         struc1: quotient
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         division by zero (-10)
: NC1U/MOD ( struc1 u1 size -- struc2 u2 ) \ PUBLIC
0 	     	       	       	      	\ initialize intermediate result
SWAP 2 + 2  DO                          \ iterate over size
    OVER I 1+ PICK ROT ROT UM/MOD       \ divide one cell
    I PLACE                             \ store result
LOOP                                    \ next iteration
NIP ;                                   \ clean up

\ <=======Progress

\ NCU*
\ # Multiply two unsigned multi-cell numbers.
\ # args:   size:   size of each factor (in cells)
\ #         struc2: factor
\ #         struc1: factor
\ # result: dstruc: accumulated product
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ # 
\ # +--------+ -  Example: size=5				       
\ # |  size  | |  outer      inner           cell of                              
\ # +--------+ |  loop (J):  loop (I):       result:  	 
\ # | interm.| |        13    2+2*size-> 12   8, 9	       
\ # | result | |        12            12 11   7		       
\ # | 3 cells| |        11         12 11 10   6		       
\ # +--------+ |        10      12 11 10  9   5		       
\ # | result | |I        9   12 11 10  9  8   4		       
\ # | 1 cell | |         8   11 10  9  8      3		       
\ # | per    | |         7   10  9  8         2		       
\ # | inner  | |         6    9  8            1		       
\ # | iterat.| |         5    8 <-3+size      0                
\ # +--------+ |  
\ # |        | |  Example: size=4				       
\ # |        | V  outer      inner        cell of                            
\ # | struc2 |	  loop (J):  loop (I):    result:  	  
\ # |        |	        11 2+2*size-> 10   6, 7	       
\ # |        |	        10         10  9   5	            
\ # +--------+	         9      10  9  8   4	       	       
\ # |        |	         8   10  9  8  7   3	       	       
\ # |        |	         7    9  8  7      2	       	       
\ # | struc1 |	         6    8  7         1	       	       
\ # |        |	         5    7 <-3+size   0        	       
\ # |        |	  	       
\ # +--------+	     
\ # 
: NCU* ( struc2 struc1 size -- dstruc ) \ PUBLIC
0 0 ROT                                 \ initialize intermediate result
DUP 2* 4 +                              \ set upper boundary for outer loop
5                                       \ set lower boundary for outer loop
DO                                      \ outer loop

    CR ." outer loop: " I .

    0 SWAP                              \ expand intermediate result
    DUP 2* 3 + OVER I + 1- MIN          \ set upper boundary for inner loop
    OVER 3 + I MAX                      \ set lower boundary of inner loop
    DO                                  \ inner loop

        CR ." inner loop: " I .

        I PICK                          \ pick cell from struc2
        OVER 2* J + 5 + I - PICK        \ pick cell from struc1
        UM*                             \ multiply cells
        SWAP 0 6 PICK 0 D+ SWAP 5 PLACE \ add product to intermediate result  
        ROT >R D+ R>                    \
    LOOP                                \ next iteration of the inner loop
LOOP                                    \ next iteration of the outer loop
NIP 2* DUP SREMOVE ;                    \ clean up  


\ SWAP OVER 0                             \ initialize intermediate result
\ SWAP 4 + 4 DO                           \ iterate over size
\     OVER SWAP I PICK SWAP UM/MOD        \ divide one cell
\     I 1+ PLACE                          \ store result
\ LOOP                                    \ next iteration
\ NIP SWAP ;                              \ clean up

\ NCU/MOD
\ # Perform unsigned division.
\ # args:   size:   size of each struc (in cells)
\ #         struc2: denominator
\ #         struc1: nominator
\ # result: struc4: remainder
\ #         struc3: quotient
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         division by zero (-10)
\ : NCU/MOD ( struc1 struc2 size -- struc3 struc4 ) \ PUBLIC
\ DUP 2* 1+ OVER M0INS                    \ allocate space for quotient
\ DUP 1 DO                                \ iterate over denominator width
\     I PICK IF                           \ find highest denominator cell  
\         I 1+ 1 DO                       \ iterate over nominator
\             NCDUP                       \ DUP denominator
\             DUP 2* I + PICK             \ pick nominator cell
\             I 1- IF                     \ check for previous nominator cell 
\                 OVER I + PICK           \ pick previous nominator cell
\             ELSE                        \ no previous nominator cell available
\                 0                       \ use dummy value
\             THEN                        \ nominator cell picked
\             I 2 + PICK                  \ pick denominator cell
\             UM/MOD NIP                  \ divide cells to estimate digit
\             2DUP SWAP 3 * I + 1+ PLACE \ store digit
\             SWAP NC1U*                  \ multiply denominator by digit
\             TRUE OVER 1+ 1 DO           \ check if a correction is required
\                 I PICK                  \ pick cell from intermediate result
\                 OVER 2* I + 1+ PICK     \ pick cell from nominator
\ 		U< IF                   \ make sure that nominator is larger
\                     DROP FALSE LEAVE    \ nominator is larger
\                 THEN                    \
\             LOOP                        \ keep checking
\ 	    IF                          \ correction required
\             2DUP SWAP 3 * I + 1+ PLACE \ store digit
\             
\ 
\ 
\         LEAVE                           \ done
\     ELSE                                \ denominator cell is zero  
\         DUP 1- I = IF                   \ check if denominator is zero  
\             -10 THROW                   \ throw "division by zero" error
\         THEN                            \ end of zero check
\     THEN                                \ check if denominator cell check
\ LOOP ;	                                \ next iteration


\ # Logic Operations ############################################################

\ NCINVERT
\ # Calculate 1's complement of a multi-cell data structure.
\ # args:   size:   size of each struc (in cells)
\ #         struc1: data structure
\ # result: struc2: resulting data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
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
: NCXOR ( struc1 struc2 size -- struc3 ) \ PUBLIC
['] XOR NCLOGIC ;

\ # Compare Operations ############################################################

\ NCDUP0=
\ # Check if all bits in multi-cell data structure are zero.
\ # args:   size:  size of each struc (in cells)
\ #         struc: data structure
\ # result: flag:  true if all bits in data structure are zero
\ #         struc: data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NCDUP0= ( struc size -- struc flag ) \ PUBLIC
TRUE                                    \ true by default
SWAP 0 DO                               \ iterate over size
    I PICK OR                           \ accumulate data
LOOP                                    \ next iteration
0= ;                                    \ check if combined cells are zero

\ NC0=
\ # Check if all bits in multi-cell data structure are zero.
\ # args:   size:  size of each struc (in cells)
\ #         struc: data structure
\ # result: flag:  true if all bits in data structure are zero
\ #         size:  size of each struc (in cells)
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NC0= ( struc size -- flag ) \ PUBLIC
TRUE                                    \ true by default
SWAP 0 DO                               \ iterate over size
    I ROLL OR                           \ accumulate data
LOOP                                    \ next iteration
0= ;                                    \ check if combined cells are zero


\ NC0<
\ # Interpret data multi-cell data structure as signed integer and check if it
\ # is less than zero.
\ # args:   size:  size of each struc (in cells)
\ #         struc: data structure
\ # result: flag:  true value is greater than zero
\ #         size:  size of each struc (in cells)
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NC0< ( struc size -- size flag ) \ PUBLIC
OVER 0<                                 \ check most significant cell
IF                                      \ negative value
    SDEALLOC TRUE                         \ return TRUE					
ELSE                                    \ positive or zero value
    SDEALLOC FALSE 	                \ return FALSE
THEN ;                                  \ done

\ NC=
\ # Check if two multi-cell data structure are equal.
\ # args:   size:   size of each struc (in cells)
\ #         struc2: data structure
\ #         struc1: data structure
\ # result: flag:  true equal
\ #         size:  size of each struc (in cells)
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NC= ( struc1 struc2 size -- size flag ) \ PUBLIC
NCXOR NC0= ;

\ NC<
\ # Interpret data multi-cell data structure as signed integer and check if
\ # struc1 is less than struc2.
\ # args:   size:   size of each struc (in cells)
\ #         struc2: data structure
\ #         struc1: data structure
\ # result: flag:  true if struc1 < struc2
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NC< ( struc1 struc2 size -- flag ) \ PUBLIC
NC- NC0< ;

\ NC>
\ # Interpret data multi-cell data structure as signed integer and check if
\ # struc1 is less than struc2.
\ # args:   size:   size of each struc (in cells)
\ #         struc2: data structure
\ #         struc1: data structure
\ # result: flag:  true if struc1 > struc2
\ #         size:  size of each struc (in cells)
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NC> ( struc1 struc2 size -- flag ) \ PUBLIC
NCSWAP  NC< ;

\ NCU<
\ # Interpret data multi-cell data structure as unsigned integer and check if
\ # struc1 is less than struc2.
\ # args:   size:   size of each struc (in cells)
\ #         struc2: data structure
\ #         struc1: data structure
\ # result: flag:  true if struc1 < struc2
\ #         size:  size of each struc (in cells)
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NCU< ( struc1 struc2 size -- flag ) \ PUBLIC
FALSE TUCK                              \ result undecided (and false)
OVER 3 + 3 SWAP DO                      \ iterate over size
    I ROLL                              \ get most significant cell from struc1 
    4 ROLL                              \ get most significant cell from struc2
    ROT                                 \ check if result is decided
    IF                                  \ result is decided
        2DROP TRUE                      \ don't compate cells
    ELSE                                \ result is still undecided
        2DUP =                          \ check if cells are equal
        IF                              \ cells are equal
            2DROP FALSE                 \ don't compate cells
        ELSE                            \ cells are not equal 
            U< SWAP ROT DROP TRUE       \ compare cells
        THEN                            \ equality check done                     
    THEN                                \ result check done
-1 +LOOP                                \ next iteration
DROP SWAP ;                             \ clean up

\ NCU>
\ # Interpret data multi-cell data structure as signed integer and check if
\ # struc1 is less than struc2.
\ # args:   size:   size of each struc (in cells)
\ #         struc2: data structure
\ #         struc1: data structure
\ # result: flag:  true if struc1 > struc2
\ #         size:  size of each struc (in cells)
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NCU> ( struc1 struc2 size -- flag ) \ PUBLIC
NCSWAP NCU< ;

\ NCMSB0=
\ # Check if the MSB of a multi-cell data structure is cleared.
\ # args:   size:  size of each struc (in cells)
\ #         struc: data structure
\ # result: flag:  true if MSB is cleared
\ #         size:  size of each struc (in cells)
\ #         struc: data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NCMSB0= ( struc size -- struc size flag ) \ PUBLIC 
OVER 0< INVERT ;

\ NCLSB0=
\ # Check if the LSB of a multi-cell data structure is cleared.
\ # args:   size:  size of each struc (in cells)
\ #         struc: data structure
\ # result: flag:  true if LSB is cleared
\ #         size:  size of each struc (in cells)
\ #         struc: data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NCLSB0= ( struc size -- struc size flag ) \ PUBLIC 
DUP PICK 1 AND 0= ;

\ # Shift Operations ############################################################

\ NCLSHIFT
\ # Perform a logical left shift of u bit-places on struc1, giving struc2
\ # Put zeroes into the least significant bits vacated by the shift.
\ # args:   size:   size of each struc (in cells).
\ #         u:      number of places to shift
\ #         struc1: data structure
\ # result: size:   size of each struc (in cells)
\ #         struc2: shifted data structure
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NCLSHIFT ( struc1 u size -- struc2 size ) \ PUBLIC
SWAP 0 DO                             \ iterate over u
    NC2*			        \ shift by one bit
LOOP ;                                \ next iteration

\ NCRSHIFT
\ # Perform a logical right shift of u bit-places on struc1, giving struc2.
\ # Put zeroes into the most significant bits vacated by the shift.
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

\ NCLALIGN
\ # Left shift a multi cell structure until until the MSB is set, unless all
\ # data are equal to zero.
\ # args:   size:   size of each struc (in cells) 
\ #         struc1: data structure
\ # result: size:   size of each struc (in cells)
\ #         u:      number of performed shifts (-1 if struc1=0)
\ #         struc2: shifted data structure (0 if struc1=0)
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: NCLALIGN ( struc1 size -- struc2 u size ) \ PUBLIC
0 2DUP DO                               \ iterate over size
    DROP                                \ drop intermediate count results
    OVER 0<                             \ check if MSB is set
    IF                                  \ MSB is set
        I LEAVE                         \ return shift counter
    ELSE                                \ MSB is not set
	NC2*                            \ shift data
        -1                              \ push zero result
    THEN                                \ MSB check done
LOOP ;                                  \ next iteration

\ NCRALIGN
\ # Right shift a multi cell structure until until the MSB is set, unless all
\ # data are equal to zero.
\ # args:   size:   size of each struc (in cells)
\ #         struc1: data structure
\ # result: size:   size of each struc (in cells)
\ #         u:      number of performed shifts (-1 if struc1=0)
\ #         struc2: shifted data structure (0 if struc1=0)
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: RCLALIGN ( struc1 size -- struc2 u size ) \ PUBLIC
0 2DUP DO                               \ iterate over size
    DROP                                \ drop intermediate count results
    DUP PICK 1 AND                      \ check if MSB is set
    IF                                  \ MSB is set
        I LEAVE                         \ return shift counter
    ELSE                                \ MSB is not set
	NCU2/                           \ shift data
        -1                              \ push zero result
    THEN                                \ MSB check done
LOOP ;                                  \ next iteration
