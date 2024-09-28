interface darkriscv_if (input bit CLK, input bit RES);

  logic            HLT;   // halt

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

  logic [3:0]  DEBUG       // old-school osciloscope based debug! :)

  modport CPU (
    input CLK,
    input RES,
    input HLT,
`ifdef __INTERRUPT__
    input IRQ,
`endif
    input IDATA,
    output IADDR,
    input DATAI,
    output DATAO,
    output DADDR,
    output DLEN,
    output DRW,
    output DRD,
    output DWR,
    output DAS,
`ifdef SIMULATION
    input ESIMREQ,
    output ESIMACK,
`endif
    output DEBUG
  );

  modport TEST (
    output CLK,
    output RES,
    output HLT,
`ifdef __INTERRUPT__
    output IRQ,
`endif
    output IDATA,
    input IADDR,
    output DATAI,
    input DATAO,
    input DADDR,
    input DLEN,
    input DRW,
    input DRD,
    input DWR,
    input DAS,
`ifdef SIMULATION
    output ESIMREQ,
    input ESIMACK,
`endif
    input DEBUG
  );

endinterface : darkriscv_if
