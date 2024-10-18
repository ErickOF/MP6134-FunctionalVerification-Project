//-------------------------------------------------------------------------------------------------
// Class: darkriscv_agent
//
// This class represents the active agent in the UVM environment for the darkriscv design. An 
// agent contains a sequencer, driver, and monitor to actively drive transactions to the DUT and
// monitor responses. It uses the darkriscv interface to communicate with the DUT.
//
// The class extends uvm_agent and contains a driver, sequencer, and monitor for handling 
// transactions.
//-------------------------------------------------------------------------------------------------
class darkriscv_agent extends uvm_agent;
  `uvm_component_utils(darkriscv_agent)

  //-----------------------------------------------------------------------------------------------
  // Function: new
  //
  // Constructor for the darkriscv_agent class. Initializes the agent with a given name and
  // optionally links it to a parent component.
  //
  // Parameters:
  // - name: Name of the agent instance (optional, default is "darkriscv_agent").
  // - parent: The parent UVM component (optional, default is null).
  //-----------------------------------------------------------------------------------------------
  function new(string name="darkriscv_agent", uvm_component parent=null);
    super.new(name, parent);
  endfunction : new

  // Virtual interface to the DUT
  virtual darkriscv_intf intf;

  // Driver to send transactions to the DUT
  darkriscv_driver driscv_drv;

  // Sequencer to generate and control sequence items
  uvm_sequencer #(darkriscv_item) driscv_seqr;

  // Monitor
  darkriscv_monitor driscv_mntr;

  //-----------------------------------------------------------------------------------------------
  // Function: build_phase
  //
  // Part of the UVM build phase. This function creates and initializes the driver, sequencer, and 
  // monitor components, and connects the virtual interface to the testbench.
  //
  // Parameters:
  // - phase: Current UVM phase.
  //-----------------------------------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Get the virtual interface from the UVM configuration database
    if(uvm_config_db #(virtual darkriscv_intf)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the DB the virtual interface for the TB")
    end

    // Create the driver, sequencer, and monitor instances using the UVM factory
    driscv_drv = darkriscv_driver::type_id::create("driscv_drv", this);
    driscv_seqr = uvm_sequencer#(darkriscv_item)::type_id::create("driscv_seqr", this);
    driscv_mntr = darkriscv_monitor::type_id::create("driscv_mntr", this);
  endfunction : build_phase

  //-----------------------------------------------------------------------------------------------
  // Function: connect_phase
  //
  // Part of the UVM connect phase. This function connects the sequence item port of the driver 
  // to the sequence item export of the sequencer, allowing the driver to receive transactions 
  // from the sequencer.
  //
  // Parameters:
  // - phase: Current UVM phase.
  //-----------------------------------------------------------------------------------------------
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connect the sequencer's item export to the driver's item port
    driscv_drv.seq_item_port.connect(driscv_seqr.seq_item_export);
  endfunction : connect_phase

endclass : darkriscv_agent
