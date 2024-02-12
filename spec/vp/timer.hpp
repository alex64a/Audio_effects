#ifndef _TIMER_H_
#define _TIMER_H_

#include <tlm>
#include <tlm_utils/simple_target_socket.h>

const sc_dt::uint64 TIMER_CFG = 0;
const sc_dt::uint64 TIMER_CNT = 1;
const sc_dt::uint64 TIMER_RLD = 2;

class timer :
	public sc_core::sc_module
{
public:
	timer(sc_core::sc_module_name);

	tlm_utils::simple_target_socket<timer> soc;

	inline void set_period(sc_core::sc_time&);

protected:
	sc_core::sc_time period;
	sc_dt::sc_uint<2> cfg;
	sc_dt::sc_uint<32> cnt;
	sc_dt::sc_uint<32> cnt_reload;
	typedef tlm::tlm_base_protocol_types::tlm_payload_type pl_t;

	void b_transport(pl_t&, sc_core::sc_time&);
	void proc();
	void msg(const pl_t&);
};

void timer::set_period(sc_core::sc_time& t)
{
	period = t;
}

#endif
