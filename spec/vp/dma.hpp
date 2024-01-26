#ifndef _DMA_HPP_
#define _DMA_HPP_

#include <systemc>
#include "filter_ifs.hpp"
#include <tlm>
#include <tlm_utils/simple_target_socket.h>
#include <tlm_utils/simple_initiator_socket.h>

const sc_dt::uint64 DMA_CSR = 0; // Control and Status Register
const sc_dt::uint64 DMA_SAR = 1; // Source Address Register
const sc_dt::uint64 DMA_CNT = 2; // Count Register
const sc_dt::uint64 DMA_DAR = 3; // Destination Address Register

class dma : public sc_core::sc_module
{
public:
	dma(sc_core::sc_module_name);
	tlm_utils::simple_target_socket<dma> dma_tsoc;
	tlm_utils::simple_initiator_socket<dma> dma_isoc;
	sc_core::sc_port<filter_write_if> wr_port;
	sc_core::sc_port<filter_read_if> rd_port;

protected:
	sc_dt::sc_uint<2> ctrl;
	sc_dt::sc_uint<32> saddr;
	sc_dt::sc_uint<32> cnt;
	sc_dt::sc_uint<32> daddr;

	typedef tlm::tlm_base_protocol_types::tlm_payload_type pl_t;
	void b_transport(pl_t &, sc_core::sc_time &);
	void dm();
};

#endif
