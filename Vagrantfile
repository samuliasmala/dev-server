# Requires plugin:
# vagrant plugin install vagrant-disksize

Vagrant.configure("2") do |config|
  config.vm.define "devbox"
  config.vm.hostname = "devbox"
  config.vm.box = "ubuntu/bionic64"

  config.disksize.size = '20GB'
  config.vm.network "public_network"

  config.vm.provider "virtualbox" do |vb|
    #vb.gui = true
    vb.memory = 6144
    vb.cpus = 2

    # Required to run Ubuntu VirtualBox under WSL
    # https://stackoverflow.com/questions/45773825/vagrant-with-virtualbox-on-wsl-verr-path-not-found
    vb.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]
  end

  # Port configuration
  config.vm.network "forwarded_port", guest: 8888, host: 8888, host_ip: "127.0.0.1" # phppgadmin
  config.vm.network "forwarded_port", guest: 8080, host: 8080, host_ip: "127.0.0.1"
  config.vm.network "forwarded_port", guest: 8081, host: 8081, host_ip: "127.0.0.1"
  config.vm.network "forwarded_port", guest: 8743, host: 8744, host_ip: "127.0.0.1"
  config.vm.network "forwarded_port", guest: 9229, host: 9229, host_ip: "127.0.0.1" # Node --inspect
  config.vm.network "forwarded_port", guest: 8089, host: 8089, host_ip: "127.0.0.1" # Locust control
  config.vm.network "forwarded_port", guest: 5858, host: 5858, host_ip: "127.0.0.1" # Node debug
  config.vm.network "forwarded_port", guest: 3000, host: 3000, host_ip: "127.0.0.1"
  config.vm.network "forwarded_port", guest: 5000, host: 5000, host_ip: "127.0.0.1" # Serve default port
  config.vm.network "forwarded_port", guest: 5432, host: 8432, host_ip: "127.0.0.1" # Postgresql for PgAdmin4

  # Use insecure_private_key for bootstrapping and vagrant_rsa after that to ssh into vm
  config.ssh.insert_key = false # Use the default insecure key instead of generating a new random one
  config.ssh.private_key_path = ["keys/vagrant_rsa", "~/.vagrant.d/insecure_private_key"]

  # Add vagrant key to authorized keys and GitHub as known host
  config.vm.provision "shell", privileged: false do |s|
    vagrant_rsa = File.readlines("./keys/vagrant_rsa.pub").first.strip
    githubHostKey = File.readlines("./keys/githubHostKey").first.strip
    s.inline = <<-SHELL
      echo #{vagrant_rsa} >> $HOME/.ssh/authorized_keys
      echo #{githubHostKey} >> $HOME/.ssh/known_hosts
    SHELL
  end

  # Copy local ssh key files to vm to allow git and ssh access to servers
  config.vm.provision "file", source: "~/.ssh/id_rsa", destination: "~/.ssh/id_rsa"
  config.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "~/.ssh/id_rsa.pub"

  # Copy ssh server definitions
  config.vm.provision "file", source: "~/.ssh/config", destination: "~/.ssh/config"

  # Copy bootstrap and .env files to vm
  config.vm.provision "file", source: "bootstrap-common.sh", destination: "~/bootstrap-common.sh"
  config.vm.provision "file", source: "bootstrap-vagrant.sh", destination: "~/bootstrap.sh"
  config.vm.provision "shell", privileged: false, inline: "echo Run ~/bootstrap.sh to finalize server setup"

  config.vm.synced_folder "./shared", "/vagrant"
end
