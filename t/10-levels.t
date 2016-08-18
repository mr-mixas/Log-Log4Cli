#!perl -T
use 5.006;
use strict;
use warnings;
use Capture::Tiny qw(capture);
use Test::More tests => 98;

use Log::Log4Cli;

use lib "t";
use _common qw($LVL_MAP);

for my $lvl (-2..4) {
    $Log::Log4Cli::LEVEL = $lvl;
    for my $lvl_name (keys %{$LVL_MAP}) {

        # log
        my ($out, $err) = capture { eval "log_" . lc($lvl_name) . "{ '$lvl_name log msg' }" };
        ok($out eq ''); # log write (by default) to STDERR only
        if ($lvl > $LVL_MAP->{$lvl_name}) {
            ok($err =~ /\] $lvl_name log msg$/);
        } else {
            ok($err eq '');
        }

    }
}
