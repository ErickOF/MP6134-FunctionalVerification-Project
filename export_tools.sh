#!/bin/bash

export SNPSLMD_LICENSE_FILE=27000@172.21.9.211
export SYNOPSYS_HOME=/mnt/vol_NFS_alajuela/qtree_NFS_rh003/synopsys_tools/synopsys
export VCS_HOME=/mnt/vol_NFS_alajuela/qtree_NFS_rh003/synopsys_tools/synopsys/vcs-mx/O-2018.09-SP2-3
export PATH=$PATH:$VCS_HOME/linux64/bin
export GIT_HOME="$(cd "$(dirname "$BASH_SOURCE")"; pwd)"
export UVM_HOME=/mnt/vol_NFS_alajuela/qtree_NFS_rh003/synopsys_tools/synopsys/vcs-mx/O-2018.09-SP2-3/etc/uvm-1.2
