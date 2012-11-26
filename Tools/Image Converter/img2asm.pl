#!/usr/bin/env perl
###############################################################################
# AriCalculator - Image Converter                                             #
###############################################################################
#    Copyright 2012 Dirk Heisswolf                                            #
#    This file is part of the AriCalculator framework for Freescale's S12(X)  #
#    MCU families.                                                            #
#                                                                             #
#    AriCalculator is free software: you can redistribute it and/or modify    #
#    it under the terms of the GNU General Public License as published by     #
#    the Free Software Foundation, either version 3 of the License, or        #
#    (at your option) any later version.                                      #
#                                                                             #
#    AriCalculator is distributed in the hope that it will be useful,         #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
#    GNU General Public License for more details.                             #
#                                                                             #
#    You should have received a copy of the GNU General Public License        #
#    along with AriCalculator.  If not, see <http://www.gnu.org/licenses/>.   #
###############################################################################
# Description:                                                                #
#    This perl script converts a 128x64 8-bit grascale raw image into a       #
#    stream for a ST7565R display controller. The palette of the image must   #
#    be sorted from dark to light                                             #
###############################################################################
# Version History:                                                            #
#    25 April, 2009                                                           #
#      - Initial release                                                      #
#     7 August, 2012                                                          #
#      - Added script to AriCalculator tools                                  #
###############################################################################

#################
# Perl settings #
#################
use 5.005;
#use warnings;
use IO::File;

#############
# constants #
#############

###############
# global vars #
###############
$src_file          = "";
$src_handle        =  0;
@src_buffer        = ();
$pixel             =  0;
$color             =  0;
$color_depth       =  0;
@split_buffer      = ();
$column_group      =  0;
$column            =  0;
$page              =  0;
@paged_buffer      = ();
@out_buffer        = ();
$out_file          = "";
$out_handle        =  0;
$repeat_count      =  0;
$current_data      = undef;
$next_data         = undef;

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year += 1900;
@months = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec");
@days   = ("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat");

###################
# print help text #
###################
if ($#ARGV < 0) {
    printf "usage: %s <raw image file>\n", $0;
    print  "\n";
    exit;
}

##################
# read file name #
##################
$src_file = $ARGV[0];
printf STDOUT ("Processing image file \"%s\"\n", $src_file);

###################
# open image file #
###################
#check if file exists
if (! -e $src_file) {
    printf STDOUT ("    ERROR! File \"%s\" does not exist\n", $src_file);
    exit;
} 
#check if file is readable
if (! -r $src_file) {
    printf STDOUT "    ERROR! File \"%s\" is not readable\n", $src_file;
    exit;
}
#check if file can be opened
if ($src_handle = IO::File->new($src_file, O_RDONLY)) {
} else {
    printf STDOUT "    ERROR! Unable to open file \"%s\" (%s)\n", $src_file, $!;
    exit;
}

#read file
$src_handle->seek(0, SEEK_SET);      #reset file handle pointer
$color_depth = 0;
while ($src_handle->read($pixel, 1)) {
    $pixel = unpack("C", $pixel);
    if ($pixel > $color_depth) {
	$color_depth = $pixel
    }
    push @src_buffer, $pixel;
}
$src_handle->close();                           #close file handle

#check image format
    if ($#src_buffer != (128*64)-1) {
    printf STDOUT "    ERROR! Wrong image format (%d pixels)\n", $#src_buffer+1;
    exit;
}
#printf STDOUT "Color depth: %d\n", $color_depth;

######################
# convert image file #
######################
#split source buffer into gray shades
@split_buffer = ();
foreach $color (0..$color_depth-1) {
    #foreach $pixel (@src_buffer) {       #not flipped
    foreach $pixel (reverse(@src_buffer)) { #flipped
	if ($pixel <= $color) {
	    push @split_buffer, 0xFF;
	} else {
	    push @split_buffer, 0x00;
	}
	#printf STDOUT "Color: %4d Index: %6d Pixel: %4d => %.2X\n", $color, $#split_buffer, $pixel, $split_buffer[$#split_buffer]; 
    }
}
#printf STDOUT "Splitted image: %d\n", $#split_buffer+1;

