#!perl -T

#
# $Id$
#

use Test::Simple tests => 5;

use Log::Fine qw( :macros :masks );

{

        # test construction
        my $fine = Log::Fine->new();

        ok(ref $fine eq "Log::Fine");

        # all objects should have names
        ok($fine->{name} =~ /\w\d+$/);

        # test retrieving a logging object
        my $log = $fine->logger("com0");

        # make sure we got a valid object
        ok($log and $log->isa("Log::Fine::Logger"));

        # see if the object supports getLevels
        ok($log->can("levelMap"));
        ok(ref $log->levelMap eq "Log::Fine::Levels::Syslog");

}
