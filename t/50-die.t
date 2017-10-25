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

sub capture(&) { # can't use Capture::Tiny here - it evals code (see $^S in Log::Log4Cli)
    my $stderr;

    open(OLDERR, ">&STDERR"); # save stderr
    close(STDERR);
    open(STDERR,'>', \$stderr) or die $!;

    $_[0]->();

    open(STDERR, ">&OLDERR"); # restore stderr
    close(OLDERR);

    return $stderr;
}

for my $sub (\&die_alert, \&die_fatal, \&die_info) {
    for my $status (0, 7) {
        for my $message (undef, 'message') {
            my $stderr = capture { $sub->($message, $status) };

            if ($sub != \&die_info) {
                like($stderr, qr/] .*Exit/);
            } else {
                is($stderr, undef);
            }

            is(
                $LAST_EXIT,
                ($sub == \&die_fatal and $status == 0) ? 127 : $status
            );
        }
    }
}

my $stderr = capture { die };
is($LAST_EXIT, 255);
like($stderr, qr| FATAL] Died at t/50-die\.t line \d+\. Exit 255, ET |);

$stderr = capture { die undef, undef };
is($LAST_EXIT, 255);
like($stderr, qr| FATAL] Died at t/50-die\.t line \d+\. Exit 255, ET |);

$stderr = capture { die "die", "with", "message" };
is($LAST_EXIT, 255);
like($stderr, qr| FATAL] die with message at t/50-die\.t line \d+\. Exit 255, ET |);

$Log::Log4Cli::LEVEL = 4;

eval { die_fatal "evaled die_fatal test" };
is($Log::Log4Cli::STATUS, 127);
like($@, qr/^evaled die_fatal test/);

eval { die_info "evaled die_info test" };
is($Log::Log4Cli::STATUS, 0);
like($@, qr/^evaled die_info test/);

eval { die_notice "evaled die_notice test" };
is($Log::Log4Cli::STATUS, 0);
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
