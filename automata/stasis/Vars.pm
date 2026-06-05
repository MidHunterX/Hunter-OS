package Vars;
use strict;
use warnings;
use Exporter qw(import);

our @EXPORT_OK = qw(
    DAYS_TO_LOOK_BACK
    FALLBACK_START
    FALLBACK_END
    TIMEOUT_MINOR
    TIMEOUT_MAJOR
);

# Time (minutes) to wait before actions
use constant TIMEOUT_MINOR => 15; # Screen off
use constant TIMEOUT_MAJOR => 30; # Logic execution (suspend/poweroff)

# Prediction settings
use constant DAYS_TO_LOOK_BACK => 14;

# Fallbacks
use constant FALLBACK_START => "09:00";
use constant FALLBACK_END   => "16:00";

1;
