#!perl -T

use Test::More tests => 7;

BEGIN {
        use_ok('Log::BSDLog');
        use_ok('Log::BSDLog::Handle');
        use_ok('Log::BSDLog::Handle::File');
        use_ok('Log::BSDLog::Handle::Output');
        use_ok('Log::BSDLog::Handle::Syslog');
        use_ok('Log::BSDLog::Logger');
        use_ok('Log::BSDLog::Formatter');
}

diag("Testing Log::BSDLog $Log::BSDLog::VERSION, Perl $], $^X");
