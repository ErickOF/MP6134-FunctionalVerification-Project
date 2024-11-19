
class s_instr_seq extends uvm_sequence;
  `uvm_object_utils(s_instr_seq)

  function new(string name="s_instr_seq");
    super.new(name);
  endfunction : new

  rand int num_of_instr;

  virtual task body();
    darkriscv_item driscv_item = darkriscv_item::type_id::create("driscv_item");
    super.body();
    for (int i = 0; i < num_of_instr; i++) begin
      start_item(driscv_item);
      if ( ! driscv_item.randomize() with {
        opcode == s_type; // S-type instruction
      }
      ) begin
        `uvm_fatal(get_type_name(), "Randomize failed")
      end
      // Get destination register for later verification
      `uvm_info(get_type_name(), $sformatf("Generate new item: %s", driscv_item.sprint()), UVM_LOW)
      // Notify sequencer that the item generation is complete.
      finish_item(driscv_item);
    end
    `uvm_info(get_type_name(), $sformatf("Done generation of %0d items", num_of_instr), UVM_LOW)
  endtask : body

endclass : s_instr_seq
