
class i_instr_sltiu_bug_0_seq extends uvm_sequence;
  `uvm_object_utils(i_instr_sltiu_bug_0_seq)

  function new(string name="i_instr_sltiu_bug_0_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    darkriscv_item driscv_item = darkriscv_item::type_id::create("driscv_item");
    logic [4:0] rd_;
    super.body();
    start_item(driscv_item);
    driscv_item.c_avoid_bugs.constraint_mode(0);
    if ( ! driscv_item.randomize() with {
      opcode == i_type; // I-type instruction
      funct3_i_type == sltiu;
      imm[11] == 1'b1; // Should be sign extended first before treating it as unsigned
    }
    ) begin
      `uvm_fatal(get_type_name(), "Randomize failed")
    end
    // Get destination register for later verification
    rd_ = driscv_item.rd;
    `uvm_info(get_type_name(), $sformatf("Generate new item: %s", driscv_item.sprint()), UVM_LOW)
    // Notify sequencer that the item generation is complete.
    finish_item(driscv_item);

    start_item(driscv_item);
    if ( ! driscv_item.randomize() with {
      opcode        == s_type;    // S-type instruction
	    funct3_s_type == sw;        // encoding for a "word" width store instruction
	    rs1           == 5'b0_0000; // Register with hardcoded zero value. Therefore, memory address = 0 + imm
			rs2           == rd_;        // Check previous destination register
			imm           == 12'h100;   // Arbitrary offset
    }
    ) begin
      `uvm_fatal(get_type_name(), "Randomize failed")
    end
    `uvm_info(get_type_name(), $sformatf("Generate new item: %s", driscv_item.sprint()), UVM_LOW)
    // Notify sequencer that the item generation is complete.
    finish_item(driscv_item);
  endtask : body

endclass : i_instr_sltiu_bug_0_seq
