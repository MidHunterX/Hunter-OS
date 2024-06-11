#!/bin/sh
# Writers: default, csv, flat, ini, json, xml
ffprobe -hide_banner -v error -pretty -print_format json -show_private_data \
  -show_entries 'format=filename,format_name,format_long_name,duration,size,\
  bit_rate:stream=codec_name,codec_type,\
  codec_tag_string,width,height,closed_captions,film_grain,\
  display_aspect_ratio,field_order' \
  "$1" | jq '{format: .format, streams: .streams}' | highlight -O ansi --syntax json
