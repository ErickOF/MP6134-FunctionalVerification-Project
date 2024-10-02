`ifndef _RISCV_REFERENCE_MODEL_SV_
`define _RISCV_REFERENCE_MODEL_SV_

class riscv_reference_model;

  mailbox #(riscv_instruction_d) mb_mn_instr;

  bit signed [31:0] register_bank [32];

  function new();
    mb_mn_instr = new();

    foreach (register_bank[i]) begin
      register_bank[i] = 32'h0;
    end
  endfunction : new

  task wait_for_instructions();
    riscv_instruction_d my_instr;

    forever begin
      mb_mn_instr.get(my_instr);

      proccess_instructions(.my_instr(my_instr));
    end
  endtask : wait_for_instructions

  function void proccess_instructions(riscv_instruction_d my_instr);
    inst_type_e opcode;

    opcode = my_instr[`RISCV_INST_OPCODE_RANGE];

    case (opcode)
      i_type : begin
        decode_i_type_opcode(.my_instr(my_instr));
      end
      default : begin
        $display("Instruction type %s is not supported right now in the reference model", opcode.name());
      end
    endcase
  endfunction : proccess_instructions

  function void decode_i_type_opcode(riscv_instruction_d my_instr);
    func3_i_type_e funct3;
    bit [4:0] dest_reg;
    bit [4:0] source_reg;
    bit [4:0] shamt;
    
    bit [11:0] imm;
    bit signed [31:0] imm_signed = 0;
    bit [31:0] imm_unsigned = 0;

    funct3 = my_instr[`RISCV_INST_FUNC3_RANGE];
    dest_reg = my_instr[`RISCV_INST_RD_RANGE];
    source_reg = my_instr[`RISCV_INST_RS1_RANGE];
    imm = my_instr[`RISCV_INST_IMM_I_RANGE];
    imm_signed = signed'(imm);
    imm_unsigned = unsigned'(imm_signed);
    shamt = imm[4:0];

    case (funct3)
      addi : begin
        $display("Saving result from adding R%0d = %0d and IMM = %0d to R%0d = %0d", source_reg, register_bank[source_reg], imm_signed, dest_reg, register_bank[dest_reg]);
        register_bank[dest_reg] = register_bank[source_reg] + imm_signed;
      end
      slli : begin
        if (imm[11:5] == 7'b000_0000) begin
          $display("Saving result from logic shifting to the left R%0d = 0x%0h N_bits = %0d to R%0d = 0x%0h", source_reg, register_bank[source_reg], shamt, dest_reg, register_bank[dest_reg]);
          register_bank[dest_reg] = register_bank[source_reg] << shamt;
        end
        else begin
          $display("Upper seven bits of IMM is not recognized 0x%0h!", imm[11:5]);
        end
      end
      slti : begin
        if (register_bank[source_reg] < imm_signed) begin
          $display("Saving value from R%0d to R%0d = %0d since R%0d = %0d is smaller than IMM = %0d", source_reg, dest_reg, register_bank[dest_reg], source_reg, register_bank[source_reg], imm_signed);
          register_bank[dest_reg] = register_bank[source_reg];
        end
        else begin
          $display("Saving value of 0 to R%0d = %0d since R%0d = %0d is greater or equal than IMM = %0d", dest_reg, register_bank[dest_reg], source_reg, register_bank[source_reg], imm_signed);
          register_bank[dest_reg] = 0;
        end
      end
      sltiu : begin
        if (unsigned'(register_bank[source_reg]) < imm_unsigned) begin
          $display("Saving value from R%0d to R%0d = %0d since R%0d = %0d is smaller than IMM = %0d", source_reg, dest_reg, unsigned'(register_bank[dest_reg]), source_reg, unsigned'(register_bank[source_reg]), imm_unsigned);
          register_bank[dest_reg] = register_bank[source_reg];
        end
        else begin
          $display("Saving value of 0 to R%0d = %0d since R%0d = %0d is greater or equal than IMM = %0d", dest_reg, unsigned'(register_bank[dest_reg]), source_reg, unsigned'(register_bank[source_reg]), imm_unsigned);
          register_bank[dest_reg] = 0;
        end
      end
      xori : begin
        $display("Saving result from performing XOR bitwise between R%0d = 0x%0h and IMM = 0x%0h to R%0d = 0x%0h", source_reg, register_bank[source_reg], imm_signed, dest_reg, register_bank[dest_reg]);
        register_bank[dest_reg] = register_bank[source_reg] ^ imm_signed;
      end
      srli_srai : begin
        if (imm[11:5] == 7'b000_0000) begin
          $display("Saving result from logic shifting to the right R%0d = 0x%0h N_bits = %0d to R%0d = 0x%0h", source_reg, register_bank[source_reg], shamt, dest_reg, register_bank[dest_reg]);
          register_bank[dest_reg] = register_bank[source_reg] >> shamt;
        end
        else if (imm[11:5] == 7'b010_0000) begin
          $display("Saving result from arithmetic shifting to the right R%0d = 0x%0h N_bits = %0d to R%0d = 0x%0h", source_reg, register_bank[source_reg], shamt, dest_reg, register_bank[dest_reg]);
          register_bank[dest_reg] = register_bank[source_reg] >>> shamt;
        end
        else begin
          $display("Upper seven bits of IMM is not recognized 0x%0h!", imm[11:5]);
        end
      end
      ori : begin
        $display("Saving result from performing OR bitwise between R%0d = 0x%0h and IMM = 0x%0h to R%0d = 0x%0h", source_reg, register_bank[source_reg], imm_signed, dest_reg, register_bank[dest_reg]);
        register_bank[dest_reg] = register_bank[source_reg] | imm_signed;
      end
      andi : begin
        $display("Saving result from performing AND bitwise between R%0d = 0x%0h and IMM = 0x%0h to R%0d = 0x%0h", source_reg, register_bank[source_reg], imm_signed, dest_reg, register_bank[dest_reg]);
        register_bank[dest_reg] = register_bank[source_reg] & imm_signed;
      end
      default : begin
        $display("Function was not recognized!");
      end
    endcase

  endfunction : decode_i_type_opcode

endclass : riscv_reference_model

`endif // _RISCV_REFERENCE_MODEL_SV_