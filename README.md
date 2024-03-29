# dev-server

Bootstrap scripts to quickly set up a new Ubuntu development server (real, WSL or Vagrant + Virtualbox)

## Installation instructions

Note: Following error when executing `psql` commands is caused by postgres user not having `x` permission to the working directory. It doesn't affect command result and it's fixed in PostgreSQL 16. For more information see [this answer](https://unix.stackexchange.com/questions/229069/could-not-change-directory-to-home-corey-scripts-permission-denied/773032#773032).

```
could not change directory to "/home/asmala": Permission denied
```

### Real Ubuntu

- Put ssh keyfiles and configs to `~/.ssh` directory: `tar xvf ssh-keys.tar.gz`
- Clone dev-server repository: `git clone git@github.com:samuliasmala/dev-server.git`
- Run `bootstrap-ubuntu.sh`

### WSL2 Ubuntu


**[New Windows versions](https://docs.microsoft.com/en-us/windows/wsl/install)**
1. Open PowerShell as Administrator and run the following command:  
  `wsl --install`  
  Note: it may be necessary to run `wsl --install -d Ubuntu` instead (even though this should be the default option)  
  Note 2: It's best to use the command line. If Ubuntu is installed from the Microsoft Store then steps 1-5 from Old Windows versions has to be done manually.

1. Install Windows Terminal from Microsoft Store and set following settings:
    - Startup -> Default profile -> Ubuntu
    - Ubuntu -> Starting directory -> `~`

1. Put ssh keyfiles and configs to `~/.ssh` directory: `tar xvf ssh-keys.tar.gz`
1. Clone dev-server repository: `git clone git@github.com:samuliasmala/dev-server.git`
1. Install Docker [Docker Desktop WSL 2 backend](https://docs.docker.com/docker-for-windows/wsl/)
1. Add user to Docker group to avoid the use of sudo: `sudo usermod -aG docker $USER`
1. Install [VcXsrv Windows X Server](https://sourceforge.net/projects/vcxsrv/)

**[Old Windows versions](https://docs.microsoft.com/en-us/windows/wsl/install-manual)**

- Open PowerShell as Administrator and run the following commands:

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
- Load VS Code settings: Install _Settings Sync (shan.code-settings-sync)_, login with Github account, select correct Gist and download settings.

### Vagrant + Virtualbox

- Install `vagrant-disksize` plugin
- Run `vagrant up`
