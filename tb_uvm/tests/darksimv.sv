import uvm_pkg::*;

`timescale 1ns / 1ps
`include "config.vh"
`include "riscv_defs.svh"
`include "helper.sv"
`include "instructions_pkg.svh"
`include "darkriscv_item.sv"
`include "darkriscv_seq.sv"
`include "darkriscv_driver.sv"
`include "darkriscv_monitor.sv"
`include "darkriscv_scoreboard.sv"
`include "darkriscv_agent.sv"
`include "darkriscv_env.sv"
`include "darkriscv_test.sv"

module darksimv();
  initial begin
    run_test();
  end
endmodule : darksimv
