#!perl -T

use strict;
use warnings;
use Test::More tests => 11;

sub not_in_file_ok
{
    my ($filename, %regex) = @_;
    open my $fh, "<", $filename
        or die "couldn't open $filename for reading: $!";

    my %violated;

    while (my $line = <$fh>) {
        while (my ($desc, $regex) = each %regex) {
            if ($line =~ $regex) {
                push @{ $violated{$desc} ||= [] }, $.;
            }
        }
    }

    if (%violated) {
        fail("$filename contains boilerplate text");
        diag "$_ appears on lines @{$violated{$_}}" for keys %violated;
    } else {
        pass("$filename contains no boilerplate text");
    }
}

not_in_file_ok(
             README => "The README is used..." => qr/The README is used/,
             "'version information here'" => qr/to provide version information/,
);

not_in_file_ok(Changes => "placeholder date/time" => qr(Date/time));

sub module_boilerplate_ok
{
    my ($module) = @_;
    not_in_file_ok(
              $module => 'the great new $MODULENAME' => qr/ - The great new /,
              'boilerplate description' => qr/Quick summary of what the module/,
              'stub function definition' => qr/function[12]/,
    );
}

module_boilerplate_ok('lib/Log/BSDLog.pm');
module_boilerplate_ok('lib/Log/BSDLog/Handler.pm');
module_boilerplate_ok('lib/Log/BSDLog/Handler/File.pm');
module_boilerplate_ok('lib/Log/BSDLog/Handler/Output.pm');
module_boilerplate_ok('lib/Log/BSDLog/Handler/Syslog.pm');
module_boilerplate_ok('lib/Log/BSDLog/Logger.pm');
module_boilerplate_ok('lib/Log/BSDLog/Formatter.pm');
module_boilerplate_ok('lib/Log/BSDLog/Formatter/Basic.pm');
module_boilerplate_ok('lib/Log/BSDLog/Formatter/Detailed.pm');
