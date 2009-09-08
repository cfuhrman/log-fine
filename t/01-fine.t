#!perl -T

#
# $Id$
#

use Test::Simple tests => 42;

use Log::Fine qw( :macros :masks );

{

        # test construction
        my $fine = Log::Fine->new();

        ok(ref $fine eq "Log::Fine");

        # all objects should have names
        ok($fine->{name} =~ /\w\d+$/);

        # test retrieving a logging object
        my $log = $fine->getLogger("com0");

        # see if the object supports getLevels
        ok($log->can("getLevels"));
        ok(ref $log->getLevels eq "Log::Fine::Levels::Syslog");

        ok(ref $log eq "Log::Fine::Logger");

        # now test construction through getLogger()
        undef $log;

        $log = Log::Fine->getLogger("com1");

        ok(ref $log eq "Log::Fine::Logger");

        # test to make sure each level and mask is exported correctly
        my $lvls  = Log::Fine->LOG_LEVELS;
        my $masks = Log::Fine->LOG_MASKS;

        # test levels, levels as methods, and logmasks.
        my $all = 0;
        my $err = 0;
        for (my $i = 0; $i < scalar @{$lvls}; $i++) {
                ok(eval "$lvls->[$i]"  eq $i);
                ok(eval "$masks->[$i]" eq (2 << $i));

                # bitmask all and err for later testing
                $all |= eval "$masks->[$i]";
                $err |= eval "$masks->[$i]"
                    if ($i <= ERR);

                ok($fine->can($lvls->[$i]));
                ok($fine->can($masks->[$i]));
        }

        # test shorthand logmasks
        ok(eval Log::Fine->LOGMASK_ALL == $all);
        ok(eval Log::Fine->LOGMASK_ERROR == $err);

        # test cloning
        my $clone1 = $fine->clone();
        my $clone2 = $fine->clone($log);

        ok($clone1->isa("Log::Fine"));
        ok($clone2->isa("Log::Fine"));

}
