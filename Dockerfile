FROM ubuntu:xenial

ENV DEBIAN_FRONTEND noninteractive

# Supervisor (rigormortiz/ubuntu-supervisor:0.1)
RUN apt-get update -y && \
    apt-get install -y supervisor && \
    apt-get autoclean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* 

# xrdp
RUN apt-get update -y && \
    apt-get install -y xrdp && \
    apt-get autoclean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    useradd -ms /bin/bash desktop && \
    sed -i '/TerminalServerUsers/d' /etc/xrdp/sesman.ini && \
    sed -i '/TerminalServerAdmins/d' /etc/xrdp/sesman.ini && \
    xrdp-keygen xrdp auto && \
    echo "desktop:desktop" | chpasswd

# mate desktop
RUN apt-get update -y && \
    apt-get install -y mate-core \
    mate-desktop-environment mate-notification-daemon \
    gconf-service libnspr4 libnss3 fonts-liberation \
    libappindicator1 libcurl3 fonts-wqy-microhei firefox && \
    apt-get autoclean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    echo "mate-session" > /home/desktop/.xsession

# ssh
RUN apt-get update && apt-get install -y openssh-server sudo &&\
    adduser desktop sudo &&\
    sed -re "s/PasswordAuthentication\s.*/PasswordAuthentication yes/g" -i /etc/ssh/sshd_config
RUN chown desktop:desktop /home/desktop && mkdir /var/run/sshd

# My tools : java, deluge, jdowloader, tcpdump, nmap, 
RUN apt-get update && apt-get install -y tcpdump nmap deluged deluge-webui \
    lsof iftop nethogs net-tools


ADD sshd.conf /etc/supervisor/conf.d/sshd.conf
ADD deluged.conf /etc/supervisor/conf.d/deluged.conf
ADD xrdp.conf /etc/supervisor/conf.d/xrdp.conf

CMD ["/usr/bin/supervisord", "-n"]

EXPOSE 3389 22 8112

#ebconf: delaying package configuration, since apt-utils is not installed
