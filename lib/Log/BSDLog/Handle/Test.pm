
=head1 NAME

Log::BSDLog::Handle::Test - formatted output

=head1 SYNOPSIS

Returns the formatted string for testing purposes.

    use Log::BSDLog;
    use Log::BSDLog::Handle::Test;

    # Get a new logger
    my $log = Log::BSDLog->getLogger("foo");

    # register a file handle
    my $handle = Log::BSDLog::Handle::Test->new();

    # get a formatted message
    my $formatted_message = $log->(INFO, "Opened new log handle");

=head1 DESCRIPTION

The test handle returns the formatted message.  This is useful for
general-purpose testing and verification.

=cut

use strict;
use warnings;

package Log::BSDLog::Handle::Test;

use base qw( Log::BSDLog::Handle );

our $VERSION = '0.01';

=head1 METHODS

=head2 msgWrite($lvl, $msg, $skip)

See L<Log::BSDLog::Handle>

Returns the formatted message rather than the object.

=cut

sub msgWrite
{

    my $self = shift;
    my $lvl  = shift;
    my $msg  = shift;
    my $skip = shift;        # NOT USED

    # make sure we load the appropriate formatter
    eval "require " . ref $self->{formatter};

    # if we have a formatter defined, then use that, otherwise, just
    # print the raw message
    $msg = $self->{formatter}->format($lvl, $msg, $skip)
        if defined $self->{formatter};

    # Victory!
    return $msg;

}        # msgWrite()

=head1 AUTHOR

Christopher M. Fuhrman, C<< <cfuhrman at panix.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-log-bsdlog-handle-file at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Log-BSDLog>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Log::BSDLog

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Log-BSDLog>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Log-BSDLog>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Log-BSDLog>

=item * Search CPAN

L<http://search.cpan.org/dist/Log-BSDLog>

=back

=head1 REVISION INFORMATION

  $Id: Test.pm 45 2008-05-07 22:06:40Z cfuhrman $

=head1 COPYRIGHT & LICENSE

Copyright (c) 2008 Christopher M. Fuhrman, 
All rights reserved.

This program is free software licensed under the...

	The BSD License

The full text of the license can be found in the
LICENSE file included with this module.

=cut

1;        # End of Log::BSDLog::Handle::Test
