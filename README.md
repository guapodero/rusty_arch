## Rusty Arch
My development environment. I primarily work with the [Rust Programming Language](https://www.rust-lang.org/) on [Arch Linux](https://archlinux.org/).

### Dependencies
- [QEMU](https://www.qemu.org/download/#macos)
- [Lima](https://lima-vm.io/docs/installation/)

### Why Arch Linux?
The [philosophy behind Arch](https://en.wikipedia.org/wiki/Arch_Linux#Design_and_principles) and the community that has grown around it makes it delightful to work with.

### Why Rust?
For many of the same reasons as Arch. An inclusive community which appreciates the human time that is devoted to computing. Programs written in Rust tend to be very enjoyable to use.

### Why Lima?
Relatively new, but it's an improvement over Vagrant. Some advantages:
- Easier to use.
- Supports modern filesystems which are necessary to use `podman`.
- Creates QEMU virtual machines, which integrate more directly with CPUs than [VirtualBox 6](https://www.virtualbox.org/ticket/14217).

Lima 1.0 is coming soon with breaking changes:
https://github.com/lima-vm/lima/milestone/26

### Requirements
- frequent offline use
- x86-64
- MacOS Catalina
- no Homebrew or Xcode

## Base System

- [LTS kernel](https://archlinux.org/packages/core/x86_64/linux-lts/)
- [paru](https://github.com/Morganamilo/paru)
- [git](https://en.wikipedia.org/wiki/Git)
- [zsh](https://en.wikipedia.org/wiki/Z_shell)
- [ohmyzsh](https://ohmyz.sh/)
- [starship](https://starship.rs/)
- [lsd](https://crates.io/crates/lsd)
- [helix](https://helix-editor.com/)
- [zellij](https://zellij.dev/)
- [ripgrep](https://crates.io/crates/ripgrep)
- [riff](https://github.com/walles/riff/)
- [bat](https://github.com/sharkdp/bat)
- [rustup](https://rust-lang.github.io/rustup/)
- [rust-analyzer](https://blog.rust-lang.org/2022/02/21/rust-analyzer-joins-rust-org.html)
- [clang](https://clang.llvm.org/)
- [podman](https://podman.io/)
- [cross-rs](https://github.com/cross-rs/cross)
- [cargo-make](https://sagiegurari.github.io/cargo-make/)

Offline docs at http://localhost:9306

## Usage
`bin/lima_session.sh` will do everything short of installing dependencies.
