#include "interconnect.hpp"
#include "vp_addr.hpp"
#include <string>

using namespace std;
using namespace tlm;
using namespace sc_core;
using namespace sc_dt;

interconnect::interconnect(sc_module_name name) :
	sc_module(name),
	s_gen("s_gen")
{
	s_gen.register_b_transport(this, &interconnect::b_transport);
}


void interconnect::b_transport(pl_t& pl, sc_core::sc_time& offset)
{
	uint64 addr = pl.get_address();
	uint64 taddr;
	offset += sc_time(2,SC_NS);
	
	cout << "Address is: " << hex << addr << endl;
	
	if(addr >= VP_ADDR_DMA && addr<= VP_ADDR_DMA_H)
	{
		taddr = addr & 0x000000FF;		
		pl.set_address(taddr);
		s_dma->b_transport(pl, offset);
	}
	else if(addr >= VP_ADDR_FILTER && addr <= VP_ADDR_FILTER_H) 
	{	
		taddr = addr & 0x00000FFF;
		pl.set_address(taddr);
		s_filter->b_transport(pl, offset);
	}
	
	
	
	pl.set_address(addr);
  	offset += sc_time(100, SC_NS);
}


void interconnect::msg(const pl_t& pl)
{
	stringstream ss;
	ss << hex << pl.get_address();
	sc_uint<32> val = *((sc_uint<32>*)pl.get_data_ptr());
	string cmd  = pl.get_command() == TLM_READ_COMMAND ? "read  " : "write ";

	string msg = cmd + "val: " + to_string((int)val) + " adr: " + ss.str();
	msg += " @ " + sc_time_stamp().to_string();

	SC_REPORT_INFO("BUS FWD", msg.c_str());
}

