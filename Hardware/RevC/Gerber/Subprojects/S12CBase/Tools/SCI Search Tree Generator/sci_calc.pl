#!/usr/bin/env perl
###############################################################################
# S12CBase - Search Tree Generator for the SCI Driver                         #
###############################################################################
#    Copyright 2009-2012 Dirk Heisswolf                                       #
#    This file is part of the S12CBase framework for Freescale's S12(X) MCU   #
#    families.                                                                #
#                                                                             #
#    S12CBase is free software: you can redistribute it and/or modify         #
#    it under the terms of the GNU General Public License as published by     #
#    the Free Software Foundation, either version 3 of the License, or        #
#    (at your option) any later version.                                      #
#                                                                             #
#    S12CBase is distributed in the hope that it will be useful,              #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
#    GNU General Public License for more details.                             #
#                                                                             #
#    You should have received a copy of the GNU General Public License        #
#    along with S12CBase.  If not, see <http://www.gnu.org/licenses/>.        #
###############################################################################
# Description:                                                                #
#    This perl script generates the assembler source for two search trees,    #
#    which are used by the S12CBase baud rate detection.                      #
#    One is used to determine the set of baud rates that are valid for a      #
#    certain high pulse.                                                      #
#    The other one is used to determine the set of baud rates that are valid  #
#    for a certain low pulse.                                                 #
#                                                                             #
#    Each table assigs a set of valid baud rates to a range of pulse lengths. #
#    lower boundary <= pulse length < upper boundary -> set of baud rates     #
#                                                                             #
#    The format of a node entry is the following:                             #
#                                                                             #
#                      +--------+--------+                                    #
#    start of entry -> | lower boundary  | value of lower boundary            #
#                      +--------+--------+                                    #
#                      |  BRs   |  BRs   | set of boud rates - twice          #
#                      +--------+--------+                                    #
#                      |  node pointer   | pointer to node with longer        #
#                      +--------+--------+ boundary value                     #
#    node node with -> | lower boundary  |                                    #
#    even lower        +--------+--------+                                    #
#    boundary value    |  BRs   |  BRs   |                                    #
#                      +--------+--------+                                    #
#                      |  node pointer   |                                    #
#                      +--------+--------+                                    #
#                                                                             #
###############################################################################
# Version History:                                                            #
#    14 May, 2009                                                             #
#      - Initial release                                                      #
#    18 July, 2012                                                            #
#      - Added command line parameters                                        #
#      - Reworked boundary calulation                                         #
#      - Reworked search tree balancing                                       #
#    15 November, 2012                                                        #
#      - Fixed prescaler option                                               #
###############################################################################

#################
# Perl settings #
#################
use 5.005;
#use warnings;
use File::Basename;
use FindBin qw($RealBin);
use lib $RealBin;

###############
# global vars #
###############
$need_help         = 0;
$arg_type          = "C";
$clock_freq        = 25000000;
$div_clock_freq    = 25000000;
$prescaler         = 1;
$frame_format      = "8N1";
$low_bit_counts    = [1, 2, 3, 4, 5, 6, 7, 8, 9];
$fixed_parse_time  = 2;
$lower_step_time   = 10;
$higher_step_time  = 17;
$lower_term_time   = 6;
$higher_term_time  = 15;

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year += 1900;
@months = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec");
@days   = ("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat");

@tables = ({'file'       => "sci_bdtab.s",
	   #'baud_masks' => {  '4800' => 0x01,
	   #		       '9600' => 0x02,
	   #		      '19200' => 0x04,
	   #		      '38400' => 0x08,
	   #		      '57600' => 0x10,
	   #		      '76800' => 0x20,
	   #		     '115200' => 0x40,
	   #		     '153600' => 0x80},
	    'baud_masks' => {  '4800' => 0x01,
			       '7200' => 0x02,
			       '9600' => 0x04,
			      '14400' => 0x08,
			      '19200' => 0x10,
			      '28800' => 0x20,
			      '38400' => 0x40,
			      '57600' => 0x80},
	   });

##########################
# read command line args #
##########################
#printf "parsing args: count: %s\n", $#ARGV + 1;
foreach $arg (@ARGV) {
    #printf "  arg: %s\n", $arg;

    #Help
    if ($arg =~ /^\s*-*(?|help|h)\s*$/i) {
	$need_help = 1;
    } 

    #Arg type	
    elsif ($arg =~ /^\s*-(C|F|T)\s*$/i) {
	$arg_type = $1;
    }

    #Args	
    elsif (($arg_type =~ /^C$/i) && ($arg =~ /^\s*(\d+)\s*$/i)) {
	$clock_freq = int($1);
    }
    elsif (($arg_type =~ /^T$/i) && ($arg =~ /^\s*(\d+)\s*$/i)) {
	$prescaler = int($1);
    }
    elsif (($arg_type =~ /^F$/i) && ($arg =~ /^\s*(7E1|7O1|7N2|8N1|8E1|8O1|8N2|9N1)\s*$/i)) {
	$frame_format = $1;
    }

    #Wrong args	
    else {
	$need_help = 1;
    } 
}

###################
# print help text #
###################
if ($need_help) {
    printf "usage: %s [-C bus clock frequency in Hz] [-F 7E1|7O1|7N2|8N1|8E1|8O1|8N2|9N1] [-T timer prescaler]\n", $0;
    print  "\n";
    exit;
}

################
# divide clock #
################
$div_clock_freq = $clock_freq / $prescaler;

