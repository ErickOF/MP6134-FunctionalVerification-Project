interface darksimv_hdl_xtor(input CLK);

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

  export "DPI-C" task drive;
  task drive(
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

  export "DPI-C" task reset;
  task reset();
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

  export "DPI-C" task mon_sigs;
  task mon_sigs(
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

endinterface : darksimv_hdl_xtor
