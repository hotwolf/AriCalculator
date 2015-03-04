#!/usr/bin/env perl
###############################################################################
# S12CForth - Forth to ASM Compiler                                           #
###############################################################################
#    Copyright 2015 Dirk Heisswolf                                            #
#    This file is part of the S12CForth framework for Freescale's S12C MCU    #
#    family.                                                                  #
#                                                                             #
#    S12CForth is free software: you can redistribute it and/or modify        #
#    it under the terms of the GNU General Public License as published by     #
#    the Free Software Foundation, either version 3 of the License, or        #
#    (at your option) any later version.                                      #
#                                                                             #
#    S12CForth is distributed in the hope that it will be useful,             #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
#    GNU General Public License for more details.                             #
#                                                                             #
#    You should have received a copy of the GNU General Public License        #
#    along with S12CForth.  If not, see <http://www.gnu.org/licenses/>.       #
###############################################################################
# Description:                                                                #
#    This perl script generates the assembler source of a search tree (incl.  #
#    parser) for the S12CForth CORE NFAs.                                     #
###############################################################################
# Version History:                                                            #
#   19 Februuary, 2015                                                        #
#      - Initial release                                                      #
###############################################################################

#################
# Perl settings #
#################
#use warnings;
#use strict;

####################
# create namespace #
####################
package forth2asm;

###########
# modules #
###########
use IO::File;
use Fcntl;
use Text::Tabs;
use File::Basename;







