#!perl -T

#
# $Id$
#

use Test::More tests => 1029;

use Log::Fine;
use Log::Fine::Handle;
use Log::Fine::Handle::String;
use Log::Fine::Levels::Syslog qw( :macros :masks );

# Mask to Level mapping
my $ltov = Log::Fine::Levels::Syslog->LVLTOVAL_MAP;
my $vtol = Log::Fine::Levels::Syslog->VALTOLVL_MAP;
my $mtov = Log::Fine::Levels::Syslog->MASK_MAP;

# Variable for mapping masks to their levels
my $mtolv = {};

# set message
my $msg =
    "Stop by this disaster town, we put our eyes to the sun and say 'Hello!'";

{

        my $skipflag = 0;

        # initialize logging framework and grab ref to map
        my $log = Log::Fine->new();

        isa_ok($log, "Log::Fine");

        # first we create a handle
        my $handle = Log::Fine::Handle::String->new();

        # validate handle types
        isa_ok($handle, "Log::Fine::Handle");
        isa_ok($handle->{formatter}, "Log::Fine::Formatter::Basic");

        # make sure all methods are supported
        can_ok($handle, $_) foreach (qw/ isLoggable msgWrite formatter /);

        # build mask to level map
        my @levels = sort keys %{$ltov};
        my @masks  = sort keys %{$mtov};

        ok(scalar @levels == scalar @masks);

        for (my $i = 0; $i < scalar @levels; $i++) {
                $mtolv->{ $mtov->{ $masks[$i] } } = $ltov->{ $levels[$i] };
        }

        # validate default attributes
        ok($handle->{mask} == $log->levelMap()->bitmaskAll());

        # build array of mask values
        my @mv;
        push @mv, $mtov->{$_} foreach (@masks);

        # clear bitmask
        $handle->{mask} = 0;

        # now recursive test isLoggable() with sorted values of masks
        testmask(0, sort { $a <=> $b } @mv);

    SKIP: {

                eval "use Test::Output";

                skip
"Test::Output 0.10 or above required for testing Console output",
                    1
                    if $@;

                my $badhandle = Log::Fine::Handle->new(no_croak => 1);

                stderr_like(sub { $badhandle->msgWrite(INFO, $msg) },
                            qr/direct call to abstract method/,
                            'Test Direct Abstract Call'
                );

        }

}

# --------------------------------------------------------------------

sub testmask
{

        my $bitmask = shift;
        my @masks   = @_;

        # return if there are no more elements to test
        return unless scalar @masks;

        # shift topmost mask off
        my $lvlmask = shift @masks;

        # validate lvlmask
        ok($lvlmask =~ /\d/);

        # Determine lvl and create a new handle
        my $lvl = $vtol->{ $mtolv->{$lvlmask} };
        my $handle = Log::Fine::Handle::String->new(mask => $bitmask);

        # current level should not be set so do negative test
        isa_ok($handle, "Log::Fine::Handle");
        ok(!$handle->isLoggable(eval "$lvl"));

        # recurse downward again
        testmask($handle->{mask}, @masks);

        # now we do positive testing
        $handle->{mask} |= $lvlmask;

        # Do a positive test
        ok($handle->isLoggable(eval "$lvl"));

        # now that the bitmask has been set iterate downward again
        testmask($handle->{mask}, @masks);

}          # testmask()
