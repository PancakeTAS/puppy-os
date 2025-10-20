# Configs

Assuming you just installed PuppyOS to your SD card, the next step is to set up the data partition to contain the files needed to actually boot the system.

After Linux is loaded, it will mount the root filesystem as read only. It is not recommended to touch the root filesystem, as it will be overriden by the puppyos installer. An initial shell script will be executed and mount the virtual filesystems, alongside the data partition.

The important part is that the init system will mount the following paths from the data partition:
- `/etc`
- `/root`
- `/opt`
- `/var/lib`
- `/var/cache`
- `/var/db`
- `/var/tmp`

You may read the [Filesystem Hierarchy Standard](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/index.html) for more information on these paths, but the gist is that all four paths in `/var/` are used for storing information such as DHCP leases or DNS caches, the `/root` and `/etc` paths should be obvious and the `/opt` path is for adding semi-permanent optional software to the system (because anything in `/usr` is read-only without a rebuild).

## Essential System Files

While none of these files are technically required, most userspace processes won't run properly.

Let's create two users, `root` and `nobody`. The `nobody` user is a privilege separation user, intended for programs to run that need to be isolated from the rest of the system:
```bash
# /etc/passwd (https://linux.die.net/man/5/passwd)
root:x:0:0::/root:/usr/bin/dash
nobody:x:1:1::/var/empty:/usr/bin/false
# /etc/group (https://linux.die.net/man/5/group)
root:x:0:root
nobody:x:1:nobody
```

While the system does not bundle shadow (modern password authentication), some programs do require the files to exist:
```bash
# /etc/shadow (https://linux.die.net/man/5/shadow)
root::::::::
nobody::::::::
# /etc/gshadow (https://linux.die.net/man/5/gshadow)
root:::root
nobody:::nobody
```

These files are also important:
```bash
# /etc/hosts (https://linux.die.net/man/5/hosts)
127.0.0.1 localhost
::1 localhost
# /etc/shells (https://linux.die.net/man/5/shells)
/usr/bin/sh
/usr/bin/dash
# /etc/resolv.conf (https://linux.die.net/man/5/resolv.conf)
nameserver 1.1.1.1
```

Finally, you should create these files as well:
- `/etc/services` and `/etc/protocols` (grab [here](https://github.com/Mic92/iana-etc))
- `/etc/localtime` should symlink to `/usr/share/zoneinfo/Europe/Berlin` (or similar)

## Setting up the init system

I personally like to set up my system in a way where `/etc/sv.d` contains a bunch of shell scripts, which are executed in order of filename on boot.
If you decide to go this route too, you should create at least one file already:
```bash
# /etc/sv.d/10-apply-sysctl
#!/bin/sh
sysctl --system
```

This will read `/etc/sysctl.conf` and similar files and apply the rules within. Make sure to set the executable bit on the file!

Let's actually set up the init system. The moment `runit` is started, it will execute the `/etc/runit/1` file. Once this file is done, it will move onto `/etc/runit/2`. This file should not exit, because if it does, the system will move onto `/etc/runit/3`, which is the shutdown script.

Create the `/etc/runit` directory and the following files as well:
- `/etc/runit/reboot` should symlink to `/run/runit/reboot`
- `/etc/runit/stopit` should symlink to `/run/runit/stopit`

Then set up the init, runtime and shutdown scripts:
```bash
# /etc/runit/1
#!/bin/sh

for script in /etc/sv.d/*; do
    "$script"
done

mkdir -p /run/runit
install -m000 /dev/null /run/runit/stopit
install -m000 /dev/null /run/runit/reboot
# /etc/runit/2
#!/bin/sh

runsvchdir default

ln -s /etc/runit/runsvdir/current /run/runit/service
exec env - PATH=$PATH runsvdir -P /run/runit/service 'log: ...........................................................................................................................................................................................................................................................................................................................................................................................................'
# /etc/runit/3
#!/bin/sh

sv -w3 force-stop /run/runit/service/*
sv exit /run/runit/service/*

pkill --inverse -s0,1 -TERM
sleep 3
pkill --inverse -s0,1 -KILL

sync

mount -o remount,ro /dev/mmcblk0p5

swapoff -a

umount -anr
```

As you can see, the first script executes the file from `sv.d` and creates two file for runit. The script `2` changes the runlevel to default and then executes the service manager. Finally the script `3` stops the service manager, kills all processes both nicely and not so nicely, then remounts the data partition as read only before unmounting all and turning off any swap. If you're interested, read more about the init system [here](https://smarden.org/runit/) (it's worth it!).

We need to create the runlevel as well:
- `/etc/sv` will contain future services
- `/etc/runsvdir` should be a directory
- `/etc/runsvdir/current` should be a relative symlink to `default`
- `/etc/runsvdir/default` is the runlevel executed by the script `2` and contains all active services. It should be a directory.

## Setting up a shell

Before our system is fully usable, we'll need to tell runit to start a shell on the serial output. I don't recommend you skip this step, as it also shows how the init system works.

When `dash` is launched as a login shell, it will read `/etc/profile` to set itself up. You should create this file and make sure it is executable:
```bash
export UID=0
export PATH="/usr/bin"
export TERM="linux"
export LOGNAME="root"
export USER="root"
export HOME="/root"
export SHELL="/bin/dash"
export PS1='$USER@$HOSTNAME $PWD \$ '
export HOSTNAME=puppy-os
export LANG=C.UTF-8

alias ls='ls --color=auto'
alias grep='grep --color=auto'

set -E

cd $HOME
```

Now we need to create a service for dash (make sure it is executable!):
```bash
# /etc/runit/sv/dash-ttyS0/run
#!/bin/sh
exec setsid -c /usr/bin/dash -limE </dev/ttyS0 >/dev/ttyS0 2>&1
```

This will start `dash` as a controlling shell on `/dev/ttyS0`.

In order to add it to the runlevel, add a symlink `/etc/runit/runsvdir/default/dash-ttyS0` pointing at `../../sv/dash-ttyS0`. This will make `runsvdir` launch the service.

## General recommendations

The editor installed with PuppyOS is `vim`. It is recommended to create a basic `.vimrc` in the `/root` folder. Here's mine:
```toml
" make backspace more useful
set backspace=indent,eol,start

" show line numbers
set number
highlight LineNr ctermfg=4

" setup tab
set tabstop=4
set shiftwidth=4
set expandtab

" enable mouse
set mouse=a

" show useful things
set showmatch
set hlsearch
set incsearch

" smart search
set ignorecase
set smartcase

" show command
set showcmd

" show statusline
set laststatus=2

" autoindent
set autoindent
set smartindent
```

The next things you should probably do are these:
- Set up your network devices using scripts in `/etc/sv.d` or create a service for dhcpcd.
- Set up sshd, ntpd, hostapd, dnsmasq and other daemons using services.
- Set up logging in your services (see runit documentation).
