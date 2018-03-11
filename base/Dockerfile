# BASE image - used as a starting point by MASTER and HOST images

# I use official Ubuntu 17.10 image as a starting point
FROM centos:7

# install required packages
RUN yum update -y && yum install -y openssh-server python && yum clean all && rm -rf /var/cache/yum

# ensure that required directories are created
RUN ssh-keygen -A && mkdir /var/run/sshd && mkdir /root/.ssh
