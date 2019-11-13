FROM ubuntu:latest

ENV DEBIAN_FRONTEND noninteractive

ENV USER pulseaudio
ENV UID 1000
ENV GROUPS audio
ENV HOME /home/${USER}

RUN sed -i 's/archive.ubuntu.com/mirrors.163.com/g' /etc/apt/sources.list \
    && apt update && apt upgrade -y

RUN apt install -y pulseaudio pulseaudio-utils tzdata\
    && apt -y autoremove \
    && apt -y clean

COPY [ "./default.pa", "./client.conf", "./daemon.conf", "/etc/pulse/" ]

RUN useradd -u ${UID} -m -d ${HOME} -s /usr/sbin/nologin ${USER} \
    && usermod -aG ${GROUPS} ${USER} \
    && chmod 0644 -- /etc/pulse/* \
    && mkdir -p ${HOME}/.config/pulse \
    && chown -Rh ${USER}:${USER} -- ${HOME}

RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata

WORKDIR ${HOME}
USER ${USER}
VOLUME [ "/tmp", "${HOME}/.config/pulse" ]
ENTRYPOINT [ "/usr/bin/pulseaudio" ]