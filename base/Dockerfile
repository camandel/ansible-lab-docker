# BASE image - used as a starting point by MASTER and HOST images

FROM centos:8

ENV container docker

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;

# install required packages
RUN dnf update -y && dnf install -y openssh-server python3 iproute && yum clean all && rm -rf /var/cache/yum
# ensure that required directories are created
RUN ssh-keygen -A && mkdir /var/run/sshd && mkdir /root/.ssh
# ensure sshd is started at "boot"
RUN systemctl enable sshd
# add alias and remove warning
RUN echo "alias ll='ls -l'" > /etc/profile.d/ll.sh

VOLUME [ "/sys/fs/cgroup" ]

CMD ["/usr/sbin/init"]

EXPOSE 22
