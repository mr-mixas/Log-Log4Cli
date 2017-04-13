# NAME

Log::Log4Cli -- Lightweight perl logger for command line tools

# VERSION

Version 0.16

# SYNOPSIS

    Log::Log4Cli;

    $Log::Log4Cli::COLORS->{DEBUG} = 'green'; # redefine color (Term::ANSIColor notation)
    $Log::Log4Cli::LEVEL = 4;                 # set loglevel
    $Log::Log4Cli::POSITIONS = 1;             # force file:line marks (also enables if loglevel > 4)

    log_fd(\*STDOUT);                         # print to STDOUT (STDERR by default)

    log_error { "blah-blah, it's an error" };

    $Log::Log4Cli::COLOR = 0;                 # now colors disabled

    log_trace { "Guts:\n" . Dumper $struct }; # Dumper will be called only when TRACE level enabled

    die_info 'All done', 0                    # args optional

# EXPORT

All subroutines described below are exported by default.

# SUBROUTINES

## die\_fatal, die\_info, die\_notice

    die_fatal "Something terrible happened", 8;

Log message and die with provided exid code. All arguments are optional. If second arg (exit code) omitted
die\_info, die\_notice and die\_fatal will use 0, 0 and 127 respectively.

## log\_fatal, log\_error, log\_notice, log\_warn, log\_info, log\_debug, log\_trace

    log_error { "Something went wrong!" };

Execute passed code block and write it's return value if loglevel permit so. Set `$Log::Log4Cli::COLOR` to false value
if you want to disable colors.

## log\_fd

Get/Set file descriptor for log messages. `STDERR` is used by default.

# LOG LEVELS

Only builtin loglevels supported. Here they are:

    # LEVEL     VALUE   COLOR
    FATAL       -1      'bold red',
    ERROR        0      'red',
    NOTICE       0      'bold white',
    WARN         1      'yellow',
    INFO         2      'cyan',
    DEBUG        3      'blue',
    TRACE        4      'magenta'

Colors may be changed, see ["SYNOPSIS"](#synopsis).

# SEE ALSO

[Term::ANSIColor](https://metacpan.org/pod/Term::ANSIColor)

# LICENSE AND COPYRIGHT

Copyright 2016,2017 Michael Samoglyadov.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See [http://dev.perl.org/licenses/](http://dev.perl.org/licenses/) for more information.
