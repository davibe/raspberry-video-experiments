# RPI

https://blog.protoneer.co.nz/raspberry-pi-zero-footprint-dimensions/

I have installed raspbian lite

## Enable usb networking

Mount sd card and change the following files inside `boot` partition

config.txt -> add as last line:

    dtoverlay=dwc2

cmdline.txt -> add after rootwait

    modules-load=dwc2,g_ether

Boot the raspberry with usb connected and login

    ssh -o PubkeyAuthentication=no pi@raspberrypi.local


## Raspi config

Type `sudo raspi-config` and

- configure wifi
- change locale
- timezone
- wifi settings
- expand filesystem
- reboot

sudo apt-get update
sudo apt-get upgrade
sudo apt-get dist-upgrade
sudo apt-get clean
sudo rpi-update
sudo reboot


## Add x-server and VNC

I don't relly use this anymore but i keep it as reference

    sudo apt-get install -y --no-install-recommends xserver-xorg
    sudo apt-get install -y --no-install-recommends xinit
    sudo apt-get install -y raspberrypi-ui-mod

    sudo apt-get install -y --no-install-recommends realvnc-vnc-server
    sudo systemctl enable vncserver-virtuald.service

sudo raspi-config
-> enable vnc access

## Setting up wireless AP+client mode

I found [a script that autoconfigures this](https://gist.github.com/lukicdarkoo/6b92d182d37d0a10400060d8344f86e4).
I don't like the wait it registers with `cron` to start at boot with a `sleep 30` but it works.

## Add more wifi client networks 

Editing `/etc/wpa_supplicant/wpa_supplicant.conf` one could add many networks with different priorities. Wpa supplicant will automatically pick them accordingly.

Here is an example of a mixed configuration

    # normal wpa network
    network={
        ssid="choo"
        psk="xxxxxx"
        id_str="AP1"
        priority=10
    }

    # iphone hotspot
    network={
        ssid="iPhone di Davide"
        proto=RSN
        key_mgmt=WPA-PSK
        pairwise=CCMP TKIP
        group=CCMP TKIP
        psk="nonlasaitu"
        id_str="AP2"
        priority=0
    }

    # WPA enterprise
    network={
        ssid="CORPORATE"
        scan_ssid=1
        key_mgmt=WPA-EAP
        identity="some.user"
        password="xxxxxx"
        eap=PEAP
        phase1="peaplabel=0"
        phase2="auth=MSCHAPV2"
        id_str="AP4"
        priority=2
    }

    # open wifi
    network={
        ssid="D3FREE"
        key_mgmt=NONE
        id_str="AP3"
        priority=1
    }


This is what the corresponding `/etc/network/interfaces` looks like

    source-directory /etc/network/interfaces.d

    auto lo
    auto ap0
    auto wlan0
    iface lo inet loopback

    allow-hotplug ap0
    iface ap0 inet static
        address 192.168.10.1
        netmask 255.255.255.0
        hostapd /etc/hostapd/hostapd.conf

    allow-hotplug wlan0
    iface wlan0 inet manual
        wpa-roam /etc/wpa_supplicant/wpa_supplicant.conf
    iface AP1 inet dhcp
    iface AP2 inet dhcp
    iface AP3 inet dhcp
    iface AP4 inet dhcp
