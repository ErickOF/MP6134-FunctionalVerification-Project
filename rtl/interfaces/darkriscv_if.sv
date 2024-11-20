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

  task automatic drive(
      logic [31:0] _IDATA,
      logic [31:0] _DATAI
    );
    @ (posedge CLK);
    HLT = 0;
    IDATA = _IDATA;
    DATAI = _DATAI;
    @ (posedge CLK);
    HLT = 1;
  endtask : drive

  task automatic reset();
    HLT     = 0;
`ifdef __INTERRUPT__
    IRQ     = 0;
`endif
    IDATA   = 0;
    DATAI   = 0;
`ifdef SIMULATION
    ESIMREQ = 0;
`endif
    RES     = 1;
    repeat (2) @(negedge CLK);
    RES     = 0;
    HLT     = 1;
  endtask : reset

  task automatic mon_sigs(
      output logic [31:0] _IDATA,
      output logic [31:0] _IADDR,
      output logic [31:0] _DATAI,
      output logic [31:0] _DATAO,
      output logic [31:0] _DADDR,
      output logic [2:0]  _DLEN,
      output logic        _DRD,
      output logic        _DWR,
      output bit          _valid
    );
    @ (negedge CLK);
    _IDATA = IDATA;
    _IADDR = IADDR;
    _DATAI = DATAI;
    _DATAO = DATAO;
    _DADDR = DADDR;
    _DLEN  = DLEN;
    _DRD   = DRD;
    _DWR   = DWR;
    _valid = !HLT && !RES;
  endtask : mon_sigs

endinterface : darkriscv_if
