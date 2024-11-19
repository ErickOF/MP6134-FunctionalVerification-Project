
class darkriscv_input_cov extends uvm_subscriber #(darkriscv_input_item);
  `uvm_component_utils(darkriscv_input_cov)
  darkriscv_input_item current_pkt;

  function new(string name = "darkriscv_input_cov", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void write(darkriscv_input_item pkt);
    this.current_pkt = pkt;
  endfunction

endclass