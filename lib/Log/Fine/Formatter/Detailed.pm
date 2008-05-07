
=head1 NAME

Log::BSDLog::Formatter::Detailed - Formatter for detailed logging

=head1 SYNOPSIS

Formats log messages for output in a detailed format.

    use Log::BSDLog;
    use Log::BSDLog::Formatter::Detailed;
    use Log::BSDLog::Handle::Output;
    use Log::BSDLog::Logger;

    # Create log object, logger
    ...

    my $formatter = Log::BSDLog::Formatter::Detailed->new();

    my $handle = Log::BSDLog::Handle::Output->new( {
                                                      formatter => $formatter,
                                                      ...
                                                    })

    $logger->registerHandle($handle);

    $logger->log(DEBG, "Test log message");

=head1 DESCRIPTION

The detailed formatter logs messages in two different formats,
depending on where the log message came from.

If the log message came from a particular class (e.g. C<MyModule.pm>)
the detailed formatter will format as follows:

    [TIMESTAMP] <LEVEL> (<Package>::Method():<Line Number>) <MESSAGE>

Otherwise, the formatter will return a slightly more basic format:

    [TIMESTAMP] <LEVEL> (<Script Name>:<Line Number>) <MESSAGE>

=cut

use strict;
use warnings;

package Log::BSDLog::Formatter::Detailed;

use base qw( Log::BSDLog::Formatter );

use File::Basename;
use Log::BSDLog;
use Log::BSDLog::Formatter;
use Log::BSDLog::Logger;
use POSIX qw( strftime );

our $VERSION = '0.01';

=head1 METHODS

=head2 format($lvl, $msg, $skip)

Returns the formatted message as follows:

  [TIMESTAMP] <LEVEL> (<Package>::Method():<Line Number>) <MESSAGE>

or

  [TIMESTAMP] <LEVEL> (<Script Name>:<Line Number>) <MESSAGE>

=cut

sub format
{

        my $self = shift;
        my $lvl  = shift;
        my $msg  = shift;
        my $skip = shift || Log::BSDLog::Logger->LOG_SKIP_DEFAULT;
        my $lvls = Log::BSDLog->LOG_LEVELS;

        # get the caller
        my @c = caller($skip);

        # did our call to caller() come up empty?
        if (scalar @c == 0) {

                # just include the script name
                return
                        sprintf("[%s] %-4s (%s) %s\n",
                                strftime($self->{timestamp_format},
                                         localtime(time)
                                ),
                                $lvls->[$lvl],
                                basename($0),
                                $msg
                        );

        } elsif (defined $c[0] and $c[0] eq "main") {

                # just include the script name and line number
                return
                        sprintf("[%s] %-4s (%s:%d) %s\n",
                                strftime($self->{timestamp_format},
                                         localtime(time)
                                ),
                                $lvls->[$lvl],
                                basename($c[1]),
                                $c[2],
                                $msg
                        );

        } else {

                # log package, subroutine, and line number
                return
                        sprintf("[%s] %-4s (%s():%d) %s\n",
                                strftime($self->{timestamp_format},
                                         localtime(time)
                                ),
                                $lvls->[$lvl],
                                $c[3] || "{undef}",
                                $c[2] || 0,
                                $msg
                        );

        }

        #
        # NOT REACHED
        #

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

1;          # End of Log::BSDLog::Formatter::Detailed
