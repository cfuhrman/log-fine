#!perl -T

use Test::More;
use File::Basename;

use Log::Fine;
use Log::Fine::Levels::Syslog;

{

        # See if we have Sys::Syslog installed
        eval "use Sys::Syslog qw( :standard :macros )";

        if ($@) {
                plan skip_all => "Sys::Syslog 0.13 or above required for testing";
        } else {
                plan tests => 11;
        }

        use Sys::Syslog qw( :standard :macros );
        use Log::Fine::Handle::Syslog;

        my $msg =
              "This is a test message generated by the Log::Fine unit tests.  "
            . "Please disregard";

        # Add a handle.  Note we use the default formatter.
        my $handle = Log::Fine::Handle::Syslog->new();

        # Do some validation
        isa_ok($handle, "Log::Fine::Handle");
        can_ok($handle, "name");
        can_ok($handle, "levelMap");

        ok($handle->name() =~ /\w\d+$/);

        # These should be set to their default values
        ok($handle->{mask} == $handle->levelMap()->bitmaskAll());
        ok($handle->{formatter}->isa("Log::Fine::Formatter::Basic"));

        # Syslog-specific attributes
        ok($handle->{ident} eq basename $0);
        ok($handle->{logopts} =~ /pid/);
        ok($handle->{facility} == Sys::Syslog->LOG_LOCAL0);

        # Save original STDERR on newer versions of perl
        open my $saved_stderr, ">&STDERR"
            if $^V ge v5.8.0;

        # Write a test message
        $handle->msgWrite(INFO, $msg, 1);

        # Make sure we can't define more than one handle
        eval {

                # Note: this may or may not work under Windows
                if ($^O eq "MSWin32") {
                        open STDERR, "> NUL";
                } else {
                        open STDERR, "> /dev/null";
                }

                my $console =
                    Log::Fine::Handle::Syslog->new(facility => Sys::Syslog->LOG_USER,
                                                   ident    => "badhandle");
        };

        # Restore original STDERR
        open STDERR, ">&", $saved_stderr or die "open: $!"
            if $^V ge v5.8.0;

        ok(defined $@);
        ok($@ =~ /One and _only_ one/);

}