#arrange split buffer into pages
@paged_buffer = ();
foreach $page (0..(($#split_buffer+1)/(128*8))-1) {
    foreach $column (0..127) {
	#printf STDOUT "Page: %4d Column: %4d %2X %2X %2X %2X %2X %2X %2X %2X\n", $page, $column, 
	#($split_buffer[($page*(128*8))+$column+(128*0)]),
	#($split_buffer[($page*(128*8))+$column+(128*1)]),
	#($split_buffer[($page*(128*8))+$column+(128*2)]),
	#($split_buffer[($page*(128*8))+$column+(128*3)]),
	#($split_buffer[($page*(128*8))+$column+(128*4)]),
	#($split_buffer[($page*(128*8))+$column+(128*5)]),
	#($split_buffer[($page*(128*8))+$column+(128*6)]),
	#($split_buffer[($page*(128*8))+$column+(128*7)]);
	 push @paged_buffer, (($split_buffer[($page*(128*8))+$column+(128*0)]& 0x01) |
			      ($split_buffer[($page*(128*8))+$column+(128*1)]& 0x02) |
			      ($split_buffer[($page*(128*8))+$column+(128*2)]& 0x04) |
			      ($split_buffer[($page*(128*8))+$column+(128*3)]& 0x08) |
			      ($split_buffer[($page*(128*8))+$column+(128*4)]& 0x10) |
			      ($split_buffer[($page*(128*8))+$column+(128*5)]& 0x20) |
			      ($split_buffer[($page*(128*8))+$column+(128*6)]& 0x40) |
			      ($split_buffer[($page*(128*8))+$column+(128*7)]& 0x80));
    }
}
#printf STDOUT "Paged image: %d\n", $#paged_buffer+1;

##################
# write ASM file #
##################
#determine output file name
if ($src_file =~ /^(.+)\.raw$/i) {
    $out_file = sprintf("%s.s", $1);
} else {
    $out_file = sprintf("%s.s", $src_file);
}

#open output file
if ($out_handle = IO::File->new($out_file,  O_CREAT|O_WRONLY)) {
    $out_handle->truncate(0);
} else {
    printf STDOUT "    ERROR! Unable to open file \"%s\" (%s)\n", $out_file, $!;
    exit;
}

#print header
printf $out_handle ";###############################################################################\n"; 
printf $out_handle ";# AriCalculator - Image: %-50s        #\n", sprintf("%s (%d frames)", $src_file, $color_depth);
printf $out_handle ";###############################################################################\n";
printf $out_handle ";#    Copyright 2012 Dirk Heisswolf                                            #\n";
printf $out_handle ";#    This file is part of the AriCalculator framework for Freescale's S12(X)  #\n";
printf $out_handle ";#    MCU families.                                                            #\n";
printf $out_handle ";#                                                                             #\n";
printf $out_handle ";#    AriCalculator is free software: you can redistribute it and/or modify    #\n";
printf $out_handle ";#    it under the terms of the GNU General Public License as published by     #\n";
printf $out_handle ";#    the Free Software Foundation, either version 3 of the License, or        #\n";
printf $out_handle ";#    (at your option) any later version.                                      #\n";
printf $out_handle ";#                                                                             #\n";
printf $out_handle ";#    AriCalculator is distributed in the hope that it will be useful,         #\n";
printf $out_handle ";#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #\n";
printf $out_handle ";#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #\n";
printf $out_handle ";#    GNU General Public License for more details.                             #\n";
printf $out_handle ";#                                                                             #\n";
printf $out_handle ";#    You should have received a copy of the GNU General Public License        #\n";
printf $out_handle ";#    along with AriCalculator.  If not, see <http://www.gnu.org/licenses/>.   #\n";
printf $out_handle ";###############################################################################\n";
printf $out_handle ";# Description:                                                                #\n";
printf $out_handle ";#    This file contains the two macros:                                       #\n";
printf $out_handle ";#       IMG_TAB:                                                              #\n";
printf $out_handle ";#           This macro allocates a table of raw image data.                   #\n";
printf $out_handle ";#                                                                             #\n";
printf $out_handle ";#       IMG_STREAM:                                                           #\n";
printf $out_handle ";#           This macro allocates a compressed stream of image data and        #\n";
printf $out_handle ";#           control commands, which can be directly driven to the display     #\n";
printf $out_handle ";#           driver.                                                           #\n";
printf $out_handle ";###############################################################################\n";
printf $out_handle ";# Generated on %3s, %3s %.2d %4d                                               #\n", $days[$wday], $months[$mon], $mday, $year;
printf $out_handle ";###############################################################################\n";
printf $out_handle "\n";

#write data table 
@out_buffer = @paged_buffer;

printf $out_handle "#macro IMG_TAB, 0\n";
printf $out_handle "\n";

foreach $color (0..$color_depth-1) {
    printf $out_handle ";#Frame %d:\n", $color;
    printf $out_handle ";#----------------------------------------------------------------------\n";

    foreach $page (0..7) {
	printf $out_handle ";#Page %d:\n", $page;
	foreach $column_group (0..15) {
	    printf $out_handle "\t\tDB";
	    foreach $column (0..7) {
		printf $out_handle "  \$%.2X", shift @out_buffer;
	    }  
	    printf $out_handle "\n";
	}    
    }
    printf $out_handle "\n";
}
printf $out_handle "#emac\n";
printf $out_handle "\n";

#write command stream 
@out_buffer = @paged_buffer;
#printf STDOUT "Out Buffer: %4d\n", $#out_buffer; 

printf $out_handle "#macro IMG_STREAM, 0\n";
printf $out_handle "\n";

foreach $color (0..$color_depth-1) {
    printf $out_handle ";#Frame %d:\n", $color;
    printf $out_handle ";#----------------------------------------------------------------------\n";

    foreach $page (0..7) {
	printf $out_handle ";#Page %d:\n", $page;
	printf $out_handle "\t\tDW  \$00B%.1X \$0010 \$0004 ;set page and column address", ($page & 0xF);
	$column_group = -1;
	$repeat_count = 0;
	$current_data = shift @out_buffer;	
	printf $out_handle "\n\t\tDW ";
	foreach $column (0..126) {
	    $next_data = shift @out_buffer;
	    if ($current_data == $next_data) {
		$repeat_count++;
	    } else {
		if (++$column_group >= 8) {
		    $column_group = 0;
		    printf $out_handle "\n\t\tDW ";
		}
		printf $out_handle " \$%.2X%.2X", ($repeat_count<<1)|1, $current_data;
		$repeat_count = 0;
		$current_data = $next_data;
	    }
	}
	
	if (++$column_group >= 8) {
	    $column_group = 0;
	    printf $out_handle "\n\t\tDW ";
	}
	printf $out_handle " \$%.2X%.2X", ($repeat_count<<1)|1, $current_data;
	printf $out_handle "\n";
    }
    printf $out_handle "\n";
}
printf $out_handle "#emac\n";
printf $out_handle "\n";

#close file
$out_handle->close();

1;
