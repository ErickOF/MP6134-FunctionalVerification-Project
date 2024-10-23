//-------------------------------------------------------------------------------------------------
// Class: darkriscv_scoreboard
//
// This class represents the scoreboard in the UVM environment for the darkriscv design. The 
// scoreboard is used to compare the expected transactions and the actual transactions observed
// from the DUT.
//
// The class extends uvm_scoreboard and uses two analysis implementation ports (one for the driver
// and one for the monitor) to receive transactions and perform comparisons.
//
// The scoreboard does not contain any specific comparison logic yet, but the foundation is laid
// out for handling the transactions received from the driver and monitor.
//-------------------------------------------------------------------------------------------------
`uvm_analysis_imp_decl(_drv)
`uvm_analysis_imp_decl(_mon)
class darkriscv_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(darkriscv_scoreboard)

  //-----------------------------------------------------------------------------------------------
  // Function: new
  //
  // Constructor for the darkriscv_scoreboard class. It initializes the scoreboard with the given 
  // name and optionally links it to a parent UVM component.
  //
  // Parameters:
  // - name: Name of the scoreboard instance (optional, default is "darkriscv_scoreboard").
  // - parent: The parent UVM component (optional, default is null).
  //-----------------------------------------------------------------------------------------------
  function new(string name="darkriscv_scoreboard", uvm_component parent=null);
    super.new(name, parent);
  endfunction : new

  //-----------------------------------------------------------------------------------------------
  // Analysis Implementation: driscv_drv
  //
  // This is the analysis implementation port for receiving transactions from the driver. It is 
  // connected to the driver via the analysis port in the testbench and will receive darkriscv_item
  // transactions for comparison in the scoreboard.
  //-----------------------------------------------------------------------------------------------
  uvm_analysis_imp_drv #(darkriscv_item, darkriscv_scoreboard) driscv_drv;

  //-----------------------------------------------------------------------------------------------
  // Analysis Implementation: driscv_mon
  //
  // This is the analysis implementation port for receiving transactions from the monitor. It will
  // collect observed transactions from the monitor via its analysis port for comparison in the
  // scoreboard.
  //-----------------------------------------------------------------------------------------------
  uvm_analysis_imp_mon #(darkriscv_item, darkriscv_scoreboard) driscv_mon;

  i_type_checker i_type_check;

  //-----------------------------------------------------------------------------------------------
  // Function: build_phase
  //
  // This function is part of the UVM build phase. It initializes the analysis implementation ports
  // for the driver and the monitor, which will be used to receive transactions from the respective
  // components.
  //
  // Parameters:
  // - phase: Current UVM phase.
  //-----------------------------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    // Initialize the analysis implementation ports for receiving transactions.
    driscv_drv = new("driscv_drv", this);
    driscv_mon = new("driscv_mon", this);
    // Initialize checkers
    i_type_check = new("i_type_check", this);
  endfunction : build_phase

  //-----------------------------------------------------------------------------------------------
  // Task: run_phase
  //
  // This task is part of the UVM run phase. It currently does not contain any specific logic but
  // can be used to perform any operations that need to happen during the run-time simulation.
  //
  // Parameters:
  // - phase: Current UVM phase.
  //-----------------------------------------------------------------------------------------------
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    `uvm_info(get_full_name(), "Start of run_phase", UVM_LOW)

    i_type_check.start_checker();

    `uvm_info(get_full_name(), "End of run_phase", UVM_LOW)
  endtask : run_phase

  //-----------------------------------------------------------------------------------------------
  // Function: check_phase
  //
  // This function is part of the UVM check phase. It is currently empty but can be used to perform 
  // checks and comparisons between the transactions received from the driver and monitor.
  //
  // Parameters:
  // - phase: Current UVM phase.
  //-----------------------------------------------------------------------------------------------
  virtual function void check_phase(uvm_phase phase);
    // No specific check logic implemented yet.
  endfunction : check_phase

  virtual function void write_drv(darkriscv_item trans);
  endfunction

  virtual function void write_mon(darkriscv_item trans);
  endfunction
endclass : darkriscv_scoreboard
