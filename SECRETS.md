## Secrets
Don't store sensitive information in a VM.

### SSH Keys
Install 1password in your host OS and enable the SSH Agent.
https://developer.1password.com/docs/ssh/agent/

#### Agent Forwarding
~/.ssh/config (host)

```
Host *
    IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    ForwardAgent true
```

#### Commit Signing
~/.gitconfig (guest)

```
[user]
    username = guapodero
    email = 568034+guapodero@users.noreply.github.com
    signingkey = ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA3V9SNCgRlA4meWgvjagvSqSBmIi+wkUJJT1i4ajvIH
[gpg]
    format = ssh
[commit]
    gpgsign = true
```

https://1password.community/discussion/135317/how-do-i-use-the-1password-ssh-agent-without-installing-the-1password-gui


### Other Secrets
1password can be accessed by shell scripts using the 1password-cli AUR. Several other actively maintained integrations can be found on github.
