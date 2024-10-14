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

    opcode = inst_type_e'(my_instr[`RISCV_INST_OPCODE_RANGE]);

    case (opcode)
      i_type : begin
        decode_i_type_opcode(.my_instr(my_instr));
      end
      s_type : begin
        decode_s_type_opcode(.my_instr(my_instr));
      end
      default : begin
        $display("Instruction type %s is not supported right now in the reference model\n", opcode.name());
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
    
    bit signed [31:0] result;

    funct3 = func3_i_type_e'(my_instr[`RISCV_INST_FUNC3_RANGE]);
    dest_reg = my_instr[`RISCV_INST_RD_RANGE];
    source_reg = my_instr[`RISCV_INST_RS1_RANGE];
    imm = my_instr[`RISCV_INST_IMM_I_11_0_RANGE];
    imm_signed = signed'(imm);
    imm_unsigned = unsigned'(imm_signed);
    shamt = imm[4:0];

    if (dest_reg != 'h0) begin
      case (funct3)
        addi : begin
          result = register_bank[source_reg] + imm_signed;
          $display("Saving result 0x%0h from adding R%0d = %0d and IMM = %0d to R%0d = %0d\n", result, source_reg, register_bank[source_reg], imm_signed, dest_reg, register_bank[dest_reg]);
          register_bank[dest_reg] = result;
        end
        slli : begin
          // if (imm[11:5] == 7'b000_0000) begin // RISCV spec shows IMM[11:5] = 0, but the design doesn't check for that
            result = register_bank[source_reg] << shamt;
            $display("Saving result 0x%0h from logic shifting to the left R%0d = 0x%0h N_bits = %0d to R%0d = 0x%0h\n", result, source_reg, register_bank[source_reg], shamt, dest_reg, register_bank[dest_reg]);
            register_bank[dest_reg] = result;
          // end
          // else begin
          //   $display("Upper seven bits of IMM is not recognized 0x%0h!\n", imm[11:5]);
          // end
        end
        slti : begin
          if (register_bank[source_reg] < imm_signed) begin
            $display("Saving value 0x1 to R%0d = %0d since R%0d = %0d is smaller than IMM = %0d\n", dest_reg, register_bank[dest_reg], source_reg, register_bank[source_reg], imm_signed);
            register_bank[dest_reg] = 1;
          end
          else begin
            $display("Saving value of 0 to R%0d = %0d since R%0d = %0d is greater or equal than IMM = %0d\n", dest_reg, register_bank[dest_reg], source_reg, register_bank[source_reg], imm_signed);
            register_bank[dest_reg] = 0;
          end
        end
        sltiu : begin
          if (unsigned'(register_bank[source_reg]) < imm_unsigned) begin
            $display("Saving value of 0x1 to R%0d = %0d since R%0d = %0d is smaller than IMM = %0d\n", dest_reg, unsigned'(register_bank[dest_reg]), source_reg, unsigned'(register_bank[source_reg]), imm_unsigned);
            register_bank[dest_reg] = 1;
          end
          else begin
            $display("Saving value of 0 to R%0d = %0d since R%0d = %0d is greater or equal than IMM = %0d\n", dest_reg, unsigned'(register_bank[dest_reg]), source_reg, unsigned'(register_bank[source_reg]), imm_unsigned);
            register_bank[dest_reg] = 0;
          end
        end
        xori : begin
          result = register_bank[source_reg] ^ imm_signed;
          $display("Saving result 0x%0h from performing XOR bitwise between R%0d = 0x%0h and IMM = 0x%0h to R%0d = 0x%0h\n", result, source_reg, register_bank[source_reg], imm_signed, dest_reg, register_bank[dest_reg]);
          register_bank[dest_reg] = result;
        end
        srli_srai : begin
          // if (imm[11:5] == 7'b000_0000) begin // RISCV spec shows IMM[11:5] = 0, but the design doesn't check for that, only for imm[10] == 0
          if (imm[10] == 1'b0) begin
            result = register_bank[source_reg] >> shamt;
            $display("Saving result 0x%0h from logic shifting to the right R%0d = 0x%0h N_bits = %0d to R%0d = 0x%0h\n", result, source_reg, register_bank[source_reg], shamt, dest_reg, register_bank[dest_reg]);
            register_bank[dest_reg] = result;
          end
          // else if (imm[11:5] == 7'b010_0000) begin // RISCV spec shows IMM[11:5] = 0, but the design doesn't check for that, only for imm[10] != 0
          else begin
            result = register_bank[source_reg] >>> shamt;
            $display("Saving result 0x%0h from arithmetic shifting to the right R%0d = 0x%0h N_bits = %0d to R%0d = 0x%0h\n", result, source_reg, register_bank[source_reg], shamt, dest_reg, register_bank[dest_reg]);
            register_bank[dest_reg] = result;
          end
          // else begin
          //   $display("Upper seven bits of IMM is not recognized 0x%0h!\n", imm[11:5]);
          // end
        end
        ori : begin
          result = register_bank[source_reg] | imm_signed;
          $display("Saving result 0x%0h from performing OR bitwise between R%0d = 0x%0h and IMM = 0x%0h to R%0d = 0x%0h\n", result, source_reg, register_bank[source_reg], imm_signed, dest_reg, register_bank[dest_reg]);
          register_bank[dest_reg] = result;
        end
        andi : begin
          result = register_bank[source_reg] & imm_signed;
          $display("Saving result 0x%0h from performing AND bitwise between R%0d = 0x%0h and IMM = 0x%0h to R%0d = 0x%0h\n", result, source_reg, register_bank[source_reg], imm_signed, dest_reg, register_bank[dest_reg]);
          register_bank[dest_reg] = result;
        end
        default : begin
          $display("Function %0d was not recognized!\n", funct3);
        end
      endcase
    end
    else begin
      $display("Destination register 0 is trying to be used, this will result in the same value of 0 being stored, so no operation is done!\n");
    end
  endfunction : decode_i_type_opcode

  function void decode_s_type_opcode(riscv_instruction_d my_instr);
    func3_s_type_e funct3;
    bit [4:0] source_reg_1;
    bit [4:0] source_reg_2;

    bit [11:0] imm;
    bit signed [31:0] imm_signed = 0;

    bit signed [31:0] result_address = 0;
    bit [31:0] result_data = 0;
    int bytes_to_transfer = 0;

    funct3 = func3_s_type_e'(my_instr[`RISCV_INST_FUNC3_RANGE]);
    source_reg_1 = my_instr[`RISCV_INST_RS1_RANGE];
    source_reg_2 = my_instr[`RISCV_INST_RS2_RANGE];
    imm[11:5] = my_instr[`RISCV_INST_IMM_S_11_5_RANGE];
    imm[4:0] = my_instr[`RISCV_INST_IMM_S_4_0_RANGE];
    imm_signed = signed'(imm);

    case (funct3)
      sb : begin
        bytes_to_transfer = 1;
        result_data = {24'h0, register_bank[source_reg_2][7:0]};
      end
      sh : begin
        bytes_to_transfer = 2;
        result_data = {16'h0, register_bank[source_reg_2][15:0]};
      end
      sw : begin
        bytes_to_transfer = 4;
        result_data = register_bank[source_reg_2];
      end
      default : begin
        $display("Function %0d was not recognized!\n", funct3);
      end
    endcase

    if (bytes_to_transfer != 0) begin
      result_address = register_bank[source_reg_1] + imm_signed;

      $display("Storing %0d bytes of data 0x%0h to memory address 0x%0h\n", bytes_to_transfer, result_data, result_data);
    end
  endfunction : decode_s_type_opcode

endclass : riscv_reference_model

`endif // _RISCV_REFERENCE_MODEL_SV_
