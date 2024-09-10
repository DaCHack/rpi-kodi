# dachack/rpi-kodi
[![docker-hub Actions Status](https://github.com/dachack/rpi-kodi/workflows/docker-hub/badge.svg)](https://github.com/dachack/rpi-kodi/actions)

Dockerized [Kodi](https://kodi.tv/) with audio and video.

Works on amd64 Fujitsu Futro S740

## Features

* fully-functional [Kodi](https://kodi.tv/) installation in a [Docker](https://www.docker.com/) container
* **audio** ([ALSA or PulseAudio](https://kodi.wiki/view/Linux_audio)) and **video**
* simple, Debian-slim image that adheres to the [official Kodi installation instructions](https://kodi.wiki/view/HOW-TO:Install_Kodi_for_Linux#Installing_Kodi_on_Ubuntu-based_distributions)
* clean shutdown of Kodi when its container is terminated

## Host Prerequisites

The host system will need the following:

1. **Linux** and [**Docker**](https://www.docker.com)

   This image should work on any Linux distribution with a functional Docker installation.
   
3. **A connected display and speaker(s)**
       
## Usage

```yml
services:
  rpi-kodi:
    image: dachack/rpi-kodi
    container_name: "kodi"
    user: kodi
    network_mode: host
    restart: unless-stopped
    privileged: true
    devices:
      - /dev/fb0:/dev/fb0
      - /dev/dri:/dev/dri
      - /dev/snd:/dev/snd
      - /dev/input/event3:/dev/input/event3   #Add my USB mouse and keyboard based on "evtest" output
      - /dev/input/event4:/dev/input/event4
      - /dev/input/event5:/dev/input/event5
      - /dev/input/event6:/dev/input/event6
      - /dev/input/event7:/dev/input/event7
      - /dev/input/event8:/dev/input/event8
      - /dev/input/event9:/dev/input/event9
    volumes:
      - /home/administrator/kodi/home:/home/kodi
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
      - /var/run/dbus:/var/run/dbus
      - /run/udev:/run/udev
    tmpfs:
      - /tmp
#    environment:
#      - PULSE_SERVER=127.0.0.1
```
WARNING: it requires the --privileged flag which is risky. Please let me know if you have an idea how to remove it.

NOTE: This container is aimed to run in a Proxmox VM and thus selects the second sound card as the default device. If you run it natively, please edit asound.conf_alsa and rebuild the container or use asound.conf in the dockerfile instead!

 * If you want to have the home directory outside of the container (e.g. /home/pi/kodi/home:/home/kodi) you need to add the following user to the host:

```
   groupadd -g 9002 kodi && useradd -u 9002 -r -g kodi kodi
```
   and make sure this user is the owner of the home directory:
```
   chown -R kodi:kodi /home/pi/kodi/home
```
   
## Kodi-Control
### Kore-App
I am using the Kore-App for Remote-Control:
 * [Android](https://play.google.com/store/apps/details?id=org.xbmc.kore&hl=de&gl=US)
 * [iOS](https://apps.apple.com/de/app/official-kodi-remote/id520480364)

To enable it, you have to enable the Kodi webserver by creating the file 
`/home/pi/kodi/home/.kodi/userdata/advancedsettings.xml` 
with the following content:
```xml
<advancedsettings>
    <services>
        <esallinterfaces>true</esallinterfaces>
        <webserver>true</webserver>
        <zeroconf>true</zeroconf>
    </services>
</advancedsettings>
```

### Local Control
The current configuration does not allow access on keyboard or mouse.
If you want to use them you probably have to mount these devices in the container.
Please let me know if you have figured out how that works.
I am happy to add this to the Readme here.

### IR Remotes
In order to use IR remotes, add this device to your docker file:

```yml
      - /dev/lirc0:/dev/lirc0
```

Then once the container is created, you have to manually launch lircd in the container:

```sh
docker-compose exec  -u root kodi lircd
```

## Contributing
This docker project is based on [erichough/kodi](https://github.com/ehough/docker-kodi) and [rimago/rpi-kodi](https://github.com/rimago/rpi-kodi).

Constructive criticism and contributions are welcome! Please 
[submit an issue](https://github.com/dachack/rpi-kodi/issues/new) or 
[pull request](https://github.com/dachack/rpi-kodi/compare).
