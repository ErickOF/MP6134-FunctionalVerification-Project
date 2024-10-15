// Based on: https://www.edaplayground.com/x/Yk4N
class driver;
  // Instance of stimulus class to generate random values
  stimulus sti;

  // Instance of scoreboard class to store expected results
  scoreboard sb;

  // Virtual interface to interact with the DUT
  virtual darkriscv_if intf;

  // Constructor: Initializes the interface and scoreboard objects
  function new(virtual darkriscv_if intf, scoreboard sb);
    this.intf = intf;
    this.sb = sb;
  endfunction : new

  // Reset task: Initializes the DUT by resetting all control and data signals
  task reset();
    $display("Executing Reset\n");
    intf.HLT     = 0;
    intf.IRQ     = 0;
    intf.IDATA   = 0;
    intf.DATAI   = 0;
`ifdef SIMULATION
    intf.ESIMREQ = 0;
`endif
    intf.RES     = 1;
    repeat (2) @(negedge intf.CLK);
    intf.RES     = 0;
    intf.HLT     = 1;
  endtask : reset

  // Write task: Generates random instructions. Could be constrained (valid ones) or completely random (not valid RISC-V instructions)
  task write(input integer iteration, input bit valid_inst);
    bit previous_sti_s_type = 1'b0;
    for (int i = 0; i < iteration; i++) begin
      if (i == 0) begin
        @ (negedge intf.CLK);
        previous_sti_s_type = 1'b0;
      end
      else begin
        @ (posedge intf.CLK);
        if (sti.opcode == s_type) begin
          previous_sti_s_type = 1'b1;
          intf.HLT = 1;
        end
        else begin
          previous_sti_s_type = 1'b0;
        end
      end
      sti = new();
      if(sti.randomize()) begin // Generate stimulus
        $display("write(): Driving instruction 0x%0h\n", sti.riscv_inst);
      end
      else begin
        $error("There was an error in randomize call of write task at %m");
      end
      intf.IDATA = sti.riscv_inst;
      intf.DATAI = sti.riscv_data;
      sb.expected_mb[0].put(sti.riscv_inst); // Store the current instruction input in the scoreboard queue for that purpose
      sb.expected_mb[1].put(sti.riscv_data);        // Store the current data input in the scoreboard queue for that purpose
      if (i == 0) begin
          @ (posedge intf.CLK);
          intf.HLT = 0;
      end
      if (previous_sti_s_type == 1'b1) begin
        @ (posedge intf.CLK);
        @ (posedge intf.CLK);
        intf.HLT = 0;
      end
    end
    if (sti.opcode == s_type) begin
      sti = new();
      sti.c_supported_type_only.constraint_mode(0);
      @ (negedge intf.CLK);
      if ( ! sti.randomize() with { // Let's use ADDI instruction for populate each register, by taking advance of immediate values
        opcode == custom_0_type;    // Custom-0-type instruction
        funct3 == 3'b000;    // funct3 code for idle
      }) begin
        $error("There was an error in randomize call of write init_registers task at %m");
      end
      $display("write(): Driving instruction 0x%0h\n", sti.riscv_inst);
      intf.IDATA = sti.riscv_inst;
      intf.DATAI = sti.riscv_data;
      @ (posedge intf.CLK);
      intf.HLT = 0;
    end
    @ (posedge intf.CLK);
    intf.HLT = 1;
    // TODO: what values to drive in "IDLE" mode?
  endtask : write

  // init_registers task: In order to do useful computation instructions, we need known values different than zero in each register
  task init_registers();
    bit previous_sti_s_type = 1'b0;
    for (int k = 0; k < 32; k++) begin
      sti = new();
      if (k == 0) begin
        @ (negedge intf.CLK);
      end
      else begin
        @ (posedge intf.CLK);
      end
      if ( ! sti.randomize() with { // Let's use ADDI instruction for populate each register, by taking advance of immediate values
        opcode == i_type;    // I-type instruction
        funct3 == 3'b000;    // funct3 code for ADDI
        rs1    == 5'b0_0000; // Register with hardcoded zero value. Therefore, rd = 0 + imm -> rd = imm
        rd     == k;         // Number of destiny register, iterating over all 32 registers
      }
      ) begin
        $error("There was an error in randomize call of write init_registers task at %m");
      end
      $display("init_registers(): Driving instruction for init_registers: 0x%0h\n", sti.riscv_inst);
      intf.IDATA = sti.riscv_inst;
      intf.DATAI = sti.riscv_data;
      sb.expected_mb[0].put(sti.riscv_inst); // Store the current instruction input in the scoreboard queue for that purpose
      sb.expected_mb[1].put(sti.riscv_data);        // Store the current data input in the scoreboard queue for that purpose
      if (k == 0) begin
        @ (posedge intf.CLK);
        intf.HLT = 0;
      end
    end
    @ (posedge intf.CLK);
    intf.HLT = 1;
  endtask

	// save_registers task: Useful task for dumping the register file content at the end of 
	// test, by doing store instructions for transfer each register content to a random memory
	// location
	task save_registers();
    bit previous_sti_s_type = 1'b0;
		for (int k = 0; k < 32; k++) begin
		    if (k == 0) begin
          @ (negedge intf.CLK);
          previous_sti_s_type = 1'b0;
        end
        else begin
          @ (posedge intf.CLK);
          if (sti.opcode == s_type) begin
            previous_sti_s_type = 1'b1;
            intf.HLT = 1;
          end
          else begin
            previous_sti_s_type = 1'b0;
          end
        end
        sti = new();
		    if ( ! sti.randomize() with {
		      opcode == s_type;    // S-type instruction
		      funct3 == 3'b010;    // encoding for a "word" width store instruction
		      rs1    == 5'b0_0000; // Register with hardcoded zero value. Therefore, memory address = 0 + imm
					rs2    == k;         // Iterate over all the registers
					imm    == 12'h100;   // Arbitrary offset
		    }
		    ) begin
		      $fatal("There was an error in randomize call of write init_registers task at %m");
		    end
		    $display("save_registers(): Driving instruction for save_registers: 0x%0h\n", sti.riscv_inst);
		    intf.IDATA = sti.riscv_inst;
		    intf.DATAI = sti.riscv_data; // Driving input data but DUT should ignore this
		    sb.expected_mb[0].put(sti.riscv_inst); // Store the current instruction input in the scoreboard queue for that purpose
                    sb.expected_mb[1].put(sti.riscv_data);        // Store the current data input in the scoreboard queue for that purpose
                    // Arbitrary wait time to avoid race conditions in the model, based on feedback PR#15 Feedback
        if (k == 0) begin
          @ (posedge intf.CLK);
          intf.HLT = 0;
        end
        if (previous_sti_s_type == 1'b1) begin
          @ (posedge intf.CLK);
          @ (posedge intf.CLK);
          intf.HLT = 0;
        end
		end
    if (sti.opcode == s_type) begin
      sti = new();
      sti.c_supported_type_only.constraint_mode(0);
      @ (negedge intf.CLK);
      if ( ! sti.randomize() with { // Let's use ADDI instruction for populate each register, by taking advance of immediate values
        opcode == custom_0_type;    // Custom-0-type instruction
        funct3 == 3'b000;    // funct3 code for idle
      }) begin
        $error("There was an error in randomize call of write init_registers task at %m");
      end
      $display("save_registers(): Driving instruction 0x%0h\n", sti.riscv_inst);
      intf.IDATA = sti.riscv_inst;
      intf.DATAI = sti.riscv_data;
      @ (posedge intf.CLK);
      intf.HLT = 0;
    end
		@ (posedge intf.CLK);
		intf.HLT = 1;
	endtask

  // halt_pattern task: Drive HLT input with a delay pattern
  task halt_pattern();
    //TODO:
  endtask

  // interrupt_req task: request an interrupt to RISC-V core
  task interrupt_req();
    $display("New interrupt request\n");
    @ (negedge intf.CLK);
    intf.IRQ = 1;
    @ (negedge intf.CLK);
    intf.IRQ = 0;
  endtask

`ifdef SIMULATION
  // end_simulation_req task: Let the DUT that simulation will end soon. Just a debug capability that was added on DarkRISCV
  task end_simulation_req();
    $display("Simulation end request\n");
    @ (negedge intf.CLK);
    intf.ESIMREQ = 1;
  endtask
`endif

endclass : driver
