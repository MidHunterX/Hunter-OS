#!/usr/bin/env perl

use strict;
use warnings;

use constant {
  WALLPAPER => $ARGV[0],
  SCREEN => "eDP-1",
  IRIS => "$ENV{HOME}/automata/iris/worker.pl",
};

exit 1 unless WALLPAPER;

my $wallpaper_extension = WALLPAPER;
$wallpaper_extension =~ s/.*\.(.*)/$1/;

# IMAGE WALLPAPER
my @swww_extensions = ("png", "jpg", "jpeg", "webp");
for my $ext (@swww_extensions) {
  if ($wallpaper_extension eq $ext) {
    system("swww", "img", WALLPAPER, "--transition-step", 10);
    system("perl", IRIS);
    exit 0;
  }
}

# # VIDEO WALLPAPER
# my @mpv_extensions = ("mp4", "mkv", "avi", "mov", "flv", "webm", "wmv", "m4v");
# for my $ext (@mpv_extensions) {
#   if ($wallpaper_extension eq $ext) {
#     system("pkill", "-x", "mpvpaper");
#     system("mpvpaper", "-o", "no-audio loop panscan=1.0", SCREEN, WALLPAPER);
#     exit 0;
#   }
# }
