# probably not needed, just a commands reference

sudo v4l2-ctl -d /dev/video0 -c exposure_auto_priority=0
sudo v4l2-ctl --device=/dev/video0 --set-fmt-video=width=1280,height=720,pixelformat=1