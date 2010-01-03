
=head1 NAME

Log::Fine::Formatter - Log message formatting and sanitization

=head1 SYNOPSIS

Provides a formatting facility for log messages

    use Log::Fine::Handle;
    use Log::Fine::Formatter;

    my $handle    = Log::Fine::Handle::Console->new();
    my $formatter = Log::Fine::Formatter::Detailed->new(
      timestamp_format => "%Y-%m-%d %H:%M:%S"
    );

    # by default, the handle will set its formatter to
    # Log::Fine::Formatter::Basic.  If that's not what you want, set
    # it to preference.
    $handle->formatter($formatter);

    # set the time-stamp to "YYYY-MM-DD HH:MM:SS"
    $formatter->timeStamp("%Y-%m-%d %H:%M:%S");

    # high resolution timestamps with milliseconds are
    # supported thus:
    my $hires_formatter =
      Log::Fine::Formatter::Basic->new(
        hires => 1,
        timestamp_format => "%H:%M:%S.%%millis%%",
      );

=head1 DESCRIPTION

Base ancestral class for all formatters.  All customized formatters
must inherit from this class.  The formatter class allows developers
to adjust the time-stamp in a log message to a customizable
strftime-compatible string without the tedious mucking about writing a
formatter sub-class.  By default, the time-stamp format is "%c".  See
L</timeStamp> and the L<strftime(3)> man page on your system for
further details.

=head2 High Resolution Timestamps

High Resolution time stamps are generated using the L<Time::HiRes>
module.  Depending on your distribution of perl, this may or may not
be installed.  Add the string "%%millis%%" (without the quotes) where
you would like milliseconds displayed within your format.  For example:

    $formatter->timeStamp("%H:%M:%S.%%millis%%");

Please note you I<must> enable high resolution mode during Formatter
construction as so:

    my $formatter = Log::Fine::Formatter::Basic->new( hires => 1 );

By default, the time-stamp format for high resolution mode is
"%H:%M:%S.%%millis%%".  This can be changed via the L</timeStamp>
method or set during formatter construction.

=cut

use strict;
use warnings;

package Log::Fine::Formatter;

use base qw( Log::Fine );

use POSIX qw( strftime );

# Constant: LOG_TIMESTAMP_FORMAT, LOG_TIMESTAMP_FORMAT_PRECISE
#
# strftime(3)-compatible format string
use constant LOG_TIMESTAMP_FORMAT         => "%c";
use constant LOG_TIMESTAMP_FORMAT_PRECISE => "%H:%M:%S.%%millis%%";

=head1 METHODS

=head2 format

Returns the formatted message.  B<Must> be sub-classed!

=head3 Returns

The formatted string

=cut

sub format
{

        my $self  = shift;
        my $class = ref $self;

        $self->_fatal("direct call to abstract method format()!")
            if $class eq 'Log::Fine::Formatter';

        $self->_fatal("call to abstract method ${class}::format()");

}          # format()

=head2 testFormat

Special method used for unit tests only.
I<Not for use in production environments!>

=head3 Parameters

=over

=item  * level

Level at which to log

=item  * message

Message to log

=back

=head3 Returns

The formatted string

=cut

sub testFormat
{

        my $self = shift;
        my $lvl  = shift;
        my $msg  = shift;

        return $self->format($lvl, $msg, 0);

}          # testFormat()

=head2 timeStamp

Getter/Setter for a L<strftime(3)-compatible|strftime> format string.
If passed with an argument, sets the objects strftime compatible
string.  Otherwise, returns the object's format string.

=head3 Parameters

=over

=item  * string

[optional] L<strftime(3)> compatible string to set

=back

=head3 Returns

L<strftime(3)> compatible string

=cut

sub timeStamp
{

        my $self = shift;
        my $str  = shift;

        $self->{timestamp_format} = $str
            if (defined $str);

        return $self->{timestamp_format};

}          # timeStamp()

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

        # verify that we can load the Time::HiRes module
        if ($self->{hires}) {

                eval "use Time::HiRes";
                $self->_fatal(
"Time::HiRes failed to load.  Please install Time::HiRes via CPAN"
                ) if $@;

                # set {timestamp_format} to default high precision
                # format if necessary.
                $self->{timestamp_format} = LOG_TIMESTAMP_FORMAT_PRECISE
                    unless (defined $self->{timestamp_format}
                            and $self->{timestamp_format} =~ /\w+/);

        } else {

                # set {timestamp_format} to the default if necessary
                $self->{timestamp_format} = LOG_TIMESTAMP_FORMAT
                    unless (defined $self->{timestamp_format}
                            and $self->{timestamp_format} =~ /\w+/);

        }

        # Victory!
        return $self;

}          # _init()

##
# Formats the time string returned

sub _formatTime
{
        my $seconds;

        my $self = shift;
        my $fmt  = $self->{timestamp_format};

        if ($self->{hires}) {

                # use Time::HiRes to get seconds and milliseconds
                my $time = sprintf("%.05f", &Time::HiRes::time);
                my @t = split /\./, $time;

                # and format
                $fmt =~ s/%%millis%%/$t[1]/g;
                $seconds = $time;

        } else {
                $seconds = time;
        }

        # return the formatted time
        return strftime($fmt, localtime($seconds));

}          # _formatTime()

=head1 SEE ALSO

L<perl>, L<strftime>, L<Log::Fine>, L<Time::HiRes>

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

Copyright (c) 2008, 2009, 2010 Christopher M. Fuhrman, 
All rights reserved.

This program is free software licensed under the...

	The BSD License

The full text of the license can be found in the
LICENSE file included with this module.

=cut

1;          # End of Log::Fine::Formatter

