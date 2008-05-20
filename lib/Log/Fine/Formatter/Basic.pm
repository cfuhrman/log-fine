
=head1 NAME

Log::Fine::Formatter::Basic - Default logging formatter

=head1 SYNOPSIS

Formats log messages for output in a basic format, suitable for most
applications.

    use Log::Fine::Formatter::Basic;
    use Log::Fine::Handle::Console;

    # instantiate a handle
    my $handle = Log::Fine::Handle::Console->new();

    # instantiate a formatter
    my $formatter = Log::Fine::Formatter::Basic
        ->new( name             => 'basic0',
               timestamp_format => "%y-%m-%d %h:%m:%s" );

    # set the formatter
    $handle->setFormatter( formatter => $formatter );

=head1 DESCRIPTION

The basic formatter provides logging in the following format:

    <[TIMESTAMP] <LEVEL> <MESSAGE>>

Please note that this is the default format.

=cut

use strict;
use warnings;

package Log::Fine::Formatter::Basic;

use base qw( Log::Fine::Formatter );

use Log::Fine;
use Log::Fine::Formatter;
use POSIX qw( strftime );

=head1 METHODS

=head2 format($lvl, $msg, $skip)

Returns the formatted message as follows:

  [TIMESTAMP] LEVEL MESSAGE

=cut

sub format
{

        my $self = shift;
        my $lvl  = shift;
        my $msg  = shift;
        my $skip = shift;                         # NOT USED
        my $lvls = Log::Fine->LOG_LEVELS;

        # return the formatted string
        return
                sprintf("[%s] %-4s %s\n",
                        strftime($self->{timestamp_format}, localtime(time)),
                        $lvls->[$lvl], $msg);

}          # format()

=head1 SEE ALSO

L<perl>, L<Log::Fine::Formatter>

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

1;          # End of Log::Fine::Formatter::Basic