###############
# constructor #
###############
sub new {
    my $proto            = shift @_;
    my $class            = ref($proto) || $proto;
    
    my $asm_code         = shift @_;
    my $library_list     = shift @_;
    my $defines          = shift @_;
    my $cpu              = shift @_;
    my $verbose          = shift @_;
    my $symbols          = shift @_;
    my $self             = {};


















#################
# Perl settings #
#################
use 5.005;
#use warnings;
use File::Basename;
use FindBin qw($RealBin);
use lib $RealBin;
use Data::Dumper;
use lib "$RealBin/../HSW12/Perl";
require hsw12_asm;

###############
# global vars #
###############
@asm_files         = ();
@lib_files         = ();
%defines           = ();
@forth_files       = ();
$asm_output_path   = ();
$asm_prog_name     = "";
$forth_output_path = ();
$forth_prog_name   = "";
$arg_type          = "none;
$srec_format       = $hsw12_asm::srec_def_format;
$srec_data_length  = $hsw12_asm::srec_def_data_length;
$srec_add_s5       = $hsw12_asm::srec_def_add_s5;
$srec_word_entries = 1;
$command_file_name = "";
$symbols           = {};
$code              = {};
$comp_symbols      = {};
$pag_addrspace     = {};

%compile_words     = ();
%immediate_words   = ();

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year += 1900;
@months = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec");
@days   = ("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat");

##########################
# read command line args #
##########################
#printf "parsing args: count: %s\r\n", $#ARGV + 1;
foreach $arg (@ARGV) {
    #printf "  arg: %s\r\n", $arg;
    if ($arg =~ /^\s*\-L\s*$/i) {
	$arg_type = "lib";
    } elsif ($arg =~ /^\s*\-D\s*$/i) {
	$arg_type = "def";
    } elsif ($arg =~ /^\s*\-A\s*$/i) {
	$arg_type = "asm";
    } elsif ($arg =~ /^\s*\-F\s*$/i) {
	$arg_type = "forth";
    } elsif ($arg =~ /^\s*\-/) {
	#ignore
    } elsif ($arg_type eq "asm") {
	#ASM file
	push @asm_files, $arg;
    } elsif ($arg_type eq "forth") {
	#Forth file
	push @forth_files, $arg;
    } elsif ($arg_type eq "lib") {
	#library path
	if ($arg !~ /\/$/) {$arg = sprintf("%s/", $arg);}
	unshift @lib_files, $arg;
    } elsif ($arg_type eq "def") {
	#precompiler define
	if ($arg =~ /^\s*(\w+)=(\w+)\s*$/) {
	    $defines{uc($1)} = $2;
	} elsif ($arg =~ /^\s*(\w+)\s*$/) {
	    $defines{uc($1)} = "";
	}
    }
}

###################
# print help text #
###################
if ($#asm_files < 0) {
    printf "usage: %s [-L <library path>] [-D <define: name=value or name>] -A <ASM files> -F <Forth files> \r\n", $0;
    print  "\r\n";
    exit;
}

###################
# add default lib #
###################
#printf "libraries:   %s (%s)\r\n",join("\", \"", @lib_files), $#lib_files;
#printf "asm files:   %s (%s)\r\n",join("\", \"", @asm_files), $#asm_files;
#printf "forth files: %s (%s)\r\n",join("\", \"", @forth_files), $#forth_files;
if ($#lib_files < 0) {
  foreach my $asm_file (@asm_files) {
    #printf "add library:%s/\r\n", dirname($asm_file);
    push @lib_files, sprintf("%s/", dirname($asm_file));
  }
  foreach my $forth_file (@forth_files) {
    #printf "add library:%s/\r\n", dirname($forth_file);
    push @lib_files, sprintf("%s/", dirname($forth_file));
  }
}

#######################################
# determine program name and location #
#######################################
$asm_prog_name     = basename($asm_files[0], ".s");
$asm_output_path   = dirname($asm_files[0],  ".s");
$forth_prog_name   = basename($asm_files[0], ".4th");
$forth_output_path = dirname($asm_files[0],  ".4th");

####################
# load symbol file #
####################
$symbol_file_name = sprintf("%s/%s.sym", $asm_output_path, $asm_prog_name);
printf STDERR "Loading: %s\n",  $symbol_file_name;
if (open (FILEHANDLE, sprintf("<%s", $symbol_file_name))) {
    $data = join "", <FILEHANDLE>;
    eval $data;
    close FILEHANDLE;
}
#printf STDERR $data;
#printf STDERR "Importing %s\n",  join(",\n", keys %{$symbols});
#exit;

#######################
# compile source code #
#######################
#printf STDERR "asm files: \"%s\"\r\n", join("\", \"", @asm_files);  
#printf STDERR "lib files: \"%s\"\r\n", join("\", \"", @lib_files);  
#printf STDERR "defines:   \"%s\"\r\n", join("\", \"", @defines);  
$code = hsw12_asm->new(\@asm_files, \@lib_files, \%defines, "S12", 1, $symbols);

###################
# write list file #
###################
$list_file_name = sprintf("%s/%s.lst", $asm_output_path, $asm_prog_name);
if (open (FILEHANDLE, sprintf("+>%s", $list_file_name))) {
    $out_string = $code->print_listing();
    print FILEHANDLE $out_string;
    #print STDOUT     $out_string;
    #printf "output: %s\n", $list_file_name;
    close FILEHANDLE;
} else {
    printf STDERR "Can't open list file \"%s\"\n", $list_file_name;
    exit;
}

#####################
# check code status #
#####################
if ($code->{problems}) {
    printf STDERR "Problem summary: %s\r\n", $code->{problems};
} else {
    #####################################
    # read symbol table and address map #
    #####################################
    $comp_symbols  = $code->{comp_symbols};
    $pag_addrspace = $code->{pag_addrspace};
    
    #####################
    # write symbol file #
    #####################
    #$symbol_file_name = sprintf("%s/%s.sym", $asm_output_path, $asm_prog_name);
    if (open (FILEHANDLE, sprintf("+>%s", $symbol_file_name))) {
	$dump = Data::Dumper->new([$code->{comp_symbols}], ['symbols']);
	$dump->Indent(2);
	print FILEHANDLE $dump->Dump;
 	close FILEHANDLE;
    } else {
	printf STDERR "Can't open symbol file \"%s\"\n", $symbol_file_name;
	exit;
    }

    #printf STDERR "Loaded...(%s)\n", $#{$code->{code}};
    #######################
    # parse code for CFAs #
    #######################
    foreach $code_entry (@{$code->{code}}) {	
	$code_comments = $code_entry->[2];
	$code_label    = $code_entry->[3];
	$code_opcode   = $code_entry->[4];
	$code_args     = $code_entry->[5];
	$code_pc_lin   = $code_entry->[6];
	$code_pc_pag   = $code_entry->[7];
	$code_hex      = $code_entry->[8];
	$code_byte_cnt = $code_entry->[9];
	$code_macros   = $code_entry->[11];
	$code_sym_tabs = $code_entry->[12];
	
	#printf STDERR "Label: \"%s\"\n", $code_label;
	#Word must begin with "CFA_" label
	if ($code_label =~ /^CFA_/) {		
	    #printf STDERR "CFA found: \"%s\"\n", $code_label;
	    
	    #Word must contain the comment line: ;Word: <name> ... IMMEDIATE"
	    my $name_string  = "";
	    my $name_found   = 0;
	    my $is_immediate = 0;
	    foreach my $code_comment (@{$code_comments}) {
		#printf STDERR "Comment: \"%s\"\n", $code_comment;
		if ($code_comment =~ /^;Word:\s+(\S+)/) {
		    $name_found   = 1;
		    $name_string  =  uc($1);
		    #$name_string =  $1;     //case sensitive naming
		    if ($code_comment =~ /^;Word:\s+\S+\s+.*IMMEDIATE\s*$/) {
			$is_immediate = 1;
		    } else {
			$is_immediate = 0;
		    }
		    last;
		}
	    }	    
	    if ($name_found) {
		#printf STDERR "      \"%s\" %s\n", $name_string, $is_immediate ? "-> IMMEDIATE" : "";;
		
		if ($is_immediate) {
		    $immediate_words{$name_string} = $code_label;
		} else {
		    $compile_words{$name_string) = $code_label;
		}
	    }
	}
    }

    #####################
    # parse forth files #
    #####################
    foreach my $forth_file (@forth_files) {
	my $file_name;
        ############################
        # determine full file name #
        ############################
        #printf "forth_file: %s\n", $forth_file;
        if ($forth_file =~ /$path_absolute/) {
           #asolute path
	   #printf STDERR "absolute path: %s\n", $file_name;
            $file_name = $forth_file;
	} else {
	    #relative path
	    foreach my $library_path (@$library_list) {
		$file_name = sprintf("%s%s", $library_path, $forth_file);
		#printf STDERR "relative path: %s\n", $file_name;
		if (-e $file_name) {
		    last;
		} else {
		    $file_name = $forth_file;
		}
	    }	    
	    #printf STDERR "relative path: %s\n", $file_name;
	}

        ###################
        # open forth file #
        ###################
	if (-e $file_name) {
	    if (-r $file_name) {
		if (open (FILEHANDLE, sprintf("<%s", $file_name))) {




























    condense_tree(\%dict_tree);

    ##########################################
    # find zero-length terminated substrings #
    ##########################################
    #find_zero_term(\%dict_tree);

    #########################
    # write NFA search tree #
    #########################
    $dict_tree_file_name = sprintf("%s/fcdict_tree.s", $output_path);

    if (open (FILEHANDLE, sprintf(">%s", $dict_tree_file_name))) {

	#Print header
	#------------ 
        printf FILEHANDLE ";###############################################################################\n"; 
        printf FILEHANDLE ";# S12CForth - Search Tree for the Core Dictionary                             #\n";
        printf FILEHANDLE ";###############################################################################\n";
        printf FILEHANDLE ";#    Copyright 2009-2013 Dirk Heisswolf                                       #\n";
        printf FILEHANDLE ";#    This file is part of the S12CForth framework for Freescale's S12(X) MCU  #\n";
        printf FILEHANDLE ";#    families.                                                                #\n";
        printf FILEHANDLE ";#                                                                             #\n";
        printf FILEHANDLE ";#    S12CForth is free software: you can redistribute it and/or modify        #\n";
        printf FILEHANDLE ";#    it under the terms of the GNU General Public License as published by     #\n";
        printf FILEHANDLE ";#    the Free Software Foundation, either version 3 of the License, or        #\n";
        printf FILEHANDLE ";#    (at your option) any later version.                                      #\n";
        printf FILEHANDLE ";#                                                                             #\n";
        printf FILEHANDLE ";#    S12CForth is distributed in the hope that it will be useful,             #\n";
        printf FILEHANDLE ";#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #\n";
        printf FILEHANDLE ";#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #\n";
        printf FILEHANDLE ";#    GNU General Public License for more details.                             #\n";
        printf FILEHANDLE ";#                                                                             #\n";
        printf FILEHANDLE ";#    You should have received a copy of the GNU General Public License        #\n";
        printf FILEHANDLE ";#    along with S12CForth.  If not, see <http://www.gnu.org/licenses/>.       #\n";
        printf FILEHANDLE ";###############################################################################\n";
        printf FILEHANDLE ";# Description:                                                                #\n";
        printf FILEHANDLE ";#    This file contains a search tree for the NFAs of the S12CForth CORE      #\n";
        printf FILEHANDLE ";#    words.                                                                   #\n";
        printf FILEHANDLE ";#                                                                             #\n";
        printf FILEHANDLE ";###############################################################################\n";
        printf FILEHANDLE ";# Generated on %3s, %3s %.2d %4d                                               #\n", $days[$wday], $months[$mon], $mday, $year;
        printf FILEHANDLE ";###############################################################################\n";

	#Print tree layout
	$tree_layout_width = get_tree_layout_width(\%dict_tree);
        printf FILEHANDLE "\n";
        printf FILEHANDLE ";###############################################################################\n";
        printf FILEHANDLE ";# Dictionary Tree Structure                                                   #\n";
        printf FILEHANDLE ";###############################################################################\n";
        printf FILEHANDLE ";\n";
        printf FILEHANDLE "; -> ";
	print_tree_layout(\%dict_tree, ";    ");

	#Macro label
        printf FILEHANDLE "\n";
        printf FILEHANDLE ";###############################################################################\n";
        printf FILEHANDLE ";# Macros                                                                      #\n";
        printf FILEHANDLE ";###############################################################################\n";
        printf FILEHANDLE "\n";

	#Print tree
        printf FILEHANDLE "#ifndef FCDICT_TREE_EXTSTS\n";
        printf FILEHANDLE "FCDICT_TREE_EXISTS      EQU     1\n";
	printf FILEHANDLE "\n";
        printf FILEHANDLE ";Global constants\n";
        printf FILEHANDLE "FCDICT_TREE_DEPTH       EQU     %d\n", get_tree_depth(\%dict_tree);
 	printf FILEHANDLE "\n";
        printf FILEHANDLE ";Dictionary tree\n";
        printf FILEHANDLE "#macro       FCDICT_TREE, 0\n";
        printf FILEHANDLE ";Local constants\n";
        #printf FILEHANDLE "STRING_TERMINATION      EQU     \$00\n";
        printf FILEHANDLE "EMPTY_STRING            EQU     \$00\n";
        printf FILEHANDLE "BRANCH                  EQU     \$00\n";
        printf FILEHANDLE "END_OF_BRANCH           EQU     \$00\n";
        printf FILEHANDLE "IMMEDIATE               EQU     \$8000\n";
        #printf FILEHANDLE "\n";
	print_tree(\%dict_tree, "", []);
        printf FILEHANDLE "#emac\n";
        printf FILEHANDLE "#endif\n";
 
	close FILEHANDLE;
    } else {
	printf STDERR "Can't open output file \"%s\"\r\n", $nfa_tree_file_name;
	exit;
    }
}
















		

1;
