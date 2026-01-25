#!/usr/bin/env perl

use File::Path qw(make_path);
use File::Spec;
use POSIX qw(strftime);
use Term::ANSIColor qw(:constants);
use IPC::Cmd qw(can_run);

# ================================= HELPERS ================================= #

# log_msg(str:message)
sub log_msg {
    my $msg = shift;
    print "[" . GREEN . strftime('%H:%M:%S', localtime) . RESET . "] $msg\n";
}

# create_tmpfile(dir, filename) -> returns full path
sub create_tmpfile {
    my ($dir, $filename) = @_;
    make_path($dir) unless -d $dir;
    my $path = File::Spec->catfile($dir, $filename);
    # "touch" and chmod 600 (og-rwx)
    open(my $fh, '>', $path) or die "Could not create $path: $!";
    close($fh);
    chmod(0600, $path) or die "Could not chmod $path: $!";
    return $path;
}


# ============================== DEPENDENCIES ============================== #

# check_dependencies(deps:array)
sub check_dependencies {
    my @deps = @_;
    return grep { !can_run($_) } @deps;
}

my @missing = check_dependencies(qw(nvim kitty wtype wl-copy));

if (@missing) {
    log_msg("Error: missing required commands: @missing");
    exit 1;
}

# ================================== MAIN ================================== #

my $temp_dir  = "/tmp/nvim-textinput";
my $temp_file = create_tmpfile($temp_dir, "buffer.md");

# ACTION: Launch Terminal + Editor
local $ENV{TERM} = 'kitty'; # Set environment variable locally
log_msg("Launching editor");
system(
    'kitty',
    '--class', 'textinput',
    '-e', 'nvim',
    '+startinsert',
    '+autocmd BufWritePost <buffer> quit',
    $temp_file
);

# ACTION: Read file content
my $content = do {
    open(my $fh, '<', $temp_file) or die "Could not read $temp_file: $!";
    local $/; # Enable slurp mode
    <$fh>;
};

# ACTION: Output file content
if (defined $content && $content =~ /\S/) {
    log_msg("Pasting content...");
    # Pipe content to wl-copy
    open(my $pipe, '|-', 'wl-copy', '-n') or die "Could not open wl-copy: $!";
    print $pipe $content;
    close($pipe);
    # Simulate Paste
    system('wtype', '-M', 'Ctrl', '-k', 'v', '-m', 'Ctrl');
} else {
    log_msg("Buffer empty. Exiting.");
    exit 1;
}
