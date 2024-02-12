#include <iostream>
#include <fstream>
#include <vector>
#include <cstdio>
#include <string.h>
#include <stdexcept>
#include "filter.hpp"
#include "vp_addr.hpp"

using namespace std;

using namespace sc_core;
using namespace sc_dt;
using namespace tlm;

filter::filter(sc_module_name name) : sc_channel(name),
									  filter_tsoc("filter_tsoc")
{
	filter_tsoc.register_b_transport(this, &filter::b_transport);
}

// funkcija pomocu koje upisujemo podatak koji zelimo da filtriramo
void filter::write(const Data &data)
{

	if (ctrl & 0x1)
	{
		cout << "Data written in Filter IP" << endl;
		// din[cnt] = data.byte;
		din.push_back(data.byte);
		cnt = cnt + 1;
		//	cout << "DEBUG" << endl;
		if (data.last)
		{
			cnt = 0;
			cout << "Input data" << endl;
			for (int i = 0; i < din.size(); i++)
			{
				printf("%d: %d\t", i, din[i]);
			}
			cout << endl;
			dout.resize(din.size());
			filter_function(din, dout, coef);
			ctrl = 0x2;
			cout << "Output data " << dout.size() << endl;
			for (int i = 0; i < dout.size(); i++)
			{
				printf("%d: %d\t", i, dout[i]);
			}
			cout << endl;
		}
	}
}

void filter::read(Data &data, int i)
{
	data.byte = 0;
	for (int i = 0; i < din.size(); i++)
	{
		data.byte = dout[i];
	}
	// data.byte = dout;
	printf("%2d\t", data.byte);

	cout << endl;
}

void filter::b_transport(pl_t &pl, sc_core::sc_time &offset)
{

	tlm_command cmd = pl.get_command();
	sc_dt::uint64 addr = pl.get_address();
	unsigned char *data = pl.get_data_ptr();
	unsigned int length = pl.get_data_length();
	cout << "cmd" << cmd << endl;
	cout << "filter_addr" << FILTER_COEFF << endl;

	switch (cmd)
	{

	case TLM_WRITE_COMMAND:

		switch (addr)
		{

		case FILTER_CSR:

			ctrl = *((sc_uint<2> *)data);
			cout << "FILTER_CSR = " << ctrl << endl;
			pl.set_response_status(TLM_OK_RESPONSE);
			offset += sc_time(2000, SC_NS);
			break;

		case FILTER_COEFF:

			for (int i = 0; i < length; i++)
			{

				coef.push_back(data[i]);
				// printf("%d, %d i value is", i, length);
			}

			cout << addr << endl;

			cout << "***********COEFFS IN FILTER***********" << endl;
			for (int i = 0; i < 16; i++)
			{
				printf("%d: %d\t", i, coef[i]);
			}
			cout << endl;
			// char* p;
			// cin.getline(p,17);
			pl.set_response_status(TLM_OK_RESPONSE);
			// printf("Printing coeff %lf\t", coef);
			break;
		default:

			pl.set_response_status(TLM_ADDRESS_ERROR_RESPONSE);
			break;
		}
		break;

	case TLM_READ_COMMAND:
		switch (addr)
		{
		case FILTER_CSR:
			memcpy(data, &ctrl, sizeof(ctrl));
			cout << "Filter_CSR = " << ctrl << endl;
			pl.set_response_status(TLM_OK_RESPONSE);
			break;
		default:
			pl.set_response_status(TLM_ADDRESS_ERROR_RESPONSE);
			break;
		}
		break;

	default:
		pl.set_response_status(TLM_COMMAND_ERROR_RESPONSE);
		break;
	}

	offset += sc_time(10, SC_NS);
}

// Filter funkcija koju koristimo za filtriranje podataka
void filter::filter_function(const vector<unsigned char> &din, vector<unsigned char> &dout, vector<double> coef)
{
	for (int i = 0; i < din.size(); i++)
	{
		printf("%d: %d\t", i, din[i]);
	}
	for (int i = 0; i < din.size(); i++)
	{
		for (int j = 0; j < coef.size(); j++)
		{
			if (i - j < 0)
			{
				continue;
			}

			dout[i] += din[i - j] * coef[j];
		}
	}
}

void filter::msg(const pl_t& pl) {


  stringstream ss;
  ss << hex << pl.get_address();
  sc_uint<8> val = *((sc_uint<8>*)pl.get_data_ptr());
	string cmd  = pl.get_command() == TLM_READ_COMMAND ? "read  " : "write ";
	string msg = cmd + "val: " + to_string((int)val) + " adr: " + ss.str();
	msg += " @ " + sc_time_stamp().to_string();

	SC_REPORT_INFO("FILTER", msg.c_str());



}
