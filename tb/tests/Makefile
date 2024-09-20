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
VCS = vcs -sverilog -full64 -debug_all +v2k +lint=all
RTLS =  darksimv.v                      \
        ../../rtl/src/darksocv.v           \
        ../../rtl/src/darkbridge.v         \
        ../../rtl/src/darkuart.v           \
        ../../rtl/src/darkriscv.v          \
        ../../rtl/src/darkpll.v            \
        ../../rtl/src/darkram.v            \
        ../../rtl/src/darkio.v             \
        ../../rtl/src/darkcache.v          \
        ../../rtl/src/lib/mt48lc16m16a2_ctrl.v
        
INCS = ../../rtl/src/config.vh
XSIM = darksocv
VCDS = darksocv.vcd
TRCE = darksocv.txt

ifdef HARVARD
	SRCS = ../src/darksocv.rom.mem ../src/darksocv.ram.mem
else
	SRCS = ../src/darksocv.mem
endif

DEPS = $(SRCS) $(RTLS) $(INCS)

all: $(XSIM)
	./$(XSIM) +vcs+dumpvars+$(VCDS)

$(XSIM): $(DEPS)
	$(VCS) -I../rtl/src $(RTLS) -o $(XSIM)

clean:
	-rm -f $(VCDS) $(XSIM) $(TRCE) csrc DVEfiles ucli.key

.PHONY: clean all
