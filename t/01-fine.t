#!perl -T

#
# $Id$
#

use Test::Simple tests => 36;

use Log::Fine qw( :macros :masks );

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

        # test to make sure each level and mask is exported correctly
        my $lvls  = Log::Fine->LOG_LEVELS;
        my $masks = Log::Fine->LOG_MASKS;

        # test levels, levels as methods, and logmasks.
        for (my $i = 0; $i < scalar @{$lvls}; $i++) {
                ok(eval "$lvls->[$i]"  eq $i);
                ok(eval "$masks->[$i]" eq (2 << $i));
                ok($fine->can($lvls->[$i]));
                ok($fine->can($masks->[$i]));
        }

}
