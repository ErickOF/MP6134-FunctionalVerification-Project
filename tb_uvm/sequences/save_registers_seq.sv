
class save_registers_seq extends uvm_sequence;
  `uvm_object_utils(save_registers_seq)

  function new(string name="save_registers_seq");
    super.new(name);
  endfunction : new

  rand int num_of_regs;

  virtual task body();
    darkriscv_item driscv_item = darkriscv_item::type_id::create("driscv_item");
    super.body();
    for (int i = 0; i < num_of_regs; i++) begin
      // First send the s-type instruction
      start_item(driscv_item);
      if ( ! driscv_item.randomize() with {
        opcode == s_type;    // S-type instruction
		    funct3 == 3'b010;    // encoding for a "word" width store instruction
		    rs1    == 5'b0_0000; // Register with hardcoded zero value. Therefore, memory address = 0 + imm
				rs2    == i;         // Iterate over all the registers
				imm    == 12'h100;   // Arbitrary offset
      }
      ) begin
        `uvm_fatal(get_type_name(), "Randomize failed")
      end
      `uvm_info(get_type_name(), $sformatf("Generate new item: %s", driscv_item.sprint()), UVM_LOW)
      // Notify sequencer that the item generation is complete.
      finish_item(driscv_item);
      // Now send the custom-0 type instruction as "IDLE" between s-type instructions
      start_item(driscv_item);
      driscv_item.c_supported_type_only.constraint_mode(0);
      if ( ! driscv_item.randomize() with {
        opcode == custom_0_type; // Custom-0-type instruction
        funct3 == 3'b000;        // funct3 code for idle
      }
      ) begin
        `uvm_fatal(get_type_name(), "Randomize failed")
      end
      `uvm_info(get_type_name(), $sformatf("Generate new item (IDLE): %s", driscv_item.sprint()), UVM_LOW)
      // Notify sequencer that the item generation is complete.
      finish_item(driscv_item);
    end
    `uvm_info(get_type_name(), $sformatf("Done generation of %0d items", num_of_regs), UVM_LOW)
  endtask : body

endclass : save_registers_seq
