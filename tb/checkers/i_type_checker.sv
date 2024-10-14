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
    case (instruction_intf.i_type.funct3)
      // Fetch the source register value from the DUT register file
      logic [31:0] reg_rs1 = darksimv.core0.REGS[instruction_intf.i_type.rs1];
      // Fetch the destination register value from the DUT
      logic [31:0] reg_rd = darksimv.core0.REGS[instruction_intf.i_type.rd];

      // ADDI Operation: Performs a add operation between rs1 and the immediate value, then checks
      // the result
      addi: begin
        // Sign-extend the immediate value based on the MSB (bit 11)
        logic signed [31:0] imm = instruction_intf.i_type.imm[11] ?
                {'1, instruction_intf.i_type.imm} :
                {'0, instruction_intf.i_type.imm};

        // Compute the expected result for the operation
        logic [31:0] result = reg_rs1 + simm;

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
        logic [31:0] imm = instruction_intf.i_type.imm[11] ?
                {'1, instruction_intf.i_type.imm} :
                {'0, instruction_intf.i_type.imm};

        // Compute the expected result for the operation
        logic [31:0] result = reg_rs1 << imm;

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
        // Sign-extend the immediate value based on the MSB (bit 11)
        logic sgined [31:0] imm = instruction_intf.i_type.imm[11] ?
                {'1, instruction_intf.i_type.imm} :
                {'0, instruction_intf.i_type.imm};

        // Compute the expected result for the operation
        logic [31:0] result = reg_rs1 < imm;

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
        // Sign-extend the immediate value based on the MSB (bit 11)
        logic [31:0] imm = instruction_intf.i_type.imm[11] ?
                {'1, instruction_intf.i_type.imm} :
                {'0, instruction_intf.i_type.imm};

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
        // Sign-extend the immediate value based on the MSB (bit 11)
        logic signed [31:0] imm = instruction_intf.i_type.imm[11] ?
                {'1, instruction_intf.i_type.imm} :
                {'0, instruction_intf.i_type.imm};

        // Compute the expected result for the operation
        logic [31:0] result = reg_rs1 ^ imm;

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
        // Sign-extend the immediate value based on the MSB (bit 11)
        logic [31:0] imm = instruction_intf.i_type.imm[11] ?
                {'1, instruction_intf.i_type.imm} :
                {'0, instruction_intf.i_type.imm};

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
            simm,
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
        // Sign-extend the immediate value based on the MSB (bit 11)
        logic signed [31:0] imm = instruction_intf.i_type.imm[11] ?
                {'1, instruction_intf.i_type.imm} :
                {'0, instruction_intf.i_type.imm};

        // Compute the expected result for the operation
        logic [31:0] result = reg_rs1 | imm;

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
        // Sign-extend the immediate value based on the MSB (bit 11)
        logic signed [31:0] imm = instruction_intf.i_type.imm[11] ?
                {'1, instruction_intf.i_type.imm} :
                {'0, instruction_intf.i_type.imm};

        // Compute the expected result for the operation
        logic [31:0] result = reg_rs1 & imm;

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
endclass : i_type_checker
