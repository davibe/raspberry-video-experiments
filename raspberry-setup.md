# RPI

https://blog.protoneer.co.nz/raspberry-pi-zero-footprint-dimensions/

I have installed raspbian lite

## Configure for usb networking

config.txt - last line
dtoverlay=dwc2

cmdline.txt - after rootwait
modules-load=dwc2,g_ether

create ssh file

ssh -o PubkeyAuthentication=no pi@raspberrypi.local

## Configure wifi manually

sudo nano /etc/wpa_supplicant/wpa_supplicant.conf

network={
  ssid="NETWORK"
  psk="PASSWORD"
}

sudo wpa_cli reconfigure
ifconfig wlan0

## Next setups

vi /etc/ssh/sshd_config - uncomment and change
MaxAuthTries -> 60

sudo raspi-config
-> change locale
-> timezone
-> wifi settings
-> expand filesystem
reboot

sudo apt-get update
sudo apt-get upgrade
sudo apt-get dist-upgrade
sudo apt-get clean
sudo rpi-update
sudo reboot

## add UI

sudo apt-get install -y --no-install-recommends xserver-xorg
sudo apt-get install -y --no-install-recommends xinit
sudo apt-get install -y raspberrypi-ui-mod

sudo apt-get install -y --no-install-recommends realvnc-vnc-server
sudo systemctl enable vncserver-virtuald.service

sudo raspi-config
-> enable vnc access

## Setting up wireless AP+client mode

https://gist.github.com/lukicdarkoo/6b92d182d37d0a10400060d8344f86e4

## Install gstreamer

apt-get install -y --