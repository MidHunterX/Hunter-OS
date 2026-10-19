package Logic;

use strict;
use warnings;
use JSON::PP qw(decode_json);
use File::Spec;
use POSIX qw(strftime);
use Exporter qw(import);

our @EXPORT_OK = qw(
    data_file
    fval
    hm_to_minute
    interpolate_brightness
    load_data
    minute_to_hm
    now_minute
    save_data
    update_point
);

# ============================== SHARED PATHS =============================== #

sub data_file {
    return $ENV{RADIANCE_FILE}
        if defined $ENV{RADIANCE_FILE} && length $ENV{RADIANCE_FILE};
    my $home = $ENV{HOME} // '';
    return File::Spec->catfile($home, '.cache', 'radiance_data.json');
}

# ============================== DATA I/O =================================== #

sub load_data {
    my ($file_path) = @_;
    if (!defined $file_path || !-e $file_path) { return {}; }
    open my $fh, '<', $file_path or return {};
    local $/;
    my $json_text = <$fh>;
    close $fh;
    # Blank or malformed content must never crash a caller.
    if (!defined $json_text || $json_text !~ /\S/) { return {}; }
    my $data = eval { decode_json($json_text) };
    return {} unless ref $data eq 'HASH';
    return $data;
}

sub save_data {
    my ($file_path, $data) = @_;
    $data ||= {};
    open my $fh, '>', $file_path or die "write $file_path: $!";
    # Sort by numeric minute key for a stable file
    my @keys = sort { $a <=> $b } keys %$data;
    my %ordered = map { $_ => $data->{$_} } @keys;
    print {$fh} JSON::PP->new->canonical->encode(\%ordered);
    close $fh;
    return 1;
}

# ============================== HELPERS ==================================== #

# Coerce a stored value to a number; anything unparseable counts as 0.
sub fval {
    my ($v) = @_;
    return (defined $v && $v =~ /^-?\d/) ? $v + 0 : 0;
}

sub minute_to_hm {
    my $m = shift;
    $m = int($m) % 1440;
    $m += 1440 if $m < 0;
    return sprintf("%02d:%02d", int($m / 60), $m % 60);
}

sub hm_to_minute {
    my $s = shift;
    return undef unless defined $s && $s =~ /^\s*(\d{1,2}):?(\d{2})?\s*$/;
    my ($h, $mn) = ($1, $2 // 0);
    return undef if $h > 23 || $mn > 59;
    return $h * 60 + $mn;
}

# Minutes elapsed since local midnight (0..1439).
sub now_minute {
    my ($h, $m) = (strftime("%H", localtime), strftime("%M", localtime));
    return $h * 60 + $m;
}

# ============================== DOMAIN ===================================== #

sub update_point {
    my ($data, $minute, $value, $window_size) = @_;
    $window_size //= 10; # Default to 10 minutes if not specified
    # Remove any existing points within the detection window (padding)
    for my $stored_min (keys %$data) {
        my $diff = abs($stored_min - $minute);
        # Handle circular time wrap-around (e.g., 23:59 and 00:01)
        if ($diff > 720) { $diff = 1440 - $diff; }
        if ($diff <= $window_size) { delete $data->{$stored_min}; }
    }
    # Set the new point
    $data->{$minute} = sprintf("%.2f", fval($value));
    return $data;
}

sub interpolate_brightness {
    my ($data, $current_min) = @_;

    my @stored_mins = sort { $a <=> $b } keys %$data;

    # SCENARIO No dataset
    return 0 if (!@stored_mins);

    # SCENARIO Exact match
    return fval($data->{$current_min}) if exists $data->{$current_min};

    my ($prev, $next);
    for my $m (@stored_mins) {
        if ($m < $current_min) { $prev = $m; }
        if ($m > $current_min && !defined $next) { $next = $m; }
    }

    # CASE: Time Wrap-around (Midnight)
    # If no prev, the "prev" is the last point of the previous day
    if (!defined $prev) {
        $prev = $stored_mins[-1];
        my $val_prev = fval($data->{$prev});
        my $val_next = fval($data->{$stored_mins[0]});

        my $dist_total = (1440 - $prev) + $stored_mins[0];
        my $dist_curr  = ($current_min < $prev) ? $current_min + (1440 - $prev) : $current_min - $prev;

        return $val_prev + ($val_next - $val_prev) * ($dist_curr / $dist_total);
    }

    # If no next, the "next" is the first point of the next day
    if (!defined $next) {
        $next = $stored_mins[0];
        my $val_prev = fval($data->{$prev});
        my $val_next = fval($data->{$next});

        my $dist_total = (1440 - $prev) + $next;
        my $dist_curr  = $current_min - $prev;

        return $val_prev + ($val_next - $val_prev) * ($dist_curr / $dist_total);
    }

    # LERP (Linear Interpolation)
    my $val_prev = fval($data->{$prev});
    my $val_next = fval($data->{$next});
    return $val_prev + ($val_next - $val_prev) * (($current_min - $prev) / ($next - $prev));
}

1; # Must return a true value
