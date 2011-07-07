#!/bin/sh
# Patch script is executed just before RELEASE is launched.
# At that time you have no USB and no network
# This script is for patching memory (RELEASE) with 
# commands like dd, cat, devmem, hexdump, etc...

# Address at which LGAPP is mounted LGAPP_FS_ADDRESS=\`cat /proc/xipfs\`

# RELEASE is a first file in LGAPP_FS and is aligned in kernel PAGE_SIZE=0x1000
# RELEASE_BASE_ADDRESS=\$((LGAPP_FS_ADDRESS+PAGE_SIZE))

# So can patch RELEASE this way:
# 1. Read value to patch, for example country feature, you have to know its offset in RELEASE
#VALUE=\`devmem \$((RELEASE_BASE_ADDRESS+country_feature_offset)) 32\`
# 2. Patch value
#NEWVALUE=\$((VALUE|maskmodifier))
# 3. Write patched value
#devmem \$((RELEASE_BASE_ADDRESS+country_feature_offset)) 32 \$NEWVALUE
