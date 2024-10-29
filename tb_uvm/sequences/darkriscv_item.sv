//-------------------------------------------------------------------------------------------------
// Class: darkriscv_item
//
// This class represents a sequence item for the darkriscv UVM environment.
// A sequence item is used to send data between the sequencer and the driver in the UVM testbench.
// This class inherits from the uvm_sequence_item base class, which provides basic functionality
// for sequence items.
//
// In this class, we define a constructor to initialize the sequence item with a name that defaults
// to "darkriscv_item" if no other name is provided.
//-------------------------------------------------------------------------------------------------
class darkriscv_item extends uvm_sequence_item;
  // Fields for RISC-V core instructions
  rand inst_type_e  opcode;
  rand logic [4:0]  rd;
  rand logic [4:0]  rs1;
  rand logic [4:0]  rs2;
  rand logic [2:0]  funct3;
  rand logic [6:0]  funct7;
  rand logic [31:0] imm;
  // Pointers for handle the complete instruction and the corresponding data (if necessary, for example: store instructions)
  rand logic [31:0] riscv_inst;
  rand logic [31:0] riscv_data;

  `uvm_object_utils_begin(darkriscv_item)
    `uvm_field_int(opcode,     UVM_ALL_ON)
    `uvm_field_int(rd,         UVM_ALL_ON)
    `uvm_field_int(rs1,        UVM_ALL_ON)
    `uvm_field_int(rs2,        UVM_ALL_ON)
    `uvm_field_int(funct3,     UVM_ALL_ON)
    `uvm_field_int(funct7,     UVM_ALL_ON)
    `uvm_field_int(imm,        UVM_ALL_ON)
    `uvm_field_int(riscv_inst, UVM_ALL_ON)
    `uvm_field_int(riscv_data, UVM_ALL_ON)
  `uvm_object_utils_end

  constraint c_valid_inst {
    if (opcode == r_type) {
      riscv_inst == {funct7, rs2, rs1, funct3, rd, opcode};
    }
    else if (opcode == i_type) {
      riscv_inst == {imm[11:0], rs1, funct3, rd, opcode};
    }
    else if (opcode == s_type) {
      riscv_inst == {imm[11:5], rs2, rs1, funct3, imm[4:0], opcode};
    }
    else if (opcode == b_type) {
      riscv_inst == {imm[12], imm[10:5], rs2, rs1, funct3, imm[4:1], imm[11], opcode};
    }
    else if (opcode == u_type) {
      riscv_inst == {imm[31:12], rd, opcode};
    }
    else if (opcode == j_type) {
      riscv_inst == {imm[20], imm[10:1], imm[11], imm[19:12], rd, opcode};
    }
    else if (opcode == custom_0_type) {
      riscv_inst == {imm[24:0], opcode};
    }
    solve opcode before riscv_inst; // We need to first known the instruction type in order to determine valid instructions
  }

  constraint c_imm {
    if (opcode == r_type) {
      imm == 32'd0; // There are no immediate values for R-type registers, so keep those bits low
    }
    else if (opcode inside {i_type, s_type}) {
      imm[31:12] == 'd0; // Bits at positions higher than 11 are not going to be used, so let's force them low in order to randomize values within [11:0] frame
    }
    else if (opcode == b_type) {
      imm[31:13] == 'd0; // Bits at positions higher than 12 are not going to be used, so let's force them low in order to randomize values within [12:0] frame
    }
    else if (opcode == u_type) {
      imm[11:0]  == 'd0; // Bits at positions lower than 11 are not going to be used, so let's force them low in order to randomize values within [31:12] frame
    }
    else if (opcode == j_type) {
      imm[31:21] == 'd0; // Bits at positions higher than 21 are not going to be used
      imm[9:0]   == 'd0; // Bits at positions lower than 9 are not going to be used
    }
    else if (opcode == custom_0_type) {
      imm[31:0] == 'd0; // Custom-0 will use no data
    }
    solve opcode before imm; // We need to first known the instruction type in order to determine valid instructions
  }

  constraint c_funct3 {
    if (opcode == s_type) {
      funct3 dist {3'b000 := 32, 3'b001 := 32, 3'b010 := 32, [3'b011:3'b111] := 4};
    }
  }

  constraint c_supported_type_only {
    opcode inside {i_type, s_type, j_type};
  }

  //-----------------------------------------------------------------------------------------------
  // Function: new
  //
  // Constructor for the darkriscv_item class. This initializes the sequence item with the provided
  // name, or uses the default name "darkriscv_item".
  //
  // Parameters:
  // - name: The name of the sequence item (optional, default is "darkriscv_item").
  //-----------------------------------------------------------------------------------------------
  function new(string name="darkriscv_item");
    super.new(name);
  endfunction

endclass : darkriscv_item
