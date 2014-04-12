#!/usr/bin/perl
#
#
#
use warnings;
use strict;
use TimeWindow;

my $timing = 'test.timing';

my $state = {
    0 => 'off',
    1 => 'on',
};

sub VERBOSE { 1 }
my $on = time_in_window(time, $timing);
print $state->{$on}, $/;

