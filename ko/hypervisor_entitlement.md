## Description
When the VM is started, the following error is displayed
> QEMU binary "/opt/local/bin/qemu-system-x86_64" is not properly signed with the "com.apple.security.hypervisor" entitlement

## References
https://github.com/lima-vm/lima/issues/4#issuecomment-841907334

https://github.com/lima-vm/lima#error-killed--9

## Workarounds
Acknowledge the prompt every time the VM is started

This seems like the right idea but it doesn't work for me
`codesign --remove-signature /usr/local/bin/qemu-system-x86_64`
