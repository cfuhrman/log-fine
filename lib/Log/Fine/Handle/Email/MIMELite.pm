
=head1 NAME

Log::Fine::Handle::Email::MIMELite - Email log messages using MIME::Lite

=head1 SYNOPSIS

Provides messaging to one or more email addresses via the
L<MIME::Lite> module.

    use Log::Fine;
    use Log::Fine::Formatter::Template;
    use Log::Fine::Handle::Email;
    use Log::Fine::Levels::Syslog qw( :macros :masks );

    # Get a new logger
    my $log = Log::Fine->logger("foo");

    # Create a formatter object for subject line
    my $subjfmt = Log::Fine::Formatter::Template
        ->new( name     => 'template2',
               template => "%%LEVEL%% : The angels have my blue box" );

    # Create a formatted msg template
    my $msgtmpl = <<EOF;
    The program, $0, has encountered the following error condition:

    %%MSG%% at %%TIME%%

    Contact Operations at 1-800-555-5555 immediately!
    EOF

    my $bodyfmt = Log::Fine::Formatter::Template
        ->new( name     => 'template2',
               template => $msgtmpl );

    # register an email handle
    my $handle = Log::Fine::Handle::Email
        ->new( name => 'email0',
               mask => LOGMASK_EMERG | LOGMASK_ALERT | LOGMASK_CRIT,
               subject_formatter => $subjfmt,
               body_formatter    => $bodyfmt,
               header_from       => 'alerts@example.com',
               header_to         => 'critical_alerts@example.com',
               email_handle      => 'EmailSender',  # <-- default value
               envelope          => {
                   to        => [ 'critical_alerts@example.com',
                                  'chris@example.com',
                                  'joe@example.com'],
                   from      => 'alerts@example.com',
               }
             );

    # register the handle
    $log->registerHandle($handle);

    # log something
    $log->log(CRIT, "Beware the weeping angels");

=head1 DESCRIPTION

Log::Fine::Handle::Email::MIMELite provides formatted message delivery
to one or more email addresses via the L<MIME::Lite> module and is
intended for situations where the default L<Email::Sender> module is
not appropriate (such as older versions of perl).

Persons who wish to use this module are I<strong> encouraged to read
the L<MIME::Lite> documentation!

=cut

use strict;
use warnings;

package Log::Fine::Handle::Email::MIMELite;

use base qw( Log::Fine::Handle::Email );

#use Data::Dumper;
use MIME::Lite;

our $VERSION = $Log::Fine::Handle::Email::VERSION;

=head1 METHODS

=head2 new

Constructor for this method

=head3 Parameters

In addition to the hash parameters specified in
L<Log::Fine::Handle::Email/msgWrite>, this class accepts the following
keys:

All parameters below are passed in the envelope hash key unless
otherwise specified.

=over

=item  * method

The method by which the email will be sent.  Valid options include
'sendmail' (default) and 'smtp'.  See L<MIME::Lite> documentation for
further details.

=item  * options

Array ref containing options specific to the above method

=back

=cut

sub new
{

        my $class  = shift;
        my %params = @_;

        my $self = bless \%params, $class;

        return $self->_init();

}          # new()

=head2 msgWrite

Sends given email message via MIME::Lite module.  Note that
L<Log::Fine/_fatal> will be called should there be a failure of
delivery.

See also L<Log::Fine::Handle/msgWrite>

=cut

sub msgWrite
{

        my $self = shift;
        my $lvl  = shift;
        my $msg  = shift;
        my $skip = shift;

        my $mimeobj = MIME::Lite->new(
                 From    => $self->{header_from},
                 To      => $self->{header_to},
                 Subject => $self->{subject_formatter}->format($lvl, "", $skip),
                 Data    => $self->{body_formatter}->format($lvl, $msg, $skip),
                 'X-Mailer' => sprintf("%s ver %s", ref $self, $VERSION),
        );

        if (defined $self->{envelope}->{method}) {
                $mimeobj->send($self->{envelope}->{method},
                               @{ $self->{envelope}->{options} });
        } else {
                $mimeobj->send();
        }

}          # msgWrite()

# --------------------------------------------------------------------

##
# Initializes our object

sub _init
{

        my $self = shift;

        # call the super object
        $self->SUPER::_init();

        my $envelope = $self->{envelope};
        my $options = $self->{envelope}->{options} || [];

        if (defined $envelope->{method}) {

                $self->_fatal(
                        "{envelope}->{method} must be a valid MIME::Lite method"
                ) if ($envelope->{method} !~ /\w/);
                $self->_fatal("{envelope}->{options} must be a valid array ref")
                    if (defined $options and ref $options ne "ARRAY");
                $self->{envelope}->{options} = $options;

        }

        return $self;

}          # _init()

=head1 BUGS

Please report any bugs or feature requests to
C<bug-log-fine-handle-email at rt.cpan.org>, or through the web interface at
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

=head1 AUTHOR

Christopher M. Fuhrman, C<< <cfuhrman at panix.com> >>

=head1 SEE ALSO

L<perl>, L<Log::Fine>, L<Log::Fine::Handle>,
L<Log::Fine::Handle::Email>, L<Mail::RFC822::Address>

=head1 COPYRIGHT & LICENSE

Copyright (c) 2012 Christopher M. Fuhrman, 
All rights reserved.

This program is free software licensed under the...

	The BSD License

The full text of the license can be found in the
LICENSE file included with this module.

=cut

1;          # End of Log::Fine::Handle::Email::MIMELite
