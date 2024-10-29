`ifndef _DARKRISCV_OUTPUT_ITEM_SV_
`define _DARKRISCV_OUTPUT_ITEM_SV_

class darkriscv_output_item extends uvm_object;

  logic [31:0] output_data;
  logic [31:0] data_address;
  logic [31:0] instruction_address;
  logic [2:0] bytes_transfered;
  logic write_op;
  logic read_op;

  `uvm_object_utils_begin(darkriscv_output_item)
    `uvm_field_int(output_data, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_int(data_address, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_int(instruction_address, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_int(bytes_transfered, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_int(write_op, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_int(read_op, UVM_ALL_ON | UVM_NOCOMPARE)
  `uvm_object_utils_end

  function new(string name = "darkriscv_output_item");
    super.new(name);
  endfunction : new

  virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    darkriscv_output_item rhs_;

    if (!$cast(rhs_, rhs)) begin
      `uvm_fatal(get_type_name(), "Couldn't cast rhs to darkriscv_output_item!")
      return 1'b0;
    end

    do_compare = 1'b1;

    do_compare &= (this.instruction_address == rhs_.instruction_address);

    do_compare &= (this.write_op == rhs_.write_op);
    do_compare &= (this.read_op == rhs_.read_op);

    if ((this.write_op == 1'b1) || (this.read_op == 1'b1)) begin
      do_compare &= (this.output_data == rhs_.output_data);
      do_compare &= (this.data_address == rhs_.data_address);
    end

    do_compare &= (this.bytes_transfered == rhs_.bytes_transfered);
  endfunction : do_compare

endclass : darkriscv_output_item

`endif // _DARKRISCV_OUTPUT_ITEM_SV_
