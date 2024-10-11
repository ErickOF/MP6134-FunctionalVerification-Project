class r_type_checker extends base_instruction_checker;
  function new(string name, virtual darkriscv_if intf, scoreboard sb);
    super.new(name, intf, sb);
  endfunction : new

  //###############################################################################################
  // Task: check_instruction
  // Description: Specialized check for R-type instructions.
  //
  // Example: R-type instructions include ADD, SUB, AND, etc.
  //###############################################################################################
  task check_instruction();
    // Specialized check for R-type instructions
    if (this.opcode == r_type) begin
      `PRINT_INFO(this.name, "`check_instruction` task running")

      `PRINT_INFO(
        this.name,
        $sformatf(
          "\nOPCODE: 0b%07b (%s),\nRD: 0b%05b (%d),\nFUNCT3: 0b%03b (%d),\nRS1: 0b%05b (%d),\nRS2: 0b%05b (%d),\nFUNCT7: 0x%02h (%d)\n",
          // Opcode (7 bits)
          instruction_intf.r_type.opcode,
          // Opcode name
          instruction_intf.r_type.opcode.name(),
          // Destination register (5 bits)
          instruction_intf.r_type.rd,
          // RD in decimal
          instruction_intf.r_type.rd,
          // Function field (3 bits)
          instruction_intf.r_type.funct3,
          // Function field in decimal
          instruction_intf.r_type.funct3,
          // Source register 1 (5 bits)
          instruction_intf.r_type.rs1,
          // RS1 in decimal
          instruction_intf.r_type.rs1,
          // Source register 2 (5 bits)
          instruction_intf.r_type.rs2,
          // RS2 in decimal
          instruction_intf.r_type.rs2,
          // Function field (7 bits)
          instruction_intf.r_type.funct7,
          // Function field (7 bits) in decimal
          instruction_intf.r_type.funct7
        )
      )
    end
  endtask : check_instruction
endclass : r_type_checker
