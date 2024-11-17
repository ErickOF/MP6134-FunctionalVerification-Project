`define HDL_TOP darksimv_hdl.core0

//-------------------------------------------------------------------------------------------------
// Class: base_instruction_checker
//
// This virtual class is used as a base for instruction checkers in a UVM testbench. It checks
// instructions being executed by the DUT. Derived classes should implement the `check_instruction`
// task to define specific checks for each instruction.
//
// The class interfaces with the DUT using a virtual interface and processes the instruction and
// data fetched from the interface.
//-------------------------------------------------------------------------------------------------
virtual class base_instruction_checker extends uvm_component;

  // Virtual interface connected to the DUT
  virtual darkriscv_if intf;

  // Instruction fetched from the interface
  instruction_t instruction_intf;

  // Data fetched from the interface
  logic [31:0] data_intf;

  // Opcode type for the current instruction
  inst_type_e opcode;

  // Halt signal and checker enable logic
  logic hlt;
  logic checker_en;

  //-----------------------------------------------------------------------------------------------
  // Function: new
  //
  // Constructor for the base_instruction_checker. Initializes the checker with the given name or
  // uses the default "base_instruction_checker". Calls the base class constructor.
  //
  // Parameters:
  // - name: The name of the checker (optional, default is "base_instruction_checker").
  // - parent: The parent UVM component (optional, default is null).
  //-----------------------------------------------------------------------------------------------
  function new(string name="base_instruction_checker", uvm_component parent=null);
    super.new(name, parent);
  endfunction : new

  //-----------------------------------------------------------------------------------------------
  // Function: build_phase
  //
  // In the build phase, this function retrieves the virtual interface from the UVM config database
  // and checks for errors. It also logs an informational message at the end of the build phase.
  //
  // Parameters:
  // - phase: The current UVM phase.
  //-----------------------------------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Retrieve the virtual interface from the UVM configuration database
    if (uvm_config_db #(virtual darkriscv_if)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the DB the virtual interface for the TB")
    end

    uvm_report_info(get_full_name(), "End_of_build_phase", UVM_LOW);
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
    start_checker();
  endtask : run_phase

  //-----------------------------------------------------------------------------------------------
  // Task: start_checker
  //
  // This task is responsible for continuously monitoring the interface and checking instructions
  // based on signals from the DUT. It waits for the system reset to deassert and then starts the
  // instruction checks whenever the checker is enabled and the DUT is not halted.
  //
  // Signals:
  // - RES: Reset signal (active low).
  // - CLK: Clock signal.
  // - HLT: Halt signal from the DUT.
  //-----------------------------------------------------------------------------------------------
  task start_checker();
    `uvm_info(get_full_name(), "`start_checker` task running", UVM_LOW)

    // Capture the halt signal
    this.hlt = this.intf.HLT;

    // Wait for reset deassertion and a few clock cycles
    @(negedge this.intf.RES);
    repeat (5) @(posedge this.intf.CLK);

    @(negedge this.intf.CLK);

    // Continuous checking loop
    forever begin
      // Update halt signal
      this.hlt = this.intf.HLT;
      // Enable checker if not halted and reset
      this.checker_en = (this.intf.RES === 1'b0) && (hlt === 1'b0);

      if (this.checker_en === 1'b1) begin
        // Fetch instruction and data from the interface
        this.instruction_intf = this.intf.IDATA;
        this.data_intf = this.intf.IDATA;
        // Extract opcode from the instruction
        this.opcode = this.instruction_intf.opcode.opcode;

        // Fork a process to check the instruction
        fork
          this.check_instruction();
        join_none
      end

      // Wait for the next clock edge
      @(negedge this.intf.CLK);
    end
  endtask : start_checker

  //-----------------------------------------------------------------------------------------------
  // Virtual Task: check_instruction
  //
  // This virtual task is meant to be overridden by derived classes to implement specific
  // instruction checks.
  //-----------------------------------------------------------------------------------------------
  virtual task check_instruction();
  endtask : check_instruction

endclass : base_instruction_checker
