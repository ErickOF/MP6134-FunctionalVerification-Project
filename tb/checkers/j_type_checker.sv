class j_type_checker extends base_instruction_checker;
  function new(string name, virtual darkriscv_if intf, scoreboard sb);
    super.new(name, intf, sb);
  endfunction : new

  //###############################################################################################
  // Task: check_instruction
  // Description: Specialized check for J-type instructions.
  //
  //              J-type instructions are used for jump operations, which typically alter the flow
  //              of execution by jumping to a specified address. The most common J-type
  //              instruction in RISC-V is JAL (Jump and Link), which jumps to a target address and
  //              saves the return address in a register.
  //
  // Example: J-type instructions can be utilized for function calls and for implementing control
  //          flow in programs.
  //###############################################################################################
  task check_instruction();
    // Specialized check for J-type instructions
    if (this.opcode == j_type) begin
      `PRINT_INFO(this.name, "`check_instruction` task running")

      `PRINT_INFO(
        this.name,
        $sformatf(
          "\nOPCODE: 0b%07b (%s),\nRD: 0b%05b (%d),\nIMM[19:12]: 0b%02h (%d),\nIMM[11]: 0b%01b,\nIMM[10:1]: 0x%03h (%d),\nIMM[20]: 0b%01b\n",
          // Opcode (7 bits)
          instruction_intf.j_type.opcode,
          // Opcode name
          instruction_intf.j_type.opcode.name(),
          // Destination register (5 bits)
          instruction_intf.j_type.rd,
          // RD in decimal
          instruction_intf.j_type.rd,
          // Immediate [19:12]
          instruction_intf.j_type.imm1,
          // Immediate [19:12] in decimal
          instruction_intf.j_type.imm1,
          // Immediate [11]
          instruction_intf.j_type.imm2,
          // Immediate [10:1]
          instruction_intf.j_type.imm3,
          // Immediate [10:1] in decimal
          instruction_intf.j_type.imm3,
          // Immediate [20]
          instruction_intf.j_type.imm4
        )
      )
    end
  endtask : check_instruction
endclass : j_type_checker
