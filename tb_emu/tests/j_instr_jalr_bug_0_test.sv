
class j_instr_jalr_bug_0_test extends darkriscv_instr_base_test;
  j_instr_jalr_bug_0_seq j_instrs_jalr_bug_0_seq;

  `uvm_component_utils(j_instr_jalr_bug_0_test)

  function new(string name="j_instr_jalr_bug_0_test", uvm_component parent=null);
    super.new(name, parent);

    `uvm_info(get_type_name(), "Running test", UVM_MEDIUM)
  endfunction : new

  virtual task configure_phase(uvm_phase phase);
    super.configure_phase(phase);

    env.ref_model.jalr_bug_0_bypass = 1'b0;
  endtask  :configure_phase

  virtual task main_phase(uvm_phase phase);
    // Raise an objection to keep the simulation running.
    phase.raise_objection(this, "Starting main_phase!");

    `uvm_info(get_type_name(), $sformatf("Starting with main_phase!"), UVM_NONE)

    j_instrs_jalr_bug_0_seq = j_instr_jalr_bug_0_seq::type_id::create("j_instrs_jalr_bug_0_seq");

    main_sequence = j_instrs_jalr_bug_0_seq;

    `uvm_info(get_type_name(), $sformatf("Finishing with main_phase!"), UVM_NONE)

    // Drop the objection to end the test.
    phase.drop_objection(this, "Finishing main_phase!");

    super.main_phase(phase);
  endtask : main_phase

endclass : j_instr_jalr_bug_0_test
