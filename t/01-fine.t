#!perl -T

#
# $Id$
#

use Test::More tests => 12;

use Log::Fine qw( :macros :masks );
use Log::Fine::Levels;

{

        # test construction
        my $fine = Log::Fine->new();

        isa_ok($fine, "Log::Fine");
        can_ok($fine, "name");

        # all objects should have names
        ok($fine->name() =~ /\w\d+$/);

        # test retrieving a logging object
        my $log = $fine->logger("com0");

        # make sure we got a valid object
        isa_ok($log, "Log::Fine::Logger");

        # check name
        ok($log->can("name"));
        ok($log->name() =~ /\w\d+$/);

        # see if the object supports getLevels
        ok($log->can("levelMap"));
        ok($log->levelMap and $log->levelMap->isa("Log::Fine::Levels"));

        # Check default level map
        ok( ref $log->levelMap eq "Log::Fine::Levels::"
                . Log::Fine::Levels->DEFAULT_LEVELMAP);

        # see if object supports listLoggers
        ok($log->can("listLoggers"));

        my @loggers = $log->listLoggers();

        ok(scalar @loggers > 0);
        ok(grep("com0", @loggers));

}
