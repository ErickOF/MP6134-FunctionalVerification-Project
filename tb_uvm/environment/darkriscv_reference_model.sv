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

  logic [31:0] pc[4];

  bit previous_inst_s_type;

  bit previous_inst_b_j_type;

  darkriscv_output_item next_output_item_queue[$];
  darkriscv_output_item next_load_queue[$];

  int flushing_pipeline;

  `uvm_component_utils(darkriscv_reference_model)

  function new(string name = "darkriscv_reference_model", uvm_component parent = null);
    super.new(name, parent);

    mb_mn_instr = new();

    foreach (register_bank[i]) begin
      register_bank[i] = 32'hXXXX_XXXX;
    end

    next_instruction_address = 32'hXXXX_XXXX;
    foreach (pc[i]) begin
      pc[i] = 32'hXXXX_XXXX;
    end

    previous_inst_s_type = 1'b0;

    previous_inst_b_j_type = 1'b0;

    flushing_pipeline = 0;
  endfunction : new

  function void reset();
    register_bank[0] = 32'h0;

    next_instruction_address = 32'h0;
    pc[3] = 32'h0;
    pc[2] = 32'h0;
    pc[1] = 32'h4;
    pc[0] = 32'h8;

    previous_inst_s_type = 1'b0;

    previous_inst_b_j_type = 1'b0;

    next_output_item_queue.delete();
    next_load_queue.delete();

    flushing_pipeline = 0;
  endfunction : reset

  function void build_phase(uvm_phase phase);
    input_data_ap = new("input_data_ap", this);
    output_data_ap = new("output_data_ap", this);

    output_item = darkriscv_output_item::type_id::create("output_item");
  endfunction : build_phase

  task main_phase(uvm_phase phase);
    super.main_phase(phase);
    fork
      wait_for_instructions();
    join_none
  endtask : main_phase

  task post_main_phse(uvm_phase phase);
    super.post_main_phase(phase);
    while (next_output_item_queue.size() > 0) begin
      send_output_item();
    end
  endtask : post_main_phse

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
    logic [31:0] my_data;

    forever begin
      mb_mn_instr.get(my_input_data);
      my_instr = my_input_data.instruction_data;
      my_data = my_input_data.input_data;

      proccess_instructions(.my_instr(my_instr), .my_data(my_data));
    end
  endtask : wait_for_instructions

  function void proccess_instructions(logic [31:0] my_instr, logic[31:0] my_data);
    inst_type_e opcode;

    `uvm_info(get_type_name(), $sformatf("Decoding instruction %0h", my_instr), UVM_LOW)

    opcode = inst_type_e'(my_instr[RISCV_INST_OPCODE_RANGE_HIGH+1:RISCV_INST_OPCODE_RANGE_LOW]);

    check_for_prev_load(.my_data(my_data));

    send_output_item();

    if (flushing_pipeline > 0) begin
      `uvm_info(get_type_name(), $sformatf("The pipeline is being flushed after B/J instructions!"), UVM_LOW)
    end
    else begin
      case (opcode)
        r_type : begin
          `uvm_info(get_type_name(), $sformatf("R instruction detected"), UVM_MEDIUM)
          decode_r_type_opcode(.my_instr(my_instr));
        end
        i_type : begin
          `uvm_info(get_type_name(), $sformatf("I instruction detected"), UVM_MEDIUM)
          decode_i_type_opcode(.my_instr(my_instr));
        end
        l_type : begin
          `uvm_info(get_type_name(), $sformatf("L instruction detected"), UVM_MEDIUM)
          decode_l_type_opcode(.my_instr(my_instr));
        end
        s_type : begin
          `uvm_info(get_type_name(), $sformatf("S instruction detected"), UVM_MEDIUM)
          decode_s_type_opcode(.my_instr(my_instr));
        end
        b_type : begin
          `uvm_info(get_type_name(), $sformatf("B instruction detected"), UVM_MEDIUM)
          decode_b_type_opcode(.my_instr(my_instr));
        end
        u_lui_type, u_auipc_type : begin
          `uvm_info(get_type_name(), $sformatf("U instruction detected"), UVM_MEDIUM)
          decode_u_type_opcode(.my_instr(my_instr));
        end
        custom_0_type : begin
          `uvm_info(get_type_name(), $sformatf("Custom0 instruction detected, this is an idle instrucction so no action needed!"), UVM_MEDIUM)
        end
        default : begin
          `uvm_error(get_type_name(), $sformatf("Instruction type %s = %0h is not supported right now in the reference model\n", opcode.name(), opcode))
        end
      endcase
    end

    if (((opcode != j_type) && (opcode != b_type)) || ((flushing_pipeline > 0) && (flushing_pipeline < 3))) begin
      update_pc();
      pc[0] += 32'h4;
    end
  endfunction : proccess_instructions

  function void update_pc();
    `uvm_info(get_type_name(), $sformatf("PC[3] = %0h PC[2] = %0h PC[1] = %0h PC[0] = %0h", pc[3], pc[2], pc[1], pc[0]), UVM_MEDIUM)

    pc[3] = pc[2];
    pc[2] = pc[1];
    pc[1] = pc[0];
    next_instruction_address = pc[2];
  endfunction : update_pc

  function void decode_r_type_opcode(logic [31:0] my_instr);
    func3_r_type_e funct3;
    bit [4:0] dest_reg;
    bit [4:0] source_reg_1;
    bit [4:0] source_reg_2;
    bit [6:0] funct7;

    bit signed [31:0] result;

    funct3 = func3_r_type_e'(my_instr[RISCV_INST_FUNC3_RANGE_HIGH:RISCV_INST_FUNC3_RANGE_LOW]);
    dest_reg = my_instr[RISCV_INST_RD_RANGE_HIGH:RISCV_INST_RD_RANGE_LOW];
    source_reg_1 = my_instr[RISCV_INST_RS1_RANGE_HIGH:RISCV_INST_RS1_RANGE_LOW];
    source_reg_2 = my_instr[RISCV_INST_RS2_RANGE_HIGH:RISCV_INST_RS2_RANGE_LOW];
    funct7 = my_instr[RISCV_INST_FUNC7_RANGE_HIGH:RISCV_INST_FUNC7_RANGE_LOW];

    if (dest_reg != 'h0) begin
      case (funct3)
        add_sub : begin
          if (funct7 == 7'b000_0000) begin // RISCV spec shows funct7[4:0] = 0 and funct7[6] = 0
            result = register_bank[source_reg_1] + register_bank[source_reg_2];
            `uvm_info(get_type_name(), $sformatf("Saving result 0x%0h from adding R%0d = %0d and R%0d = %0d to R%0d = %0d\n", result, source_reg_1, register_bank[source_reg_1], source_reg_2, register_bank[source_reg_2], dest_reg, register_bank[dest_reg]), UVM_MEDIUM)
            register_bank[dest_reg] = result;
          end
          else if (funct7 == 7'b010_0000) begin // RISCV spec shows funct7[4:0] = 0 and funct7[6] = 0
            result = register_bank[source_reg_1] - register_bank[source_reg_2];
            `uvm_info(get_type_name(), $sformatf("Saving result 0x%0h from subtracting R%0d = %0d and R%0d = %0d to R%0d = %0d\n", result, source_reg_1, register_bank[source_reg_1], source_reg_2, register_bank[source_reg_2], dest_reg, register_bank[dest_reg]), UVM_MEDIUM)
            register_bank[dest_reg] = result;
          end
          else begin
            `uvm_info(get_type_name(), $sformatf("Seven bits of FUNCT7 are not recognized 0x%0h!\n", funct7), UVM_MEDIUM)
          end
        end
        sll : begin
          result = unsigned'(register_bank[source_reg_1]) << register_bank[source_reg_2][4:0];
          `uvm_info(get_type_name(), $sformatf("Saving result 0x%0h from logic shifting to the left R%0d = 0x%0h N_bits = %0d to R%0d = 0x%0h\n", result, source_reg_1, register_bank[source_reg_1], register_bank[source_reg_2][4:0], dest_reg, register_bank[dest_reg]), UVM_MEDIUM)
          register_bank[dest_reg] = result;
        end
        slt : begin
          if (register_bank[source_reg_1] < register_bank[source_reg_2]) begin
            `uvm_info(get_type_name(), $sformatf("Saving value 0x1 to R%0d = %0d since R%0d = %0d is smaller than R%0d = %0d\n", dest_reg, register_bank[dest_reg], source_reg_1, register_bank[source_reg_1], source_reg_2, register_bank[source_reg_2]), UVM_MEDIUM)
            register_bank[dest_reg] = 1;
          end
          else begin
            `uvm_info(get_type_name(), $sformatf("Saving value of 0 to R%0d = %0d since R%0d = %0d is greater or equal than R%0d = %0d\n", dest_reg, register_bank[dest_reg], source_reg_1, register_bank[source_reg_1], source_reg_2, register_bank[source_reg_2]), UVM_MEDIUM)
            register_bank[dest_reg] = 0;
          end
        end
        sltu : begin
          if (unsigned'(register_bank[source_reg_1]) < unsigned'(register_bank[source_reg_2])) begin
            `uvm_info(get_type_name(), $sformatf("Saving value of 0x1 to R%0d = %0d since R%0d = %0d is smaller than R%0d = %0d\n", dest_reg, unsigned'(register_bank[dest_reg]), source_reg_1, unsigned'(register_bank[source_reg_1]), source_reg_2, unsigned'(register_bank[source_reg_2])), UVM_MEDIUM)
            register_bank[dest_reg] = 1;
          end
          else begin
            `uvm_info(get_type_name(), $sformatf("Saving value of 0 to R%0d = %0d since R%0d = %0d is greater or equal than R%0d = %0d\n", dest_reg, unsigned'(register_bank[dest_reg]), source_reg_1, unsigned'(register_bank[source_reg_1]), source_reg_2, unsigned'(register_bank[source_reg_2])), UVM_MEDIUM)
            register_bank[dest_reg] = 0;
          end
        end
        xor_ : begin
          result = register_bank[source_reg_1] ^ register_bank[source_reg_2];
          `uvm_info(get_type_name(), $sformatf("Saving result 0x%0h from performing XOR bitwise between R%0d = 0x%0h and R%0d = 0x%0h to R%0d = 0x%0h\n", result, source_reg_1, register_bank[source_reg_1], source_reg_2, register_bank[source_reg_2], dest_reg, register_bank[dest_reg]), UVM_MEDIUM)
          register_bank[dest_reg] = result;
        end
        srl_sra : begin
          if (funct7 == 7'b000_0000) begin // RISCV spec shows funct7[4:0] = 0 and funct7[6] = 0
            result = unsigned'(register_bank[source_reg_1]) >> register_bank[source_reg_2][4:0];
            `uvm_info(get_type_name(), $sformatf("Saving result 0x%0h from logic shifting to the right R%0d = 0x%0h N_bits = %0d to R%0d = 0x%0h\n", result, source_reg_1, register_bank[source_reg_1], register_bank[source_reg_2][4:0], dest_reg, register_bank[dest_reg]), UVM_MEDIUM)
            register_bank[dest_reg] = result;
          end
          else if (funct7 == 7'b010_0000) begin // RISCV spec shows funct7[4:0] = 0 and funct7[6] = 0
            result = unsigned'(register_bank[source_reg_1]) >>> register_bank[source_reg_2][4:0];
            `uvm_info(get_type_name(), $sformatf("Saving result 0x%0h from arithmetic shifting to the right R%0d = 0x%0h N_bits = %0d to R%0d = 0x%0h\n", result, source_reg_1, register_bank[source_reg_1], register_bank[source_reg_2][4:0], dest_reg, register_bank[dest_reg]), UVM_MEDIUM)
            register_bank[dest_reg] = result;
          end
          else begin
            `uvm_info(get_type_name(), $sformatf("Seven bits of FUNCT7 are not recognized 0x%0h!\n", funct7), UVM_MEDIUM)
          end
        end
        or_ : begin
          result = register_bank[source_reg_1] | register_bank[source_reg_2];
          `uvm_info(get_type_name(), $sformatf("Saving result 0x%0h from performing OR bitwise between R%0d = 0x%0h and R%0d = 0x%0h to R%0d = 0x%0h\n", result, source_reg_1, register_bank[source_reg_1], source_reg_2, register_bank[source_reg_2], dest_reg, register_bank[dest_reg]), UVM_MEDIUM)
          register_bank[dest_reg] = result;
        end
        and_ : begin
          result = register_bank[source_reg_1] & register_bank[source_reg_2];
          `uvm_info(get_type_name(), $sformatf("Saving result 0x%0h from performing AND bitwise between R%0d = 0x%0h and R%0d = 0x%0h to R%0d = 0x%0h\n", result, source_reg_1, register_bank[source_reg_1], source_reg_2, register_bank[source_reg_2], dest_reg, register_bank[dest_reg]), UVM_MEDIUM)
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
  endfunction : decode_r_type_opcode

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
          if (imm[11:5] == 7'b000_0000) begin // RISCV spec shows IMM[11:5] = 0
            result = register_bank[source_reg] << shamt;
            `uvm_info(get_type_name(), $sformatf("Saving result 0x%0h from logic shifting to the left R%0d = 0x%0h N_bits = %0d to R%0d = 0x%0h\n", result, source_reg, register_bank[source_reg], shamt, dest_reg, register_bank[dest_reg]), UVM_MEDIUM)
            register_bank[dest_reg] = result;
          end
          else begin
            `uvm_info(get_type_name(), "Upper seven bits of IMM is not recognized 0x%0h!\n", imm[11:5]);
          end
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
          if (imm[11:5] == 7'b000_0000) begin // RISCV spec shows IMM[11:5] = 0
            result = register_bank[source_reg] >> shamt;
            `uvm_info(get_type_name(), $sformatf("Saving result 0x%0h from logic shifting to the right R%0d = 0x%0h N_bits = %0d to R%0d = 0x%0h\n", result, source_reg, register_bank[source_reg], shamt, dest_reg, register_bank[dest_reg]), UVM_MEDIUM)
            register_bank[dest_reg] = result;
          end
          else if (imm[11:5] == 7'b010_0000) begin // RISCV spec shows IMM[11] = 0 and IMM[9:5] = 0
            result = register_bank[source_reg] >>> shamt;
            `uvm_info(get_type_name(), $sformatf("Saving result 0x%0h from arithmetic shifting to the right R%0d = 0x%0h N_bits = %0d to R%0d = 0x%0h\n", result, source_reg, register_bank[source_reg], shamt, dest_reg, register_bank[dest_reg]), UVM_MEDIUM)
            register_bank[dest_reg] = result;
          end
          else begin
            `uvm_info(get_type_name(), "Upper seven bits of IMM is not recognized 0x%0h!\n", imm[11:5]);
          end
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

  function void decode_l_type_opcode(logic [31:0] my_instr);
    darkriscv_output_item output_item_tmp;

    func3_l_type_e funct3;
    bit [4:0] dest_reg;
    bit [4:0] source_reg_1;

    bit [11:0] imm;
    bit signed [31:0] imm_signed = 0;

    bit signed [31:0] result_address = 0;
    int bytes_to_load = 0;

    funct3 = func3_l_type_e'(my_instr[RISCV_INST_FUNC3_RANGE_HIGH:RISCV_INST_FUNC3_RANGE_LOW]);
    dest_reg = my_instr[RISCV_INST_RD_RANGE_HIGH:RISCV_INST_RD_RANGE_LOW];
    source_reg_1 = my_instr[RISCV_INST_RS1_RANGE_HIGH:RISCV_INST_RS1_RANGE_LOW];
    imm[11:0] = my_instr[RISCV_INST_IMM_I_11_0_RANGE_HIGH:RISCV_INST_IMM_I_11_0_RANGE_LOW];
    imm_signed = signed'(imm);

    case (funct3)
      lw : begin
        bytes_to_load = 4;
      end
      lh, lhu : begin
        bytes_to_load = 2;
      end
      lb, lbu : begin
        bytes_to_load = 1;
      end
      default : begin
        bytes_to_load = 0;
        `uvm_info(get_type_name(), $sformatf("Function %0d was not recognized in L-type decoding, loading 0 bytes of data!\n", funct3), UVM_MEDIUM)
      end
    endcase

    `uvm_info("DEBUG", $sformatf("rs1 %08h imm %08h", register_bank[source_reg_1], imm_signed), UVM_LOW)
    result_address = register_bank[source_reg_1] + imm_signed;

    `uvm_info(get_type_name(), $sformatf("Loading %0d bytes of data from memory address 0x%0h to R%0d = 0x%0h", bytes_to_load, result_address, dest_reg, register_bank[dest_reg]), UVM_MEDIUM)

    output_item.instruction_address = 32'hXXXX_XXXX;
    output_item.data_address = result_address;
    output_item.output_data = 32'h0;
    // Use the output data to hold the destination register and the funct3 value
    output_item.output_data[4:0] = dest_reg;
    output_item.output_data[7:5] = funct3;
    output_item.bytes_transfered = bytes_to_load;
    output_item.write_op = 0;
    output_item.read_op = 1;

    if (!$cast(output_item_tmp, output_item.clone())) begin
      `uvm_fatal(get_type_name(), "Couldn't cast output_item!")
    end

    next_output_item_queue.push_back(output_item_tmp);
    next_load_queue.push_back(output_item_tmp);
  endfunction : decode_l_type_opcode

  function void decode_s_type_opcode(logic [31:0] my_instr);
    darkriscv_output_item output_item_tmp;

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
    `uvm_info("DEBUG", $sformatf("rs1 %08h imm %08h", register_bank[source_reg_1], imm_signed), UVM_LOW)
    result_address = register_bank[source_reg_1] + imm_signed;

    `uvm_info(get_type_name(), $sformatf("Storing %0d bytes of data R%0d = 0x%0h to memory address 0x%0h\n", bytes_to_transfer, source_reg_2, result_data, result_address), UVM_MEDIUM)

    output_item.instruction_address = 32'hXXXX_XXXX;
    output_item.data_address = result_address;
    output_item.output_data = result_data;
    output_item.bytes_transfered = bytes_to_transfer;
    output_item.write_op = 1;
    output_item.read_op = 0;

    if (!$cast(output_item_tmp, output_item.clone())) begin
      `uvm_fatal(get_type_name(), "Couldn't cast output_item!")
    end

    next_output_item_queue.push_back(output_item_tmp);
  endfunction : decode_s_type_opcode

  function void decode_b_type_opcode(logic [31:0] my_instr);
    func3_b_type_e funct3;
    bit [4:0] source_reg_1;
    bit [4:0] source_reg_2;

    bit [12:0] imm;
    bit signed [31:0] imm_signed = 0;

    bit signed [31:0] result_offset = 0;

    bit [31:0] result_address;

    bit taking_branch;

    funct3 = func3_b_type_e'(my_instr[RISCV_INST_FUNC3_RANGE_HIGH:RISCV_INST_FUNC3_RANGE_LOW]);
    source_reg_1 = my_instr[RISCV_INST_RS1_RANGE_HIGH:RISCV_INST_RS1_RANGE_LOW];
    source_reg_2 = my_instr[RISCV_INST_RS2_RANGE_HIGH:RISCV_INST_RS2_RANGE_LOW];
    imm[12] = my_instr[RISCV_INST_IMM_R_12];
    imm[11] = my_instr[RISCV_INST_IMM_R_11];
    imm[10:5] = my_instr[RISCV_INST_IMM_R_10_5_RANGE_HIGH:RISCV_INST_IMM_R_10_5_RANGE_LOW];
    imm[4:1] = my_instr[RISCV_INST_IMM_R_4_1_RANGE_HIGH:RISCV_INST_IMM_R_4_1_RANGE_LOW];
    imm[0] = 1'b0;
    imm_signed = signed'(imm);

    case (funct3)
      beq : begin
        if (register_bank[source_reg_1] == register_bank[source_reg_2]) begin
          result_offset = imm_signed;
          taking_branch = 1'b1;
          `uvm_info(get_type_name(), $sformatf("Taking branch with offset %0d since R%0d = %0h and R%0d = %0h were equal", imm_signed, source_reg_1, register_bank[source_reg_1], source_reg_2, register_bank[source_reg_2]), UVM_MEDIUM)
        end
        else begin
          result_offset = 32'h4;
          taking_branch = 1'b0;
          `uvm_info(get_type_name(), $sformatf("Not taking branch with offset %0d since R%0d = %0h and R%0d = %0h were not equal", imm_signed, source_reg_1, register_bank[source_reg_1], source_reg_2, register_bank[source_reg_2]), UVM_MEDIUM)
        end
      end
      bne : begin
        if (register_bank[source_reg_1] != register_bank[source_reg_2]) begin
          result_offset = imm_signed;
          taking_branch = 1'b1;
          `uvm_info(get_type_name(), $sformatf("Taking branch with offset %0d since R%0d = %0h and R%0d = %0h were not equal", imm_signed, source_reg_1, register_bank[source_reg_1], source_reg_2, register_bank[source_reg_2]), UVM_MEDIUM)
        end
        else begin
          result_offset = 32'h4;
          taking_branch = 1'b0;
          `uvm_info(get_type_name(), $sformatf("Not taking branch with offset %0d since R%0d = %0h and R%0d = %0h were equal", imm_signed, source_reg_1, register_bank[source_reg_1], source_reg_2, register_bank[source_reg_2]), UVM_MEDIUM)
        end
      end
      blt : begin
        if (register_bank[source_reg_1] < register_bank[source_reg_2]) begin
          result_offset = imm_signed;
          taking_branch = 1'b1;
          `uvm_info(get_type_name(), $sformatf("Taking branch with offset %0d since signed R%0d = %0h was less than signed R%0d = %0h", imm_signed, source_reg_1, register_bank[source_reg_1], source_reg_2, register_bank[source_reg_2]), UVM_MEDIUM)
        end
        else begin
          result_offset = 32'h4;
          taking_branch = 1'b0;
          `uvm_info(get_type_name(), $sformatf("Not taking branch with offset %0d since signed R%0d = %0h was greater or equal than signed R%0d = %0h", imm_signed, source_reg_1, register_bank[source_reg_1], source_reg_2, register_bank[source_reg_2]), UVM_MEDIUM)
        end
      end
      bge : begin
        if (register_bank[source_reg_1] >= register_bank[source_reg_2]) begin
          result_offset = imm_signed;
          taking_branch = 1'b1;
          `uvm_info(get_type_name(), $sformatf("Taking branch with offset %0d since signed R%0d = %0h was greater or equal than signed R%0d = %0h", imm_signed, source_reg_1, register_bank[source_reg_1], source_reg_2, register_bank[source_reg_2]), UVM_MEDIUM)
        end
        else begin
          result_offset = 32'h4;
          taking_branch = 1'b0;
          `uvm_info(get_type_name(), $sformatf("Not taking branch with offset %0d since signed R%0d = %0h was less than signed R%0d = %0h", imm_signed, source_reg_1, register_bank[source_reg_1], source_reg_2, register_bank[source_reg_2]), UVM_MEDIUM)
        end
      end
      bltu : begin
        if (unsigned'(register_bank[source_reg_1]) < unsigned'(register_bank[source_reg_2])) begin
          result_offset = imm_signed;
          taking_branch = 1'b1;
          `uvm_info(get_type_name(), $sformatf("Taking branch with offset %0d since unsigned R%0d = %0h was less than unsigned R%0d = %0h", imm_signed, source_reg_1, unsigned'(register_bank[source_reg_1]), source_reg_2, unsigned'(register_bank[source_reg_2])), UVM_MEDIUM)
        end
        else begin
          result_offset = 32'h4;
          taking_branch = 1'b0;
          `uvm_info(get_type_name(), $sformatf("Not taking branch with offset %0d since unsigned R%0d = %0h was greater or equal than unsigned R%0d = %0h", imm_signed, source_reg_1, unsigned'(register_bank[source_reg_1]), source_reg_2, unsigned'(register_bank[source_reg_2])), UVM_MEDIUM)
        end
      end
      bgeu : begin
        if (unsigned'(register_bank[source_reg_1]) >= unsigned'(register_bank[source_reg_2])) begin
          result_offset = imm_signed;
          taking_branch = 1'b1;
          `uvm_info(get_type_name(), $sformatf("Taking branch with offset %0d since unsigned R%0d = %0h was greater or equal than unsigned R%0d = %0h", imm_signed, source_reg_1, unsigned'(register_bank[source_reg_1]), source_reg_2, unsigned'(register_bank[source_reg_2])), UVM_MEDIUM)
        end
        else begin
          result_offset = 32'h4;
          taking_branch = 1'b0;
          `uvm_info(get_type_name(), $sformatf("Not taking branch with offset %0d since unsigned R%0d = %0h was less than unsigned R%0d = %0h", imm_signed, source_reg_1, unsigned'(register_bank[source_reg_1]), source_reg_2, unsigned'(register_bank[source_reg_2])), UVM_MEDIUM)
        end
      end
      default : begin
        result_offset = 32'h4;
          taking_branch = 1'b0;
        `uvm_info(get_type_name(), $sformatf("Function %0d was not recognized in R-type decoding, using the default offset of 4!", funct3), UVM_MEDIUM)
      end
    endcase

    if (taking_branch == 1'b1) begin
      result_address = unsigned'(signed'(pc[3]) + result_offset);

      `uvm_info(get_type_name(), $sformatf("On result from B-type decoding, advancing instruction address from %0h to %0h", pc[1], result_address), UVM_MEDIUM)

      pc[0] = result_address;

      result_address += 32'h4;

      flushing_pipeline = 3;
    end
    else begin
      result_address = unsigned'(signed'(pc[0]) + result_offset);

      `uvm_info(get_type_name(), $sformatf("On result from B-type decoding, advancing instruction address from %0h to %0h", pc[0], result_address), UVM_MEDIUM)
    end

    update_pc();
    pc[0] = result_address;
  endfunction : decode_b_type_opcode

  function void decode_u_type_opcode(logic [31:0] my_instr);
    inst_type_e opcode;

    bit [4:0] dest_reg;

    bit [31:0] imm;

    bit [31:0] result;

    opcode = inst_type_e'(my_instr[RISCV_INST_OPCODE_RANGE_HIGH+1:RISCV_INST_OPCODE_RANGE_LOW]);

    dest_reg = my_instr[RISCV_INST_RD_RANGE_HIGH:RISCV_INST_RD_RANGE_LOW];
    imm[31:12] = my_instr[RISCV_INST_IMM_U_31_12_RANGE_HIGH:RISCV_INST_IMM_U_31_12_RANGE_LOW];
    imm[11:0] = 12'h0;

    case (opcode)
      u_lui_type : begin
        result = imm;
        `uvm_info(get_type_name(), $sformatf("Saving result 0x%0h from LUI to R%0d = 0x%0h\n", result, dest_reg, register_bank[dest_reg]), UVM_MEDIUM)
        register_bank[dest_reg] = result;
      end
      u_auipc_type : begin
        result = imm + pc[3];
        `uvm_info(get_type_name(), $sformatf("Saving result 0x%0h from adding IMM = 0x%0h and PC = 0x%0h to R%0d = 0x%0h\n", result, imm, pc[3], dest_reg, register_bank[dest_reg]), UVM_MEDIUM)
        register_bank[dest_reg] = result;
      end
      default : begin
        `uvm_fatal(get_type_name(), $sformatf("Illegal opcode %0d was not recognized in U-type decoding!", opcode))
      end
    endcase
  endfunction : decode_u_type_opcode

  function void send_output_item();
    darkriscv_output_item output_item_tmp;

    if (next_output_item_queue.size() > 0) begin
      output_item = next_output_item_queue.pop_front();
    end
    else begin
      output_item.bytes_transfered = 0;
      output_item.write_op = 0;
      output_item.read_op = 0;
    end

    if (flushing_pipeline > 0) begin
      output_item.bytes_transfered = 0;
      output_item.write_op = 0;
      output_item.read_op = 0;
      flushing_pipeline--;
    end

    output_item.instruction_address = next_instruction_address;

    if (!$cast(output_item_tmp, output_item.clone())) begin
      `uvm_fatal(get_type_name(), "Couldn't cast output_item!")
    end

    output_data_ap.write(output_item_tmp);

    `uvm_info(get_type_name(), $sformatf("Sent item to scoreboard!\n%s", output_item_tmp.sprint()), UVM_MEDIUM)
  endfunction : send_output_item

  function void check_for_prev_load(logic [31:0] my_data);
    darkriscv_output_item output_item_tmp;

    if (next_load_queue.size() == 0) begin
      return;
    end
    output_item_tmp = next_load_queue.pop_front();

    if (flushing_pipeline == 0) begin
      func3_l_type_e funct3;
      bit [4:0] dest_reg;

      bit signed [31:0] result_s;

      funct3 = func3_l_type_e'(output_item_tmp.output_data[7:5]);
      dest_reg = output_item_tmp.output_data[4:0];
      
      case (funct3)
        lw : begin
          bit [31:0] result;
          result = my_data[31:0];
          result_s = signed'(result);
          `uvm_info(get_type_name(), $sformatf("Loading 4 bytes of data = 0x%0h from memory address 0x%0h to R%0d = 0x%0h", result_s, output_item_tmp.data_address, dest_reg, register_bank[dest_reg]), UVM_MEDIUM)
          register_bank[dest_reg] = result_s;
        end
        lh, lhu : begin
          bit [15:0] result;
          result = my_data[15:0];
          if (funct3 == lh) begin
            result_s = signed'(result);
            `uvm_info(get_type_name(), $sformatf("Loading 4 bytes of data = 0x%0h after sign-extending 2 bytes of data = 0x%0h from memory address 0x%0h to R%0d = 0x%0h", result_s, result, output_item_tmp.data_address, dest_reg, register_bank[dest_reg]), UVM_MEDIUM)
            register_bank[dest_reg] = result_s;
          end
          else begin
            result_s = unsigned'(result);
            `uvm_info(get_type_name(), $sformatf("Loading 4 bytes of data = 0x%0h after zero-extending 2 bytes of data = 0x%0h from memory address 0x%0h to R%0d = 0x%0h", result_s, result, output_item_tmp.data_address, dest_reg, register_bank[dest_reg]), UVM_MEDIUM)
            register_bank[dest_reg] = result_s;
          end
        end
        lb, lbu : begin
          bit [7:0] result;
          result = my_data[7:0];
          if (funct3 == lb) begin
            result_s = signed'(result);
            `uvm_info(get_type_name(), $sformatf("Loading 4 bytes of data = 0x%0h after sign-extending 1 byte of data = 0x%0h from memory address 0x%0h to R%0d = 0x%0h", result_s, result, output_item_tmp.data_address, dest_reg, register_bank[dest_reg]), UVM_MEDIUM)
            register_bank[dest_reg] = result_s;
          end
          else begin
            result_s = unsigned'(result);
            `uvm_info(get_type_name(), $sformatf("Loading 4 bytes of data = 0x%0h after zero-extending 1 byte of data = 0x%0h from memory address 0x%0h to R%0d = 0x%0h", result_s, result, output_item_tmp.data_address, dest_reg, register_bank[dest_reg]), UVM_MEDIUM)
            register_bank[dest_reg] = result_s;
          end
        end
        default : begin
          `uvm_info(get_type_name(), $sformatf("Function %0d was not recognized in L-type decoding, loading 0 bytes of data!", funct3), UVM_MEDIUM)
        end
      endcase
    end
  endfunction : check_for_prev_load

endclass : darkriscv_reference_model

`endif // _DARKRISCV_REFERENCE_MODEL_SV_
