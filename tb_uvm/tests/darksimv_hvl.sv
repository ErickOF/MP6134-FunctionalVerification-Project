`timescale 1ns / 1ps

import uvm_pkg::*;
import instructions_pkg::*;

`include "config.vh"
`include "helper.sv"
`include "base_instruction_checker.sv"
`include "i_type_checker.sv"
`include "s_type_checker.sv"
`include "darkriscv_input_item.sv"
`include "darkriscv_output_item.sv"
`include "darkriscv_item.sv"
`include "darkriscv_seq.sv"
`include "init_registers_seq.sv"
`include "save_registers_seq.sv"
`include "random_instr_seq.sv"
`include "darkriscv_driver.sv"
`include "darkriscv_monitor.sv"
`include "darkriscv_scoreboard.sv"
`include "darkriscv_agent.sv"
`include "darkriscv_reference_model.sv"
`include "darkriscv_env.sv"
`include "random_instr_test.sv"
`include "darkriscv_test.sv"

module darksimv_hvl();
  initial begin
    run_test();
  end
endmodule : darksimv_hvl
