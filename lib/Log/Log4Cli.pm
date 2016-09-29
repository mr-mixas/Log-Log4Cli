package Log::Log4Cli;

use 5.006;
use strict;
use warnings;
use parent qw(Exporter);

use Term::ANSIColor qw(colored);

our $VERSION = '0.12'; # Don't forget to change in pod below

our @EXPORT = qw(
    die_fatal
    die_info
    die_notice

    log_fd

    log_fatal
    log_error
    log_notice
    log_warn
    log_info
    log_debug
    log_trace
);

our $COLORS = {
    FATAL  => 'bold red',
    ERROR  => 'red',
    NOTICE => 'bold green',
    WARN   => 'yellow',
    INFO   => 'cyan',
    DEBUG  => 'blue',
    TRACE  => 'magenta'
};
our $LEVEL = 0;
our $POSITIONS = undef;
my $FD = \*STDERR;       # descriptor
our $COLOR = -t $FD;     # color on/off switcher

sub _die($$$$) {
    print $FD $_[2] . (defined $_[3] ? "$_[3]. " : "") .
        "Exit $_[0], ET ", (time - $^T), "s\n" if ($_[1]);
    exit $_[0];
}

sub _pfx($) {
    my ($S, $M, $H, $d, $m, $y) = localtime(time);
    my $pfx = sprintf "[%04i-%02i-%02i %02i:%02i:%02i %i %6s] ",
        $y + 1900, $m + 1, $d, $H, $M, $S, $$, $_[0];
    return ($COLOR ? colored($pfx, $COLORS->{$_[0]}) : $pfx) .
        (($POSITIONS or $LEVEL > 4) ? join(":", (caller(1))[1,2]) . " " : "");
}

sub die_fatal(;$;$)  { _die $_[1] || 127, $LEVEL > -2, _pfx('FATAL'),  $_[0] }
sub die_notice(;$;$) { _die $_[1] || 0,   $LEVEL > -1, _pfx('NOTICE'), $_[0] }
sub die_info(;$;$)   { _die $_[1] || 0,   $LEVEL >  1, _pfx('INFO'),   $_[0] }

sub log_fatal(&)  { print $FD _pfx('FATAL'),  $_[0]->($_), "\n" if $LEVEL > -2 }
sub log_error(&)  { print $FD _pfx('ERROR'),  $_[0]->($_), "\n" if $LEVEL > -1 }
sub log_notice(&) { print $FD _pfx('NOTICE'), $_[0]->($_), "\n" if $LEVEL > -1 }
sub log_warn(&)   { print $FD _pfx('WARN'),   $_[0]->($_), "\n" if $LEVEL >  0 }
sub log_info(&)   { print $FD _pfx('INFO'),   $_[0]->($_), "\n" if $LEVEL >  1 }
sub log_debug(&)  { print $FD _pfx('DEBUG'),  $_[0]->($_), "\n" if $LEVEL >  2 }
sub log_trace(&)  { print $FD _pfx('TRACE'),  $_[0]->($_), "\n" if $LEVEL >  3 }

sub log_fd(;$) {
    if (@_) {
        $FD = shift;
        $COLOR = -t $FD;
    }
    return $FD;
}

1;

__END__

=head1 NAME

Log::Log4Cli -- Lightweight perl logger for command line tools

=head1 VERSION

Version 0.12

=head1 SYNOPSIS

    Log::Log4Cli;

    $Log::Log4Cli::COLORS->{DEBUG} = 'green'; # redefine color
    $Log::Log4Cli::LEVEL = 4;                 # set max loglevel
    $Log::Log4Cli::POSITIONS = 1;             # force file:line marks (also enables if loglevel > 4)

    log_fd(\*STDOUT);                         # print to STDOUT (STDERR by default)

    log_error { "blah-blah, it's an error" };

    $Log::Log4Cli::COLOR = 0;                 # now colors disabled

    log_trace { "Guts:\n" . Dumper $struct }; # Dumper will be called only when TRACE level enabled

    die_info 'All done', 0                    # args optional

=head1 EXPORT

All subroutines described below are exported by default.

=head1 SUBROUTINES

=head2 die_fatal, die_info, die_notice

    die_fatal "Something terrible happened", 8;

Log message and die with provided exid code. All arguments are optional. If second arg (exit code) omitted
die_info, die_notice and die_fatal will use 0, 0 and 127 respectively.

=head2 log_fatal, log_error, log_notice, log_warn, log_info, log_debug, log_trace

    log_error { "Something went wrong!" };

Execute passed code block and write it's return value if loglevel permit so. Set C<$Log::Log4Cli::COLOR> to false value
if you want to disable colors.

=head2 log_fd

Get/Set file descriptor for log messages. C<STDERR> is used by default.

=head1 LOG LEVELS

Only builtin loglevels supported. Here they are:

    # LEVEL     VALUE   COLOR
    FATAL       -1      'bold red',
    ERROR        0      'red',
    NOTICE       0      'bold green',
    WARN         1      'yellow',
    INFO         2      'cyan',
    DEBUG        3      'blue',
    TRACE        4      'magenta'

Colors may be changed, see L</SYNOPSIS>.

=head1 SEE ALSO

L<Term::ANSIColor|Term::ANSIColor>

=head1 LICENSE AND COPYRIGHT

Copyright 2016 Michael Samoglyadov.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.

=cut
