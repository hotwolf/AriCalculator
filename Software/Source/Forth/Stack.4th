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
\ #    S12CForth/GForth/SwiftForth - SP@ word                                   #
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

\ PLACE
\ # Opposite of PICK. Replace a cell anywhere on the parameter stack.
\ # args:   u:    position of the cell to be replaced
\ #         xu':  cell to replace xu  
\ #         x0:   untouched cell
\ #         x1:   untouched cell
\ #         ...
\ #         xu-1: untouched cell
\ #         xu:   cell to be replaced
\ # result: x0:   untouched cell
\ #         x1:   untouched cell
\ #         ...
\ #         xu-1: untouched cell
\ #         xu':  cell which replaced xu  
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: PLACE ( xu xu-1 ... x1 x0 xu' u -- xu' xu-1 ... x1 x0 ) \ PUBLIC
2 + CELLS                                     \ add offset to u
SP@ +                                         \ determine target address
! ;                                           \ replace xu

\ UNROLL
\ # Opposite of ROLL. Insert a cell anywhere into the parameter stack.
\ # args:   u:    position of the insertion
\ #         xu:   cell to be inserted
\ #         x0:   untouched cell
\ #         x1:   untouched cell
\ #         ...
\ #         xu-1: untouched cell
\ # result: x0:   untouched cell
\ #         x1:   untouched cell
\ #         ...
\ #         xu-1: untouched cell
\ #         xu:   inserted cell
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: UNROLL ( xu-1 ... x1 x0 xu u -- xu xu-1 ... x1 x0 ) \ PUBLIC
DUP	   	       	       	     	      \ allocate temporal stack space
DUP					      \ save u
2 + CELLS                                     \ calculate upper boundary of I
[ 1 CELLS ] LITERAL	 		      \ calculate lower boundary of I
DO  	    				      \ iterate u times
    SP@ I + DUP [ 1 CELLS ] LITERAL +         \ calculate move source and target
    @ SWAP !                                  \ copy cell at I+1 to I
[ 1 CELLS ] LITERAL +LOOP                     \ iterate with step size of 1 cell
PLACE ;                                       \ move xu to position u

\ REMOVE
\ # Remove a cell anywhere from the parameter stack.
\ # args:   u:    position of cell to be removed
\ #         x0:   untouched cell
\ #         x1:   untouched cell
\ #         ...
\ #         xu:   cell to be removed
\ # result: x0:   untouched cell
\ #         x1:   untouched cell
\ #         ...
\ #         xu-1: untouched cell
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: REMOVE ( xu ... x1 x0 u -- xu-1 ... x1 x0 ) \ PUBLIC
ROLL DROP ;                                   \ remove cell 
