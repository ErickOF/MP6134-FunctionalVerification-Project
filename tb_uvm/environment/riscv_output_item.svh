`ifndef __RISCV_OUTPUT_ITEM_SVH__
`define __RISCV_OUTPUT_ITEM_SVH__

class riscv_output_item extends uvm_object;

  logic [31:0] output_data;
  logic [31:0] data_address;
  logic [2:0] bytes_transfered;
  logic write_op;
  logic read_op;

  `uvm_object_utils_begin(riscv_output_item)
    `uvm_field_int(output_data, UVM_ALL_ON)
    `uvm_field_int(data_address, UVM_ALL_ON)
    `uvm_field_int(bytes_transfered, UVM_ALL_ON)
    `uvm_field_int(write_op, UVM_ALL_ON)
    `uvm_field_int(read_op, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "riscv_output_item");
    super.new(name);
  endfunction : new

endclass : riscv_output_item

`endif // __RISCV_OUTPUT_ITEM_SVH__