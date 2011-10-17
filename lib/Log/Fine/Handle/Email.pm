
=head1 NAME

Log::Fine::Handle::Email - Email log messages to one or more addresses

=head1 SYNOPSIS

Provides messaging to one or more email addresses.

    use Email::Sender::Simple qw(sendmail);
    use Email::Sender::Transport::SMTP qw();
    use Log::Fine;
    use Log::Fine::Handle::Email;
    use Log::Fine::Levels::Syslog;

    # Get a new logger
    my $log = Log::Fine->logger("foo");

    # Create a formatter object for subject line
    my $subjfmt = Log::Fine::Formatter::Template
        ->new( name     => 'template1',
               template => '%%LEVEL%% : The angels have my blue box" );

    # Create a formatted msg template
    my $msgtmpl = <<EOF
    The program, $0, has encountered the following error condition:

    %%MSG%% at %%TIME%%

    Contact Operations at 1-800-555-5555 immediately!
EOF;

    my $bodyfmt = Log::Fine::Formatter::Template
        ->new( name     => 'template2',
               template => $msgtmpl );

    # Define an optional transport

    # register an email handle
    my $handle = Log::Fine::Handle::Email
        ->new( name => 'email0',
               mask => LOGMASK_EMERG | LOGMASK_ALERT | LOGMASK_CRIT,
               subject_formatter => $subjfmt,
               body_formatter => $bodyfmt,
               transport => Email::Sender::Transport::SMTP->new({
                   host => smtp.example.com,
                   port => 25,
                }),
               email_from => "alerts@example.com",
               email_to => [ "critical_alerts@example.com" ],
             );

    # register the handle
    $log->registerHandle($handle);

    # log something
    $log->(CRIT, "Beware the weeping angels");

=head1 DESCRIPTION

Log::Fine::Handle::Email provides formatted message delivery to one or
more email addresses.  The intended use is for programs that need to
alert a user in the event of a critical condition.  Conceivably, the
destination address could be a pager or cell phone.

=head2 Implementation Details

Log::Fine::Handle::Email uses the L<Email::Sender> framework for
delivery of emails.  Users who wish to use Log::Fine::Handle::Email
are I<strongly> encouraged to read the following documentation:

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

=head2 Constructor Parameters

The following parameters can be passed to
Log::Fine::Handle::Email->new();

=over

=item  * name

[optional] Name of this object (see L<Log::Fine>).  Will be autoset if
not specified.

=item  * mask

Mask to set the handle to (see L<Log::Fine::Handle>)

=item  * subj_formatter

A Log::Fine::Formatter object.  This template will be used to format
the Email Subject Line.

=item  * body_formatter

A Log::Fine::Formatter object.  This template will be used to format
the body of the message.

=item  * from

The person sending the email.  Will default to the current user at
current host.

=item  * to

The intended destination.  Note this value is passed directly to
Email::Sender::Simple->create() and can be either a string or an array
ref containing one or more email addresses.

=item  * transport

[optional] An L<Email::Sender::Transport> object.  See
L<Email::Sender::Manual> for further details.

=back

=cut

use strict;
use warnings;

package Log::Fine::Handle::Email;

use base qw( Log::Fine::Handle );

#use Email::Sender::Simple qw(sendmail);
#use Email::Simple;
use Mail::RFC822::Address qw(valid validlist);
use Log::Fine;
use Sys::Hostname;

our $VERSION = $Log::Fine::Handle::VERSION;

=head1 METHODS

=head2 msgWrite

See L<Log::Fine::Handle/msgWrite>

=cut

sub msgWrite
{

        my $self = shift;
        my $lvl  = shift;
        my $msg  = shift;
        my $skip = shift;

        my $email =
            Email::Simple->create(
                  header => [
                         To      => $self->{email_to},
                         From    => $self->{email_from},
                         Subject => $self->{formatter}->format($lvl, "", $skip),
                  ],
                  body => $self->{formatter}->format($lvl, $msg, $skip),
            );

        sendmail($email);

}          # msgWrite()

# --------------------------------------------------------------------

##
# Initializes our object

sub _init
{

        my $self = shift;

        # call the super object
        $self->SUPER::_init();

        # verify that we can load the Email::Sender Module
        eval "require Email::Sender::Simple qw(sendmail)";
        $self->_fatal(
"Email::Sender failed to load.  Please install Email::Sender via CPAN : $@"
        ) if $@;

        # verify that we can load the Email::Simple Module
        eval "require Email::Simple";
        $self->_fatal(
"Email::Simple failed to load.  Please install Email::Simple via CPAN : $@"
        ) if $@;

        # Validate To address
        $self->_fatal("Invalid destination email address : $self->{email_to}")
            unless (
                  defined $self->{email_to}
                  and (($self->{email_to} =~ /\w/ and valid($self->{email_to}))
                       or (ref $self->{email_to} eq "ARRAY"
                           and validlist(join(", ", @{ $self->{email_to} })))));

        # Validate From address
        unless (    defined $self->{email_from}
                and $self->{email_from} eq /\w/
                and valid($self->{email_from})) {
                $self->{email_from} =
                    printf("%s@%s", $self->_userName(), $self->_hostName());
        }

        # Validate Transport
        $self->_fatal("Invalid Transport Object")
            if (defined $self->{transport}
                and !$self->{transport}->isa("Email::Sender::Transport"));

        # Validate subject formatter
        $self->_fatal(
"{subject_formatter} must be a valid Log::Fine::Formatter object")
            unless (defined $self->{subject_formatter}
                   and $self->{subject_formatter}->isa("Log::Fine::Formatter"));

        # Validate body formatter
        $self->_fatal(
                 "{body_formatter} must be a valid Log::Fine::Formatter object")
            unless (defined $self->{body_formatter}
                    and $self->{body_formatter}->isa("Log::Fine::Formatter"));

        return $self;

}
          # _init()

##
# Getter/Setter for hostname

sub _hostName
{

        my $self = shift;

        # If {_fullHost} is already cached, then return it, otherwise
        # get hostname, cache it, and return
        if (defined $self->{_fullHost} and $self->{_fullHost} =~ /\w/) {
                return $self->{_fullHost};
        } else {
                $self->{_fullHost} = hostname() || "{undef}";
                return $self->{_fullHost};
        }

        #
        # NOT REACHED
        #

}          # _hostName()

##
# Getter/Setter for user name

sub _userName
{

        my $self = shift;

        # If {_userName} is already cached, then return it, otherwise get
        # the user name, cache it, and return
        if (defined $self->{_userName} and $self->{_userName} =~ /\w/) {
                return $self->{_userName};
        } elsif ($self->{use_effective_id}) {
                $self->{_userName} =
                    ($^O eq "MSWin32")
                    ? $ENV{EUID}   || 0
                    : getpwuid($>) || "nobody";
        } else {
                $self->{_userName} = getlogin() || getpwuid($<) || "nobody";
        }

        return $self->{_userName};

}          # _userName()

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

L<perl>, L<Log::Fine>, L<Log::Fine::Handle>

=head1 COPYRIGHT & LICENSE

Copyright (c) 2011 Christopher M. Fuhrman, 
All rights reserved.

This program is free software licensed under the...

	The BSD License

The full text of the license can be found in the
LICENSE email included with this module.

=cut

1;          # End of Log::Fine::Handle::Email
