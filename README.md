# archiso for Lenovo ThinkPad X13s

This repository contains a customized archiso preset for building images for the ThinkPad X13s ARM laptop. Pre-built images are available [here](https://ironrobin.net/linux-x13s/alpha/). Note: There is a regression right now, the last bootable image is archlinuxarm-2022.08.05-aarch64.iso, with Arch Linux 5.19.0-0-x13s


PKGBUILDs for the packages used in this image can be found [here](https://github.com/szclsya/x13s-alarm).

## Installation
The instructions in installation guide in `/root` mostly apply, however there are some things specific to the X13s to be aware of:

 * The internal drive is `/dev/nvme0n1`, and USB storage will be `/dev/sdX`.
 * On the internal drive, by default there is an existing EFI system partition `/dev/nvme0n1p1`.
 * Currently, the regular `linux-aarch64` and `linux-aarch64-rc` kernels don't work, until this is sorted out you can use the `x13s` repository included in the image (see `/etc/pacman.conf`) and install `linux-x13s` from it.
 * The `x13s` repo will be missing from the target system's `pacman.conf`, make sure to edit it and add this if you want to use Leo's prebuilt packages
```
[x13s]
Server = https://lecs.dev/repo
```

You'll need to trust the public key in order to verify package signature:

```bash
# Run as root
curl -O https://lecs.dev/repo/public.asc
pacman-key --add public.asc
pacman-key --lsign 9FD0B48BBBD974B80A3310AB6462EE0B8E382F3F
```
