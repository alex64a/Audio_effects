#include "vp.hpp"
#include "generator.hpp"
#include "interconnect.hpp"
#include "memory.hpp"
#include "dma.hpp"
#include "filter.hpp"
#include "timer.hpp"

using namespace std;
using namespace sc_core;
using namespace tlm;

vp::vp(sc_module_name name) : sc_module(name), gen(NULL), ic(NULL), mem(NULL), dm(NULL), filter_ip(NULL), t(NULL)
{
  gen = new generator("m_generator");
  ic = new interconnect("m_interconnect");
  mem = new memory("m_memory");
  dm = new dma("m_dma");
  filter_ip = new filter("m_filter");
  t = new timer("m_timer");

  t->soc.bind(ic->s_timer);
  gen->isoc.bind(ic->s_gen);
  gen->gen_isoc.bind(mem->tsoc);
  ic->s_filter.bind(filter_ip->filter_tsoc);
  ic->s_dma.bind(dm->dma_tsoc);
//  ic->s_timer.bind(t->soc);
  dm->dma_isoc(mem->mem_tsoc);
  dm->wr_port(*filter_ip);
  dm->rd_port(*filter_ip);

  tlm_global_quantum::instance().set(sc_time(10, SC_NS));
}
