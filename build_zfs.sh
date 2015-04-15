#!/bin/bash
#
# ZFS builder for boot2docker
# Explicitly using commit 5f91bd3 because of issues with both 0.6.3 and master at the moment :(
#
# Needs kernel config
# SPL=y
# ZFS=y

# SPL version v0.6.3-50_g917fef2
git clone https://github.com/zfsonlinux/spl.git /zfs/spl
cd /zfs/spl
git checkout 917fef273295616c563bbb0a5f6986cfce543d2f

#ZFS version v0.6.3-141_g5f91bd3
git clone https://github.com/zfsonlinux/zfs.git /zfs/zfs
cd /zfs/zfs
git checkout 5f91bd3dea49a529e87e0aa39595f074fd09736a


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
    --host=i686-pc-linux-gnu "CFLAGS=-m32" "CXXFLAGS=-m32" "LDFLAGS=-m32"
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
    --host=i686-pc-linux-gnu "CFLAGS=-m32" "CXXFLAGS=-m32" "LDFLAGS=-m32"
make
make install DESTDIR=/rootfs
