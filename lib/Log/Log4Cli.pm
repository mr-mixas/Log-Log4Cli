package Log::Log4Cli;

use 5.006;
use strict;
use warnings;
use parent qw(Exporter);

use Term::ANSIColor qw(colored);

our $VERSION = '0.19'; # Don't forget to change in pod below

our @EXPORT = qw(
    die_fatal
    die_info
    die_alert
    die_notice

    log_fd

    log_fatal
    log_error
    log_alert
    log_notice
    log_warn
    log_info
    log_debug
    log_trace
);

our $COLORS = {
    FATAL  => 'bold red',
    ERROR  => 'red',
    ALERT  => 'bold yellow',
    WARN   => 'yellow',
    INFO   => 'cyan',
    DEBUG  => 'blue',
    TRACE  => 'magenta'
};
$COLORS->{NOTICE} = $COLORS->{ALERT}; # Deprecated

our $LEVEL = 0;
our $POSITIONS = undef;
my $FD = \*STDERR;       # descriptor
our $COLOR = -t $FD;     # color on/off switcher

sub _die($$$$) {
    if ($^S) {
        # inside eval block
        die defined $_[3] ? "$_[3]. " : "";
    } else {
        print $FD $_[2] . (defined $_[3] ? "$_[3]. " : "") .
            "Exit $_[0], ET " . (time - $^T) . "s\n" if ($_[1]);
        exit $_[0];
    }
}

sub _pfx($) {
    my ($S, $M, $H, $d, $m, $y) = localtime(time);
    my $pfx = sprintf "[%04i-%02i-%02i %02i:%02i:%02i %i %5s] ",
        $y + 1900, $m + 1, $d, $H, $M, $S, $$, $_[0];
    return ($COLOR ? colored($pfx, $COLORS->{$_[0]}) : $pfx) .
        (($POSITIONS or $LEVEL > 4) ? join(":", (caller(1))[1,2]) . " " : "");
}

sub die_fatal(;$;$) { _die $_[1] || 127, $LEVEL > -2, _pfx('FATAL'), $_[0] }
sub die_alert(;$;$) { _die $_[1] || 0,   $LEVEL > -1, _pfx('ALERT'), $_[0] }
*die_notice = \&die_alert; # Deprecated
sub die_info(;$;$)  { _die $_[1] || 0,   $LEVEL >  1, _pfx('INFO'),  $_[0] }

sub log_fatal(&) { print $FD _pfx('FATAL') . $_[0]->($_) . "\n" if $LEVEL > -2 }
sub log_error(&) { print $FD _pfx('ERROR') . $_[0]->($_) . "\n" if $LEVEL > -1 }
sub log_alert(&) { print $FD _pfx('ALERT') . $_[0]->($_) . "\n" if $LEVEL > -1 }
*log_notice = \&log_alert; # Deprecated
sub log_warn(&)  { print $FD _pfx('WARN')  . $_[0]->($_) . "\n" if $LEVEL >  0 }
sub log_info(&)  { print $FD _pfx('INFO')  . $_[0]->($_) . "\n" if $LEVEL >  1 }
sub log_debug(&) { print $FD _pfx('DEBUG') . $_[0]->($_) . "\n" if $LEVEL >  2 }
sub log_trace(&) { print $FD _pfx('TRACE') . $_[0]->($_) . "\n" if $LEVEL >  3 }

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

Log::Log4Cli -- Lightweight logger for command line tools

=begin html

<a href="https://travis-ci.org/mr-mixas/Log-Log4Cli.pm"><img src="https://travis-ci.org/mr-mixas/Log-Log4Cli.pm.svg?branch=master" alt="CI"></a>
<a href='https://coveralls.io/github/mr-mixas/Log-Log4Cli.pm?branch=master'><img src='https://coveralls.io/repos/github/mr-mixas/Log-Log4Cli.pm/badge.svg?branch=master' alt='Coverage Status'></a>
<a href="https://badge.fury.io/pl/Log-Log4Cli"><img src="https://badge.fury.io/pl/Log-Log4Cli.svg" alt="CPAN version"></a>

=end html

=head1 VERSION

Version 0.19

=head1 SYNOPSIS

    use Log::Log4Cli;

    $Log::Log4Cli::COLORS->{DEBUG} = 'green'; # redefine color (Term::ANSIColor notation)
    $Log::Log4Cli::LEVEL = 4;                 # set loglevel
    $Log::Log4Cli::POSITIONS = 1;             # force file:line marks (also enables if loglevel > 4)

    log_fd(\*STDOUT);                         # print to STDOUT (STDERR by default)

    log_error { "blah-blah, it's an error" };

    $Log::Log4Cli::COLOR = 0;                 # now colors disabled

    my $guts = { some => "value" };
    log_trace {                               # block executed when appropriate level enabled only
        require Data::Dumper;
        return "Guts:\n" . Data::Dumper->Dump([$guts]);
    };

    die_info 'All done', 0;

=head1 DESCRIPTION

Lightweight, but sufficient and user friendly logging for command line tools with
minimal impact on performance, no configuration and no non-core dependencies.

=head1 EXPORT

All subroutines described below are exported by default.

=head1 SUBROUTINES

=head2 die_fatal, die_alert, die_notice, die_info

    die_fatal "Something terrible happened", 8;

Log message and exit with provided code. All arguments are optional. If second arg
(exit code) omitted die_fatal, die_alert and die_info will exit with 127, 0 and 0
respectively. C<die_notice> is deprecated and will be removed in future releases.

=head2 log_fatal, log_error, log_alert, log_notice, log_warn, log_info, log_debug, log_trace

    log_error { "Something went wrong!" };

Execute passed code block and write it's return value if loglevel permit so. Set
C<$Log::Log4Cli::COLOR> to false value to disable colors. C<log_notice> is
deprecated and will be removed in future releases.

=head2 log_fd

Get/set file descriptor for log messages. C<STDERR> is used by default.

=head1 LOG LEVELS

Only builtin loglevels supported:

    FATAL       -1      'bold red',
    ERROR        0      'red',
    ALERT        0      'bold yellow',
    WARN         1      'yellow',
    INFO         2      'cyan',
    DEBUG        3      'blue',
    TRACE        4      'magenta'

Colors may be changed, see L</SYNOPSIS>. Default loglevel is C<ERROR> (0).

=head1 SEE ALSO

L<Log::Dispatch|Log::Dispatch>, L<Log::Log4perl|Log::Log4perl>

L<Term::ANSIColor|Term::ANSIColor>

=head1 LICENSE AND COPYRIGHT

Copyright 2016,2017 Michael Samoglyadov.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.

=cut
