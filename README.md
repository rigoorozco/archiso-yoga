# archiso for ARM64 Lenovo laptops

This repository contains customized Arch Linux ARM archiso profiles for supported Lenovo ARM64 laptops.

Supported device profiles:

| Device | Profile | ISO name | Device tree | Package repository |
| --- | --- | --- | --- | --- |
| Lenovo Yoga C630 | `configs/yoga` | `archlinux-yoga` | `sdm850-lenovo-yoga-c630.dtb` | `yoga-alarm` |
| Lenovo ThinkPad X13s | `configs/x13s` | `archlinux-x13s` | `sc8280xp-lenovo-thinkpad-x13s.dtb` | `ironrobin-x13s` |

Pre-built images are published in GitHub Releases for this project. The images include device-specific kernels, firmware, boot configuration, and setup helpers needed to make Arch Linux ARM boot reliably on the target hardware.

## Building

Build an image by passing the desired profile to `mkarchiso`:

```bash
sudo ./archiso/mkarchiso -v configs/yoga
```

or:

```bash
sudo ./archiso/mkarchiso -v configs/x13s
```

Generated images are written to `out/`.

## Publishing a release

After building an ISO, publish it with:

```bash
scripts/publish_release.sh
```

By default, the script uploads the newest `out/*.iso`, creates a SHA-256 checksum, and publishes both files to the configured GitHub repository. Use `-h` to see all options.

## Boot instructions

1. Download the latest pre-built image for your device.
2. Flash it to a USB drive:

```bash
sudo dd bs=4M if=archlinux-DEVICE-YYYY.MM.DD-aarch64.iso of=<DEV-TARGET> conv=fsync oflag=direct status=progress
```

3. Reboot the laptop and open the firmware boot menu.
4. Select the USB drive.

On Lenovo laptops, the boot menu is usually opened with `F12` while the Lenovo logo is shown.

## Installation notes

The standard Arch Linux [Installation guide](https://wiki.archlinux.org/title/Installation_guide) mostly applies, but these devices need their matching kernel, firmware, and package repository after installation.

Common notes:

* The internal NVMe drive is usually `/dev/nvme0n1`.
* USB storage usually appears as `/dev/sdX`.
* The existing EFI system partition can usually be reused if you do not want to create a new one.
* The live ISO pacman configuration includes the matching device repository, but the installed target system may need that repository added manually.

### Yoga C630

The Yoga profile uses the `yoga-alarm` package repository:

```ini
[yoga-alarm]
SigLevel = Required DatabaseOptional
Server = https://github.com/rigoorozco/yoga-alarm/releases/download/packages-latest
```

If the repository is missing from the installed system, add it to `/etc/pacman.conf` before installing or updating Yoga-specific packages.

### ThinkPad X13s

The X13s profile uses the `ironrobin-x13s` package repository:

```ini
[ironrobin-x13s]
Server = https://github.com/ironrobin/x13s-alarm/releases/download/packages
```

Currently, the regular `linux-aarch64` and `linux-aarch64-rc` kernels may not work on the X13s. Use the X13s-specific packages from the repository above when installing the target system.

Trust the package signing key before installing packages from the X13s repository:

```bash
sudo pacman-key --recv-keys 6ED02751500A833A
sudo pacman-key --lsign-key 6ED02751500A833A
```
