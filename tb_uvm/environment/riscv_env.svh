`ifndef __RISCV_ENV_SVH__
`define __RISCV_ENV_SVH__

class riscv_env extends uvm_env;

  riscv_reference_model ref_model;

  riscv_scoreboard #(riscv_input_item) input_sb;
  riscv_scoreboard #(riscv_output_item) output_sb;

  `uvm_component_utils(riscv_env)

  function new(string name = "riscv_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    ref_model = riscv_reference_model::type_id::create("ref_model", this);

    input_sb = riscv_scoreboard #(riscv_input_item)::type_id::create("input_sb", this);
    output_sb = riscv_scoreboard #(riscv_output_item)::type_id::create("output_sb", this);
  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    ref_model.output_data_ap.connect(output_sb.expected_ap);
  endfunction : connect_phase

endclass : riscv_env

`endif // __RISCV_ENV_SVH__