
=head1 NAME

Log::Fine::Handle::Email - Email log messages to one or more addresses

=head1 SYNOPSIS

Provides messaging to one or more email addresses.

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

    # register an email handle
    my $handle = Log::Fine::Handle::Email
        ->new( name => 'email0',
               mask => LOGMASK_EMERG | LOGMASK_ALERT | LOGMASK_CRIT,
               subject_formatter => $subjfmt,
               body_formatter    => $bodyfmt,
               header_from       => 'Critical Alerts <alerts@example.com>',
               header_to         => 'critical_alerts@example.com',
               email_handle      => "EmailSender",       # <-- default value
               envelope          => {
                   from => 'alerts@example.com',
                   to   => ['critical_alerts@example.com',
                            'techoncall@example.com',
                            'techops@example.com'],
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

=head1 EMAIL INTERFACES

Up until Log::Fine v0.59, the L<Email::Sender> framework was used to
do the heavy lifting of delivery of emails.  While powerful and
configurable, the Email::Sender framework required a hefty number of
dependencies, some of which would not work on older versions of perl.
In addition, some vendors did not include Email::Sender in their
respective packaging systems, necessitating the use of CPAN.

As there are numerous modules relating to email delivery in CPAN,
Log::Fine::Handle::Email now makes use of "interface" classes which
can be used specify how email is delivered.  Currently, the following
classes are supported:

=over

=item  * L<Email::Sender>

=item  * L<MIME::Lite>

=back

To maintain backward-compatibility with previous releases,
Email::Sender is the default mechanism.

=head2 Subclassing

To sub-class this module, the following methods I<must> be provided:

=over

=item  * L</new>()

=item  * L</msgWrite>()

=back

See the documentation below as well as the included interface modules
for further details.

=cut

use strict;
use warnings;

package Log::Fine::Handle::Email;

use base qw( Log::Fine::Handle );

use Carp;

#use Data::Dumper;
use Mail::RFC822::Address qw(valid validlist);
use Log::Fine;
use Log::Fine::Formatter;
use Sys::Hostname;

our $VERSION = $Log::Fine::Handle::VERSION;

# Constants
# --------------------------------------------------------------------

use constant DEFAULT_EMAIL_HANDLE => 'EmailSender';

# --------------------------------------------------------------------

=head1 METHODS

=head2 new

Creates a new Log::Fine::Handle::Email subclass.  By default, this
will be a L<Log::Fine::Handle::Email::EmailSender> class.

When writing an interface for Log::Fine::Handle::Email, this method
I<must> be sub-classed!

=head3 Parameters

Parameters are passed in hash-style, and thus may be passed in any order:

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
Optionally, this can be an array ref containing multiple addresses

=item  * email_handle

Name of email_handle to use.  The following modules are available:

=over 8

=item  - L<Log::Fine::Handle::Email::EmailSender> (EmailSender)

Deliver email via the L<Email::Sender> module

=item  - L<Log::Fine::Handle::Email::MIMELite> (MIMELite)

Deliver email via the L<MIME::Lite> module

=back

By default L<Log::Fine::Handle::Email::EmailSender> will be used

=item  * envelope

[optional] hash ref containing envelope information for email:

=over 8

=item  - to

array ref containing one or more destination addresses

=item  - from

String containing email sender

=back

=back

Additional parameters will be documented in each individual subclass.

=cut

sub new
{

        my $class  = shift;
        my %params = @_;

        my $emailHandle =
            join("::", $class, $params{"email_handle"} || DEFAULT_EMAIL_HANDLE);

        # validate the sub module
        eval "require $emailHandle";

        # Do we have the class defined
        confess "Error : Email handle $emailHandle does not exist : $@"
            if $@;

        return $emailHandle->new(%params);

}          # new()

=head2 msgWrite

See L<Log::Fine::Handle/msgWrite>

=cut

#
# This space intentionally left blank as, by default, the SUPER method
# will be called
#

# --------------------------------------------------------------------

##
# Initializes our object

sub _init
{

        my $self = shift;

        # call the super object
        $self->SUPER::_init();

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
        $self->_fatal(  "{header_to} must be either an array ref containing "
                      . "valid email addresses or a string representing a "
                      . "valid email address")
            unless (defined $self->{header_to});

        # Check for array ref
        if (ref $self->{header_to} eq "ARRAY") {

                if (validlist($self->{header_to})) {
                        $self->{header_to} = join(",", @{ $self->{header_to} });
                } else {
                        $self->_fatal(
"{header_to} must contain valid RFC 822 email addresses");
                }

        } elsif (not valid($self->{header_to})) {
                $self->_fatal(
                        "{header_to} must contain a valid RFC 822 email address"
                );
        }

        # Validate subject formatter
        $self->_fatal(
"{subject_formatter} must be a valid Log::Fine::Formatter object")
            unless (   defined $self->{subject_formatter}
                   and ref $self->{subject_formatter}
                   and UNIVERSAL::can($self->{subject_formatter}, 'isa')
                   and $self->{subject_formatter}->isa("Log::Fine::Formatter"));

        # Validate body formatter
        $self->_fatal(
"{body_formatter} must be a valid Log::Fine::Formatter object : "
                    . ref $self->{body_formatter} || "{undef}")
            unless (    defined $self->{body_formatter}
                    and ref $self->{body_formatter}
                    and UNIVERSAL::can($self->{body_formatter}, 'isa')
                    and $self->{body_formatter}->isa("Log::Fine::Formatter"));

        # Grab a ref to envelope
        my $envelope = $self->{envelope} || {};

        # Check Envelope To
        if (defined $envelope->{to}) {
                $self->_fatal(
"{envelope}->{to} must be an array ref containing one or more valid RFC 822 email addresses"
                    )
                    unless (ref $envelope->{to} eq "ARRAY"
                            and validlist($envelope->{to}));
        } else {
                $envelope->{to} = [ $self->{header_to} ];
        }

        # Check envelope from
        if (defined $envelope->{from} and $envelope->{from} =~ /\w/) {
                $self->_fatal(
"{envelope}->{from} must be a valid RFC 822 Email Address"
                ) unless valid($envelope->{from});
        } else {
                $envelope->{from} = $self->{header_from};
        }

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

L<perl>, L<Log::Fine>, L<Log::Fine::Handle>, L<Mail::RFC822::Address>

=head1 COPYRIGHT & LICENSE

Copyright (c) 2011-2012 Christopher M. Fuhrman, 
All rights reserved.

This program is free software licensed under the...

	The BSD License

The full text of the license can be found in the
LICENSE file included with this module.

=cut

1;          # End of Log::Fine::Handle::Email
