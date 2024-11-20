
class darkriscv_output_cov extends uvm_subscriber #(darkriscv_output_item);
  `uvm_component_utils(darkriscv_output_cov)
  darkriscv_output_item current_pkt;

  function new(string name = "darkriscv_output_cov", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void write(darkriscv_output_item pkt);
    this.current_pkt = pkt;
  endfunction

endclass
