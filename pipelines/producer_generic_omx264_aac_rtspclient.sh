
gst-launch-1.0 \
  alsasrc device=hw:1 do-timestamp=true \
  ! audio/x-raw,format=\(string\)S16LE,rate=32000,channels=2 \
  ! queue \
  ! decodebin \
  ! audioconvert ! audiorate ! queue \
  ! queue \
  ! voaacenc bitrate=41000 \
  ! mux. \
  videotestsrc is-live=true \
  ! videoconvert \
  ! videorate \
  ! videoscale \
  ! queue \
  ! omxh264enc  \
  ! "video/x-h264,profile=high,width=900,height=600,framerate=20/1" \
  ! h264parse \
  ! queue \
  ! rtspclientsink name=mux \
    debug=1 latency=0 \
    location=rtsp://choo.local:8554/test/record \