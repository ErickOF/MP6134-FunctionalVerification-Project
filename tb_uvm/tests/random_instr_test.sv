
class random_instr_test extends uvm_test;
  init_registers_seq init_regs_seq;
  save_registers_seq save_regs_seq;
  random_instr_seq   random_instrs_seq;

  `uvm_component_utils(random_instr_test)

  function new(string name="random_instr_test", uvm_component parent=null);
    super.new(name, parent);

    `uvm_info(get_type_name(), "Running test", UVM_MEDIUM)
  endfunction : new

  // Virtual interface to the DUT
  virtual darkriscv_if intf;

  // Environment that contains the agent and scoreboard
  darkriscv_env env;  

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Retrieve the virtual interface from the UVM configuration DB
    if (uvm_config_db #(virtual darkriscv_if)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the DB the virtual interface for the TB")
    end

    // Create the environment using the UVM factory
    env = darkriscv_env::type_id::create("env", this);

    // Set the virtual interface for the environment
    uvm_config_db #(virtual darkriscv_if)::set(null, "uvm_test_top.*", "VIRTUAL_INTERFACE", intf);
  endfunction : build_phase

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_report_info(get_full_name(), "End_of_elaboration", UVM_LOW);
    print();
  endfunction : end_of_elaboration_phase

  virtual task run_phase(uvm_phase phase);
    // Raise an objection to keep the simulation running.
    phase.raise_objection(this);
    init_regs_seq = init_registers_seq::type_id::create("init_regs_seq");
    if ( ! init_regs_seq.randomize() with {
      num_of_regs == 32;
    }
    ) begin
      `uvm_fatal(get_type_name(), "Randomize failed!")
    end
    init_regs_seq.start(env.driscv_ag.driscv_seqr);

    random_instrs_seq = random_instr_seq::type_id::create("random_instrs_seq");
    if ( ! random_instrs_seq.randomize() with {
      num_of_instr == 32;
    }
    ) begin
      `uvm_fatal(get_type_name(), "Randomize failed!")
    end
    random_instrs_seq.start(env.driscv_ag.driscv_seqr);

    save_regs_seq = save_registers_seq::type_id::create("save_regs_seq");
    if ( ! save_regs_seq.randomize() with {
      num_of_regs == 32;
    }
    ) begin
      `uvm_fatal(get_type_name(), "Randomize failed!")
    end
    save_regs_seq.start(env.driscv_ag.driscv_seqr);

    // Drop the objection to end the test.
    phase.drop_objection(this);
  endtask : run_phase

endclass : random_instr_test
