FROM centos:centos7

LABEL io.openshift.expose-services="5901:tcp"

RUN yum -y update
# install wget, unzip lsof ...
RUN yum -y install curl wget zip unzip lsof nano iotop

# install nmon
WORKDIR /usr/bin
RUN curl -L -o nmon https://github.com/axibase/nmon/releases/download/16f/nmon_x86_rhel6 && \
	chmod +x nmon
WORKDIR /

# install ssh + make EASY password
RUN yum -y install openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:dark' | chpasswd
RUN mkdir -p /var/run/sshd
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''


USER root
ENV DISPLAY="" \
    HOME=/home/1001

RUN yum clean all && \
    yum update -y && \
    yum install -y epel-release

RUN yum clean all && \
    yum update -y && \
    yum install -y --setopt=tsflags=nodocs \
                   tigervnc-server \
    		           xorg-x11-server-utils \
                   xorg-x11-server-Xvfb \
                   xorg-x11-fonts-* \
                   xterm \
                   xrdp \
                   supervisor \
                   mlocate \
                   gnome-session && \
                   yum clean all && \
                   rm -rf /var/cache/yum

RUN yum install -y --setopt=tsflags=nodocs \
                  firefox \
                  net-tools \
                  yum clean all && \
                  rm -rf /var/cache/yum/*

RUN /bin/dbus-uuidgen --ensure
RUN useradd -u 1001 -r -g 0 -d ${HOME} -s /sbin/nologin -c "Kiosk User" kioskuser

ADD xstartup ${HOME}/.vnc/
RUN echo "${vncpassword}" | vncpasswd -f > ${HOME}/.vnc/passwd
RUN /bin/echo "/usr/bin/firefox" >> /home/1001/.vnc/xstartup

RUN chown -R 1001:0 ${HOME} && \
    chmod 775 ${HOME}/.vnc/xstartup && \
    chmod 600 ${HOME}/.vnc/passwd


WORKDIR /
ADD start.sh /

RUN chmod 775 start.sh

EXPOSE 5901 22 3350


ENTRYPOINT ["/start.sh"]