#!/usr/bin/perl
use strict;
use warnings;

my $self = basename($0);
my $ARGC = scalar(@ARGV);

if (($ARGV[0] =~ /-h/) || ($ARGC < 1)) {
   help();
}

# Arg parsing
foreach (@ARGV) {

}

sub help {
print<<EOF;
Summary

Usage: 
   $self [options] 

   Available options:
         -h          - Show this help

EOF
exit;
}
