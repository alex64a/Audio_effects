#ifndef _VP_HPP_
#define _VP_HPP_

#include <systemc>

class generator;
class interconnect;
class memory;
class dma;
class filter;

SC_MODULE(vp)
{
public:
	vp(sc_core::sc_module_name);

protected:
	generator *gen;
	interconnect *ic;
	memory *mem;
	dma *dm;
	filter *filter_ip;
};
#endif
