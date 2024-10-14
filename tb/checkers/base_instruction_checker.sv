virtual class base_instruction_checker;
  // Import instruction types from the package
  //import instructions_pkg::*;

  //###############################################################################################
  // Members:
  //###############################################################################################
  // Reference to the scoreboard to fetch expected values
  scoreboard sb;
  // Virtual interface to observe signals from the DUT
  virtual darkriscv_if intf;
  // Checker name
  string name;

  // Actual instruction from DUT interface
  instruction_t instruction_intf;
  // Actual data from DUT interface
  logic [31:0] data_intf;
  // Instruction opcode (enum)
  inst_type_e opcode;

  // PASS/ERROR counters to track matching/mismatched comparisons
  int pass_counter;
  int error_counter;

  function new(string name, virtual darkriscv_if intf, scoreboard sb);
    this.name = name;
    this.intf = intf;
    this.sb = sb;
  endfunction : new

  task check();
    `PRINT_INFO(this.name, "`check` task running")
  
    // Initialize counters
    this.pass_counter = 0;
    this.error_counter = 0;

    // Infinite loop to continuously check the DUT
    forever begin
      // Check on negative edge of the clock
      @(negedge intf.CLK);

      // Ensure the reset is de-asserted and there are instructions in the scoreboard queue
      if (this.intf.RES === 0) begin
        // Fetch the instruction and data from the DUT interface
        this.instruction_intf = this.intf.IDATA;
        this.data_intf = this.intf.IDATA;
        this.opcode = this.instruction_intf.opcode.opcode;

        @(posedge intf.CLK);

        this.check_instruction();
      end
    end
  endtask : check

  virtual task check_instruction();
  endtask : check_instruction
endclass : base_instruction_checker
