
raspivid \
  -fps 26 \
  -h 600 -w 800 \
  -n -t 0 -b 500000 \
  -ex sports \
  -o - | \
gst-launch-1.0 \
  audiotestsrc do-timestamp=true \
  ! audio/x-raw,format=\(string\)S16LE,rate=32000,channels=2 \
  ! queue leaky=1 \
  ! decodebin \
  ! audioconvert ! audiorate ! queue \
  ! queue \
  ! voaacenc bitrate=41000 \
  ! mux. \
  fdsrc \
  ! h264parse \
  ! queue \
  ! rtspclientsink name=mux \
    debug=1 latency=0 \
    location=rtsp://choo.local:8554/test/record \