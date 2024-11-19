
class s_instr_test extends darkriscv_instr_base_test;
  s_instr_seq s_instrs_seq;

  `uvm_component_utils(s_instr_test)

  function new(string name="s_instr_test", uvm_component parent=null);
    super.new(name, parent);

    `uvm_info(get_type_name(), "Running test", UVM_MEDIUM)
  endfunction : new

  virtual task main_phase(uvm_phase phase);
    // Raise an objection to keep the simulation running.
    phase.raise_objection(this, "Starting main_phase!");

    `uvm_info(get_type_name(), $sformatf("Starting with main_phase!"), UVM_NONE)

    s_instrs_seq = s_instr_seq::type_id::create("s_instrs_seq");
    if ( ! s_instrs_seq.randomize() with {
      num_of_instr == 32;
    }
    ) begin
      `uvm_fatal(get_type_name(), "Randomize failed!")
    end

    main_sequence = s_instrs_seq;

    `uvm_info(get_type_name(), $sformatf("Finishing with main_phase!"), UVM_NONE)

    // Drop the objection to end the test.
    phase.drop_objection(this, "Finishing main_phase!");

    super.main_phase(phase);
  endtask : main_phase

endclass : s_instr_test
