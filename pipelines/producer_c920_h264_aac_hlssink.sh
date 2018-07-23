# with gst 1.10.4 (raspbian default) this fails badly with an assertion

gst-launch-1.0 \
  uvch264src \
    mode=2 \
    initial-bitrate=500000 \
    average-bitrate=500000 \
    fixed-framerate=true \
    rate-control=1 \
    usage-type=2 \
    iframe-period=3000 \
    device=/dev/video0 name=src \
    auto-start=true \
    src.vidsrc \
  ! queue \
  ! "video/x-h264,width=960,height=720,framerate=20/1" \
  ! h264parse \
  ! mpegtsmux name=mux  \
  ! queue \
  ! hlssink location="test/testa%02d.ts" max-files=3 playlist-location=test/playlist.m3u8 target-duration=3 \
  alsasrc device=hw:1 do-timestamp=false slave-method=1 \
  ! queue leaky=1 \
  ! decodebin \
  ! audioconvert ! audiorate ! queue \
  ! voaacenc bitrate=41000 \
  ! mux.