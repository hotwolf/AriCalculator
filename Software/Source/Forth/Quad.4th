\ ###############################################################################
\ # AriCalculator - Quad-Cell Number Operations                                 #
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
\ #   This module implements quad-cell number operations.                       #
\ #                                                                             #
\ # Data types:                                                                 #
\ #   q          - quad-cell number                                             #
\ #   uq         - unsigned quad-cell number                                    #
\ #   dq         - double quad-cell number                                      #
\ ###############################################################################
\ # Version History:                                                            #
\ #    April 8, 2015                                                            #
\ #      - Initial release                                                      #
\ ###############################################################################
\ # Required Word Sets:                                                         #
\ #    ANSForth - CORE word set                                                 #
\ #               DOUBLE word set                                               #
\ #    NStack   - Stack Operations for Multi-Cell Data Structures               #
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

\ # Stacking Arithmetic #########################################################

\ Drop last quad-cell number
\ # args:   q: quad-cell number
\ # result: --
\ # throws: stack overflow (-3)
\           stack underflow (-4)
: QDROP ( q -- )			\ PUBLIC
4 NDROP ;

\ Duplicate last quad-cell number
\ # args:   q: quad-cell number
\ # result: q: duplicated quad-cell number
\ #         q: quad-cell number
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: QDUP ( q -- q q)  \ PUBLIC
4 NDUP ;

\ Duplicate previous quad-cell number
\ # args:   q2: quad-cell number
\ #         q1: quad-cell number
\ # result: q1: duplicated quad-cell number 
\ #         q2: quad-cell number
\ #         q1: quad-cell number
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: QOVER ( q1 q2 -- q1 q2 q1 )  \ PUBLIC
4 NOVER ;

\ Swap two quad-cell numbers
\ # args:   q1: quad-cell number
\ #         q2: quad-cell number
\ # result: q2: quad-cell number
\ #         q1: quad-cell number
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: QSWAP ( q2 q1 -- q1 q2 )  \ PUBLIC
4 NSWAP ;

\ ROTATE over three quad-cell numbers
\ # args:   q3: quad-cell number
\ #         q2: quad-cell number
\ #         q1: quad-cell number
\ # result: q1: quad-cell number
\ #         q3: quad-cell number
\ #         q2: quad-cell number
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: QROT ( q1 q2 q3 -- q2 q3 q1 )   \ PUBLIC
4 NROT ;

\ Rotate over multiple quad-cell numbers
\ # args:   u:    number of quad-cell numbers to rotate
\ #         q0:   quad-cell number
\ #         ...
\ #         qu:   quad-cell number
\ # result: qu:   quad-cell number
\ #         q0:   quad-cell number
\ #         ...
\ #         qu-1: quad-cell number
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
\ #         result out of range (-11)
: QROLL ( qu ... q0 u -- qu-1 ...  q0 qu ) \ PUBLIC
4 NROLL ;

\ # Arithmetic Operations ########################################################

\ Increment quad-cell number
\ # args:   q1:  quad-cell number
\ # result: q2:  incremented quad-cell number
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: Q1+ ( q1 -- q2 ) \ PUBLIC
[ 0 1 ] 2LITERAL      \ constant one
4 0 DO	      	      \ repeat four times
  6 ROLL              \ get least significant cell
  M+		      \ add constant one
  

4 ROLL INVERT	      \ rotate and invert





4 0 DO	      	      \ repeat four times
  4 ROLL INVERT	      \ rotate and invert
LOOP ;


\ Invert quad-cell number (1's complement)
\ # args:   q1:  quad-cell number
\ # result: q2:  inverted quad-cell number
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: QINVERT ( q1 -- q2 ) \ PUBLIC
4 0 DO	      	      \ repeat four times
  4 ROLL INVERT	      \ rotate and invert
LOOP ;

\ Negate quad-cell number (2's complement)
\ # args:   q1:  quad-cell number
\ # result: q2:  negated quad-cell number
\ # throws: stack overflow (-3)
\ #         stack underflow (-4)
: QNEGATE ( q1 -- q2 ) \ PUBLIC
QINVERT Q1+ ;



