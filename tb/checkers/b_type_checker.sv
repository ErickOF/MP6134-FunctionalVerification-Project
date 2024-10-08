class b_type_checker extends base_instruction_checker;
  //###############################################################################################
  // Task: check_instruction
  // Description: Specialized check for B-type instructions.
  //
  //              B-type instructions include conditional branches such as BEQ (branch if equal),
  //              BNE (branch if not equal), etc.
  //
  // Example: B-type instructions are used for conditional branching based on register comparisons
  //          in RISC-V architectures.
  //###############################################################################################
  task check_instruction();
    // Specialized check for B-type instructions
    if (this.opcode == b_type) begin
      `PRINT_INFO(this.name, "`check_instruction` task running")

      `PRINT_INFO(
        `MONITOR_NAME,
        $sformatf(
          "\nOPCODE: 0b%07b (%s),\nIMM[11]: 0b%01b,\nIMM[4:1]: 0b%04b (%d),\nFUNCT3: 0b%03b (%d),\nRS1: 0b%05b (%d),\nRS2: 0b%05b (%d),\nIMM[10:5]: 0x%02h (%d),\nIMM[12]: 0x%01b",
          // Opcode (7 bits)
          instruction_intf.b_type.opcode,
          // Opcode name
          instruction_intf.b_type.opcode.name(),
          // Immediate [11]
          instruction_intf.b_type.imm1,
          // Immediate [4:1]
          instruction_intf.b_type.imm2,
          // Immediate [4:1] in decimal
          instruction_intf.b_type.imm2,
          // Function field (3 bits)
          instruction_intf.b_type.funct3,
          // Function field in decimal
          instruction_intf.b_type.funct3,
          // Source register 1 (5 bits)
          instruction_intf.b_type.rs1,
          // RS1 in decimal
          instruction_intf.b_type.rs1,
          // Source register 2 (5 bits)
          instruction_intf.b_type.rs2,
          // RS2 in decimal
          instruction_intf.b_type.rs2,
          // Immediate [10:5]
          instruction_intf.b_type.imm3,
          // Immediate [10:5] in decimal
          instruction_intf.b_type.imm3,
          // Immediate [12]
          instruction_intf.b_type.imm4
        )
      )
    end
  endtask check_instruction
endclass : b_type_checker
