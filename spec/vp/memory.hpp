#ifndef _MEMORY_HPP_
#define _MEMORY_HPP_

#include <systemc>
#include <tlm>
#include <tlm_utils/simple_target_socket.h>

static const int DRAM_SIZE = 2048;

class memory : public sc_core::sc_module
{
public:
	memory(sc_core::sc_module_name);
	tlm_utils::simple_target_socket<memory> tsoc;
	tlm_utils::simple_target_socket<memory> mem_tsoc;

protected:
	unsigned char dram[DRAM_SIZE];

	typedef tlm::tlm_base_protocol_types::tlm_payload_type pl_t;
	void b_transport(pl_t &, sc_core::sc_time &);
};

#endif
