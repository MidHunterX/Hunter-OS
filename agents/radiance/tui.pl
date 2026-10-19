#!/usr/bin/env perl
use strict;
use warnings;
use Term::ReadKey;

use FindBin;            # locate script directory
use lib $FindBin::Bin;  # add directory to the search path (@INC) for lib
use Logic qw(
    data_file
    fval
    hm_to_minute
    load_data
    minute_to_hm
    save_data
);

my $FILE = data_file();

# ---------- Terminal ---------------------------------------------------------

my ($COLS, $ROWS);
sub term_size { my ($c, $r) = GetTerminalSize(); $COLS = $c || 80; $ROWS = $r || 24 }

sub clear_screen { print "\e[2J\e[H" }

sub move_to { my ($r, $c) = @_; print "\e[${r};${c}H" }

sub hide_cursor { print "\e[?25l" }
sub show_cursor { print "\e[?25h" }

sub attr { my $a = shift; print "\e[${a}m" }
sub reset_attr { print "\e[0m" }

# ---------- Render -----------------------------------------------------------

my $status = '';
my $dirty  = 0;

sub render {
    my ($data, $selected_idx, $edit_mode, $edit_buf) = @_;
    term_size();
    clear_screen();

    my @mins = sort { $a <=> $b } keys %$data;

    # Header
    move_to(1, 1);
    attr('1;36');
    printf "radiance TUI  %-45s  %d pts%s", $FILE, scalar(@mins),
        ($dirty ? "  [modified]" : "");
    reset_attr();

    # Determine bar area
    my $bar_start_col = 14;                 # "HH:MM  48.90  " prefix
    my $bar_max_width = $COLS - $bar_start_col - 2;
    $bar_max_width = 10 if $bar_max_width < 10;

    my $visible_rows = $ROWS - 5;           # header, footer, status
    my $top = 3;

    # If selection is beyond view, scroll
    my $first = 0;
    if (@mins > $visible_rows) {
        if ($selected_idx >= $visible_rows) {
            $first = $selected_idx - $visible_rows + 1;
        }
        $first = 0 if $first < 0;
    }

    for my $i (0 .. $visible_rows - 1) {
        my $idx = $first + $i;
        last if $idx >= @mins;
        my $m   = $mins[$idx];
        my $val = fval($data->{$m});
        my $sel = ($idx == $selected_idx);

        move_to($top + $i, 1);
        if ($sel) { attr('7'); }  # reverse video for selection

        my $label = sprintf("%5s %6.2f ", minute_to_hm($m), $val);
        print $label;

        my $width = int(($val / 100) * $bar_max_width);
        $width = 0 if $width < 0;
        $width = $bar_max_width if $width > $bar_max_width;

        # Color-code bars by brightness
        my $color = $val >= 66 ? '1;33' : $val >= 33 ? '1;32' : '1;34';
        attr($color) unless $sel;
        print '█' x $width;
        attr('0') unless $sel;
        print ' ' x ($bar_max_width - $width);
        reset_attr();
    }

    # Edit prompt line (overrides status when active)
    move_to($ROWS - 2, 1);
    attr('0');
    if ($edit_mode) {
        printf "Edit value for %s: %s_", minute_to_hm($mins[$selected_idx]), $edit_buf;
        # Move cursor into the edit line
        move_to($ROWS - 2, length("Edit value for " . minute_to_hm($mins[$selected_idx]) . ": ") + length($edit_buf) + 1);
        show_cursor();
    } else {
        print " " x ($COLS - 1);
        hide_cursor();
    }
    reset_attr();

    # Status / help line
    move_to($ROWS - 1, 1);
    attr('2');
    printf "%-*s", $COLS - 1,
        ($status ne '' ? $status
                       : "j/k move   h/l adjust   e/Enter edit   a add   d delete   s save   q quit");
    reset_attr();
}

# ---------- Input loop -------------------------------------------------------

