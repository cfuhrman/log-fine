#!perl -T

#
# $Id$
#

use Test::More tests => 1025;

use Log::Fine qw( :macros :masks );
use Log::Fine::Handle;
use Log::Fine::Handle::String;

# Mappings
my $ltov;
my $vtol;
my $mtov;

# Variable for mapping masks to their levels
my $mtolv = {};

{

        my @mv;
        my $levels = Log::Fine::LOG_LEVELS;
        my $masks  = Log::Fine::LOG_MASKS;

        # build level-to-value and value-to-level maps
        foreach my $level (@{$levels}) {
                my $val = eval $level;
                $ltov->{$level} = $val;
                $vtol->{$val}   = $level;
        }

        # now build mask to value maps
        $mtov->{$_} = eval $_ foreach (@{$masks});

        # finally, build mask to level map
        for (my $i = 0; $i < scalar @{$masks}; $i++) {
                $mtolv->{ $mtov->{ $masks->[$i] } } = $ltov->{ $levels->[$i] };
        }

        # now that we're set up, start by constructing a handle
        my $handle = Log::Fine::Handle::String->new();

        # validate handle and formatter
        isa_ok($handle,              "Log::Fine::Handle");
        isa_ok($handle->{formatter}, "Log::Fine::Formatter::Basic");

        # make sure all methods are supported
        can_ok($handle, $_) foreach (qw/ isLoggable msgWrite setFormatter /);

        # build array of mask values
        push @mv, $mtov->{$_} foreach (keys %{$mtov});

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
