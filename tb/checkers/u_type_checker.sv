class u_type_checker extends base_instruction_checker;
  function new(string name, virtual darkriscv_if intf, scoreboard sb);
    super.new(name, intf, sb);
  endfunction : new

  //###############################################################################################
  // Task: check_instruction
  // Description: Specialized check for U-type instructions.
  //
  //              U-type instructions are used for operations that require a 20-bit immediate value
  //              that is sign-extended to 32 bits. The most common U-type instructions in RISC-V
  //              are LUI (Load Upper Immediate) and AUIPC (Add Upper Immediate to PC).
  //
  // Example: U-type instructions are often used to set up immediate values in higher-order bits,
  //          which can then be combined with lower order bits using other instructions for address
  //          calculations.
  //###############################################################################################
  task check_instruction();
    // Specialized check for S-type instructions
    if (this.opcode == s_type) begin
      `PRINT_INFO(this.name, "`check_instruction` task running")

      `PRINT_INFO(
        this.name,
        $sformatf(
          "\nOPCODE: 0b%07b (%s),\nRD: 0b%05b (%d),\nIMM[19:0]: 0x%05h (%d)\n",
          // Opcode (7 bits)
          instruction_intf.u_type.opcode,
          // Opcode name
          instruction_intf.u_type.opcode.name(),
          // Destination register (5 bits)
          instruction_intf.u_type.rd,
          // RD in decimal
          instruction_intf.u_type.rd,
          // Immediate value (20 bits)
          instruction_intf.u_type.imm,
          // Immediate in decimal
          instruction_intf.u_type.imm
        )
      )
    end
  endtask : check_instruction
endclass : u_type_checker
