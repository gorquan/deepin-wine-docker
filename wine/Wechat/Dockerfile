FROM ubuntu:latest

RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list 

RUN apt update && apt -y upgrade \
    && apt -y install vim net-tools curl wget ca-certificates locales

RUN mkdir -p /etc/apt/sources.list.d \
    && touch /etc/apt/sources.list.d/deepin.list \
    && echo "deb [trusted=yes] https://mirrors.huaweicloud.com/deepin stable main contrib non-free" > /etc/apt/sources.list.d/deepin.list \
    && dpkg --add-architecture i386

RUN apt update \
    && apt install -y  --allow-downgrades perl-base=5.24.1-3+deb9u5 \
    && apt install -y perl=5.24.1-3+deb9u5 \
    && apt install -y udis86 libgif7 libreadline7 libpng16-16 libjpeg62-turbo libgnutls30 libgstreamer1.0-0 libgstreamer-plugins-base1.0-0 zenity fonts-wqy-microhei fonts-wqy-zenhei firefox

RUN apt install -y deepin-fonts-wine deepin-libwine deepin-wine32 deepin-wine deepin-wine32-preloader deepin-wine-binfmt deepin-wine-helper deepin-wine-plugin deepin-wine-plugin-virtual deepin-wine-uninstaller

ENV LC_CTYPE=zh_CN.UTF-8 XMODIFIERS="@im=fcitx"

RUN locale-gen en_US.UTF-8 zh_CN.UTF-8 zh_CN.GBK \
    && update-locale LANG=zh_CN.UTF-8

RUN apt install -y deepin.com.wechat \
    && apt -y autoremove \
    && apt -y clean

COPY ./run.sh /home/run.sh

RUN chmod a+x /home/run.sh

CMD [ "/bin/bash", "-c", "/home/run.sh" ]