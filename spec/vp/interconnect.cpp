#include "interconnect.hpp"
#include "vp_addr.hpp"
#include <string>

using namespace std;
using namespace tlm;
using namespace sc_core;
using namespace sc_dt;

interconnect::interconnect(sc_module_name name) : sc_module(name),
												  s_gen("s_gen")
{
	s_gen.register_b_transport(this, &interconnect::b_transport);
}

void interconnect::b_transport(pl_t &pl, sc_core::sc_time &offset)
{
	uint64 addr = pl.get_address();
	uint64 taddr;
	offset += sc_time(2, SC_NS);

	cout << "Address is: " << hex << addr << endl;

	if (addr >= VP_ADDR_DMA && addr <= VP_ADDR_DMA_H)
	{
		taddr = addr & 0x000000FF;
		pl.set_address(taddr);
		s_dma->b_transport(pl, offset);
	}
	else if (addr >= VP_ADDR_FILTER && addr <= VP_ADDR_FILTER_H)
	{
		taddr = addr & 0x00000FFF;
		pl.set_address(taddr);
		s_filter->b_transport(pl, offset);
	}

	pl.set_address(addr);
	offset += sc_time(100, SC_NS);
}
