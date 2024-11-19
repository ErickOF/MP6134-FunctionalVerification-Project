#!/bin/sh
# Define the number of seeds to run per test
max=3
# Compile the environment
make compile_uvm
# Actual run of the tests
for i in `seq 2 $max`
do
	echo "$i"
	make uvm_run_b_instr_test
	make uvm_run_darkriscv_base_test
	make uvm_run_darkriscv_instr_base_test
	make uvm_run_i_instr_test
	make uvm_run_j_instr_test
	make uvm_run_l_instr_test
	make uvm_run_r_instr_test
	make uvm_run_random_instr_test
	make uvm_run_s_instr_test
	make uvm_run_u_instr_test
done
# Create the coverage database report using Synopsys URG tool
/mnt/vol_NFS_alajuela/qtree_NFS_rh003/synopsys_tools/synopsys/vcs-mx/O-2018.09-SP2-3/bin/urg -dir coverage.vdb/
# Open the coverage dashboard
firefox urgReport/dashboard.html

