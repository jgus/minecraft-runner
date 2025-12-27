FROM ubuntu

ARG java_ver=21

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

RUN apt update && \
    apt install -y \
    sudo \
    openjdk-$java_ver-jre-headless \
    openssh-server
COPY auth.conf /etc/ssh/sshd_config.d/

COPY entrypoint.sh /
COPY start.sh /usr/local/bin
COPY stop.sh /usr/local/bin
COPY command.sh /usr/local/bin

# User and group are created at runtime in entrypoint.sh
# This allows UID/GID to be set via environment variables

EXPOSE 22/tcp \
       8123/tcp \
       19132/udp \
       19133/udp \
       25565/tcp \
       25565/udp

# SSH keys and authorized_keys are injected at runtime via volume mount
# See README.md for setup instructions

CMD ["/bin/bash", "-c", "/entrypoint.sh"]