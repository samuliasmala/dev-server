# dev-server

Bootstrap scripts to quickly set up a new Ubuntu development server (real, WSL or Vagrant + Virtualbox)

Installation instructions

### Real Ubuntu

- Put ssh keyfiles and configs to `~/.ssh`
- Run `bootstrap-ubuntu.sh`

### WSL Ubuntu

- Install _DejaVu Sans Mono_ font from `dejavu-sans-mono.zip` (downloaded from [Nerdfonts](https://nerdfonts.com/))
- Change the Ubuntu terminal font to _DejaVu Sans Mono_ from _Properties_
- Disable terminal window Scroll-Forward from _Properties -> Terminal_ tab (available since Windows 10 May 2019 Update)
- Put ssh keyfiles and configs to `~/.ssh`
- Run `bootstrap-wsl.sh`

### Vagrant + Virtualbox

- Install `vagrant-disksize` plugin
- Run `vagrant up`
