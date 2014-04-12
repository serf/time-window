#!/usr/bin/perl
#
#
#
use warnings;
use strict;

package TimeWindow;

use strict;
use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION     = 1.00;
@ISA         = qw(Exporter);
@EXPORT      = qw(time_in_window);
@EXPORT_OK   = qw(time_in_window check_window);
%EXPORT_TAGS = ( DEFAULT => [qw(&time_in_window)],
                 Both    => [qw(&time_in_window &check_window)]);

#
# This file should be in the format:
#
# ddd HH:MM-HH:MM
#

sub VERBOSE { 0 }

sub check_window($$$) {
    my ($now,$begin,$end) = (shift,shift,shift);
    my ($bh,$bm) = split(/:/,$begin);
    my ($eh,$em) = split(/:/,$end);
    my $from = "$bh$bm";
    my $to = "$eh$em";
    my $on = 0;
    $on = 1 if ( $from <= $now && $now <= $to );
    return $on;
}

sub time_in_window ($$) {

    my ($time,$timing) = (shift,shift);

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time);

    my @wdays = (qw( all mon tue wed thu fri sat sun));

    my $on = 0;
    open (my $timing_fh, "$timing") || die "Can't read '$timing': $!\n";
    while (defined (my $line = <$timing_fh>)) {

        #
        chomp $line;
        if ( $line =~ /^([a-z]{3})\s+(\d\d:\d\d)-(\d\d:\d\d)\s*$/i ) {
            my ($day, $begin, $end) = ($1,$2,$3);
            if ( $day eq $wdays[$wday] ) {
                VERBOSE && print "Today: $line\n";
                my $now = "$hour$min";
                $on = check_window($now,$begin,$end);
            } else {
                VERBOSE && print "No [$day] ($wdays[$wday])\n";
            }
        } else {
            print "ERROR: Invalid timing line [$line]\n";
            exit 1;
        }

    }
    close $timing_fh;
    return $on;
    
}

1;

