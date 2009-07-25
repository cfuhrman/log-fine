use strict;
use warnings;

require Exporter;

package Log::Fine::Levels::Syslog;

use Carp;

#our $VERSION = sprintf("r%d", q$Rev$ =~ /\d+/);

use base qw/ Log::Fine::Levels /;

# Default level-to-value hash
use constant LVLTOVAL_MAP => {
                               EMER => 0,
                               ALRT => 1,
                               CRIT => 2,
                               ERR  => 3,
                               WARN => 4,
                               NOTI => 5,
                               INFO => 6,
                               DEBG => 7
};          # LVLTOVAL_MAP{}

# Default value-to-level hash
use constant VALTOLVL_MAP => {
                               0 => "EMER",
                               1 => "ALRT",
                               2 => "CRIT",
                               3 => "ERR",
                               4 => "WARN",
                               5 => "NOTI",
                               6 => "INFO",
                               7 => "DEBG"
};          # VALTOLVL_MAP{}

use constant MASK_MAP => {
                           LOGMASK_EMERG   => LVLTOVAL_MAP->{EMER} << 2,
                           LOGMASK_ALERT   => LVLTOVAL_MAP->{ALRT} << 2,
                           LOGMASK_CRIT    => LVLTOVAL_MAP->{CRIT} << 2,
                           LOGMASK_ERR     => LVLTOVAL_MAP->{ERR} << 2,
                           LOGMASK_WARNING => LVLTOVAL_MAP->{WARN} << 2,
                           LOGMASK_NOTICE  => LVLTOVAL_MAP->{NOTI} << 2,
                           LOGMASK_INFO    => LVLTOVAL_MAP->{INFO} << 2,
                           LOGMASK_DEBUG   => LVLTOVAL_MAP->{DEBG} << 2
};          # MASK_MAP{}

# Constructor
# --------------------------------------------------------------------

sub new
{

        my $class = shift;
        return bless { levelclass => $class },
            $class;

}           # new()

# Public Methods
# --------------------------------------------------------------------

# --------------------------------------------------------------------

