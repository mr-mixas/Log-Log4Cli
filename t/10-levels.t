#!perl
use 5.006;
use strict;
use warnings;
use Capture::Tiny qw(capture);
use Test::More tests => 140;

use Log::Log4Cli;

use lib "t";
use _common qw($LVL_MAP);

for my $lvl (-2..4) {
    $Log::Log4Cli::LEVEL = $lvl;
    for my $lvl_name (keys %{$LVL_MAP}) {
        my ($out, $err) = capture { eval "log_" . lc($lvl_name) . "{ '$lvl_name log msg' }" };
        ok($out eq ''); # log write (by default) to STDERR only
        if ($lvl > $LVL_MAP->{$lvl_name}) {
            ok($err =~ /\] $lvl_name log msg$/);
        } else {
            ok($err eq '');
        }
    }

    for my $lvl_name (qw(FATAL INFO NOTICE)) {
        my $cmd = 'use Log::Log4Cli; $Log::Log4Cli::LEVEL = ' . $lvl .
            '; die_' . lc($lvl_name) . " '$lvl_name die msg', 123";
        my ($out, $err) = capture { `$^X -MLog::Log4Cli -e '$cmd'` };
        ok($out eq ''); # die write (by default) to STDERR only
        if ($lvl > $LVL_MAP->{$lvl_name}) {
            ok($err =~ /$lvl_name/);
        } else {
            ok($err eq '');
        }
    }
}
