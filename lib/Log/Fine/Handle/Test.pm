
=head1 NAME

Log::Fine::Handle::Test - formatted output

=head1 SYNOPSIS

Returns the formatted string for testing purposes.

    use Log::Fine;
    use Log::Fine::Handle::Test;

    # Get a new logger
    my $log = Log::Fine->getLogger("foo");

    # register a file handle
    my $handle = Log::Fine::Handle::Test->new();

    # get a formatted message
    my $formatted_message = $log->(INFO, "Opened new log handle");

=head1 DESCRIPTION

The test handle returns the formatted message.  This is useful for
general-purpose testing and verification.

=cut

use strict;
use warnings;

package Log::Fine::Handle::Test;

use base qw( Log::Fine::Handle );

=head1 METHODS

=head2 msgWrite($lvl, $msg, $skip)

See L<Log::Fine::Handle>

Returns the formatted message rather than the object.

=cut

sub msgWrite
{

        my $self = shift;
        my $lvl  = shift;
        my $msg  = shift;
        my $skip = shift;          # NOT USED

        # make sure we load the appropriate formatter
        eval "require " . ref $self->{formatter};

        # if we have a formatter defined, then use that, otherwise, just
        # print the raw message
        $msg = $self->{formatter}->format($lvl, $msg, $skip)
                if defined $self->{formatter};

        # Victory!
        return $msg;

}          # msgWrite()

=head1 SEE ALSO

L<perl>, L<Log::Fine>, L<Log::Fine::Handle>

=head1 AUTHOR

Christopher M. Fuhrman, C<< <cfuhrman at panix.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-log-fine-handle-file at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Log-Fine>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Log::Fine

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Log-Fine>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Log-Fine>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Log-Fine>

=item * Search CPAN

L<http://search.cpan.org/dist/Log-Fine>

=back

=head1 REVISION INFORMATION

  $Id$

=head1 COPYRIGHT & LICENSE

Copyright (c) 2008 Christopher M. Fuhrman, 
All rights reserved.

This program is free software licensed under the...

	The BSD License

The full text of the license can be found in the
LICENSE file included with this module.

=cut

1;          # End of Log::Fine::Handle::Test
