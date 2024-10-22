//-------------------------------------------------------------------------------------------------
// Class: darkriscv_seq
//
// This class represents a UVM sequence for the darkriscv environment. 
// A UVM sequence is a series of sequence items that will be sent from the sequencer to the driver
// during simulation. In this sequence, random items of type darkriscv_item are generated and sent.
//
// The class inherits from uvm_sequence and uses the UVM utility macro `uvm_object_utils` to
// register this sequence with the UVM factory, allowing it to be created and used dynamically in
// the test environment.
//-------------------------------------------------------------------------------------------------
class darkriscv_seq extends uvm_sequence;
  `uvm_object_utils(darkriscv_seq)

  //-----------------------------------------------------------------------------------------------
  // Function: new
  //
  // Constructor for the darkriscv_seq class. This initializes the sequence with the given name or
  // uses "darkriscv_seq" as the default name.
  //
  // Parameters:
  // - name: The name of the sequence (optional, default is "darkriscv_seq").
  //-----------------------------------------------------------------------------------------------
  function new(string name="darkriscv_seq");
    super.new(name);
  endfunction : new

  //-----------------------------------------------------------------------------------------------
  // rand int num;
  //
  // Random variable representing the total number of items to be generated and sent during the
  // execution of the sequence. The number will be randomized as part of the sequence execution.
  //-----------------------------------------------------------------------------------------------
  rand int num;

  //-----------------------------------------------------------------------------------------------
  // Task: body
  //
  // The main body of the sequence. It generates the specified number of random darkriscv_item
  // sequence items and sends them to the driver. Each item is randomized and printed to the log.
  //
  // This task overrides the body task in the base uvm_sequence class.
  //-----------------------------------------------------------------------------------------------
  virtual task body();
    darkriscv_item driscv_item = darkriscv_item::type_id::create("driscv_item");// Create a darkriscv_item object to generate random items for the sequence.
    super.body();

    

    for (int i = 0; i < num; i++) begin
       // Notify sequencer that an item is ready to start.
      start_item(driscv_item);

      driscv_item.randomize();

      `uvm_info(get_type_name(), "Generate new item: ", UVM_LOW)

      driscv_item.print();

      // Notify sequencer that the item generation is complete.
      finish_item(driscv_item);
    end

    `uvm_info(get_type_name(), $sformatf("Done generation of %0d items", num), UVM_LOW)
  endtask : body

endclass : darkriscv_seq
