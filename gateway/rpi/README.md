# Setup Raspberry Pi (RPI)

## Installation

1. Prepeare `cmdline.txt` of raspian image on sd card. Append the following:
        
        ip=192.168.2.2
2. (OSX) Internet Sharing WiFi to (Thunderbolt) Ethernet
3. Login to rpi (pw: raspberry)

        ssh pi@192.168.2.2
4. Set locales: Choose `en_US.UTF8` in

        sudo dpkg-reconfigure locales
5. Set timezone: Choose `Zurich` in

        dpkg-reconfigure tzdata
6. Install required debian packages
        
        aptitude install autossh git vim mosh htop # Not nodejs npm!!!
7. Get latest Node.js debian package
        
        wget http://node-arm.herokuapp.com/node_latest_armhf.deb
8. Install Node.js

        sudo dpkg -i node_latest_armhf.deb
9. Checkout source code

        mkdir ~/src
        cd src/
        git clone <tresh_repo_url>

## Configuration

### DNS
Add following line to network interface in /etc/network/interfaces:
    
    dns-nameservers 8.8.8.8 8.8.4.4

### SSH Reverse Tunnel

1. Add autossh-tresh systemd service

        pi@raspberrypi:~ $ vim /etc/systemd/system/autossh-tresh.service

        [Unit]
        Description=Autossh tresh: Maintain a ssh reverse tunnel to a control server
        # After=network.target
        After=network-online.target
        
        [Service]
        # User=autossh
        User=pi
        Group=pi
        # -p [PORT]
        # -l [user]
        # -M 0 --> no monitoring
        # -N Just open the connection and do nothing (not interactive)
        # LOCALPORT:IP_ON_EXAMPLE_COM:PORT_ON_EXAMPLE_COM
        # ExecStart=/usr/bin/autossh -M 0 -N -q \
        # -o "ServerAliveInterval 60" -o "ServerAliveCountMax 3" \
        # -p 22 -l autossh remote.example.com \
        # -L 7474:127.0.0.1:7474 -i /home/autossh/.ssh/id_rsa
        TimeoutStartSec=3
        TimeoutStopSec=3
        ExecStart=/usr/bin/autossh -M 20000 -N -C -q \
        -o "ServerAliveInterval 60" -o "ServerAliveCountMax 3" \
        -p 22 -l tooreht tjmp -R 22000:localhost:22 \
        -i /home/pi/.ssh/id_rsa
        # ExecStart=/home/pi/scripts/autossh-tresh.sh
        Restart=always
        
        [Install]
        WantedBy=multi-user.target
2. Enable service
        
        systemctl enable autossh-tresh.service

### Detect Waspmote Gateaway USB via udev

1. Add udev rule

        pi@raspberrypi:~ $ vim  /etc/udev/rules.d/99-tresh.rules

        SUBSYSTEM=="tty", ACTION=="add", \
        ATTRS{manufacturer}=="FTDI", \
        ATTRS{product}=="FT232R USB UART",\
          PROGRAM="/bin/systemd-escape \
          -p --template=tresh-gateway@.service $env{DEVNAME} $env{ID_FS_LABEL}",\
          ENV{SYSTEMD_WANTS}+="%c"
2. Add tresh-gateway@ systemd service

        pi@raspberrypi:~ $ vim /etc/systemd/system/tresh-gateway@.service

        [Unit]
        Description=tresh siot gateway
        BindTo=%i.device
        After=%i.device
        After=rc-local.service

        [Service]
        Type=oneshot
        TimeoutStartSec=0
        ExecStart=/home/pi/scripts/tresh-gateway.sh /%I
        # RemainAfterExit=yes
3. Prepeare adding bash script

        mkdir -p /var/log/tresh
        touch /var/log/tresh/tresh-gateway.log
4. Add bash script tresh-gateway.sh

        vim ~/scripts/tresh-gateway.sh

        #!/bin/bash
        LOG=/var/log/tresh/tresh-gateway.log
        cd /home/pi/src/tresh/gateway/tresh-siot-gateway
        DEVNAME=$1 node multi-sensor.js $1 | tee $LOG
6. Set permissions
        
        chmod  u+x /home/pi/src/tresh/gateway/tresh-siot-gateway
7. Check USB insertion via systemd journal

        journalctl -xn --follow

### Connect to WPA Enterprise

1. Add wpa configs

        vim /etc/wpa_supplicant/wpa_supplicant.conf
        country=CH
        ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
        update_config=1
        
        # Locked BFH network
        network={
            ssid="bfh"
            key_mgmt=WPA-EAP IEEE8021X
            eap=PEAP
            auth_alg=OPEN
            phase1="peaplabel=0"
            phase2="auth=MSCHAPV2"
            identity="insert-your-bfh-identity-here"
            password="insert-your-password-here"
            priority=100
        }
    
        # Open BFH network
        network={
            ssid="public-bfh"
            key_mgmt=NONE
            priority=0
        }
2. Reboot

        sudo reboot
3. Check status

        sudo wpa_cli status

        Selected interface 'wlan0'
        bssid=b8:be:bf:b7:e3:f0
        freq=2412
        ssid=bfh
        id=0
        mode=station
        pairwise_cipher=CCMP
        group_cipher=CCMP
        key_mgmt=WPA2/IEEE 802.1X/EAP
        wpa_state=COMPLETED
        ip_address=147.87.46.112
        p2p_device_address=b8:27:eb:aa:73:e7
        address=b8:27:eb:aa:73:e7
        Supplicant PAE state=AUTHENTICATED
        suppPortStatus=Authorized
        EAP state=SUCCESS
        selectedMethod=25 (EAP-PEAP)
        EAP TLS cipher=ECDHE-RSA-AES256-SHA
        EAP-PEAPv0 Phase2 method=MSCHAPV2 uuid=edcd5979-ee8d-52ec-9c5e-5d3b6ed664c2

## Misc

### Access RPI via ssh reverse tunnel

    1. eval `ssh-agent -s`
    2. ssh-add
    3. ssh -N -R 22000:localhost:22 tjmp or autossh -M 20000 -f -N tjmp -R 22000:localhost:22 -C
    ssh -p 22000 pi@localhost
