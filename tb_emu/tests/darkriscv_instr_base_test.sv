
class darkriscv_instr_base_test extends darkriscv_base_test;
  init_registers_seq init_regs_seq;
  save_registers_seq save_regs_seq;
  uvm_sequence       main_sequence;

  `uvm_component_utils(darkriscv_instr_base_test)

  function new(string name="darkriscv_instr_base_test", uvm_component parent=null);
    super.new(name, parent);

    `uvm_info(get_type_name(), "Running test", UVM_MEDIUM)
  endfunction : new

  virtual task main_phase(uvm_phase phase);
    super.main_phase(phase);

    // Raise an objection to keep the simulation running.
    phase.raise_objection(this, "Starting main_phase!");

    `uvm_info(get_type_name(), $sformatf("Starting with main_phase!"), UVM_NONE)

    init_regs_seq = init_registers_seq::type_id::create("init_regs_seq");
    if ( ! init_regs_seq.randomize() with {
      num_of_regs == 32;
    }
    ) begin
      `uvm_fatal(get_type_name(), "Randomize failed!")
    end
    init_regs_seq.start(env.driscv_ag.driscv_seqr);

    if (main_sequence != null) begin
      main_sequence.start(env.driscv_ag.driscv_seqr);
    end

    save_regs_seq = save_registers_seq::type_id::create("save_regs_seq");
    if ( ! save_regs_seq.randomize() with {
      num_of_regs == 32;
    }
    ) begin
      `uvm_fatal(get_type_name(), "Randomize failed!")
    end
    save_regs_seq.start(env.driscv_ag.driscv_seqr);

    `uvm_info(get_type_name(), $sformatf("Finishing with main_phase!"), UVM_NONE)

    // Drop the objection to end the test.
    phase.drop_objection(this, "Finishing main_phase!");
  endtask : main_phase

endclass : darkriscv_instr_base_test