sub main {
    ReadMode(4);                # cbreak, no echo, no signals
    END { ReadMode(0); show_cursor(); print "\e[?25h\e[0m\n" }
    hide_cursor();

    my $data = load_data($FILE);
    my @mins = sort { $a <=> $b } keys %$data;
    my $sel = @mins ? 0 : -1;

    my $edit_mode = 0;
    my $edit_buf  = '';
    my $add_mode  = 0;
    my $add_field = 0;          # 0=time, 1=value
    my $add_time  = '';
    my $add_value = '';

    render($data, $sel, $edit_mode, $edit_buf);

    while (1) {
        my $key = ReadKey(0);
        next unless defined $key;

        # --- add mode handling ---
        if ($add_mode) {
            if ($key eq "\e") { $add_mode = 0; $status = ''; }
            elsif ($key eq "\r" || $key eq "\n") {
                if ($add_field == 0) {
                    my $m = hm_to_minute($add_time);
                    if (defined $m) {
                        $add_field = 1;
                    } else {
                        $status = "Invalid time (use HH:MM)";
                    }
                } else {
                    if ($add_value =~ /^-?\d+(\.\d+)?$/) {
                        my $m = hm_to_minute($add_time);
                        $data->{$m} = sprintf("%.2f", $add_value + 0);
                        @mins = sort { $a <=> $b } keys %$data;
                        $sel = (grep { $mins[$_] == $m } 0 .. $#mins)[0] // 0;
                        $dirty = 1;
                        $status = "Added point";
                        $add_mode = 0;
                    } else {
                        $status = "Invalid value";
                    }
                }
            }
            elsif ($key eq "\x7f" || $key eq "\b") {
                if ($add_field == 0) { chop $add_time; }
                else                 { chop $add_value; }
            }
            elsif ($key =~ /^[0-9.:]$/ && $add_field == 0) { $add_time  .= $key; }
            elsif ($key =~ /^[-0-9.]$/ && $add_field == 1) { $add_value .= $key; }

            # Render add prompt inline using status region
            term_size();
            move_to($ROWS - 2, 1);
            print ' ' x ($COLS - 1);
            move_to($ROWS - 2, 1);
            if ($add_field == 0) {
                print "Add point — time (HH:MM): ${add_time}_";
            } else {
                print "Add point — time ${add_time} value: ${add_value}_";
            }
            show_cursor();
            next;
        }

        # --- edit mode handling ---
        if ($edit_mode) {
            if ($key eq "\e") { $edit_mode = 0; }
            elsif ($key eq "\r" || $key eq "\n") {
                if ($edit_buf =~ /^-?\d+(\.\d+)?$/) {
                    my $m = $mins[$sel];
                    $data->{$m} = sprintf("%.2f", $edit_buf + 0);
                    $dirty = 1;
                    $status = "Updated " . minute_to_hm($m);
                } else {
                    $status = "Invalid number";
                }
                $edit_mode = 0;
            }
            elsif ($key eq "\x7f" || $key eq "\b") { chop $edit_buf; }
            elsif ($key =~ /^[-0-9.]$/) { $edit_buf .= $key; }
            render($data, $sel, $edit_mode, $edit_buf);
            next;
        }

        # --- normal mode ---
        $status = '';

        if ($key eq 'q' || $key eq 'Q' || $key eq "\x03") { last }

        elsif ($key eq 'j' || $key eq "\e[B") {
            $sel++ if $sel < $#mins;
        }
        elsif ($key eq 'k' || $key eq "\e[A") {
            $sel-- if $sel > 0;
        }
        elsif ($key eq 'g') { $sel = 0 }
        elsif ($key eq 'G') { $sel = $#mins }

        elsif ($key eq 'l') {
            if ($sel >= 0) {
                my $m = $mins[$sel];
                my $v = fval($data->{$m}) + 1;
                $v = 100 if $v > 100;
                $data->{$m} = sprintf("%.2f", $v);
                $dirty = 1;
            }
        }
        elsif ($key eq 'h') {
            if ($sel >= 0) {
                my $m = $mins[$sel];
                my $v = fval($data->{$m}) - 1;
                $v = 0 if $v < 0;
                $data->{$m} = sprintf("%.2f", $v);
                $dirty = 1;
            }
        }

        elsif ($key eq 'e' || $key eq "\r" || $key eq "\n") {
            if ($sel >= 0) {
                $edit_mode = 1;
                $edit_buf  = sprintf("%.2f", fval($data->{$mins[$sel]}));
            }
        }
        elsif ($key eq 'a') {
            $add_mode  = 1;
            $add_field = 0;
            $add_time  = '';
            $add_value = '';
        }
        elsif ($key eq 'd' || $key eq 'x') {
            if ($sel >= 0) {
                my $m = $mins[$sel];
                delete $data->{$m};
                @mins = sort { $a <=> $b } keys %$data;
                $sel = $#mins if $sel > $#mins;
                $sel = 0 if $sel < 0;
                $dirty = 1;
                $status = "Deleted " . minute_to_hm($m);
            }
        }
        elsif ($key eq 's' || $key eq "\x13") {
            save_data($FILE, $data);
            $dirty = 0;
            $status = "Saved to $FILE";
        }
        elsif ($key eq 'r') {
            $data = load_data($FILE);
            @mins = sort { $a <=> $b } keys %$data;
            $sel = @mins ? 0 : -1;
            $dirty = 0;
            $status = "Reloaded from disk";
        }

        render($data, $sel, $edit_mode, $edit_buf);
    }
}

main();
