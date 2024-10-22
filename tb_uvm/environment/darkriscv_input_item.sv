`ifndef _DARKRISCV_INPUT_ITEM_SV_
`define _DARKRISCV_INPUT_ITEM_SV_

class darkriscv_input_item extends uvm_object;

  logic [31:0] instruction_data;
  logic [31:0] input_data;

  `uvm_object_utils_begin(darkriscv_input_item)
    `uvm_field_int(instruction_data, UVM_ALL_ON)
    `uvm_field_int(input_data, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "darkriscv_input_item");
    super.new(name);
  endfunction : new

endclass : darkriscv_input_item

`endif // _DARKRISCV_INPUT_ITEM_SV_