//-------------------------------------------------------------------------------------------------
// Class: darkriscv_monitor
//
// This class represents the monitor in the UVM environment for the darkriscv design.
// The monitor's role is to passively observe signals from the DUT via the virtual interface and
// publish the observed transactions to other components like the scoreboard via the analysis port.
//
// The class extends uvm_monitor and contains an analysis port for sending observed transactions.
//-------------------------------------------------------------------------------------------------
class darkriscv_monitor extends uvm_monitor;
  `uvm_component_utils(darkriscv_monitor)

  //-----------------------------------------------------------------------------------------------
  // Virtual Interface: intf
  //
  // This virtual interface is used to passively monitor signals from the DUT. It will be assigned
  // during the build phase using uvm_config_db.
  //-----------------------------------------------------------------------------------------------
  virtual darksimv_hvl_proxy intf;

  //-----------------------------------------------------------------------------------------------
  // Analysis Port: monitored_input_ap
  //
  // This analysis port is used to send observed transactions (darkriscv_input_item) from the input
  // signals to other UVM components, like the scoreboard. It will be used to forward the data
  // observed in the DUT.
  //-----------------------------------------------------------------------------------------------
  uvm_analysis_port #(darkriscv_input_item) monitored_input_ap;

  darkriscv_input_item input_item;

  //-----------------------------------------------------------------------------------------------
  // Analysis Port: monitored_output_ap
  //
  // This analysis port is used to send observed transactions (darkriscv_output_item) from the
  // output signals to other UVM components, like the scoreboard. It will be used to forward the
  // data observed in the DUT.
  //-----------------------------------------------------------------------------------------------
  uvm_analysis_port #(darkriscv_output_item) monitored_output_ap;

  darkriscv_output_item output_item;

  //-----------------------------------------------------------------------------------------------
  // Function: new
  //
  // Constructor for the darkriscv_monitor class. It initializes the monitor with a given name and
  // optionally links it to a parent UVM component.
  //
  // Parameters:
  // - name: Name of the monitor instance (optional, default is "darkriscv_monitor").
  // - parent: The parent UVM component (optional, default is null).
  //-----------------------------------------------------------------------------------------------
  function new(string name="darkriscv_monitor", uvm_component parent=null);
    super.new(name, parent);
  endfunction : new

  //-----------------------------------------------------------------------------------------------
  // Function: build_phase
  //
  // This function is part of the UVM build phase. It initializes the analysis port and retrieves the
  // virtual interface (intf) from the UVM configuration database.
  //
  // If the virtual interface cannot be found, a fatal error is triggered.
  //
  // Parameters:
  // - phase: Current UVM phase.
  //-----------------------------------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create the analysis port for sending observed transactions.
    monitored_input_ap = new("monitored_input_ap", this);
    monitored_output_ap = new("monitored_output_ap", this);

    // Get the virtual interface from the UVM configuration database.
    if(uvm_config_db #(virtual darksimv_hvl_proxy)::get(this, "", "PROXY_VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the DB the virtual interface for the TB")
    end

    input_item = darkriscv_input_item::type_id::create("expected_item");
    output_item = darkriscv_output_item::type_id::create("output_item");
  endfunction : build_phase

  //-----------------------------------------------------------------------------------------------
  // Task: run_phase
  //
  // This task is part of the UVM run phase. Currently, it is empty but will be used to observe
  // signals on the virtual interface and collect transactions. The transactions will then be
  // published to other components via the analysis port.
  //
  // Parameters:
  // - phase: Current UVM phase.
  //-----------------------------------------------------------------------------------------------
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    check_transactions();
  endtask : run_phase

  // Check task: Continuously monitors the read enable signal and checks the data output
  task check_transactions();
    logic [31:0] instruction_data;
    logic [31:0] input_data;

    logic write_op;
    logic read_op;
    logic [31:0] data_address;
    logic [31:0] output_data;
    logic [2:0] bytes_transfered;

    bit valid_transaction;

    forever begin
      intf.c_mon_sigs(
        ._IDATA(instruction_data),
        ._IADDR(output_item.instruction_address),
        ._DATAI(input_data),
        ._DATAO(output_data),
        ._DADDR(data_address),
        ._DLEN(bytes_transfered),
        ._DRD(read_op),
        ._DWR(write_op),
        ._valid(valid_transaction)
      );

      if (valid_transaction) begin
        input_item.instruction_data = instruction_data;
        input_item.input_data = input_data;
        send_input_item();

        `uvm_info(get_type_name(), $sformatf("Instruction IDATA: %h, Input Data: %h", instruction_data, input_data), UVM_MEDIUM)

        output_item.data_address = data_address;
        output_item.output_data = output_data;
        output_item.bytes_transfered = bytes_transfered;
        output_item.write_op = write_op;
        output_item.read_op = read_op;
        send_output_item();

        if (write_op) begin
          `uvm_info(get_type_name(), $sformatf("Write operation of %0d bytes: Data Address: %h, Output Data: %h", bytes_transfered, data_address, output_data), UVM_MEDIUM)
        end
      end
    end
  endtask : check_transactions

  function void send_input_item();
    darkriscv_input_item input_item_tmp;

    if (!$cast(input_item_tmp, input_item.clone())) begin
      `uvm_fatal(get_type_name(), "Couldn't cast input_item!")
    end

    monitored_input_ap.write(input_item_tmp);
  endfunction : send_input_item

  function void send_output_item();
    darkriscv_output_item output_item_tmp;

    if (!$cast(output_item_tmp, output_item.clone())) begin
      `uvm_fatal(get_type_name(), "Couldn't cast output_item!")
    end

    monitored_output_ap.write(output_item_tmp);

    `uvm_info(get_type_name(), "Sent item to scoreboard!", UVM_MEDIUM)
  endfunction : send_output_item

endclass : darkriscv_monitor
