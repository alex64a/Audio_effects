#include "timer.hpp"
#include <tlm>
#include <tlm_utils/tlm_quantumkeeper.h>

using namespace sc_core;
using namespace sc_dt;
using namespace std;
using namespace tlm;

SC_HAS_PROCESS(timer);

timer::timer(sc_module_name name):
	sc_module(name),
	soc("soc"),
	period(1, SC_NS),
	cfg(0)
{
	soc.register_b_transport(this, &timer::b_transport);
	SC_THREAD(proc);
}

void timer::b_transport(pl_t& pl, sc_time& offset)
{
	tlm_command    cmd  = pl.get_command();
	uint64         addr = pl.get_address();
	unsigned char* data = pl.get_data_ptr();

	switch(cmd)
	{
	case TLM_WRITE_COMMAND:
	{
		switch(addr)
		{
		case TIMER_CFG:
			cfg = *((sc_uint<2>*)data);
			if (cfg & 0x1)
				cnt = cnt_reload;
			pl.set_response_status( TLM_OK_RESPONSE );
			break;
		case TIMER_CNT:
			cnt = *((sc_uint<32>*)data);
			pl.set_response_status( TLM_OK_RESPONSE );
			break;
		case TIMER_RLD:
			cnt_reload = *((sc_uint<32>*)data);
			pl.set_response_status( TLM_OK_RESPONSE );
			break;
		default:
			pl.set_response_status( TLM_ADDRESS_ERROR_RESPONSE );
			break;
		}
		break;
	}
	case TLM_READ_COMMAND:
	{
		switch(addr)
		{
		case TIMER_CFG:
			memcpy(data, &cfg, sizeof(cfg));
			pl.set_response_status( TLM_OK_RESPONSE );
			break;
		case TIMER_CNT:
			memcpy(data, &cnt, sizeof(cnt));
			pl.set_response_status( TLM_OK_RESPONSE );
			break;
		case TIMER_RLD:
			memcpy(data, &cnt_reload, sizeof(cnt_reload));
			pl.set_response_status( TLM_OK_RESPONSE );
			break;
		default:
			cout << "TIMER bad address.\n";
			pl.set_response_status( TLM_ADDRESS_ERROR_RESPONSE );
			break;
		}
		break;
	}
	default:
		pl.set_response_status( TLM_COMMAND_ERROR_RESPONSE );
		SC_REPORT_ERROR("TIMER", "TLM bad command");
		break;
	}

	msg(pl);
	offset += sc_time(4, SC_NS);
}

void timer::msg(const pl_t& pl)
{
	stringstream ss;
	ss << hex << pl.get_address();
	sc_uint<32> val = *((sc_uint<32>*)pl.get_data_ptr());
	string cmd  = pl.get_command() == TLM_READ_COMMAND ? "read  " : "write ";

	string regname;
	switch(pl.get_address())
	{
	case 0: regname = "CFG"; break;
	case 1: regname = "CNT"; break;
	case 2: regname = "RLD"; break;
	default: regname = "no reg";
	}

	string msg = cmd + "val: " + to_string((int)val) + " adr: " + ss.str();
	msg += " " + regname;
	msg += " @ " + sc_time_stamp().to_string();

	SC_REPORT_INFO("TIMER", msg.c_str());
}

void timer::proc()
{
	tlm_utils::tlm_quantumkeeper qk;
	qk.reset();

	while(1)
	{
		if(cfg & 0x1)
		{
			cnt--;
			if(cnt == 0)
			{
				cfg |= 0x2;
				cnt = cnt_reload;
				SC_REPORT_INFO("TIMER", "Counter expired");
			}
		}
		qk.inc(period);
		if (qk.need_sync())
		{
			qk.sync();
			SC_REPORT_INFO("TIMER", string(
							   "Synced @ " +
							   sc_time_stamp().to_string()).c_str());
		}
	}
}
