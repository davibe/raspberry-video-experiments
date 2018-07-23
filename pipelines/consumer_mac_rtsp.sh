
gst-launch-1.0 -v \
  rtspsrc debug=1 latency=0 location=rtspt://127.0.0.1:8554/test name=r \
  r. \
  ! rtph264depay \
  ! avdec_h264 \
  ! videoconvert \
  ! autovideosink \
  r. \
  ! rtpmp4adepay \
  ! faad \
  ! audioconvert \
  ! autoaudiosink
