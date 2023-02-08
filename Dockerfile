# syntax=docker/dockerfile:1.4

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

FROM ubuntu:18.04

RUN apt-get update -y && \ 
    apt-get install -y sudo nmap net-tools ufw vim iptables

# repo: can be 'repos', 'repos-staging', 'repos-snapshot'
# Optional. The default is 'repos'.
ARG repo

# version: can be '22.05' and '21.11'
# Optional. The default is '22.05'.
ARG version

# type: can be
# 'code' - Collabora Online Development Edition
# 'cool' - Collabora Online, to build this you need to give your secret URL part from https://support.collaboraoffice.com, i.e. you have to be Collabora partner or customer
# 'key'  - Collabora Online, the license key enabled version.
# Optional. The default is 'code'.
ARG type

# Optional. If defined then brand package will not be installed.
ARG nobrand

# Environment variables
ENV LC_CTYPE C.UTF-8

# Setup scripts for Collabora Online
COPY /scripts/install-collabora-online-ubuntu.sh /
RUN --mount=type=secret,id=secret_key bash install-collabora-online-ubuntu.sh
RUN rm -rf /install-collabora-online-ubuntu.sh

# Start script for Collabora Online
COPY /scripts/start-collabora-online.sh /
COPY /scripts/start-collabora-online.pl /

RUN chmod +x start-collabora-online.sh
RUN chmod +x start-collabora-online.pl

EXPOSE 9980

RUN useradd -m admin && echo "admin:admin" | chpasswd && adduser admin sudo

# switch to cool user (use numeric user id to be compatible with Kubernetes Pod Security Policies)
USER 104

# Entry point
CMD ["/start-collabora-online.sh"]