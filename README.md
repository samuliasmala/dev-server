# dev-server

Bootstrap scripts to quickly set up a new Ubuntu development server (real, WSL or Vagrant + Virtualbox)

Installation instructions

### Real Ubuntu

- Put ssh keyfiles and configs to `~/.ssh`
- Run `bootstrap-ubuntu.sh`

### WSL2 Ubuntu

- Open PowerShell as Administrator and run following four commands:

1. Enable WSL   
`dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart`  
If you only want to use WSL 1 restart computer and skip to step 5

2. Enable 'Virtual Machine Platform'  
`dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart`  
Restart the computer.

3. Update the WSL 2 Linux kernel: https://docs.microsoft.com/en-us/windows/wsl/wsl2-kernel

4. Set WSL 2 as default  
`wsl --set-default-version 2`

5. Install a distro from Microsoft Store (e.g. Ubuntu 20.04). If you had a distro already installed you need to set it to use WSL 2:  
Check available distros:  
`wsl --list --verbose`  
Change a distro to use WSL 2:  
`wsl --set-version <distribution name> <versionNumber>`  
e.g. `wsl --set-version Ubuntu 2`  
Docker installation MAY need this: `wsl --set-default Ubuntu`


- Install _DejaVu Sans Mono_ font from `dejavu-sans-mono.zip` (downloaded from [Nerdfonts](https://nerdfonts.com/))
- Change the Ubuntu terminal font to _DejaVu Sans Mono_ from _Properties_
- Enable "Use Ctrl+Shift+C/V as Copy/Paste"
- Disable terminal window Scroll-Forward from _Properties -> Terminal_ tab (available since Windows 10 May 2019 Update)
- Put ssh keyfiles and configs to `~/.ssh`
- Run `bootstrap-wsl2.sh`
- Install Docker [Docker Desktop WSL 2 backend](https://docs.docker.com/docker-for-windows/wsl/)
- Add user to Docker group to avoid the use of sudo: `sudo usermod -aG docker $USER`
- Install Docker Compose
```
sudo curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

- Load VS Code settings: Install _Settings Sync (shan.code-settings-sync)_, login with Github account, select correct Gist and download settings.

### Vagrant + Virtualbox

- Install `vagrant-disksize` plugin
- Run `vagrant up`
