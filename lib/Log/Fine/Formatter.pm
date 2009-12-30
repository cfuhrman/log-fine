
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
    $handle->setFormatter($formatter);

    # set the time-stamp to "YYYY-MM-DD HH:MM:SS"
    $formatter->setTimestamp("%Y-%m-%d %H:%M:%S");

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
L</"setTimestamp($format)"> and the L<strftime> man page for further
details.

=head2 High Resolution Timestamps

High Resolution time stamps are generated using the L<Time::HiRes>
module.  Depending on your distribution of perl, this may or may not
be installed.  Add the string "%%millis%%" (without the quotes) where
you would like milliseconds displayed within your format.  For example:

    $formatter->setTimestamp("%H:%M:%S.%%millis%%");

Please note you I<must> enable high resolution mode during Formatter
construction as so:

    my $formatter = Log::Fine::Formatter::Basic->new( hires => 1 );

By default, the time-stamp format for high resolution mode is
"%H:%M:%S.%%millis%%".  This can be changed via the
L</"setTimestamp($format)"> method or set during formatter
construction.

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

=head2 getTimestamp()

Returns the current L<strftime(3)-compatible|strftime> format string for
timestamped log messages

=cut

sub getTimestamp
{
        my $self = shift;
        return $self->{timestamp_format};
}          # getTimeStamp

=head2 format($lvl, $msg, $skip)

Returns the formatted message.  B<Must> be sub-classed!

=cut

sub format
{

        my $self  = shift;
        my $class = ref $self;

        $self->_fatal("someone used an (abstract) Formatter object")
            if $class eq 'Log::Fine::Formatter';

        $self->_fatal("call to abstract method ${class}::format()");

}          # format()

=head2 setTimestamp($format)

Sets the time-stamp format to the given L<strftime(3)-compatible|strftime>
string.

=cut

sub setTimestamp
{
        my $self = shift;
        $self->{timestamp_format} = shift;
}          # setTimestamp;

=head2 testFormat($lvl, $msg)

For testing purposes only

=cut

sub testFormat
{

        my $self = shift;
        my $lvl  = shift;
        my $msg  = shift;
        my $log  = $self->format($lvl, $msg, 0);

        return $log;

}          # testFormat()

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

sub _getFmtTime
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

}          # _getFmtTime()

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

Copyright (c) 2008, 2009 Christopher M. Fuhrman, 
All rights reserved.

This program is free software licensed under the...

	The BSD License

The full text of the license can be found in the
LICENSE file included with this module.

=cut

1;          # End of Log::Fine::Formatter

