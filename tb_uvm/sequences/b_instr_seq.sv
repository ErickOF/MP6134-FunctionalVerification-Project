
class b_instr_seq extends uvm_sequence;
  `uvm_object_utils(b_instr_seq)

  function new(string name="b_instr_seq");
    super.new(name);
  endfunction : new

  rand int num_of_instr;

  virtual task body();
    darkriscv_item driscv_item = darkriscv_item::type_id::create("driscv_item");
    super.body();
    for (int i = 0; i < num_of_instr; i++) begin
      start_item(driscv_item);
      if ( ! driscv_item.randomize() with {
        opcode == b_type; // B-type instruction
      }
      ) begin
        `uvm_fatal(get_type_name(), "Randomize failed")
      end
      `uvm_info(get_type_name(), $sformatf("Generate new item: %s", driscv_item.sprint()), UVM_LOW)
      // Notify sequencer that the item generation is complete.
      finish_item(driscv_item);

      // Now send the custom-0 type instruction as "IDLE" between b-type instructions
      // this is for flushing the instructions
      for (int j = 0; j < 2; j++) begin
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
    end
    `uvm_info(get_type_name(), $sformatf("Done generation of %0d items", num_of_instr), UVM_LOW)
  endtask : body

endclass : b_instr_seq
