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
FILELIST_LAYERS = tb/filelist.f
FILELIST_UVM    = tb_uvm/filelist.f
SIMDIR = darksocv_dir
XSIM = $(SIMDIR)/darksocv
VCDS = $(SIMDIR)/darksocv.vcd
TRCE = $(SIMDIR)/darksocv.txt
VCS = vcs -sverilog -full64 -debug_access+all +v2k +lint=none -Mdir=$(SIMDIR)
VCS_UVM = $(VCS) \
	+acc +vpi -debug_access+dmptf -debug_region+cell \
	+define+UVM_OBJECT_MUST_HAVE_CONSTRUCTOR \
	-ntb_opts uvm-1.2 \
	-timescale=1ns/1ps \
	-cm line+cond+fsm+branch+tgl -cm_dir ./coverage.vdb \
	-CFLAGS -DVCS
VCS_GUI_LAYERS = $(VCS) -gui
VCS_GUI_UVM = $(VCS_UVM) -gui

DEPS_LAYERS = $(FILELIST_LAYERS)
DEPS_UVM = $(FILELIST_UVM)

layers: compile_layers
	./$(XSIM) +vcs+dumpvars+$(VCDS)

compile_layers: $(DEPS_LAYERS) $(SIMDIR)
	$(VCS) -f $(FILELIST_LAYERS) -o $(XSIM)

layers_gui: compile_layers_gui
	./$(XSIM) +vcs+dumpvars+$(VCDS)

compile_layers_gui: $(DEPS_LAYERS) $(SIMDIR)
	$(VCS_GUI_LAYERS) -f $(FILELIST_LAYERS) -o $(XSIM)

uvm: compile_uvm
	./$(XSIM) +vcs+dumpvars+$(VCDS) +UVM_TESTNAME=random_instr_test

compile_uvm: $(DEPS_UVM) $(SIMDIR)
	$(VCS_UVM) -f $(FILELIST_UVM) -o $(XSIM)

uvm_gui: compile_uvm_gui
	./$(XSIM) +vcs+dumpvars+$(VCDS) +UVM_TESTNAME=random_instr_test

compile_uvm_gui: $(DEPS_UVM) $(SIMDIR)
	$(VCS_GUI_UVM) -f $(FILELIST_UVM) -o $(XSIM)

$(SIMDIR):
	mkdir -p $(SIMDIR)

clean:
	-rm -rf $(SIMDIR) DVEfiles ucli.key vc_hdrs.h .inter.vpd.uvm  inter.vpd
#	-rm -rf $(VCDS) $(XSIM) $(TRCE) csrc DVEfiles ucli.key $(XSIM).daidir

print_vcs:
	echo $(VCS)

print_vcs_uvm:
	echo $(VCS_UVM)

.PHONY: clean all
