virtual class base_instruction_checker extends uvm_component;
  virtual darkriscv_if intf;

  instruction_t instruction_intf;
  logic [31:0] data_intf;
  inst_type_e opcode;

  logic hlt;
  logic checker_en;

  function new(string name="base_instruction_checker", uvm_component parent=null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (uvm_config_db #(virtual darkriscv_if)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the DB the virtual interface for the TB")
    end

    uvm_report_info(get_full_name(), "End_of_build_phase", UVM_LOW);
  endfunction : build_phase

  task start_checker();
    `uvm_info(get_full_name(), "`start_checker` task running", UVM_LOW)
  
    // Store the value of the halt
    this.hlt = this.intf.HLT;

    // Wait for reset to be done
    @(negedge this.intf.RES);
    repeat (5) @(posedge this.intf.CLK);

    // Infinite loop to continuously check the DUT
    forever begin
      this.hlt = this.intf.HLT;
      this.checker_en = (this.intf.RES === 1'b0) && (hlt === 1'b0);

      if (this.checker_en === 1'b1) begin
        // Fetch the instruction and data from the DUT interface
        this.instruction_intf = this.intf.IDATA;
        this.data_intf = this.intf.IDATA;
        this.opcode = this.instruction_intf.opcode.opcode;

        fork
          this.check_instruction();
        join_none
      end

      @(posedge this.intf.CLK);
    end
  endtask : start_checker

  virtual task check_instruction();
  endtask : check_instruction
endclass : base_instruction_checker
