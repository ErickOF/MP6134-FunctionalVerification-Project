virtual class base_instruction_checker extends uvm_object;
  scoreboard sb;
  virtual darkriscv_if intf;
  string name;

  instruction_t instruction_intf;
  logic [31:0] data_intf;
  inst_type_e opcode;

  // HTL
  logic hlt;
  logic prev_hlt;
  logic checker_en;

  function new(string name="base_instruction_checker", uvm_component parent=null);
    super.new(name, parent)
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (uvm_config_db #(virtual darkriscv_if)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the DB the virtual interface for the TB")
    end

    driscv_sb = darkriscv_scoreboard::type_id::create("driscv_sb", this);

    uvm_report_info(get_full_name(), "End_of_build_phase", UVM_LOW);
  endfunction : build_phase

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
