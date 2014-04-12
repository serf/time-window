#!/usr/bin/perl
#
#
#
use warnings;
use strict;
use Time::Window;

my $window = Time::Window->new(
    range_file => 'test.timing',
);
my $text = $window->as_text;
my $in = $window->check;

my $state = {
    0 => 'off',
    1 => 'on',
};

print $state->{$in}, $/;
print $text, $/;

