FROM ubuntu:latest

RUN sed -i 's/archive.ubuntu.com/mirrors.163.com/g' /etc/apt/sources.list 

RUN apt update && apt -y upgrade \
    && apt -y install vim net-tools curl wget ca-certificates locales

RUN mkdir -p /etc/apt/sources.list.d \
    && touch /etc/apt/sources.list.d/deepin.list \
    && echo "deb [trusted=yes] https://mirrors.huaweicloud.com/deepin stable main contrib non-free" > /etc/apt/sources.list.d/deepin.list \
    && dpkg --add-architecture i386

RUN apt update \
    && apt install -y  --allow-downgrades perl-base=5.24.1-3+deb9u5 \
    && apt install -y perl=5.24.1-3+deb9u5 \
    && apt install -y udis86 libgif7 libreadline7 libpng16-16 libjpeg62-turbo libgnutls30 libgstreamer1.0-0 libgstreamer-plugins-base1.0-0 zenity fonts-wqy-microhei ttf-ubuntu-font-family ttf-wqy-zenhei firefox

# ENV VERSION: latest

RUN apt install -y deepin-fonts-wine deepin-libwine deepin-wine32 deepin-wine deepin-wine32-preloader deepin-wine-binfmt deepin-wine-helper deepin-wine-plugin deepin-wine-plugin-virtual deepin-wine-uninstaller

# ENV VERSION=2.18-18

# RUN mkdir -p /home/downloads && cd /home/downloads \
#     && wget https://mirrors.huaweicloud.com/deepin/pool/non-free/d/deepin-wine/deepin-fonts-wine_${VERSION}_all.deb && apt install -y ./deepin-fonts-wine_2.18-18_all.deb \
#     && wget https://mirrors.huaweicloud.com/deepin/pool/non-free/d/deepin-wine/deepin-libwine_${VERSION}_i386.deb && apt install -y ./deepin-libwine_2.18-18_i386.deb \
#     && wget https://mirrors.huaweicloud.com/deepin/pool/non-free/d/deepin-wine/deepin-libwine-dbg_${VERSION}_i386.deb && apt install -y ./deepin-libwine-dbg_2.18-18_i386.deb \
#     && wget https://mirrors.huaweicloud.com/deepin/pool/non-free/d/deepin-wine/deepin-libwine-dev_${VERSION}_i386.deb && apt install -y ./deepin-libwine-dev_2.18-18_i386.deb \
#     && wget https://mirrors.huaweicloud.com/deepin/pool/non-free/d/deepin-wine/deepin-wine32_${VERSION}_i386.deb && apt install -y ./deepin-wine32_2.18-18_i386.deb \
#     && wget https://mirrors.huaweicloud.com/deepin/pool/non-free/d/deepin-wine/deepin-wine_${VERSION}_all.deb && apt install -y ./deepin-wine_2.18-18_all.deb \
#     && wget https://mirrors.huaweicloud.com/deepin/pool/non-free/d/deepin-wine/deepin-wine-binfmt_${VERSION}_all.deb && apt install -y ./deepin-wine-binfmt_2.18-18_all.deb \
#     && wget https://mirrors.huaweicloud.com/deepin/pool/non-free/d/deepin-wine/deepin-wine32-preloader_${VERSION}_i386.deb && apt install -y ./deepin-wine32-preloader_2.18-18_i386.deb \
#     && wget https://mirrors.huaweicloud.com/deepin/pool/non-free/d/deepin-wine/deepin-wine32-tools_${VERSION}_i386.deb && apt install -y ./deepin-wine32-tools_2.18-18_i386.deb \
#     && apt install -y deepin-wine-plugin deepin-wine-plugin-virtual deepin-wine-helper deepin-wine-uninstaller

ENV LC_CTYPE=en_US.UTF-8 XMODIFIERS="@im=fcitx"

RUN locale-gen en_US.UTF-8 zh_CN.UTF-8 zh_CN.GBK \
    && update-locale LANG=en_US.UTF-8

RUN /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone

COPY ./run.sh /home/run.sh

COPY ./wine-qqmusic-linux-i386.deb /home/wine-qqmusic-linux-i386.deb

COPY ./deepin-wine-tools/run.sh /opt/deepinwine/tools/run.sh

RUN dpkg -i /home/wine-qqmusic-linux-i386.deb \
    && apt -y clean \
    && apt -y autoremove

RUN chmod a+x /home/run.sh

CMD [ "/bin/bash", "-c", "/home/run.sh" ]