
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
    src.vidsrc \
  ! "video/x-h264,width=1280,height=720,framerate=20/1" \
  ! h264parse \
  ! queue \
  ! rtspclientsink name=mux \
    debug=1 latency=0 \
    location=rtsp://choo.local:8554/test/record \