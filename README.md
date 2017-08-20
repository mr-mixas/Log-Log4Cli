# NAME

Log::Log4Cli -- Lightweight logger for command line tools

# VERSION

Version 0.18

# SYNOPSIS

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

# DESCRIPTION

Lightweight, but sufficient and user friendly logging for command line tools with
minimal impact on performance, no configuration and no non-core dependencies.

# EXPORT

All subroutines described below are exported by default.

# SUBROUTINES

## die\_fatal, die\_alert, die\_notice, die\_info

    die_fatal "Something terrible happened", 8;

Log message and exit with provided code. All arguments are optional. If second arg
(exit code) omitted die\_fatal, die\_alert and die\_info will exit with 127, 0 and 0
respectively. `die_notice` is deprecated and will be removed in future releases.

## log\_fatal, log\_error, log\_alert, log\_notice, log\_warn, log\_info, log\_debug, log\_trace

    log_error { "Something went wrong!" };

Execute passed code block and write it's return value if loglevel permit so. Set
`$Log::Log4Cli::COLOR` to false value to disable colors. `log_notice` is
deprecated and will be removed in future releases.

## log\_fd

Get/set file descriptor for log messages. `STDERR` is used by default.

# LOG LEVELS

Only builtin loglevels supported:

    FATAL       -1      'bold red',
    ERROR        0      'red',
    ALERT        0      'bold yellow',
    WARN         1      'yellow',
    INFO         2      'cyan',
    DEBUG        3      'blue',
    TRACE        4      'magenta'

Colors may be changed, see ["SYNOPSIS"](#synopsis). Default loglevel is `ERROR` (0).

# SEE ALSO

[Log::Dispatch](https://metacpan.org/pod/Log::Dispatch), [Log::Log4perl](https://metacpan.org/pod/Log::Log4perl)

[Term::ANSIColor](https://metacpan.org/pod/Term::ANSIColor)

# LICENSE AND COPYRIGHT

Copyright 2016,2017 Michael Samoglyadov.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See [http://dev.perl.org/licenses/](http://dev.perl.org/licenses/) for more information.
