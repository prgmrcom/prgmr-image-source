# Overview

This set of scripts is used in the Prgmr.com Arch Linux install process.
The top-level script is named rdinit, and it will be the script that runs
as init from the initramfs on the autoinstall ISO.
rdinit was taken from the initramfs in the Arch Linux ISO and modified,
so that it performs an install procedure.

To get a network address from dhcp while building an image, we use the
udhcpc client from busybox, which is shipped in the Arch Linux initramfs.
I needed a script to properly build resolv.conf at install time, so I borrowed
the udhcpc script that Alpine Linux uses.
That is udhcpc.script in this directory.

rdinit does some initial configuration: loading modules, mounting filesystems,
bringing up the network interface, and copying files into place. Arch Linux
install media uses overlayfs for the root filesystem; it is the union of a
tmpfs and a read-only filesystem stored in a squashfs image. We do the same
thing in the autoinstall environment. We add a second directory to the
read-only part of the union. The arch-install-scripts directory is copied
there, so that it will be available in our new root filesystem. Finally, rdinit
does a switch_root to /new_root, where the union is mounted, executing
/archinstall-scripts/archinstall_archboot there. After switching root, we now
have all of the tools we need to do an Arch Linux install available at their
expected locations.

The archinstall_archboot script is responsible for installing Arch
Linux to a disk.  The disk is partitioned, a filesystem is made, and
the filesystem is mounted on the target directory /mnt.  The pacman
package manager is configured here.  Mirrors are chosen, and the
keyring holding package signing keys is initialized.  The pacstrap
script from Arch Linux is called to pull packages from the network and
install them to the target directory.

Additional files are copied into place or created in the target
directory.  These include /etc/default/grub, /etc/fstab, a systemd
service to populate the pacman keyring on first boot, and a network
definition for systemd-networkd.

Next, archinstall_archboot calls archinstall_finalize, while chrooted
into the target directory.  Arch provides the arch-chroot script to
handle all of the details of making a chroot, so we use that.  The
archinstall_finalize script is responsible for taking care of any
post-installation configuration.  As many configuration file
modifications are done in archinstall_finalize as possible, because we
do not need to prefix filenames with the target directory /mnt.  Most
of the config file changes done in archinstall_finalize could be done
in archinstall_archboot, but working in a chroot makes mistakes less
likely.

A few tasks must by necessity be performed from a chroot.  Here, we
enable all of the systemd services that will be needed by a running
Arch Linux system.  We install and configure the GRUB 2 bootloader,
generating an initial /boot/grub/grub.cfg.  Finally, we clear the
pacman package cache, to avoid bloating the image with cached package
files.  At this point, installation is nearly complete.

There is one final post-installation task: a symlink needs to be made
at /etc/resolv.conf, pointing to systemd-resolved's
dynamically-generated resolv.conf.  It can't be done in the chroot,
because /etc/resolv.conf is a bind mount.  The symlink is made after
archinstall_finalize has finished.

Now we have an installable Arch Linux image.  The target filesystem is
cleanly unmounted, and the auto-installer terminates.

# Credits

Files in archinstall-scripts are very heavily based on
[https://github.com/prgmrcom/archinstall-scripts](https://github.com/prgmrcom/archinstall-scripts).
Thanks to Jason Randolph Eads and the others who contributed to that
repository.

udhcpc.script came from Alpine Linux:
[link to file on GitHub](https://github.com/alpinelinux/aports/raw/master/main/busybox-initscripts/default.script)
