
=head1 NAME

Log::Fine::Formatter - Log message formatting and sanitization

=head1 SYNOPSIS

Provides a formatting facility for log messages

    use Log::Fine::Handle;
    use Log::Fine::Formatter;

    my $handle    = Log::Fine::Handle::Console->new();
    my $formatter = Log::Fine::Formatter::Detailed->new();

    # by default, the handle will set its formatter to
    # Log::Fine::Formatter::Basic.  If that's not what you want, set
    # it to preference.
    $handle->setFormatter($formatter);

    # You can also adjust the timestamp in the log message to your own
    # strftime(3) compatible string without having to write your own
    # formatter.  By default, the timestamp format is "%c"

    # YYYY-MM-DD HH:MM:SS
    $formatter->{"%Y-%m-%d %H:%M:%S"};

=head1 DESCRIPTION

Base class for all formatters.  This class should not be instantiated
directly.

=cut

use strict;
use warnings;

package Log::Fine::Formatter;

use base qw( Log::Fine );

use Carp;

# Constant: LOG_TIMESTAMP_FORMAT
#
# strftime(3)-compatible format string
use constant LOG_TIMESTAMP_FORMAT => "%c";

# --------------------------------------------------------------------

##
# Initializer for this object

sub _init
{

        my $self = shift;

        # perform super initializations
        $self->SUPER::_init();

        # make sure we load in the logger object
        require Log::Fine::Logger;

        # set timestamp_format to the default if necessary
        $self->{timestamp_format} = LOG_TIMESTAMP_FORMAT
                unless (defined $self->{timestamp_format}
                        and $self->{timestamp_format} =~ /\w+/);

        return $self;

}          # _init()

=head1 SEE ALSO

L<perl>, L<strftime>, L<Log::Fine>

=head1 AUTHOR

Christopher M. Fuhrman, C<< <cfuhrman at panix.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-log-fine-record at rt.cpan.org>, or through the web interface at
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

1;          # End of Log::Fine::Formatter

