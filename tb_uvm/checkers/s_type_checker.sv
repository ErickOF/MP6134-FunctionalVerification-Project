//-------------------------------------------------------------------------------------------------
// Class: s_type_checker
//
// This class is used store instruction checkers in a UVM testbench. It checks instructions being
// executed by the DUT.
//
// The class interfaces with the DUT using a virtual interface and processes the instruction and
// data fetched from the interface.
//-------------------------------------------------------------------------------------------------
class s_type_checker extends base_instruction_checker;
  //-----------------------------------------------------------------------------------------------
  // Function: new
  //
  // Constructor for the s_type_checker. Initializes the checker with the given name or uses the
  // default "s_type_checker". Calls the base class constructor "base_instruction_checker".
  //
  // Parameters:
  // - name: The name of the checker (optional, default is "s_type_checker").
  // - parent: The parent UVM component (optional, default is null).
  //-----------------------------------------------------------------------------------------------
  function new(string name="s_type_checker", uvm_component parent=null);
    super.new(name, parent);
  endfunction : new

  //###############################################################################################
  // Task: check_instruction
  // Description: Specialized check for S-type instructions.
  //
  //              S-type instructions are typically used for store operations, such as storing a
  //              a register value to memory. These instructions include store commands like SW
  //              (store word), SH (store halfword), and SB (store byte).
  //
  // Example: S-type instructions calculate a memory address from a base register and an immediate
  //          value, then store a value from a source register to that address.
  //###############################################################################################
  task check_instruction();
    // Specialized check for S-type instructions
    if (this.opcode == s_type) begin
      `uvm_info(get_full_name(), "`check_instruction` task running", UVM_LOW)

      fork
        check_data_len();
        check_drw();
        check_dwr();
        check_sign_extension();
      join_none
    end
  endtask : check_instruction

  //-----------------------------------------------------------------------------------------------
  // Task: check_data_len
  //
  // Description:
  //   This task verifies the data length of S-type instructions based on the `funct3` field. The
  //   task determines the expected data length (byte, halfword, or word) and compares it with the
  //   actual data length provided by the DUT (`DLEN` signal).
  //
  // Notes:
  //   - The task identifies the instruction type (SB, SH, SW) from `funct3` and sets the
  //     corresponding data length.
  //   - A delay accounts for HLT signal handling between instructions.
  //-----------------------------------------------------------------------------------------------
  task check_data_len();
    // Retrieve the `funct3` field from the instruction interface.
    logic [2:0] funct3 = this.instruction_intf.s_type.funct3;

    // Determine data length based on `funct3`.
    // Funct3 == 0 -> byte, Funct3 == 1 -> halfword, Funct3 == 2 -> word
    logic [2:0] data_len = (funct3 == 3'd2) ?
                            3'b100 : (funct3 == 3'd1) ?
                              3'b010 : 3'b001;

    // Determine the instruction name for logging purposes
    string inst_name = (funct3 == 3'd2) ?
                        "SW" : (funct3 == 3'd1) ?
                          "SH" : "SB";

    // Expected data length value from RTL interface
    logic [2:0] expected_data_len;

    // Introduce a delay for HLT signal processing
    repeat (2) @(posedge this.intf.CLK);

    // Retrieve the actual data length from the RTL
    expected_data_len = this.intf.DLEN;

    // Log the data lengths for debugging purposes
    `uvm_info(
      get_full_name(),
      $sformatf(
        "%s data len: %03b (expected: %03b)",
        inst_name,
        data_len,
        expected_data_len
      ),
      UVM_LOW
    );

    // Compare the DUT's data length with the expected data length
    if (data_len === expected_data_len) begin
      `uvm_info(
        get_full_name(),
        $sformatf("Data len for %s match", inst_name),
        UVM_LOW
      );
    end
    else begin
      `uvm_error(
        get_full_name(),
        $sformatf("Data len for %s mismatch", inst_name)
      );
    end
  endtask : check_data_len

  //-----------------------------------------------------------------------------------------------
  // Task: check_drw
  //
  // Description:
  //   This task verifies the DRW (Data Ready Write) signal for S-type instructions (SW, SH, SB).
  //   Based on the `funct3` field, it determines the instruction type and checks if the DRW signal
  //   from the DUT matches the expected value of 1'b0.
  //
  // Notes:
  //   - The task determines the instruction name (SB, SH, SW) from `funct3`.
  //   - A delay accounts for HLT signal handling between instructions.
  //-----------------------------------------------------------------------------------------------
  task check_drw();
    // Retrieve the `funct3` field from the instruction interface to identify the instruction type
    logic [2:0] funct3 = this.instruction_intf.s_type.funct3;

    // Determine the instruction name for logging purposes
    string inst_name = (funct3 == 3'd2) ?
                        "SW" : (funct3 == 3'd1) ?
                          "SH" : "SB";

    // Introduce a delay for HLT signal processing
    repeat (2) @(posedge this.intf.CLK);

    // Log the DRW value for debugging purposes, expecting DRW to be 1'b0
    `uvm_info(
      get_full_name(),
      $sformatf(
        "%s DRW: %01b (expected: 1'b0)",
        inst_name,
        this.intf.DRW
      ),
      UVM_LOW
    );

    // Compare the DUT's DRW with the expected DRW value of 1'b0
    if (this.intf.DRW === 1'b0) begin
      `uvm_info(
        get_full_name(),
        $sformatf("DRW for %s match", inst_name),
        UVM_LOW
      );
    end
    else begin
      `uvm_error(
        get_full_name(),
        $sformatf("DRW for %s mismatch", inst_name)
      );
    end
  endtask : check_drw

  //-----------------------------------------------------------------------------------------------
  // Task: check_dwr
  //
  // Description:
  //   This task verifies the DWR (Data Write Ready) signal for S-type instructions (SW, SH, SB).
  //   Based on the `funct3` field, it determines the instruction type and checks if the DWR signal
  //   from the DUT matches the expected value of 1'b1.
  //
  // Notes:
  //   - The task identifies the instruction type from `funct3` and assigns an instruction name
  //     (SB, SH, SW) for improved log readability.
  //   - A delay accounts for the HLT signal handling between instructions.
  //-----------------------------------------------------------------------------------------------
  task check_dwr();
    // Retrieve the `funct3` field from the instruction interface to identify the instruction type
    logic [2:0] funct3 = this.instruction_intf.s_type.funct3;

    // Determine the instruction name for logging purposes
    string inst_name = (funct3 == 3'd2) ?
                        "SW" : (funct3 == 3'd1) ?
                          "SH" : "SB";

    // Introduce a delay for HLT signal processing
    repeat (2) @(posedge this.intf.CLK);

    // Log the expected DWR value for debugging, expecting it to be 1'b1
    `uvm_info(
      get_full_name(),
      $sformatf(
        "%s DWR: %01b (expected: 1'b1)",
        inst_name,
        this.intf.DWR
      ),
      UVM_LOW
    );

    // Compare the DUT's DWR with the expected DWR value of 1'b1
    if (this.intf.DWR === 1'b1) begin
      `uvm_info(
        get_full_name(),
        $sformatf("DWR for %s match", inst_name),
        UVM_LOW
      );
    end
    else begin
      `uvm_error(
        get_full_name(),
        $sformatf("DWR for %s mismatch", inst_name)
      );
    end
  endtask : check_dwr

  //-----------------------------------------------------------------------------------------------
  // Task: check_sign_extension
  //
  // Description:
  //   This task verifies that the store value in S-type instructions is correctly sign-extended or
  //   zero-extended. The task reads the immediate value, performs sign extension based on the
  //   opcode requirements, and compares it against the RTL value (`SIMM`) to ensure correctness.
  //-----------------------------------------------------------------------------------------------
  task check_sign_extension();
    // Declare a 32-bit signed logic variable for the immediate value
    logic signed [31:0] imm;

    // Set the sign bit based on the MSB of imm2[6]
    // If imm2[6] is set, sign-extension is applied, else zero-extension
    imm = instruction_intf.i_type.imm2[6] ? '1 : '0;

    // Populate the imm variable with the upper (imm2) and lower (imm) parts
    imm[31:25] = instruction_intf.i_type.imm2;
    imm[11:7] = instruction_intf.i_type.imm;

    // Introduce a delay to account for the HLT signal processing between instructions
    repeat (2) @(posedge this.intf.CLK);

    // Retrieve the sign-extended immediate result from the DUT
    simm = darksimv.core0.SIMM;

    // Print the immediate values for debugging
    `uvm_info(
      get_full_name(),
      $sformatf(
        "%s sign-extension: %08h (expected: %08h).",
        inst_name,
        simm,
        imm
      ),
      UVM_LOW
    );

    // Compare the RTL immediate (`simm`) with the expected (`imm`)
    if (simm === imm) begin
      `uvm_info(
        get_full_name(),
        $sformatf("IMM sign/zero-extension for %s match", inst_name),
        UVM_LOW
      );
    end
    else begin
      `uvm_error(
        get_full_name(),
        $sformatf("IMM sign/zero-extension for %s mismatch", inst_name)
      );
    end
  endtask : check_sign_extension
endclass : s_type_checker
