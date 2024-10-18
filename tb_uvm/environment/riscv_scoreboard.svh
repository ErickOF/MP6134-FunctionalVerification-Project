`ifndef __RISCV_SCOREBOARD_SVH__
`define __RISCV_SCOREBOARD_SVH__

`uvm_analysis_imp_decl(_exp)
`uvm_analysis_imp_decl(_act)

class riscv_scoreboard #(type T = uvm_object) extends uvm_scoreboard;

  uvm_analysis_imp_exp #(T, riscv_scoreboard) expected_ap;
  uvm_analysis_imp_act #(T, riscv_scoreboard) actual_ap;

  mailbox #(T) expected_mb;
  mailbox #(T) actual_mb;

  int unsigned match_count;
  int unsigned mismatch_count;

  bit objection_raised;

  `uvm_component_utils(riscv_scoreboard)

  function new(string name = "riscv_scoreboard", uvm_component parent = null);
    expected_mb = new();
    actual_mb = new();

    match_count = 0;
    mismatch_count = 0;

    objection_raised = 1'b0;
  endfunction : new

  function void build_phase(uvm_phase phase);
    expected_ap = new("expected_ap", this);
    actual_ap = new("actual_ap", this);
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    T expected_data;
    T actual_data;

    forever begin
      fork
        begin
          fork
            begin
              expected_mb.peek(expected_data);
              handle_objetions(phase);
            end
            begin
              actual_mb.peek(actual_data);
              handle_objetions(phase);
            end
          join_any
          disable fork;
        end
      join

      expected_mb.get(expected_data);
      actual_mb.get(actual_data);

      if (expected_data.compare(actual_data)) begin
        `uvm_info(get_type_name(), $sformatf("Data matched in scoreboard with expected = %s and actual = %s!", expected_data.sprint(), actual_data.sprint()), UVM_MEDIUM);
        match_count++;
      end
      else begin
        `uvm_error(get_type_name(), $sformatf("Data mismatched in scoreboard with expected = %s and actual = %s!", expected_data.sprint(), actual_data.sprint()));
        mismatch_count++;
      end

      handle_objetions(phase);
    end
  endtask : run_phase

  function void write_exp(T expected_item);
    T expected_item_tmp;

    if (!$cast(expected_item_tmp, expected_item.clone())) begin
      `uvm_fatal(get_type_name(), "Failed to cast expected_item!")
    end

    expected_mb.try_put(expected_item_tmp);
  endfunction : write_exp

  function void write_act(T actual_item);
    T actual_item_tmp;

    if (!$cast(actual_item_tmp, actual_item.clone())) begin
      `uvm_fatal(get_type_name(), "Failed to cast actual_item!")
    end

    actual_mb.try_put(actual_item_tmp);
  endfunction : write_act

  function void handle_objetions(uvm_phase phase);
    if ((expected_mb.num() > 0) || (actual_mb.num() > 0)) begin
      if (objection_raised == 1'b0) begin
        phase.raise_objection(this, "Pending transactions to compare")
      end
    end
    else begin
      if (objection_raised == 1'b1) begin
        phase.lower_objection(this, "Pending transactions to compare completed")
      end
    end
  endfunction : handle_objetions

  function void report_phase(uvm_phase phase);
    phase.raise_objection(this, "Reporting results")

    `uvm_info(get_type_name(), $sformatf("Scoreboard finished with %0d matches and %0d mismatches!", match_count, mismatch_count), UVM_NONE);
    `uvm_info(get_type_name(), $sformatf("Scoreboard finished with %0d expected items waiting to be processed!", expected_mb.num()), UVM_NONE);
    `uvm_info(get_type_name(), $sformatf("Scoreboard finished with %0d actual items waiting to be processed!", actual_mb.num()), UVM_NONE);

    phase.lower_objection(this, "Reporting results finished")
  endfunction : report_phase

endclass : riscv_scoreboard

`endif // __RISCV_SCOREBOARD_SVH__