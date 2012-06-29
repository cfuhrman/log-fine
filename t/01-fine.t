#!perl -T

#
# $Id$
#

use Test::More tests => 14;

use Log::Fine qw( :macros :masks );
use Log::Fine::Levels;

{

        # Test construction
        my $fine = Log::Fine->new();

        isa_ok($fine, "Log::Fine");
        can_ok($fine, "name");

        # All objects should have names
        ok($fine->name() =~ /\w\d+$/);

        # Test retrieving a logging object
        my $log = $fine->logger("com0");

        # Make sure we got a valid object
        isa_ok($log, "Log::Fine::Logger");

        # Make sure _error() and _fatal() are present
        ok($log->can("_error"));
        ok($log->can("_fatal"));

        # Check name
        ok($log->can("name"));
        ok($log->name() =~ /\w\d+$/);

        # See if the object supports getLevels
        ok($log->can("levelMap"));
        ok($log->levelMap and $log->levelMap->isa("Log::Fine::Levels"));

        # Check default level map
        ok( ref $log->levelMap eq "Log::Fine::Levels::"
                . Log::Fine::Levels->DEFAULT_LEVELMAP);

        # See if object supports listLoggers
        ok($log->can("listLoggers"));

        my @loggers = $log->listLoggers();

        ok(scalar @loggers > 0);
        ok(grep("com0", @loggers));

}
