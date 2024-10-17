class my_test extends uvm_test;
  `uvm_component_utils(my_test)

  function new(string name="my_test", uvm_component parent=null)
    super.new(name, parent);
    `UVM_INFO(this.name, "Running test", UVM_MEDIUM)
  endfunction : new
endclass : my_test
