#ifndef _VP_HPP_
#define _VP_HPP_

#include <systemc>
#include <tlm_utils/simple_target_socket.h>
#include <tlm_utils/simple_initiator_socket.h>
#include "interconnect.hpp"
#include "filter.hpp"
#include "timer.hpp"

class timer;
class generator;
class interconnect;
class memory;
class dma;
class filter;

SC_MODULE(vp)
{
public:
  vp(sc_core::sc_module_name);
	tlm_utils::simple_target_socket<vp> s_gen;

protected:

	tlm_utils::simple_initiator_socket<vp> s_interconnect;

  generator* gen;
  memory* mem; 
  dma* dm;
  filter* filter_ip;
  interconnect* ic;
  timer *t;

  typedef tlm::tlm_base_protocol_types::tlm_payload_type pl_t;
  void b_transport(pl_t&, sc_core::sc_time&);

};
#endif
