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
//#################################################################################################
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
//#################################################################################################
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
// Struct: b_type_t
// Description: Represents a B-type (branch-type) RISC-V instruction format. This structure encodes
//              the components of a B-type instruction.
//
// Fields:
//  - imm4   : Immediate value used for branch offset, 1 bit.
//  - imm3   : Immediate value used for branch offset, 6 bits.
//  - rs2    : Source register 2, 5 bits, typically used as the second operand for comparison.
//  - rs1    : Source register 1, 5 bits, typically used as the first operand for comparison.
//  - funct3 : Function field to specify the operation subtype for branching, 3 bits.
//  - imm2   : Immediate value used for branch offset, 4 bits.
//  - imm1   : Immediate value used for branch offset, 1 bit.
//  - opcode : Opcode field from the `inst_type_e` enum, 7 bits.
//
// Example: A typical B-type instruction might be BEQ, which compares the values in rs1 and rs2,
//          and if they are equal, it branches to the specified immediate offset.
//#################################################################################################
typedef struct packed {
  // Immediate value used for branch offset (1 bit)
  logic imm4;
  // Immediate value used for branch offset (6 bits)
  logic [5:0] imm3;
  // Source register 2 (5 bits)
  logic [4:0] rs2;
  // Source register 1 (5 bits)
  logic [4:0] rs1;
  // Function field (3 bits)
  logic [2:0] funct3;
  // Immediate value used for branch offset (4 bits)
  logic [3:0] imm2;
  // Immediate value used for branch offset (1 bit)
  logic imm1;
  // Opcode (7 bits)
  inst_type_e opcode;
} b_type_t;

//#################################################################################################
// Struct: i_type_t
// Description: Represents an I-type (immediate-type) RISC-V instruction format. This structure
//              encodes the components of an I-type instruction.
//
// Fields:
//  - imm    : The immediate value, 12 bits.
//  - rs1    : Source register 1, 5 bits.
//  - funct3 : Function field to define the operation, 3 bits.
//  - rd     : Destination register, 5 bits.
//  - opcode : Opcode field from the `inst_type_e` enum, 7 bits.
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
  logic [2:0] funct3;
  // Destination register (5 bits)
  logic [4:0] rd;
  // Opcode (7 bits)
  inst_type_e opcode;
} i_type_t;

//#################################################################################################
// Struct: j_type_t
// Description: Represents a J-type (jump) RISC-V instruction format. This structure encodes the
//              components of a J-type instruction, which typically involves jumping to a target
//              address.
//
// Fields:
//  - imm4   : Immediate value bit (1 bit) used to extend the immediate value for jumps.
//  - imm3   : Immediate value (10 bits) that contributes to the address calculation.
//  - imm2   : Immediate value bit (1 bit) that is used in the target address.
//  - imm1   : Immediate value (8 bits) that also contributes to the jump address calculation.
//  - rd     : Destination register (5 bits) where the target address is stored.
//  - opcode : Opcode field from the `inst_type_e` enum (7 bits) that specifies the jump operation.
//
// Example: A typical J-type instruction might be JAL (Jump and Link), which calculates a jump
//          target address and stores the return address in the destination register.
//#################################################################################################
typedef struct packed {
  // Immediate value bit (1 bit)
  logic imm4;
  // Immediate value (10 bits)
  logic [9:0] imm3;
  // Immediate value bit (1 bit)
  logic imm2;
  // Immediate value (8 bits)
  logic [7:0] imm1;
  // Destination register (5 bits)
  logic [4:0] rd;
  // Opcode (7 bits)
  inst_type_e opcode;
} j_type_t;

