# -*- mode: ruby -*-
# vi: set ft=ruby :

if not ENV["TZ"]
  raise "environment variable 'TZ' needs to be set (ex. TZ='America/Argentina/Buenos_Aires')"
end 

Vagrant.configure("2") do |config|
  config.vm.define "dev"
  config.vm.box = "archlinux/archlinux"
  config.vm.box_check_update = false

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
  end
  
  config.vm.provision "vm", type: "shell", path: "provision.sh", env: { "TZ" => ENV["TZ"] }

  if File.directory?("dot_config")
    config.vm.provision "config", type: "file", source: "dot_config/.", destination: "$HOME/.config"
  end

  config.vm.synced_folder "../rusty_projects", "/home/vagrant/rusty_projects",
    type: "sshfs"
 
  config.vm.synced_folder "../rusty_docs", "/home/vagrant/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/share/doc/rust",
    type: "sshfs",
    reverse: true,
    sshfs_opts_append: "-o volname=rusty_docs"

  # remove reverse mounts
  config.trigger.before [:halt, :reload] do |trigger|
    trigger.run = { inline: "vagrant sshfs --unmount" }
  end
end