########################################
# determine maximum number of low bits #
########################################
for ($frame_format) {
    ############
    # 7O1, 7N2 #
    ############
    /^\s(7O1|7N2)\s*$/i && do {
        $low_bit_counts  = [1, 2, 3, 4, 5, 6, 7, 8];
        last;};
    #######
    # 7E1 #
    #######
    /^\s(7E1)\s*$/i && do {
        $low_bit_counts  = [1, 2, 3, 4, 5, 6, 7, 9]; #8 consecutive low bits not possible
	last;};
    #################
    # 8O1, 8N1, 8N2 #
    #################
    /^\s(8O1|8N1|8N2)\s*$/i && do {
        $low_bit_counts  = [1, 2, 3, 4, 5, 6, 7, 8, 9];
	last;};
    #######
    # 8E1 #
    #######
    /^\s(8E1)\s*$/i && do {
        $low_bit_counts  = [1, 2, 3, 4, 5, 6, 7, 8, 10]; #9 consecutive low bits not possible
	last;};
    #######
    # 9N1 #
    #######
    /^\s(9N1)\s*$/i && do {
        $low_bit_counts  = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
	last;};
}

###################################
# calculate RT clock $prescalers  #
###################################
foreach my $table (@tables) {
    $baud_masks = $table->{'baud_masks'};
    $baud_divs  = $table->{'baud_divs'};
    $bit_cycs   = $table->{'bit_cycs'};

    foreach $baud_mask (keys %$baud_masks) {
	$table->{'baud_divs'}->{$baud_mask} = ($clock_freq/(16*$baud_mask))+(((2*$clock_freq)/(16*$baud_mask))&1);
	$table->{'bit_cycs'}->{$baud_mask}  = ($div_clock_freq/(16*$baud_mask))+(((2*$div_clock_freq)/(16*$baud_mask))&1);
    }
}

########################
# calculate boundaries #
########################
foreach my $table (@tables) {
    my $baud_masks = $table->{'baud_masks'};
    my $baud_divs  = $table->{'baud_divs'};
    my $bit_cycs   = $table->{'bit_cycs'};
    my $lower_boundary;
    my $upper_boundary;

    foreach my $baud (keys %$baud_divs) {
	$baud_div  = $baud_divs->{$baud};
	$bit_cyc   = $bit_cycs->{$baud};
	$baud_mask = $baud_masks->{$baud};
	
	#print "baud      = $baud\n";
	#print "baud_div  = $baud_div\n";
	#print "bit_cyc   = $bit_cyc\n";
	#print "baud_mask = $baud_mask\n";
	
	#low pulse boundaries:  
	#  for each valid bit length n:              n*16-6  <=  RT cycles < (           n*16+7 ) + 1
	#                                 bit_cyc * (n*16-6) <= TIM cycles < (bit_cyc * (n*16+7)) + 1 
	foreach $n (@$low_bit_counts) {
	    $lower_boundary      = int( $bit_cyc*((16*$n)-6));
	    $upper_boundary      = int(($bit_cyc*((16*$n)+7))+1);
	    
	    $table->{'low_pulse_boundaries'}->{$lower_boundary}->{lower}->{$baud_mask} = $n;
	    $table->{'low_pulse_boundaries'}->{$upper_boundary}->{upper}->{$baud_mask} = $n;
	}
	
	#shortest high pulse length:  
	#  allow 5% tolerance:                      16 * 0.95 <=  RT cycles
	#                                 bit_cyc * 16 * 0.95 <= TIM cycles
	$lower_boundary = int(($bit_cyc*16)*0.95);
	
	$table->{'high_pulse_boundaries'}->{$lower_boundary}->{lower}->{$baud_mask} = $n;
    }   
}

