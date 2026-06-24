package MenuLib;

use strict;
use warnings;
use utf8;
use Exporter 'import';
use File::Path qw(make_path);
use File::Spec;
use HTTP::Tiny;
use JSON::PP;
use IPC::Open2;
use Encode qw(encode_utf8);

our @EXPORT_OK = qw(get_cache_dir get_script_dir update_emojis update_nerdfonts
    parse_emojis parse_nerdfonts ensure_cache get_switch_entries show_menu
    switch_if_menu bump_to_top send_output);

use constant MENU_REGISTRY => {
    "Emoji Menu" => "menu_emoji.pl",
    "Font Menu"  => "menu_nerdfont.pl",
};

# ================================[ GETTERS ]================================ #

sub get_cache_dir {
    my $base = $ENV{XDG_CACHE_HOME} || File::Spec->catdir($ENV{HOME}, '.cache');
    my $cache_dir = File::Spec->catdir($base, 'menu-cache');
    make_path($cache_dir) unless -d $cache_dir;
    return $cache_dir;
}

sub get_script_dir {
    require File::Basename;
    return File::Basename::dirname(File::Spec->rel2abs($0));
}

# ================================[ PARSERS ]================================ #

sub parse_emojis {
    my ($json_content) = @_;
    my $data = decode_json($json_content);
    my @lines;
    for my $key (sort keys %$data) {
        my $keywords = join(" ", @{$data->{$key}});
        $keywords =~ s/_/ /g;
        push @lines, "$key $keywords\n";
    }
    return join("", @lines);
}

sub parse_nerdfonts {
    my ($css_content) = @_;
    my @lines;
    my $current_name = "";
    for my $line (split /\n/, $css_content) {
        if ($line =~ /^\.nf-(.*?):before/) {
            $current_name = $1;
        } elsif ($line =~ /content:\s*"\\(.*?)";/) {
            my $hex = $1;
            if ($current_name ne '') {
                my $char = chr(hex($hex));
                push @lines, "$char $current_name\n";
                $current_name = "";
            }
        }
    }
    return join("", @lines);
}

# ===============================[ UPDATERS ]=============================== #

sub update_emojis {
    my ($cache_file) = @_;
    # Use curl instead of HTTP::Tiny to avoid SSL dependency issues
    my $url = 'https://raw.githubusercontent.com/muan/emojilib/main/dist/emoji-en-US.json';
    my $content = `curl -sSL "$url"`;
    if ($? != 0 || !$content) {
        die "Failed to download emojis using curl. Exit code: $?\n";
    }
    my $parsed = parse_emojis($content);
    open my $fh, '>', $cache_file or die "Cannot open $cache_file: $!";
    binmode($fh, ":encoding(UTF-8)");
    print $fh $parsed;
    close $fh;
}

sub update_nerdfonts {
    my ($cache_file) = @_;
    my $url = 'https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/css/nerd-fonts-generated.css';
    my $content = `curl -sSL "$url"`;
    if ($? != 0 || !$content) {
        die "Failed to download nerdfonts using curl. Exit code: $?\n";
    }
    my $parsed = parse_nerdfonts($content);
    open my $fh, '>', $cache_file or die "Cannot open $cache_file: $!";
    binmode($fh, ":encoding(UTF-8)");
    print $fh $parsed;
    close $fh;
}

sub ensure_cache {
    my ($cache_file) = @_;
    unless (-e $cache_file) {
        open my $fh, '>', $cache_file or die "Cannot create $cache_file: $!";
        close $fh;
    }
}

# =============================[ CORE FEATURES ]============================= #

sub get_switch_entries {
    my ($current) = @_;
    my @entries;
    my $reg = MENU_REGISTRY;
    for my $label (sort keys %$reg) {
        push @entries, $label if $label ne $current;
    }
    return @entries;
}

sub show_menu {
    my ($cache_file, $prompt, $switch_label, $color) = @_;
    ensure_cache($cache_file);

    my $pid = open2(my $out, my $in, 'fuzzel', '--dmenu', "--border-color=$color", '--match-mode=fzf', "--prompt=$prompt ");
    binmode($in, ":encoding(UTF-8)");
    binmode($out, ":encoding(UTF-8)");

    # Stream file to fuzzel to save memory
    open my $fh, '<:encoding(UTF-8)', $cache_file or die "Cannot open $cache_file: $!";
    while (my $line = <$fh>) {
        print $in $line if $line =~ /\S/;
    }
    close $fh;

    # Stream the dynamic switch entries
    for my $entry (get_switch_entries($switch_label)) {
        print $in "$entry\n";
    }
    close $in;

    my $selection = <$out>;
    close $out;
    waitpid($pid, 0);

    chomp $selection if defined $selection;
    return $selection;
}

sub switch_if_menu {
    my ($selection) = @_;
    my $reg = MENU_REGISTRY;

    if (exists $reg->{$selection}) {
        my $script = $reg->{$selection};
        my $path = File::Spec->catfile(get_script_dir(), $script);

        if (my $pid = fork()) {
            return 1; # Parent process confirms a switch happened
        } elsif (defined $pid) {
            exec($^X, $path) or die "Failed to execute $path: $!";
        } else {
            die "Fork failed: $!";
        }
    }
    return 0;
}

sub bump_to_top {
    my ($row, $cache_file) = @_;
    open my $fh_in, '<:encoding(UTF-8)', $cache_file or return;
    my @lines = <$fh_in>;
    close $fh_in;

    # Remove duplicates of the selected row
    @lines = grep { $_ ne "$row\n" } @lines;

    # Prepend the new row at the top
    unshift @lines, "$row\n";

    open my $fh_out, '>:encoding(UTF-8)', $cache_file or die "Cannot write $cache_file: $!";
    print $fh_out $_ for @lines;
    close $fh_out;
}

sub send_output {
    my ($symbol) = @_;
    my $bytes = encode_utf8($symbol);
    system("wtype", $bytes);
    system("wl-copy", $bytes);
}

1;
