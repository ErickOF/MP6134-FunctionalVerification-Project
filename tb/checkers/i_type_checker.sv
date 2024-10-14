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

  task check_operation();
    logic [31:0] reg_rs1 = darksimv.core0.REGS[instruction_intf.i_type.rs1];
    logic [31:0] imm = instruction_intf.i_type.imm[11] ?
		         {'1, instruction_intf.i_type.imm} :
		         {'0, instruction_intf.i_type.imm};
    logic [31:0] reg_rd = darksimv.core0.REGS[instruction_intf.i_type.rd];

    case (instruction_intf.i_type.funct3)
      addi: begin
        logic [31:0] result = reg_rs1 + imm;
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
          `PRINT_INFO(this.name, "Operation match")
        end
        else begin
          `PRINT_ERROR(this.name, "Operation mismatch")
        end
      end
      slli: begin
        `PRINT_INFO(
          this.name,
	  $sformatf(
            "SLLI instruction detected."
          )
        )
      end
      slti: begin
        `PRINT_INFO(
          this.name,
	  $sformatf(
            "SLTI instruction detected."
          )
        )
      end
      sltiu: begin
        `PRINT_INFO(
          this.name,
	  $sformatf(
            "SLTIU instruction detected."
          )
        )
      end
      xori: begin
        `PRINT_INFO(
          this.name,
	  $sformatf(
            "XORI instruction detected."
          )
        )
      end
      srli_srai: begin
        `PRINT_INFO(
          this.name,
	  $sformatf(
            "SRLI/SRAI instruction detected."
          )
        )
      end
      ori: begin
        `PRINT_INFO(
          this.name,
	  $sformatf(
            "ORI instruction detected."
          )
        )
      end
      andi: begin
        `PRINT_INFO(
          this.name,
	  $sformatf(
            "ANDI instruction detected."
          )
        )
      end
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
