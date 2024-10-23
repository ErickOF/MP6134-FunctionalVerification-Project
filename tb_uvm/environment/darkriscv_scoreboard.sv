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

`ifndef _DARKRISCV_SCOREBOARD_SV_
`define _DARKRISCV_SCOREBOARD_SV_

`uvm_analysis_imp_decl(_exp)
`uvm_analysis_imp_decl(_act)

class darkriscv_scoreboard #(type T = uvm_object) extends uvm_scoreboard;

  //-----------------------------------------------------------------------------------------------
  // Analysis Implementation: driscv_drv
  //
  // This is the analysis implementation port for receiving transactions from the expected item. It
  // connected the component that will predict the expected value via the analysis port in the 
  // testbench and will receive transactions of type T for comparison in the scoreboard.
  //-----------------------------------------------------------------------------------------------
  uvm_analysis_imp_exp #(T, darkriscv_scoreboard #(T)) expected_ap;

  //-----------------------------------------------------------------------------------------------
  // Analysis Implementation: driscv_mon
  //
  // This is the analysis implementation port for receiving transactions from the actual items from
  // the monitor. It will collect observed transactions from the monitor via its analysis port for
  // comparison in the scoreboard.
  //-----------------------------------------------------------------------------------------------
  uvm_analysis_imp_act #(T, darkriscv_scoreboard #(T)) actual_ap;

  mailbox #(T) expected_mb;
  mailbox #(T) actual_mb;

  int unsigned match_count;
  int unsigned mismatch_count;

  bit objection_raised;

  `uvm_component_utils(darkriscv_scoreboard #(T))

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
    super.new(name, parent); // Call the base class constructor.

    expected_mb = new();
    actual_mb = new();

    match_count = 0;
    mismatch_count = 0;

    objection_raised = 1'b0;
  endfunction : new

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
    expected_ap = new("expected_ap", this);
    actual_ap = new("actual_ap", this);
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
    T expected_data;
    T actual_data;

    forever begin
      expected_mb.get(expected_data);
      actual_mb.get(actual_data);

      if (expected_data.compare(actual_data)) begin
        `uvm_info(get_type_name(), $sformatf("Data matched in scoreboard with expected = %s and actual = %s!", expected_data.sprint(), actual_data.sprint()), UVM_MEDIUM)
        match_count++;
      end
      else begin
        `uvm_error(get_type_name(), $sformatf("Data mismatched in scoreboard with expected = %s and actual = %s!", expected_data.sprint(), actual_data.sprint()))
        mismatch_count++;
      end
    end
  endtask : run_phase

  function void write_exp(T expected_item);
    T expected_item_tmp;

    if (!$cast(expected_item_tmp, expected_item.clone())) begin
      `uvm_fatal(get_type_name(), "Failed to cast expected_item!")
    end

    expected_mb.try_put(expected_item_tmp);
  endfunction : write_exp

  function void write_act(T actual_item);
    T actual_item_tmp;

    if (!$cast(actual_item_tmp, actual_item.clone())) begin
      `uvm_fatal(get_type_name(), "Failed to cast actual_item!")
    end

    actual_mb.try_put(actual_item_tmp);
  endfunction : write_act

  function void check_phase(uvm_phase phase);

    if (expected_mb.num() > 0) begin
      `uvm_error(get_type_name(), $sformatf("There is still %0d expected items to be processed!", expected_mb.num()))
    end

    if (actual_mb.num() > 0) begin
      `uvm_error(get_type_name(), $sformatf("There is still %0d actual items to be processed!", actual_mb.num()))
    end

  endfunction : check_phase

  function void report_phase(uvm_phase phase);

    `uvm_info(get_type_name(), $sformatf("Scoreboard finished with %0d matches and %0d mismatches!", match_count, mismatch_count), UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("Scoreboard finished with %0d expected items waiting to be processed!", expected_mb.num()), UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("Scoreboard finished with %0d actual items waiting to be processed!", actual_mb.num()), UVM_NONE)

  endfunction : report_phase

endclass : darkriscv_scoreboard

`endif // _DARKRISCV_SCOREBOARD_SV_
