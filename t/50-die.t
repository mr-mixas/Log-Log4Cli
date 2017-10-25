#!perl -T

use 5.006;
use strict;
use warnings FATAL => 'all';

my $LAST_EXIT;

BEGIN {
    *CORE::GLOBAL::exit = sub {
        $LAST_EXIT = $_[0];
    };
};

use Log::Log4Cli;
use Test::More;

open(OLDERR, ">&STDERR"); # save stderr
close(STDERR);

for my $sub (\&die_alert, \&die_fatal, \&die_info) {
    for my $status (0, 7) {
        for my $message (undef, 'message') {
            my $stderr;
            open(STDERR,'>', \$stderr) or die $!;

            $sub->($message, $status);

            if ($sub != \&die_info) {
                like($stderr, qr/] .*Exit/);
            } else {
                is($stderr, undef);
            }

            is(
                $LAST_EXIT,
                ($sub == \&die_fatal and $status == 0) ? 127 : $status
            );

            close(STDERR);
        }
    }
}

open(STDERR, ">&OLDERR"); # r4estoire stderr
close(OLDERR);

$Log::Log4Cli::LEVEL = 4;

eval { die_fatal "evaled die_fatal test" };
like($@, qr/^evaled die_fatal test/);

eval { die_info "evaled die_info test" };
like($@, qr/^evaled die_info test/);

eval { die_notice "evaled die_notice test" };
like($@, qr#^evaled die_notice test at t/50-die.t#);

$Log::Log4Cli::LEVEL = 0;

eval { die_fatal undef, 42 };
is($Log::Log4Cli::STATUS, 42);
like($@, qr#^Died at t/50-die.t#);

eval { die_info undef, 43 };
is($Log::Log4Cli::STATUS, 43);
like($@, qr/^Died at/);

eval { die_notice undef, 44 };
is($Log::Log4Cli::STATUS, 44);
like($@, qr/^Died at/);

done_testing();
