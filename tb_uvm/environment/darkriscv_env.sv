//-------------------------------------------------------------------------------------------------
// Class: darkriscv_env
//
// This class represents the UVM environment for the darkriscv design. It contains the major
// components like the agent and the scoreboard, which are necessary for driving and monitoring
// transactions during simulation.
//
// The class extends uvm_env and provides a build phase to create components, and a connect phase
// to connect the components within the environment.
//-------------------------------------------------------------------------------------------------
class darkriscv_env extends uvm_env;
  `uvm_component_utils(darkriscv_env)

  //-----------------------------------------------------------------------------------------------
  // Function: new
  //
  // Constructor for the darkriscv_env class. Initializes the environment with a given name and
  // optionally links it to a parent component.
  //
  // Parameters:
  // - name: Name of the environment instance (optional, default is "darkriscv_env").
  // - parent: The parent UVM component (optional, default is null).
  //-----------------------------------------------------------------------------------------------
  function new(string name="darkriscv_env", uvm_component parent=null);
    super.new(name, parent);
	endfunction : new

  // Virtual interface to the DUT
  virtual darkriscv_if intf;

  // Agent to drive and monitor transactions in the testbench
  darkriscv_agent driscv_ag;

  // Scoreboard to check the correctness of transactions
  darkriscv_scoreboard #(darkriscv_input_item) input_sb;
  darkriscv_scoreboard #(darkriscv_output_item) output_sb;

  // Reference model for results predictions
  darkriscv_reference_model ref_model;

  //-----------------------------------------------------------------------------------------------
  // Function: build_phase
  //
  // Part of the UVM build phase. This function creates and initializes the agent and scoreboard,
  // and connects the virtual interface to the testbench.
  //
  // Parameters:
  // - phase: Current UVM phase.
  //-----------------------------------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Get the virtual interface from the UVM configuration database
    if (uvm_config_db #(virtual darkriscv_if)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the DB the virtual interface for the TB")
    end

    // Create the agent and scoreboard instances using the UVM factory
    driscv_ag = darkriscv_agent::type_id::create("driscv_ag", this);

    input_sb = darkriscv_scoreboard #(darkriscv_input_item)::type_id::create("input_sb", this);
    output_sb = darkriscv_scoreboard #(darkriscv_output_item)::type_id::create("output_sb", this);
    
    ref_model = darkriscv_reference_model::type_id::create("ref_model", this);

    // Report the end of the build phase and print the component's hierarchy
    uvm_report_info(get_full_name(), "End_of_build_phase", UVM_LOW);
    print();
  endfunction : build_phase

  //-----------------------------------------------------------------------------------------------
  // Function: connect_phase
  //
  // Part of the UVM connect phase. This function connects the monitor's analysis port from the 
  // agent to the scoreboard's input for checking transactions.
  //
  // Parameters:
  // - phase: Current UVM phase.
  //-----------------------------------------------------------------------------------------------
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connect the drivers's analysis port to the scoreboard's input expected data port
    driscv_ag.driscv_drv.driven_data_ap.connect(input_sb.expected_ap);

    // Connect the monitor's analysis port to the scoreboard's input actual data port
    driscv_ag.driscv_mntr.monitored_input_ap.connect(input_sb.actual_ap);

    // Connect the reference model's analysis port to the scoreboard's output expected data port
    ref_model.output_data_ap.connect(output_sb.expected_ap);

    // Connect the monitor's analysis port to the scoreboard's output actual data port
    driscv_ag.driscv_mntr.monitored_output_ap.connect(output_sb.actual_ap);
  endfunction : connect_phase

endclass : darkriscv_env
