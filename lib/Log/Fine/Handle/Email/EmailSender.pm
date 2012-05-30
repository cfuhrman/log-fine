
=head1 NAME

Log::Fine::Handle::Email::EmailSender - Email log messages using Email::Sender

=head1 SYNOPSIS

Provides messaging to one or more email addresses via the
L<Email::Sender> module.

    use Log::Fine;
    use Log::Fine::Formatter::Template;
    use Log::Fine::Handle::Email;
    use Log::Fine::Levels::Syslog qw( :macros :masks );

    # Get a new logger
    my $log = Log::Fine->logger("foo");

    # Create a formatter object for subject line
    my $subjfmt = Log::Fine::Formatter::Template
        ->new( name     => 'template1',
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

    # Define an optional transport
    my $transport = Email::Sender::Transport::SMTP->new({
      host => 'smtp.example.com',
      port => 2525,
    });

    # register an email handle
    my $handle = Log::Fine::Handle::Email
        ->new( name => 'email0',
               mask => LOGMASK_EMERG | LOGMASK_ALERT | LOGMASK_CRIT,
               subject_formatter => $subjfmt,
               body_formatter    => $bodyfmt,
               header_from       => "alerts@example.com",
               header_to         => "critical_alerts@example.com",
               email_handle      => "EmailSender",  # <-- default value
               envelope          => {
                   to        => [ "critical_alerts@example.com",
                                  "chris@example.com",
                                  "joe@example.com"],
                   from      => "alerts@example.com",
                   transport => $transport,
               }
             );

    # register the handle
    $log->registerHandle($handle);

    # log something
    $log->log(CRIT, "Beware the weeping angels");

=head1 DESCRIPTION

Log::Fine::Handle::Email::EmailSender provides formatted message
delivery to one or more email addresses via the L<Email::Sender>
module.  Users who wish to use this module are I<strongly> encouraged
to read the following documentation:

=over

=item  * L<Email::Sender::Manual>

=item  * L<Email::Sender::Manual::Quickstart>

=item  * L<Email::Sender::Simple>

=back

Be especially mindful of the following environment variables as they
will take precedence when defining a transport:

=over

=item  * C<EMAIL_SENDER_TRANSPORT>

=item  * C<EMAIL_SENDER_TRANSPORT_host>

=item  * C<EMAIL_SENDER_TRANSPORT_port>

=back

See L<Email::Sender::Manual::Quickstart> for further details.

=cut

use strict;
use warnings;

package Log::Fine::Handle::Email::EmailSender;

use 5.008_003; # Email::Sender requires Moose which requires perl
               # v5.8.3

use base qw( Log::Fine::Handle::Email );

use Email::Sender::Simple qw(sendmail);
use Email::Simple;
use Try::Tiny;

our $VERSION = $Log::Fine::Handle::Email::VERSION;


=head1 METHODS

=head2 new

Constructor for this method

=head3 Parameters

In addition to the hash parameters specified in
L<Log::Fine::Handle::Email/msgWrite>, this class accepts the following
keys:

=over

=item  * envelope

[optional] hash ref containing envelope information for email:

=over 8

=item  + to

array ref containing one or more destination addresses

=item  + from

String containing email sender

=item  * transport

[optional] An L<Email::Sender::Transport> object.  See
L<Email::Sender::Manual> for further details.

=back

=back

=cut

sub new
{

        my $class = shift;
        my %params = @_;

        my $self = bless \%params, $class;

        return $self->_init();

} # new()

=head2 msgWrite

Sends given message via Email::Sender module.  Note that
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

        # Construct email object
        my $email =
            Email::Simple->create(
                 header => [
                        To   => $self->{header_to},
                        From => $self->{header_from},
                        Subject =>
                            $self->{subject_formatter}->format($lvl, "", $skip),
                 ],
                 body => $self->{body_formatter}->format($lvl, $msg, $skip),
            );

        # Set X-Mailer
        $email->header_set("X-Mailer",
                           sprintf("%s ver %s", ref $self, $VERSION));

        # And send!
        try {
                sendmail($email, $self->{envelope});
        }
        catch {
                $self->_fatal("Unable to deliver email: $_");
        }

} # msgWrite()

# --------------------------------------------------------------------

##
# Initializes our object

sub _init
{

        my $self = shift;

        # call the super object
        $self->SUPER::_init();

        my $envelope = $self->{envelope};

        # Check envelope transport
        if (defined $envelope->{transport} and not defined $ENV{EMAIL_SENDER_TRANSPORT}) {
                my $transtype = ref $envelope->{transport};

                $self->_fatal(
"{envelope}->{transport} must be a valid Email::Sender::Transport object : $transtype"
                ) unless ($transtype =~ /^Email\:\:Sender\:\:Transport/);
        }

        return $self;

} # _init()

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

1;          # End of Log::Fine::Handle::Email::EmailSender
