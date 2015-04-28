\ ###############################################################################
\ # AriCalculator - Supplemental Stack Operations                               #
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

\ # Elementary Operations #######################################################

\ SALLOC
\ # Allocate multiple cells at the top of the stack.
\ # args:   u:    number of cells to allocate
\ # result: x0:   random data
\ #         ...
\ #         xu-1: rondom data
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: SALLOC ( u -- xu-1 ... x0 ) \ PUBLIC
1- CELLS SP@ SWAP -                     \ calculate new sack pointer
SP! ; 			                \ set new stack pointer

\ SDEALLOC
\ # Deallocate multiple cells at the top of the stack.
\ # args:   u:    number of cells to remove
\ #         x0:   data
\ #         ...
\ #         xu-1: data
\ # result: -
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: SDEALLOC ( xu ... x0 u -- ) \ PUBLIC
1+ CELLS SP@ +                          \ calculate new sack pointer
SP! ; 			                \ set new stack pointer

\ SMOVE
\ # Move data within the stack
\ # args:   u3:  number of cells to move
\ #         u2:  target location  
\ #         u1:  source location
\ #         x0:  data  
\ #         ...
\ # result: x0': altered data
\ #         ...
\ #         stack underflow (-4)
: SMOVE ( ... x0 u1 u2 u3 u -- ... x0' ) \ PUBLIC
CELLS ROT                               \ calculate byte count
CELLS SP@ + [ 3 CELLS ] LITERAL + ROT   \ calculate target address
CELLS SP@ + [ 3 CELLS ] LITERAL + ROT   \ calculate source address
MOVE ;

\ SINSERT
\ # Allocate/duplicate multiple cells anywhere on the stack.
\ # args:   u2:       number of cells to allocate
\ #         u1:       location  
\ #         ...
\ #         xu1:      data
\ #         ...
\ #         xu1+u2-1: data
\ # result: ..
\ #         xu1:      duplicated data
\ #         ...
\ #         xu1+u2-1: duplicated data
\ #         xu1:      data
\ #         ...
\ #         xu1+u2-1: data
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: SINSERT ( xu1+u2-1 ... xu1 ... u1 u2 -- xu1+u2-1 ... xu1 xu1+u2-1 ... xu1 ) \ PUBLIC
TUCK 2>R SALLOC 2R>                     \ allocate new stack space
TUCK + 0 SWAP SMOVE ;                   \ shift cells

\ SREMOVE
\ # Dellocate multiple cells anywhere on the stack.
\ # args:   u2:       number of cells to deallocate
\ #         u1:       location  
\ #         ...
\ #         xu1:      data
\ #         ...
\ #         xu1+u2-1: data
\ # result: ...
\ #         xu1-1:    data
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: SREMOVE ( xu1+u2-1 ... xu1 ... u1 u2 -- xu1+u2-1 ... xu1 xu1+u2-1 ... xu1 ) \ PUBLIC
TUCK 0 SWAP ROT 1+ SMOVE                \ shift cells
SDEALLOC ;                              \ free stack space

\ # Single-Cell Operations ######################################################

\ PLACE
\ # Opposite of PICK. Replace a cell anywhere on the parameter stack.
\ # args:   u:    position of the cell to be replaced
\ #         xu':  cell to replace xu  
\ #         x0:   untouched cell
\ #         ...
\ #         xu-1: untouched cell
\ #         xu:   cell to be replaced
\ # result: x0:   untouched cell
\ #         ...
\ #         xu-1: untouched cell
\ #         xu':  cell which replaced xu  
\ #         stack underflow (-4)
: PLACE ( xu xu-1 ... x0 xu' u -- xu' xu-1 ... x0 ) \ PUBLIC
2 + CELLS                               \ add offset to u
SP@ +                                   \ determine target address
! ;                                     \ replace xu

\ UNROLL
\ # Opposite of ROLL. Insert a cell anywhere into the parameter stack.
\ # args:   u:    position of the insertion
\ #         xu:   cell to be inserted
\ #         x0:   untouched cell
\ #         ...
\ #         xu-1: untouched cell
\ # result: x0:   untouched cell
\ #         ...
\ #         xu-1: untouched cell
\ #         xu:   inserted cell
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: UNROLL ( xu-1 ... x0 xu u -- xu xu-1 ... x0 ) \ PUBLIC
2DUP                                    \ make room for the shift                
3 2 ROT SMOVE                           \ shift cells
SWAP PLACE ;                            \ place xu

\ 0INS 
\ # Insert a zero anywhere into the parameter stack.
\ # args:   u:    position of the insertion
\ #         x0:   untouched cell
\ #         ...
\ #         xu-1: untouched cell
\ # result: x0:   untouched cell
\ #         ...
\ #         xu-1: untouched cell
\ #         0:    zero
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: 0INS ( xu-1 ... x0 u -- 0 xu-1 ... x1 ) \ PUBLIC
DUP 2 1 SMOVE                           \ shift cells
0 SWAP PLACE ;                          \ place 0

\ REMOVE
\ # Remove a cell anywhere from the parameter stack.
\ # args:   u:    position of cell to be removed
\ #         x0:   untouched cell
\ #         ...
\ #         xu:   cell to be removed
\ # result: x0:   untouched cell
\ #         ...
\ #         xu-1: untouched cell
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: REMOVE ( xu ... x0 u -- xu-1 ... x0 ) \ PUBLIC
ROLL DROP ;                             \ remove cell 

\ # Multi-Cell Operations #######################################################

\ MDUP
\ # Duplicate multiple cells at the top of the stack
\ # args:   u:  number of cells to 
\ #         x0: data
\ #         ...
\ #         xu: data
\ # result: x0: duplicated data
\ #         ...
\ #         xu: duplicated data
\ #         x0: data
\ #         ...
\ #         xu: data
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         result out of range (-11)
: MDUP ( xu ... x0 u -- xu ... x0 xu ... x0 ) \ PUBLIC
DUP >R SALLOC R>                        \ allocate stack space
0 OVER SMOVE ;                          \ duplicate cells

\ MPICK
\ # Pick multiple cells from anywhere on the stack
\ # args:   u2:       number of cells to pick
\ #         u1:       pick offset
\ #         x0:       data
\ #         ...
\ #         xu1+u2-1: data
\ # result: xu1:      duplicated data
\ #         ...
\ #         xu1+u2-1: duplicated data
\ #         x0:       data
\ #         ...
\ #         xu1+u2-1: data
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         result out of range (-11)
: MPICK ( xu1+u2-1 ... x0 u1 u2 -- xu1+u2-1 ... x0 xu1+u2-1 ... xu1 ) \ PUBLIC
TUCK 2>R SALLOC 2R>                       \ allocate new stack space
TUCK + 0 ROT SMOVE ;                      \ move data

\ MPLACE
\ # Replace multiple cells anywhere on the stack
\ # args:   u2:       number of cells to place
\ #         u1:       place offset (u2<=u1)
\ #         x0:       data
\ #         ...
\ #         xu1+u2-1: data
\ # result: xu2:      data
\ #         ...
\ #         xu1-1:    data
\ #         x0:       data
\ #         ...
\ #         xu2-1:    data
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         result out of range (-11)
: MPLACE ( xu1+u2-1 ... x0 u1 u2 -- xu2-1 ... x0 xu1-1 ... x0 ) \ PUBLIC
0 ROT ROT DUP >R SMOVE R>               \ move data
SDEALLOC ;                              \ deallocate stack space

\ MROLL
\ # Extract multiple cells anywhere on the stack
\ # args:   u2:       number of cells to rotate
\ #         u1:       unroll offset
\ #         x0:       rotated data
\ #         ...
\ #         xu1+u2-1: rotated data
\ # result: xu1:      data
\ #         ...
\ #         xu1+u2-1: data
\ #         x0:       data
\ #         ...
\ #         xu1-1:    data
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         result out of range (-11)
: MROLL ( xu1+u2-1 ... x0 u1 u2 -- xu1-1 ... x0 xu1+u2-1 ... xu1 ) \ PUBLIC
2DUP 2>R MPICK 2R>                      \ move data  
TUCK + SWAP SREMOVE ;                   \ deallocate stack space

\ MUNROLL
\ # Insert multiple cells anywhere on the stack
\ # args:   u2:       number of cells to rotate
\ #         u1:       unroll offset
\ #         xu1:      data
\ #         ...
\ #         xu1+u2-1: data
\ #         x0:       data
\ #         ...
\ #         xu1-1:    data
\ # result: x0:       rotated data
\ #         ...
\ #         xu1+u2-1: rotated data
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         result out of range (-11)
: MUNROLL ( xu1-1 ... x0 xu1+u2-1 ... xu1 u1 u2 -- xu1+u2-1 ... x0 ) \ PUBLIC
2DUP 2>R SINSERT 2R>                    \ allocate stack space
MPLACE ;                                \ move data

\ M0INS
\ # Insert a zero anywhere into the parameter stack.
\ # args:   u2:    number of zeros to insert
\ #         u1:    position of the insertion
\ #         x0:    untouched cell
\ #         ...
\ #         xu1-1: untouched cell
\ # result: x0:    untouched cell
\ #         ...
\ #         xu1-1: untouched cell
\ #         0:     zero
\ #         ...
\ #         0:     zero
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: M0INS ( xu-1 ... x1 x0 xu u1 u2 -- 0 ... 0 xu-1 ... x1 x0 ) \ PUBLIC
2DUP 2>R SINSERT 2R>                    \ allocate stack space
OVER + SWAP DO                          \ iterate over u2
    0 I PLACE                            \ place zero
LOOP ;                                  \ next iteration
