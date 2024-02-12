#include "vp.hpp"
#include <systemc>
#include "tb_vp.hpp"

using namespace sc_core;

int sc_main(int argc, char* argv[])
{
	vp uut("uut");
	tb_vp tb("tb_vp");
  tb.isoc.bind(uut.s_gen);

tlm::tlm_global_quantum::instance().set(sc_time(100, SC_NS));

	sc_start();

  return 0;
}
