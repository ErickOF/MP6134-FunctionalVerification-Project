
class i_instr_sltiu_bug_0_test extends darkriscv_instr_base_test;
  i_instr_sltiu_bug_0_seq i_instrs_sltiu_bug_0_seq;

  `uvm_component_utils(i_instr_sltiu_bug_0_test)

  function new(string name="i_instr_sltiu_bug_0_test", uvm_component parent=null);
    super.new(name, parent);

    `uvm_info(get_type_name(), "Running test", UVM_MEDIUM)
  endfunction : new

  virtual task main_phase(uvm_phase phase);
    // Raise an objection to keep the simulation running.
    phase.raise_objection(this, "Starting main_phase!");

    `uvm_info(get_type_name(), $sformatf("Starting with main_phase!"), UVM_NONE)

    i_instrs_sltiu_bug_0_seq = i_instr_sltiu_bug_0_seq::type_id::create("i_instrs_sltiu_bug_0_seq");

    main_sequence = i_instrs_sltiu_bug_0_seq;

    `uvm_info(get_type_name(), $sformatf("Finishing with main_phase!"), UVM_NONE)

    // Drop the objection to end the test.
    phase.drop_objection(this, "Finishing main_phase!");

    super.main_phase(phase);
  endtask : main_phase

endclass : i_instr_sltiu_bug_0_test
