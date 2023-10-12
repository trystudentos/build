#!/bin/bash

# Define variables for the script
ISO_NAME="mydebian.iso"
TARGET_DIR="/tmp/debian-iso"
DEBIAN_SUITE="buster"
ARCHITECTURE="amd64"

# Create a working directory
mkdir -p "$TARGET_DIR"

# Install necessary tools
apt-get update
apt-get install -y debootstrap syslinux squashfs-tools genisoimage

# Create a minimal Debian system using debootstrap
debootstrap --arch=$ARCHITECTURE $DEBIAN_SUITE "$TARGET_DIR" http://deb.debian.org/debian/

# Customize the system (e.g., install packages, configure settings)

# Create a squashfs filesystem
mksquashfs "$TARGET_DIR" "$TARGET_DIR/live/filesystem.squashfs"

# Create an ISO directory and copy necessary files
mkdir -p "$TARGET_DIR/iso"
cp /usr/lib/ISOLINUX/isolinux.bin "$TARGET_DIR/iso/"
cp /boot/memtest86+.bin "$TARGET_DIR/iso/"
cp "$TARGET_DIR/live/filesystem.squashfs" "$TARGET_DIR/iso/"
cp -r "$TARGET_DIR/boot" "$TARGET_DIR/iso/"

# Create the isolinux configuration
cat > "$TARGET_DIR/iso/isolinux.cfg" << EOF
UI menu.c32

prompt 0
menu title Debian Live

label debian
  menu label ^Boot Debian
  kernel /live/vmlinuz
  append initrd=/live/initrd.img boot=live

label memtest86
  menu label ^Memory Test
  kernel /live/memtest86+.bin

label hdt
  menu label ^Hardware Detection Tool
  kernel /live/hdt.c32
  append modules=loop,squashfs
EOF

# Create the ISO
mkisofs -r -V "Debian Live" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o "$ISO_NAME" "$TARGET_DIR/iso"

# Clean up
rm -rf "$TARGET_DIR"

echo "ISO created: $ISO_NAME"
