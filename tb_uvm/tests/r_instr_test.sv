
class r_instr_test extends darkriscv_instr_base_test;
  r_instr_seq r_instrs_seq;

  `uvm_component_utils(r_instr_test)

  function new(string name="r_instr_test", uvm_component parent=null);
    super.new(name, parent);

    `uvm_info(get_type_name(), "Running test", UVM_MEDIUM)
  endfunction : new

  virtual task main_phase(uvm_phase phase);
    // Raise an objection to keep the simulation running.
    phase.raise_objection(this, "Starting main_phase!");

    `uvm_info(get_type_name(), $sformatf("Starting with main_phase!"), UVM_NONE)

    r_instrs_seq = r_instr_seq::type_id::create("r_instrs_seq");
    if ( ! r_instrs_seq.randomize() with {
      num_of_instr == 32;
    }
    ) begin
      `uvm_fatal(get_type_name(), "Randomize failed!")
    end

    main_sequence = r_instrs_seq;

    `uvm_info(get_type_name(), $sformatf("Finishing with main_phase!"), UVM_NONE)

    // Drop the objection to end the test.
    phase.drop_objection(this, "Finishing main_phase!");

    super.main_phase(phase);
  endtask : main_phase

endclass : r_instr_test