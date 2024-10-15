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

  // HTL
  logic hlt;
  logic prev_hlt;
  logic checker_en;

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

    // Store the value of the halt
    this.hlt = this.intf.HLT;
    this.prev_hlt = this.intf.HLT;

    // Infinite loop to continuously check the DUT
    forever begin
      // Check on negative edge of the clock
      @(negedge this.intf.CLK);

      this.prev_hlt = hlt;
      this.hlt = this.intf.HLT;

      // Ensure the reset is de-asserted
      this.checker_en = (this.intf.RES === 1'b0) && (hlt === 1'b0) && (prev_hlt === 1'b0);

      if (this.checker_en === 1'b1) begin
        @(posedge this.intf.CLK);

        // Fetch the instruction and data from the DUT interface
        this.instruction_intf = this.intf.IDATA;
        this.data_intf = this.intf.IDATA;
        this.opcode = this.instruction_intf.opcode.opcode;

        fork
          this.check_instruction();
        join_none
      end
    end
  endtask : check

  virtual task check_instruction();
  endtask : check_instruction
endclass : base_instruction_checker
