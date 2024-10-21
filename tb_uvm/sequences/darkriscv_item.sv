//-------------------------------------------------------------------------------------------------
// Class: darkriscv_item
//
// This class represents a sequence item for the darkriscv UVM environment.
// A sequence item is used to send data between the sequencer and the driver in the UVM testbench.
// This class inherits from the uvm_sequence_item base class, which provides basic functionality
// for sequence items.
//
// In this class, we define a constructor to initialize the sequence item with a name that defaults
// to "darkriscv_item" if no other name is provided.
//-------------------------------------------------------------------------------------------------
class darkriscv_item extends uvm_sequence_item;
  `uvm_object_utils_begin(darkriscv_item)
  `uvm_object_utils_end

  //-----------------------------------------------------------------------------------------------
  // Function: new
  //
  // Constructor for the darkriscv_item class. This initializes the sequence item with the provided
  // name, or uses the default name "darkriscv_item".
  //
  // Parameters:
  // - name: The name of the sequence item (optional, default is "darkriscv_item").
  //-----------------------------------------------------------------------------------------------
  function new(string name="darkriscv_item");
    super.new(name);
  endfunction

endclass : darkriscv_item
