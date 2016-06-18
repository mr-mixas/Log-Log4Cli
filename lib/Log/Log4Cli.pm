package Log::Log4Cli;

use 5.006;
use strict;
use warnings;
use parent qw(Exporter);

use Term::ANSIColor qw(colored);

our $VERSION = '0.09'; # Don't forget to change in pod below

our @EXPORT = qw(
    die_fatal
    die_info
    die_notice

    log_fd

    log_fatal
    log_error
    log_warn
    log_info
    log_debug
    log_trace
);

our $C = {
    FATAL  => 'bold red',
    ERROR  => 'red',
    NOTICE => 'bold green',
    WARN   => 'yellow',
    INFO   => 'cyan',
    DEBUG  => 'blue',
    TRACE  => 'magenta'
};
our $L = 0;
our $N = undef;

my $F = *STDERR;    # descriptor
our $T = -t $F;     # color on/off switcher

sub _pfx($) {
    my ($S, $M, $H, $d, $m, $y) = localtime(time);
    my $pfx = sprintf "[%04i-%02i-%02i %02i:%02i:%02i %i %6s] ", $y + 1900, $m + 1, $d, $H, $M, $S, $$, $_[0];
    return ($T ? colored($pfx, $C->{$_[0]}) : $pfx) . (($N or $L > 4) ? join(":", (caller(1))[1,2]) . " " : "");
}

sub die_fatal(;$;$) {
    my ($msg, $code) = @_;
    $code = 127 unless (defined $code);
    if ($L > -2) {
        $msg = defined $msg ? "$msg. " : "";
        print $F _pfx('FATAL'), $msg, "Exit $code, ET ", (time - $^T), "s\n";
    }
    exit $code;
}

sub die_info(;$;$) {
    my ($msg, $code) = @_;
    $code = 0 unless (defined $code);
    if ($L > 1) {
        $msg = defined $msg ? "$msg. " : "";
        print $F _pfx('INFO'), $msg, "Exit $code, ET ", (time - $^T), "s\n";
    }
    exit $code;
}

sub die_notice(;$;$) {
    my ($msg, $code) = @_;
    $code = 0 unless (defined $code);
    if ($L > -1) {
        $msg = defined $msg ? "$msg. " : "";
        print $F _pfx('NOTICE'), $msg, "Exit $code, ET ", (time - $^T), "s\n";
    }
    exit $code;
}

sub log_fatal(&) { print $F _pfx('FATAL'), $_[0]->($_), "\n" if $L > -2 }
sub log_error(&) { print $F _pfx('ERROR'), $_[0]->($_), "\n" if $L > -1 }
sub log_warn(&)  { print $F _pfx('WARN'),  $_[0]->($_), "\n" if $L >  0 }
sub log_info(&)  { print $F _pfx('INFO'),  $_[0]->($_), "\n" if $L >  1 }
sub log_debug(&) { print $F _pfx('DEBUG'), $_[0]->($_), "\n" if $L >  2 }
sub log_trace(&) { print $F _pfx('TRACE'), $_[0]->($_), "\n" if $L >  3 }

sub log_fd(;$) {
    if (@_) {
        $F = shift;
        $T = -t $F;
    }
    return $F;
}

1;

__END__

=head1 NAME

Log::Log4Cli -- Lightweight perl logger for command line tools

=head1 VERSION

Version 0.09

=head1 SYNOPSIS

    Log::Log4Cli;

    $Log::Log4Cli::C->{DEBUG} = 'green';      # redefine color
    $Log::Log4Cli::L = 5;                     # set loglevel
    $Log::Log4Cli::N = 1;                     # force file:line marks (also enables if loglevel > 4)
    log_fd(\*STDOUT);                         # print to STDOUT (STDERR by default)

    log_error { "blah-blah, it's an error" };

    $Log::Log4Cli::T = 0;                     # colors now disabled

    log_trace { "Guts:\n" . Dumper $struct }; # Dumper will be called only when TRACE level enabled

    die_info 'All done', 0                    # args optional

=head1 EXPORT

All subroutines described below exports by default.

=head1 SUBROUTINES

=head2 die_fatal, die_info, die_notice

    die_fatal("Something went wrong!", 8);

Log message and die with provided exid code. All arguments are optional. If second arg (exit code) omitted
die_info, die_notice and die_fatal will use 0, 0 and 127 respectively. C<die_notice()> is almost the same as C<die_info()>,
but it's logging activated on ERROR level and use 'bold green' as prefix color.

=head2 log_fatal, log_error, log_warn, log_info, log_debug, log_trace

    log_(fatal|error|warn|info|debug|trace) { "This is a log message" };

Execute passed code block and write it's return value if loglevel permit so. Set C<$Log::Log4Cli::T> to false value
if you want to disable colors.

=head2 log_fd

Get/Set file descriptor for log messages. STDERR is used by default.

=head1 SEE ALSO

L<Term::ANSIColor|Term::ANSIColor>

=head1 LICENSE AND COPYRIGHT

Copyright 2016 Michael Samoglyadov.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.

=cut
