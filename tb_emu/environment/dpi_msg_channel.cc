#include <iostream>
#include <svdpi.h>
#include <string.h>

using namespace std;

extern "C" void drive(int _IDATA, int _DATAI);
extern "C" void reset();
extern "C" void mon_sigs(int *_IDATA, int *_IADDR, int *_DATAI, int *_DATAO, int *_DADDR, int *_DLEN, int *_DRD, int *_DWR, int *_valid);

extern "C" void c_drive(int _IDATA, int _DATAI) {
  // Set cope
  svSetScope(svGetScopeFromName("darksimv_hdl.cpu_if"));

  drive(_IDATA, _DATAI);
}

extern "C" void c_reset() {
  // Set cope
  svSetScope(svGetScopeFromName("darksimv_hdl.cpu_if"));

  reset();
}

extern "C" void c_mon_sigs(int *_IDATA, int *_IADDR, int *_DATAI, int *_DATAO, int *_DADDR, int *_DLEN, int *_DRD, int *_DWR, int *_valid) {
  // Set cope
  svSetScope(svGetScopeFromName("darksimv_hdl.cpu_if"));

  mon_sigs(_IDATA, _IADDR, _DATAI, _DATAO, _DADDR, _DLEN, _DRD, _DWR, _valid);
}
