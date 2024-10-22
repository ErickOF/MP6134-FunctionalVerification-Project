import uvm_pkg::*;
import instructions_pkg::*;

`timescale 1ns / 1ps
`include "config.vh"
`include "riscv_defs.svh"
`include "helper.sv"
`include "instructions_pkg.svh"
`include "darkriscv_item.sv"
`include "darkriscv_seq.sv"
`include "init_registers_seq.sv"
`include "save_registers_seq.sv"
`include "random_instr_seq.sv"
`include "darkriscv_driver.sv"
`include "darkriscv_monitor.sv"
`include "darkriscv_scoreboard.sv"
`include "darkriscv_agent.sv"
`include "darkriscv_env.sv"
`include "random_instr_test.sv"
`include "darkriscv_test.sv"

module darksimv();
  initial begin
    run_test();
  end
endmodule : darksimv
