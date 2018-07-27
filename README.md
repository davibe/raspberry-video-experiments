
# Readme

This document is a WIP reference of my video streaming experiments with [GStreamer](https://gstreamer.freedesktop.org), raspberry pi w, logitech c920, random [raspberry camera](https://www.amazon.it/gp/product/B0748GQ32H/ref=oh_aui_detailpage_o03_s00?ie=UTF8&psc=1) and my macbook pro

## Setup

I wrote a [brief summary](raspberry-setup.md) of how I set up my raspbian lite.

### GStreamer versions

Current raspbian ships with GStreamer 1.10.2 but the last GStreamer release as of today is 1.14.2 so I decided to [build and install the latest version](https://github.com/davibe/docker-gstreamer-raspbian-build). *Note: the stock GStreamer 1.10.2 has a few problems and most of the examples here would not work.*

### Logitec C920

The c920 is a camera that's capable of producing hardware encoded h264 streams. It also has a microphone. Both things make it perfect for the pi zero w which is lacking both cpu power and mic.

#### RTSP

I was able to 
[stream hardware encoded h264 using rtsp](pipelines/producer_c920_h264_aac_rtspclient.sh) 
to a 
[rtsp relay](https://github.com/jayridge/rtsprelay/) 
running on my mac. 
The stream 
[played fine](pipelines/consumer_mac_rtsp.sh) 
with very low latency.

#### HLS

I even successfully
[streamed it to disk as HLS](pipelines/producer_c920_h264_aac_hlssink.sh). 
The pipeline generated some critical error in the console but the stream worked fine.

I also tried to
[encode the video stream using omxh264enc](pipeline/producer_c920_omxh264_aac_hjlssink.sh)
instead of the hardware encoder of the camera. The pi w was able to handle up to 720x480 (85% cpu).

Pure software encoding [with x264 software encoder](pipelines/producer_x264_aac_hlssink)
worked as well but its very heavy and the pi could only handle very low resolutions (320x240).

#### Artifacts

Streaming hardware-encoded h264 from the c920 works but the stream seems to have some artifacts from time to time. It looks like B-frames are lost.

I have tried to get rid of them. After reading 
[this](https://www.raspberrypi.org/forums/viewtopic.php?t=67629) 
and 
[this](https://www.raspberrypi.org/forums/viewtopic.php?f=28&t=70437) 
I have tried 

    sudo rpi-update

and prepended to `/boot/cmdline.txt`

    dwc_otg.fiq_enable=1 dwc_otg.fiq_fsm_enable=1 dwc_otg.fiq_fsm_mask=0x7

I still see the artifacts from time to time. I am not sure if these ones
are introduced by the camera itself or it's the network. Need more testing.

### Raspberry camera

The camera shipped with wrong cable. I am waiting for re-shipment before i can test it :)
