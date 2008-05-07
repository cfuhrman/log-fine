
=head1 NAME

Log::BSDLog::Formatter - Log message formatting and sanitization

=head1 SYNOPSIS

Provides a formatting facility for log messages

    use Log::BSDLog::Handle;
    use Log::BSDLog::Formatter;

    my $handle   = Log::BSDLog::Handle::Output->new();
    my $formatter = Log::BSDLog::Formatter::Detailed->new();

    # by default, the handle will set its formatter to
    # Log::BSDLog::Formatter::Basic.  If that's not what you want,
    # reset it to preference.
    $handle->setFormatter($formatter);

=head1 DESCRIPTION

Base class for all formatters.  This class should not be instantiated
directly.

=cut

use strict;
use warnings;

package Log::BSDLog::Formatter;

use base qw( Log::BSDLog );

use Carp;

our $VERSION = '0.01';

use constant LOG_TIMESTAMP_FORMAT => "%c";

# --------------------------------------------------------------------

##
# Initializer for this object

sub _init
{

        my $self = shift;

        # make sure we load in the logger object
        require Log::BSDLog::Logger;

        # set timestamp_format to the default if necessary
        $self->{timestamp_format} = LOG_TIMESTAMP_FORMAT
                unless (defined $self->{timestamp_format}
                        and $self->{timestamp_format} =~ /\w+/);

        return $self;

}          # _init()

=head1 AUTHOR

Christopher M. Fuhrman, C<< <cfuhrman at panix.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-log-bsdlog-record at rt.cpan.org>, or through the web interface at
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

  $Id$

=head1 COPYRIGHT & LICENSE

Copyright (c) 2008 Christopher M. Fuhrman, 
All rights reserved.

This program is free software licensed under the...

	The BSD License

The full text of the license can be found in the
LICENSE file included with this module.

=cut

1;          # End of Log::BSDLog::Formatter

