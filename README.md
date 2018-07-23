
# Intro

This document is a reference of my video streaming experiments with a few hardware toys

- raspberry pi zero w
- logitech c920
- random raspberry camera from amazon
- my macbook pro

# Raspberry

## Setup

I wrote a [brief and still messy summary](raspberry-setup.md) of how i set up my raspberry

## Logitech c920 + Raspberry

Stream from raspberry + c920 unsing ~half megabit

    gst-launch-1.0 \
      uvch264src \
        initial-bitrate=500000 \
        average-bitrate=500000 \
        iframe-period=3000 \
        device=/dev/video0 name=src \
        auto-start=true \
        src.vidsrc \
      ! "video/x-h264,width=960,height=720,framerate=20/1" \
      ! h264parse \
      ! queue \
      ! gdppay \
      ! tcpclientsink host=choo.local port=5000 \
      alsasrc device=hw:1 ! fakesink

Playback (from anywhere)

    gst-launch-1.0 \
      tcpserversrc host=0.0.0.0 port=5000 \
      ! gdpdepay \
      ! decodebin \
      ! autovideosink


Read more on [how to set advanced c920 encoding parameters](http://oz9aec.net/software/gstreamer/using-the-logitech-c920-webcam-with-gstreamer-12)

### Artifacts

Streaming hardware-encoded h264 from the c920 works but the stream seems to have some artifacts.

I have tried to get rid of them. After reading 
[this](https://www.raspberrypi.org/forums/viewtopic.php?t=67629) 
and 
[this](https://www.raspberrypi.org/forums/viewtopic.php?f=28&t=70437) 
I have done

    sudo rpi-update

and prepended to /boot/cmdline.txt

    dwc_otg.fiq_enable=1 dwc_otg.fiq_fsm_enable=1 dwc_otg.fiq_fsm_mask=0x7

**So far I still see the artifacts**. *Maybe* there is less of them. I am not sure if they are introduced by the camera itself or it's the network. Need more testing.



# Gst Playground

Here some txt notes I use to quickly copy-paste and create pipelines

### sources

    videotestsrc is-live=true \

    uvch264src \
      name=src \
      iframe-period=3000 \
      device=/dev/video0 \
      auto-start=true \
      src.vidsrc \

    v4l2src \

### outputs

    ! flvmux name=mux \

    ! rtmpsink \
      location="rtmp://live-api-s.facebook.com:80/rtmp/[secret]"

    ! rtspclientsink name=mux \
      debug=1 latency=0 \
      location=rtsp://choo.local:8554/test/record \

    ! filesink location=test.flv

    ! omxh264enc target-bitrate=500 \


Mac + hardware h264 encoding + local playback

    gst-launch-1.0 \
      avfvideosrc do-timestamp=true \
      ! clockoverlay font-desc="Sans Italic 100" \
      ! videoconvert \
      ! videoscale n-threads=8 \
      ! video/x-raw, framerate=25/1, width=1080, height=720 \
      ! vtenc_h264_hw realtime=true bitrate=5000 quality=1 max-keyframe-interval-duration=1000000000 \
      ! h264parse \
      ! queue \
      ! decodebin \
      ! autovideosink \
      osxaudiosrc \
      ! audioconvert \
      ! autoaudiosink

Mac + hardware h264 encoding + local playback + hlssink

    gst-launch-1.0 \
      avfvideosrc capture-screen=true do-timestamp=true \
      ! clockoverlay font-desc="Sans Italic 100" \
      ! videoconvert \
      ! videoscale n-threads=8 \
      ! video/x-raw, framerate=25/1, width=1080, height=720 \
      ! videoconvert \
      ! tee name=tee \
      tee. ! queue ! decodebin ! autovideosink \
      tee. ! vtenc_h264_hw realtime=true bitrate=5000 quality=1 max-keyframe-interval-duration=10000000000 \
      ! h264parse \
      ! queue \
      ! mpegtsmux name=n \
      ! hlssink location="test/testa%02d.ts" max-files=6 playlist-location=test/playlist.m3u8 target-duration=1 \
      osxaudiosrc \
      ! audioconvert \
      ! faac ! n.

    gst-launch-1.0 \
      videotestsrc is-live=true \
      ! videoconvert \
      ! videoscale n-threads=8 \
      ! video/x-raw, framerate=25/1, width=80, height=60 \
      ! videoconvert \
      ! x264enc tune=zerolatency byte-stream=true threads=1 key-int-max=3 intra-refresh=true \
      ! h264parse \
      ! queue \
      ! mpegtsmux name=n \
      ! hlssink location="test/testa%02d.ts" max-files=6 playlist-location=test/playlist.m3u8 target-duration=1 \
      audiotestsrc is-live=true \
      ! audioconvert \
      ! queue \
      ! faac ! n.

Mac + hardware h264 encoding + local playback + hlssink2 (does not work with gstreamer 1.14.1)

    GST_DEBUG=*:4 gst-launch-1.0 \
      avfvideosrc do-timestamp=true \
      ! clockoverlay font-desc="Sans Italic 100" \
      ! videoconvert \
      ! videoscale n-threads=8 \
      ! video/x-raw, framerate=25/1, width=1080, height=720 \
      ! videoconvert \
      ! tee name=tee \
      tee. ! queue ! decodebin ! autovideosink \
      tee. ! queue ! vtenc_h264_hw realtime=true bitrate=5000 quality=1 max-keyframe-interval-duration=1000000000 \
      ! h264parse \
      ! queue \
      ! hlssink2 name=n location="test/testa%02d.ts" max-files=6 playlist-location=test/playlist.m3u8 target-duration=2 sync=false \
      audiotestsrc \
      ! audioconvert \
      ! audioresample \
      ! queue \
      ! faac \
      ! queue \
      ! n.audio

Mac + software h264 encoding + rtspclient announce

    gst-launch-1.0 \
      autoaudiosrc \
      ! audioconvert \
      ! queue \
      ! faac \
      ! aacparse \
      ! r. \
      autovideosrc is-live=1 \
      ! clockoverlay font-desc="Sans Italic 100" \
      ! videoconvert \
      ! videoscale \
      ! video/x-raw, framerate=10/1, width=800, height=600 \
      ! videoconvert \
      ! queue \
      ! x264enc tune=zerolatency byte-stream=true threads=1 key-int-max=15 intra-refresh=true \
      ! video/x-h264,width=800,height=600,framerate=10/1 \
      ! rtspclientsink debug=1 latency=0 location=rtsp://127.0.0.1:8554/test/record name=r \
    

# gst on mac

    avfvideosrc capture-screen=true \
    ! x264enc tune=zerolatency bitrate=5000 key-int-max=6 \
    ! vtenc_h264_hw realtime=true bitrate=5000 quality=1 max-keyframe-interval-duration=1000000000 \
    videotestsrc is-live=true \
    avfvideosrc do-timestamp=true \
    ! omxh264enc target-bitrate=500 \
