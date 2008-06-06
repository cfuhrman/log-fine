
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

    # set the time-stamp to "YYYY-MM-DD HH:MM:SS"
    $formatter->setTimestamp("%Y-%m-%d %H:%M:%S");

=head1 DESCRIPTION

Base ancestral class for all formatters.  All customized formatters
must inherit from this class.  The formatter class allows developers
to adjust the time-stamp in a log message to a customizable
strftime-compatible string without the tedious mucking about writing a
formatter sub-class.  By default, the time-stamp format is "%c".  See
L</"setTimestamp($format)"> and the L<strftime> man page for further
details.

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

        croak "someone used an (abstract) Formatter object"
            if $class eq 'Log::Fine::Formatter';

        croak "call to abstract method ${class}::format()";

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

        # set {timestamp_format} to the default if necessary
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

