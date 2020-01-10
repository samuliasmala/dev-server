# dev-server

Bootstrap scripts to quickly set up a new Ubuntu development server (real, WSL or Vagrant + Virtualbox)

Installation instructions

### Real

- Run `bootstrap-ubuntu.sh`

### WSL

- Install _DejaVu Sans Mono_ font from `dejavu-sans-mono.zip`
- Change the Ubuntu terminal font to _DejaVu Sans Mono_ from Properties
- Put ssh keyfiles and configs to `~/.ssh`
- Run `bootstrap-wsl.sh`

### Vagrant + Virtualbox

- Install `vagrant-disksize` plugin
- Run `vagrant up`
