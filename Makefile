# Copyright (c) 2018, Marcelo Samsoniuk
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
## Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
## Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
## Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# VCS variables
#FILELIST = tb/filelist.f
FILELIST = tb_uvm/filelist.f
SIMDIR = darksocv_dir
XSIM = $(SIMDIR)/darksocv
VCDS = $(SIMDIR)/darksocv.vcd
TRCE = $(SIMDIR)/darksocv.txt
UVM_HOME = /mnt/vol_NFS_alajuela/qtree_NFS_rh003/synopsys_tools/synopsys/vcs-mx/O-2018.09-SP2-3/etc/uvm-1.2
VCS = vcs -sverilog -full64 -debug_access+all -gui +v2k +lint=all -Mdir=$(SIMDIR) \
        +acc +vpi -debug_access+nomemcbk+dmptf -debug_region+cell \
	+define+UVM_OBJECT_MUST_HAVE_CONSTRUCTOR \
	-ntb_opts uvm-1.2 \
	-timescale=1ns/1ps \
	-cm line+cond+fsm+branch+tgl -cm_dir ./coverage.vdb \
	-CFLAGS -DVCS

DEPS = $(FILELIST)

all: compile
	./$(XSIM) +vcs+dumpvars+$(VCDS) +UVM_TESTNAME=random_instr_test

compile: $(DEPS) $(SIMDIR)
	$(VCS) -f $(FILELIST) -o $(XSIM)

$(SIMDIR):
	mkdir -p $(SIMDIR)

clean:
	-rm -rf $(SIMDIR)
#	-rm -rf $(VCDS) $(XSIM) $(TRCE) csrc DVEfiles ucli.key $(XSIM).daidir

print_vcs:
	echo $(VCS)

.PHONY: clean all
