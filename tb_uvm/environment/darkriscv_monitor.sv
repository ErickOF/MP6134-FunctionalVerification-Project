//-------------------------------------------------------------------------------------------------
// Class: darkriscv_monitor
//
// This class represents the monitor in the UVM environment for the darkriscv design.
// The monitor's role is to passively observe signals from the DUT via the virtual interface and 
// publish the observed transactions to other components like the scoreboard via the analysis port.
//
// The class extends uvm_monitor and contains an analysis port for sending observed transactions.
//-------------------------------------------------------------------------------------------------
class darkriscv_monitor extends uvm_monitor;
  `uvm_component_utils(darkriscv_monitor)

  //-----------------------------------------------------------------------------------------------
  // Virtual Interface: intf
  //
  // This virtual interface is used to passively monitor signals from the DUT. It will be assigned
  // during the build phase using uvm_config_db.
  //-----------------------------------------------------------------------------------------------
  virtual darkriscv_if intf;

  //-----------------------------------------------------------------------------------------------
  // Analysis Port: mon_analysis_port
  //
  // This analysis port is used to send observed transactions (darkriscv_item) to other UVM
  // components, like the scoreboard. It will be used to forward the data observed in the DUT.
  //-----------------------------------------------------------------------------------------------
  uvm_analysis_port #(darkriscv_item) mon_analysis_port;

  //-----------------------------------------------------------------------------------------------
  // Function: new
  //
  // Constructor for the darkriscv_monitor class. It initializes the monitor with a given name and
  // optionally links it to a parent UVM component.
  //
  // Parameters:
  // - name: Name of the monitor instance (optional, default is "darkriscv_monitor").
  // - parent: The parent UVM component (optional, default is null).
  //-----------------------------------------------------------------------------------------------
  function new(string name="darkriscv_monitor", uvm_component parent=null);
    super.new(name, parent);
  endfunction : new

  //-----------------------------------------------------------------------------------------------
  // Function: build_phase
  //
  // This function is part of the UVM build phase. It initializes the analysis port and retrieves the
  // virtual interface (intf) from the UVM configuration database.
  //
  // If the virtual interface cannot be found, a fatal error is triggered.
  //
  // Parameters:
  // - phase: Current UVM phase.
  //-----------------------------------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create the analysis port for sending observed transactions.
    mon_analysis_port = new("mon_analysis_port", this);

    // Get the virtual interface from the UVM configuration database.
    if(uvm_config_db #(virtual darkriscv_if)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the DB the virtual interface for the TB")
    end
  endfunction : build_phase

  //-----------------------------------------------------------------------------------------------
  // Task: run_phase
  //
  // This task is part of the UVM run phase. Currently, it is empty but will be used to observe
  // signals on the virtual interface and collect transactions. The transactions will then be
  // published to other components via the analysis port.
  //
  // Parameters:
  // - phase: Current UVM phase.
  //-----------------------------------------------------------------------------------------------
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    // Monitoring logic will be implemented here to capture and forward transactions.
  endtask : run_phase

endclass : darkriscv_monitor
