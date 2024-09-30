`include "config.vh"

interface darkriscv_if (input bit CLK);

  logic            HLT;   // halt
  logic            RES;   // reset

`ifdef __INTERRUPT__
  logic            IRQ;   // interrupt request
`endif

  logic     [31:0] IDATA; // instruction data bus
  logic     [31:0] IADDR; // instruction addr bus

  logic     [31:0] DATAI; // data bus (input)
  logic     [31:0] DATAO; // data bus (output)
  logic     [31:0] DADDR; // addr bus

  logic     [ 2:0] DLEN; // data length
  logic            DRW;  // data read/write
  logic            DRD;  // data read
  logic            DWR;  // data write
  logic            DAS;  // address strobe
  
`ifdef SIMULATION
  logic            ESIMREQ;  // end simulation req
  logic            ESIMACK;  // end simulation ack
`endif

  logic [3:0]  DEBUG;       // old-school osciloscope based debug! :)

endinterface : darkriscv_if
