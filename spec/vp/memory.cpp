#include "memory.hpp"

using namespace std;
using namespace sc_core;
using namespace tlm;
using namespace sc_dt;

memory::memory(sc_module_name name):
  sc_module(name),
  tsoc("tsoc"),
  mem_tsoc("mem_tsoc")
{
	tsoc.register_b_transport(this, &memory::b_transport);
	mem_tsoc.register_b_transport(this, &memory::b_transport);
 	for(int i = 0; i < DRAM_SIZE; i++)
	{
   		dram[i] = 0;
	}

}

void memory::b_transport(pl_t& pl, sc_time& offset)
{
	tlm_command cmd    = pl.get_command();
	uint64 adr         = pl.get_address();
	unsigned char *buf = pl.get_data_ptr();
	unsigned int len   = pl.get_data_length();

	switch(cmd)
    {
    case TLM_WRITE_COMMAND:
      for (unsigned int i = 0; i != len; ++i)
        {
          dram[adr++] = buf[i];
        }
      pl.set_response_status( TLM_OK_RESPONSE );
      break;
    case TLM_READ_COMMAND:
      for (unsigned int i = 0; i != len; ++i)
        {
          buf[i] = dram[adr++];
        }
      pl.set_response_status( TLM_OK_RESPONSE );
      break;
    default:
      pl.set_response_status( TLM_COMMAND_ERROR_RESPONSE );
    }

  offset += sc_time(10, SC_NS);
 
  cout << "**********MEMORY**********" << endl;
  for (int i = 0; i < 550; i++)
  {
	  printf("%d: %02x\t",i,dram[i]);  
  
  }
  cout << endl;
}

void memory::msg(const pl_t& pl) {


  stringstream ss;
  ss << hex << pl.get_address();
  sc_uint<8> val = *((sc_uint<8>*)pl.get_data_ptr());
	string cmd  = pl.get_command() == TLM_READ_COMMAND ? "read  " : "write ";
	string msg = cmd + "val: " + to_string((int)val) + " adr: " + ss.str();
	msg += " @ " + sc_time_stamp().to_string();

	SC_REPORT_INFO("MEMORY", msg.c_str());



}
