//#################################################################################################
// File: instructions_pkg.svh
// Description: This package defines an enumeration for RISC-V instruction types, as well as data
//              structures representing instruction formats (specifically `i_type_t`
//              for immediate-type instructions) and a union `instruction_t` that can hold
//              different instruction types.
//
//              The package is designed for RISC-V ISA instruction encoding with a focus on opcode
//              and immediate-type instructions.
//##############################################################################

// Guard to prevent multiple inclusions of this file
`ifndef INSTRUCTIONS_PKG_SVH
`define INSTRUCTIONS_PKG_SVH

//#################################################################################################
// Package: instructions_pkg
// This package contains enumerations and structures to represent RISC-V instruction types and
// formats.
//#################################################################################################

package instructions_pkg;
  //###############################################################################################
  // Enum: inst_type_e
  // Description: Defines the opcode field for different types of RISC-V instructions. Each type is
  //              represented by a 7-bit value.
  //
  // Fields:
  //  - r_type: Represents the opcode for R-type instructions (register type).
  //  - i_type: Represents the opcode for I-type instructions (immediate type).
  //  - s_type: Represents the opcode for S-type instructions (store type).
  //  - b_type: Represents the opcode for B-type instructions (branch type).
  //  - u_type: Represents the opcode for U-type instructions (upper immediate type).
  //  - j_type: Represents the opcode for J-type instructions (jump type).
  //##########################################################################
  typedef enum logic [6:0] {
    // R-type instructions (register)
    r_type = 7'b011_0011,
    // I-type instructions (immediate)
    // TODO: only for: ADDI, XORI, ORI, ANDI, SLLI, SRLI, SRAI, SLTI and SLTIU
    i_type = 7'b001_0011,
    // S-type instructions (store)
    s_type = 7'b010_0011,
    // B-type instructions (branch)
    b_type = 7'b110_0011,
    // U-type instructions (AUIPC)
    // TODO: only for AUIPC
    u_type = 7'b001_0111,
    // J-type instructions (JAL)
    // TODO: only for JAL
    j_type = 7'b110_1111
  } inst_type_e;

//#################################################################################################
// Struct: i_type_t
// Description: Represents an I-type (immediate-type) RISC-V instruction format. This structure
//              encodes the components of an I-type instruction.
//
// Fields:
//  - imm  : The immediate value, 12 bits.
//  - rs1  : Source register 1, 5 bits.
//  - func3: Function field to define the operation, 3 bits.
//  - rd   : Destination register, 5 bits.
//  - opcode: Opcode field from the `inst_type_e` enum, 7 bits.
//
// Example: A typical I-type instruction might be ADDI, which adds an immediate value to the value
//          of rs1 and stores the result in rd.
//#################################################################################################
typedef struct packed {
  // Immediate field (12 bits)
  logic [11:0] imm;
  // Source register 1 (5 bits)
  logic [4:0] rs1;
  // Function field (3 bits)
  logic [2:0] func3;
  // Destination register (5 bits)
  logic [4:0] rd;
  // Opcode (7 bits)
  inst_type_e opcode;
} i_type_t;

//#################################################################################################
// Union: instruction_t
// Description: A union that represents a RISC-V instruction. It can either  hold the opcode field
//              directly, or represent an I-type instruction.
//
// Fields:
//  - opcode: A structure that contains the opcode (7 bits) and filler bits.
//  - i_type: A structure representing an I-type instruction (12-bit immediate, rs1, func3, rd, and
//            opcode).
//
// Example: This union can be used to interpret the 32-bit instruction word as either just an
//          opcode or as a more complex I-type instruction.
//#################################################################################################
typedef union packed {
  struct packed {
    // Filler bits to occupy space up to bit 31
    logic [31:7] fillin;
    // Opcode field (7 bits)
    inst_type_e opcode;
  } opcode;
  // I-type instruction
  i_type_t i_type;
} instruction_t;

endpackage : instructions_pkg

`endif // INSTRUCTIONS_PKG_SVH
