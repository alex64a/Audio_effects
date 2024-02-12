#include "tb_vp.hpp"
#include "vp_addr.hpp"
#include <string>
#include <tlm_utils/tlm_quantumkeeper.h>

using namespace sc_core;
using namespace sc_dt;
using namespace std;
using namespace tlm;

SC_HAS_PROCESS(tb_vp);

tb_vp::tb_vp(sc_module_name name):
	sc_module(name)
{
	SC_THREAD(test);
}

void tb_vp::test()
{
	sc_time loct;
	tlm_generic_payload pl;
	tlm_utils::tlm_quantumkeeper qk;
	qk.reset();

	//**********************************************************************
	// Test FILETE every 5 ns
	//**********************************************************************
	for (int i = 0; i != 10; ++i)
	{
		sc_uint<8> val = i+1;
		pl.set_address(VP_ADDR_FILTER);
		pl.set_command(TLM_WRITE_COMMAND);
		pl.set_data_length(1);
		pl.set_data_ptr((unsigned char*)&val);

		isoc->b_transport(pl, loct);
		qk.set_and_sync(loct);
		msg(pl);

		loct += sc_time(5, SC_NS);
	}

	//**********************************************************************
	// Configure timer
	//**********************************************************************
	sc_uint<32> val = 0x00001000;
	pl.set_address(VP_ADDR_TIMER_RLD);
	pl.set_command(TLM_WRITE_COMMAND);
	pl.set_data_length(1);
	pl.set_data_ptr((unsigned char*)&val);
	isoc->b_transport(pl, loct);
	msg(pl);
	qk.set_and_sync(loct);

	sc_uint<2> cfg = 1;
	pl.set_address(VP_ADDR_TIMER_CFG);
	pl.set_command(TLM_WRITE_COMMAND);
	pl.set_data_length(1);
	pl.set_data_ptr((unsigned char*)&cfg);
	isoc->b_transport(pl, loct);
	msg(pl);
	qk.set_and_sync(loct);

	//**********************************************************************
	// Wait until timer is done.
	//**********************************************************************
	while(1)
	{
		sc_uint<32> tmp;
		pl.set_address(VP_ADDR_TIMER_CFG);
		pl.set_command(TLM_READ_COMMAND);
		pl.set_data_length(1);
		pl.set_data_ptr((unsigned char*)&tmp);
		isoc->b_transport(pl, loct);
		msg(pl);
		qk.set_and_sync(loct);

		if (tmp & 0x2) break;
		else
		{
			qk.set_and_sync(qk.get_local_time() + sc_time(200, SC_NS));
			loct = qk.get_local_time();
			SC_REPORT_INFO("TB", string("Synced @ " +
								  sc_time_stamp().to_string()).c_str());
		}
	}

	//**********************************************************************
	// Wait 1 more micro second and finish simulation.
	//**********************************************************************
	qk.inc(sc_time(1, SC_US));
	qk.sync();
	sc_stop();
}


void tb_vp::msg(const pl_t& pl)
{
	static int trcnt = 0;
	stringstream ss;
	ss << hex << pl.get_address();
	sc_uint<32> val = *((sc_uint<32>*)pl.get_data_ptr());

	string msg = "val: " + to_string((int)val) + " adr: " + ss.str();
	msg += " @ " + sc_time_stamp().to_string();

	SC_REPORT_INFO("TB", msg.c_str());
	trcnt++;
	SC_REPORT_INFO("TB", ("------------" + to_string(trcnt)).c_str());
}
