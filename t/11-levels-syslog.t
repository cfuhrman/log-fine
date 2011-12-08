#!perl -T

#
# $Id$
#

use Test::More tests => 1334;

use Log::Fine;
use Log::Fine::Handle::String;
use Log::Fine::Levels::Syslog qw( :macros :masks );

# Mask to Level mapping
my $ltov = Log::Fine::Levels::Syslog->LVLTOVAL_MAP;
my $vtol = Log::Fine::Levels::Syslog->VALTOLVL_MAP;
my $mtov = Log::Fine::Levels::Syslog->MASK_MAP;

# set message
my $msg =
    "Stop by this disaster town, we put our eyes to the sun and say 'Hello!'";

{

        my $levels = Log::Fine::Levels::Syslog->new();

        # levels should be a *::Syslog object
        isa_ok($levels, "Log::Fine::Levels::Syslog");

        # validate methods
        can_ok($levels, $_)
            foreach (
                    qw/ new bitmaskAll levelToValue maskToValue valueToLevel /);

        # build mask to level map
        my @levels = $levels->logLevels();
        my @masks  = $levels->logMasks();

        ok(scalar @levels > 0);
        ok(scalar @masks > 0);

        # make sure levels are in ascending order by val;
        my $val = 0;
        foreach my $level (@levels) {
                next if $ltov->{$level} == 0;
                ok($ltov->{$level} > $val);
                $val = $ltov->{$level};
        }

        # make sure masks are ascending order by val
        $val = 0;
        foreach my $mask (@masks) {
                next if $mtov->{$mask} == 0;
                ok($mtov->{$mask} > $val);
                $val = $mtov->{$mask};
        }

        # variable for holding bitmask
        my $bitmask = 0;

        for (my $i = 0; $i < scalar @levels; $i++) {
                ok($i == $levels->levelToValue($levels[$i]));
                ok(&{ $levels[$i] } eq $i);
                ok(&{ $masks[$i] }  eq $levels->maskToValue($masks[$i]));

                $bitmask |= $levels->maskToValue($masks[$i]);
        }

        ok($bitmask == $levels->bitmaskAll());
        ok($levels->MASK_MAP($_) =~ /\d/) foreach (@masks);

        # initialize some Log::Fine objects
        my $log    = Log::Fine->new();
        my $handle = Log::Fine::Handle::String->new();

        # validate handle types
        isa_ok($handle, "Log::Fine::Handle");

        # resort levels and masks
        @levels = sort keys %{$ltov};
        @masks  = sort keys %{$mtov};

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
        can_ok($handle, "isLoggable");

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