################
# build tables #
################
foreach my $table (@tables) {
    my $baud_masks;
    my $accumulated_baud_mask;
    my $comment;
    my $boundary;
 
    #low pulse table
    $baud_mask;
    $accumulated_baud_mask;
    $comment = [".", ".", ".", ".", ".", ".", ".", "."];
    @low_pulse_table = ();
    $accumulated_baud_mask = 0;
    foreach $boundary (sort {$a <=> $b} keys %{$table->{'low_pulse_boundaries'}}) {
	if (exists $table->{'low_pulse_boundaries'}->{$boundary}->{lower}) {
	    foreach $baud_mask (keys %{$table->{'low_pulse_boundaries'}->{$boundary}->{lower}}) {
		#printf STDOUT "%4X: accumulated_baud_mask=%X baud_mask=%X -> new accumulated_baud_mask=%X\n", $boundary, $accumulated_baud_mask, $baud_mask, $accumulated_baud_mask | $baud_mask;
		$accumulated_baud_mask = $accumulated_baud_mask | $baud_mask;
		if ($baud_mask & 0x80) {$comment->[0] = $table->{'low_pulse_boundaries'}->{$boundary}->{lower}->{$baud_mask};}
		if ($baud_mask & 0x40) {$comment->[1] = $table->{'low_pulse_boundaries'}->{$boundary}->{lower}->{$baud_mask};}
		if ($baud_mask & 0x20) {$comment->[2] = $table->{'low_pulse_boundaries'}->{$boundary}->{lower}->{$baud_mask};}
		if ($baud_mask & 0x10) {$comment->[3] = $table->{'low_pulse_boundaries'}->{$boundary}->{lower}->{$baud_mask};}
		if ($baud_mask & 0x08) {$comment->[4] = $table->{'low_pulse_boundaries'}->{$boundary}->{lower}->{$baud_mask};}
		if ($baud_mask & 0x04) {$comment->[5] = $table->{'low_pulse_boundaries'}->{$boundary}->{lower}->{$baud_mask};}
		if ($baud_mask & 0x02) {$comment->[6] = $table->{'low_pulse_boundaries'}->{$boundary}->{lower}->{$baud_mask};}
		if ($baud_mask & 0x01) {$comment->[7] = $table->{'low_pulse_boundaries'}->{$boundary}->{lower}->{$baud_mask};}
	    }
	}
	if (exists $table->{'low_pulse_boundaries'}->{$boundary}->{upper}) {
	    foreach $baud_mask (keys %{$table->{'low_pulse_boundaries'}->{$boundary}->{upper}}) {
		#printf STDOUT "%4X: accumulated_baud_mask=%X baud_mask=%X ~baud_mask=%X -> new accumulated_baud_mask=%X\n", $boundary, $accumulated_baud_mask, $baud_mask, ($baud_mask^0xff), $accumulated_baud_mask & ($baud_mask^0xff);
		$accumulated_baud_mask = $accumulated_baud_mask & ($baud_mask^0xff);
		if ($baud_mask & 0x80) {$comment->[0] = ".";}
		if ($baud_mask & 0x40) {$comment->[1] = ".";}
		if ($baud_mask & 0x20) {$comment->[2] = ".";}
		if ($baud_mask & 0x10) {$comment->[3] = ".";}
		if ($baud_mask & 0x08) {$comment->[4] = ".";}
		if ($baud_mask & 0x04) {$comment->[5] = ".";}
		if ($baud_mask & 0x02) {$comment->[6] = ".";}
		if ($baud_mask & 0x01) {$comment->[7] = ".";}
	    } 
	}
	
	$low_pulse_table_entry = {"mask"        => $accumulated_baud_mask,
	 	                  "boundary"    => $boundary,
			          "comment"     => join(" ", @$comment),
				  "weight"      => 1,
                                  "depth"       => 1,
                                  "parse_time"  => $fixed_parse_time};
	push @low_pulse_table, $low_pulse_table_entry;
    }
    $table->{'low_pulse_table'} = [@low_pulse_table];

    #high pulse table
    $baud_mask;
    $accumulated_baud_mask;
    $comment = [".", ".", ".", ".", ".", ".", ".", "."];
    @high_pulse_table = ();
    $accumulated_baud_mask = 0;
    foreach $boundary (sort {$a <=> $b} keys %{$table->{'high_pulse_boundaries'}}) {
	if (exists $table->{'high_pulse_boundaries'}->{$boundary}->{lower}) {
	#printf STDOUT "High_pulse_table exists.\n";
	    foreach $baud_mask (keys %{$table->{'high_pulse_boundaries'}->{$boundary}->{lower}}) {
		$accumulated_baud_mask = $accumulated_baud_mask | $baud_mask;
		if ($baud_mask & 0x80) {$comment->[0] = "1";}
		if ($baud_mask & 0x40) {$comment->[1] = "1";}
		if ($baud_mask & 0x20) {$comment->[2] = "1";}
		if ($baud_mask & 0x10) {$comment->[3] = "1";}
		if ($baud_mask & 0x08) {$comment->[4] = "1";}
		if ($baud_mask & 0x04) {$comment->[5] = "1";}
		if ($baud_mask & 0x02) {$comment->[6] = "1";}
		if ($baud_mask & 0x01) {$comment->[7] = "1";}
	    }
	}
	
	$high_pulse_table_entry = {"mask"        => $accumulated_baud_mask,
	  	                   "boundary"    => $boundary,
			           "comment"     => join(" ", @$comment),
				   "weight"      => 1,
                                   "depth"       => 1,
                                   "parse_time"  => $fixed_parse_time};
	#printf STDOUT "New high_pulse_table entry./n";
	push @high_pulse_table, $high_pulse_table_entry;
    }
    $table->{'high_pulse_table'} = [@high_pulse_table];
}

#####################
# calculate weights #
#####################
foreach $table (@tables) {
    $low_pulse_table  = $table->{'low_pulse_table'};
    $high_pulse_table = $table->{'high_pulse_table'};    
    $low_pulse_table_entry;
    $high_pulse_table_entry;

    $min_pulse       = 0xffff;
    $max_pulse       = 0;
    $average_sum     = 0;
    $average_count   = 0;
    $average_pulse;

   #low pulse table
   #calculate average pulse length and set preliminary weights based on occurance
    foreach $low_pulse_table_entry (@$low_pulse_table) {
	#calculate min/max
	if ($low_pulse_table_entry->{'boundary'} < $min_pulse) {$min_pulse = $low_pulse_table_entry->{'boundary'};}
	if ($low_pulse_table_entry->{'boundary'} > $max_pulse) {$max_pulse = $low_pulse_table_entry->{'boundary'};}
	#printf STDOUT "Min pulse    = %X (%X)\n",  $min_pulse, $low_pulse_table_entry->{'boundary'};

	#count mask bits
	my $mask       = $low_pulse_table_entry->{'mask'};
	my $mask_count = 0;
	foreach my $i (1..8) {
	    $mask_count += ($mask & 1) ? 1 : 0;
	    $mask >>= 1;
	}
	#calculate average
	$average_sum    += $low_pulse_table_entry->{'boundary'} * $mask_count;
	$average_count  += $mask_count;
	#set preliminary weight
	$low_pulse_table_entry->{'weight'} = $mask_count;
    }
    $average_pulse = $average_sum/$average_count;
    #printf STDOUT "Average pulse= %X\n",  $average_pulse;
    #printf STDOUT "Min pulse    = %X\n",  $min_pulse;

    #give shorter pulses a more weight
    foreach $low_pulse_table_entry (@$low_pulse_table) {
	if ($low_pulse_table_entry->{'boundary'} < $average_pulse) {
	    
	   #my $relative_weight = (((($average_pulse - $low_pulse_table_entry->{'boundary'}) / ($average_pulse - $min_pulse)) ** 20) *1000) + 1; #good result
	    my $relative_weight = (((($average_pulse - $low_pulse_table_entry->{'boundary'}) / ($average_pulse - $min_pulse)) ** 40) *2000) + 1;
	    $low_pulse_table_entry->{'weight'} *= $relative_weight;	
	}
    }

    #high pulse table
    #calculate average pulse length and set preliminary weights based on occurance
    $min_pulse       = 0xffff;
    $max_pulse       = 0;
    $average_sum     = 0;
    $average_count   = 0;
    $average_pulse;

    #calculate average pulse length and set preliminary weights based on occurance
    foreach $high_pulse_table_entry (@$high_pulse_table) {
	#calculate min/max
	if ($high_pulse_table_entry->{'boundary'} < $min_pulse) {$min_pulse = $high_pulse_table_entry->{'boundary'};}
	if ($high_pulse_table_entry->{'boundary'} > $max_pulse) {$max_pulse = $high_pulse_table_entry->{'boundary'};}
	#printf STDOUT "Min pulse    = %X (%X)\n",  $min_pulse, $high_pulse_table_entry->{'boundary'};

	#count mask bits
	my $mask       = $high_pulse_table_entry->{'mask'};
	my $mask_count = 0;
	foreach my $i (1..8) {
	    $mask_count += ($mask & 1) ? 1 : 0;
	    $mask >>= 1;
	}
	#calculate average
	$average_sum    += $high_pulse_table_entry->{'boundary'} * $mask_count;
	$average_count  += $mask_count;
	#set preliminary weight
	$high_pulse_table_entry->{'weight'} = $mask_count;
    }
    $average_pulse = $average_sum/$average_count;
    #printf STDOUT "Average pulse= %X\n",  $average_pulse;
    #printf STDOUT "Min pulse    = %X\n",  $min_pulse;

    #give shorter pulses a more weight
    foreach $high_pulse_table_entry (@$high_pulse_table) {
	if ($high_pulse_table_entry->{'boundary'} < $average_pulse) {
	    
	    my $relative_weight = (((($average_pulse - $high_pulse_table_entry->{'boundary'}) / ($average_pulse - $min_pulse)) ** 2) *10) + 1;
	    $high_pulse_table_entry->{'weight'} *= $relative_weight;	
	}
    }
}

