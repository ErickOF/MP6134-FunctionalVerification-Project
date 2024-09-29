// Based on: https://www.edaplayground.com/x/Yk4N
class stimulus;
  // Fields for RISC-V core instructions
  rand inst_type_e  inst_type;
  rand logic [4:0]  rd;
  rand logic [4:0]  rs1;
  rand logic [4:0]  rs2;
  rand logic [2:0]  funct3;
  rand logic [6:0]  funct7;
  rand logic [31:0] imm;
  // Pointers for handle the complete instruction and the corresponding data (if necessary, for example: store instructions)
  rand logic [31:0] riscv_inst;
  rand logic [31:0] riscv_data;

  constraint valid_inst {
    if (inst_type == r_type) {
      riscv_inst == {funct7, rs2, rs1, funct3, rd, opcode};
    }
    else if (inst_type == i_type) {
      riscv_inst == {imm[11:0], rs1, funct3, rd, opcode};
    }
    else if (inst_type == s_type) {
      riscv_inst == {imm[11:5], rs2, rs1, funct3, imm[4:0], opcode};
    }
    else if (inst_type == b_type) {
      riscv_inst == {imm[12], imm[10:5], rs2, rs1, funct3, imm[4:1], imm[11], opcode};
    }
    else if (inst_type == u_type) {
      riscv_inst == {imm[31:12], rd, opcode};
    }
    else { // Assume that it will be a J instruction type
      riscv_inst == {imm[20], imm[10:1], imm[11], imm[19:12], rd, opcode};
    }
    solve inst_type before riscv_inst; // We need to first known the instruction type in order to determine valid instructions
  }
  
endclass : stimulus
