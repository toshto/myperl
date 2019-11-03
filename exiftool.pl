#! /usr/bin/perl

use strict;
use Image::ExifTool;

my $path = $ARGV[0] || die "usage: exiftool.pl <filename or dirname>\n";
my $exifTool = new Image::ExifTool;

open(FIND, "find $path -type f | ") or die "ERROR: find commad failure.\n";
while(<FIND>){
    chomp;
    my $filepath = $_;
    my $info = $exifTool->ImageInfo($filepath);
    show($info);
    #copy($info);
}
close(FIND);

sub show {
    my @args = @_;
    my $ret;
    foreach my $key (sort keys %{$args[0]}) {
         $ret = "$key => $args[0]->{$key}\n";
    }
    retern $ret;
}

sub copy {
    my @args = @_;
    my $new_path;
    # CreateDate => 2005:01:29 10:17:28
    if ( $args[0]->{'CreateDate'} =~ /(\d{4}):(\d{2}):(\d{2}) (\d{2}):(\d{2}):(\d{2})/
         || $args[0]->{'FileModifyDate'} =~ /(\d{4}):(\d{2}):(\d{2}) (\d{2}):(\d{2}):(\d{2})/
    ){
        my ($yyyy, $mm, $dd, $HH, $MM, $SS) = ($1, $2, $3, $4, $5, $6);
        if ( -f "/Users/tosh/Pictures/${yyyy}/${yyyy}-${mm}-${dd}/$args[0]->{'FileName'}" ){
            # there !
        } elsif ( -f "/Users/tosh/Pictures/album/${yyyy}-${mm}/$args[0]->{'FileName'}" ){
            # there !
        } else {
            if (/06_album/){
                $new_path = "/Users/tosh/Pictures/album/${yyyy}-${mm}";
            } elsif (/scan/){
                $new_path = "/Users/tosh/Pictures/scan/${yyyy}/${yyyy}-${mm}-${dd}";
            } else {
                $new_path = "/Users/tosh/Pictures/${yyyy}/${yyyy}-${mm}-${dd}";
            }

            print `mkdir -p $new_path`;
            if ($? == 0 ){
                print `cp -p $args[0]->{'Directory'}/$args[0]->{'FileName'} $new_path/$args[0]->{'FileName'}`;
                if ( $? != 0 ){
                    print "ERROR: can not copy $args[0]->{'Directory'}/$args[0]->{'FileName'} to $new_path/$args[0]->{'FileName'}\n";
                } else{
                    print "OK: copied $args[0]->{'Directory'}/$args[0]->{'FileName'} to $new_path/$args[0]->{'FileName'}\n";
                }
            }
        }
    } else {
      print "No Date: $args[0]->{'Directory'}/$args[0]->{'FileName'}\n";
    }
    return 0;
}