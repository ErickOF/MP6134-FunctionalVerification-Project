`ifndef __RISCV_INPUT_ITEM_SVH__
`define __RISCV_INPUT_ITEM_SVH__

class riscv_input_item extends uvm_object;

  logic [31:0] instruction_data;
  logic [31:0] input_data;

  `uvm_object_utils_begin(riscv_input_item)
    `uvm_field_int(instruction_data, UVM_ALL_ON)
    `uvm_field_int(input_data, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "riscv_input_item");
    super.new(name);
  endfunction : new

endclass : riscv_input_item

`endif // __RISCV_INPUT_ITEM_SVH__