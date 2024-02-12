#ifndef _GENERATOR_HPP_
#define _GENERATOR_HPP_

#include <systemc>
#include <tlm>
#include <tlm_utils/simple_initiator_socket.h>

class generator:
	public sc_core::sc_module
{
public:
	generator(sc_core::sc_module_name);

	tlm_utils::simple_initiator_socket<generator> isoc;
	tlm_utils::simple_initiator_socket<generator> gen_isoc;
	
	

protected:
	void gen();

	typedef tlm::tlm_base_protocol_types::tlm_payload_type pl_t;
  void b_transport(pl_t&, sc_core::sc_time&);
  void msg(const pl_t&);
};


#endif
