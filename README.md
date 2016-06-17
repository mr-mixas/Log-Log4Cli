# NAME

Log::Log4Cli -- Lightweight perl logger for command line tools

# VERSION

Version 0.09

# SYNOPSIS

    Log::Log4Cli;

    $Log::Log4Cli::C->{DEBUG} = 'green';      # redefine color
    $Log::Log4Cli::L = 5;                     # set loglevel
    $Log::Log4Cli::N = 1;                     # force file:line marks (also enables if loglevel > 4)
    log_fd(\*STDOUT);                         # print to STDOUT (STDERR by default)

    log_error { "blah-blah, it's an error" };

    $Log::Log4Cli::T = 0;                     # colors now disabled

    log_trace { "Guts:\n" . Dumper $struct }; # Dumper will be called only when TRACE level enabled

    die_info 'All done', 0                    # args optional

# EXPORT

All subroutines described below exports by default.

# SUBROUTINES

## die\_fatal, die\_info, die\_notice

    die_fatal("Something went wrong!", 8);

Log message and die with provided exid code. All arguments are optional. If second arg (exit code) omitted
die\_info, die\_notice and die\_fatal will use 0, 0 and 127 respectively. die\_notice() is almost the same as die\_info(),
but it's logging activated on ERROR level and use 'bold green' as prefix color.

## log\_fatal, log\_error, log\_warn, log\_info, log\_debug, log\_trace

    log_(fatal|error|warn|info|debug|trace) { "This is a log message" };

Execute passed code block and write it's return value if loglevel permit so. Set $Log::Log4Cli::T to false value
if you want to disable colors.

## log\_fd

Get/Set file descriptor for log messages. STDERR is used by default.

# SEE ALSO

[Term::ANSIColor](https://metacpan.org/pod/Term::ANSIColor)

# LICENSE AND COPYRIGHT

Copyright 2016 Michael Samoglyadov.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See [http://dev.perl.org/licenses/](http://dev.perl.org/licenses/) for more information.