#############################
# build binary search trees #
#############################
foreach my $table (@tables) {
    $low_pulse_table  = $table->{'low_pulse_table'};
    $high_pulse_table = $table->{'high_pulse_table'};    
    $low_pulse_tree   = build_tree($low_pulse_table);
    $high_pulse_tree  = build_tree($high_pulse_table);
    
    $table->{'low_pulse_tree'}  = $low_pulse_tree;
    $table->{'high_pulse_tree'} = $high_pulse_tree;
}

###################
# print ASM files #
###################
foreach $table (@tables) {
    $file             = $table->{'file'};
    $baud_masks       = $table->{'baud_masks'};
    $baud_divs        = $table->{'baud_divs'};
    $low_pulse_table  = $table->{'low_pulse_table'};
    $high_pulse_table = $table->{'high_pulse_table'};

    %low_pulse_boundaries   = ();
    %high_pulse_boundaries  = ();
    @low_pulse_table        = ();
    @high_pulse_table       = ();
    $low_pulse_table_entry;
    $high_pulse_table_entry;
    $low_pulse_tree_list;
    $high_pulse_tree_list;
    $lower_boundary;
    $upper_boundary;
    $boundary;
    
    #Open file
    #--------- 
    if (open (FILEHANDLE, sprintf(">%s", $file))) {

	#Print header
	#------------ 
        printf FILEHANDLE "#ifndef SCI_BD\n"; 
        printf FILEHANDLE "#define SCI_BD\n"; 
        printf FILEHANDLE ";###############################################################################\n"; 
        printf FILEHANDLE ";# S12CBase - SCI Baud Detection Search Trees                                  #\n";
        printf FILEHANDLE ";###############################################################################\n";
        printf FILEHANDLE ";#    Copyright 2009-2012 Dirk Heisswolf                                       #\n";
        printf FILEHANDLE ";#    This file is part of the S12CBase framework for Freescale's S12(X) MCU   #\n";
        printf FILEHANDLE ";#    families.                                                                #\n";
        printf FILEHANDLE ";#                                                                             #\n";
        printf FILEHANDLE ";#    S12CBase is free software: you can redistribute it and/or modify         #\n";
        printf FILEHANDLE ";#    it under the terms of the GNU General Public License as published by     #\n";
        printf FILEHANDLE ";#    the Free Software Foundation, either version 3 of the License, or        #\n";
        printf FILEHANDLE ";#    (at your option) any later version.                                      #\n";
        printf FILEHANDLE ";#                                                                             #\n";
        printf FILEHANDLE ";#    S12CBase is distributed in the hope that it will be useful,              #\n";
        printf FILEHANDLE ";#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #\n";
        printf FILEHANDLE ";#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #\n";
        printf FILEHANDLE ";#    GNU General Public License for more details.                             #\n";
        printf FILEHANDLE ";#                                                                             #\n";
        printf FILEHANDLE ";#    You should have received a copy of the GNU General Public License        #\n";
        printf FILEHANDLE ";#    along with S12CBase.  If not, see <http://www.gnu.org/licenses/>.        #\n";
        printf FILEHANDLE ";###############################################################################\n";
        printf FILEHANDLE ";# Description:                                                                #\n";
        printf FILEHANDLE ";#    This file contains the two search trees which are required for the SCI   #\n";
        printf FILEHANDLE ";#    modules baud rate detection.                                             #\n";
        printf FILEHANDLE ";#    One is used to determine the set of baud rates that are valid for a      #\n";
        printf FILEHANDLE ";#    certain high pulse.                                                      #\n";
        printf FILEHANDLE ";#    The other one is used to determine the set of baud rates that are valid  #\n";
        printf FILEHANDLE ";#    for a certain low pulse.                                                 #\n";
        printf FILEHANDLE ";#                                                                             #\n";
        printf FILEHANDLE ";#    Each table assigs a set of valid baud rates to a range of pulse lengths. #\n";
        printf FILEHANDLE ";#    lower boundary <= pulse length < upper boundary -> set of baud rates     #\n";
        printf FILEHANDLE ";#                                                                             #\n";
        printf FILEHANDLE ";#    The format of a node entry is the following:                             #\n";
        printf FILEHANDLE ";#                                                                             #\n";
        printf FILEHANDLE ";#                      +--------+--------+                                    #\n";
        printf FILEHANDLE ";#    start of entry -> | lower boundary  | value of lower boundary            #\n";
        printf FILEHANDLE ";#                      +--------+--------+                                    #\n";
        printf FILEHANDLE ";#                      |  BRs   |  BRs   | set of boud rates - twice          #\n";
        printf FILEHANDLE ";#                      +--------+--------+                                    #\n";
        printf FILEHANDLE ";#                      |  node pointer   | pointer to node with longer        #\n";
        printf FILEHANDLE ";#                      +--------+--------+ boundary value                     #\n";
        printf FILEHANDLE ";#    node node with -> | lower boundary  |                                    #\n";
        printf FILEHANDLE ";#    even lower        +--------+--------+                                    #\n";
        printf FILEHANDLE ";#    boundary value    |  BRs   |  BRs   |                                    #\n";
        printf FILEHANDLE ";#                      +--------+--------+                                    #\n";
        printf FILEHANDLE ";#                      |  node pointer   |                                    #\n";
        printf FILEHANDLE ";#                      +--------+--------+                                    #\n";
        printf FILEHANDLE ";#                                                                             #\n";
        printf FILEHANDLE ";###############################################################################\n";
        printf FILEHANDLE ";# Generated on %3s, %3s %.2d %4d                                               #\n", $days[$wday], $months[$mon], $mday, $year;
        printf FILEHANDLE ";###############################################################################\n";
        printf FILEHANDLE ";# Bus clock:              %4.2f MHz %-30s            #\n", ($clock_freq/1000000), ($prescaler > 1) ? sprintf("divided by %2d", $prescaler) : "";
        printf FILEHANDLE ";# Frame format:           %3s                                                 #\n", $frame_format;
        printf FILEHANDLE ";# Supported baud rates:                                                       #\n";
	foreach my $baud (sort {$a <=> $b} keys %$baud_divs) {
	    printf FILEHANDLE ";#                      %6.d (%4X)                                          #\n", $baud, $baud_divs->{$baud};
	}
        printf FILEHANDLE ";###############################################################################\n";
	printf FILEHANDLE "\n";

	#Print low pulse table
	#--------------------- 	
        printf FILEHANDLE ";###############################################################################\n";
	print  FILEHANDLE ";# Low pulse search tree                                                       #\n";
        printf FILEHANDLE ";###############################################################################\n";
	print  FILEHANDLE "#macro SCI_BD_LOW_PULSE_TREE, 0\n";
	print  FILEHANDLE print_table($baud_divs, $low_pulse_table);
	#Print low pulse tree
        printf FILEHANDLE ";#\n";
	$low_pulse_tree_list = [$table->{'low_pulse_tree'}];
	printf FILEHANDLE print_tree($low_pulse_tree_list);
        printf FILEHANDLE ";#\n";
	#Print ASM code
	printf FILEHANDLE print_asm($table->{'low_pulse_tree'}, "00");
	print  FILEHANDLE "#emac\n";
        printf FILEHANDLE "\n";
	
	#Print high pulse table
	#---------------------- 	
        printf FILEHANDLE ";###############################################################################\n";
	print  FILEHANDLE ";# High pulse search tree                                                      #\n";
        printf FILEHANDLE ";###############################################################################\n";
	print  FILEHANDLE "#macro SCI_BD_HIGH_PULSE_TREE, 0\n";
	#Print low pulse tree
 	print  FILEHANDLE print_table($baud_divs, $high_pulse_table);
	printf FILEHANDLE ";#\n";
	$high_pulse_tree_list = [$table->{'high_pulse_tree'}];
	printf FILEHANDLE print_tree($high_pulse_tree_list);
        printf FILEHANDLE ";#\n";
	#Print ASM code
	printf FILEHANDLE print_asm($table->{'high_pulse_tree'}, "00");
	print  FILEHANDLE "#emac\n";
        printf FILEHANDLE "\n";

	#Print parse routine
	#------------------- 	
        printf FILEHANDLE ";###############################################################################\n";
	print  FILEHANDLE ";# Parse routine                                                               #\n";
        printf FILEHANDLE ";###############################################################################\n";
	printf FILEHANDLE ";#Parse search tree for detected pulse length\n";
	printf FILEHANDLE "; args:   Y: root of the search tree\n";
	printf FILEHANDLE ";         X: pulse length\n";
	printf FILEHANDLE "; result: D: list of matching baud rates (mirrored in high and low byte)\n";
	printf FILEHANDLE "; SSTACK: 0 bytes\n";
	printf FILEHANDLE ";         X is preserved\n"; 
        printf FILEHANDLE "#macro	SCI_BD_PARSE, 0\n";
        printf FILEHANDLE "		LDD	#\$0000		;  2 cycs	;initialize X\n";
        printf FILEHANDLE "LOOP		TST	0,Y	     	;  3 cycs	;check if lower boundary exists\n";
        printf FILEHANDLE "		BEQ	DONE		;1/3 cycs	;search done\n";
        printf FILEHANDLE "		CPX	6,Y+		;  3 cycs	;check if pulse length is shorter than lower boundary\n";
        printf FILEHANDLE "		BLO	LOOP		;1/3 cycs	;pulse length is shorter than lower boundary -> try a shorter range\n";
        printf FILEHANDLE "		LDD	-4,Y		;  3 cycs	;new lowest boundary found -> store valid baud rate field in index X\n";
        printf FILEHANDLE "		LDY	-2,Y		;  3 cycs	;switch to the branch with higher compare values\n";
        printf FILEHANDLE "		BNE	LOOP		;1/3 cycs	;parse branch if it exists\n";
        printf FILEHANDLE "DONE		EQU	*				;done, result in X\n";
	print  FILEHANDLE "#emac\n";
	print  FILEHANDLE "#endif\n";
    }
    close FILEHANDLE
}

