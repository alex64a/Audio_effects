#ifndef _TB_VP_H_
#define _TB_VP_H_

#include <tlm_utils/simple_initiator_socket.h>

class tb_vp :
	public sc_core::sc_module
{
public:
	tb_vp(sc_core::sc_module_name);

	tlm_utils::simple_initiator_socket<tb_vp> isoc;

protected:

	void test();

	typedef tlm::tlm_base_protocol_types::tlm_payload_type pl_t;

	void msg(const pl_t&);
};


#endif
