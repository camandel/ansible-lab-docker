#!/bin/bash

# add a master public key to authorized_keys on host in order to allow SSH connections
cat /opt/ansible-lab/keys/master01_key.pub >> /root/.ssh/authorized_keys

# start SSH server
/usr/sbin/sshd -D
