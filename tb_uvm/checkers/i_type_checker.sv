//-------------------------------------------------------------------------------------------------
// Class: i_type_checker
//
// This class is used immediate instruction checkers in a UVM testbench. It checks instructions
// being executed by the DUT.
//
// The class interfaces with the DUT using a virtual interface and processes the instruction and
// data fetched from the interface.
//-------------------------------------------------------------------------------------------------
class i_type_checker extends base_instruction_checker;

  `uvm_component_utils(i_type_checker)

  //-----------------------------------------------------------------------------------------------
  // Function: new
  //
  // Constructor for the i_type_checker. Initializes the checker with the given name or uses the
  // default "i_type_checker". Calls the base class constructor "base_instruction_checker".
  //
  // Parameters:
  // - name: The name of the checker (optional, default is "i_type_checker").
  // - parent: The parent UVM component (optional, default is null).
  //-----------------------------------------------------------------------------------------------
  function new(string name="i_type_checker", uvm_component parent=null);
    super.new(name, parent);
  endfunction : new

  //###############################################################################################
  // Task: check_instruction
  // Description: Specialized check for I-type instructions.
  //
  // Example: I-type instructions include ADDI, XORI, ORI, etc.
  //###############################################################################################
  task check_instruction();
    // Specialized check for I-type instructions
    if (this.opcode == i_type) begin      
      `uvm_info(get_full_name(), "`check_instruction` task running", UVM_LOW)

      fork
        check_sign_extension();
        check_zero_extension();
        check_valid_shift();
        check_operation();
      join_none
    end
  endtask : check_instruction

  //###############################################################################################
  // Task: check_operation
  // Description: Specialized check for I-type instructions. This task handles the verification of
  //              I-type instructions (such as ADDI, SLTIU, XORI, ORI, ANDI, SRLI, and SRAI) by
  //              calculating the result based on the immediate value and comparing it against the
  //              expected result in the destination register. If the result matches, the operation
  //              is deemed successful; otherwise, an error message is printed.
  //
  // I-type instructions involve immediate values that are added to or used with a source register
  // value (rs1) and stored in a destination register (rd).
  //
  // Example: I-type instructions include ADDI, XORI, ORI, SLTIU, ANDI, SRLI, and SRAI.
  //###############################################################################################
  task check_operation();
    // Fetch the source register value from the DUT register file
    logic [31:0] reg_rs1 = `HDL_TOP.REGS[instruction_intf.i_type.rs1];
    logic [11:0] i_type_imm = instruction_intf.i_type.imm;
    logic [2:0] funct3 = instruction_intf.i_type.funct3;
    logic [31:0] alu_result;

    repeat (2) @(posedge this.intf.CLK);

    // Fetch the destination register value from the DUT
    alu_result = `HDL_TOP.RMDATA;

    case (funct3)
      // ADDI Operation: Performs a add operation between rs1 and the immediate value, then checks
      // the result
      addi: begin
        logic [31:0] result;
        // Sign-extend the immediate value based on the MSB (bit 11)
        logic signed [31:0] imm = i_type_imm[11] ? '1 : '0;
        imm[11:0] = i_type_imm;

        // Compute the expected result for the operation
        result = reg_rs1 + imm;

        `uvm_info(
          get_full_name(),
            $sformatf(
            "ADDI: %08h + %08h = %08h (expected: %08h).",
            reg_rs1,
            imm,
            alu_result,
            result
          ),
          UVM_LOW
        )

        if (result === alu_result) begin
          `uvm_info(get_full_name(), "ADDI operation match", UVM_LOW)
        end
        else begin
          `uvm_error(get_full_name(), "ADDI operation mismatch")
        end
      end

      // SLLI Operation: Shifts the value in rs1 logically left depending on the `imm` bits.
      slli: begin
        logic [31:0] result;
        // Get the immediate value for the shift operation
        logic signed [31:0] imm = i_type_imm[11] ? '1 : '0;
        imm[11:0] = i_type_imm;

        // Compute the expected result for the operation
        result = reg_rs1 << imm[4:0];

        `uvm_info(
          get_full_name(),
            $sformatf(
            "SLLI: %08h << %08h = %08h (expected: %08h).",
            reg_rs1,
            imm,
            alu_result,
            result
          ),
          UVM_LOW
        )

        if (result === alu_result) begin
          `uvm_info(get_full_name(), "SLLI operation match", UVM_LOW)
        end
        else begin
          `uvm_error(get_full_name(), "SLLI operation mismatch")
        end
      end

      // SLTI Operation: Compares rs1 with the immediate value (signed comparison) and stores the
      // result in rd
      slti: begin
        logic [31:0] result;
        // Sign-extend the immediate value based on the MSB (bit 11)
        logic signed [31:0] imm = i_type_imm[11] ? '1 : '0;
        imm[11:0] = i_type_imm;

        // Compute the expected result for the operation
        result = $signed(reg_rs1) < $signed(imm);

        `uvm_info(
          get_full_name(),
            $sformatf(
            "SLTI: %08h < %08h = %08h (expected: %08h).",
            reg_rs1,
            imm,
            alu_result,
            result
          ),
          UVM_LOW
        )

        if (result === alu_result) begin
          `uvm_info(get_full_name(), "SLTI operation match", UVM_LOW)
        end
        else begin
          `uvm_error(get_full_name(), "SLTI operation mismatch")
        end
      end

      // SLTIU Operation: Compares rs1 with the immediate value (unsigned comparison) and stores
      // the result in rd
      sltiu: begin
        // Get the immediate value for the shift operation
        logic [31:0] imm = {20'b0, i_type_imm};

        // Compute the expected result for the operation
        logic [31:0] result = reg_rs1 < imm;

        `uvm_info(
          get_full_name(),
            $sformatf(
            "SLTIU: %08h < %08h = %08h (expected: %08h).",
            reg_rs1,
            imm,
            alu_result,
            result
          ),
          UVM_LOW
        )

        if (result === alu_result) begin
          `uvm_info(get_full_name(), "SLTIU operation match", UVM_LOW)
        end
        else begin
          `uvm_error(get_full_name(), "SLTIU operation mismatch")
        end
      end

      // XORI Operation: Performs a bitwise XOR between rs1 and the immediate value, then checks
      // the result
      xori: begin
        logic [31:0] result;
        // Sign-extend the immediate value based on the MSB (bit 11)
        logic signed [31:0] imm = i_type_imm[11] ? '1 : '0;
        imm[11:0] = i_type_imm;

        // Compute the expected result for the operation
        result = reg_rs1 ^ imm;

        `uvm_info(
          get_full_name(),
            $sformatf(
            "XORI: %08h ^ %08h = %08h (expected: %08h).",
            reg_rs1,
            imm,
            alu_result,
            result
          ),
          UVM_LOW
        )

        if (result === alu_result) begin
          `uvm_info(get_full_name(), "XORI operation match", UVM_LOW)
        end
        else begin
          `uvm_error(get_full_name(), "XORI operation mismatch")
        end
      end

      // SRLI/SRAI Operation: Shifts the value in rs1 right either logically or arithmetically,
      // depending on the `imm` bits.
      srli_srai: begin
        // Get the immediate value for the shift operation
        logic [31:0] imm = {20'b0, i_type_imm};

        // Compute the expected result for the operation
        logic [31:0] result = (imm[11:5] === 7'b010_0000) ?
                                (reg_rs1 >>> $signed(imm[4:0])) :
                                (reg_rs1 >> imm[4:0]);

        string inst_name = (imm[11:5] === 7'b010_0000) ? "SRAI" : "SRLI";
        string symb = (imm[11:5] === 7'b010_0000) ? ">>>" : ">>";

        `uvm_info(
          get_full_name(),
            $sformatf(
            "%s: %08h %s %08h = %08h (expected: %08h).",
            inst_name,
            reg_rs1,
            symb,
            imm[4:0],
            alu_result,
            result
          ),
          UVM_LOW
        )

        if (result === alu_result) begin
          `uvm_info(
            get_full_name(),
            $sformatf("%s operation match", inst_name),
            UVM_LOW
          )
        end
        else begin
          `uvm_error(
            get_full_name(),
            $sformatf("%s operation mismatch", inst_name)
          )
        end
      end

      // ORI Operation: Performs a bitwise OR between rs1 and the immediate value, then checks the
      // result.
      ori: begin
        logic [31:0] result;
        // Sign-extend the immediate value based on the MSB (bit 11)
        logic signed [31:0] imm = i_type_imm[11] ? '1 : '0;
        imm[11:0] = i_type_imm;

        // Compute the expected result for the operation
        result = reg_rs1 | imm;

        `uvm_info(
          get_full_name(),
            $sformatf(
            "ORI: %08h | %08h = %08h (expected: %08h).",
            reg_rs1,
            imm,
            alu_result,
            result
          ),
          UVM_LOW
        )

        if (result === alu_result) begin
          `uvm_info(get_full_name(), "ORI operation match", UVM_LOW)
        end
        else begin
          `uvm_error(get_full_name(), "ORI operation mismatch")
        end
      end

      // ANDI Operation: Performs a bitwise AND between rs1 and the immediate value, then checks
      // the result.
      andi: begin
        logic [31:0] result;
        // Sign-extend the immediate value based on the MSB (bit 11)
        logic signed [31:0] imm = i_type_imm[11] ? '1 : '0;
        imm[11:0] = i_type_imm;

        // Compute the expected result for the operation
        result = reg_rs1 & imm;

        `uvm_info(
          get_full_name(),
            $sformatf(
            "ANDI: %08h & %08h = %08h (expected: %08h).",
            reg_rs1,
            imm,
            alu_result,
            result
          ),
          UVM_LOW
        )

        if (result === alu_result) begin
          `uvm_info(get_full_name(), "ANDI operation match", UVM_LOW)
        end
        else begin
          `uvm_error(get_full_name(), "ANDI operation mismatch")
        end
      end

      // Default case for unsupported instructions
      default: begin
        `uvm_error(
          get_full_name(),
          $sformatf(
            "Operation (funct3) with code %03b (%d) is not supported.",
            instruction_intf.i_type.funct3,
            instruction_intf.i_type.funct3
          )
        )
      end
    endcase
  endtask : check_operation

  //###############################################################################################
  // Task: check_sign_extension
  // Description: This task checks the sign-extension of immediate values in instructions that
  //              require the immediate value to be sign-extended. The task verifies if the sign
  //              simulated value extension of the immediate value has been correctly performed by
  //              comparing the RTL (SIMM) to the immediate value (IMM) extracted from the
  //              instruction.
  //
  // Example: Instructions like ADDI, SLTI, XORI, ORI, and ANDI require sign-extension for their
  //          immediate values. The task checks that the immediate value has been correctly
  //          extended and prints the result.
  //
  // Notes: - If the instruction's `funct3` field matches ADDI, SLTI, XORI, ORI, or ANDI,
  //          sign-extension is applied.
  //        - The task prints a message indicating whether the extension is correct or if there is
  //          a mismatch.
  //###############################################################################################
  task check_sign_extension();
    // Instruction name for logging
    string inst_name;
    // Flag to indicate if sign-extension is required
    logic use_sign_ext;
    // Sign-extended immediate result
    logic [31:0] simm;
    // Funct3 value
    logic [2:0] funct3 = instruction_intf.i_type.funct3;
    // Immediate value (either sign-extended or zero-extended)
    logic signed [31:0] imm = instruction_intf.i_type.imm[11] ? '1 : '0;
    imm[11:0] = instruction_intf.i_type.imm;

    // Consider the HLT between instructions
    repeat (2) @(posedge this.intf.CLK);

    // Read immediate extension result
    simm = `HDL_TOP.SIMM;

    // Check the funct3 field to determine if the instruction uses sign-extension
    case (funct3)
      // ADDI Operation: Add Immediate with sign-extension
      addi: begin
        inst_name = "ADDI";
        use_sign_ext = 1'b1;
      end

      // SLLI Operation: Shift Left Logical Immediate with sign-extension
      slli: begin
        inst_name = "SLLI";
        use_sign_ext = 1'b1;
      end

      // SLTI Operation: Set Less Than Immediate, requires sign-extension
      slti: begin
        inst_name = "SLTI";
        use_sign_ext = 1'b1;
      end

      // XORI Operation: XOR Immediate, requires sign-extension
      xori: begin
        inst_name = "XORI";
        use_sign_ext = 1'b1;
      end

      // SRLI/SRAI Operation: Shift Right Logical Immediate or Shift Right Arithmetic Immediate
      srli_srai: begin
        inst_name = (imm[11:5] === 7'b010_0000) ? "SRAI" : "SRLI";
        use_sign_ext = 1'b1;
      end

      // ORI Operation: OR Immediate, requires sign-extension
      ori: begin
        inst_name = "ORI";
        use_sign_ext = 1'b1;
      end

      // ANDI Operation: AND Immediate, requires sign-extension
      andi: begin
        inst_name = "ANDI";
        use_sign_ext = 1'b1;
      end

      // Default case: No sign-extension required for other instructions
      default: begin
        use_sign_ext = 1'b0;
      end
    endcase

    // If sign-extension is required, check the value and print the results
    if (use_sign_ext === 1'b1) begin
      `uvm_info(
        get_full_name(),
        $sformatf(
          "%s sign-extension: %08h (expected: %08h).",
          inst_name,
          simm,
          imm
        ),
        UVM_LOW
      )

      // Compare the simulated immediate with the expected immediate
      if (simm === imm) begin
        `uvm_info(
          get_full_name(),
          $sformatf("IMM sign-extension for %s match", inst_name),
          UVM_LOW
        )
      end
      else begin
        `uvm_error(get_full_name(), $sformatf("IMM sign-extension for %s mismatch", inst_name))
      end
    end
  endtask : check_sign_extension

  //###############################################################################################
  // Task: check_zero_extension
  // Description: This task checks the zero-extension of immediate values in instructions that
  //              require the immediate value to be extended. The task verifies if the sign or zero
  //              extension of the immediate value has been correctly performed by comparing the
  //              RTL value (SIMM) to the immediate value (IMM) extracted from the instruction.
  //
  // Example: Instructions like SLLI, SLTIU, SRLI, and SRAI require zero-extension for their
  //          immediate values. The task checks that the immediate value has been correctly
  //          extended and prints the result.
  //
  // Notes: - If the instruction's `funct3` field matches SLLI, SLTIU, or SRLI/SRAI, zero-extension
  //          is applied.
  //        - The task prints a message indicating whether the extension is correct or if there is
  //          a mismatch.
  //###############################################################################################
  task check_zero_extension();
    // RTL value of the sign-extended immediate
    logic [31:0] simm;
    // Immediate value (either sign-extended or zero-extended)
    logic signed [31:0] imm = {20'b0, instruction_intf.i_type.imm};
    // Funct3 value
    logic [2:0] funct3 = instruction_intf.i_type.funct3;
    // Instruction name for logging
    string inst_name;
    // Flag to indicate if zero-extension is required
    logic use_zero_ext;

    // Consider the HLT between instructions
    repeat (2) @(posedge this.intf.CLK);

    // Read zero-extended immediate value
    simm = `HDL_TOP.SIMM;

    // Check the funct3 field to determine if the instruction uses zero-extension
    case (funct3)
      // SLTIU Operation: Set Less Than Immediate Unsigned, requires zero-extension
      sltiu: begin
        inst_name = "SLTIU";
        use_zero_ext = 1'b1;
      end

      // Default case: No zero-extension required for other instructions
      default: begin
        use_zero_ext = 1'b0;
      end
    endcase

    // If zero-extension is required, check the value and print the results
    if (use_zero_ext === 1'b1) begin
      `uvm_info(
        get_full_name(),
        $sformatf(
          "%s zero-extension: %08h (expected: %08h).",
          inst_name,
          simm,
          imm
        ),
        UVM_LOW
      )

      // Compare the simulated immediate with the expected immediate
      if (simm === imm) begin
        `uvm_info(
          get_full_name(),
          $sformatf("IMM zero-extension for %s match", inst_name),
          UVM_LOW
        )
      end
      else begin
        `uvm_error(get_full_name(), $sformatf("IMM zero-extension for %s mismatch", inst_name))
      end
    end
  endtask : check_zero_extension

  //###############################################################################################
  // Task: check_valid_shift
  // Description: This task verifies the validity of the immediate (IMM) field for shift
  //              instructions such as SLLI, SRLI, and SRAI. It checks whether the bit imm[5] is
  //              properly set to 0 for valid shift operations, as required by the RISC-V
  //              specification.
  //
  // Example: For SLLI (Shift Left Logical Immediate), SRLI (Shift Right Logical Immediate), and 
  //          SRAI (Shift Right Arithmetic Immediate), imm[5] must be 0 to ensure proper behavior.
  // 
  // Notes: - The task checks if the instruction is a shift operation by evaluating the funct3
  //          field.
  //        - If the instruction requires a shift operation, it logs whether the immediate field is
  //          valid by checking imm[5].
  //###############################################################################################
  task check_valid_shift();
    // Immediate value from the instruction
    logic [11:0] imm = instruction_intf.i_type.imm;
    // Instruction name for logging
    string inst_name;
    // Flag to indicate if the instruction is a shift operation
    logic is_shift;

    // Check the funct3 field to determine if the instruction is a shift operation
    case (instruction_intf.i_type.funct3)
      // SLLI Operation: Shift Left Logical Immediate
      slli: begin
        inst_name = "SLLI";
        is_shift = 1'b1;
      end

      // SRLI and SRAI Operations: Shift Right Logical and Arithmetic Immediate
      srli_srai: begin
        inst_name = (imm[11:5] === 7'b010_0000) ? "SRAI" : "SRLI";
        is_shift = 1'b1;
      end

      // Default case: No shift operation for other instructions
      default: begin
        is_shift = 1'b0;
      end
    endcase

    // If the instruction is a shift operation, validate the imm[5] bit
    if (is_shift === 1'b1) begin
      `uvm_info(
        get_full_name(),
        $sformatf(
          "%s imm[5]: %01b (expected: 0).",
          inst_name,
          imm[5]
        ),
        UVM_LOW
      )

      // Check if imm[5] is properly set to 0
      if (imm[5] === 1'b0) begin
        `uvm_info(
          get_full_name(),
          $sformatf("%s is properly set for shift operation", inst_name),
          UVM_LOW
        )
      end
      else begin
        `uvm_error(get_full_name(), $sformatf("%s bit imm[5] must be 0", inst_name))
      end
    end
  endtask : check_valid_shift
endclass : i_type_checker
