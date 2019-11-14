#! /usr/bin/perl

use strict;
use Image::ExifTool;
use FindBin;

my $basedir = $FindBin::Bin;

my $path  = $ARGV[0] || die "usage: exiftool.pl <filename or dirname> [comma separate columns]\n";
my $label = $ARGV[1];

my $exifTool = new Image::ExifTool;

open(FIND, "find $path -type f | ") or die "ERROR: find commad failure.\n";
while(<FIND>){
    chomp;
    my $filepath = $_;
    my $info = $exifTool->ImageInfo($filepath);
    show($info, $label);
}
close(FIND);


### sub routines

sub show {
    my @args = @_;
    if ( $args[1] ne "" ) {
    	# comma separate columns
        my @ret;
        my @col = split(/,/, $args[1]);
        foreach my $col (@col){
            push(@ret, $args[0]->{$col});
        }
        print join("\t", @ret) . "\n";

    } else {
    	# all values
        my %ret;
        foreach my $key (sort keys %{$args[0]}) {
            print "$key => $args[0]->{$key}\n";
        }
        print "\n";
    }
    return 1;
}