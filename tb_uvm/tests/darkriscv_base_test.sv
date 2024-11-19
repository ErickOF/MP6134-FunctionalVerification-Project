
class darkriscv_base_test extends uvm_test;

  `uvm_component_utils(darkriscv_base_test)

  function new(string name="darkriscv_base_test", uvm_component parent=null);
    super.new(name, parent);

    `uvm_info(get_type_name(), "Running test", UVM_MEDIUM)
  endfunction : new

  // Virtual interface to the DUT
  virtual darkriscv_if intf;

  // Environment that contains the agent and scoreboard
  darkriscv_env env;  

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Retrieve the virtual interface from the UVM configuration DB
    if (uvm_config_db #(virtual darkriscv_if)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the DB the virtual interface for the TB")
    end

    // Create the environment using the UVM factory
    env = darkriscv_env::type_id::create("env", this);

    // Set the virtual interface for the environment
    uvm_config_db #(virtual darkriscv_if)::set(null, "uvm_test_top.*", "VIRTUAL_INTERFACE", intf);
  endfunction : build_phase

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_report_info(get_full_name(), "End_of_elaboration", UVM_LOW);
    print();
  endfunction : end_of_elaboration_phase

  virtual task reset_phase(uvm_phase phase);
    super.reset_phase(phase);

    phase.raise_objection(this, "Starting reset!");

    `uvm_info(get_type_name(), $sformatf("Starting with reset_phase!"), UVM_NONE)

    env.reset();

    `uvm_info(get_type_name(), $sformatf("Finishing with reset_phase!"), UVM_NONE)

    phase.drop_objection(this, "Finishing reset!");
  endtask : reset_phase

endclass : darkriscv_base_test
