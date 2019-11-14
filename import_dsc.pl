#! /usr/bin/perl

use strict;
use File::Copy;
use File::Path;

my ($basedir, $local) = @ARGV;
unless (-d $basedir && -d $local ){
    die "usage: import_dsc.pl <sd card path> <copy destination>\n";
}

if ( opendir(DIR, $basedir) ){
    my @file = readdir(DIR);
    foreach my $file (@file){
        if ( -f "$basedir/$file" ){

            # dev, ino, mode, nlink, uid, gid, rdev, size, atime, mtime, ctime, blksize, blocks
            #                                                     ~~~~~[9]
            my @stats = stat("$basedir/$file");

            my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime("$stats[9]"); $year+=1900; $mon++;
            my $subdir = sprintf("%04d/%04d-%02d-%02d",$year,$year,$mon,$mday);

            my $dirpath = "$local/$subdir";
            if ( ! -d $dirpath ){
	            eval {
                    mkpath("$dirpath");
                };
            }
            if ( ! -f "$dirpath/$file" ){
                copy("$basedir/$file", "$dirpath/") or die "ERROR: $!";
                print STDERR "Copied $dirpath/$file\n";
            } else {
                print STDERR "Don't copy cause already exist $dirpath/$file \n";
            }
        }
    }
} else {
    print STDERR "No mounted memory card.\n";
    exit 1;
}
