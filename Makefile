COMPILER=vcs

FILELIST?=filelist
COMPILATION_FLAGS=-sverilog -full64 -gui -debug_access+all
COV_FLAGS=

ifdef COVEN
COV_FLAGS+=-cmline+tgl+assert
endif

compile:
		@$(COMPILER) -f $(FILELIST) $(COMPILATION_FLAGS) $(COV_FLAGS)

run:
		@./simv $(COV_FLAGS)

gen_cov:
		@Urg1 -full64 -dir simv.vdb

open_cov: gen_cov
		@firefox urgReport/dashboard.html