sub build_tree {
    my $pulse_table = shift @_;
    my $pulse_table_entry;
    my $sum_of_weights;
    my $center_of_weight = 0;
    my @lower_table      = ();
    my @higher_table     = (@$pulse_table);
    my $tree_node;
    my $tree_node_width  = 1;
    my $higher_child_node;
    my $lower_child_node;
    my $count_table_entry;

    #calculate sum of weights
    $sum_of_weights;
    foreach $pulse_table_entry (@$pulse_table) {
	$sum_of_weights += $pulse_table_entry->{'weight'} ;
    }
 
    #split table at center of weight
    while (($#higher_table >= 0) && ($center_of_weight < ($sum_of_weights/2))) {
	$pulse_table_entry = shift @higher_table;
	push @lower_table, $pulse_table_entry;
	$center_of_weight += $pulse_table_entry->{'weight'} ;
	#printf STDOUT "split: low: %d  high: %d pulse: %4X   %d/%d\n", $#lower_table, $#higher_table, $pulse_table_entry->{'boundary'}, $center_of_weight, $sum_of_weights/2;
    }
    #in case the loop was never executed
    if ($#lower_table  < 0) {
	$pulse_table_entry = shift @higher_table;
    } else {
	$pulse_table_entry = pop @lower_table;
    }
    #printf STDOUT "low: %d  high: %d\n", $#lower_table, $#higher_table;

    #increment depth of subtrees
    foreach $count_table_entry (@lower_table, @higher_table) {
    	$count_table_entry->{'depth'} += 1;
    }
    #add step to parse time of subtrees
    foreach $count_table_entry (@lower_table) {
    	$count_table_entry->{'parse_time'} += $lower_step_time;
    }
    foreach $count_table_entry (@higher_table) {
    	$count_table_entry->{'parse_time'} += $higher_step_time;
    }

    #No children
    if (($#lower_table  < 0) &&
	($#higher_table < 0)) {
	#adjust parse time
	$pulse_table_entry->{'parse_time'} += $higher_term_time;
	
	$tree_node = {"lower_branch"     => 0,
		      "higher_branch"    => 0,
		      "table_entry"      => $pulse_table_entry,
		      "width"            => 2,
		      "position"         => 0,
		      "lower_connector"  => 0,
		      "higher_connector" => 0};

        #printf STDOUT "node %4X: no children (%d/%d)\n", $pulse_table_entry->{'boundary'}, $tree_node->{'width'}, $tree_node->{'position'};
	return $tree_node;
    }
    #Lower child only
    if ($#higher_table < 0) {
	#build lower branch
	$lower_child_node = build_tree(\@lower_table);
  
	#adjust parse time
	$pulse_table_entry->{'parse_time'} += $higher_term_time;

	$tree_node = {"lower_branch"     => $lower_child_node,
		      "higher_branch"    => 0,
		      "table_entry"      => $pulse_table_entry,
		      "width"            => $lower_child_node->{'width'},
		      "position"         => $lower_child_node->{'position'},
		      "lower_connector"  => $lower_child_node->{'position'},
		      "higher_connector" => $lower_child_node->{'position'}};

        #printf STDOUT "node %4X: lower child %4X (%d/%d)\n", $pulse_table_entry->{'boundary'}, $lower_child_node->{'table_entry'}->{'boundary'}, $tree_node->{'width'}, $tree_node->{'position'};
	return $tree_node;
    }
    #higher child only
    if ($#lower_table < 0) {
	#build higher branch
	$higher_child_node = build_tree(\@higher_table);

	#adjust parse time
	$pulse_table_entry->{'parse_time'} +=  ($higher_step_time + get_lower_term_parse_time($higher_child_node));

	$tree_node = {"lower_branch"     => 0,
		      "higher_branch"    => $higher_child_node,
		      "table_entry"      => $pulse_table_entry,
		      "width"            => $higher_child_node->{'width'},
		      "position"         => $higher_child_node->{'position'},
		      "lower_connector"  => $higher_child_node->{'position'},
		      "higher_connector" => $higher_child_node->{'position'}};

        #printf STDOUT "node %4X: higher child %4X (%d/%d)\n", $pulse_table_entry->{'boundary'}, $higher_child_node->{'table_entry'}->{'boundary'}, $tree_node->{'width'}, $tree_node->{'position'};
	return $tree_node;
    }
    #both childrwn
    #build both branches
    $lower_child_node  = build_tree(\@lower_table);
    $higher_child_node = build_tree(\@higher_table);
    
    #adjust parse time
    $pulse_table_entry->{'parse_time'} +=  ($higher_step_time + get_lower_term_parse_time($higher_child_node));

    $tree_node = {"lower_branch"     => $lower_child_node,
		  "higher_branch"    => $higher_child_node,
		  "table_entry"      => $pulse_table_entry,
		  "width"            => $lower_child_node->{'width'}+$higher_child_node->{'width'},
		  "position"         => $lower_child_node->{'position'}+((($lower_child_node->{'width'}+$higher_child_node->{'position'})-$lower_child_node->{'position'})/2),
		  "lower_connector"  => $lower_child_node->{'position'},
		  "higher_connector" => $lower_child_node->{'width'}+$higher_child_node->{'position'}};
    
    #printf STDOUT "node %4X: lower child %4X, higher child %4X (%d/%d)\n", $pulse_table_entry->{'boundary'},  $lower_child_node->{'table_entry'}->{'boundary'}, $higher_child_node->{'table_entry'}->{'boundary'}, $tree_node->{'width'}, $tree_node->{'position'};
    return $tree_node;
}

sub get_lower_term_parse_time {
    my $tree = shift @_;
    if ($tree->{'lower_branch'}) {
	return ($lower_step_time + get_lower_term_parse_time($tree->{'lower_branch'}));
    } else {
	return $lower_term_time;
    }
}

sub print_tree {
    my $current_tree_level = shift @_;
 
    my @next_tree_level   = ();    
    my @branch_line1;
    my @branch_line2;
    my @branch_line3;
    my @branch_line4;
    my @branch_line5;
    my @branch_label;
    my @level_line1       = ();
    my @level_line2       = ();
    my @level_line3       = ();
    my @level_line4       = ();
    my @level_line5       = ();
    my $next_level_exists = 0,
    my $pulse_table_entry,
    my $tree_node,
    my $dummy_tree_node,
    my $current_line,
    my $output_string,
    my $label;
    my $width;
    my $position;
    my $lower_connector;
    my $higher_connector;
    my $col;

    #clear next level
    $next_tree_level = [];
    #printf STDOUT "new tree level\n";

    #parse current level
    foreach $tree_node (@$current_tree_level) {
	$label             = int($tree_node->{'table_entry'}->{'boundary'});	 
	$width             = int($tree_node->{'width'});			 
	$position          = int($tree_node->{'position'});			 
	$lower_connector   = int($tree_node->{'lower_connector'});		 
	$higher_connector  = int($tree_node->{'higher_connector'});              
	#printf STDOUT "print node %4X: (%d/%d/%d/%d)\n", $label, $width, $position, $lower_connector, $higher_connector;

	#update next level
	if ($tree_node->{'lower_branch'}) {
	    $next_level_exists = 1;
	    push @next_tree_level, $tree_node->{'lower_branch'};
	}
	if ($tree_node->{'higher_branch'}) {
	    $next_level_exists = 1;
	    push @next_tree_level, $tree_node->{'higher_branch'};
	}
	if ((! $tree_node->{'lower_branch'}) &&
	    (! $tree_node->{'higher_branch'})) {
	    $dummy_table_entry = {"lower_branch"     => 0,
				  "higher_branch"    => 0,
				  "table_entry"      => 0,
				  "width"            => $width,
				  "position"         => -1,
				  "lower_connector"  => -1,
				  "higher_connector" => -1};
	    push @next_tree_level, $dummy_table_entry;
	}

	#split branch label
	if (exists $tree_node->{'table_entry'}->{'boundary'}) {
	    @branch_label = reverse split("", sprintf("%X", $label));
	    while ($#branch_label < 4) {
		push @branch_label, "|";
	    }
	} else {
	    @branch_label = ();
	}

	#Print branch
	@branch_line1 = ();
	@branch_line2 = ();
	@branch_line3 = ();
	@branch_line4 = ();
	@branch_line5 = ();
	for ($col=0; $col<$width; $col++) {
	    #printf STDOUT "i=%d (%s)\n", $col, join(",", @branch_label);

	    #fill lines with spaces
	    @branch_line1[$col] = " ";
	    @branch_line2[$col] = " ";
	    @branch_line3[$col] = " ";
	    @branch_line4[$col] = " ";
	    @branch_line5[$col] = " ";
	    #draw connectors
	    if (($lower_connector  >= 0) &&
		($higher_connector >= 0)) {
		if (($lower_connector  < $col) &&
		    ($higher_connector > $col)) {
		    #printf STDOUT "print connector line (%d-%d/%d)\n", $col, $lower_connector, $higher_connector;
		    @branch_line5[$col] = "-";
		}
		if (($lower_connector  == $col) ||
		    ($higher_connector == $col)) {
		    #printf STDOUT "print connector ends (%d/%d)\n", $lower_connector, $higher_connector;
		    @branch_line5[$col] = "+";
		}
	    }
	    #draw label
	    if (($#branch_label == 4) &&
		($position == $col)) {
		    #printf STDOUT "print label (%d)\n", $position;
		@branch_line1[$col] = $branch_label[4];
		@branch_line2[$col] = $branch_label[3];
		@branch_line3[$col] = $branch_label[2];
		@branch_line4[$col] = $branch_label[1];		
		@branch_line5[$col] = $branch_label[0];		
	    }
	}
	#add branch to level
	push @level_line1, @branch_line1;
	push @level_line2, @branch_line2;
	push @level_line3, @branch_line3;
	push @level_line4, @branch_line4;
	push @level_line5, @branch_line5;
    }

    #print current level
    $output_string = "";

    $current_line  = join("", @level_line1);
    $current_line  =~ s/\s+$//g; #remove spaces at the end of the line
    $output_string .= ";#" . $current_line . "\n";
 
    $current_line  = join("", @level_line2);
    $current_line  =~ s/\s+$//g; #remove spaces at the end of the line
    $output_string .= ";#" . $current_line ."\n";
  
    $current_line  = join("", @level_line3);
    $current_line  =~ s/\s+$//g; #remove spaces at the end of the line
    $output_string .= ";#" . $current_line ."\n";
  
    $current_line  = join("", @level_line4);
    $current_line  =~ s/\s+$//g; #remove spaces at the end of the line
    $output_string .= ";#" . $current_line ."\n";
  
    $current_line  = join("", @level_line5);
    $current_line  =~ s/\s+$//g; #remove spaces at the end of the line
    $output_string .= ";#" . $current_line ."\n";

    #print next level
    if ($next_level_exists) {
    	$output_string .= print_tree([@next_tree_level]);
    }
    return $output_string;
}

sub print_space {
    my $file  = shift @_;
    my $count = shift @_;
    #printf STDOUT "print %d spaces to %s\n",$count, $file;
    for (my $i=0; $i<$count; $i++) {
	print $file " ";
    }
}

sub print_table {
    my $bauds_divs     = shift @_;
    my $table          = shift @_;
    my $table_entry;
    my $output_string  = "";
    #print header
    $output_string .= print_table_header([sort {$b <=> $a} keys %$baud_divs]);
    #print table
    foreach $table_entry (@$table) {
	$parse_time = 5 + (5 * $table_entry->{'lower_steps'}) + (5 * $table_entry->{'higher_steps'});
	$output_string .= sprintf   ";# %6d (%4X)      %s (%2X) %6d %6d   %6d\n", $table_entry->{'boundary'},  
	                                                                          $table_entry->{'boundary'},  
                                                                                  $table_entry->{'comment'},
	                                                                          $table_entry->{'mask'},
	                                                                          $table_entry->{'weight'},
 	                                                                          $table_entry->{'depth'},
										  $table_entry->{'parse_time'};
    }
    return $output_string;
}

sub print_table_header {
    my $bauds          = shift @_;
    my @baud_chars;
    my $baud_chars_max = 0;
    my $baud_matrix    = {};
    my $i;
    my $j;
    my $str            = "";

    for ($i=0; $i<=$#$bauds; $i++) {
	@baud_chars = split(//, sprintf("%s", $bauds->[$i]));
	if ($baud_chars_max < $#baud_chars) {$baud_chars_max = $#baud_chars;}
    }

    for ($i=0; $i<=$#$bauds; $i++) {
	@baud_chars = split(//, sprintf("%s", $bauds->[$i]));
	for ($j=0; $j<=$#baud_chars; $j++) {
	    $baud_matrix->{$i}->{$j+($baud_chars_max-$#baud_chars)} = $baud_chars[$j];
	}
    }
    
    foreach $j (0..($baud_chars_max)) {
	if ($j < $baud_chars_max) {
	    $str .= sprintf ";# %-18s ", "";
	} else {
	    $str .= sprintf ";# %-18s ", "pulse length >=";
	}
	foreach $i (0..$#$bauds) {
	    if (exists $baud_matrix->{$i}->{$j}) {
		$str .= $baud_matrix->{$i}->{$j};
		$str .= " ";
	    } else {
		$str .= "  ";
	    }
	}
	if ($j < $baud_chars_max) {
	    $str .= "\n";
	} else {
	    $str .= "      weight  depth  parse time\n";
	}
    }
    
    $str .= ";# ------------------------------------------------------------------\n";
    return $str;
}

sub bin2str {
   my $bin   = shift @_;
   my $width = shift @_;
   my $str   = "";

   foreach my $i (1..$width) {
      if ($bin & 1) {
         $str = "1" . $str;
      } else {
         $str = "0" . $str;
      }
      $bin = $bin >> 1;
   }
   return $str;
}

sub bin2str_x {
   my $bin   = shift @_;
   my $width = shift @_;
   my $str   = "";

   foreach my $i (1..$width) {
      if ($bin & 1) {
         $str = "X" . $str;
      } else {
         $str = "." . $str;
      }
      $bin = $bin >> 1;
   }
   return $str;
}

sub print_asm {
    my $tree           = shift @_;
    my $prev_mask      = shift @_;
    my $label          = $tree->{'table_entry'}->{'boundary'};	 
    my $mask           = $tree->{'table_entry'}->{'mask'};	 
    my $lower_label    = $tree->{'lower_branch'}->{'table_entry'}->{'boundary'};		 
    my $higher_label   = $tree->{'higher_branch'}->{'table_entry'}->{'boundary'};              
    my $lower_branch   = $tree->{'lower_branch'};		 
    my $higher_branch  = $tree->{'higher_branch'};              
    my $output_string  = "";

    #fix label strings
    my $label_name     =  sprintf("N_%4X", $label);
       $label_name     =~ s/\ /_/g;
    my $label_boundary =  sprintf("%4X", $label);
       $label_boundary =~ s/\ /0/g;
       $mask           =  sprintf("%2X", $mask);
       $mask           =~ s/\ /0/g;
    my $lower_name     =  sprintf("N_%4X", $lower_label);
       $lower_name     =~ s/\ /_/g;
    my $higher_name    =  sprintf("N_%4X", $higher_label);
       $higher_name    =~ s/\ /_/g;
    #printf STDOUT "print asm %s %s %s: (%s/%s)\n", $label_name, $label_boundary, $mask, $lower_label, $higher_label;

    #two children
    if (($lower_branch) &&
	($higher_branch)) {
	#print node entry
	$output_string .= sprintf("%s\t\tDW\t\$%s\t\$%s%s\t%s\t\t;if pulse >= %d then check %s else check %s\n", $label_name, 
				                                                                                 $label_boundary, 
                                                                                                                 $mask, $mask, 
                                                                                                                 $higher_name,
                                                                                                                 $label,
                                                                                                                 $higher_name,
                                                                                                                 $lower_name);
	#print lower branch
	#printf STDOUT "print asm lower %s\n", $lower_label;
	$output_string .= print_asm($lower_branch, $prev_mask);
	#print higher branch
   	#printf STDOUT "print asm higher %s\n", $higher_label;
   	$output_string .= print_asm($higher_branch, $mask);
	return $output_string;
    }

    #only lower child
    if ($lower_branch) {
	#print node entry
	$output_string .= sprintf("%s\t\tDW\t\$%s\t\$%s%s\t\$0000\t\t;if pulse >= %d then the result is %s else check %s\n", $label_name, 
				                                                                                             $label_boundary, 
                                                                                                                             $mask, $mask, 
                                                                                                                             $label,
                                                                                                                             $mask,
                                                                                                                             $lower_name);
	#print lower branch
	#printf STDOUT "print asm lower %s\n", $lower_label;
	$output_string .= print_asm($lower_branch, $prev_mask);
	return $output_string;
    }

    #only higher child
    if ($higher_branch) {
	#print node entry
	$output_string .= sprintf("%s\t\tDW\t\$%s\t\$%s%s\t%s\t\t;if pulse >= %d then check %s else the result is %s\n", $label_name, 
				                                                                                         $label_boundary, 
                                                                                                                         $mask, $mask, 
                                                                                                                         $higher_name,
                                                                                                                         $label,
                                                                                                                         $higher_name,
                                                                                                                         $prev_mask);
	#print lower branch
	$output_string .= sprintf("\t\tDW\t\$0000\n");
	#print higher branch
   	#printf STDOUT "print asm higher %s\n", $higher_label;
   	$output_string .= print_asm($higher_branch, $mask);
	return $output_string;
    }

    #no children
    #print node entry
    $output_string .= sprintf("%s\t\tDW\t\$%s\t\$%s%s\t\$0000\t\t;if pulse >= %d then the result is %s else the result is %s %s\n", $label_name, 
				                                                                                                    $label_boundary, 
                                                                                                                                    $mask, $mask, 
                                                                                                                                    $label,
                                                                                                                                    $mask,
                                                                                                                                    $prev_mask);
    #print lower branch
    $output_string .= sprintf("\t\tDW\t\$0000\n");
    return $output_string;
}
