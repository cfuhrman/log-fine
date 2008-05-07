#!perl -T

#
# $Id: 02-handle.t 45 2008-05-07 22:06:40Z cfuhrman $
#

use Test::More tests => 5;

use Log::BSDLog;
use Log::BSDLog::Handle;
use Log::BSDLog::Handle::Test;

{

    # first we create a handle
    my $handle = Log::BSDLog::Handle::Test->new();

    # validate handle
    ok($handle->isa("Log::BSDLog::Handle"));

    # validate default attributes
    ok($handle->{mask} == Log::BSDLog::Handle->DEFAULT_LOGMASK);
    ok($handle->{level} == DEBG);
    ok($handle->{formatter}->isa("Log::BSDLog::Formatter"));
    ok(ref $handle->{formatter} eq "Log::BSDLog::Formatter::Basic");

}
