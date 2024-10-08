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
    end
  endtask : check_instruction
endclass : i_type_checker
