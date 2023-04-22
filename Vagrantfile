# -*- mode: ruby -*-
# vi: set ft=ruby :

for k in ["TZ", "UID", "GID"]
  if not ENV[k]
    raise "environment variable '#{k}' needs to be exported"
   end
end

Vagrant.configure("2") do |config|
    config.vm.define "dev"
    config.vm.box = "archlinux/archlinux"
    config.vm.box_check_update = false

    config.vm.provider "virtualbox" do |vb|
        vb.memory = "4096"
        vb.cpus = 2
    end
  
    config.vm.provision "vm", type: "shell", path: "provision.sh", env: { "HOST_TZ" => ENV["TZ"], "HOST_UID" => ENV["UID"], "HOST_GID" => ENV["GID"] }

    if File.directory?("dot_config")
        config.vm.provision "config", type: "file", source: "dot_config/.", destination: "$HOME/.config"
    end

    config.vm.synced_folder ".", "/vagrant",
        type: "sshfs",
        sshfs_opts_append: "-o idmap=file,uidfile=/etc/sshfs/uidfile,gidfile=/etc/sshfs/gidfile,cache=no,compression=yes,ciphers=arcfour"

    if File.directory?("../rusty_docs")
        config.vm.synced_folder "../rusty_docs", "/home/vagrant/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/share/doc/rust",
            type: "sshfs",
            reverse: true,
            sshfs_opts_append: "-o volname=rusty_docs"
    end

    # remove reverse mounts
    config.trigger.before [:halt, :reload] do |trigger|
        trigger.run = { inline: "vagrant sshfs --unmount" }
    end
end
