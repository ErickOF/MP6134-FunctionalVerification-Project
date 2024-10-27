`ifndef _DARKRISCV_REFERENCE_MODEL_SV_
`define _DARKRISCV_REFERENCE_MODEL_SV_

`uvm_analysis_imp_decl(_in_dat)

class darkriscv_reference_model extends uvm_component;

  uvm_analysis_imp_in_dat #(darkriscv_input_item, darkriscv_reference_model) input_data_ap;
  uvm_analysis_port #(darkriscv_output_item) output_data_ap;

  darkriscv_output_item output_item;

  mailbox #(darkriscv_input_item) mb_mn_instr;

  logic signed [31:0] register_bank [32];

  logic [31:0] next_instruction_address;

  `uvm_component_utils(darkriscv_reference_model)

  function new(string name = "darkriscv_reference_model", uvm_component parent = null);
    super.new(name, parent);

    mb_mn_instr = new();

    foreach (register_bank[i]) begin
      register_bank[i] = 32'hXXXX_XXXX;
    end

    next_instruction_address = 32'hXXXX_XXXX;
  endfunction : new

  function void reset();
    register_bank[0] = 32'h0;

    next_instruction_address = 32'h0;
  endfunction : reset

  function void build_phase(uvm_phase phase);
    input_data_ap = new("input_data_ap", this);
    output_data_ap = new("output_data_ap", this);

    output_item = darkriscv_output_item::type_id::create("output_item");
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    wait_for_instructions();
  endtask : run_phase

  function void write_in_dat(darkriscv_input_item input_item);
    darkriscv_input_item input_item_tmp;

    if (!$cast(input_item_tmp, input_item.clone())) begin
      `uvm_fatal(get_type_name(), $sformatf("Failed to cast darkriscv_input_item!"))
    end

    mb_mn_instr.try_put(input_item);
  endfunction : write_in_dat

  task wait_for_instructions();
    darkriscv_input_item my_input_data;
    logic [31:0] my_instr;

    forever begin
      mb_mn_instr.get(my_input_data);
      my_instr = my_input_data.instruction_data;

      proccess_instructions(.my_instr(my_instr));
    end
  endtask : wait_for_instructions

  function void proccess_instructions(logic [31:0] my_instr);
    inst_type_e opcode;

    `uvm_info(get_type_name(), $sformatf("Decoding instruction %0h", my_instr), UVM_LOW)

    opcode = inst_type_e'(my_instr[RISCV_INST_OPCODE_RANGE_HIGH+1:RISCV_INST_OPCODE_RANGE_LOW]);

    case (opcode)
      i_type : begin
        decode_i_type_opcode(.my_instr(my_instr));
      end
      s_type : begin
        decode_s_type_opcode(.my_instr(my_instr));
      end
      custom_0_type : begin
        `uvm_info(get_type_name(), $sformatf("Custom0 instruction detected, this is an idle instrucction so no action needed!"), UVM_MEDIUM)
      end
      default : begin
        `uvm_error(get_type_name(), $sformatf("Instruction type %s = %0h is not supported right now in the reference model\n", opcode.name(), opcode))
      end
    endcase

    if (opcode != s_type) begin
      send_filler_output_item();
    end

    if ((opcode != j_type) && (opcode != b_type)) begin
      next_instruction_address += 32'h0;
    end
  endfunction : proccess_instructions

  function void decode_i_type_opcode(logic [31:0] my_instr);
    func3_i_type_e funct3;
    bit [4:0] dest_reg;
    bit [4:0] source_reg;
    bit [4:0] shamt;

    bit [11:0] imm;
    bit signed [31:0] imm_signed = 0;
    bit [31:0] imm_unsigned = 0;
    
    bit signed [31:0] result;

    funct3 = func3_i_type_e'(my_instr[RISCV_INST_FUNC3_RANGE_HIGH:RISCV_INST_FUNC3_RANGE_LOW]);
    dest_reg = my_instr[RISCV_INST_RD_RANGE_HIGH:RISCV_INST_RD_RANGE_LOW];
    source_reg = my_instr[RISCV_INST_RS1_RANGE_HIGH:RISCV_INST_RS1_RANGE_LOW];
    imm = my_instr[RISCV_INST_IMM_I_11_0_RANGE_HIGH:RISCV_INST_IMM_I_11_0_RANGE_LOW];
    imm_signed = signed'(imm);
    imm_unsigned = unsigned'(imm_signed);
    shamt = imm[4:0];

    if (dest_reg != 'h0) begin
      case (funct3)
        addi : begin
          result = register_bank[source_reg] + imm_signed;
          `uvm_info(get_type_name(), $sformatf("Saving result 0x%0h from adding R%0d = %0d and IMM = %0d to R%0d = %0d\n", result, source_reg, register_bank[source_reg], imm_signed, dest_reg, register_bank[dest_reg]), UVM_MEDIUM)
          register_bank[dest_reg] = result;
        end
        slli : begin
          // if (imm[11:5] == 7'b000_0000) begin // RISCV spec shows IMM[11:5] = 0, but the design doesn't check for that
            result = register_bank[source_reg] << shamt;
            `uvm_info(get_type_name(), $sformatf("Saving result 0x%0h from logic shifting to the left R%0d = 0x%0h N_bits = %0d to R%0d = 0x%0h\n", result, source_reg, register_bank[source_reg], shamt, dest_reg, register_bank[dest_reg]), UVM_MEDIUM)
            register_bank[dest_reg] = result;
          // end
          // else begin
          //   `uvm_info(get_type_name(), "Upper seven bits of IMM is not recognized 0x%0h!\n", imm[11:5]);
          // end
        end
        slti : begin
          if (register_bank[source_reg] < imm_signed) begin
            `uvm_info(get_type_name(), $sformatf("Saving value 0x1 to R%0d = %0d since R%0d = %0d is smaller than IMM = %0d\n", dest_reg, register_bank[dest_reg], source_reg, register_bank[source_reg], imm_signed), UVM_MEDIUM)
            register_bank[dest_reg] = 1;
          end
          else begin
            `uvm_info(get_type_name(), $sformatf("Saving value of 0 to R%0d = %0d since R%0d = %0d is greater or equal than IMM = %0d\n", dest_reg, register_bank[dest_reg], source_reg, register_bank[source_reg], imm_signed), UVM_MEDIUM)
            register_bank[dest_reg] = 0;
          end
        end
        sltiu : begin
          if (unsigned'(register_bank[source_reg]) < imm_unsigned) begin
            `uvm_info(get_type_name(), $sformatf("Saving value of 0x1 to R%0d = %0d since R%0d = %0d is smaller than IMM = %0d\n", dest_reg, unsigned'(register_bank[dest_reg]), source_reg, unsigned'(register_bank[source_reg]), imm_unsigned), UVM_MEDIUM)
            register_bank[dest_reg] = 1;
          end
          else begin
            `uvm_info(get_type_name(), $sformatf("Saving value of 0 to R%0d = %0d since R%0d = %0d is greater or equal than IMM = %0d\n", dest_reg, unsigned'(register_bank[dest_reg]), source_reg, unsigned'(register_bank[source_reg]), imm_unsigned), UVM_MEDIUM)
            register_bank[dest_reg] = 0;
          end
        end
        xori : begin
          result = register_bank[source_reg] ^ imm_signed;
          `uvm_info(get_type_name(), $sformatf("Saving result 0x%0h from performing XOR bitwise between R%0d = 0x%0h and IMM = 0x%0h to R%0d = 0x%0h\n", result, source_reg, register_bank[source_reg], imm_signed, dest_reg, register_bank[dest_reg]), UVM_MEDIUM)
          register_bank[dest_reg] = result;
        end
        srli_srai : begin
          // if (imm[11:5] == 7'b000_0000) begin // RISCV spec shows IMM[11:5] = 0, but the design doesn't check for that, only for imm[10] == 0
          if (imm[10] == 1'b0) begin
            result = register_bank[source_reg] >> shamt;
            `uvm_info(get_type_name(), $sformatf("Saving result 0x%0h from logic shifting to the right R%0d = 0x%0h N_bits = %0d to R%0d = 0x%0h\n", result, source_reg, register_bank[source_reg], shamt, dest_reg, register_bank[dest_reg]), UVM_MEDIUM)
            register_bank[dest_reg] = result;
          end
          // else if (imm[11:5] == 7'b010_0000) begin // RISCV spec shows IMM[11:5] = 0, but the design doesn't check for that, only for imm[10] != 0
          else begin
            result = register_bank[source_reg] >>> shamt;
            `uvm_info(get_type_name(), $sformatf("Saving result 0x%0h from arithmetic shifting to the right R%0d = 0x%0h N_bits = %0d to R%0d = 0x%0h\n", result, source_reg, register_bank[source_reg], shamt, dest_reg, register_bank[dest_reg]), UVM_MEDIUM)
            register_bank[dest_reg] = result;
          end
          // else begin
          //   `uvm_info(get_type_name(), "Upper seven bits of IMM is not recognized 0x%0h!\n", imm[11:5]);
          // end
        end
        ori : begin
          result = register_bank[source_reg] | imm_signed;
          `uvm_info(get_type_name(), $sformatf("Saving result 0x%0h from performing OR bitwise between R%0d = 0x%0h and IMM = 0x%0h to R%0d = 0x%0h\n", result, source_reg, register_bank[source_reg], imm_signed, dest_reg, register_bank[dest_reg]), UVM_MEDIUM)
          register_bank[dest_reg] = result;
        end
        andi : begin
          result = register_bank[source_reg] & imm_signed;
          `uvm_info(get_type_name(), $sformatf("Saving result 0x%0h from performing AND bitwise between R%0d = 0x%0h and IMM = 0x%0h to R%0d = 0x%0h\n", result, source_reg, register_bank[source_reg], imm_signed, dest_reg, register_bank[dest_reg]), UVM_MEDIUM)
          register_bank[dest_reg] = result;
        end
        default : begin
          `uvm_info(get_type_name(), $sformatf("Function %0d was not recognized in I-type decoding!\n", funct3), UVM_MEDIUM)
        end
      endcase
    end
    else begin
      `uvm_info(get_type_name(), $sformatf("Destination register 0 is trying to be used, this will result in the same value of 0 being stored, so no operation is done!\n"), UVM_MEDIUM)
    end
  endfunction : decode_i_type_opcode

  function void decode_s_type_opcode(logic [31:0] my_instr);
    func3_s_type_e funct3;
    bit [4:0] source_reg_1;
    bit [4:0] source_reg_2;

    bit [11:0] imm;
    bit signed [31:0] imm_signed = 0;

    bit signed [31:0] result_address = 0;
    bit [31:0] result_data = 0;
    int bytes_to_transfer = 0;

    funct3 = func3_s_type_e'(my_instr[RISCV_INST_FUNC3_RANGE_HIGH:RISCV_INST_FUNC3_RANGE_LOW]);
    source_reg_1 = my_instr[RISCV_INST_RS1_RANGE_HIGH:RISCV_INST_RS1_RANGE_LOW];
    source_reg_2 = my_instr[RISCV_INST_RS2_RANGE_HIGH:RISCV_INST_RS2_RANGE_LOW];
    imm[11:5] = my_instr[RISCV_INST_IMM_S_11_5_RANGE_HIGH:RISCV_INST_IMM_S_11_5_RANGE_LOW];
    imm[4:0] = my_instr[RISCV_INST_IMM_S_4_0_RANGE_HIGH:RISCV_INST_IMM_S_4_0_RANGE_LOW];
    imm_signed = signed'(imm);

    case (funct3)
      sb : begin
        bytes_to_transfer = 1;
      end
      sh : begin
        bytes_to_transfer = 2;
      end
      sw : begin
        bytes_to_transfer = 4;
      end
      default : begin
        bytes_to_transfer = 0;
        `uvm_info(get_type_name(), $sformatf("Function %0d was not recognized in S-type decoding, transfering 0 bytes of data!\n", funct3), UVM_MEDIUM)
      end
    endcase

    result_data = register_bank[source_reg_2];
    result_address = register_bank[source_reg_1] + imm_signed;

    `uvm_info(get_type_name(), $sformatf("Storing %0d bytes of data 0x%0h to memory address 0x%0h\n", bytes_to_transfer, result_data, result_address), UVM_MEDIUM)

    output_item.instruction_address = next_instruction_address;
    output_item.data_address = result_address;
    output_item.output_data = result_data;
    output_item.bytes_transfered = bytes_to_transfer;
    output_item.write_op = 1;
    output_item.read_op = 0;
    send_output_item();
  endfunction : decode_s_type_opcode

  function void send_output_item();
    darkriscv_output_item output_item_tmp;

    if (!$cast(output_item_tmp, output_item.clone())) begin
      `uvm_fatal(get_type_name(), "Couldn't cast output_item!")
    end

    output_data_ap.write(output_item_tmp);

    `uvm_info(get_type_name(), "Sent item to scoreboard!", UVM_MEDIUM)
  endfunction : send_output_item

  function void send_filler_output_item();
    output_item.instruction_address = next_instruction_address;
    output_item.bytes_transfered = 0;
    output_item.write_op = 0;
    output_item.read_op = 0;
    send_output_item();
  endfunction : send_filler_output_item

endclass : darkriscv_reference_model

`endif // _DARKRISCV_REFERENCE_MODEL_SV_
