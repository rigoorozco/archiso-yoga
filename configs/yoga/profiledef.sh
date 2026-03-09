#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="archlinux-yoga"
iso_label="ARCH_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="Rigo Orozco Díaz <rigo.orozco.d@gmail.com>"
iso_application="ARM64 Arch Linux Live/Rescue Disk for Yoga C630"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('uefi.grub')
arch='aarch64'
kernel_format='Image'
dtb='sdm850-lenovo-yoga-c630.dtb'
pacman_conf="pacman.conf"
airootfs_image_type="erofs"
#airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
airootfs_image_tool_options=('-zlz4hc,12')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '--long' '-19')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
)
