#!/bin/bash
#
# ZFS builder for boot2docker
# Explicitly using commit 5f91bd3 because of issues with both 0.6.3 and master at the moment :(
#
# Needs kernel config
# SPL=y
# ZFS=y

# Download SPL
git clone -b spl-0.6.5.8 https://github.com/zfsonlinux/spl.git /zfs/spl
cd /zfs/spl

# Download ZFS
git clone -b zfs-0.6.5.8 https://github.com/zfsonlinux/zfs.git /zfs/zfs
cd /zfs/zfs

# Configure and compile SPL kernel module
cd /zfs/spl
./autogen.sh
./configure \
    --prefix=/ \
    --libdir=/lib \
    --includedir=/usr/include \
    --datarootdir=/usr/share \
    --enable-linux-builtin=yes \
    --with-linux=/linux-kernel \
    --with-linux-obj=/linux-kernel \
    --with-config=kernel
./copy-builtin /linux-kernel

# Configure and cross-compile SPL usermode utils
./configure \
    --prefix=/ \
    --libdir=/lib \
    --includedir=/usr/include \
    --datarootdir=/usr/share \
    --enable-linux-builtin=yes \
    --with-linux=/linux-kernel \
    --with-linux-obj=/linux-kernel \
    --with-config=user \
    --build=x86_64-pc-linux-gnu \
    --host=x86_64-pc-linux-gnu
make
make install DESTDIR=/rootfs

# Configure and compile ZFS kernel module
cd /zfs/zfs
./autogen.sh
./configure \
    --prefix=/ \
    --libdir=/lib \
    --includedir=/usr/include \
    --datarootdir=/usr/share \
    --enable-linux-builtin=yes \
    --with-linux=/linux-kernel \
    --with-linux-obj=/linux-kernel \
    --with-spl=/zfs/spl \
    --with-spl-obj=/zfs/spl \
    --with-config=kernel
./copy-builtin /linux-kernel

# Configure and cross-compile ZFS usermode utils
./configure \
    --prefix=/ \
    --libdir=/lib \
    --includedir=/usr/include \
    --datarootdir=/usr/share \
    --enable-linux-builtin=yes \
    --with-linux=/linux-kernel \
    --with-linux-obj=/linux-kernel \
    --with-spl=/zfs/spl \
    --with-spl-obj=/zfs/spl \
    --with-config=user \
    --build=x86_64-pc-linux-gnu \
    --host=x86_64-pc-linux-gnu
make
make install DESTDIR=/rootfs
