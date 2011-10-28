#!perl -T

#
# $Id$
#

use Test::More tests => 24;

#use Data::Dumper;
use Log::Fine;
use Log::Fine::Handle;
use Log::Fine::Handle::String;
use Log::Fine::Levels::Syslog qw( :macros :masks );

{

        # initialize logging framework and grab ref to map
        my $log = Log::Fine->new();

        isa_ok($log, "Log::Fine");
        can_ok($log, "name");

        # all objects should have names
        ok($log->name() =~ /\w\d+$/);

        # first we create a handle
        my $handle =
            Log::Fine::Handle::String->new(
                            mask => LOGMASK_EMERG | LOGMASK_CRIT | LOGMASK_ERR |
                                LOGMASK_WARNING);

        # validate handle types
        isa_ok($handle,              "Log::Fine::Handle");
        isa_ok($handle->{formatter}, "Log::Fine::Formatter::Basic");
        can_ok($handle, "name");
        ok($handle->name() =~ /\w\d+$/);

        # make sure all methods are supported
        can_ok($handle, $_)
            foreach (qw/ isLoggable msgWrite formatter bitmaskListEnabled /);

        $handle->formatter(Log::Fine::Formatter::Basic->new());
        ok($handle->formatter()->isa("Log::Fine::Formatter"));
        ok($handle->isLoggable(CRIT));
        ok(!$handle->isLoggable(DEBG));

        my @masks        = $handle->levelMap()->logMasks();
        my @enabledmasks = $handle->bitmaskListEnabled();

        ok(scalar @enabledmasks == 4);          # remember, our handle defined
                                                # above only has 4 bitor'd masks

        foreach my $mask (@enabledmasks) {
                ok(
                    $handle->isLoggable(
                                  log($handle->levelMap()->maskToValue($mask)) /
                                      log(2) - 1
                    ));
        }

        # Get difference of arrays
        my @union = my @intersection = my @difference = ();
        my %count = ();
        foreach my $element (@masks, @enabledmasks) { $count{$element}++ }
        foreach my $element (keys %count) {
                push @union, $element;
                push @{ $count{$element} > 1 ? \@intersection : \@difference },
                    $element;
        }

        foreach my $mask (@difference) {
                ok(
                    !$handle->isLoggable(
                                  log($handle->levelMap()->maskToValue($mask)) /
                                      log(2) - 1
                    ));
        }

    SKIP: {

                eval "use Test::Output";

                skip
"Test::Output 0.10 or above required for testing Console output",
                    1
                    if $@;

                my $msg =
"Stop by this disaster town, we put our eyes to the sun and say 'Hello!'";
                my $badhandle = Log::Fine::Handle->new(no_croak => 1);

                stderr_like(sub { $badhandle->msgWrite(INFO, $msg) },
                            qr/direct call to abstract method/,
                            'Test Direct Abstract Call'
                );

        }

}
