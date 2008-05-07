
=head1 NAME

Log::BSDLog::Handle - Controls where to send logging output

=head1 SYNOPSIS

A handle controls I<where> to send formatted log messages.  The
destination can be a file, syslog, a database table, or simply to
output.

    use Log::BSDLog::Handle;

    my $foo = Log::BSDLog::Handle->new();
    ...

=cut

use strict;
use warnings;

package Log::BSDLog::Handle;

use base qw( Log::BSDLog );

use Carp;
use Log::BSDLog qw( :macros :masks );
use Log::BSDLog::Formatter::Basic;

our $VERSION = '0.01';

# Constant: DEFAULT_LOG_MASK
#
# Default log mask.  Basically everything
use constant DEFAULT_LOGMASK => LOGMASK_EMERG | LOGMASK_ALERT | LOGMASK_CRIT |
        LOGMASK_ERR | LOGMASK_WARNING | LOGMASK_NOTICE | LOGMASK_INFO |
        LOGMASK_DEBUG;

=head1 METHODS

=head2 getFormatter()

Returns the formatter for this object

=cut

sub getFormatter
{
        my $self = shift;

        return $self->{formatter};
}          # getFormatter()

=head2 isLoggable($lvl)

Specifies whether the handle is loggable at the given level.  Returns
1 if we can log, undef otherwise.

=cut

sub isLoggable
{

        my $self = shift;
        my $lvl  = shift;

        croak "No Level :$lvl\n"
                unless (defined $lvl and $lvl =~ /\d+/);

        # bitand the level and the mask to see if we're loggable
        return (($self->{mask} & $lvl) == $lvl) ? 1 : undef;

}          # isLoggable()

=head2 msgWrite($lvl, $msg, $skip)

Tells the handle to output the given log message.  The third
parameter, $skip, is passed to caller() for accurate method logging.

=cut

sub msgWrite
{

        my $self  = shift;
        my $class = ref $self;

        croak "someone used an (abstract) Handler object"
                if $class eq 'Log::BSDLog::Handle';

        croak "call to abstract method ${class}::msgWrite()";

}          # msgWrite()

=head2 setFormatter( <Log::BSDLog::Formatter> )

Sets the formatter for this object

=cut

sub setFormatter
{

        my $self      = shift;
        my $formatter = shift;

        # validate formatter
        croak "First argument must be a valid formatter object!\n"
                unless (defined $formatter
                        and $formatter->isa("Log::BSDLog::Formatter"));

        $self->{formatter} = $formatter;

}          # setFormatter()

# --------------------------------------------------------------------

##
# Initializes our object

sub _init
{

        my $self = shift;

        # set default bitmask
        $self->{mask} = DEFAULT_LOGMASK
                unless defined $self->{mask};

        # by default, set the level to DEBG
        $self->{level} = DEBG
                unless defined $self->{level};

        # set the default formatter
        $self->{formatter} = Log::BSDLog::Formatter::Basic->new()
                unless (defined $self->{formatter}
                        and $self->{formatter}->isa("Log::BSDLog::Formatter"));

        # Victory!
        return $self;

}          # _init()

=head1 AUTHOR

Christopher M. Fuhrman, C<< <cfuhrman at panix.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-log-bsdlog-handle at rt.cpan.org>, or through the web interface at
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

1;          # End of Log::BSDLog::Handle
