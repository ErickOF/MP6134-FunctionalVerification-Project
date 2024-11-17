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

  rand func3_r_type_e funct3_r_type;
  rand func3_i_type_e funct3_i_type;
  rand func3_s_type_e funct3_s_type;

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
    if (opcode == r_type) {
      funct3 == funct3_r_type;
    }
    else if (opcode == i_type) {
      funct3 == funct3_i_type;
    }
    else if (opcode == s_type) {
//      funct3 dist {funct3_s_type := 96, [3'b011:3'b111] := 4};
      funct3 == funct3_s_type;
    }
    solve opcode before funct3;
    solve funct3_r_type before funct3;
    solve funct3_i_type before funct3;
    solve funct3_s_type before funct3;
  }

  constraint c_funct7 {
    if (opcode == r_type) {
//      if ((funct3 == add_sub) || (funct3 == srl_sra)) {
//        funct7[4:0] dist {5'b0_0000 := 96, [5'b0_0001:5'b1_1111] := 4};
//        funct7[6] dist {1'b0 := 96, 1'b1 := 4};
//      }
//      else {
//        funct7 dist {7'b000_0000 := 96, [7'b000_0001:7'b111_1111] := 4};
//      }
      if ((funct3 != add_sub) && (funct3 != srl_sra)) {
        funct7[5] == 1'b0;
      }
      funct7[4:0] == 5'b0_0000;
      funct7[6] == 1'b0;
    }
    solve opcode before funct7;
    solve funct3 before funct7;
  }

  constraint c_imm_valid {
    if (opcode == i_type) {
      if ((funct3_i_type == slli) || (funct3_i_type == srli_srai)) {
        imm[9:5] == 5'b000_0000;
        imm[11] == 1'b0;
        if (funct3_i_type == slli) {
          imm[10] == 1'b0;
        }
      }
    }
    solve opcode before imm;
    solve funct3_i_type before imm;
  }

  constraint c_supported_type_only {
    opcode inside {r_type, i_type, s_type};
  }

  constraint c_avoid_bugs {
    // DUT is not making the IMM to be sign extended before using it as unsigned for comparison
    if ((opcode == i_type) && (funct3_i_type == sltiu)) {
      imm[11] == 1'b0;
    }
    solve opcode before imm;
    solve funct3_i_type before imm;
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
