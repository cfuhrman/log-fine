
=head1 NAME

Log::Fine::Handle::Output - Output messages to C<STDERR> or C<STDOUT>

=head1 SYNOPSIS

Provides logging to either C<STDERR> or C<STDOUT>.

    # Get a new logger
    my $log = Log::Fine->getLogger("foo");

    # register a file handle
    my $handle = Log::Fine::Handle::Output
        ->new( name => 'myname',
               mask => LOGMASK_EMERG | LOGMASK_ALERT | LOGMASK_CRIT | LOGMASK_ERR | LOGMASK_WARNING | LOGMASK_NOTICE | LOGMASK_INFO,
               use_stderr => undef );

    # you can set logging to STDERR per preference
    $handle->{use_stderr} = 1;

    # register the handle
    $log->registerHandle($handle);

    # log something
    $log->(INFO, "Opened new log handle");

=cut

use strict;
use warnings;

package Log::Fine::Handle::Output;

use base qw( Log::Fine::Handle );

our $VERSION = '0.01';

=head1 METHODS

=head2 msgWrite($lvl, $msg, $skip)

See L<Log::Fine::Handle>

=cut

sub msgWrite
{

        my $self = shift;
        my $lvl  = shift;
        my $msg  = shift;
        my $skip = shift;

        # if we have a formatter defined, then use that, otherwise, just
        # print the raw message
        $msg = $self->{formatter}->format($lvl, $msg, $skip)
                if defined $self->{formatter};

        # where do we send the message to?
        if (defined $self->{use_stderr}) {
                print STDERR $msg;
        } else {
                print STDOUT $msg;
        }

        # Victory!
        return $self;

}          # msgWrite()

# --------------------------------------------------------------------

##
# Initializes our object

sub _init
{

        my $self = shift;

        # call the super object
        $self->SUPER::_init();

        # by default, we print messages to STDOUT
        $self->{use_stderr} = undef
                unless (exists $self->{use_stderr});

        # Victory!
        return $self;

}          # _init()

=head1 SEE ALSO

L<perl>, L<Log::Fine::Handle>

=head1 AUTHOR

Christopher M. Fuhrman, C<< <cfuhrman at panix.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-log-fine-handle-output at rt.cpan.org>, or through the web interface at
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

1;          # End of Log::Fine::Handle::Output
