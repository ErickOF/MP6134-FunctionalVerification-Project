//-------------------------------------------------------------------------------------------------
// Class: darkriscv_driver
//
// This class represents the driver in the UVM environment for the darkriscv design.
// The driver's role is to receive sequence items from the sequencer and drive them to the DUT via
// the virtual interface. The driver also reads responses or status from the DUT.
//
// The class extends uvm_driver with darkriscv_item as the sequence item type.
//-------------------------------------------------------------------------------------------------
class darkriscv_driver extends uvm_driver #(darkriscv_item);
  `uvm_component_utils(darkriscv_driver)

  //-----------------------------------------------------------------------------------------------
  // Function: new
  //
  // Constructor for the darkriscv_driver class. It initializes the driver with a given name and
  // optionally links it to a parent UVM component.
  //
  // Parameters:
  // - name: Name of the driver instance (optional, default is "darkriscv_driver").
  // - parent: The parent UVM component (optional, default is null).
  //-----------------------------------------------------------------------------------------------
  function new(string name="darkriscv_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  //-----------------------------------------------------------------------------------------------
  // Virtual Interface: intf
  //
  // This virtual interface is used to communicate with the DUT. It will be assigned during the
  // build phase via uvm_config_db.
  //-----------------------------------------------------------------------------------------------
  virtual darkriscv_if intf;

  //-----------------------------------------------------------------------------------------------
  // Function: build_phase
  //
  // This function is part of the UVM build phase. It retrieves the virtual interface (intf) from
  // the UVM configuration database and links it to this driver.
  //
  // If the virtual interface cannot be found, a fatal error is triggered.
  //
  // Parameters:
  // - phase: Current UVM phase.
  //-----------------------------------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Get the virtual interface from the UVM configuration database.
    if (uvm_config_db #(virtual darkriscv_if)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the DB the virtual interface for the TB")
    end
  endfunction : build_phase

  //-----------------------------------------------------------------------------------------------
  // Function: connect_phase
  //
  // This function is part of the UVM connect phase. It handles any connections that need to be
  // made between components. In this case, it calls the base class function, but no extra
  // connections are required.
  //
  // Parameters:
  // - phase: Current UVM phase.
  //-----------------------------------------------------------------------------------------------
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction : connect_phase

  //-----------------------------------------------------------------------------------------------
  // Task: run_phase
  //
  // This task is part of the UVM run phase. It runs forever, waiting for items from the sequencer,
  // then it calls the drive and read tasks for each item in parallel using fork-join.
  //
  // Parameters:
  // - phase: Current UVM phase.
  //-----------------------------------------------------------------------------------------------
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    reset();

    forever begin
      darkriscv_item driscv_item;

      `uvm_info(get_type_name(), "Wait for item from sequencer", UVM_LOW)

      // Get the next item from the sequencer.
      seq_item_port.get_next_item(driscv_item);

      // Drive the item to the DUT and read the response in parallel.
      fork
        drive(driscv_item);
        read(driscv_item);
      join

      // Indicate to the sequencer that the item has been processed.
      seq_item_port.item_done();
    end
  endtask : run_phase

  //-----------------------------------------------------------------------------------------------
  // Task: drive
  //
  // This task is responsible for driving the sequence item (darkriscv_item) to the DUT.
  // The actual implementation of driving the signals to the interface will be added here.
  //
  // Parameters:
  // - driscv_item: The item to be driven to the DUT.
  //-----------------------------------------------------------------------------------------------
  virtual task drive(darkriscv_item driscv_item);
    // Drive the signals from the item to the DUT via the interface (implementation required).
    `uvm_info(get_type_name(), $sformatf("Driving instruction 0x%0h with data 0x%0h", driscv_item.riscv_inst, driscv_item.riscv_data), UVM_NONE)
    @ (posedge intf.CLK);
    intf.HLT = 0;
    intf.IDATA = driscv_item.riscv_inst;
    intf.DATAI = driscv_item.riscv_data;
    @ (posedge intf.CLK);
    intf.HLT = 1;
  endtask : drive

  virtual task reset();
    `uvm_info(get_type_name(), "Driving signals to initial/known values" , UVM_NONE)
    intf.HLT     = 0;
    intf.IRQ     = 0;
    intf.IDATA   = 0;
    intf.DATAI   = 0;
`ifdef SIMULATION
    intf.ESIMREQ = 0;
`endif
    intf.RES     = 1;
    repeat (2) @(negedge intf.CLK);
    intf.RES     = 0;
    intf.HLT     = 1;
  endtask : reset

  //-----------------------------------------------------------------------------------------------
  // Task: read
  //
  // This task is responsible for reading the status or response from the DUT after driving an item.
  // The actual implementation of reading signals from the interface will be added here.
  //
  // Parameters:
  // - driscv_item: The item related to the read operation.
  //-----------------------------------------------------------------------------------------------
  virtual task read(darkriscv_item driscv_item);
    // Read the status/response from the DUT via the interface (implementation required).
  endtask : read

endclass : darkriscv_driver
