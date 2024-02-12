# ehough/docker-kodi - Dockerized Kodi with audio and video.
#
# https://github.com/ehough/docker-kodi
# https://hub.docker.com/r/erichough/kodi/
#
# Copyright 2018-2020 - Eric Hough (eric@tubepress.com)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

FROM debian:bookworm-slim

# https://github.com/ehough/docker-nfs-server/pull/3#issuecomment-387880692
ARG DEBIAN_FRONTEND=noninteractive

# install the team-xbmc ppa
RUN apt update
RUN apt -y purge openssl
RUN apt -y --purge autoremove
RUN apt -y upgrade
# Bugfix for: installed kodi package post-installation script subprocess returned error exit status 1
# either install udev or make the required directory 
RUN apt install uuid-dev
#    mkdir -p /etc/udev/rules.d
RUN rm -rf /var/lib/apt/lists/*                                           

# besides kodi, we will install a few extra packages:
#  - ca-certificates              allows Kodi to properly establish HTTPS connections
#  - kodi-eventclients-kodi-send  allows us to shut down Kodi gracefully upon container termination
#  - kodi-game-libretro           allows Kodi to utilize Libretro cores as game add-ons
#  - kodi-game-libretro-*         Libretro cores
#  - kodi-inputstream-*           input stream add-ons
#  - kodi-peripheral-*            enables the use of gamepads, joysticks, game controllers, etc.
#  - kodi-pvr-*                   PVR add-ons
#  - kodi-screensaver-*           additional screensavers
#  - lirc,lirc-compat-remotes     enables the use of IR Remotes
#  - locales                      additional spoken language support (via x11docker --lang option)
#  - pulseaudio                   in case the user prefers PulseAudio instead of ALSA
#  - tzdata                       necessary for timezone selection
RUN packages="                                               \
    fbset                                                         \
    ca-certificates                                          \
    mesa-*                                                   \
    kodi                                                     \
    kodi-eventclients-kodi-send                              \
    kodi-inputstream-adaptive                                \
    kodi-inputstream-rtmp                                    \
    kodi-peripheral-joystick                                 \
    kodi-pvr-argustv                                         \
    kodi-pvr-dvblink                                         \
    kodi-pvr-dvbviewer                                       \
    kodi-pvr-filmon                                          \
    kodi-pvr-hdhomerun                                       \
    kodi-pvr-hts                                             \
    kodi-pvr-iptvsimple                                      \
    kodi-pvr-mediaportal-tvserver                            \
    kodi-pvr-mythtv                                          \
    kodi-pvr-nextpvr                                         \
    kodi-pvr-njoy                                            \
    kodi-pvr-pctv                                            \
    kodi-pvr-sledovanitv-cz                                  \
    kodi-pvr-stalker                                         \
    kodi-pvr-teleboy                                         \
    kodi-pvr-vbox                                            \
    kodi-pvr-vdr-vnsi                                        \
    kodi-pvr-vuplus                                          \
    kodi-pvr-wmc                                             \
    kodi-pvr-zattoo                                          \
    kodi-pvr-hts                                             \
    kodi-screensaver-biogenesis                              \
    kodi-screensaver-pyro                                    \
    lirc                                                     \
    lirc-compat-remotes                                      \
    locales                                                  \
    pulseaudio                                               \
    libnss3                                                  \
    tzdata"                                               && \
                                                             \
    apt update                                        && \
    apt install -y $packages                          

# Add python for netflix plugin
RUN sudo apt install python3-pip python3-cryptography build-essential python3-all-dev            \
                         python3-setuptools python3-wheel                && \
    pip install --break-system-packages pycryptodomex                                                               && \
    ln -s /usr/lib/python3/dist-packages/Crypto /usr/lib/python3/dist-packages/Cryptodome   && \
    apt -y --purge autoremove                                                           && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd -g 9002 kodi && useradd -u 9002 -r -g kodi kodi && usermod -a -G video kodi

ADD /asound.conf /etc/asound.conf

# setup entry point
COPY entrypoint.sh /usr/local/bin
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
