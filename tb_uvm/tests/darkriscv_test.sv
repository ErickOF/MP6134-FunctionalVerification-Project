//-------------------------------------------------------------------------------------------------
// Class: darkriscv_test
//
// This class represents the UVM test class for the darkriscv environment. The test is responsible 
// for configuring, initializing, and executing the UVM environment and sequences.
//
// The class inherits from uvm_test and uses the UVM factory to create components dynamically 
// during simulation.
//-------------------------------------------------------------------------------------------------
class darkriscv_test extends uvm_test;
  `uvm_component_utils(darkriscv_test)

  //-----------------------------------------------------------------------------------------------
  // Function: new
  //
  // Constructor for the darkriscv_test class. It initializes the test with the given name or uses
  // "darkriscv_test" as the default name. It also logs an info message indicating that the test is
  // running.
  //
  // Parameters:
  // - name: The name of the test (optional, default is "darkriscv_test").
  // - parent: The parent UVM component (optional, default is null).
  //-----------------------------------------------------------------------------------------------
  function new(string name="darkriscv_test", uvm_component parent=null);
    super.new(name, parent);

    `UVM_INFO(this.name, "Running test", UVM_MEDIUM)
  endfunction : new

  // Virtual interface to the DUT
  virtual darkriscv_intf intf;

  // Environment that contains the agent and scoreboard
  darkriscv_env env;  

  //-----------------------------------------------------------------------------------------------
  // Function: build_phase
  //
  // Part of the UVM build phase. This function gets the virtual interface from the UVM config DB
  // and creates the environment using the UVM factory.
  //
  // Parameters:
  // - phase: Current UVM phase.
  //-----------------------------------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Retrieve the virtual interface from the UVM configuration DB
    if (uvm_config_db #(virtual darkriscv_intf)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the DB the virtual interface for the TB")
    end

    // Create the environment using the UVM factory
    env = darkriscv_env::type_id::create("env", this);

    // Set the virtual interface for the environment
    uvm_config_db #(virtual darkriscv_intf)::set(null, "uvm_test_top.*", "VIRTUAL_INTERFACE", intf);
  endfunction : build_phase

  //-----------------------------------------------------------------------------------------------
  // Function: end_of_elaboration_phase
  //
  // This function is executed at the end of the elaboration phase. It logs an informational
  // message and prints the component's hierarchy.
  //
  // Parameters:
  // - phase: Current UVM phase.
  //-----------------------------------------------------------------------------------------------
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_report_info(get_full_name(), "End_of_elaboration", UVM_LOW);
    print();
  endfunction : end_of_elaboration_phase

  // Sequence that generates items for the test
  gen_item_seq seq;

  //-----------------------------------------------------------------------------------------------
  // Task: run_phase
  //
  // This task contains the main execution logic for the test. It raises an objection to ensure the
  // simulation doesn't end prematurely, performs initialization tasks, starts the sequence, and
  // drops the objection once the test is done.
  //
  // Parameters:
  // - phase: Current UVM phase.
  //-----------------------------------------------------------------------------------------------
  virtual task run_phase(uvm_phase phase);
    // Raise an objection to keep the simulation running.
    phase.raise_objection(this);

    // Create and randomize the sequence
    seq = gen_item_seq::type_id::create("seq");
    seq.randomize();

    // Start the sequence on the sequencer
    seq.start(env.driscv_ag.driscv_seqr);

    // Drop the objection to end the test.
    phase.drop_objection(this);
  endtask : run_phase

endclass : darkriscv_test
