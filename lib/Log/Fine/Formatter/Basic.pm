
=head1 NAME

Log::BSDLog::Formatter::Basic - Default logging formatter

=head1 SYNOPSIS

Formats log messages for output in a basic format, suitable for most
applications.

    use Log::BSDLog;
    use Log::BSDLog::Formatter::Basic;
    use Log::BSDLog::Handle::Output;
    use Log::BSDLog::Logger;

    # Create log object, logger
    ...

    my $formatter = Log::BSDLog::Formatter::Basic->new();

    my $handle = Log::BSDLog::Handle::Output->new( {
                                                      formatter => $formatter,
                                                      ...
                                                    })

    $logger->registerHandle($handle);

    $logger->log(DEBG, "Test log message");

=head1 DESCRIPTION

The basic formatter provides logging in the following format:

    C<[TIMESTAMP] <LEVEL> <MESSAGE>]>

=cut

use strict;
use warnings;

package Log::BSDLog::Formatter::Basic;

use base qw( Log::BSDLog::Formatter );

use Log::BSDLog;
use Log::BSDLog::Formatter;
use POSIX qw( strftime );

our $VERSION = '0.01';

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
        my $skip = shift;                           # NOT USED
        my $lvls = Log::BSDLog->LOG_LEVELS;

        # return the formatted string
        return
                sprintf("[%s] %-4s %s\n",
                        strftime($self->{timestamp_format}, localtime(time)),
                        $lvls->[$lvl], $msg);

}          # format()

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

1;          # End of Log::BSDLog::Formatter::Basic
