#!/bin/sh

mkdir -p /tmp/cifs
nqnd &
nqbr &
insmod /home/drivers/cifs.ko CIFSMaxBufSize=130048
