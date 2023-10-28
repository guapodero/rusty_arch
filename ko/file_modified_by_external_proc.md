## Description
While saving text files to mounted directories with Helix, this error is often shown
> file modified by an external process, use :w! to overwrite

## References
https://github.com/helix-editor/helix/issues/7648

This could be related to the the way file modification times are updated by 9pfs.
https://wiki.qemu.org/Documentation/9psetup
https://www.kernel.org/doc/Documentation/filesystems/9p.txt
https://github.com/lima-vm/lima/blob/044cb12a43af464b379dc15bf833eea8cadcfb56/examples/default.yaml#L76

It might have to do with how system time is managed.
https://wiki.archlinux.org/title/System_time
https://sophiedogg.com/kvm-clocks-and-time-zone-settings/

A deep dive into the source appears to be in order here.
https://github.com/helix-editor/helix/blob/f992c3b5972dbe2432ceb55bc8d47fed912f88bf/helix-view/src/document.rs#L891

## Discussion
Helix uses `std::time::SystemTime` to track the initial modification time when the file is loaded or reloaded. Later
this is compared to the file modification time provided by `tokio::fs::metadata` which uses the `stat` system call.

## Workarounds
`w!`

Don't use Helix in mounted directories.
