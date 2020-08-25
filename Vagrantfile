Vagrant.configure('2') do |config|

  config.vm.hostname = 'ansible-lab.local'
  config.vm.box = "centos/8"

  config.vm.network :forwarded_port, guest: 2022, host: 2022
  config.vm.network :forwarded_port, guest: 8001, host: 8001
  config.vm.network :forwarded_port, guest: 8002, host: 8002
  config.vm.network :forwarded_port, guest: 8003, host: 8003

  config.vm.provider :virtualbox do |virtualbox|
    virtualbox.name = 'ansible-lab'
    virtualbox.customize ['modifyvm', :id, '--memory', '1024', '--cpus', '1']
  end

  config.vm.provider :libvirt do |libvirt|
    libvirt.memory = 1024
    libvirt.cpus = 1
  end

  config.vm.provision "file", source: ".", destination: "$HOME/ansible-lab"

  config.vm.provision :shell do |shell|
    shell.inline = <<-SHELL
      sudo getenforce 0
      sudo sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux  
      sudo dnf update -y
      sudo dnf -y install https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.2.6-3.3.el7.x86_64.rpm
      sudo dnf -y install yum-utils epel-release
      sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
      sudo dnf -y install docker-ce docker-ce-cli dos2unix --nobest
      sudo curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
      sudo chmod +x /usr/local/bin/docker-compose
      sudo systemctl start docker
      sudo systemctl enable docker
      cd ansible-lab && find . -type f | xargs dos2unix
      sudo /usr/local/bin/docker-compose up -d
    SHELL
  end

  config.vm.post_up_message = "To connect directly to master01 from your PC:\n\n  ssh root@localhost -p 2022 (password is ansiblelab)\n\nthen type 'screen' to connect to host01m host02 and host03\n\nLocal ports 800[1-2] will be redirected to port 80 of host0[1-3]"

end
