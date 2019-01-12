Vagrant.configure('2') do |config|

  config.vm.hostname = 'ansible-lab.local'
  config.vm.box = "centos/7"

  config.vm.network :forwarded_port, guest: 2022, host: 2022

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

  config.vm.post_up_message = "To connect directly to master01 from your PC:\n\n  ssh root@localhost -p 2022 (password is ansiblelab)\n\nthen type 'screen' to connect to host01m host02 and host03"

end
