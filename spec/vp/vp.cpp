#include "vp.hpp"
#include "generator.hpp"
#include "interconnect.hpp"
#include "memory.hpp"
#include "dma.hpp"
#include "filter.hpp"

using namespace std;
using namespace sc_core;
using namespace tlm;

vp::vp(sc_module_name name) : sc_module(name), gen(NULL), ic(NULL), mem(NULL), dm(NULL), filter_ip(NULL)
{

	gen = new generator("m_generator");
	ic = new interconnect("m_interconnect");
	mem = new memory("m_memory");
	dm = new dma("m_dma");
	filter_ip = new filter("m_filter");

	gen->isoc.bind(ic->s_gen);
	gen->gen_isoc.bind(mem->tsoc);
	ic->s_filter.bind(filter_ip->filter_tsoc);
	ic->s_dma.bind(dm->dma_tsoc);
	dm->dma_isoc.bind(mem->mem_tsoc);
		dm->wr_port(*filter_ip);
		dm->rd_port(*filter_ip);

	tlm_global_quantum::instance().set(sc_time(10, SC_NS));
}