//#################################################################################################
// Struct: r_type_t
// Description: Represents an R-type (register-type) RISC-V instruction format. This structure
//              encodes the components of an R-type instruction.
//
// Fields:
//  - funct7 : Function field to define the operation, 7 bits.
//  - rs2    : Source register 2, 5 bits.
//  - rs1    : Source register 1, 5 bits.
//  - funct3 : Function field to specify the operation subtype, 3 bits.
//  - rd     : Destination register, 5 bits.
//  - opcode : Opcode field from the `inst_type_e` enum, 7 bits.
//
// Example: A typical R-type instruction might be ADD, which adds the values of rs1 and rs2 and
//          stores the result in rd.
//#################################################################################################
typedef struct packed {
  // Function field (7 bits)
  logic [6:0] funct7;
  // Source register 2 (5 bits)
  logic [4:0] rs2;
  // Source register 1 (5 bits)
  logic [4:0] rs1;
  // Function field (3 bits)
  logic [2:0] funct3;
  // Destination register (5 bits)
  logic [4:0] rd;
  // Opcode (7 bits)
  inst_type_e opcode;
} r_type_t;

//#################################################################################################
// Struct: s_type_t
// Description: Represents an S-type (store-type) RISC-V instruction format. This structure encodes
//              the components of an S-type instruction.
//
// Fields:
//  - imm2   : Function field to define the operation, 7 bits.
//  - rs2    : Source register 2, 5 bits.
//  - rs1    : Source register 1, 5 bits.
//  - funct3 : Function field to specify the operation subtype, 3 bits.
//  - imm1   : Immediate value, 5 bits, typically used for store offsets.
//  - opcode : Opcode field from the `inst_type_e` enum, 7 bits.
//
// Example: A typical S-type instruction might be SW (Store Word), which stores the value from
//          register rs2 into memory at the address computed from rs1 plus the immediate value.
//#################################################################################################
typedef struct packed {
  // Function field (7 bits)
  logic [6:0] imm2;
  // Source register 2 (5 bits)
  logic [4:0] rs2;
  // Source register 1 (5 bits)
  logic [4:0] rs1;
  // Function field (3 bits)
  logic [2:0] funct3;
  // Immediate (5 bits)
  logic [4:0] imm1;
  // Opcode (7 bits)
  inst_type_e opcode;
} s_type_t;

//#################################################################################################
// Struct: u_type_t
// Description: Represents a U-type (upper immediate) RISC-V instruction format. This structure
//              encodes the components of a U-type instruction.
//
// Fields:
//  - imm    : Immediate value, 20 bits, which is typically used to load upper immediate values
//             into registers.
//  - rd     : Destination register, 5 bits, where the result of the instruction is stored.
//  - opcode : Opcode field from the `inst_type_e` enum, 7 bits, which specifies the operation
//             type.
//
// Example: A typical U-type instruction might be LUI (Load Upper Immediate), which loads a 20-bit
//          immediate value into the upper 20 bits of the destination register while setting the
//          lower 12 bits to zero.
//#################################################################################################
typedef struct packed {
  // Immediate value (20 bits)
  logic [19:0] imm;
  // Destination register (5 bits)
  logic [4:0] rd;
  // Opcode (7 bits)
  inst_type_e opcode;
} u_type_t;

//#################################################################################################
// Union: instruction_t
// Description: A union that represents a RISC-V instruction. It can either  hold the opcode field
//              directly, or represent an I-type instruction.
//
// Fields:
//  - opcode: A structure that contains the opcode (7 bits) and filler bits.
//  - i_type: A structure representing an I-type instruction (12-bit immediate, rs1, funct3, rd,
//            and opcode).
//
// Example: This union can be used to interpret the 32-bit instruction word as either just an
//          opcode or as a more complex I-type instruction.
//#################################################################################################
typedef union packed {
  struct packed {
    // Filler bits to occupy space up to bit 31 (25 bits)
    logic [24:0] fillin;
    // Opcode field (7 bits)
    inst_type_e opcode;
  } opcode;
  // B-type instruction
  b_type_t b_type;
  // I-type instruction
  i_type_t i_type;
  // J-type instruction
  j_type_t j_type;
  // R-type instruction
  r_type_t r_type;
  // S-type instruction
  s_type_t s_type;
  // U-type instruction
  u_type_t u_type;
} instruction_t;

endpackage : instructions_pkg

`endif // INSTRUCTIONS_PKG_SVH
