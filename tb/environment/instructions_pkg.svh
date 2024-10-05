`ifndef INSTRUCTIONS_PKG_SVH
`define INSTRUCTIONS_PKG_SVH

package instructions_pkg;

// Represents IMM instructions
typedef struct packed {
  logic [11:0] imm;
  logic [4:0] rs1;
  logic [2:0] func3;
  logic [4:0] rd;
//  inst_type_e opcode;
} i_type_t;

// Represents the RISV-V instruction
typedef union packed {
//  inst_type_e opcode;
  i_type_t i_type;
} instruction_t;

endpackage : instructions_pkg

`endif // INSTRUCTIONS_PKG_SVH
