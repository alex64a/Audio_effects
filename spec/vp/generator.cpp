#include "generator.hpp"
#include "vp_addr.hpp"
#include <string>
#include <fstream>
#include <tlm_utils/tlm_quantumkeeper.h>

using namespace std;
using namespace sc_core;
using namespace sc_dt;
using namespace tlm;

SC_HAS_PROCESS(generator);
ifstream input_data("input_data.txt");
ofstream filtered_data("filtered_data.txt");

generator::generator(sc_module_name name) : sc_module(name),
											isoc("isoc"),
											gen_isoc("gen_isoc")
{
	SC_THREAD(gen);
}

void generator::gen()
{
	FILE *filtered_data;
	int i = 0;
	int size = 0;
	int size2 = 0;
	int length = 0;
	char coeff[2];
	char *input;
	unsigned char coeffx[16];
	unsigned char *input_audio_data;
	unsigned char *output_audio_data;
	int a = 0;
	int j = 0;
	int ad = 0;
	int p = 0;

	tlm_generic_payload pl;
	tlm_utils::tlm_quantumkeeper qk;
	qk.reset();

	cout << "Enter value of coefficients:" << endl; // na ovaj nacin upisujemo koeficijente preko tastature
	cin.getline(coeff, 17);

	if (strlen(coeff) % 2 != 0)
	{
		coeff[strlen(coeff)] = '0';
	}

	a = 0;
	while ((sscanf(coeff + a, "%2d", &coeffx[j])) == 1)
	{
		printf("%d\n", coeffx[j]);
		a += 2;
		j++;
	}

	// Sending coeff to Filter IP	//ovako mi saljemo coeff u Filter IP
	tlm_command cmd = TLM_WRITE_COMMAND;
	uint64 addr = VP_ADDR_FILTER_COEFF; // VP_ADDR_FILTER_COEFF
	unsigned int number_of_coeff = j;

	sc_time offset;
	pl.set_command(cmd);
	pl.set_address(addr);
	pl.set_data_ptr(coeffx);
	pl.set_data_length(number_of_coeff);
	pl.set_response_status(TLM_INCOMPLETE_RESPONSE);

	qk.inc(sc_time(40, SC_NS));
	offset = qk.get_local_time();
	isoc->b_transport(pl, offset);
	qk.set_and_sync(offset);

	if (input_data.is_open())
	{
		input_data.seekg(0, input_data.end);
		size = input_data.tellg();
		input_data.seekg(0, input_data.beg);
		input = new char[size];
		input_data.read(input, size);
		printf("SIZE:%d\n", size);
	}

	if (input[size - 1] == 10)
	{
		input[size - 1] = '0';
	}

	size2 = (size) / 2;
	printf("input_length:%d\n", size2);
	if (size2 % 16 == 0)
	{
		length = size2;
	}
	else
	{
		length = (size2 / 16) * 16 + 16;
	}
	printf("length:%d\n", length);

	input_audio_data = new unsigned char[size2];
	output_audio_data = new unsigned char[length];

	j = 0;
	a = 0;

	while ((sscanf(input + a, "%2d", &input_audio_data[j])) == 1)
	{
		printf("%02d\n", input_audio_data[j]);
		a += 2;
		j++;
	}

	cmd = TLM_WRITE_COMMAND;
	addr = 0;
	unsigned int input_length = j;
	pl.set_command(cmd);
	pl.set_address(addr);
	pl.set_data_ptr(input_audio_data);
	pl.set_data_length(input_length);
	pl.set_response_status(TLM_INCOMPLETE_RESPONSE);

	qk.inc(sc_time(40, SC_NS));
	offset = qk.get_local_time();
	gen_isoc->b_transport(pl, offset);
	qk.set_and_sync(offset);
	cout << "Send input data to memory" << endl;

	while (size2)
	{
		// Sending start bit to FILTER //slanje start bita u Filter IP
		sc_uint<2> filter_ctrl = 1;
		cout << "filter_ctrl :" << filter_ctrl << endl;
		cmd = TLM_WRITE_COMMAND;
		addr = VP_ADDR_FILTER_CSR;
		unsigned int data_length = 1;
		pl.set_command(cmd);
		pl.set_address(addr);
		pl.set_data_ptr((unsigned char *)&filter_ctrl);
		pl.set_data_length(data_length);
		pl.set_response_status(TLM_INCOMPLETE_RESPONSE);
		cout << "Send start bit to Filter IP:" << endl;
		qk.inc(sc_time(40, SC_NS));
		offset = qk.get_local_time();
		isoc->b_transport(pl, offset);
		qk.set_and_sync(offset);

		// Sending source address to DMA
		sc_uint<32> saddr = ad * 16;
		cmd = TLM_WRITE_COMMAND;
		addr = VP_ADDR_DMA_SAR;
		data_length = 4;
		pl.set_command(cmd);
		pl.set_address(addr);
		pl.set_data_ptr((unsigned char *)&saddr);
		pl.set_data_length(data_length);
		pl.set_response_status(TLM_INCOMPLETE_RESPONSE);
		cout << "Send saddr to DMA" << endl;
		qk.inc(sc_time(40, SC_NS));
		offset = qk.get_local_time();
		isoc->b_transport(pl, offset);
		qk.set_and_sync(offset);

		// Sending cnt to DMA
		sc_uint<32> cnt = 16;
		cmd = TLM_WRITE_COMMAND;
		addr = VP_ADDR_DMA_CNT;
		data_length = 4;
		pl.set_command(cmd);
		pl.set_address(addr);
		pl.set_data_ptr((unsigned char *)&cnt);
		pl.set_data_length(data_length);
		pl.set_response_status(TLM_INCOMPLETE_RESPONSE);
		cout << "Send cnt to DMA" << endl;
		qk.inc(sc_time(40, SC_NS));
		offset = qk.get_local_time();
		isoc->b_transport(pl, offset);
		qk.set_and_sync(offset);

		// Sending destination address to DMA
		sc_uint<32> daddr = VP_ADDR_FILTER;
		cmd = TLM_WRITE_COMMAND;
		addr = VP_ADDR_DMA_DAR;
		data_length = 4;
		pl.set_command(cmd);
		pl.set_address(addr);
		pl.set_data_ptr((unsigned char *)&daddr);
		pl.set_data_length(data_length);
		pl.set_response_status(TLM_INCOMPLETE_RESPONSE);
		cout << "Send daddr to DMA" << endl;
		qk.inc(sc_time(40, SC_NS));
		offset = qk.get_local_time();
		isoc->b_transport(pl, offset);
		qk.set_and_sync(offset);

		// Sending start bit to DMA
		sc_uint<2> dma_ctrl = 1;
		cmd = TLM_WRITE_COMMAND;
		addr = VP_ADDR_DMA_CSR;
		data_length = 1;
		pl.set_command(cmd);
		pl.set_address(addr);
		pl.set_data_ptr((unsigned char *)&dma_ctrl);
		pl.set_data_length(data_length);
		pl.set_response_status(TLM_INCOMPLETE_RESPONSE);
		cout << "Send start bit to DMA" << endl;
		qk.inc(sc_time(40, SC_NS));
		offset = qk.get_local_time();
		isoc->b_transport(pl, offset);
		qk.set_and_sync(offset);

		// Waiting to receive done bit from DMA
		do
		{
			cmd = TLM_READ_COMMAND;
			addr = VP_ADDR_DMA_CSR;
			data_length = 1;
			pl.set_command(cmd);
			pl.set_address(addr);
			pl.set_data_ptr((unsigned char *)&dma_ctrl);
			pl.set_data_length(data_length);
			pl.set_response_status(TLM_INCOMPLETE_RESPONSE);
			cout << "Receive done bit from DMA" << endl;
			qk.inc(sc_time(40, SC_NS));
			offset = qk.get_local_time();
			isoc->b_transport(pl, offset);
			qk.set_and_sync(offset);
		} while (dma_ctrl != 0x2);

		// Waiting to receive done bit from FILTER //cekamo da dobijemo done bit od filter IP-a
		do
		{
			cmd = TLM_READ_COMMAND;
			addr = VP_ADDR_FILTER_CSR;
			data_length = 1;
			pl.set_command(cmd);
			pl.set_address(addr);
			pl.set_data_ptr((unsigned char *)&filter_ctrl);
			pl.set_data_length(data_length);
			pl.set_response_status(TLM_INCOMPLETE_RESPONSE);
			cout << "Receive done bit from Filter" << endl;
			qk.inc(sc_time(40, SC_NS));
			offset = qk.get_local_time();
			isoc->b_transport(pl, offset);
			qk.set_and_sync(offset);
		} while (filter_ctrl != 0x2);

		cout << "Filtering done at: " << sc_time_stamp() << endl; // informacija o tome kada se završila obrada signala

		// Sending source address to DMA
		saddr = length + ad * 16 + 1;
		cmd = TLM_WRITE_COMMAND;
		addr = VP_ADDR_DMA_SAR;
		data_length = 4;
		pl.set_command(cmd);
		pl.set_address(addr);
		pl.set_data_ptr((unsigned char *)&saddr);
		pl.set_data_length(data_length);
		pl.set_response_status(TLM_INCOMPLETE_RESPONSE);
		cout << "Send saddr to DMA" << endl;
		qk.inc(sc_time(40, SC_NS));
		offset = qk.get_local_time();
		isoc->b_transport(pl, offset);
		qk.set_and_sync(offset);

		// Sending cnt to DMA
		cnt = 16;
		cmd = TLM_WRITE_COMMAND;
		addr = VP_ADDR_DMA_CNT;
		data_length = 4;
		pl.set_command(cmd);
		pl.set_address(addr);
		pl.set_data_ptr((unsigned char *)&cnt);
		pl.set_data_length(data_length);
		pl.set_response_status(TLM_INCOMPLETE_RESPONSE);
		cout << "Send cnt to DMA" << endl;
		qk.inc(sc_time(40, SC_NS));
		offset = qk.get_local_time();
		isoc->b_transport(pl, offset);
		qk.set_and_sync(offset);

		// Sending destination address to DMA
		daddr = VP_ADDR_MEM;
		cmd = TLM_WRITE_COMMAND;
		addr = VP_ADDR_DMA_DAR;
		data_length = 4;
		pl.set_command(cmd);
		pl.set_address(addr);
		pl.set_data_ptr((unsigned char *)&daddr);
		pl.set_data_length(data_length);
		pl.set_response_status(TLM_INCOMPLETE_RESPONSE);
		cout << "Send daddr to DMA" << endl;
		qk.inc(sc_time(40, SC_NS));
		offset = qk.get_local_time();
		isoc->b_transport(pl, offset);
		qk.set_and_sync(offset);

		// Sending start bit to DMA
		dma_ctrl = 1;
		cmd = TLM_WRITE_COMMAND;
		addr = VP_ADDR_DMA_CSR;
		data_length = 1;
		pl.set_command(cmd);
		pl.set_address(addr);
		pl.set_data_ptr((unsigned char *)&dma_ctrl);
		pl.set_data_length(data_length);
		pl.set_response_status(TLM_INCOMPLETE_RESPONSE);
		cout << "Send start bit to DMA" << endl;
		qk.inc(sc_time(40, SC_NS));
		offset = qk.get_local_time();
		isoc->b_transport(pl, offset);
		qk.set_and_sync(offset);

		// Waiting to receive done bit from DMA
		do
		{
			cmd = TLM_READ_COMMAND;
			addr = VP_ADDR_DMA_CSR;
			data_length = 1;
			pl.set_command(cmd);
			pl.set_address(addr);
			pl.set_data_ptr((unsigned char *)&dma_ctrl);
			pl.set_data_length(data_length);
			pl.set_response_status(TLM_INCOMPLETE_RESPONSE);
			cout << "Receive done bit from DMA" << endl;
			qk.inc(sc_time(40, SC_NS));
			offset = qk.get_local_time();
			isoc->b_transport(pl, offset);
			qk.set_and_sync(offset);
		} while (dma_ctrl != 0x2);

		ad++;
		if (size2 > 16)
		{
			size2 = size2 - 16;
		}
		else
		{
			size2 = 0;
		}
	}

	// Receiving filtered_data from memory // primanje obrađenog podatka iz memorije
	cmd = TLM_READ_COMMAND;
	addr = length + 1;
	unsigned int output_length = length;
	pl.set_command(cmd);
	pl.set_address(addr);
	pl.set_data_ptr(output_audio_data);
	pl.set_data_length(output_length);
	pl.set_response_status(TLM_INCOMPLETE_RESPONSE);
	cout << "Receive filtered_data from memory" << endl;
	qk.inc(sc_time(40, SC_NS));
	offset = qk.get_local_time();
	gen_isoc->b_transport(pl, offset);
	qk.set_and_sync(offset);

	filtered_data = fopen("filtered_data.txt", "w");

	a = 1;
	while (length)
	{
		for (i = p; i < 16 * a; i++)
		{
			fprintf(filtered_data, "%02x\t", output_audio_data[i]);
		}
		fprintf(filtered_data, "\n");

		length = length - 16;
		p = 16 * a;
		a++;
	}

	input_data.close();
	fclose(filtered_data);
	free(input);
	free(input_audio_data);
	free(output_audio_data);
}

void generator::msg(const pl_t& pl) {


  stringstream ss;
  ss << hex << pl.get_address();
  sc_uint<8> val = *((sc_uint<8>*)pl.get_data_ptr());
	string cmd  = pl.get_command() == TLM_READ_COMMAND ? "read  " : "write ";
	string msg = cmd + "val: " + to_string((int)val) + " adr: " + ss.str();
	msg += " @ " + sc_time_stamp().to_string();

	SC_REPORT_INFO("GENERATOR", msg.c_str());



}
