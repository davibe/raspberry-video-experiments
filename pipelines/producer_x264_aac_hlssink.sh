
rm -rf test/* 
gst-launch-1.0 \
  videotestsrc is-live=true \
  ! clockoverlay font-desc="Sans Italic 100" \
  ! "video/x-raw, width=200, height=60" \
  ! queue \
  ! x264enc tune=zerolatency \
  ! h264parse   \
  ! mpegtsmux name=mux \
  ! hlssink location="test/testa%02d.ts" max-files=6 playlist-location=test/playlist.m3u8 target-duration=1 \
  audiotestsrc is-live=true \
  ! audioconvert \
  ! audiorate \
  ! queue \
  ! voaacenc bitrate=41000 \
  ! mux.