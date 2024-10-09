class s_type_checker extends base_instruction_checker;
  function new(string name, virtual darkriscv_if intf, scoreboard sb);
    super.new(name, intf, sb);
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
      `PRINT_INFO(this.name, "`check_instruction` task running")

      `PRINT_INFO(
        this.name,
        $sformatf(
          "\nOPCODE: 0b%07b (%s),\nIMM[4:0]: 0b%05b (%d),\nFUNCT3: 0b%03b (%d),\nRS1: 0b%05b (%d),\nRS2: 0b%05b (%d),\nIMM[11:5]: 0x%02h (%d)\n",
          // Opcode (7 bits)
          instruction_intf.s_type.opcode,
          // Opcode name
          instruction_intf.s_type.opcode.name(),
          // Immediate [4:0]
          instruction_intf.s_type.imm1,
          // Immediate [4:0] in decimal
          instruction_intf.s_type.imm1,
          // Function field (3 bits)
          instruction_intf.s_type.funct3,
          // Function field in decimal
          instruction_intf.s_type.funct3,
          // Source register 1 (5 bits)
          instruction_intf.s_type.rs1,
          // RS1 in decimal
          instruction_intf.s_type.rs1,
          // Source register 2 (5 bits)
          instruction_intf.s_type.rs2,
          // RS2 in decimal
          instruction_intf.s_type.rs2,
          // Immediate [11:5]
          instruction_intf.s_type.imm2,
          // Immediate [11:5] in decimal
          instruction_intf.s_type.imm2
        )
      )
    end
  endtask : check_instruction
endclass : s_type_checker
