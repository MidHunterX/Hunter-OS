# profile.hypr
# message "Test Message"

profile.hypr() {
  NAME="Hypr Chan"
  IMG=~/Mid_Hunter/scripts/hyprchan/assets/hypr_chan.jpg
  HINTS="-h string:frcolor:#52efb3 "
  HINTS+="-h string:bgcolor:#1f4738 "
}

message() {
  notify-send $HINTS -i $IMG "$NAME" "$1"
}
