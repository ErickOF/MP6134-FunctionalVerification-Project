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

  
endclass : stimulus
