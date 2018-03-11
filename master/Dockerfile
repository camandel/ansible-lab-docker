# MASTER image - used to create the master container to manage hosts

# use builded ansible_base (defined in ../base/Dockerfile) as a starting point
FROM ansible_base:latest

# install ansible package
RUN yum install -y ansible openssh-clients screen && yum clean all && rm -rf /var/cache/yum

# copy content of ansible directory from local disk to file system inside Docker image
COPY ansible /opt/ansible-lab/
COPY screenrc /root/.screenrc
COPY config /root/.ssh/

# change working directory
WORKDIR /opt/ansible-lab

# generate RSA key pair to allow master to communicate with managed nodes
# and set a password to access master01 directly from ssh client 
RUN chmod 600 /root/.ssh/config && mkdir keys && ssh-keygen -t rsa -C "master01 key" -f keys/master01_key && echo ansiblelab | passwd --stdin root

EXPOSE 22
