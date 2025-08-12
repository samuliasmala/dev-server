# dev-server

Bootstrap scripts to quickly set up a new Ubuntu development server (real, WSL or Vagrant + Virtualbox)

## Installation instructions

The first thing to do is to clone this repository to get access to scripts:
```bash
git clone https://github.com/samuliasmala/dev-server.git
```

Note: Following error when executing `psql` commands is caused by postgres user not having `x` permission to the working directory. It doesn't affect command result and it's fixed in PostgreSQL 16 (included in Ubuntu 24.04). For more information see [this answer](https://unix.stackexchange.com/questions/229069/could-not-change-directory-to-home-corey-scripts-permission-denied/773032#773032).

```
could not change directory to "/home/asmala": Permission denied
```

### Server
Run following commands as root from dev-server directory, e.g., `/root/dev-server`

```bash
# Install packages and add pm user
./server/root-bootstrap.sh
# Add regular user (samuli)
./server/root-add-user.sh
# Bootstrap regular and pm users
sudo -u samuli server/user-bootstrap.sh
sudo -u pm server/user-bootstrap.sh
# Add public key for ssh access
cat server/id_rsa.pub >> $(sudo -u samuli bash -c 'echo $HOME')/.ssh/authorized_keys
cat server/id_rsa.pub >> $(sudo -u pm bash -c 'echo $HOME')/.ssh/authorized_keys
# Change Postgres password for kuura
sudo -u postgres psql -c "ALTER USER kuura WITH ENCRYPTED PASSWORD 'new_password';"
# Disable ssh login using password
sudoedit /etc/ssh/sshd_config 
# Uncomment/add "PasswordAuthentication no" row
sudo systemctl reload sshd
```

Then do following steps (should be added to script at some point)
- Add `admin` user (gets automatically sudo rights from admin group)
- Add `admin` user to `adm` group so Apache logs can be accessed
- Add log rotation config to `/etc/logrotate.d/pm2` (example in `configs/logrotate`)


### Real Ubuntu

- Put ssh keyfiles and configs to `~/.ssh` directory: `tar xvf ssh-keys.tar.gz`
- Clone dev-server repository: `git clone git@github.com:samuliasmala/dev-server.git`
- Run `bootstrap-ubuntu.sh`

### WSL2 Ubuntu


**[New Windows versions](https://docs.microsoft.com/en-us/windows/wsl/install)**
1. Open PowerShell as Administrator and run the following commands:  
  `wsl --update` to make sure you're running the latest version  
  `wsl --version` to test you have latest version (command should work, if not try "Old Windows versions")  
  `wsl --install`  
  Note: if installing for another (second non-admin) user you must open PowerShell in normal mode (not as Administrator) and run `wsl --install -d Ubuntu` instead (this may also work for the first user who is admin and if so would be preferred installation method).  
  Note 2: It's best to use the command line. If Ubuntu is installed from the Microsoft Store then steps 1-5 from Old Windows versions has to be done manually.

1. Install Windows Terminal from Microsoft Store and set following settings:
    - Startup -> Default profile -> Ubuntu
    - Ubuntu -> Starting directory -> `~` (this should be default nowadays)

1. Put ssh keyfiles and configs to `~/.ssh` directory: `tar xvf ssh-keys.tar.gz`
1. Clone dev-server repository: `git clone git@github.com:samuliasmala/dev-server.git`
1. Run `./dev-server/bootstrap-wsl2.sh`
1. Install Docker [Docker Desktop WSL 2 backend](https://docs.docker.com/docker-for-windows/wsl/)
   - If installing for other than Administrator, add Windows user to docker-users group by running following command in PowerShell as Administrator after installation:  
   `net localgroup docker-users "your-user-id from C:\Users" /ADD`
1. Add Ubuntu user to Docker group to avoid the use of sudo: `sudo usermod -aG docker $USER`
1. Install [VcXsrv Windows X Server](https://sourceforge.net/projects/vcxsrv/)
1. Enable VS Code Backup and sync by logging in (under gear icon) with GitHub account

**[Old Windows versions](https://docs.microsoft.com/en-us/windows/wsl/install-manual)**

1. Open PowerShell as Administrator and run the following commands:

   1. Enable WSL   
   `dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart`  
   If you only want to use WSL 1 restart computer and skip to step 5
   
   1. Enable 'Virtual Machine Platform'  
   `dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart`  
   Restart the computer.
   
   1. Update the WSL 2 Linux kernel: https://docs.microsoft.com/en-us/windows/wsl/wsl2-kernel
   
   1. Set WSL 2 as default  
   `wsl --set-default-version 2`
   
   1. Install a distro from Microsoft Store (e.g. Ubuntu 20.04). If you had a distro already installed you need to set it to use WSL 2:  
   Check available distros:  
   `wsl --list --verbose`  
   Change a distro to use WSL 2:  
   `wsl --set-version <distribution name> <versionNumber>`  
   e.g. `wsl --set-version Ubuntu 2`  
   Docker installation MAY need this: `wsl --set-default Ubuntu`
1. Install _DejaVu Sans Mono_ font from `dejavu-sans-mono.zip` (downloaded from [Nerdfonts](https://nerdfonts.com/))
1. Change the Ubuntu terminal font to _DejaVu Sans Mono_ from _Properties_
1. Enable "Use Ctrl+Shift+C/V as Copy/Paste"
1. Disable terminal window Scroll-Forward from _Properties -> Terminal_ tab (available since Windows 10 May 2019 Update)
1. Put ssh keyfiles and configs to `~/.ssh`
1. Run `bootstrap-wsl2.sh`
1. Install Docker [Docker Desktop WSL 2 backend](https://docs.docker.com/docker-for-windows/wsl/)
1. Add user to Docker group to avoid the use of sudo: `sudo usermod -aG docker $USER`
1. Load VS Code settings: Install _Settings Sync (shan.code-settings-sync)_, login with Github account, select correct Gist and download settings.

### Vagrant + Virtualbox

- Install `vagrant-disksize` plugin
- Run `vagrant up`
