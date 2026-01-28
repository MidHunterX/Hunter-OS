package logic;

use strict;
use warnings;
use JSON::PP;
use Exporter qw(import);

our @EXPORT_OK = qw(
    interpolate_brightness
    load_data
);

sub load_data {
    my ($file_path) = @_;
    if (!-e $file_path) { return {}; }
    open my $fh, '<', $file_path or return {};
    local $/;
    my $json_text = <$fh>;
    close $fh;
    return decode_json($json_text || '{}');
}


sub interpolate_brightness {
    my ($data, $current_min) = @_;

    my @stored_mins = sort { $a <=> $b } keys %$data;

    # SCENARIO No dataset
    return 0 if (!@stored_mins);

    # SCENARIO Exact match
    return $data->{$current_min} if exists $data->{$current_min};

    my ($prev, $next);
    for my $m (@stored_mins) {
        if ($m < $current_min) { $prev = $m; }
        if ($m > $current_min && !defined $next) { $next = $m; }
    }

    # CASE: Time Wrap-around (Midnight)
    # If no prev, the "prev" is the last point of the previous day
    if (!defined $prev) {
        $prev = $stored_mins[-1];
        my $val_prev = $data->{$prev};
        my $val_next = $data->{$stored_mins[0]};

        my $dist_total = (1440 - $prev) + $stored_mins[0];
        my $dist_curr  = ($current_min < $prev) ? $current_min + (1440 - $prev) : $current_min - $prev;

        return $val_prev + ($val_next - $val_prev) * ($dist_curr / $dist_total);
    }

    # If no next, the "next" is the first point of the next day
    if (!defined $next) {
        $next = $stored_mins[0];
        my $val_prev = $data->{$prev};
        my $val_next = $data->{$next};

        my $dist_total = (1440 - $prev) + $next;
        my $dist_curr  = $current_min - $prev;

        return $val_prev + ($val_next - $val_prev) * ($dist_curr / $dist_total);
    }

    # LERP (Linear Interpolation)
    my $val_prev = $data->{$prev};
    my $val_next = $data->{$next};
    return $val_prev + ($val_next - $val_prev) * (($current_min - $prev) / ($next - $prev));
}

1; # Must return a true value
