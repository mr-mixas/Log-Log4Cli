#!perl
use 5.006;
use strict;
use warnings;
use Capture::Tiny qw(capture);
use Log::Log4Cli;
use Test::More;

$Log::Log4Cli::LEVEL = 4;

for my $lvl_name (qw(FATAL INFO NOTICE)) {
    for my $status (0, 7) {
        my $text = 'use Log::Log4Cli; die_' . lc($lvl_name) . " undef, $status";
        my ($out, $err, $exit) = capture { system ($^X, '-MLog::Log4Cli', '-e', "$text") };
        my $exp = ($lvl_name eq 'FATAL' and $status == 0) ? 127 : $status;
        is(($exit >> 8), $exp, "die $lvl_name status check ($status)")
    }
}

done_testing();
