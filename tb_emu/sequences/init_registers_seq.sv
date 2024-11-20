
class init_registers_seq extends uvm_sequence;
  `uvm_object_utils(init_registers_seq)

  function new(string name="init_registers_seq");
    super.new(name);
  endfunction : new

  rand int num_of_regs;

  virtual task body();
    darkriscv_item driscv_item = darkriscv_item::type_id::create("driscv_item");
    super.body();
    for (int i = 0; i < num_of_regs; i++) begin
      start_item(driscv_item);
      if ( ! driscv_item.randomize() with { // Let's use ADDI instruction for populate each register, by taking advance of immediate values
        opcode == i_type;    // I-type instruction
        funct3 == 3'b000;    // funct3 code for ADDI
        rs1    == 5'b0_0000; // Register with hardcoded zero value. Therefore, rd = 0 + imm -> rd = imm
        rd     == i;         // Number of destiny register, iterating over all 32 registers
      }
      ) begin
        `uvm_fatal(get_type_name(), "Randomize failed")
      end
      `uvm_info(get_type_name(), $sformatf("Generate new item: %s", driscv_item.sprint()), UVM_LOW)
      // Notify sequencer that the item generation is complete.
      finish_item(driscv_item);
    end
    `uvm_info(get_type_name(), $sformatf("Done generation of %0d items", num_of_regs), UVM_LOW)
  endtask : body

endclass : init_registers_seq
