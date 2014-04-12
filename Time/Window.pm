
package Time::Window;
 
use strict;
use warnings;
 
our $VERSION = "1.00";
 
=head1 NAME
 
TimeWindow - Check if a time is within the ranges specified in a file
 
=head1 SYNOPSIS
 
    use Time::Window;
    my $window = Time::Window->new();
    $window->range_file = 'timing.file';
    my $in = $window->check;
 
=head1 DESCRIPTION
 
The range file should be in the format:

    ddd HH:MM-HH:MM

where:

    ddd - Day, one of; all, mon, tue, wed, thu, fri, sat, sun
    HH  - Hour ( 00 to 23 )
    MM  - Minute ( 00 to 59 )

The file may contain multiple time ranges for a day

=head2 Methods
 
=head3 new
 
    my $window = Time::Window->new();
    my $window = Time::Window->new( range_file => $range_file );
    my $window = Time::Window->new( time => $time );
 
Instantiates an object which holds the path to the range file.
If a C<$time> is given it is passed to C<< $window->check >>.
 
=cut
 
#
# Constructor method
#
 
sub new {

    my($class, %args) = @_;
 
    my $self = bless({}, $class);
 
    my $range_file = exists $args{range_file} ? $args{range_file} : 'timing.file';
    $self->{range_file} = $range_file;
 
    my $time = exists $args{time} ? $args{time} : time;
    $self->{time} = $time;

    my $on = 0;
    $self->{on} = $on;
 
    return $self;

}
 
=head3 range_file
 
    $window->range_file($range_file);
    my $in = $window->check;
 
Timing file to read time ranges from
 
=cut
 
sub range_file {

    my $self = shift;
    if( @_ ) {
        my $range_file = shift;
        $self->{range_file} = $range_file;
    }
 
    return $self->{range_file};

}

 
=head3 time
 
    $window->time($time);
    my $in = $window->check;
 
The time to check against the range
 
=cut
 
sub time {

    my $self = shift;
    if( @_ ) {
        my $time = shift;
        $self->{time} = $time;
    }
 
    return $self->{time};

}
 
 
=head3 check
 
    $window->check;
 
An alias for time_in_window
 
=cut
 
sub check {

    my $self = shift;
    return $self->time_in_window;

}
 

=head3 as_text
 
    my $status = $window->as_text;
 
    Returns the status as 'in' or 'out'
 
=cut
 
sub as_text {

   my $self = shift;
   if ( $self->time_in_window ) {
       return 'in';
   } else {
       return 'out';
   }

}


=head3 time_in_window
 
Check the time is in one of the ranges in the file
Returns 1 for yes and 0 for no
 
=cut
 
sub time_in_window {

    my $self = shift;

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($self->time);

    my @wdays = (qw( all mon tue wed thu fri sat sun));

    open (my $timing_fh, $self->range_file) || die "Can't read '" . $self->range_file . "': $!\n";
    while (defined (my $line = <$timing_fh>)) {

        #
        # Read in & parse timing file
        #
        next if $line =~ /^\s*#/;
        next if $line =~ /^\s*$/;
        chomp $line;
        if ( $line =~ /^([a-z]{3})\s+(\d\d:\d\d)-(\d\d:\d\d)\s*$/i ) {
            my ($day, $begin, $end) = ($1,$2,$3);
            if ( $day eq $wdays[$wday] || $day eq 'all' ) {
                my $now = "$hour$min";
                my ($bh,$bm) = split(/:/,$begin);
                my ($eh,$em) = split(/:/,$end);
                my $from = "$bh$bm";
                my $to = "$eh$em";
                $self->{on} = 1 if ( $from <= $now && $now <= $to );
            }
        } else {
            print "ERROR: Invalid timing line [$line]\n";
            exit 1;
        }

    }
    close $timing_fh;

    return $self->{on};
    
}


=head1 AUTHOR
 
John Harrison <serf@perlmonks.org>
 
=cut
 
1;

