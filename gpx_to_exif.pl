#! /usr/bin/perl

use strict;
use XML::Simple;
use Time::Local;
use Image::ExifTool;

my ($imgdir, $gpxfile) = @ARGV;
unless ( -d $imgdir && -f $gpxfile){
    die "usage: gpx_to_exif.pl <image directory> <pgx.xml file>";
}
my $exifTool = new Image::ExifTool;

### GPS情報ファイルのセット
my $xml = XML::Simple->new;
my $data = $xml->XMLin("$gpxfile") or die "$gpxfile\n";

opendir(DIR,"$imgdir") or dir $!;
my @files = readdir(DIR);

foreach my $file (@files){

    ### 拡張子チェック
    unless ( -f "$imgdir/$file" && $file =~ /\.jpg$/i ){ next; }

    ### 画像ファイルをセットして撮影日時(UnixTime)を取得
    $exifTool->ExtractInfo("$imgdir/$file") or die "$imgdir/$file\n";
    my @orig = split(/[:\s]/, $exifTool->GetValue('DateTimeOriginal'));
    if (@orig < 6 ){ next; }
    my $orig_ux = ux(@orig);

    my $mindef = 120;        # 最大誤差
    my $chkdef = $mindef;
    my @nearst;              # 最少誤差の時の座標をセット

    ### データはARRAYに統一してあつかう。
    my @trkseg;
    my $type = ref $data->{trk}->{trkseg};
    if ($type =~ /HASH/ ){
        push(@trkseg, $data->{trk}->{trkseg});
    } elsif ( $type =~ /ARRAY/){
        @trkseg = @{$data->{trk}->{trkseg}};
    }

    foreach my $trkseg (@trkseg){
        foreach my $trkpt (@{$trkseg->{trkpt}}){

            # GPX Format
            # time                        lat           lon            ele
            # 2017-10-29T23:12:41.950Z    35.5650714    139.5673554

            $trkpt->{time} =~ /(\d{4})-(\d+)-(\d+)T(\d{2}):(\d{2}):(\d{2})\.(\d{3})Z/;
            my $ux = ux_p9($1, $2, $3, $4, $5, $6);    # gpxの日時がUTCなので9hずらしてunixtime取得

            my $def = abs($ux - $orig_ux); # 誤差の絶対値

            if ( $def < $chkdef ){
                # 撮影日時とGPS日時の誤差最少となる座標を記録する。
                $chkdef = $def;
                @nearst = ($ux, $trkpt->{lat}, $trkpt->{lon}, $trkpt->{ele});
            }
        }
    }

    if ( $chkdef < $mindef ){
        # 最大誤差を下回る誤差のレコードがあった場合
        $exifTool->SetNewValue("GPSLatitude", "$nearst[1]") or die $!;
        $exifTool->SetNewValue("GPSLongitude", "$nearst[2]") or die $!;
        $exifTool->SetNewValue("GPSAltitude", "$nearst[3]") or die $!;
        $exifTool->WriteInfo("$imgdir/$file") or die $!;

        print STDERR "$file\t" . fmtts($nearst[0]) . "\t$chkdef\t$nearst[1]\t$nearst[2]\t$nearst[3]\n";

    } else {
        print STDERR "$file No suitable record found.\n";
    }
}
exit;


###
### Sub routine
###
sub ux {
    my ($YYYY, $MM, $DD, $hh, $mm, $ss) = @_;
    return timelocal($ss ,$mm ,$hh ,$DD, $MM-1, $YYYY);
}

sub ux_p9 {
    my ($YYYY, $MM, $DD, $hh, $mm, $ss) = @_;
    my $p9 = timelocal($ss ,$mm ,$hh ,$DD, $MM-1, $YYYY);
    $p9 += 60*60*9;        # 9h plus
    return $p9;
}

sub fmtts {
    my ($ss,$mm,$hh,$DD,$MM,$YYYY,$wday,$yday,$isdst) = localtime($_[0]);
    $YYYY+=1900; $MM+=1;
    return sprintf("%04d-%02d-%02d %02d:%02d:%02d", $YYYY, $MM, $DD, $hh, $mm, $ss);
}
