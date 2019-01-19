# BASE image - used as a starting point by MASTER and HOST images

FROM centos/systemd

# install required packages
RUN yum update -y && yum install -y openssh-server python iproute && yum clean all && rm -rf /var/cache/yum
# ensure that required directories are created
RUN ssh-keygen -A && mkdir /var/run/sshd && mkdir /root/.ssh
# ensure sshd is started at "boot"
RUN systemctl enable sshd

CMD ["/usr/sbin/init"]

EXPOSE 22
