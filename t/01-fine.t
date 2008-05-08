#!perl -T

#
# $Id$
#

use Test::Simple tests => 12;

use Log::Fine;

{

        # test construction
        my $fine = Log::Fine->new();

        ok(ref $fine eq "Log::Fine");

        # all objects should have names
        ok($fine->{name} =~ /\w+\d+/);

        # test retrieving a logging object
        my $log = $fine->getLogger("com0");

        ok(ref $log eq "Log::Fine::Logger");

        # now test construction through getLogger()
        undef $log;

        $log = Log::Fine->getLogger("com1");

        ok(ref $log eq "Log::Fine::Logger");

        # test to make sure each level is exported correctly
        my $lvls = Log::Fine->LOG_LEVELS;

        for (my $i = 0; $i < scalar @{$lvls}; $i++) {
                print STDERR eval "$lvls->[$i]\n";
                ok(eval "$lvls->[$i]" eq $i);
        }

}
