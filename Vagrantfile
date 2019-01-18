Vagrant.configure('2') do |config|

  config.vm.hostname = 'ansible-lab.local'
  config.vm.box = "centos/7"

  config.vm.network :forwarded_port, guest: 2022, host: 2022
  config.vm.network :forwarded_port, guest: 8001, host: 8001
  config.vm.network :forwarded_port, guest: 8002, host: 8002
  config.vm.network :forwarded_port, guest: 8003, host: 8003

  config.vm.provider :virtualbox do |vb|
    vb.name = 'ansible-lab'
    vb.customize ['modifyvm', :id, '--memory', '1024', '--cpus', '1']
  end

  config.vm.provision "file", source: ".", destination: "$HOME/ansible-lab"

  config.vm.provision :shell do |shell|
    shell.inline = <<-SHELL
      sudo yum -y install epel-release
      sudo yum -y install docker docker-compose dos2unix
      sudo systemctl start docker
      sudo systemctl enable docker
      cd ansible-lab && find . -type f | xargs dos2unix
      sudo docker-compose up -d
    SHELL
  end

  config.vm.post_up_message = "To connect directly to master01 from your PC:\n\n  ssh root@localhost -p 2022 (password is ansiblelab)\n\nthen type 'screen' to connect to host01m host02 and host03\n\nLocal ports 800[1-2] will be redirected to port 80 of host0[1-3]"

end
