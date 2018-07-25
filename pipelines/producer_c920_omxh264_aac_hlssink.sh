# with gst 1.10.4 (raspbian default) this produces segments but they are not playable on ios

rm -rf test/*
gst-launch-1.0 \
  alsasrc device=hw:1 do-timestamp=true \
  ! audio/x-raw,format=\(string\)S16LE,rate=32000,channels=2 \
  ! queue leaky=1 \
  ! decodebin \
  ! audioconvert ! audiorate ! queue \
  ! queue \
  ! voaacenc bitrate=41000 \
  ! mux. \
  uvch264src \
    mode=2 \
    leaky-bucket-size=5000 \
    entropy=1 \
    post-previews=false \
    max-bframe-qp=0 \
    min-bframe-qp=0 \
    max-pframe-qp=0 \
    min-pframe-qp=0 \
    max-iframe-qp=0 \
    min-iframe-qp=0 \
    initial-bitrate=500000 \
    average-bitrate=500000 \
    fixed-framerate=true \
    rate-control=1 \
    usage-type=2 \
    iframe-period=5000 \
    device=/dev/video0 name=src \
    auto-start=true \
    src.vfsrc \
  ! omxh264enc inline-header=true  \
  ! "video/x-h264,profile=baseline,width=640,height=480,framerate=20/1" \
  ! h264parse \
  ! queue \
  ! mpegtsmux name=mux  \
  ! queue \
  ! hlssink location="test/testa%02d.ts" max-files=6 playlist-location=test/playlist.m3u8 target-duration=1 \