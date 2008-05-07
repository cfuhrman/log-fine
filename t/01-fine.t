#!perl -T

#
# $Id$
#

use Test::Simple tests => 11;

use Log::BSDLog;

{

    # test construction
    my $bsdlog = Log::BSDLog->new();

    ok(ref $bsdlog eq "Log::BSDLog");

    # test retrieving a logging object
    my $log = $bsdlog->getLogger("com0");

    ok(ref $log eq "Log::BSDLog::Logger");

    # now test construction through getLogger()
    undef $log;

    $log = Log::BSDLog->getLogger("com1");

    ok(ref $log eq "Log::BSDLog::Logger");

    # test to make sure each level is exported correctly
    my $lvls = Log::BSDLog->LOG_LEVELS;

    for (my $i = 0; $i < scalar @{$lvls}; $i++) {
        print STDERR eval "$lvls->[$i]\n";
        ok(eval "$lvls->[$i]" eq $i);
    }

}
