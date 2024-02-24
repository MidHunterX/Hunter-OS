profile.hypr() {
  NAME="Hypr Chan"
  IMG=~/Mid_Hunter/scripts/hyprchan/assets/hypr_chan.jpg
  HINTS="-h string:frcolor:#52efb3 "
  HINTS+="-h string:bgcolor:#1f4738 "
}

hypr.message() {
  notify-send $HINTS -t 5000 -i $IMG "$NAME" "$1"
}
