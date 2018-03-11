# Introduction

This project is based on the work of LMtx (https://github.com/LMtx/ansible-lab-docker.git) with these changes:

* switched base image from Ubuntu to Centos 7
* removed ssh-agent and password protection from ssh key
* added ansible.cfg in lab directory for custom configuration
* created all-in-one Vagrant machine (centos7 + docker + containers) for users can't install directly docker
* added port-forward to access directly master01 container from main host (root@localhost:1022)
* added "screen" multiplexer to have an overview of all four "server" from a single terminal window

The aim of this guide is setup of [Ansible](https://www.ansible.com/) training environment using [Docker](https://www.docker.com/) containers. After finishing this tutorial you will have Docker master container that can manage three host containers (you can easily extend number of managed hosts to meet your needs).

Why I decided to use Docker instead of conventional virtualization like [VirtualBox](https://www.virtualbox.org/)? Docker containers consume much less resources so you can build bigger test environments on your laptop. Docker container is way faster to start/kill than standard virtual machine which is important when you experiment and bring the whole environment up and down. I used [Docker Compose](https://docs.docker.com/compose/overview/) to automate setup of lab environment (there is no need to maintain each container separately).

This Ansible lab is composed of four containers:

* master01: ansible node
* host01
* host02
* host03

**IMPORTANT**: In order to follow this tutorial you need to install Docker or Vagrant on your machine.

# Quick start

## Clone repository

Clone this git repository:

`git clone https://github.com/camandel/ansible-lab-docker.git`

## Build images and run containers

If you are on a Linux server with docker already installed enter directory containing [docker-compose.yml](./docker-compose.yml) file and build docker images and run containers in the background (details defined in [docker-compose.yml](./docker-compose.yml)):

`docker-compose up -d`

If you need a VM to run the lab install Vagrant and you hypervisor (tested with virtualbox and libvirt) and run:

`vagrant up`
vagrant ssh`

## Connect to **master node** (master01):

From the host running docker run:

`docker exec -it master01 bash`

or from vagrant:

`vagrant ssh
vagrant@ansible-lab $ sudo docker exec -it master01 bash`

or direcly from your host to master01 container (it exposes 1022 port to sshd service and Vagrant simply forwards host:1022 to guest:1022):

`ssh root@localhost -p 1022 # password is ansiblelab`

here you can start "screen" to have four windows opened on master01, host01, host02 and host03 (F11 or F12 to switch windows or regular screen command CTRL+a+n, CTRL+a+p):

`screen`

Verify if network connection is working between master and managed hosts:

`ping -c 2 host01`

or with ansible ad-hoc command:

`ansible -m ping all`

## Ansible playbooks

Run a [sample ansible playbook](./examples/ping_all.yml) that checks connection between master node and managed hosts:

`ansible-playbook -i examples/inventory ping_all.yml`

Install PHP on web **inventory group**:

Run a [sample ansible playbook](./examples/install_php.yml):

`ansible-playbook examples/install_php.yml`

## Copy data between local file system and containers

### Copy directory from container to local file system

`docker cp master01:/opt/ansible-lab/ .`

### Copy directory from local file system to container:

`docker cp ./demo.yml master01:/opt/ansible-lab/examples/`

You can check usage executing:

`docker cp --help`

## Cleanup

After you are done with your experiments or want to destroy lab environment to bring new one execute following commands.

Stop containers:

`docker-compose kill`

Remove containers:

`docker-compose rm`

Remove volume:

`docker volume rm ansible_ansible_vol`

If you want you can remove Docker images (although that is not required to start new lab environment):

`docker rmi ansible_host ansible_master ansible_base`

# Tips

In order to share public SSH key between **master** and **host** containers I used Docker **volume** mounted to all containers:

[docker-compose.yml](./docker-compose.yml):

    [...]
    volumes:
      - ansible_vol:/opt/ansible-lab
    [...]

Master container stores SSH key in that volume ([ansible/master/Dockerfile](./master/Dockerfile)):

    [...]
    WORKDIR /var/ans
    RUN ssh-keygen -t rsa -C "master key" -f master_key
    [...]

And host containers add SSH public key to authorized_keys file ([host/run.sh](./host/run.sh)) in order to allow connections from master:

    cat /opt/ansible-lab/master_key.pub >> /root/.ssh/authorized_keys

**IMPORTANT:** this is valid setup for lab environment but for production deployment you have to distribute the public key other way.

# Troubleshooting

## Host containers stop after creation

Check that [hosts/run.sh](./host/run.sh) has proper end of line type - it **should be Linux/Unix (LF)** not Windows (CRLF). You can change end of line type using source code editor (like Notepad++ or Visual Studio Code); under Linux you can use `dos2unix` command.

## Other issue

Please open an [issue](https://github.com/camandel/ansible-lab-docker/issues/new) and I'll try to help.
