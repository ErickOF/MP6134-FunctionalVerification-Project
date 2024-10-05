`ifndef INSTRUCTIONS_PKG_SVH
`define INSTRUCTIONS_PKG_SVH

package instructions_pkg;

typedef enum logic [6:0] {
  r_type = 7'b011_0011,
  i_type = 7'b001_0011, //TODO: only for: ADDI, XORI, ORI, ANDI, SLLI, SRLI, SRAI, SLTI and SLTIU
  s_type = 7'b010_0011,
  b_type = 7'b110_0011,
  u_type = 7'b001_0111, //TODO: only for AUIPC
  j_type = 7'b110_1111 //TODO: only for JAL
} inst_type_e;

// Represents IMM instructions
typedef struct packed {
  logic [11:0] imm;
  logic [4:0] rs1;
  logic [2:0] func3;
  logic [4:0] rd;
  inst_type_e opcode;
} i_type_t;

// Represents the RISV-V instruction
typedef union packed {
  struct packed {
    logic [31:7] fillin;
    inst_type_e opcode;
  } opcode;
  i_type_t i_type;
} instruction_t;

endpackage : instructions_pkg

`endif // INSTRUCTIONS_PKG_SVH
