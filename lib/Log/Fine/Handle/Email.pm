
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

    # register an email handle
    my $handle = Log::Fine::Handle::Email
        ->new( name => 'email0',
               mask => LOGMASK_EMERG | LOGMASK_ALERT | LOGMASK_CRIT,
               subject_formatter => $subjfmt,
               body_formatter    => $bodyfmt,
               header_from       => "alerts@example.com",
               header_to         => [ "critical_alerts@example.com" ],
               envelope          =>
                 { to   => [ "critical_alerts@example.com" ],
                   from => "alerts@example.com",
                   transport =>
                     Email::Sender::Transport::SMTP->new({ host => 'smtp.example.com' }),
                 }
             );

    # register the handle
    $log->registerHandle($handle);

    # log something
    $log->log(CRIT, "Beware the weeping angels");

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

[optional] Name of this object (see L<Log::Fine>).  Will be auto-set if
not specified.

=item  * mask

Mask to set the handle to (see L<Log::Fine::Handle>)

=item  * subject_formatter

A Log::Fine::Formatter object.  Will be used to format the Email
Subject Line.

=item  * body_formatter

A Log::Fine::Formatter object.  Will be used to format the body of the
message.

=item  * header_from

String containing text to be placed in "From" header of generated
email.

=item  * header_to

String containing text to be placed in "To" header of generated email.

=item  * envelope

[optional] hash ref containing envelope information for email:

=over 8

=item  + to

array ref containing one or more destination addresses

=item  + from

String containing email sender

=item  * transport

An L<Email::Sender::Transport> object.  See L<Email::Sender::Manual>
for further details.

=back

=back

=cut

use strict;
use warnings;

package Log::Fine::Handle::Email;

use base qw( Log::Fine::Handle );

#use Data::Dumper;
use Email::Sender::Simple qw(sendmail);
use Email::Simple;
use Mail::RFC822::Address qw(valid validlist);
use Log::Fine;
use Log::Fine::Formatter;
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
                        To   => $self->{header_to},
                        From => $self->{header_from},
                        Subject =>
                            $self->{subject_formatter}->format($lvl, "", $skip),
                 ],
                 body => $self->{body_formatter}->format($lvl, $msg, $skip),
            );

        sendmail($email, $self->{envelope});

}          # msgWrite()

# --------------------------------------------------------------------

##
# Initializes our object

sub _init
{

        my $self = shift;

        # call the super object
        $self->SUPER::_init();

        # Make sure envelope is defined
        $self->{envelope} ||= {};

        # Validate From address
        if (not defined $self->{header_from}) {
                $self->{header_from} =
                    printf("%s@%s", $self->_userName(), $self->_hostName());
        } elsif (defined $self->{header_from}
                 and not valid($self->{header_from})) {
                $self->_fatal(
                         "{header_from} must be a valid RFC 822 Email Address");
        }

        # Validate To address
        $self->_fatal("{header_to} must be a valid RFC 822 Email Address")
            unless (    defined $self->{header_to}
                    and $self->{header_to} =~ /\w/
                    and valid($self->{header_to}));

        # Check envelope
        $self->_fatal("{envelope} must be a valid hash ref")
            unless (defined $self->{envelope}
                    and ref $self->{envelope} eq "HASH");

        # Grab a ref to envelope
        my $envelope = $self->{envelope};

        # Check Envelope Transport
        if (defined $envelope->{transport}) {
                my $transtype = ref $envelope->{transport};
                $self->_fatal(
"{envelope}->{transport} must be a valid Email::Sender::Transport object : $transtype"
                ) unless ($transtype =~ /^Email\:\:Sender\:\:Transport/);
        }

        # Check Envelope To
        if (defined $envelope->{to}) {
                $self->_fatal(
"{envelope}->{to} must be an array ref containing one or more valid RFC 822 email addresses"
                    )
                    unless (ref $envelope->{to} eq "ARRAY"
                            and validlist($envelope->{to}));
        }

        if (defined $envelope->{from}) {
                $self->_fatal(
"{envelope}->{from} must be a valid RFC 822 Email Address"
                ) unless valid($envelope->{from});
        }

        # Validate subject formatter
        $self->_fatal(
"{subject_formatter} must be a valid Log::Fine::Formatter object")
            unless (defined $self->{subject_formatter}
                   and $self->{subject_formatter}->isa("Log::Fine::Formatter"));

        # Validate body formatter
        $self->_fatal(
"{body_formatter} must be a valid Log::Fine::Formatter object : "
                    . ref $self->{body_formatter} || "{undef}")
            unless (defined $self->{body_formatter}
                    and $self->{body_formatter}->isa("Log::Fine::Formatter"));

        return $self;

}          # _init()

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
LICENSE file included with this module.

=cut

1;          # End of Log::Fine::Handle::Email