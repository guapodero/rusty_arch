## Rusty Arch
Virtual development environment for Rust, based on Arch Linux.

### Dependencies
- [VirtualBox 6.1](https://www.virtualbox.org/manual/)
- [Vagrant](https://developer.hashicorp.com/vagrant/docs)
- [SSHFS](https://github.com/libfuse/sshfs)

### Features
- usable offline or in a data center
- usable on legacy hardware (x86-64)
- compatible with Mac OS Catalina, no need for Homebrew or Xcode 

### Why Arch Linux?
The [philosophy behind Arch](https://en.wikipedia.org/wiki/Arch_Linux#Design_and_principles) and the community that has grown behind it makes it a delightful alternative to
MacOS and many other Linux distributions.

### Why Rust?
For many of the same reasons as Arch. An inclusive community and proper respect for the human time that is devoted to computing.

### Why SSHFS?
Using SSH as the only channel is simpler. NFS and SMB are very difficult to configure.

Benefits

- Supports *rustc* incremental compilation better than the default *vboxsf* [see reddit](https://www.reddit.com/r/rust/comments/7yy9a6/is_rustc_complaining_about_the_filesystem_for)
- Allows for differences in file system case-sensitivity between host and guest [see stackoverflow](https://stackoverflow.com/q/21562913)
- *vagrant-sshfs* plugin supports reverse mounts, used to access local documentation generated by *rustup*

Drawbacks

- no longer maintained [see github](https://github.com/libfuse/sshfs)
- not as performant as NFS or SMB

## Base System

- [archlinux/archlinux](https://app.vagrantup.com/archlinux/boxes/archlinux) Vagrant box provided by the Arch community
- [LTS kernel](https://archlinux.org/packages/core/x86_64/linux-lts/)
- [git](https://en.wikipedia.org/wiki/Git)
- [zsh](https://en.wikipedia.org/wiki/Z_shell)
- [ohmyzsh](https://ohmyz.sh/)
- [starship](https://starship.rs/)
- [lsd](https://crates.io/crates/lsd)
- [helix](https://helix-editor.com/)
- [zellij](https://zellij.dev/)
- [rustup](https://rust-lang.github.io/rustup/) (stable and nightly channels)
- [rust-analyzer](https://blog.rust-lang.org/2022/02/21/rust-analyzer-joins-rust-org.html)
- [gcc](https://en.wikipedia.org/wiki/GNU_Compiler_Collection)

## Usage
1. Install dependencies

    [VirtualBox 6.1](https://www.virtualbox.org/wiki/Download_Old_Builds_6_1)
    It's important to use this version to avoid errors related to package signatures (ex. `signature from "David Runge <dvzrv@archlinux.org>" is invalid`)
    [see attempted workarounds](https://wiki.archlinux.org/title/Pacman/Package_signing#Tips_and_tricks and https://bbs.archlinux.org/viewtopic.php?id=278478)
    
    [Vagrant](https://developer.hashicorp.com/vagrant/downloads)
    
    [SSHFS](https://github.com/libfuse/sshfs)
    Optional, but necessary for accessing local rust documentation
    
    [vagrant-sshfs](https://github.com/dustymabe/vagrant-sshfs) plugin

2. Prepare environment

    Ensure that `TZ` environment variable is set (ex. `TZ='America/New_York'`).
    Presumably this information is useful to the package manager [see arch wiki](https://wiki.archlinux.org/title/installation_guide#Time_zone)
    
    Customize `dot_config`, which will be copied to `~/.config` in the guest
    
    Create empty sibling directories to serve as share mounts. They are siblings to avoid overlapping with the repository directory,
    which is by default mounted to `/vagrant` [see vagrant docs](https://developer.hashicorp.com/vagrant/docs/synced-folders/basic_usage#disabling)
    
    ```
    # rust code lives here
    mkdir ../rusty_projects
    
    # mount point for accessing books and API documentation
    mkdir ../rusty_docs 
    ```

4. Build

    ```
    # creates the VM, but fails because vagrant-sshfs plugin can't
    # install sshfs in the guest yet (provisioner hasn't run yet)
    vagrant up
    
    # provision the VM
    vagrant up
    
    # install sshfs in the guest and mount shared directories
    vagrant sshfs --mount
    ```

5. Verify

    ```
    vagrant ssh 
    ```

    or alternatively use the helper script (manages a tunnel on port 5000)

    ```
    ./session.sh
    ```
    
    Rust documentation should be accessible with a web browser at file:///path/to/your/rusty_docs/html/std/index.html

6. Enjoy Rust! Programming is supposed to be fun.

## Related Work
1. [rust-sandbox](https://github.com/jameslmartin/rust-sandbox) is similar in intent but more opinionated