## Rusty Arch
My development environment. I primarily work with the [Rust Programming Language](https://www.rust-lang.org/)
on [Arch Linux](https://archlinux.org/).

### Dependencies
- [QEMU](https://www.qemu.org/download/#macos)
- [Lima](https://lima-vm.io/docs/installation/)

### Why Arch Linux?
The [philosophy behind Arch](https://en.wikipedia.org/wiki/Arch_Linux#Design_and_principles) and the community that
has grown around it makes it delightful to work with.

### Why Rust?
For many of the same reasons as Arch. An inclusive community which appreciates the human time that is devoted to
computing. Programs written in Rust tend to be very enjoyable to use.

### Why Lima?
Relatively new, but it's an improvement over Vagrant. Some advantages:
- Easier to use.
- Supports modern filesystems which are necessary to use `podman`.
- Creates QEMU virtual machines, which integrate more directly with CPUs than
  [VirtualBox 6](https://www.virtualbox.org/ticket/14217).

### Use Case
- Intel Mac (MacOS 10.15 Catalina)
- minimal dependencies (no Homebrew, Xcode, Docker)
- frequent offline use (not supported yet)

## Base System

- [LTS kernel](https://archlinux.org/packages/core/x86_64/linux-lts/)
- [paru](https://github.com/Morganamilo/paru) AUR helper
- [git](https://en.wikipedia.org/wiki/Git)
- [zsh](https://en.wikipedia.org/wiki/Z_shell)
- [starship](https://starship.rs/) easily customizable shell prompt
- [lsd](https://crates.io/crates/lsd) colorized and configurable `ls` replacement
- [helix](https://helix-editor.com/) modal editor
- [zellij](https://zellij.dev/) terminal workspace
- [ripgrep](https://crates.io/crates/ripgrep) fast and easy `grep` replacement
- [riff](https://github.com/walles/riff/) more readable `diff` formatter
- [bat](https://github.com/sharkdp/bat) `cat` replacement
- [skim](https://github.com/lotabout/skim) fuzzy finder
- [rustup](https://rust-lang.github.io/rustup/) stable toolchain
- [rust-analyzer](https://blog.rust-lang.org/2022/02/21/rust-analyzer-joins-rust-org.html) LSP server
- [clang](https://clang.llvm.org/) LSP server
- [podman](https://podman.io/) container runtime
- [cross-rs](https://github.com/cross-rs/cross) simplified cross-compilation
- [cargo-binstall](https://github.com/cargo-bins/cargo-binstall) binary installer
- [cargo-make](https://sagiegurari.github.io/cargo-make/) build tool and more
- [httplz](https://crates.io/crates/https) static file server

Offline Rust documentation at http://localhost:9306

## Usage
`bin/lima_session.sh vm_name [session_name | .] # . = force new session`
- interact with `limactl` to create a new virtual machine
- start up existing VM and attach to existing zellij session
- to close a session: `Ctrl d`
- to detach from it: `Ctrl o` `d`
- the VM will remain running until you stop it with `limactl`

I use [Alacritty](https://alacritty.org/) as my terminal emulator. If I close the terminal window on an open session,
QEMU doesn't send a signal to zellij in the same way that VirtualBox did, so the `on_force_close` setting in zellij has
no effect. To prevent myself from accidentally terminating the QEMU process with my keyboard, I disabled those key
combinations in `~/.alacritty.yml`:
```
key_bindings:
# prevent closing window by keyboard accidentally
# https://github.com/alacritty/alacritty/issues/3426
  - { key: Q,      mods: Command,            action: None             }
  - { key: W,      mods: Command,            action: None             }
```

### Example
```
bin/lima_session.sh arch rust
gh_clone guapodero/pulso && rg_open TODO
```

### Known Issues
Unable to start or ssh to a VM while offline.
https://github.com/lima-vm/lima/issues/1422

Lima 1.0 is coming soon with breaking changes.
https://github.com/lima-vm/lima/milestone/26

### Known Obstacles
Tracked in the [ko](ko/) directory. These are being passively worked on.
