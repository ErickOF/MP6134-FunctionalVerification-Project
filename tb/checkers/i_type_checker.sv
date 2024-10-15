class i_type_checker extends base_instruction_checker;
  function new(string name, virtual darkriscv_if intf, scoreboard sb);
    super.new(name, intf, sb);
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
      `PRINT_INFO(this.name, "`check_instruction` task running")

      `PRINT_INFO(
        this.name,
        $sformatf(
          "\nOPCODE: 0b%07b (%s),\nRD: 0b%05b (%d),\nFUNCT3: 0b%03b (%d),\nRS1: 0b%05b (%d),\nIMM: 0x%03h (%d)\n",
          // Opcode (7 bits)
          instruction_intf.i_type.opcode,
          // Opcode name
          instruction_intf.i_type.opcode.name(),
          // Destination register (5 bits)
          instruction_intf.i_type.rd,
          // RD in decimal
          instruction_intf.i_type.rd,
          // Function field (3 bits)
          instruction_intf.i_type.funct3,
          // Function field in decimal
          instruction_intf.i_type.funct3,
          // Source register 1 (5 bits)
          instruction_intf.i_type.rs1,
          // RS1 in decimal
          instruction_intf.i_type.rs1,
          // Immediate value (12 bits)
          instruction_intf.i_type.imm,
          // Immediate in decimal
          instruction_intf.i_type.imm
        )
      )

      check_sign_extension();
      check_zero_extension();
      check_operation();
    end
  endtask : check_instruction

  //###############################################################################################
  // Task: check_instruction
  // Description: Specialized check for I-type instructions. This task handles the verification
  //              of I-type instructions (such as ADDI, SLTIU, XORI, ORI, ANDI, SRLI, and SRAI)
  //              by calculating the result based on the immediate value and comparing it against
  //              the expected result in the destination register. If the result matches,
  //              the operation is deemed successful; otherwise, an error message is printed.
  //
  // I-type instructions involve immediate values that are added to or used with a source register
  // value (rs1) and stored in a destination register (rd).
  //
  // Example: I-type instructions include ADDI, XORI, ORI, SLTIU, ANDI, SRLI, and SRAI.
  //###############################################################################################
  task check_operation();
    // Fetch the source register value from the DUT register file
    logic [31:0] reg_rs1 = darksimv.core0.REGS[instruction_intf.i_type.rs1];
    logic [31:0] reg_rd;

    @(posedge this.intf.CLK);

    // Fetch the destination register value from the DUT
    reg_rd = darksimv.core0.REGS[instruction_intf.i_type.rd];

    case (instruction_intf.i_type.funct3)
      // ADDI Operation: Performs a add operation between rs1 and the immediate value, then checks
      // the result
      addi: begin
        logic [31:0] result;
        // Sign-extend the immediate value based on the MSB (bit 11)
        logic signed [31:0] imm = instruction_intf.i_type.imm[11] ? '1 : '0;
        imm[11:0] = instruction_intf.i_type.imm;

        // Compute the expected result for the operation
        result = reg_rs1 + imm;

        `PRINT_INFO(
          this.name,
            $sformatf(
            "ADDI: %08h + %08h = %08h (expected: %08h).",
            reg_rs1,
            imm,
            reg_rd,
            result
          )
        )

        if (result === reg_rd) begin
          `PRINT_INFO(this.name, "ADDI operation match")
        end
        else begin
          `PRINT_ERROR(this.name, "ADDI operation mismatch")
        end
      end

      // SLLI Operation: Shifts the value in rs1 logically left depending on the `imm` bits.
      slli: begin
        // Get the immediate value for the shift operation
        logic [31:0] imm = {20'b0, instruction_intf.i_type.imm};

        // Compute the expected result for the operation
        logic [31:0] result = reg_rs1 << imm[4:0];

        `PRINT_INFO(
          this.name,
            $sformatf(
            "SLLI: %08h << %08h = %08h (expected: %08h).",
            reg_rs1,
            imm,
            reg_rd,
            result
          )
        )

        if (result === reg_rd) begin
          `PRINT_INFO(this.name, "SLLI operation match")
        end
        else begin
          `PRINT_ERROR(this.name, "SLLI operation mismatch")
        end
      end

      // SLTI Operation: Compares rs1 with the immediate value (signed comparison) and stores the
      // result in rd
      slti: begin
        logic [31:0] result;
        // Sign-extend the immediate value based on the MSB (bit 11)
        logic signed [31:0] imm = instruction_intf.i_type.imm[11] ? '1 : '0;
        imm[11:0] = instruction_intf.i_type.imm;

        // Compute the expected result for the operation
        result = reg_rs1 < imm;

        `PRINT_INFO(
          this.name,
            $sformatf(
            "SLTI: %08h < %08h = %08h (expected: %08h).",
            reg_rs1,
            imm,
            reg_rd,
            result
          )
        )

        if (result === reg_rd) begin
          `PRINT_INFO(this.name, "SLTI operation match")
        end
        else begin
          `PRINT_ERROR(this.name, "SLTI operation mismatch")
        end
      end

      // SLTIU Operation: Compares rs1 with the immediate value (unsigned comparison) and stores
      // the result in rd
      sltiu: begin
        // Get the immediate value for the shift operation
        logic [31:0] imm = {20'b0, instruction_intf.i_type.imm};

        // Compute the expected result for the operation
        logic [31:0] result = reg_rs1 < imm;

        `PRINT_INFO(
          this.name,
            $sformatf(
            "SLTIU: %08h < %08h = %08h (expected: %08h).",
            reg_rs1,
            imm,
            reg_rd,
            result
          )
        )

        if (result === reg_rd) begin
          `PRINT_INFO(this.name, "SLTIU operation match")
        end
        else begin
          `PRINT_ERROR(this.name, "SLTIU operation mismatch")
        end
      end

      // XORI Operation: Performs a bitwise XOR between rs1 and the immediate value, then checks
      // the result
      xori: begin
        logic [31:0] result;
        // Sign-extend the immediate value based on the MSB (bit 11)
        logic signed [31:0] imm = instruction_intf.i_type.imm[11] ? '1 : '0;
        imm[11:0] = instruction_intf.i_type.imm;

        // Compute the expected result for the operation
        result = reg_rs1 ^ imm;

        `PRINT_INFO(
          this.name,
            $sformatf(
            "XORI: %08h < %08h = %08h (expected: %08h).",
            reg_rs1,
            imm,
            reg_rd,
            result
          )
        )

        if (result === reg_rd) begin
          `PRINT_INFO(this.name, "XORI operation match")
        end
        else begin
          `PRINT_ERROR(this.name, "XORI operation mismatch")
        end
      end

      // SRLI/SRAI Operation: Shifts the value in rs1 right either logically or arithmetically,
      // depending on the `imm` bits.
      srli_srai: begin
        // Get the immediate value for the shift operation
        logic [31:0] imm = {'0, instruction_intf.i_type.imm};

        // Compute the expected result for the operation
        logic [31:0] result = (imm[11:5] === 7'b010_0000) ?
                                ($signed(reg_rs1) >>> imm[4:0]) :
                                (reg_rs1 <<< imm[4:0]);

        string inst_name = (imm[11:5] === 7'b010_0000) ? "SRAI" : "SRLI";

        `PRINT_INFO(
          this.name,
            $sformatf(
            "%s: %08h < %08h = %08h (expected: %08h).",
            inst_name,
            reg_rs1,
            imm,
            reg_rd,
            result
          )
        )

        if (result === reg_rd) begin
          `PRINT_INFO(
            this.name,
            $sformatf("%s operation match", inst_name)
          )
        end
        else begin
          `PRINT_INFO(
            this.name,
            $sformatf("%s operation mismatch", inst_name)
          )
        end
      end

      // ORI Operation: Performs a bitwise OR between rs1 and the immediate value, then checks the
      // result.
      ori: begin
        logic [31:0] result;
        // Sign-extend the immediate value based on the MSB (bit 11)
        logic signed [31:0] imm = instruction_intf.i_type.imm[11] ? '1 : '0;
        imm[11:0] = instruction_intf.i_type.imm;

        // Compute the expected result for the operation
        result = reg_rs1 | imm;

        `PRINT_INFO(
          this.name,
            $sformatf(
            "ORI: %08h < %08h = %08h (expected: %08h).",
            reg_rs1,
            imm,
            reg_rd,
            result
          )
        )

        if (result === reg_rd) begin
          `PRINT_INFO(this.name, "ORI operation match")
        end
        else begin
          `PRINT_ERROR(this.name, "ORI operation mismatch")
        end
      end

      // ANDI Operation: Performs a bitwise AND between rs1 and the immediate value, then checks
      // the result.
      andi: begin
        logic [31:0] result;
        // Sign-extend the immediate value based on the MSB (bit 11)
        logic signed [31:0] imm = instruction_intf.i_type.imm[11] ? '1 : '0;
        imm[11:0] = instruction_intf.i_type.imm;

        // Compute the expected result for the operation
        result = reg_rs1 & imm;

        `PRINT_INFO(
          this.name,
            $sformatf(
            "ANDI: %08h < %08h = %08h (expected: %08h).",
            reg_rs1,
            imm,
            reg_rd,
            result
          )
        )

        if (result === reg_rd) begin
          `PRINT_INFO(this.name, "ANDI operation match")
        end
        else begin
          `PRINT_ERROR(this.name, "ANDI operation mismatch")
        end
      end

      // Default case for unsupported instructions
      default: begin
        `PRINT_ERROR(
          this.name,
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
    // Simulated value of the sign-extended immediate
    logic [31:0] simm = darksimv.core0.SIMM;
    // Immediate value (either sign-extended or zero-extended)
    logic signed [31:0] imm = instruction_intf.i_type.imm[11] ? '1 : '0;
    // Instruction name for logging
    string inst_name;
    // Flag to indicate if sign-extension is required
    logic use_sign_ext;
  
    // Check the funct3 field to determine if the instruction uses sign-extension
    case (instruction_intf.i_type.funct3)
  
      // ADDI Operation: Add Immediate with sign-extension
      addi: begin
        inst_name = "ADDI";
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
      `PRINT_INFO(
        this.name,
        $sformatf(
          "%s sign extension: %08h (expected: %08h).",
          inst_name,
          simm,
          imm
        )
      )
  
      // Compare the simulated immediate with the expected immediate
      if (simm === imm) begin
        `PRINT_INFO(this.name, $sformatf("IMM sign-extension for %s match", inst_name))
      end
      else begin
        `PRINT_ERROR(this.name, $sformatf("IMM sign-extension for %s mismatch", inst_name))
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
    logic [31:0] simm = darksimv.core0.SIMM;
    // Immediate value (either sign-extended or zero-extended)
    logic signed [31:0] imm = instruction_intf.i_type.imm[11] ? '1 : '0;
    // Instruction name for logging
    string inst_name;
    // Flag to indicate if zero-extension is required
    logic use_zero_ext;

    // Check the funct3 field to determine if the instruction uses zero-extension
    case (instruction_intf.i_type.funct3)
      // SLLI Operation: Shift Left Logical Immediate with zero-extension
      slli: begin
        inst_name = "SLLI";
        use_zero_ext = 1'b1;
      end

      // SLTIU Operation: Set Less Than Immediate Unsigned, requires zero-extension
      sltiu: begin
        inst_name = "SLTIU";
        use_zero_ext = 1'b1;
      end

      // SRLI/SRAI Operation: Shift Right Logical Immediate or Shift Right Arithmetic Immediate
      srli_srai: begin
        inst_name = (imm[11:5] === 7'b010_0000) ? "SRAI" : "SRLI";
        use_zero_ext = 1'b1;
      end

      // Default case: No zero-extension required for other instructions
      default: begin
        use_zero_ext = 1'b0;
      end
    endcase

    // If zero-extension is required, check the value and print the results
    if (use_zero_ext === 1'b1) begin
      `PRINT_INFO(
        this.name,
        $sformatf(
          "%s sign extension: %08h (expected: %08h).",
          inst_name,
          simm,
          imm
        )
      )

      // Compare the simulated immediate with the expected immediate
      if (simm === imm) begin
        `PRINT_INFO(this.name, $sformatf("IMM sign-extension for %s match", inst_name))
      end
      else begin
        `PRINT_ERROR(this.name, $sformatf("IMM sign-extension for %s mismatch", inst_name))
      end
    end
  endtask : check_zero_extension
endclass : i_type_checker
