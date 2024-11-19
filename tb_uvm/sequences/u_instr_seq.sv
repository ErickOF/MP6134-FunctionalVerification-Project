
class u_instr_seq extends uvm_sequence;
  `uvm_object_utils(u_instr_seq)

  function new(string name="u_instr_seq");
    super.new(name);
  endfunction : new

  rand int num_of_instr;

  virtual task body();
    darkriscv_item driscv_item = darkriscv_item::type_id::create("driscv_item");
    logic [4:0] rd_;
    super.body();
    for (int i = 0; i < num_of_instr; i++) begin
      start_item(driscv_item);
      if ( ! driscv_item.randomize() with {
        opcode inside {u_lui_type, u_auipc_type}; // U-type instruction
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
      if ( ! (driscv_item.randomize() with {
        opcode        == s_type;    // S-type instruction
		    funct3_s_type == sw;        // encoding for a "word" width store instruction
		    rs1           == 5'b0_0000; // Register with hardcoded zero value. Therefore, memory address = 0 + imm
				rs2           == rd_;        // Check previous destination register
				imm           == 12'h100;   // Arbitrary offset
      })
      ) begin
        `uvm_fatal(get_type_name(), "Randomize failed")
      end
      `uvm_info(get_type_name(), $sformatf("Generate new item: %s", driscv_item.sprint()), UVM_LOW)
      // Notify sequencer that the item generation is complete.
      finish_item(driscv_item);
    end
    `uvm_info(get_type_name(), $sformatf("Done generation of %0d items", num_of_instr), UVM_LOW)
  endtask : body

endclass : u_instr_seq
