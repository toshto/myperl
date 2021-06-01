#! /usr/bin/perl

use strict;
my %line;

if ( -f $ARGV[0] && -f $ARGV[1]){
    die "usage: whichbe.pl <file1> <file2>¥n";
}

foreach my $n (0..1){
    open(IN, $ARGV[$n]) or die "can't open file.";
    while(<IN>){
        chomp;
        if ($n == 0 ){
            $line{$_} += 10;
        } else {
            $line{$_}++;
        }
    }
    close(IN);
}

foreach my $line (keys %line){
    if ( $line{$line} == 10 ){
        print "<: $line\n";
    } elsif ( $line{$line} == 1 ){
        print ">: $line\n";
    } else {
        print "|: $line{$line}: $line\n";
    }
}

exit 0;
exit 0;
